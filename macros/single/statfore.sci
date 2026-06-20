function [grocer_p]=statfore(grocer_res,varargin)
 
// PURPOSE: provides a static forecast from an equation
// estimated by ols(), hwhite(), olst(), lad(),...
// ------------------------------------------------------------
// INPUT:
// * res = result tlist
// * varargin  =
//   - (optional) subperiod over which the forecast is done if
//   variables are ts
//   - a (m x k) matrix of exogenous variables if they are not ts
// ------------------------------------------------------------
// OUTPUT:
// grocer_p = forecast
// ------------------------------------------------------------
// NOTES:
// * can be used also with results of olsc (but does not take
//   into account the correlation)
// * cannot be used with results of garch (but this needs only
//   small adaptation)
// * if the estimation has been performed with ts, then the
//   function assumes that the variables have been entered
//   between quotes and that their name has therefore been
//   saved in the tlist
// * in that case, the corresponding data must be present in
//   the environment
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-20013
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_nargin=length(varargin)
 
if grocer_res('prests') then
// replace the constant term, if any, by 1
   grocer_b=grocer_res('bounds')
   grocer_nargin=length(varargin)
   select grocer_nargin
   case 1
      grocer_bf=varargin(1)
      grocer_b1=grocer_bf(1)
      grocer_b2=grocer_bf($)
   case 2
      grocer_b1=varargin(1)
      grocer_b2=varargin(2)
   else
       error('# of arguments should be 2 or 3, not '+string(grocer_nargin+1))
   end
   [grocer_b1n,fq]=date2num_fq(grocer_b1)
   grocer_b2n=date2num(grocer_b2)
   grocer_daten=[grocer_b1n:grocer_b2n]'
   if grocer_res('meth')  == 'DMA' then
      grocer_diff=grocer_daten(1)-[date2num(grocer_b(1)) ; date2num(grocer_b($))]
      if grocer_diff(1) < 0 then
         error('starting forecast period before start of DMA estimation')
      else
         grocer_theta=grocer_res('exp theta')
         grocer_bet=grocer_theta($+min(0,grocer_diff(2)),:)'
         grocer_namex=[grocer_res('fixed namex') ; grocer_res('variable namex')]
      end
   else
      grocer_namex=grocer_res('namex')
      grocer_bet=grocer_res('beta')
   end
 
   y=explone(grocer_namex,[grocer_b1;grocer_b2],'endogenous',%t,%f,%f,0)
   grocer_p=tlist(['ts';'freq';'dates';'series'],fq,[grocer_b1n:grocer_b2n]',y*grocer_bet)
 
else
   if res('meth') == 'DMA' then
      grocer_theta=grocer_res('exp theta')
      grocer_bet=grocer_theta($)
   else
      grocer_bet=res('beta')
   end
   grocer_p=varargin(1)*grocer_bet
end
 
endfunction
