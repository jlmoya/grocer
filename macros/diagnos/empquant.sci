function [y] = empquant(runs,q)
 
// PURPOSE: function called by function raftery
// ------------------------------------------------
// REFERENCES: Geweke (1992), `Evaluating the accuracy of sampling-based
// approaches to the calculation of posterior moments'', in J.O. Berger,
// J.M. Bernardo, A.P. Dawid, and A.F.M. Smith (eds.) Proceedings of
// the Fourth Valencia International Meeting on Bayesian Statistics,
// pp. 169-194, Oxford University Press
// Also: `Using simulation methods for Bayesian econometric models:
// Inference, development and communication'', at: www.econ.umn.edu/~bacc
// -----------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
// NOTE: the original Matlab code draws heavily on MATLAB programs
// written by Siddartha Chib available at: www.econ.umn.edu/~bacc
 
n = size(runs,1);
work = gsort(runs,'r','i');// note: this line of code is the one that
// takes by a wide margin the greatest execution time
// this is the one to change to improve the speed of the program...
order = (n - 1)*q + 1;
fract = order-fix(order)
low = max(fix(order),1);
high = min(low+1,n);
y = (1.0 - fract)*work(low) + fract*work(high);
 
endfunction
