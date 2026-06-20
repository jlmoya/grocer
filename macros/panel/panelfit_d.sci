function panelfit_d()
 
// The followig program uses the data from " Introduction to the Theory and Practice of
//  Econometrics "(Judge, Hill, Griffiths, L�tkepohl and Lee) Second Edition.
//  Chapter 11 pages 476-479 and pages 487-488, as an example to test the procedures for
//  panel data estimation and display adjustement.
 
global GROCERDIR ;

load(GROCERDIR+'\macros\grocer\db\judgepanel.dat')     // Judge Example with Balanced Panel
 
//  Fixed Effects Estimation
r1 = pfixed('y',judgepanel);
 
// Compute adjustement
rfit = panelfit(r1,judgepanel);
 
endfunction
