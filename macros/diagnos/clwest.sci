function rcw = clwest(grocer_namey0,varargin)
 
// PURPOSE: Compute Clark and West test of forecast
//  accuracy between nested models with the test of
//  of martingal difference hypothesis as a special case
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = observed vector or ts
//    WARNING: in case of of martingal difference test combined
//        with overlapping regression (for computional purpose) :
//    (1) this series should be in non-overlapping form :
//        overlaping terms are be construct by sumation
//        ex: If y(t)-y(t-4) = d(y(t))+d(y(t-1))+d(y(t-2))+d(y(t-3))
//        is the series that is forecast it's d(y) that must be entered
//    (2) the series of forecasts should be in overlapping form
//        (y(t)-y(t-4) in the example)
// * varargin = arguments which can be:
//   . 1 or 2 time series according to the test specified
//      (first series should be the benchmark in case of nested model)
//   . a real (nx1) or (nx2) vector
//   . a string equal to the name of a time series or a (nx1)/(nx2)
//        real vector between quotes the results of the regression
//   . 'overlap=xx'  the number of overlapping terms if the user performs
//      the martingal difference test for an overlapping regression
//      or the size of the lag truncation window if the user wants an
//      HAC correction when testing for predictive accuracy bewteen nested models
//   . 'bench = ''mdh''' if the user want to test martingal difference hypothesis
//        otherwise 2 nested model are tested (default, 'nm')
//   . 'noprint' if the user does not want to print the
//          results (optional)
//   . 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// rcw = a results tlist with:
// * rcw('meth') = 'Clark-West' or 'Clark-West - martingal difference'
//   (if the model under H0 is a random walk)
// * rcw('namey') = name of forecasted serie
// * rcw('namex') = name of forecasts models (benchmark at first)
// * rcw('stat') = value of the Clark-West statistics
// * rcw('mse-adj') = mse adjusted
// * rcw('pvalue') = p-value of the Diebold-Mariano statistics
// * rcw('overlap') = number of overllapping terms
//      in overlapping regression
// * rcw('prests') = flag for the presence of time series
// * rcw('bounds') = if there is a timeseries in the forecast,
//   the bounds of the regression
// * rcw('dropna') = boolean indicating if NAs have
//   been dropped
// * rcw('nonna') = vector indicating position of
//    non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// REFERENCES:
// . Todd E. Clark & Kenneth D. West (2005), "Using out-of-sample mean squared
//    prediction errors to test the martingale difference hypothesis",
//    forthcoming Journal of Econometrics.
// . Todd E. Clark & Kenneth D. West (2006), "Approximately normal
//    test for equal predictive accuracy in nested models",
//    NBER Technical Paper, 326
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2006
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
grocer_dropna=%f
grocer_overlap = 0
grocer_bench = 'nm'
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
 
      argi=strsubst(varargin(grocer_i),' ','')
 
      if part(argi,1:5) == 'bench' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
 
      elseif part(argi,1:7) == 'overlap' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
 
      elseif argi == 'norpint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      else
 
      end
 
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
                                typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
 
end
 
 
// martingal difference test
if (grocer_bench == 'mdh') then
  if (grocer_overlap ~= 0) then
 
   // explode TS into vector according to the model
    [grocer_x,grocer_namex,grocer_prests,grocer_boundsvar]=...
            explone(varargin,[],'fcst',%t,grocer_dropna)
 
    if (size(grocer_x,2) ~= 1) then
      error("Must have 1 serie of forecasts to compute martingal difference test")
    end
 
    // take an ealier beginning date to compute
    // overlaping data
    nbeg = date2num(grocer_boundsvar(1))-grocer_overlap+1
    freqx = date2fq(grocer_boundsvar(1))
    dbeg= num2date(nbeg,freqx(1))
 
    [grocer_ty,grocer_namey,junk,junk]=...
          explone(grocer_namey0,[dbeg;grocer_boundsvar(2)],'obs',%t,grocer_dropna)
 
    grocer_y = zeros(size(grocer_ty,1)-grocer_overlap+1,1)
    // h-th difference of "y" with h = grocer_overlap
    for i=1:size(grocer_y,1)
      grocer_y(i) = sum(grocer_ty(i:i+grocer_overlap-1))
    end
 
    // MSE adj. stat
    f = grocer_y.^2-(grocer_y-grocer_x).^2+grocer_x.^2
    fbar = mean0(f)
 
    // compute vcv for overllapping test
    grocer_dy = grocer_ty(grocer_overlap:$)
    P = size(grocer_x,1)
    g = zeros(P-grocer_overlap+1,1)
    for i=1:P-grocer_overlap+1
      g(i) = 2*grocer_dy(i)*sum(grocer_x(i:i+grocer_overlap-1))
    end
    V   = (1/(P-grocer_overlap+1))*sum((g-mean0(g)).^2)
 
  else
    [grocer_ty,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvar]=...
            explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
    if (size(grocer_x,2) ~= 1) then
      error("Must have 1 serie of forecasts to compute martingal difference test")
    end
 
    grocer_y = grocer_ty
    P = size(grocer_x,1)
 
    // MSE adj. stat
    f = grocer_y.^2-(grocer_y-grocer_x).^2+grocer_x.^2
    fbar = mean0(f)
 
    // variance matrix "normal" case
    V = mean0((f-fbar).^2)
  end
 
  // test statistic & p-value
  cw = fbar/sqrt(V/P)
  result = 'Clark-West - martingal difference'
 
// test of predictive accuracy bewteen nested model
else
   [grocer_y,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvar]=...
            explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
  grocer_ty = grocer_y
 
  if (size(grocer_x,2) ~= 2) then
    error("Must have 2 series of forecasts to compute the test of predictive accuracy")
  end
 
  P = size(grocer_x,1)
  f=(grocer_y-grocer_x(:,1)).^2-(grocer_y-grocer_x(:,2)).^2+(grocer_x(:,1)-grocer_x(:,2)).^2
  fbar = mean0(f)
  if (grocer_overlap == 0) then
      V = mean0((f-fbar).^2)
  else
      V = newey_west(f-fbar,grocer_overlap)
  end
  cw = fbar/sqrt(V/P)
  result = 'Clark-West'
end
pvalue = 1-cdfnor("PQ",cw,0,1)
 
// tlist results
rcw=tlist(['results';'meth';'y';'yfor';'namey';'namex';'mse-adj';'stat';...
           'pvalue';'overlap';'prests';'dropna'],...
            result,grocer_ty,grocer_x,grocer_namey,grocer_namex,...
            fbar,cw,pvalue,grocer_overlap,grocer_prests,grocer_dropna)
 
if grocer_prests then
   rcw(1)($+1)='bounds'
   rcw('bounds')=grocer_boundsvar
end
 
if grocer_dropna then
   rcw(1)($+1)='nonna'
   rcw('nonna')=nonna
end
 
if grocer_prt then
   prtclwest(rcw)
end
endfunction
