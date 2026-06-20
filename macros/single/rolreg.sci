function rreg = rolreg(grocer_namey0,varargin)
 
// PURPOSE: computes rolling/recursive regression and
// performs h-step ahead forecasts
//------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . 'roll' or 'recu' : if the user want to use
//      a rolling or recursive window (default='recu')
//   . 'hstep = xx': number of out-of-sample forecasts
//   . 'mul=1' : if the user wants to keep the forecast from 1 to hstep
//       otherwise only hstep forecast is kept
//   . 'dates = [xx,yy]':  end of first estimation + end of sample.
//      or 'dates=xx': if the user wants the estimation to
//      be done up to the last sample point of y. The elements of date
//      can be either a string (ex: '1986m1') or a  number (ex: 4)
//      If 'roll'  method is used the size of the rolling window choosen to
//			be the difference between the beginning of the sample and 'xx'
//   . 'cte' or 'const' if the user wants a constant in the
//     regression
//   . 'nwest', 'ols','white'  according to the type of coefficients
//        variance-covariance matrix desired
//   . 'trunc = xx" truncation window for newey-west estimation
//   . 'xsmpl': allow program to extand the last hstep-ahead forecasts beyond
//      the last date of endogenous variable (provided exogenous data are available,
//      the program tests it)
//   . 'signs =[''>0'',...,''<0''] signs restriction. When they are not satisfied,
//      the variable is omitted during estimation and forcasts.
//      'signs' must have k elements (the constant is omitted)
//      ''na'' stands for no restriction
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
//------------------------------------------------------------
// OUTPUT:
//   . rreg('meth')  = 'rolling' / 'recursive'
//   . rreg('beta')  =  rolling/recursive betas
//   . rreg('tstat')  = rolling/recursive tstats
//   . rreg('pvalue') = rolling/recursive pvalue of the betas
//   . rreg('rsqr')  =  rolling/recursive rsquared
//   . rreg('rbar')  =  rolling/recursiverbar-squared
//   . rreg('namey') = name of the y variable
//   . rreg('namex') = name of the x variables
//   . rreg('yfor')  =  out-of-sample forecasts
//     or rreg('yfor_h(i)')  if multiple horizon forecats are kept
//   . rreg('prescte') = boolean indicating the presence or
//   . rreg('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rreg('bounds')  = begin-end of first estiamtion + end of sample
//   . rreg('nfor') = vector of number of realized forecast and
//            and number of desired forecast
//   . rreg('dropna') = boolean indicating if NAs have
//		            been dropped
//   . rreg('nonna') = vector indicating position of non-NAs
//------------------------------------------------------------
// E. Michaux (2006-2007)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_simu='recu'
grocer_hstep=0
grocer_mul=0
grocer_meth='ols'
grocer_win=[]
grocer_dates= []
grocer_xsmpl=0
grocer_signs=[]
grocer_trunc=0
grocer_dates=[]
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
 
      argi=strsubst(varargin(grocer_i),' ','')
      str3=part(argi,1:3)
      str4=part(argi,1:4)
      str5=part(argi,1:5)
      str6=part(argi,1:6)
 
      if str6 == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif  str5 == 'hstep' | str5 == 'dates' |  ...
            str5== 'signs' | str5=='trunc'  then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif  str5== 'nwest' | str5 == 'white' then
         grocer_meth=str5
         varargin(grocer_i)=null()
      elseif  str5== 'xsmpl' then
         grocer_xsmpl=1
         varargin(grocer_i)=null()
      elseif str4=='recu' | str4=='roll' then
         grocer_simu=varargin(grocer_i)
         varargin(grocer_i)=null()
      elseif str3 == 'mul' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif str6 == 'dropna' then
         grocer_dropna = %t;
         varargin(grocer_i)=null();
      end
 
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
                                typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
if (length(grocer_dates)==0) then
  error('estimation dates are missing')
end
 
// test the presence of ts
execstr('grocer_prests='+grocer_namey0)
if typeof(grocer_prests)=="ts" then
  grocer_prests=%t
else
  grocer_prests=%f
end
 
