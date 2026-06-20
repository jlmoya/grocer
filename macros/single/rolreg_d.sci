function rolreg_d()
 
// PURPOSE: out-of-sample forecasting of French industrial production
//  by the mean of business survey
// demo proposed by E. Michaux
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
load(GROCERDIR+'\data\industrial.dat')
 
// LABEL OF THE DATA
// y 						= french manufacturing production
// ypast 				=	industrial survey, past trend of production
// yfut 	 			=	industrial survey, futur trend of production
//
// MODELS TO COMPARE
// selected model by automatic function over the period 1979q1 - 2002q4
// delts(log(y)) = al*ypast + a2*delts(yfut) "indicators model"
 
 
// Out-of-sample forecasts
// - 4 quaters ahead
// - forecasts from 1 to 4 quater are stored
// - recursive estimation (as opposed to rolling)
// - 'xmpl' option allow program to extand the last hstep-ahead forecasts beyond
//      the last date of endogenous variable (provided exogenous data are available,
//      the program tests it)
 
bounds()
ri = rolreg('delts(log(y))','lagts(4,ypast)','lagts(4,delts(yfut))','cte',...
 'dates=[''1992q1'';''2003q4'']','hstep=4','mul=1','recu','xsmpl')
 
// keep 4-step ahead forecasts
fct = ri('yfor_h4') ;
 
pltseries('delts(log(y))','fct','legend=[Obs.;Fcst.]',...
  'title=4-step ahead recursive out-of-sample forecasts of '+ri('namey'),'styleg=3')
halt()
 
// Out-of-sample forecasts
// - 1 quater ahead
// - rolling estimation
// - no end date is given
 
ri = rolreg('delts(log(y))','ypast','delts(yfut)','cte','dates=[''1992q1'']',...
'hstep=1','roll')
fct = ri('yfor') ;
 
pltseries('delts(log(y))','fct','legend=Obs.;Fcst.',...
  'title=Out-of-sample forecasts of '+ri('namey'),'styleg=3','window=2')
 
endfunction
 
