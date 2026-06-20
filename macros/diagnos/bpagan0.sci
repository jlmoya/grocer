function [f,f_pvalue,nvar2,r2]=bpagan0(u2,x2,nvar)
 
// PURPOSE: Breusch and Pagan heteroscedasticity test
// low level command: assumes that the x variables, including
// the constant, have already been stacked in matrix x2
// ------------------------------------------------------------
// INPUT:
// * u2 = the first stage regression squared residuals
// * x2 = the exogenous variables of the Breusch and Pagan second
//        stage regression
// * nvar = number of exogenous variables in the first satge
//          regression
// ------------------------------------------------------------
// OUPTUT:
// * f = value of the Goldfeld-Quandt F test
// * f_pvalue = its p-value
// * nvar2 = # of exogenous variables of the Breusch and Pagan
//           second stage regression
// * r2 = R� of the auxilliary regression
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2010
// http://grocer.toolbox.free.fr/grocer.html
 
b=ols0(u2,x2)
u2c=u2-mean0(u2)
u2hat=u2-x2*b
[nobs,nvar2]=size(x2)
r2=1-(u2hat'*u2hat)/(u2c'*u2c)
f=((u2c'*u2c)/(u2hat'*u2hat)-1)*(nobs-nvar-nvar2)/(nvar2-1)
f_pvalue=1-cdff("PQ",f,nvar2-1,(nobs-nvar-nvar2+1))
 
endfunction
