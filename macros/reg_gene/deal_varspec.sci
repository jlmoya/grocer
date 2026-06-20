function x=deal_varspec(x,name,j,boun)
 
// PURPOSE: in a matrix replace column j by the evaluation of
// a predifined expression, such as a trend, a dummy, ...
// ------------------------------------------------------------
// INPUT:
// * x = a (T x k) real matrix
// * name = a string
// * j = the affected x column
// ------------------------------------------------------------
// OUTPUT:
// * x = the transformed matrix x
// ------------------------------------------------------------
// NOTE : this function goes hand in hand with the function
// cond_varspec which defines how to recognize the variables
// whose values are implictely defined by their name instead of
// corresponding to a varaible already existing
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2015
// http://grocer.toolbox.free.fr/grocer.html
 
namen=strsubst(name,' ','')
if typeof(boun) ==  'string' then
   nbounds=size(boun,1)
   deldates=ones(nbounds,1)
   boundsnum=date2num_m(boun)
   T=boundsnum($)-boundsnum(1)+1
   // fill a vector of indexes corresponding to the regression dates
   // (important to deal the cases of a fractional period, such as:
   // '1900a' to '1913a' followed by '1919a' to '1939a')
   ind_dates=1:(boundsnum(2)-boundsnum(1)+1)
   for i=2:size(boundsnum,'*')/2
      ind_dates= [ind_dates , [boundsnum(2*i-1):boundsnum(2*i)]-boundsnum(1)+1 ]
   end
   nobs=size(ind_dates,2)
else
   T=size(x,1)
   ind_dates=1:T
end
 
if namen =='cte' | namen == 'const' then
   x(:,j)=1
 
elseif namen == 'trend' then
   t=trend(1,T)
   x(:,j)=t(ind_dates)
 
elseif part(namen,1:6) == 'trend^' then
   namen=evstr(part(namen,7:length(namen)))
   t=trend(namen,T)
   x(:,j)=t(ind_dates)
 
else
   ind_dum=strindex(namen,'dummy(')
   ind_post=strindex(namen,'post(')
   ind_rightp=strindex(namen,')')
 
   for i=size(ind_dum,2):-1:1
      k=find(ind_rightp > ind_dum(i))
      dat=part(namen,ind_dum(i)+6:ind_rightp(k(1))-1)
      deldate=date2num(dat)-boundsnum(1)+1
      // find the index of the date when the dummy is 1
      inddate=find(deldate == ind_dates)
 
      if isempty(inddate) then
         error('dummy('+dat+') is outside the regression bounds')
      end
      execstr('dummy_'+dat+'=zeros(T,1)')
      execstr('dummy_'+dat+'(inddate)=1')
      namen=part(namen,1:ind_dum(i)-1)+'dummy_'+dat+part(namen,ind_rightp(k(1))+1:length(namen))
 
   end
 
   for i=size(ind_post,2):-1:1
      k=find(ind_rightp > ind_post(i))
      dat=part(namen,ind_post(i)+5:ind_rightp(k(1))-1)
      deldate=date2num(dat)-boundsnum(1)+1
      // find the index of the date from which the dummy is 1
      inddum=find(deldate == ind_dates)
 
      if isempty(inddum) then
         error('dummy('+dat+') is outside the regression bounds')
      end
      execstr('post_'+dat+'=zeros(T,1)')
      execstr('post_'+dat+'(inddum:$)=1')
      namen=part(namen,1:ind_post(i)-1)+'post_'+dat+part(namen,ind_rightp(k(1))+1:length(namen))
 
   end
   x(:,j)=evstr(namen)
 
end
 
endfunction
