function y = moment_gauss(x,d);
 
// PURPOSE: mimics gauss function moment: computes a
// cross-product matrix. This is the same as x'*x
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix or M-dimensional array where the last
//   two dimensions are (N x k)
// * d = a scalar, controls handling of missing values
//   0: missing values will not be checked for. This is the
//      fastest option.
//   1: “listwise deletion” is used. Any row that contains a
//      missing value in any of its elements is excluded from
//      the computation of the moment matrix. If every row in x
//      contains missing values, then moment(x,1) will return a
//      scalar zero.
//   2: “pairwise deletion” is used. Any element of x that is
//      missing is excluded from the computation of the moment
//      matrix. Note that this is seldom a satisfactory method
//      of handling missing values, and special care must be
//      taken in computing the relevant number of observations
//      and degrees of freedom.
// ------------------------------------------------------------
// OUTPUT:
// * y = (K x K) matrix or M-dimensional array where the last
//   two dimensions are K x K, the cross-product of x
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
select typeof(x)
case 'constant' then
   select d
   case 0 then
      y=x'*x
 
   case 1 then
      x(isnan(sum(x,'c')),:)=[]
      y=x'*x+0
 
   case 2 then
      ncol=size(x,2)
      m=zeros(ncol,ncol)
      for i=1:ncol
         for j=1:i
            xn=[x(:,i) x(:,j)]
            xn(isnan(sum(xn,'c')),:)=[]
            y(i,j)=0+sum(xn(:,1) .* xn(:,2))
            y(j,i)=y(i,j)
         end
      end
 
   else
      error('not an available option in moment_gauss')
   end
 
case 'hypermat' then
   dims=size(x)
   dimsn=dims
   dimsn($-1)=dims($)
   execstr('y=zeros('+strcat(string(dimsn),',')+')')
   str1=emptystr()
   str2=emptystr()
   str4=emptystr()
   ndim=size(dimsn,2)
 
   select d
 
   case 0 then
       for i=1:ndim-2
         str1=str1+'for k'+string(i)+'=1:'+string(dims(i))+';'
         str2=str2+'k'+string(i)+','
         str4=str4+';end'
      end
      str2=str2+':,:)'
      str2n=str2+','+string(dims($-1))+','+string(dims($))+')'
      str=str1+'xn=matrix(x('+str2n+';y('+str2+'=xn''*xn'+str4
      execstr(str)
 
 
   case 1 then
      for i=1:ndim-2
         str1=str1+'for k'+string(i)+'=1:'+string(dims(i))+';'
         str2=str2+'k'+string(i)+','
         str4=str4+';end'
      end
      str2=str2+':,:)'
      str2n=str2+','+string(dims($-1))+','+string(dims($))+')'
      str=str1+'xn=matrix(x('+str2n+';xn(isnan(sum(xn,''c'')),:)=[];y('+str2+'=xn''*xn+0'+str4
      execstr(str)
 
   case 2 then
      ncol=dims($)
      nrow=dims($-1)
      m=zeros(ncol,ncol)
      for i=1:ndim-2
         str1=str1+'for k'+string(i)+'=1:'+string(dims(i))+';'
         str2=str2+'k'+string(i)+','
         str4=str4+';end'
      end
      str1=str1+'for i=1:ncol;for j=1:i;'
      str2n=str2+':,[i j]),nrow,2)'
      str4=str4+';end;end'
      str=str1+'xn=matrix(x('+str2n+';xn(isnan(sum(xn,''c'')),:)=[];y('+str2+'i,j)=0+sum(xn(:,1) .* xn(:,2));y('+str2+'j,i)=y('+str2+'i,j)'+str4
      pause
      execstr(str)
 
   else
      error('not an available option in moment_gauss')
   end
end
 
endfunction
 
