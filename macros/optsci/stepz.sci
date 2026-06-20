function [grocer_alpha]=stepz(grocer_xarg,grocer_chf,grocer_infoz,grocer_stat,varargin)
 
// PURPOSE: Determine step size in NUMZ package
// ------------------------------------------------------------
// INPUT:
// * grocer_xarg = vector of model parameters
// * grocer_chf = a string that represents a call to a function
// with all useful arguments; the first one must be called
// grocer_xarg; the other ones if they exists must be called
// varargin(:)
// * grocer_infoz = tlist with settings for maxlik
// * grocer_stat = tlist with minimization status
// * varargin = Variable list of arguments passed to func
// ------------------------------------------------------------
// OUTPUT:
// grocer_alpha = scalar step size
// ------------------------------------------------------------
// REFERENCES:  Numerical Recipes in FORTRAN  (LNSRCH, p. 378)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted (sligthly) from:
// Mike Cliff,  UNC Finance  mcliff@unc.edu
 
//  INITIALIZATIONS
 
grocer_direc = grocer_stat('direc');
grocer_alf = grocer_infoz('ftol');
grocer_fold = grocer_stat('f');
 
grocer_slope = grocer_stat('G')'*grocer_direc;
grocer_temp = max(abs(grocer_direc) ./ max(abs(grocer_xarg),1));
grocer_test = max(grocer_temp,%eps);
// Added to avoid /0 error
grocer_minalpha = grocer_infoz('btol')/grocer_test;
grocer_b0 = grocer_xarg;
 
//  FIND MINIMIZING STEP SIZE
 
// try first full Newton step size
grocer_xarg = grocer_b0+grocer_direc;
execstr('grocer_f = '+grocer_chf)
if grocer_f<(grocer_fold+grocer_slope*grocer_alf) then
// sufficent function decrease
   grocer_alpha=1
   grocer_go = 0;
else
   grocer_go = 1;
   grocer_tmpalpha = -grocer_slope/...
   (2*(grocer_f-grocer_fold-grocer_slope));
   grocer_alpha2 = 1;
   grocer_f2 =grocer_f;
   grocer_alpha = max(grocer_tmpalpha,.1);
end
 
while grocer_go==1 then
   grocer_xarg = grocer_b0+grocer_alpha*grocer_direc;
   execstr('grocer_f = '+grocer_chf)
   if grocer_alpha<grocer_minalpha then
      grocer_go = 0;
      grocer_alpha = 0;
   elseif grocer_f<(grocer_fold+grocer_alpha*grocer_slope*grocer_alf) then
// sufficent function decrease
      grocer_go = 0;
   else
      grocer_rhs1 = grocer_f-grocer_fold-grocer_alpha*grocer_slope;
      grocer_rhs2 = grocer_f2-grocer_fold-grocer_alpha2*grocer_slope;
      grocer_a = (grocer_rhs1/(grocer_alpha^2)-grocer_rhs2/...
      (grocer_alpha2^2))/(grocer_alpha-grocer_alpha2);
      grocer_b = (-grocer_alpha2*grocer_rhs1/(grocer_alpha^2)+...
      grocer_alpha*grocer_rhs2/(grocer_alpha2^2))/...
      (grocer_alpha-grocer_alpha2);
      if grocer_a==0 then
         grocer_tmpalpha = -grocer_slope/(2*grocer_b);
      else
         grocer_disc = grocer_b^2-3*grocer_a*grocer_slope;
         if grocer_disc<0 then
            grocer_tmpalpha=0.5*grocer_alpha
         elseif grocer_b <= 0 then
            grocer_tmpalpha = (-grocer_b+sqrt(grocer_disc))/...
            (3*grocer_a);
         else
            grocer_tmpalpha=-grocer_slope/(grocer_b+sqrt(grocer_disc))
         end
      end
      grocer_tmpalpha = min(grocer_tmpalpha,.5*grocer_alpha);
      grocer_alpha2 = grocer_alpha;
      grocer_f2 =grocer_f;
      grocer_alpha = max(grocer_tmpalpha,.1*grocer_alpha);
   end
end
endfunction
