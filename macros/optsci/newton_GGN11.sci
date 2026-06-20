function [grocer_x0,grocer_f0,grocer_maxf0]=newton_GGN11(grocer_x0,grocer_func,grocer_Jac,grocer_ftol,grocer_itermax,grocer_alphamin)
 
// PURPOSE: find the 0 of an equation using the variant of the
// Newton method provided by Grau-Sanchez, Grau and Noguera
// "On the computational efficiency index and some iterative
// methods for solving systems of nonlinear equations",
// Journal of Computational and Applied Mathematics 236 (6),
// 1259-1266
// ------------------------------------------------------------
// INPUT:
// * grocer_x0 = a (n x 1) vector of starting values
// * grocer_func = a function, whose 0 is searched
// * grocer_Jac = a function, performing the Jacobian of the
//   function
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
   grocer_J0=grocer_Jac(grocer_x0)
   grocer_IJ0_f0=inv(grocer_J0)*grocer_f0 ;
   try
      grocer_y1=grocer_x0-grocer_IJ0_f0;
      grocer_Jy1=grocer_Jac(grocer_y1)
      grocer_IJ1=inv(grocer_Jy1)
      grocer_IJy1_f0=grocer_IJ1*grocer_f0;
 
      grocer_z1=grocer_x0-0.5*(grocer_IJ0_f0+grocer_IJy1_f0)
      grocer_fz1=grocer_func(grocer_z1)
      grocer_maxfz1=max(abs(grocer_fz1))
 
      if grocer_maxfz1 < grocer_ftol then
      // stop here the process since convergence has been achieved
         grocer_x0=grocer_z1
         grocer_f0=grocer_fz1
         grocer_maxf0=grocer_maxfz1
 
      else
         grocer_IJy1_f1=grocer_IJ1*grocer_fz1;
         grocer_x1=grocer_z1-grocer_IJy1_f1;
 
         grocer_f1=grocer_func(grocer_x1)
         grocer_maxf1=max(abs(grocer_f0))
 
         if grocer_maxf1 < grocer_maxf0 then
            grocer_x0=grocer_x1
            grocer_f0=grocer_f1
            grocer_maxf0=grocer_maxf1
 
         elseif grocer_maxfz1 < grocer_maxf0 then
            grocer_x0=grocer_z1
            grocer_f0=grocer_fz1
            grocer_maxf0=grocer_maxfz1
 
         else
            grocer_decreasing=%f
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
 
endfunction
