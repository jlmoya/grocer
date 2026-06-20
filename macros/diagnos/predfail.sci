function [rpredf]=predfail(grocer_res,varargin)
 
// PURPOSE: performs out-of-sample predictive failure test
// ------------------------------------------------------------
// INPUT:
// * grocer_res = the tlist results resulting from a regression
// * varargin
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . either:
//     - a constant, which idicates the # of periods over which
//       the forecast is done
//     - a date, which indicates the date until which the
//       forecast is done (if the estimation has been made with
//       ts)
// ------------------------------------------------------------
// OUTPUT:
// grocer_rpredf = a results tlist with:
//   . grocer_rpredf('meth')  = 'rprefail'
//   . grocer_rpredf('res0')  = results tlist of the
//     originating estimation
//   . grocer_rpredf('chistat')  = value of the test statistics
//   . grocer_rpredf('pchi') = its p-level
//   . grocer_rpredf('p') = the # of forecasts
//   . grocer_rpredf('prests')  = boolean indicating the
//     presence or absence of a time series in the regression
//   . grocer_rpredf('prests')  = the residuals over the
//     forecasting period
//   . grocer_rpredf('bounds')  = the bounds of the forecasting
//     period
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt=%t
for grocer_i=length(varargin):-1:1
   if varargin(grocer_i) == 'noprint' then
      grocer_prt=%f
      varargin(grocer_i)=null()
   end
end
 
select typeof(varargin(1))
 
case 'constant'
   grocer_p=varargin(1)
   if grocer_res('prests') then
// calculate the range of the forecast
      grocer_b=grocer_res('bounds')
      grocer_bf=grocer_b(max(size(grocer_b)))
      grocer_fq=date2fq(grocer_bf)
      grocer_perprev=[num2date(date2num(grocer_bf)+1,...
      grocer_fq) ;num2date(date2num(grocer_bf)+varargin(1),...
      grocer_fq) ]
      grocer_uprev=evstr(grocer_res('namey'))-...
      statfore(grocer_res,grocer_perprev)
   else
      grocer_uprev=varargin(1)-statfore(grocer_res,varargin(2))
   end
 
case 'string' then
    grocer_b=grocer_res('bounds')
    grocer_bf=grocer_b(max(size(grocer_b)))
    grocer_fq=date2fq(grocer_bf)
    grocer_d0=num2date(date2num(grocer_bf)+1,grocer_fq)
    grocer_perprev=[grocer_d0 ; varargin(1)]
    grocer_uprev=evstr(grocer_res('namey'))-statfore(...
    grocer_res,grocer_d0,varargin(1))
    grocer_p=size(grocer_uprev('series'),1)
else
   error(typeof(varargin(1))+' is not a valid type for arg # 2')
end
 
grocer_chistat=sum(grocer_uprev .^2)/grocer_res('sige')
grocer_pchi= 1-cdfchi("PQ",grocer_chistat,grocer_p)
rpredf=tlist(['results';'meth';'res0';'chistat';'chi_df';'chi_pvalue';...
'prests';'resid'],'predfail',grocer_res,grocer_chistat,...
grocer_p,grocer_pchi,grocer_res('prests'),grocer_uprev)
 
if grocer_res('prests') then
   rpredf(1)($+1)='bounds'
   rpredf($+1)=grocer_perprev
end
 
if grocer_prt then
   prtchi(rpredf)
end
endfunction
