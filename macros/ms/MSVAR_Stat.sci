function [yy_m,yy_med,yy_s,yy_cov,yy_cor] = MSVAR_Stat(M_data);
 
// PURPOSE: Provides basic statistics for the columns of a
// matrix
// ------------------------------------------------------------
// INPUT:
// * M_mat = a (T x K) matrix
// ------------------------------------------------------------
// OUTPUT:
// * yy_m = a (1 x K) vector of means of the columns
// * yy_med = a (1 x K) vector of medians of the columns
// * yy_s = a (1 x K) vector of standard deviations of the
//   columns
// * yy_cov = a (K x K) matrix of covariances of the columns
// * yy_cor = a (1 x K) vector of correlations of the columns
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
yy_m=mean0(M_data,'r');
yy_med=median(M_data,'r');
yy_s=st_dev(M_data,'r');
yy_cov=mvvacov(M_data);
yy_cor=var2cor(yy_cov);
 
endfunction
