function [res]=phaussman(result1,result2,prt)
 
// PURPOSE: performs Haussman test, used for testing the
//      specification of the fixed or random effects model.
// ------------------------------------------------------------
// INPUT:
// * results1 = a tlist returned by pfixed()
// * results2 = a tlist returned by prandom()
// * prt = 'noprint' if the user does not want to print the
//   result on the screen
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with
// * res('meth') = 'panel haussman'
// * res('pfixed res') = the tlist returned by pfixed()
// * res('prandom res') = the tlist returned by prandom()
// * res('stat') = the Haussman statistics
// * res('pvalue') = the corresponding p-value
// ------------------------------------------------------------
// Copyright Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a matlab programm written by:
// Carlos Alberto Castro
// National Planning Department
// Bogota, Colombia
// Email: ccastro@dnp.gov.co
 
[nargout,nargin]=argn(0)
 
if nargin<2 | nargin>3 then
  error('wrong # of arguments to phaussman');
end
 
if result1('meth') ~= 'panel with fixed effects' then
   error('phaussman requires a Fixed effects panel model results tlist');
end
 
if result2('meth') ~= 'panel with random effects' then
  error('phaussman requires a Random effects panel model results tlist');
end
 
 
// pull out results from Fixed effects model
bfe = result1('beta')
covf = result1('vcovar')
 
// pull out results from Random effects model
bre = result2('beta');
covr=result2('vcovar')
 
//haussman test
 
k = size(bre,1);
 
bdif = bfe($-k+2:$)-bre(2:k);
mdif = covf($-k+2:$,$-k+2:$ )-covr(2:k,2:k);
m = bdif'*inv(mdif)*bdif;
p = 1-cdfchi("PQ",m,k-1)
 
res=tlist(['results';'meth';'pfixed res';'prandom res';'stat';'pvalue'],...
'panel haussman',result1,result2,m,p)
 
if nargin==2 then
   prthaussman(res,%io(2))
end
 
endfunction
