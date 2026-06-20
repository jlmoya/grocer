function [grocer_x0,grocer_f0,grocer_maxf0]=newton_U15_sp(grocer_x0,grocer_func,grocer_Jac,grocer_indJac,grocer_ftol,grocer_itermax,grocer_alphamin,grocer_date)
 
// PURPOSE: find the 0 of an equation using the variant of the
// Newton method provided by Ullah in his thesis
// "Numerical Iterative Methods For Nonlinear Problems", p. 37
// Adpated to a problem when the Jacobian is sparse
// ------------------------------------------------------------
// INPUT:
// * grocer_x0 = a (n x 1) vector of starting values
// * grocer_func = a function, whose 0 is searched
// * grocer_Jac = a function, performing the non zero values of
//   the Jacobian of this function (with the rhs as an output)
// * grocer_indJac = a (K x 2) matrix, collecting the non zero
//   indexes of the Jacobian
// * grocer_ftol = the convergence criterion for the function
//   value
// * grocer_itermax = the maxmimum number for the function
//   calls
// * grocer_alphamin = the minimum value used to dampen the
//   step when convergence is not acheived
// ------------------------------------------------------------
// OUTPUT:
// * grocer_x0 = the value of the parameter at solution
// * grocer_f0 = the value of the function at solution
// * grocer_maxf0 = the maximum value of the absolute function
//   at solution
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_f0=grocer_func(grocer_x0)
grocer_maxf0=max(abs(grocer_f0))
grocer_decreasing=%t
grocer_iter=0
warning('off')
 
while grocer_maxf0 > grocer_ftol & grocer_decreasing & grocer_iter < grocer_itermax
   grocer_iter=grocer_iter+1
   grocer_v0=grocer_Jac(grocer_x0)
   grocer_J0=sparse(grocer_indJac,grocer_v0);
   grocer_hand0=lufact(grocer_J0)
   grocer_IJ0_f0=lusolve(grocer_hand0,grocer_f0);
   grocer_y1=grocer_x0-2/3*grocer_IJ0_f0;
   grocer_v1=grocer_Jac(grocer_y1)
   grocer_hand1=lufact(sparse(grocer_indJac,3*grocer_v1-grocer_v0))
   grocer_maxf1=grocer_maxf0
   try
      grocer_z1=grocer_x0-0.5*lusolve(grocer_hand1,sparse(grocer_indJac,3*grocer_v1+grocer_v0)*grocer_IJ0_f0)
      grocer_f1=grocer_func(grocer_z1)
      grocer_maxf1=max(abs(grocer_f1))
 
      if grocer_maxf1 < grocer_ftol then
          grocer_x0=grocer_z1
          grocer_f0=grocer_f1
          grocer_maxf0=grocer_maxf1
      else
         grocer_w1=grocer_z1-2*lusolve(grocer_hand1,grocer_f1)
         grocer_f1=grocer_func(grocer_w1)
         grocer_maxf1=max(abs(grocer_f1))
         if grocer_maxf1 < grocer_ftol then
            grocer_x0=grocer_w1
            grocer_f0=grocer_f1
            grocer_maxf0=grocer_maxf1
 
         else
            grocer_x1=grocer_w1-2*lusolve(grocer_hand1,grocer_f1)
            grocer_f1=grocer_func(grocer_x1)
 
            grocer_maxf1=max(abs(grocer_f1))
            if grocer_maxf1 < grocer_maxf0 then
               grocer_x0=grocer_x1
               grocer_f0=grocer_f1
               grocer_maxf0=grocer_maxf1
 
            else
               grocer_decreasing=%f
            end
         end
 
      end
 
   catch
      grocer_alpha=0.9
      while grocer_alpha > grocer_alphamin
         try
            grocer_x1=grocer_x0-grocer_alpha*grocer_IJ0_f0
            grocer_f1=grocer_func(grocer_x1)
            grocer_alpha=grocer_alphamin
         catch
            grocer_alpha=grocer_alpha/2
         end
      end
      grocer_maxf1=max(abs(grocer_f1))
      if grocer_maxf1 < grocer_maxf0 then
         grocer_maxf0=grocer_maxf1
         grocer_x0=grocer_x1
         grocer_f0=grocer_f1
      else
         grocer_decreasing = %f
      end
   end
end
warning('on')
 
endfunction
