function [grocer_valfn,grocer_b0,grocer_valg]=optimg(grocer_f,grocer_fg,grocer_b0,grocer_optim_opt,grocer_nelmead_opt,grocer_gradconv)
 
// PURPOSE: Grocer optimization function
// ------------------------------------------------------------
// INPUT:
// * grocer_f = the function to minimize
// * grocer_fg = the function to minimize, with gradient vector
//   calculated as second argument
// * grocer_b0 = a (k x 1) vector, the vector of starting values
// * grocer_optim_opt = a string, any options to optim entered
//   but entered between quotes
// * grocer_nelmead_opt = a string, the values of the convergence
//   criterion, followed by the maximum number of iterations,
//   the figure being separated by a comma
// * grocer_gradconv = a positive number, the convergence
//   criterion of the absolute m    ean of the gradient components
// ------------------------------------------------------------
// OUTPUT:
// * grocer_valf = the value of the function at the solution
// * grocer_b1 = the value of the solution vector of parameters
// * grocer_valg = the value of the gradient at the solution
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013-2015
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_nargout,grocer_nargin]=argn(0)
if ~exists('grocer_verbose') then
   grocer_verbose=%F
end
 
grocer_nparam=size(grocer_b0,1)
// set the convergence criterion for the gradient to 0
// if not provided by the user
if grocer_nargin < 6 then
   grocer_gradconv=0
elseif isempty(grocer_gradconv) then
   grocer_gradconv=0
end
 
// set options for the Nelder Meade  optimisation program
if grocer_nargin < 5 then
   grocer_nelmead_opt=',2*%eps*grocer_nparam,1E5'
elseif isempty(grocer_nelmead_opt) then
   grocer_nelmead_opt=',2*%eps*grocer_nparam,1E5'
end
 
 
if grocer_nargin < 4 then
   grocer_optim_opt=',''ar'',1e5,1e5'
elseif isempty(grocer_optim_opt) then
   grocer_optim_opt=',''ar'',1e5,1e5'
end
 
if typeof(grocer_f) == 'list'  then
   grocer_vararg=grocer_f
   grocer_vararg(1)=null()
   grocer_f=grocer_f(1)
   grocer_fg1=grocer_fg(1)
   [grocer_valfn,grocer_valg]=grocer_fg1(grocer_b0,[],grocer_vararg(:))
else
   grocer_vararg=list()
   [grocer_valfn,grocer_valg]=grocer_fg(grocer_b0,[],grocer_vararg(:))
end
 
write(%io(2),' ','(a)')
 
grocer_valf0=%inf
while real(grocer_valf0 - grocer_valfn) > 0 & mean0(abs(grocer_valg)) > grocer_gradconv then
   grocer_valf0=grocer_valfn
   try
      execstr('[grocer_valf1,grocer_b1,grocer_valg]=optim(grocer_fg,grocer_b0,''qn'''+grocer_optim_opt+')');
      write(%io(2),'optim with qn option has ended','(a)')
      grocer_valf1(isnan(grocer_valf1))=%inf
      if grocer_verbose then
         write(%io(2),'f value: '+string(grocer_valf1),'(a)')
         write(%io(2),' ','(a)')
         write(%io(2),'g value: ','(a)')
         disp(grocer_valg)
      end
 
   catch
      write(%io(2),'warning: optim with qn option has not converged because of the following error:','(a)')
      write(%io(2),lasterror(),'(a)')
      grocer_b1=grocer_b0+sqrt(%eps)
      grocer_valf1=%inf
      grocer_valg=%inf*grocer_b0
   end
   grocer_valf=[grocer_valf0  grocer_valf1]
   grocer_b=[grocer_b0 grocer_b1]
 
   if (mean0(abs(grocer_valg)) <= grocer_gradconv) then
      grocer_b0=grocer_b1
      grocer_valfn=grocer_valf1
   else
      try
         execstr('[grocer_valf2,grocer_b2,grocer_valg]=optim(grocer_fg,grocer_b0,''gc'''+grocer_optim_opt+')');
         write(%io(2),'optim with gc option ended','(a)')
         grocer_b=[grocer_b grocer_b2]
         grocer_valf2(isnan(grocer_valf2))=%inf
         grocer_valf=[grocer_valf  grocer_valf2]
         if grocer_verbose then
            write(%io(2),'f value: '+string(grocer_valf2),'(a)')
            write(%io(2),' ','(a)')
            write(%io(2),'g value: ','(a)')
            disp(grocer_valg)
         end
      catch
         write(%io(2),'warning: optim with gc option has not converged because of the following error:','(a)')
         write(%io(2),lasterror(),'(a)')
         grocer_b=[grocer_b grocer_b0+sqrt(%eps)]
         grocer_valf=[grocer_valf grocer_f(grocer_b0+sqrt(%eps))]
      end
 
      if (mean0(abs(grocer_valg)) <= grocer_gradconv) then
         grocer_bn=grocer_b2
         grocer_valfn=grocer_valf2
      else
         try
            execstr('[grocer_b3,grocer_valf3,grocer_ended]=nelmead(grocer_f,grocer_b0'+grocer_nelmead_opt+',grocer_vararg)');
            write(%io(2),'nelmead has ended','(a)')
            grocer_valf3(isnan(grocer_valf3))=%inf
            grocer_b=[grocer_b grocer_b3]
            grocer_valf=[grocer_valf  grocer_valf3]
            [grocer_junk,grocer_valg]=grocer_fg(grocer_b3)
            if grocer_verbose then
               write(%io(2),'f value: '+string(grocer_valf3),'(a)')
               write(%io(2),' ','(a)')
               write(%io(2),'g value: ','(a)')
               disp(grocer_valg)
            end
 
         catch
            grocer_ended=%t
            write(%io(2),'warning: nelmead has not converged because of the following error:','(a)')
            write(%io(2),lasterror(),'(a)')
            grocer_b=[grocer_b grocer_b0+sqrt(%eps)]
            grocer_valf=[grocer_valf grocer_f(grocer_b0+sqrt(%eps))]
         end
 
         if (mean0(abs(grocer_valg)) <= grocer_gradconv) then
            grocer_bn=grocer_b3
            grocer_valfn=grocer_valf3
         else
            try
               execstr('[grocer_valf4,grocer_b4,grocer_valg]=optim(grocer_fg,grocer_b0,''nd'''+grocer_optim_opt+')');
               write(%io(2),'optim with nd option has ended','(a)')
               grocer_b=[grocer_b grocer_b4]
               grocer_valf4(isnan(grocer_valf4))=%inf
               grocer_valf=[grocer_valf  grocer_valf4]
               if grocer_verbose then
                  write(%io(2),'f value: '+string(grocer_valf4),'(a)')
                  write(%io(2),' ','(a)')
                  write(%io(2),'g value: ','(a)')
                  disp(grocer_valg)
               end
            catch
               write(%io(2),'warning: optim with nd option has not converged because of the following error:','(a)')
               write(%io(2),lasterror(),'(a)')
               grocer_b=[grocer_b grocer_b0+sqrt(%eps)]
               grocer_valf=[grocer_valf grocer_f(grocer_b0+sqrt(%eps))]
            end
 
            [grocer_valfn,grocer_ind]=min(real(grocer_valf))
            grocer_b0=grocer_b(:,grocer_ind)
         end
      end
   end
end
 
write(%io(2),' ','(a)')
 
endfunction
