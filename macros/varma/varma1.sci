function [theta,x_T,P_T,ytT,grocer_theta2mat,grocer_e4param,lab,ineq,f,grad,u0,AR,ARS,MA,MAS,G,V,mat2thet]=varma1(y0,AR,ARS,MA,MAS,v,s,inite4,grocer_optfunc,grocer_opt_optim,G,exo0,namexo)
 
// PURPOSE: estimate a VARMA model using E4 functions
// the ARMA model has the following form:
// AR(L)*ARS(L^s) y = MA(L)*MAS(L^s) e [+G(L)X]
// where L is the lag operator, X is an optional vector of
// exogenous variables
// ------------------------------------------------------------
// INPUT:
// * y0 = a (T x m) real matrix
// * AR = the matrix [] or a (n x (n*p)) matrix
//   with:
//   - n = # of endogenous variables in endo
//   - p = # of lags in the AR part of the process
// * ARS = the matrix [] or a (n x (n*ps)) matrix
//   with ps = # of lags in the seasonal AR part of the
//   process
// * MA = the matrix [] or a (n x (n*q)) matrix
//   with: q = # of lags in the AM part of the process
// * MAS = the matrix [] or a (n x (n*qs)) matrix
//   with qs = # of lags in the seasonal MA part of the process
// * v = a (nx1) vector if the user wants to impose
//   independence between resisduals or a (nxn) matrix in the
//   other case
// * s = a scalar representing the order of the
//   seasonality
// * inite4 = a boolean indicating whether the user has provided
//   starting values or not
// * grocer_optfunc = a string, the name of the optimisation
//   function ('optim' or 'optimg')
// * grocer_opt_optim = a tlist, collecting the optimisation
//   options
// * G = a matrix, the coefficients of the exogenous variables
//   (optional)
// * exo0 = a matrix, the matrix of exegenous variables
//   (optional)
// * namexo = a string vector, the names of the exogenous
//   variables (optional)
// ------------------------------------------------------------
// OUTPUT:
// * theta = a vector, the solution parameters
// * x_T = a (T x k) matrix, the smoothed state vector
// * P_T = a (N x N) matrix, the smoothed state variance
// * ytT = smoothed yhat
// * grocer_theta2mat = a string vetcor, the instructions used
//   to transform the parameters into the matrices of the Kalman
//   filter
// * grocer_e4param = a structure, collecting the parameters of
//   the model
// * lab = a vector, collecting the names of the estimated
//   parameter
// * ineq =
// * f = (minus) the log-kikelihood at solution
// * g = (minus) the gradient vector at solution
// * u0 = the value of the starting values of the exogenous
//   variables
// * AR = the AR part of the varma at the solution
// * ARS = the ARS part of the varma at the solution
// * MA = the MA part of the varma at the solution
// * MAS = the MAs part of the varma at the solution
// * G = the coefficient of the exgenous variables at solution
// * V = the variance
// * mat2thet = a string vetcor, the instructions used
//   to transform  the matrices of the Kalman filter  into
//    the parameters
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007-2013
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
[nargout,nargin]=argn(0)
grocer_e4_userflag=0
delta=sqrt(%eps)
grocer_theta2ss=theta2sss
[T,m]=size(y0)
 
labels=''+['AR' 'ARS' 'MA' 'MAS']
execstr(labels+'0='+labels)
 
for k=1:4
   execstr('obj='+labels(k))
   [nr,nc]=size(obj)
   select typeof(obj)
   case 'constant' then
      execstr(labels(k)+'=0*obj')
   case 'string' then
      for i=1:nr
         for j=1:nc
            if isempty(strindex(obj(i,j),'=')) & isempty(strindex(obj(i,j),'<')) ...
            & isempty(strindex(obj(i,j),'>')) then
               execstr(labels(k)+'('+string(i)+','+string(j)+')=''0''')
            end
         end
      end
   end
end
 
[y,scale]=scalemat(y0)
V0=diag(10^(-scale))*varcov0(y0)*diag(10^(-scale))
[nr,nc]=size(v)
 
if or([nr nc] == 1) then
   V0=diag(V0)
end
 
if typeof(v) == 'constant' then
   v=V0
else
   for i=1:nr
      for j=1:nc
         if isempty(strindex(v(i,j),'=')) then
            execstr('v('+string(i)+','+string(j)+')=V0('+string(i)+','+string(j)+')')
         else
            v(i,j)=part(v(i,j),1:ind_eq)+string(evstr(part(v(i,j),1+ind_eq:length(v(i,j))))*sqrt(V0(i,i)*V0(j,j)))
         end
      end
   end
end
 
if nargin > 10 then
 
   [exo,scalex]=scalemat(exo0)
   u0=exo(1,:)
 
   [theta,grocer_theta2mat,lab,grocer_e4param,ineq,n1,mat2thet]=arma2param(m,AR,ARS,MA,MAS,v,0,s,G,size(exo0,2),namexo);
 
else
 
 
   exo0=[]
   exo=[]
   u0 =[]
 
   [theta,grocer_theta2mat,lab,grocer_e4param,ineq,n1,mat2thet]=arma2param(m,AR,ARS,MA,MAS,v,0,s);
end
 
grocer_e4param.T=T
 
z=[y exo]
 
