function [r0,r1,r2,r3]=panel_d()
 
// The followig program uses the data from " Introduction to the Theory and Practice of
//  Econometrics "(Judge, Hill, Griffiths, Lütkepohl and Lee) Second Edition.
//  Chapter 11 pages 476-479 and pages 487-488, as an example to test the procedures for
//  panel data estimation.

global GROCERDIR ;
load(GROCERDIR+'\data\judgepanel.dat')     // Judge Example with Balanced Panel
 
judgepanel('id')=evstr(judgepanel('id'));
 
//  Pooled Estimation
r0 = ppooled('y',judgepanel,'const');
r0 = ppooled('y',judgepanel,'const','hac=ccm');  
r0 = ppooled('y',judgepanel,'const','hac=nw');  
  
//  Fixed Effects Estimation
r1 = pfixed('y',judgepanel);
r1b = pfixed('y',judgepanel,'hac=ccm');
r1c = pfixed('y',judgepanel,'hac=nw');
r1m = pfixed('y',judgepanel,'hac=mbb');

//  Between Estimation
r2 = pbetween('y',judgepanel);
 
//  Random Effects Estimation
r3 = prandom('y',judgepanel);
 
//  Haussman Test
phaussman(r1,r3);

 
endfunction
