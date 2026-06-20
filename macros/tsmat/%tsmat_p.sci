function %tsmat_p(tsmat)
 
// PURPOSE: provide a user friendly display of tsmat
// ------------------------------------------------------------
// INPUT:
// * tsmat = a tlist of type tsmat
// ------------------------------------------------------------
// OUTPUT:
// * nothing: the content of the tsmat is displayed on screen
// ------------------------------------------------------------
// Copyright Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
 
s=tsmat('series')
fq=tsmat('freq')
dat=tsmat('dates')
nam=tsmat('names')
 
if size(s,2) > 20 then
   write(%io(2),'tsmat has more than 20 variables; use prt_tsmat to display it','(a)')
 
else
   if fq == [365 1] then
      indnonna=or(~isnan(s),'c')
      dat=dat(indnonna)
      s=s(indnonna,:)
   end
 
   s=[nam' ; string(s)]
   datlit=[' ' ; num2date(dat,fq) ]
 
   L1=max(length(datlit)) ;
 
   t=part(datlit,1:L1+1)
   if size(tsmat(1),1) > 5 then
      com=tsmat('comments')
      nlines_com=zeros(size(s,2),1)
      L2=nlines_com
      for i=1:size(s,2)
      // do the concatenation of the columns
         L2(i)=max(length(s(:,i))) ;
         t=t+part(s(:,i),1:L2(i)+1)
         nlines_com(i)=ceil(length(com(i))/L2(i)) ;
      end
      t2=emptystr(max(nlines_com),1)+part(' ',1:L1+1)
      for i=1:size(com,1)
         if nlines_com(i) == 1 then
            t2(1:nlines_com(i))=t2(1:nlines_com(i))+part(com(i),1:L2(i)+1)
         else
            t2(1:nlines_com(i))=t2(1:nlines_com(i))+part(strsplit(com(i),L2(i):L2(i):L2(i)*(nlines_com(i)-1)),1:L2(i)+1)
         end
         if nlines_com(i)  ~= max(nlines_com)
            t2(nlines_com(i)+1:$)=t2(nlines_com(i)+1:$)+part(' ',1:L2(i)+1)
         end
      end
      t=[t(1) ; t2 ; t(2:$)]
 
   else
      for i=1:size(s,2)
      // do the concatenation of the columns
         L2=max(length(s(:,i))) ;
         t=t+part(s(:,i),1:L2+1)
      end
   end
   write(%io(2),t,'(a)')
end
 
endfunction
 