if inite4 then
   // give good starting values
   [theta,f0]=e4prees1(theta,grocer_theta2mat,z)
   // recover the true variance (to understand why, see function theta2arm2)
   [AR,ARS,MA,MAS,V,G]=theta2arm2(theta,grocer_theta2mat)
 
//   theta2mat2=''''+grocer_theta2mat+''''
   if size(y,2) == 1 then
   // change AR, ARS, MA, MAS so that all roots are lower than 1
      corrv_ar=1
      corrv_ars=1
      corrv_ma=1
      corrv_mas=1
 
      if typeof(AR0) == 'constant' then
         [AR,corrv_ar]=transf_roots(AR)
      end
      if typeof(ARS0) == 'constant' then
         [ARS,corrv_ars]=transf_roots(ARS)
      end
      if typeof(MA0) == 'constant' then
         [MA,corrv_ma]=transf_roots(MA)
      end
      if typeof(ARS0) == 'constant' then
         [MAS,corrv_mas]=transf_roots(MAS)
      end
      V=sqrt(V*corrv_ar*corrv_ars/corrv_ma/corrv_mas)
 
      execstr(mat2thet)
   end
end
 
// create the function that gathers the estimate of the
// likelihood function and its derivative
deff('[f,g,ind]=llike(p,ind)','[f,g]=llike_innov(p,grocer_theta2mat,z,u0)')
deff('f=llike1(p)','f=llike_innov1(p,grocer_theta2mat,z,u0)')
 
if or(ineq(:,1) ~= -%inf) | or(ineq(:,2) ~= %inf) then
   if size(y,2) == 1  then
      ind_V=0
      found=%f
      while ~found then
          ind_V=ind_V+1
          if ind_V ==  size(grocer_theta2mat,1)+1 then
             found=%t
             ind_V=%nan
 
          elseif ~isempty(strindex(grocer_theta2mat(ind_V),'V='))  then
             found=%t
             par1=strindex(grocer_theta2mat(ind_V),'(')
             par2=strindex(grocer_theta2mat(ind_V),')')
             execstr('ineq_V='+part(grocer_theta2mat(ind_V),par1+1:par2-1))
 
          end
      end
   end
   if ~isnan(ind_V) then
      ineq(ineq_V,1)=sqrt(%eps)
      ineq(ineq_V,2)=sqrt(mean0((y-mean(y)).^2))
   end
 
   grocer_opt_optim('optim ineq')='''b'',ineq(:,1),ineq(:,2)'
   theta=min(max(theta,ineq(:,1)),ineq(:,2))
// there are inequality constraints
   execstr('[f,theta,grad] = optim(llike,''b'',ineq(:,1),ineq(:,2),theta'+grocer_opt_optim('optim')+')');
else
// there is no inequality constraint
   select grocer_optfunc
   case 'optim'
      try
         execstr('[likl1,theta,grad] = optim(llike,theta'+grocer_opt_optim('optim')+')');
      catch
         if getversion("scilab")(1) >= 5.4 then
            warnMode = warning("query");
            warning("off");
            [likl1,theta,grad] = optimg(llike1,llike,theta,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
            warning(warnMode);
         else
            [likl1,theta,grad] = optimg(llike1,llike,theta,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
         end
      end
 
   case 'optimg'
      if getversion("scilab")(1) >= 5.4 then
         warnMode = warning("query");
         warning("off");
         [likl1,theta,grad] = optimg(llike1,llike,theta,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
         warning(warnMode);
      else
         [likl1,theta,grad] = optimg(llike1,llike,theta,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
      end
   else
      error('not an available optimization function: '+grocer_optfun)
   end
end
 
// recover the true variance (to understand why, see function theta2arm2)
[AR,ARS,MA,MAS,V,G]=theta2arm2(theta,grocer_theta2mat)
 
if size(y,2) == 1 then
// reestimate with all roots of AR, ARS, MA, MAS lower than 1
   corrv_ar=1
   corrv_ars=1
   corrv_ma=1
   corrv_mas=1
 
   if typeof(AR0) == 'constant' then
      [AR,corrv_ar]=transf_roots(AR)
   end
   if typeof(ARS0) == 'constant' then
      [ARS,corrv_ars]=transf_roots(ARS)
   end
   if typeof(MA0) == 'constant' then
      [MA,corrv_ma]=transf_roots(MA)
   end
   if typeof(ARS0) == 'constant' then
      [MAS,corrv_mas]=transf_roots(MAS)
   end
   V=V*(corrv_ar*corrv_ars/corrv_ma/corrv_mas)^2
 
   execstr(mat2thet)
 
end
 
 
[x_T,P_T,ytT]=smooth_innov(theta,grocer_theta2mat,z,u0)
 
// return to the original values and recover the true likelihood
V0=diag(10^scale)*V*diag(10^scale)
// let theta include the values for V
[N,S]=svd(V0)
V=N*sqrt(S)*N'
execstr(grocer_e4param.V2theta)
 
if grocer_e4param.r then
   G=diag(10^scale)*G*diag(10^(-scalex))
   execstr(grocer_e4param.G2theta)
   u0=u0*diag(10^scalex)
end
 
ytT=ytT .* (ones(T,1) .*. 10^scale)
z=[y0 exo0]
[f,g]=llike_innov(theta,grocer_theta2mat,z,u0)
 
V=V0
 
endfunction
 
