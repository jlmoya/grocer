function [r1,r2]=garch_d()
 
// PURPOSE: An example using garch(),
//                           prt(),
//                           plt(),
// regression model with garch(1,1) errors
//---------------------------------------------------
// USAGE: garch_d
//---------------------------------------------------
//
// Example taken from Green (2000, page 809.) sort-of.
// The model is implicit price deflator
// regressed on 4 lags with constant term
// Green (2000) reports results based on
// data from 48Q2 to 83Q4,
// with y = 100*log(p(t)/p(t-1))
// whereas here we use y = 100*log(p(t)/p(t-4))
// i.e., annualized rates of change rather than quarterly.
// The results are similar (as we would expect)
//
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/garchd.dat')
 
bounds('1949q1','1983q4')
r1 = ols('gnpdef','cte','lagts(gnpdef)','lagts(2,gnpdef)','lagts(3,gnpdef)','lagts(4,gnpdef)');
// do ols for comparison with Green
 
printsep(%io(2))
 
// test the presence of conditional heteroskedasticty
archz(r1,4)
 
bet = r1('beta');
s = r1('ser');
 
r2 = garch('gnpdef','cte','lagts(gnpdef)','lagts(2,gnpdef)','lagts(3,gnpdef)','lagts(4,gnpdef)',...
'a0=s^2','ar=0','ma=0','b=bet');
 
endfunction
