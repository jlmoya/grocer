function clwest_d()
 
// PURPOSE: out-of-sample forecasting and Clark-West test
//	for french industrial production by the mean of business survey
 
 
global GROCERDIR;
 
load(GROCERDIR+'\data\industrial.dat')
 
// LABEL OF THE DATA
// y 						= french manufacturing production
// ypast 				=	industrial survey, past trend of production
// yfut 	 			=	industrial survey, futur trend of production
//
// MODELS TO COMPARE
// . short horizon : delts(log(y)) = al*lagts(ypast) + a2*delts(lagts(yfut))
// . long horizon  : delts(4,log(y))= al*lagts(4,ypast) + a2*delts(lagts(4,yfut))
// WITH "benchmark model" :  Random walk on delts(log(y))
 
 
write(%io(2),' SHORT HORIZON MODEL','(a)')
bounds('1979q1','2003q4');
// out-of-sample foreacasts
rs = rolreg('delts(log(y))','lagts(ypast)','delts(lagts(yfut))','cte',...
      'dates=[''1991q4'' ''2003q4'']','hstep=1');
 
y_short = rs('yfor') ;
 
bounds('1992q1','2003q4') 	// select an appropriate sample period
rscl=clwest('delts(log(y))','y_short','bench=''mdh''') ;
 
 
write(%io(2),' LONG HORIZON MODEL ','(a)')
bounds('1980q1','2003q4');
// out-of-sample foreacasts
rl = rolreg('delts(4,log(y))','lagts(4,ypast)','delts(lagts(4,yfut))','cte',...
      'dates=[''1992q1'' ''2003q4'']','hstep=4');
y_long = rl('yfor') ;
 
bounds('1993q1','2003q4') 	// select an appropriate sample period
rlcl=clwest('delts(log(y))','y_long','overlap=4','bench=''mdh''') ;
 
 
write(%io(2),' SHORT HORIZON NESTED MODELS','(a)')
bounds('1979q1','2003q4');
rs2 = rolreg('delts(log(y))','delts(lagts(yfut))','cte',...
      'dates=[''1991q4'' ''2003q4'']','hstep=1');
y_short2 = rs2('yfor') ;
 
bounds('1992q1','2003q4') 	// select an appropriate sample period
rscl=clwest('delts(log(y))','y_short2','y_short','bench=''nm''') ;
 
endfunction
