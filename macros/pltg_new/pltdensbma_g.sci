function pltdensbma_g(res)
 
// PURPOSE: prints the posterior density function of coefficient
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
// bma_g()
// ---------------------------------------------------
// Copyright E. Michaux (2004)/E. Dubois (2019)
// http://grocer.toolbox.free.fr/grocer.html
 
 
bet = res('beta')
allbeta = res('all beta')
 
vprob = res('vprob')
namex = res('namex')
 
ind_beta2plot=find(vprob>0.05)
for i=size(ind_beta2plot,2):-1:1
   ibet =find(allbeta(:,i) ~= 0)
   sbet = allbeta(ibet',i)
   if size(sbet,1) <= 4 then
      indbeta2plot(i)=[]
   end
end
nbet = size(ind_beta2plot,2)+1
intn = int(sqrt(nbet))
dim1=intn
dim2=intn+1
if dim1*dim2 < nbet then
    dim1=dim2
end
 
scf()
 
subplot(dim1,dim2,1)	
plot2d([],[],axesflag=0)
titlepage(["Posterior density functions";"incl. probability > 5%"])
pos = 2
 
for i = ind_beta2plot
   ibet =find(allbeta(:,i) ~= 0)
   sbet = allbeta(ibet',i)
 
   subplot(dim1,dim2,pos)
   histplot(30,sbet,normalization=%t)
   xtitle(["Variable "+namex(i);"av. :"+string(bet(i))+" prob. :"+string(vprob(i))])
   pos = pos+1
 
end
 
endfunction
