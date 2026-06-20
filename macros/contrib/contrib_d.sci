function [rols]=contrib_d()
 
// PURPOSE: contributions from the money equation # (6)
// in D.F Hendry et N.R Ericsson (1991): "Modeling the demand
// for narrow money in the United Kingdom and the United
// States", European Economic Review, p833-886.
// ------------------------------------------------------------
// INPUT:
// nothing
// ------------------------------------------------------------
// OUPTUT:
// * rols = the results tlist of the ordianry least squares
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
m1=exp(lm1)
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// estimate the model by ols and save the results in the tlist
// rols; names are entered between quotes, in order that their
// names appears on the printed results
 
rols=ols('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1-lp-ly))','rnet'...
,'lagts(1,lm1-lp-ly)','cte')
 
// retrieve the coeficients of the regression
coef=rols('beta')
 
// calculate the residual over the whole period
resid=delts(lm1-lp)-coef(1)*delts(lp)-coef(2)*delts(lagts(1,lm1-lp-ly))-coef(3)*rnet...
-coef(4)*lagts(1,lm1-lp-ly)-coef(5)
 
bounds() ;
 
// calculate the ma infinite approximations
mainf_lp=mainf([1+coef(2)+coef(4) ; -coef(2)],...
[1+coef(1) ; -1-coef(1)-coef(2)-coef(4) ; coef(2) ],200)
mainf_ly=mainf([1+coef(2)+coef(4) ; -coef(2)],...
[0 ; -coef(2)-coef(4) ; coef(2) ],200)
mainf_resid=mainf([1+coef(2)+coef(4) ; -coef(2)],...
1,200)
mainf_rnet=coef(3)*mainf_resid
 
// calculate the contributions
contrib_lp=contrib(delts(lp),mainf_lp)
contrib_ly=contrib(delts(ly),mainf_ly)
contrib_resid=contrib(delts(resid),mainf_resid)
contrib_rnet=contrib(delts(rnet),mainf_rnet)
 
//
prtts('contrib_lp','contrib_ly','contrib_resid','contrib_rnet',...
'delts(lm1)-contrib_lp-contrib_ly-contrib_resid-contrib_rnet')
 
// now calculates annual growthr contributions
 
he_lp_list=list('lp',[1+coef(2)+coef(4) ; -coef(2)],[1+coef(1) ; -1-coef(1)-coef(2)-coef(4) ; coef(2) ])
he_ly_list=list('ly',[1+coef(2)+coef(4) ; -coef(2)],[0 ; -coef(2)-coef(4) ; coef(2) ])
he_rnet_list=list('rnet',[1+coef(2)+coef(4) ; -coef(2)],coef(3))
he_resid_list=list('resid',[1+coef(2)+coef(4) ; -coef(2)],1)
 
[listcont_unbal,listcont_bal]=contrib_logq2gra('m1',he_lp_list,he_ly_list,he_rnet_list,he_resid_list,'prt=all')
 
txm1=growthr(q2a(m1,0))
contrib_p=listcont_unbal(1)
contrib_y=listcont_unbal(2)
contrib_rnet=listcont_unbal(3)
contrib_resid=listcont_unbal(4)
 
pltseries('txm1','contrib_p','contrib_y','contrib_rnet','contrib_resid','title=uk m1: growth rate and contributions to','bars=[0 1 1 1 1]','styleg=4')
endfunction
