function prt_faccoeff(res,out)
    
ARF=res('ARF')
MAF=res('MAF')
stdARF=res('stdARF')
stdMAF=res('stdMAF')
 
nbfac=length(ARF)
Q=res('Q')
C=res('C')
R=res('R')
nr=size(R,1)
  
namey=res('namey')
std=res('std')
tstat=res('tstat')
nvar=size(namey,1)
 
 
if nbfac == 1 then
 
   narf=size(ARF(1),'*')
   write(out,' ')
   write(out,'dynamic of the factor')
   write(out,'---------------------')
   write(out,' ')
   mat2print = ['Parameter' 'Estimate'  'Std. Dev.' 't-test']
   if narf ~= 0 then
      mat2print = [mat2print ; 'AR('+string(1:narf)'+')' string([ARF(1) stdARF(1) ARF(1) ./ stdARF(1)]) ]
   end
 
   nmaf=size(MAF(1),'*')
   if nmaf then
      mat2print = [mat2print ; 'MA('+string(1:nmaf)'+')' string([MAF(1) stdMAF(1) MAF(1) ./ stdMAF(1)] )]
   end
   printmat(mat2print,out)
  
else
 
   nH=0
   for i=1:nbfac
      ARFi=ARF(i)
      stdARFi=stdARF(i)
      narfi=size(ARF(i),'*')
      write(out,' ')
      write(out,'dynamic of factor # '+string(i))
      write(out,'*********************')
      write(out,' ')
      mat2print = ['Parameter' 'Estimate'  'Std. Dev.' 't-test']
      if narfi ~= 0 then
         mat2print = [mat2print ; 'AR('+string(1:narfi)'+')' string([ARFi stdARFi (ARFi ./ stdARFi)]) ]
      end
 
      MAFi=MAF(i)
      stdMAFi=stdMAF(i)
      nmafi=size(MAF(i),'*')
      if nmafi then
         mat2print = [mat2print ; 'MA('+string(1:nmafi)'+')' string([MAFi stdMAFi (MAFi ./ stdMAFi )])]
      end
      printmat(mat2print,out)
   end
 
end
write(out,' ') 

endfunction