if grocer_prests then
  hypini = 0
 
  [grocer_y,grocer_namey,grocer_x,grocer_namexos,junk,grocer_boundsvarb,nonna]=...
           explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
   // test vector of sample size
   if size(grocer_dates,'*') < 2 then
      grocer_dates=[grocer_dates,grocer_boundsvarb(2)]
      warning('end of estimation date is missing: it is replaced by y last sample point: '+grocer_boundsvarb(2))
   elseif (date2num(grocer_dates(2)) > date2num(grocer_boundsvarb(2))) &  (grocer_xsmpl~=1) then
      error('bounds of data don''t match with bounds of forecasts')
   end
	
   ytmp = exploy(grocer_namey0)
   freqy = ytmp('freq')
 
   if grocer_xsmpl == 1 then
 
      bounds()
      [grocer_xj,grocer_namexj,prests,grocer_boundsxsmpl,nonna]=...
            explone(varargin,[],'sup. data',%t,grocer_dropna)
 
      hypini  = diff_date(grocer_boundsvarb(1),grocer_boundsxsmpl(1))
      if hypini < 0 then
         error('x first date <  y first date')
      end
 
      hyphstep = diff_date(grocer_boundsxsmpl(2),grocer_boundsvarb(2))
      if hyphstep < grocer_hstep then
         warning('sample needed for xsmpl option is < than argument in the fonction')
         write(%io(2),'initialy specified range of forecasts is used','(a)')
      end
      grocer_dates(2) = num2date(date2num(grocer_boundsvarb(2))+grocer_hstep,freqy)
 
      warning('y end date is '+grocer_boundsvarb(2)+',  xsmpl option imposes forecats to be done up to '+grocer_dates(2))
      grocer_x = grocer_xj(hypini+1:$-hyphstep+grocer_hstep,:)
      hyphstep = grocer_hstep
 
    end
 
   // total number of out-of-sample forecasts
  if freqy(1)==365 | freqy(1)==52 then
    ytmpd=ytmp('dates')(nonna)
    de=find(ytmpd==date2num(grocer_dates(1)))
    en1=find(ytmpd==date2num(grocer_dates(2)))
    en2=find(ytmpd==date2num(grocer_boundsvarb(1)))
    nfor=en1-de-grocer_hstep+1
    eest=de-en2+1
  else
    nfor =diff_date(grocer_dates(2),grocer_dates(1))-grocer_hstep+1 ;
    // end of the first estimation
    eest =diff_date(grocer_dates(1),grocer_boundsvarb(1))+1
  end
else
  [grocer_y,grocer_namey,junk1,junk2,nonnay]=...
           explone(grocer_namey0,[],'exo',%t,grocer_dropna)
 
  [grocer_x,grocer_namexos,junk1,junk2,nonnax]=...
           explone(varargin,[],'endo',%t,grocer_dropna)
 
  if (and(nonnax==nonnay)==%f) then
		error('location of NAs in y is different from x')
  end
 
  ny=max(size(grocer_y))
  nx=max(size(grocer_x))
 
  if (nx<ny) then
    error("x # of rows is less than that of y. It should be superior or equal")
  end
 
  if size(grocer_dates,'*') < 2 then
    grocer_dates=[grocer_dates,ny]
    warning('end of estimation date is missing. It is replaced by the last sample point: '+string(ny))
  elseif (grocer_dates(2)>nx) then
    error('end of estimation date is > than x # of rows')
  elseif (grocer_dates(2)>ny) then
    error('end of estimation date is > than y # of rows')
  end
 
  if grocer_xsmpl > 0 then
    if (grocer_dates(2)+grocer_hstep>nx) then
      error("the sample size needed for xsmpl option is > than x # of rows")
    end
 
    grocer_x=grocer_x(1:grocer_dates(2)+grocer_hstep,:)
    grocer_y=grocer_y(1:grocer_dates(2),:)
 
    // total number of out-of-sample forecasts
    nfor=grocer_dates(2)-grocer_dates(1)+1 ;
    // end of the first estimation
    eest=grocer_dates(1)
 
  else
    grocer_x=grocer_x(1:grocer_dates(2),:)
    grocer_y=grocer_y(1:grocer_dates(2),:)
 
    // total number of out-of-sample forecasts
    nfor=grocer_dates(2)-grocer_dates(1)-grocer_hstep+1 ;
    // end of the first estimation
    eest=grocer_dates(1)
  end
 
end
 
rreg=rolreg0(grocer_y,grocer_x,grocer_simu,grocer_meth,'win=[eest,nfor]',...
        'hstep=grocer_hstep','signs=grocer_signs','mul=grocer_mul','trunc=grocer_trunc')
 
 
// saves the names, the bounds if the regression involves ts
rreg(1)($+1) = 'prests'
rreg(1)($+1) = 'namex'
rreg(1)($+1) = 'namey'
rreg(1)($+1)  = 'dropna'
 
rreg('prests')=grocer_prests
rreg('namex')= grocer_namexos
rreg('namey')=grocer_namey
rreg('dropna')=grocer_dropna
 
if grocer_prests then
  rreg(1)($+1) = 'bounds'
  rreg('bounds')=grocer_dates
 
  if grocer_mul > 0 then
    yfor=rreg('yfor')
    for i=1+(1-grocer_mul)*(grocer_hstep-1):grocer_hstep
      deb_for=num2date(date2num(grocer_dates(1))+i,date2fq(grocer_dates(1)))
      execstr('yfor_h'+string(i)+' = reshape(yfor(:,'+...
            string(i+(grocer_mul-1)*(grocer_hstep-1))+'),deb_for)') // transform vector of prevision into TS
      rreg(1)($+1)='yfor_h'+string(i)
      execstr('rreg(''yfor_h'+string(i)+''') = yfor_h'+string(i))
    end
  else
    deb_for=num2date(date2num(grocer_dates(1))+grocer_hstep,date2fq(grocer_dates(1)))
    rreg('yfor')=reshape(rreg('yfor'),deb_for)
  end
else
  if grocer_mul > 0 then
    for i=1+(1-grocer_mul)*(grocer_hstep-1):grocer_hstep
      rreg(1)($+1) = 'yfor_h'+string(i)
      execstr('rreg(''yfor_h'+string(i)+''') = yfor(:,'+string(i-(grocer_mul-1)*(grocer_hstep-1))+')''')
    end
  end
end
 
if grocer_dropna then
   rreg(1)($+1)='nonna'
   rreg('nonna')=nonna
end
 
 
endfunction
