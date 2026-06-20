function AndPlob_d()

// This file illustrates the procedures for
// """"Testing for Structural Change in Conditional Models""""


global GROCERDIR;
load(GROCERDIR+'\data\Fra_GDP.dat')
bounds()
rpib=ols('delts(log(Fra_GDP))','const','delts(lagts(log(Fra_GDP)))','delts(lagts(3,log(Fra_GDP)))')
rap=AndPlob(rpib,0.15,0.85);

endfunction
