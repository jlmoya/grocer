function [r]=nls_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/smpt.dat')
timer();
bounds('1980a','1999a')
// first example where intial values are given by the user, coefficient not
// (so nls determines that a1 and a2 are the coefficient to estimate)
// and an option ('maximum # of calls to the function and iterations 100) is set
// (see maxlik for a list of options)
[r]=nls('smptr/lagts(smptr)-1=a1+a2*(lagts(smptr)/lagts(2,smptr)-1-a1)','init=[0.5;0.5]','opt_optim=,''ar'',200,100')
t=timer();
write(%io(2),' ','(a)')
write(%io(2),'time elapsed: '+string(t)+' seconds','(a)')
 
// now an example which shows the time lost with ts
// there are then -at least!- 3 solutions to improve the speed of nls
// when dealing with ts:
// 1) improve the representation of ts (but I don't know how!)
// 2) add an option in nls to let the user define the names of the
// ts used (here it would look like:
// [r]=nls('smptr/lagts(smptr)-1=a1+a2*(lagts(smptr)/lagts(2,smptr)-1-a1)',...
// 'init=[0.5;0.5]','ts=smptr')) and then let nls transform
// ts in vectors (that is automation of what is done below);
// it is feasible (it will need dealing with lagts, growthr, del and
// other funtions which use lags), but a little cumbersome and not elegant
// 3) perform a syntaxic analysis, which should moreover have the advantage to
// allow the achievment of an analytic derivation instead of a numerical one;
// very elegant, but cumbersome indeed!
 
s=series(smptr)
s0=s(3:22)
s1=s(2:21)
s2=s(1:20)
r=nls('s0 ./s1-1=a1+a2*(s1 ./s2-1-a1)','init=[0.5;0.5]')
t=timer();
write(%io(2),' ','(a)')
write(%io(2),'time elapsed: '+string(t)+' seconds','(a)')
endfunction
