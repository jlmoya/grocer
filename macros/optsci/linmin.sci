function [grocer_pout,grocer_fout]=linmin(grocer_pin,grocer_xi,grocer_tol,grocer_f,varargin)
 
// PURPOSE: line minimization routine that performs an ad hoc
// n-dimensional Golden Section Search for the minimum of a
// function (Converted from Numerical Recipes book linmin
// routine)
// ------------------------------------------------------------
// INPUT:
// * grocer_pin = (kx1) vector of starting values
// * grocer_xi = (kx1) direction vector
// * grocer_tol = tolerance
// * grocer_func = function name
// * varargin = arguments passed to func
// ------------------------------------------------------------
// OUTPUT:
// * grocer_pout = (kx1) minimizing vector
// * grocer_fout = (kx1) value of func at minimum pout values
// ------------------------------------------------------------
// NOTES:
// * grocer_func must take the form grocer_func(b,varargin)
//       where: b = parameter vector (k x 1)
//       varargin = arguments passed to the function
// * used by: dfp_min(), pow_min(), frpr_min()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// translated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
 
grocer_p1 = grocer_pin;
grocer_d1 = .618;
grocer_d2 = .382;
grocer_p2 = grocer_pin+grocer_xi;
grocer_itry = 0;
 
grocer_f1 = grocer_f(grocer_p1,varargin(:))
grocer_f2 = grocer_f(grocer_p2,varargin(:))
 
while grocer_f1==grocer_f2 then
  grocer_itry = grocer_itry+1;
  grocer_p2 = grocer_p2+grocer_xi;
  grocer_f2 = grocer_f(grocer_p2,varargin(:))
  if grocer_itry==10 then
    error('problems in linmin --- grocer_itry is 10');
  end
end
 
if grocer_f1<=grocer_f2 then
  grocer_pm = grocer_p1;
  grocer_fm = grocer_f1;
  grocer_f1 = grocer_f2;
  grocer_p1 = grocer_p2;
else		
  grocer_pm = grocer_p2;	
  grocer_fm = grocer_f2;
end
 
grocer_xd = grocer_pm-grocer_p1;
grocer_p2 = grocer_pm+grocer_xd;
grocer_f2 = grocer_f(grocer_p2,varargin(:))
 
while grocer_f2<=grocer_fm then
  grocer_xd = 2*grocer_xd;
  grocer_p2 = grocer_pm+grocer_xd;
  grocer_f2 = grocer_f(grocer_p2,varargin(:))
end
 
grocer_x1 = grocer_d1*grocer_p1+grocer_d2*grocer_p2;
grocer_x2 = grocer_d2*grocer_p1+grocer_d1*grocer_p2;
grocer_fx1 = grocer_f(grocer_x1,varargin(:))
grocer_fx2 = grocer_f(grocer_x2,varargin(:))
 
while sqrt(sum(grocer_p1-grocer_p2).^2)>=grocer_tol then
  grocer_x1 = grocer_d1*grocer_p1+grocer_d2*grocer_p2;
  grocer_x2 = grocer_d2*grocer_p1+grocer_d1*grocer_p2;
  grocer_fx1 = grocer_f(grocer_x1,varargin(:))
  grocer_fx2 = grocer_f(grocer_x2,varargin(:))
 
  if grocer_fx1<=grocer_fx2 then
    grocer_p2 = grocer_x2;
  else
    grocer_p1 = grocer_x1;
  end
end
 
if grocer_fx1<grocer_fx2 then
  grocer_pout = grocer_x1;
else
  grocer_pout = grocer_x2;
end
 
grocer_fout = grocer_f(grocer_pout,varargin(:))
endfunction
