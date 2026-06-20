function res=prandom(grocer_namey,varargin)
 
// PURPOSE: performs Random Effects Estimation for Panel Data
//          (for balanced or unbalanced data)
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a real (n x 1) vector or a string equal to
// the name of a time series or a (n x 1) real vector between
// quotes (this last case is the only one authorized if you
// are using a 'panel data' tlist, see below)
// * first input of varargin:
//   - either a 'panel data' tlist
//   (generally imported from a .csv database by function
//    impexc2bd)
//   - or an endogenous variable taking the form of a time
//     series, a real (nx1) vector or a string equal to the
//     name of a time series or a (nx1) real vector between
//     quotes
// * other input of varargin:
//   - if first input of varargin was a 'panel data' tlist
//   then:
//      other input are optional and can be:
//      * either 'x=name1;...;namep' where name1,...,namep are
//      a subset of the names of the variables that are in the
//      database
//      * the string 'nameid=name1,..., namen' where name1,...
//      are names of individuals present in the database
//      * the string 'glsmeth=n' where n is the name of a method
//      available to estimate the gls parameters, that is
//      'wallace', 'swamy', 'amemiya' or 'nerlove' (default:
//      'swamy')
//      * or the string 'noprint' if the user does not want to
//      print the estimation results
//   - if first input of varargin was an endogenous variable
//   then either:
//      * a time series
//      * a real (n x k) matrix
//      * a (k x 1) string vector of names of time series, vectors
//      or matrices
//      * the string 'id=v' where v is the vector of individuals
//      attached to the y and x data (this argument must be
//      present somewhere in the list of variables arguments)
//      * the string 'glsmeth=n' where n is the name of a method
//      available to estimate the gls parameters, that is
//      'wallace', 'swamy', 'amemiya' or 'nerlove' (default:
//      'swamy')
//      * the string 'noprint' if the user doesn't want to
//      print the results of the regression
// ------------------------------------------------------------
// res = a tlist with
//   . res('meth')='panel with random effects'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = nobs
//   . res('nvar')  = nvars
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('sige')  = estimated variance of the residuals
//   . res('sige')  = estimated variance of the residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('rsqr')  = rsquared
//   . res('rbar')  = rbar-squared
//   . res('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . res('pvaluef') = its significance level
//   . res('gls estimation method') = the gls method used
//   . res('random effects') = the estimation of the individual
//     effects
//   . res('res0') = residuals from the original model
//   . res('alfa') = the gls parameters
//   . res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . res('namey') = name of the y variable
//   . res('namex') = name of the x variables
//----------------------------------------------------------------------------------------
// Copyright Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt = %t
grocer_arg1 = varargin(1)
grocer_subnameid = %f
grocer_nargin=length(varargin)
grocer_meth='swamy'
grocer_dropna=%f
 
if typeof(grocer_arg1) == 'panel data' then
 
   grocer_namep=grocer_arg1('namex')(:)
// grocer_namep is the vector of names in the data base
 
   grocer_xp=grocer_arg1('x')
// grocer_xp is the vector of values in the data base
   grocer_findendo=(grocer_namep == grocer_namey)
   grocer_y=grocer_xp(:,grocer_findendo)
   grocer_x=grocer_xp(:,~grocer_findendo)
 
   execstr(grocer_namep'+'=grocer_xp(:,'+string(1:size(grocer_namep,'*'))+')')
   execstr('grocer_y='+grocer_namey)
   grocer_namex=grocer_namep(~grocer_findendo)
 
   grocer_id=grocer_arg1('id')
// grocer_id is the vector of individuals
 
   grocer_nameid=grocer_arg1('nameid')
// and grocer_nameid is their name
 
   for grocer_i=grocer_nargin:-1:2
 
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if part(grocer_argi,1:2) == 'x=' then
         // the user has given the name of the variables
         grocer_namex=str2vec(grocer_argi)
         grocer_argi=strsubst(grocer_argi,';',',')
         grocer_argi=strsubst(grocer_argi,'=','=[')+']'
         execstr('grocer_'+grocer_argi)
 
      elseif part(grocer_argi,1:7) == 'nameid=' then
// the user has given the name of the individuals, which is a subset
// of the names in the database
         grocer_subnameid=%T
         grocer_nameid0=grocer_nameid
         grocer_nameid=str2vec(varargin(grocer_i))
 
      elseif part(grocer_argi,1:8) == 'glsmeth=' then
         grocer_meth=part(grocer_argi,9:length(grocer_argi))
 
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
 
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
      end
   end
 
   if grocer_subnameid then
 
      [grocer_B,grocer_ind]=gsort(vec2col(grocer_id),'g','d')
      grocer_dB=[grocer_B(2:$)-grocer_B(1:$-1) ; 1]
      // eliminates the redundant values
      grocer_binv=grocer_B(grocer_dB ~= 0)
      // take the inverse of binv to obtain the increasing order
      grocer_uniq=grocer_binv($:-1:1)
 
      for grocer_j=1:size(grocer_nameid0,1)
         if and(grocer_nameid ~= grocer_nameid0(grocer_j)) then
            f=find(grocer_id ==grocer_uniq(grocer_j))
            grocer_id(f)=[]
            grocer_y(f)=[]
            grocer_x(f,:)=[]
 
         end
      end
   end
 
   if or(isnan([grocer_y grocer_x])) then
      if grocer_dropna then
         grocer_indonna=find(sum(isnan([grocer_y grocer_x]),'c') == 0)
         grocer_y=grocer_y(grocer_indonna)
         grocer_x=grocer_x(grocer_indonna,:)
         grocer_id=grocer_id(grocer_indonna,:)
      else
         error('there are %nan values in your panel data')
      end
   end
 
else
 
   grocer_lx=varargin
   for grocer_i=grocer_nargin:-1:2
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if part(grocer_argi,1:3) == 'id=' then
         execstr('grocer_'+vargrocer_argin(grocer_i))
         grocer_lx(grocer_i) = null()
 
      elseif part(grocer_argi,1:8) == 'glsmeth=' then
         grocer_meth=part(grocer_argi,9:length(grocer_argi))
         grocer_lx(grocer_i) = null()
 
      elseif part(grocer_argi,1:8) == 'defname=' then
         grocer_nameid=str2vec(grocer_argi)
         grocer_lx(grocer_i) = null()
 
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
 
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         grocer_lx(grocer_i) = null()
 
      end
   end
	
   if ~exists('grocer_nameid','local') then
      grocer_nameid='individual # '+string(unique(vec2col(grocer_id)))
   end
   [grocer_y,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvarb]=explouniv(grocer_namey,grocer_lx)
 
end
 
if and(grocer_meth ~= ['wallace', 'swamy', 'amemiya' , 'nerlove' ]) then
   error(grocer_meth+' is not an available gls estimation method')
end
 
// provides the results from the regression of the vector y
// on the vector x
res=prandom1(grocer_meth,grocer_y,grocer_id,grocer_x)
 
res(1)($+1) = 'name individual'
res(1)($+1) = 'prests'
res(1)($+1) = 'namex'
res(1)($+1) = 'namey'
res(1)($+1) = 'dropna'
 
res('name individual')=grocer_nameid
res('namex') = ['const' ; grocer_namex ; grocer_nameid]
res('namey') = grocer_namey
res('dropna') = grocer_dropna
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(res,foutput)
   prt_randomeffect(res,%io(2))
end
 
endfunction
