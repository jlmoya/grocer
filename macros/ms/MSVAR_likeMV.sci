function eta=MSVAR_likeMV(Res,Inv_var_mat,det_inv_var_mat,K,M,M_V)
 
// PURPOSE:  Computes the conditional densities eta of a MS-VAR
// model (conditioned upon the state)
// see Hamilton (1994), chap 22 and Krolzig (1997) chap 6
// ------------------------------------------------------------
// INPUT:
// * Res = a (T x M.K) matrix of residuals
// * Inv_var_mat =
//   - either a (K x K) matrix equal to the inverse of the
//     variance-covariance matrix of residuals (independant
//     from the state)
//   - or a (K x K.M) matrix equal to the stacked inverse of
//     the variance-covariance matrices of residuals
// * det_Inv_var_mat =
//   - either a scalar equal to the determinant of inverse of
//      the variance_covariance matrix (independant from the
//      state)
//   - or a (1 x M) stacked vector of the determinants of the
//     inverse of the variance_covariance matrix (independant
//     from the state)
// * K= a scalar equal to the number of endogenosu variables
// * M = a scalar equal to the number of states
// * M_V = a scalar indicating whether the var_cov matrix
//   switches (if M_V=1) or not (if M_V~=1)
// ------------------------------------------------------------
// OUTPUT:
// eta = a (K x 1) vector of conditionnla densities
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
 
M_aux=(Res .*. ones(1,M)) .* (eye(M,M) .*. ones(K,1));
 
// grocer_MS_likeMV is equal to 1 if M_V ==1 and to
// ones(1,M) if M_V~=1
Sig=grocer_MS_MlikeMV .*. inv_var_mat;
Det_Sig=(grocer_MS_MlikeMV .*. det_inv_var_mat)';
 
M_sigma=(eye(M,M) .*. ones(K,K)) .* (ones(M,1).*.Sig)
 
eta=(1/sqrt(2*%pi))^(K)*sqrt(Det_Sig) .* exp(-0.5*diag(M_aux'*M_sigma*M_aux));
 
endfunction
