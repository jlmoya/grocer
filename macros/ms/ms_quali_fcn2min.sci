function [l,g,ind]= ms_quali_fcn2min(theta,ind);
 
// PURPOSE: provide Scilab optimizer with (minus) the log-
// likelihood of a ms turning point model and its numerical
// derivative completed by the compulsory field ind
// ------------------------------------------------------------
// INPUT:
// theta = a (Np X 1) vector of parmaeters
// ------------------------------------------------------------
// OUTPUT:
// * l = the log-likelihood of the ms turning point model
// * g = the gradient of the ms turning point model
// * ind = a compulsory variable for optim
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated from a Gauss programm by J. Bardaji and F. Tallet
 
nbp=size(theta,1)
// calculate minus the log-likelihood (optim is a minimzer
// whereas we want to maximise the log-likelihood)
l=-ms_quali_llike(theta)
// numerical derivative
g=-numz0(ms_quali_llike,theta,nbp,ones(nbp,1),[])
 
 
endfunction
 
