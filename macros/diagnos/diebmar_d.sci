function diebmar_d()
 
// PURPOSE: out-of-sample forecasting and Diebold-Mariano test
//	for french industrial production by the mean of business survey
// demo proposed by E. Michaux
// http://grocer.toolbox.free.fr/grocer.html
 
 
global GROCERDIR;
 
load(GROCERDIR+'\data\industrial.dat') ;
 
// LABEL OF THE DATA
// y 						= french manufacturing production
// ypast 				=	industrial survey, past trend of production
// yfut 	 			=	industrial survey, futur trend of production
//
// MODELS TO COMPARE
// selected model by automatic function over the period 1979q1 - 2002q4
// delts(log(y)) = al*ypast + a2*delts(yfut) "indicators model"
// "benchmark model" :  AR(2) on delts(log(y))
 
 
bounds('1979q1','2003q4');
ri = rolreg('delts(log(y))','ypast','delts(yfut)','cte',...
'dates=[''1992q1'',''2003q4'']','hstep=1');
rb = rolreg('delts(log(y))','delts(lagts(log(y)))','delts(lagts(2,log(y)))','cte',...
'dates=[''1992q1'',''2003q4'']','hstep=1');
bounds();
 
y_indic =ri('yfor');
y_bench = rb('yfor');
 
// plot the forecasts
pltseries('delts(log(y))','y_indic','y_bench','styleg=1','bounds=[''1992q2'' ''2003q4'']',...
	'legend=[Production QoQ;Forecasts with indicators model;Forecasts with benchmark model]');
 
bounds('1992q2','2003q4'); 	// select an appropriate sample period
rdb=diebmar('delts(log(y))','y_bench','y_indic','smallc=1','trunc=4'); // performs Diebold & Mariono test
rdb=diebmar('delts(log(y))','y_bench','y_indic','smallc=1'); // performs Diebold & Mariono test
rdb=diebmar('delts(log(y))','y_bench','y_indic'); // performs Diebold & Mariono test
 
endfunction
 
 
