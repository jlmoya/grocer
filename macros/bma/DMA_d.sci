function resdma=DMA_d()

global GROCERDIR ;
 
load(GROCERDIR+'\data\us_modinf.dat')
lGDPDEFL=100*log(GDPDEFL)
lPCECC96=100*log(PCECC96)
lPRFI=100*log(PRFI)
lGDPC96=100*log(GDPC96)
lHOUST=log(HOUST)
bounds('1960q4','2008q3')

resdma=DMA('delts(lGDPDEFL)',...
['const';'delts(lagts(lGDPDEFL))';'delts(lagts(2,lGDPDEFL))'],...
['lagts(UNRATE)';'delts(lagts(lPCECC96))';'delts(lagts(lPRFI))';...
'delts(lagts(lGDPC96))';'lagts(lHOUST)'],0.99,0.99)

// plot the number of expected variables
pltdma_expnbvar(resdma)
// plot the probabilities and expected coefficients 
// of all variables
pltdma_probvar(resdma,'all')
// display the best model at some dates
prtdma_bestmodel(resdma,['1988q3';'1993q3';'1998q3';'2003q3';'2008q3'],%io(2))
   
endfunction




























