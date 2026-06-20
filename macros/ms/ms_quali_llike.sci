function l= ms_quali_llike(theta);
 
// PURPOSE: calculate the log-likelihood of a Hidden-Markov-
// Model for the detection of truning points in qualitative
// variables
// ------------------------------------------------------------
// INPUT:
// theta = a (Np X 1) vector of parmaeters
// ------------------------------------------------------------
// OUTPUT:
// l = the log-likelihood of the ms turning point model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated from a Gauss programm by J. Bardaji and F. Tallet
 
fx0=ms_quali_filt(mat_cal,theta);
l=sum(log(fx0))
 
 
endfunction
 
