function [res1,res2,res3]=ms_quali_d()
 
global GROCERDIR;
 
 
load(GROCERDIR+'/data/enq5.dat')
bounds()
 
nbquantiles=[3,0];// 3 quantiles
nblatent=1;// 1 latent state
 
// first estimate a model with 3 states
// with the option testna=%f because of lacking data
res1=ms_quali('KERN',nbquantiles,nblatent,'delts(3,B_ACTPA)','delts(3,C_VENPA)',...
'delts(3,I_PROPA)','delts(3,I_GOULOT)','delts(3,S_CAPA)','nbstates=3','testna=%f')
 
// as indicated by the estimation, impose that a high state cannot
// jump to a low one with the option 'nojump'
res2=ms_quali('KERN',[3,0],1,'delts(3,B_ACTPA)','delts(3,C_VENPA)',...
'delts(3,I_PROPA)','delts(3,I_GOULOT)','delts(3,S_CAPA)','nbstates=3','testna=%f','nojump')
 
// now estimate with Gregoir and Lenglart 2 states formulation
nbquantiles=[2,0];// 2 quantiles
nblatent=2;// 2 latent states
res3=ms_quali('KERN',nbquantiles,nblatent,'delts(3,B_ACTPA)',...
'delts(3,C_VENPA)','delts(3,I_PROPA)','delts(3,I_GOULOT)','delts(3,S_CAPA)','testna=%f')
 
// compare the indicators
ind2=res2ts(res2,'filtered indicator')
ind3=res2ts(res3,'filtered indicator')
pltseries('ind2','ind3','title=standard and Gregoir Lenglart turning point indicator','leg=standard;Gregoir-Lenglart')
 
endfunction
 
