function E4OPTION=sete4opt(varargin)
 
// PURPOSE: sets the option to the E4 estimation programs
// ------------------------------------------------------------
// INPUT:
// * o1,..., o10 = strings, options that can be set by the user
// * v1,..., v10 = the admissible options
// with the following possibilities:
//   oi	                 vi
// filter   kalman, chandrashekhar.
// scale    Matrix scaling during filtering operations: 'yes', 'no'.
// vcond    initial conditions for the variance of the state vector:
//           'lyapunov', 'zero', 'idej' (Inverse De Jong).
// econd    initial conditions for the expectation of the state vector:
//           'ml', 'zero', 'au', 'iu', 'auto'.
// var      optimize with respect to the noise covariances or the
//          corresponding Cholesky factors.
// toler    tolerance for stop criteria.
// maxiter  maximum number of iterations.
// ------------------------------------------------------------
// OUTPUT:
// E4OPTION = the vector of options
// ------------------------------------------------------------
// NOTE: this is -almost- the original program; some options
// can still be set by the program, but whith no effect on the
// working of the program
// ------------------------------------------------------------
// Copyright (c) Jaime Terceiro, 1997
// Eric Dubois 2003-2008 for the Scilab translation and adaptation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
// Default values
 
E4OPTION = tlist(['options';'filter';'scale B';'vcond';...
'econd';'var';'tol eigv';'tol djccl';'tol Q djccl';...
'gen tol';'dejong k';'deriv eps'],'kalm',0,'idjong','auto',...
'unfactorized',.99999,.0000000001,.0001,sqrt(%eps),100000,1e-8)
 
for i = 1:nargin
   argi=varargin(i)
   iequal=strindex(argi,'=')
   optstr = part(argi,1:iequal-1)
   optval = part(argi,iequal+1:length(argi))
 
   if length(optstr) <3 then
      error('Unrecognized option:'+optstr);
   end
   if length(optval) <1 then
      error('Unrecognized option value:'+optval+'for option '+optstr);
   end
 
   shortoptstr=part(convstr(optstr),1:3)
   shortoptval=part(convstr(optval),1)
 
   select shortoptstr
   case 'fil' then
      if shortoptval == 'c' then
         E4OPTION('filter') = 'chand'
      elseif shortoptval ~= 'k'
         error('Unrecognized option value:'+optval+'for option '+optstr);
      end
 
   case 'sca' then
      if shortoptval =='y' then
         E4OPTION('scale B') = 1
      else
         if part(optval,1) ~= 'n' then
            error('Unrecognized option value:'+optval+'for option '+optstr);
         end
      end
 
   case 'vco' then
      select shortoptval
      case 'l' then
         E4OPTION('vcond') = 'lyap'
      case 'z' then
         E4OPTION('vcond') = 'zero'
      case 'd' then
         E4OPTION('vcond') = 'djong'
      else
         if part(optval,1) ~='i' then
            error('Unrecognized option value:'+optval+'for option '+optstr);
         end
      end
 
   case 'eco' then
      if or(optval == ['umean';'ml';'zero';'u0']) then
         E4OPTION('econd') = optval
      else
         if part(optval,1:4) ~='auto' then
            error('Unrecognized option value:'+optval+'for option '+optstr);
         end
      end
 
   case 'var' then
      if part(optval,1) == 'f' then
         E4OPTION('var') = 'factorized'
      else
         if part(optval,1) ~= 'u' then
            error('Unrecognized option value:'+optval+'for option '+optstr);
         end
      end
 
   case 'tol' then
      if optval>0 then
         E4OPTION('tol Q djccl') = optval
       else
          error('Unvalid value: '+optval+'for option '+optstr);
       end
 
   case 'der' then
      if optval>0 then
         E4OPTION('deriv eps') = optval
       else
          error('Unvalid value: '+optval+'for option '+optstr);
       end
 
 
   else
      error('Unrecognized option:'+optstr);
   end
end
 
//if E4OPTION('filter')=='chand' & E4OPTION('vcond')=='idjong' then
//   error('If vcond=''De Jong'', then filter must be Kalman');
//end
 
endfunction
