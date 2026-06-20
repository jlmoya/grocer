function grocer_H=hessian(grocer_func,grocer_p,grocer_delta,varargin)
 
// PURPOSE: Computes finite symmetric difference Hessian
// ------------------------------------------------------------
// INPUT:
// * grocer_func = name of the function
// * grocer_p = point where to evaluate the function
// * vararagin = arguments other than p of funtion func
// ------------------------------------------------------------
// OUTPUT:
// * grocer_H = value of the hessian of func at point p
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2020
// http://grocer.toolbox.free.fr/grocer.html


grocer_n = size(grocer_p,1);
 
// Compute the stepsize (h)
abs_grocer_p=abs(grocer_p)
grocer_h =grocer_delta*(abs_grocer_p.*(abs_grocer_p>=0.5)+(abs_grocer_p<0.5))
grocer_ph = grocer_p+grocer_h;
grocer_h = grocer_ph-grocer_p;
grocer_ee = sparse([ [1:grocer_n]',[1:grocer_n]'],grocer_h,[grocer_n,grocer_n]);
 
grocer_H=grocer_h*grocer_h';
for grocer_i=1:grocer_n
   grocer_ee_i=grocer_ee(:,grocer_i)
   for grocer_j=grocer_i:grocer_n
      grocer_H(grocer_i,grocer_j) = (grocer_func(grocer_p+grocer_ee_i+grocer_ee(:,grocer_j),varargin(:))-...
          grocer_func(grocer_p-grocer_ee_i+grocer_ee(:,grocer_j),varargin(:))-...
          grocer_func(grocer_p+grocer_ee_i-grocer_ee(:,grocer_j),varargin(:))+...
          grocer_func(grocer_p-grocer_ee_i-grocer_ee(:,grocer_j),varargin(:)))/grocer_H(grocer_i,grocer_j)/4;
      grocer_H(grocer_j,grocer_i) = grocer_H(grocer_i,grocer_j);
   end
end

endfunction
