function [Likv,g,ind] = MSVAR_likfcn(param,ind);
 
// PURPOSE: calculates the log-likelihood of a MS-VAR model and
// its derivative with respect to the -unconstrainted-
// parameters
// ------------------------------------------------------------
// INPUT:
// * param = a (n x1) vector of values for the parameters
// * ind = a flag for optim
// ------------------------------------------------------------
// OUTPUT:
// * LIKV = the calculated log-likelihood
// * g = the corresponding gradient
// * ind = the output value of flag for optim
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
// transform the unconstrainted parameters (from -inf to +inf)
// to their constrained counterpart: probabilities should lie
// between 0 and 1
//parametr=MSVAR_Constraint(param);
 
[Likv,y_hat,resid,PR,PR_STT,PR_STL]=MSVAR_Filt(param);
np=size(param,1)
g=ones(np,1)
for i=1:np
   aux=[zeros(i-1,1);grocer_gdelta*param(i)+sqrt(%eps);zeros(np-i,1)]
   g(i)=(MSVAR_Filt(param+aux)-MSVAR_Filt(param-aux))/aux(i)/2
end
 
endfunction
