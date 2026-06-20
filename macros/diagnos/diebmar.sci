function rdb = diebmar(grocer_namey0,grocer_bench,grocer_competitor,varargin)
 
// PURPOSE: Compute Diebold and Mariano test for predictive
// accuracy while allowing for small sample correction as
// proposed by Harvey et al.
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = observed vector or ts
// * grocer_bench = the benchmark forecast which can be:
//   . a time series (the first serie is the benchmark model)
//   . a real (n x 1) vector
//   . a string equal to the name of a time series or a (n x 1)
//        real vector or matrix between quotes
// * grocer_competitor = the competiitor forecast which can be:
//   . a time series (the first serie is the benchmark model)
//   . a real (n x 1) vector
//   . a string equal to the name of a time series or a (n x 1)
//        real vector or matrix between quotes
// * varargin = arguments which can be:
//   - 'smallc=1' : if the user want haervey-Leybourne small sample
//      corection (default = 0)
//   - 'trunc = xx'  : truncation point of the bartlett
//      window (optional; default = floor(5*nobs^0.25))
//   - the string 'noprint' if the user doesn't want to display the
//   results of the regression
//   - the string 'dropna' if the user wants to delete NAs from
//     the forecast series and the forecasts themselves
//     (this option should be used when dealing with daily
//      and weekly TS)
// ------------------------------------------------------------
// OUPTUT:
// rdb = a results tlist with:
// - rdb('meth') = 'diebmar'
// - rdb('y') = input forecasted series
// - rdb('yfor') = forecast under the null hypothesis & under
//          the alternative hypothesis
// - rdb('namey') = name of forecasted serie
// - rdb('namex') = name of forecasts models (benchmark at first)
// - rdb('mse') = mean standard error under the null &
//      aleternative the hypothesis
// - rdb('stat') = value of the Diebold-Mariano statistics
// - rdb('pvalue') = p-value of the Diebold-Mariano statistics
// - rdb('smallc') = flag for a small sample correction
// - rdb('trunc') = truncation lag of the Barlett window
// - rdb('prests') = flag for the presence of time series
// - rdb('bounds') = if there is a timeseries in the forecast,
//   the bounds of the regression
// - res('dropna') = boolean indicating if NAs have
//    been droped
// - res('nonna') = vector indicating position of
//    non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// REFERENCES:
// - Diebold F. X. and R. S. Mariano (1995): "Comparing
//  Predictive Accuracy", Journal of Business and Economic
//  Statistics, 13, pp. 253-265
// - Harvey, D.I., S.J. Leybourne and P. Newbold (1997):
//  "Testing the Equality of Prediction Mean Square Errors",
//  International Journal of Forecasting, 13, pp. 273-281.
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2004 / 2006
// sligthly modified by E. Dubois to enhance compatability with
// other grocer functions
// http://grocer.toolbox.free.fr/grocer.html
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
 
// set defaults
grocer_prt=%t
grocer_dropna=%f
grocer_smallc = %f
grocer_smallc_v  = 1
grocer_trunc = 0
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
 
      argi=strsubst(varargin(grocer_i),' ','')
 
      if  part(argi,1:5) == 'trunc' then
         execstr('grocer_'+varargin(grocer_i))
      elseif part(argi,1:6) == 'smallc' then
         execstr('grocer_'+varargin(grocer_i))
      elseif argi == 'noprint' then
         grocer_prt=%f
      elseif argi == 'dropna' then
         grocer_dropna=%t
      end
 
   else
      error('wrong type for entry number '+string(grocer_i+2))
   end
 
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
  explouniv(grocer_namey0,list(grocer_bench,grocer_competitor),[],['observed';'forecasts'],%t,grocer_dropna)
 
// lag truncation for Bartlett window
nobs = size(grocer_y,1)
if grocer_trunc == 0 then
  grocer_trunc = floor(5*nobs^0.25)
end
// small sample correction
if grocer_smallc then
  grocer_smallc_v = ((nobs +1-2*grocer_trunc+(1/nobs)*grocer_trunc*(grocer_trunc-1))/nobs)^0.5
end
 
// compute h-step ahead residuals and MSE
resb = grocer_y-grocer_x(:,1)
resc = grocer_y-grocer_x(:,2)
 
mseb = (1/nobs)*sum(resb .^ 2,1) ;
msec = (1/nobs)*sum(resc .^ 2,1) ;
 
// DM test
d = resb .^ 2-resc .^ 2
dbar = (1/nobs)*sum(d,1)
dcenter = d-dbar*ones(nobs,1)
nw = newey_west(dcenter,grocer_trunc)
dm = grocer_smallc_v*dbar/((nw/nobs).^0.5)
 
if grocer_smallc_v == 1 then
   pvalue = 1-cdfnor("PQ",abs(dm),0,1)
else
   pvalue = 1-cdft("PQ",abs(dm),nobs-1)	
end
 
rdb=tlist(['results';'meth';'y';'yfor';'namey';'namex';'mse';'stat';...
          'pvalue';'smallc';'trunc';'prests';'dropna'],...
          'diebmar',grocer_y,grocer_x,grocer_namey,grocer_namexos,[mseb msec],dm,...
           pvalue,grocer_smallc_v,grocer_trunc,grocer_prests,grocer_dropna)
 
if grocer_prests then
   rdb(1)($+1)='bounds'
   rdb('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rdb(1)($+1)='nonna'
   rdb('nonna')=nonna
end
 
if grocer_prt then
   prtdiebmar(rdb)
end
 
 
 
endfunction
