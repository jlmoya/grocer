function [results]=dfbeta(grocer_namey0,varargin)
 
// PURPOSE: computes BKW (influential observation diagnostics)
//          dfbetas, dffits, hat-matrix, studentized residuals
// ------------------------------------------------------------
// REFERENCE: Belsley, Kuh, Welsch, 1980 Regression Diagnostics
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = either an ols results tlist or a time
//   series, a real (nx1) vector or a string equal to the name
//   of a time series or a (nx1) real vector between quotes
// * varargin = if arguments which can be:
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   or, and only if grocer_namey is not an ols results tlist:
//   . a time series
//   . a real (nx1) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and weekly TS)
//   . 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// results = a results tlist with
// - results('meth')   = 'dfbeta'
// - results('nobs')   = # of observations
// - results('nvar')   = # of variables in x-matrix
// - results('dfbeta') = df betas
// - results('dffits') = df fits
// - results('hatdi')  = hat-matrix diagonals
// - results('stud')   = studentized residuals
// - result('namex') = name of the x variables
// - result('namey') = name of the y variable
// - result('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - result('dropna') = boolean indicating if NAs have
//    been droped
// - result('nonna') = vector indicating position of
//    non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright Eric Dubois 2002 / bug fixes Emmanuel Michaux 2005
// http://grocer.toolbox.free.fr/grocer.html
// adapted by from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatia-econometrics.com
 
 
 
grocer_prt=%t
grocer_dropna=%f
if typeof(grocer_namey0) == 'results' then
   if grocer_namey0('meth') ~= 'ols' then
      error('tlist argument should be an ols result')
   end
   grocer_namexos=grocer_namey0('namex')
   grocer_namey=grocer_namey0('namey')
   grocer_prests=grocer_namey0('prests')
   if grocer_prests then
      grocer_boundsvarb=grocer_namey0('bounds')
   end
 
   if grocer_namey0('dropna') then
     grocer_dropna = %t
     nonna = grocer_namey0('nonna')
     grocer_x=grocer_namey0('x')(nonna,:)
   else
     grocer_x=grocer_namey0('x')
   end
 
   [nobs,nvar] = size(grocer_x);
   bols=grocer_namey0('beta')
   e=grocer_namey0('resid')
   sige=grocer_namey0('sige')
   sxx=grocer_namey0('vcovar')/sige
 
   nargin=length(varargin)
   if nargin ~= 0 then
      if nargin ~= 1 then
         error ('too many arguments after the results tlist argument')
      elseif varargin(1) == 'noprint' then
         grocer_prt=%f
      else
         error ('invalid argument')
      end
   end
 
else
  nargin=length(varargin)
  for grocer_i=nargin:-1:1
    grocer_argi=varargin(grocer_i)
    if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'noprint' then
        grocer_prt=%f
        varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
    end
  end
 
  [grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonnna]=...
      explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
  [bols,sxx]=ols0(grocer_y,grocer_x)
  e = grocer_y-grocer_x*bols;
  [nobs,nvar] = size(grocer_x);
  sige = e'*e/(nobs-nvar);
 
end
 
e2 = e .* e;
 
// perform QR decomposition
[q,r] = qr(grocer_x);
// pull out first nvar columns of q'
qt = q(1:nvar,:);
 
// get OLS estimates and related stuff
 
// find hat-matrix
h = zeros(nobs,1);
for i = 1:nobs
  h(i,1) = qt(:,i)'*qt(:,i);
end
 
omh = ones(nobs,1)-h;
homh = sqrt(h ./ omh);
 
d1 = (nobs-nvar)/(nobs-nvar-1)*sige*ones(nobs,1);
d2 = e2 ./ ((nobs-nvar-1)*omh);
si = sqrt(d1-d2);
t1 = si .* sqrt(omh);
 
dffits = homh .* (e ./ t1);
 
g = e ./ omh;
g = diag(g);
 
dfb = r'\(qt*g);
dfbet = dfb(1:nvar,1:nobs)';
 
 
scale=ones(nobs,nvar)
for i = 1:nvar
  scale(1:nobs,i) = si*sxx(i,i);
end
 
dfbetas = dfbet ./ scale;
 
results=tlist(['results';'meth';'nobs';'nvar';'dfbeta';...
'dffits';'hatdi';'stud';'namex';'namey';'prests';'dropna'],...
'bkw',nobs,nvar,dfbet,dffits,h,e ./ (si .* sqrt(omh)),...
grocer_namexos,grocer_namey,grocer_prests,grocer_dropna)
 
if grocer_prests then
   results(1)($+1)='bounds'
   results('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   results(1)($+1)='nonna'
   results('nonna')=nonna
end
 
if grocer_prt then
   plt_dfb(results)
   plt_dff(results)
end
 
endfunction
