function rmcd = mcd(x,h);
 
// PURPOSE: calculates the months of cyclical dominance of a series
//---------------------------------------------------------
// INPUT:
// * x   = original time series
// * h   = limit
// -------------------------------------------------------------
// OUTPUT:
// * rmcd = months of cyclical dominance
// -------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss proprams by M. Watson
 
 
nd = size(x,1);
c=spencer(x);
i=x - c;
mcdv=zeros(h,1);
 
for j = 1:h
   num=sum(abs(i(1+j:nd)-i(1:nd-j)),1);
   den=sum(abs(c(1+j:nd)-c(1:nd-j)),1);
   mcdv(j,1)=num/den;
end;
 
rmcd=0;
k =1;
while rmcd==0;
   if mcdv(k,1) < 1 then ;
      rmcd=k;
   end;
 
   if k==h;
      write(%io(2),"MCD is beyond the given h-limit. Increase h!",'(a)');
      break;
   end;
   k=k+1
end;
endfunction
