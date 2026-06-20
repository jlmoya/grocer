function [lrmod]=def_results(meth,y,namey,nobs,prests,boundsvarb,m2prt_test,dropna,nonna)
 
// PURPOSE: create a list of 2 results tlist, each tlist having
// the formal name of their elements defined and the invariable
// elements defined (y,namey,...) ; the second list has the
// names 'rsqr', 'rbar', 'f' and 'fvalue' that the first one
// doesn't have
// ------------------------------------------------------------
// INPUT:
// * y = y data vector
// * namey = name of the y variable
// * nobs = # of observations
// * prests = boolean indicating the presence or
//     absence of a time series in the regression
// * prescte = boolean indicating the presence or
//     absence of a constant in the regression
// * indcte = index of the constant in the regression+1
//   (= nvar+1 if there is none)
// * boundsvarb = if there is a timeseries in the
//     regression, the bounds of the regression
// * m2prt_test = the column describing the name of the
//   specification tests use in the process
// ------------------------------------------------------------
// OUTPUT:
// * lmod = a list of 2 tlists
// * indcte = the index of the constant variable in the x
//   matrix (nvar+1 if there is no constant variable)
// ------------------------------------------------------------
// NOTES: used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
// define all the formal names of the first tlist
rmod=tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'tstat';'pvalue';'resid';'vcovar';'sige';'sigu';...
'ser';'yhat';'dw';'condindex';'prescte';'prests';...
'namey';'namex';'ym';'spec_test';'m_test';'aic';'bic';'hq';'dropna'])
 
// fill the fields which are invariant in the automatic process
rmod('meth')=meth
rmod('nobs')=nobs
rmod('y')=y
rmod('namey')=namey
rmod('prests')=prests
rmod('ym')=y-mean0(y)
rmod('m_test')=m2prt_test
 
if prests then
   rmod(1)($+1)='bounds'
   rmod('bounds')=boundsvarb
end
 
rmod('dropna')=dropna
if dropna then
   rmod(1)($+1)='nonna'
   rmod('nonna')=nonna
end
if nargin == 11 then
   rmod('meth')='Newey-West''s HAC'
   rmod(1)($+1)='win'
   rmod('win')=win
end
 
 
// define the second tlist and define the new formal names
rmod0=rmod
if prescte then
   rmod0(1)($+1)='rsqr'
   rmod0(1)($+1)='rbar'
   rmod0(1)($+1)='f'
   rmod0(1)($+1)='pvaluef'
end
 
 
lrmod=list(rmod,rmod0)
 
endfunction
