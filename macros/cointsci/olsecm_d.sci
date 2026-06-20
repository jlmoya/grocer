function olsecm_d(); 

// PURPOSE: demo program for olsecm 
// Example taken from: N. R. Ericsson & J. G. MacKinnon (2002),
// "Distribution of error correction test for cointegration"
// Econometrics Journal, 5, 285-318
//-----------------------------------------------

global GROCERDIR;
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
bounds('1964q3','1989q2');

// lm1 = log of nominal narrow money
// ly = log of real total final expenditure
// lp = log of real total final expenditure deflator
// rnet = net interest rate

// see equation (30) p. 311 and table (6) p. 312
r=olsecm(2,'delts(lm1-lp)','delts(lagts(lm1-lp-ly))',...
    'coint=[lagts(lm1-lp-ly);lagts(ly);delts(lp);rnet]');

r=olsecm(1,'delts(lm1-lp)','delts(lagts(lm1-lp-ly))',...
    'coint=[lagts(lm1-lp-ly);lagts(ly);delts(lp);rnet]');

r=olsecm(0,'delts(lm1-lp)','delts(lagts(lm1-lp-ly))',...
    'coint=[lagts(lm1-lp-ly);lagts(ly);delts(lp);rnet]');

r=olsecm(-1,'delts(lm1-lp)','delts(lagts(lm1-lp-ly))',...
    'coint=[lagts(lm1-lp-ly);lagts(ly);delts(lp);rnet]');

endfunction
