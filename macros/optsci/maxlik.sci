function [results]=maxlik(grocer_func,grocer_xarg,varargin)
 
// PURPOSE: maximize a (log likelihood) function
// ------------------------------------------------------------
// INPUT:
// * grocer_func    = function to be minimized
// * grocer_xarg = parameter vector fed to func
// * varargin =
//   . optional arguments passed for infoz
//      'maxit=x' to set the maximum # iterations (default 100)
//      'btol=x' to set the convergence criterium for b
//       (default 1e-5)
//      'ftol=x' to set the convergence criterium for function
//       (default sqrt(%eps))
//      'gtol=x' to set the convergence criterium for gradiant
//       (default sqrt(%eps))
//      'cond=x' to set the maximum condition number authorized
//       for hessian matrix (default 1000)
//      'lambda=x' to set lambda in the GN/Marq hess option
//      (default 0.01)
//      'delta=x' to set the increment used in the numz func
//      (default 0.01)
//      'optprt=0' not to print the cause of the stop
//      (default 1)
//      'hess=namefunc' to set the name of an hessian update
//      function (default BFGS)
//      'grad=namefunc' to set the name of a grdiant function
//      (default numz0)
//   or
//   . arguments (if any) other than grocer_xarg passed to func
// ------------------------------------------------------------
// RETURNS: results = a results tlist with
//          . results('meth')  = infoz(hess)
//                             = 'dfp', 'bfgs', 'gn', 'marq',
//                               'sd' (from input)
//          . results('hess')  = numerical hessian at the
//                               optimum
//          . results('bhist') = history of b at each iteration
//          . results('b')     = parameter value at the optimum
//          . results('f')     = objective function value at the
//                               optimum
//          . results('g')     = gradient at the optimum
//          . results('dg')    = change in gradient
//          . results('db')    = change in b parameters
//          . results('df')    = change in objective function
//          . results('iter')  = # of iterations taken
//          . results('time')  = time (in seconds) needed to
//                               find solution
//          . results('infoz') = infoz (options used)
// ------------------------------------------------------------
// NOTE:
// used by nls(), garch(), kalman(), tobit(), ...
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapteed from:
// Mike Cliff,  UNC Finance   mcliff@unc.edu
 
