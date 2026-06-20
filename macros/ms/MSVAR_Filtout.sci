function [Likv,y_hat,resid,PR,PR_STT,PR_STL] = MSVAR_Filtout(r,y,x_mat,z_mat,grocer_MS_M,grocer_MS_K,grocer_MS_M_V)
 
// PURPOSE: computes, thanks to the Kittagawa-Hamilton Filter,
// filtered probabilities P(S(t)=i|I(t)) and P(P(S(t)=i|I(t-1))
// and subproduct such as mu_mean=E(y(t)) which are also useful
// to compute smoothed  probabilities.  Parametr is a vector of
// unconstrained transition martix probabilities
// ------------------------------------------------------------
// INPUT:
// parametr = a (np x 1) vector of parameters
// ------------------------------------------------------------
// OUTPUT:
// * Likv = a scalar equal to the log-likelihood of the model
// * y_hat = a (T x k) matrix of estimated y
// * resid = a (T x k) matrix of residuals
// * PR = a (T x 1) vector of conditional likelihood
// * PR_STT = a (T x M) matrix of filtered probabilities of
//   each state at each date
// * PR_STL = a (T x M) matrix of filtered probabilities of
//   each state at each date, condtionned by the y at date t
// ------------------------------------------------------------
// REFERENCES:
// * Benoit BELLONE: "Classical Estimation of Multivariate
//  Markov-Switching Models using MSVARlib", (2005).
// available at http://bellone.ensae.net
// e-mail: benoit.bellone@ensae.org
// * Adapated courtesy of Hamilton (1989), Hamilton (1994) 			
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
parametr =r('coeff')
grocer_MS_typemod=r('typemod')
[Likv,y_hat,resid,PR,PR_STT,PR_STL] = MSVAR_Filtout(parametr,y,x_mat,z_mat,grocer_MS_M,grocer_MS_K,grocer_MS_M_V)
 
endfunction
