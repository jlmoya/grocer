function res=pcce(grocer_namey,varargin)
 
// PURPOSE: Pesaran et alii common correlated effects
//  estimators for static and dynamic heterogeneous
// panel data models
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a real (nx1) vector or a string equal to
// the name of a time series or a (nx1) real vector between
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
//      * 'x=name1;...;namep' where name1,...,namep are
//      a subset of the names of the variables that are in the
//      database
//      * the string 'nameid=name1,..., namen' where name1,...
//      are names of individuals present in the database
//      * 'yar=namear' the name of the AR endogeneous variable
//      in case of a dynamic panel data model that is in the
//      database
//   - if first input of varargin was an endegnous variable
//   then either:
//      * a time series
//      * a real (nxk) matrix
//      * a (kx1) string vector of names of time series, vectors
//      or matrices
//      * the string 'id=v' where v is the vector of individuals
//      attached to the y and x data (this argument must be
//      present somewhere in the list of variables arguments)
//      * 'yar=namear' the name of the AR endogeneous variable
//      in case of a dynamic panel data model
//   - 'cce=xxx' type of common correlated effect estimators
//       (dynamic or static, depending on the presence of an AR part)
//       * meang for the mean group (CCEMG)
//       * pooled for the pooled one (CCCEP)
//   - 'jackkn' if the user wants a half-panel  jackknife
//        correction for CCEMG estimator with dynamic panel
//   - 'wvec = xxx' a vector of individual weights for the
//        CCEP estimator (optional, default = 1/#individuals)
//   - 'mglag = xxx' number of lags to filter residuals case of
//      a CCEMG dynamic panel estimation
//   - the string 'noprint' if the user doesn't want the
//      to print the results of the regression
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')='CCEMG', 'CCEP', 'jackknife CCEMG'
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
// ------------------------------------------------------------
// REFERENCE:
//  Pesaran, M. H. (2006), "Estimation and inference in large
//    heterogenous panels with multifactor error structure",
//    Econometrica, 74, 967-1012.
// ------------------------------------------------------------
// Copyright Eric Dubois 2005 & Emmanuel Michaux 2010-2012-2013
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt = %t
grocer_arg1 = varargin(1)
grocer_subnameid = %f
grocer_nargin=length(varargin)
grocer_cce='meang'
grocer_wvec=[]
grocer_mglag=[]
duar=%f;
dujk=%f;
if typeof(grocer_arg1) == 'panel data' then
 
   grocer_namep=grocer_arg1('namex')
// grocer_namep is the vector of names in the data base
 
   grocer_xp=grocer_arg1('x')
// grocer_xp is the vector of values in the data base
 
   grocer_findendo=(grocer_namep == grocer_namey)
   grocer_y=grocer_xp(:,grocer_findendo)
   grocer_x=grocer_xp(:,~grocer_findendo)
   grocer_namex=grocer_namep(~grocer_findendo)
// grocer_namex is the vector of names other than the endogenous
// one
 
   grocer_id=grocer_arg1('id')
// grocer_id is the vector of individuals
 
   grocer_nameid=grocer_arg1('nameid')
// and grocer_nameid is their name
 
   for grocer_i=grocer_nargin:-1:2
      argi=strsubst(varargin(grocer_i),' ','')
      if part(argi,1:2) == 'x=' then
          // the user has given the name of the variables, which is a subset
          // of the names in the database
         grocer_namex=str2vec(varargin(grocer_i))
         grocer_x=[]
         for grocer_j=1:size(grocer_namep,1)
            if or(grocer_namex == grocer_namep(grocer_j)) then
               grocer_x=[grocer_x grocer_xp(:,grocer_j)]
            end
         end
      elseif part(argi,1:3) == 'cce' then
         execstr('grocer_'+part(argi,1:3)+'=str2vec(argi)')
         varargin(grocer_i)=null()
      elseif part(argi,1:3) == 'yar' then
         // an endogenous autoregressive variables is used
         duar=%t
         grocer_nameyar=str2vec(varargin(grocer_i))
         grocer_findar=(grocer_namep == grocer_nameyar)
         grocer_yar=grocer_xp(:,grocer_findar)
         varargin(grocer_i)=null()
      elseif part(argi,1:4) == 'wvec' then
         execstr('grocer_'+argi)
         varargin(grocer_i)=null()
      elseif part(argi,1:5) == 'mglag' then
         execstr('grocer_'+argi)
         varargin(grocer_i)=null()
      elseif part(argi,1:6) == 'jackkn' then
         dujk=%t
         varargin(grocer_i)=null()
      elseif part(argi,1:7) == 'nameid=' then
          // the user has given the name of the individuals, which is a subset
          // of the names in the database
         grocer_subnameid=%T
         grocer_nameid0=grocer_nameid
         grocer_nameid=str2vec(varargin(grocer_i))
      elseif argi == 'noprint' then
         grocer_prt=%f
      end
   end
 
 
   if duar then
      grocer_x=[grocer_yar,grocer_x]
      grocer_namex=[grocer_nameyar;grocer_namex]
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
 
 
else
 
 
   grocer_lx=varargin
   for grocer_i=grocer_nargin:-1:2
      argi=strsubst(varargin(grocer_i),' ','')
      if part(argi,1:3) == 'id=' then
         execstr('grocer_'+argi)
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:4) == 'yar=' then
         execstr('grocer_'+argi)
         grocer_lx(grocer_i) = null()
         duar=%t;
      elseif part(argi,1:4) == 'cce=' then
         execstr('grocer_'+part(argi,1:3)+'=str2vec(argi)')
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:5) == 'wvec=' then
          execstr('grocer_'+argi)
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:5) == 'mglag' then
         execstr('grocer_'+argi)
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:6) == 'jackkn' then
         dujk=%t
         grocer_lx(grocer_i) = null()
      elseif part(argi,1:8) == 'defname=' then
         grocer_nameid=str2vec(argi)
         grocer_lx(grocer_i) = null()
      elseif argi == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
      end
   end
 
   if ~exists('grocer_nameid','local') then
      grocer_nameid='individual # '+string(vec2col(unique(grocer_id)))
   end
 
 
   if duar then
     grocer_lx(0)=grocer_yar;
   end
   [grocer_y,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvarb]=...
        explouniv(grocer_namey,grocer_lx)
end
 
 
if dujk & ~duar
  error('Half-panel jackknife correction works only with dynamic panels');
end
 
 
// provides the results from the regression of the vector y
// on the vector x
if duar then
  if grocer_cce=='meang' then
    if dujk then
      res=pdccemg_jkn1(grocer_y,grocer_id,grocer_x(:,1),grocer_x(:,2:$),grocer_mglag)
    else
      res=pdccemg1(grocer_y,grocer_id,grocer_x(:,1),grocer_x(:,2:$),grocer_mglag)
    end
 
 
  elseif grocer_cce=='pooled' then
    res=pccep1(grocer_y,grocer_id,grocer_x,grocer_wvec)
  end
 
 
else
  if grocer_cce=='meang' then
    res=pccemg1(grocer_y,grocer_id,grocer_x)
  elseif grocer_cce=='pooled' then
    res=pccep1(grocer_y,grocer_id,grocer_x,grocer_wvec)
  end
end
 
 
res(1)($+1)='prests'
res(1)($+1)='namex'
res(1)($+1)='namey'
res('namey')=grocer_namey
res('namex')=[grocer_namex;grocer_nameid]
 
 
if grocer_prt then
   prt_panel_cce(res,%io(2))
end
endfunction