grocer_X=[]
grocer_infoz=tlist(['options';'func';'maxit';'hess';'optprt';'cond';...
'btol';'ftol';'gtol';'lambda';'H1';'delta';'call';'step';...
'grad';'dirtol'],grocer_func,100,'bfgs',1,1000,sqrt(%eps),sqrt(%eps),...
sqrt(%eps),.01,1,.000001,'other','stepz','numz0',1)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   select type(varargin(grocer_i))
   case 10 then
      if (part(varargin(grocer_i),[1:5]) == 'maxit' ...
      | part(varargin(grocer_i),[1:4]) == 'btol' ...
      | part(varargin(grocer_i),[1:4]) == 'ftol' ...
      | part(varargin(grocer_i),[1:4]) == 'gtol' ...
      | part(varargin(grocer_i),[1:6]) == 'dirtol' ...
      | part(varargin(grocer_i),[1:4]) == 'cond' ...
      | part(varargin(grocer_i),[1:6]) == 'lambda' ...
      | part(varargin(grocer_i),[1:5]) == 'delta' ...
      | part(varargin(grocer_i),[1:6]) == 'optprt') ...
      then
         grocer_ch=strsubst('grocer_infoz('''+varargin(grocer_i),'=',''')=')
         execstr(grocer_ch)
         varargin(grocer_i)=null()
      else
         if part(varargin(grocer_i),[1:4]) == 'hess' ...
            | part(varargin(grocer_i),[1:4]) == 'grad' ...
         then
            grocer_ch=strsubst('grocer_infoz('''+varargin(grocer_i),'=',''')=''')+''''
            execstr(grocer_ch)
            varargin(grocer_i)=null()
         end
      end
   end
end
 
if grocer_infoz('call')=='other' then
   grocer_chf='grocer_func(grocer_xarg,varargin(:))'
else
   grocer_chf='grocer_func(grocer_xarg,grocer_infoz,grocer_stat,varargin(:))'
end
 
if grocer_infoz('grad') == 'numz0' then
   grocer_chg='numz0(grocer_func,grocer_xarg,grocer_k,grocer_ik,grocer_infoz(''delta''),varargin(:))'
else
   grocer_chg=grocer_infoz('grad')+'(grocer_xarg,varargin(:))'
end
 
grocer_chs=grocer_infoz('step')+'(grocer_xarg,grocer_chf,grocer_infoz,grocer_stat,varargin(:))'
 
grocer_k = size(grocer_xarg,1);
grocer_ik=ones(grocer_k,1)
grocer_btol=grocer_infoz('btol')*grocer_ik
grocer_gtol=grocer_infoz('gtol')*grocer_ik
 
execstr('grocer_f = '+grocer_chf)
grocer_G =  evstr(grocer_chg)
 
grocer_stat=tlist(['options';'iter';'Hi';'df';'db';'dG';'f';'G';...
'star';'Hcond';'direc'],0,[],1000,ones(grocer_k,1)*1000,...
ones(grocer_k,1)*1000,grocer_f,grocer_G,' ',0,[])
 
grocer_convcrit = ones(4,1);
grocer_X=zeros(grocer_infoz('maxit'),grocer_k)
 
//   MINIMIZATION LOOP
 
while and(grocer_convcrit>0) then
  // Calculate grad, hess, direc, step to get new b
  grocer_stat('iter')=grocer_stat('iter')+1
  grocer_stat = hessz(grocer_xarg,grocer_infoz,grocer_stat,varargin(:))
  grocer_stat('direc')=-grocer_stat('Hi')*grocer_stat('G')
  execstr('grocer_stat(''db'')='+grocer_chs'+'*grocer_stat(''direc'')')
  grocer_xarg = grocer_xarg+grocer_stat('db');
 
  // Re-evaluate function, display current status
  grocer_f0 = grocer_stat('f');
  grocer_G0 = grocer_stat('G');
  execstr('grocer_stat(''f'')='+grocer_chf)
  execstr('grocer_stat(''G'')='+grocer_chg)
  grocer_stat('df')=grocer_f0-grocer_stat('f')
  grocer_stat('dG')=grocer_stat('G')-grocer_G0
 
  grocer_dbcrit = or(abs(grocer_stat('db'))>grocer_btol);
  grocer_dgcrit = or(abs(grocer_stat('dG'))>grocer_gtol);
  grocer_convcrit = [grocer_infoz('maxit')-grocer_stat('iter');...
             grocer_stat('df')-grocer_infoz('ftol');grocer_dbcrit;grocer_dgcrit];
  if grocer_stat('df')<0 then
    error('Objective Function Increased');
  end
 
  grocer_X(grocer_stat('iter'),:) = grocer_xarg';
 
end
 
//   FINISHING STUFF
 
// Write a message about why we stopped
 
if grocer_infoz('optprt')>0 then
  if grocer_convcrit(1)<=0 then
    critmsg = 'Maximum Iterations';
  elseif grocer_convcrit(2)<=0 then
    critmsg = 'Change in Objective Function';
  elseif grocer_convcrit(3)<=0 then
    critmsg = 'Change in Parameter Vector';
  elseif grocer_convcrit(4)<=0 then
    critmsg = 'Change in Gradient';
  end
  write(%io(2),'  CONVERGENCE CRITERIA MET: '+critmsg,'(a)');
  write(%io(2),' ','(a)');
end
 
// Calculate numerical hessian at the solution
grocer_hessf = hessian(grocer_func,grocer_xarg,%eps^0.25,varargin(:))'
 
// put together results structure information
results=tlist(['results';'meth';'hess';'bhist';'b';'g';'dg';...
'f';'df';'iter';'infoz'],grocer_infoz('hess'),grocer_hessf,...
grocer_X(1:grocer_stat('iter'),:),grocer_xarg,grocer_stat('G'),...
grocer_stat('dG'),grocer_stat('f'),grocer_stat('df'),grocer_stat('iter'),...
grocer_infoz)
endfunction
