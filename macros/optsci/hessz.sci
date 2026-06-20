function [stat]=hessz(b,infoz,stat,varargin)
 
// PURPOSE: Calculate/update Inverse Hessian
// ------------------------------------------------------------
// REFERENCES:
//     Gill, Murray, Wright (1981)
//     Numerical Recipes in FORTRAN
// ------------------------------------------------------------
// INPUT:
// * b = parameter vector fed to func
// * infoz = structure from MINZ
// * stat = status structure from MINZ
// * varargin = arguments list passed to func
// ------------------------------------------------------------
// INPUT:
// stat = updated status structure with new inverse Hessian
// ------------------------------------------------------------
// NOTES: Supports the following search direction algorithms:
//         *  Steepest Descent (SD)
//         *  Gauss-Newton (GN)
//         *  Levenberg-Marquardt (MARQ)
//         *  Davidon-Fletcher-Powell (DFP)
//         *  Broyden-Fletcher-Goldfarb-Shano (BFGS)
//
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adpated from
// Mike Cliff,  UNC Finance  mcliff@unc.edu
 
 
//   INITIALIZATIONS
 
k = size(b,1);
lvar = length(varargin);
 
if infoz('call')=='gmm'|infoz('call')=='ls' then
  if infoz('call')=='gmm' then
    wdum = 1;
  else
    wdum = 0;
  end
   execstr('m='+infoz('momt')+'(b,infoz,stat,varargin(1:lvar-wdum))')
   execstr('M='+infoz('jake')+'(b,infoz,stat,varargin(1:lvar-wdum))')
  if infoz('call')=='gmm' then
    W = varargin(lvar);
  else
    W = eye(size(M,1));
  end
 
  gnbase = M'*W*M;
else
 
  gnbase = eye(k,k);
  // Could replace with some other pd matrix
end
 
dG = stat('dG');
db = stat('db');
Hi0 = stat('Hi');
 
//   UPDATE INVERSE HESSIAN BY CASE
 
select infoz('hess')
case 'sd' then
  // Steepest Descent
   Hi = eye(k,k);
 
case 'gn' then
  // GN/Marq directions
  H = gnbase;
 
  Hi = H\eye(k,k);
case 'marq' then
  // GN/Marq directions
  H = gnbase;
  lambda = infoz('lambda');
  Hcond = cond(gnbase);
  while Hcond>infoz('cond') then
    H = gnbase+lambda*eye(k,k);
    Hcond = cond(H);
    lambda = lambda*2;
    // may be a better factor for increases
  end
  Hi = H\eye(k,k);
 
case 'dfp' then
  // DFP/BFGS
  if stat('Hi')==[] then
    if infoz('H1')==1 then
       Hi = eye(k,k)
       // Initial Hessian
    else
       Hi = gnbase\eye(k,k)
    end
  else
    if db'*dG>sqrt(%eps*(db'*db)*(dG'*dG)) then
 
      // ------- Based on update of inverse given in Num. Recipes, p. 420 -------
      a = db*db'/(db'*dG);
      b = -Hi0*dG*dG'*Hi0'/(dG'*Hi0*dG);
      c = zeros(k,k);
      Hi = Hi0+a+b+c;
    else
      Hi = stat('Hi');
    end
  end
 
case 'bfgs' then
  // DFP/BFGS
   if stat('Hi')==[] then
      if infoz('H1')==1 then
         Hi = eye(k,k)
         // Initial Hessian
      else
         Hi = gnbase\eye(k,k)
      end
    else
       dbdg=db'*dG
       dgdg=dG'*dG
       if dbdg>sqrt(%eps*db'*db*dgdg) then
 
         // Based on update of inverse given in Num. Recipes, p. 420
         a=db*db'/dbdg
         hi0dg=Hi0*dG
         dghi0dg=dG'*hi0dg
         b=-hi0dg*hi0dg'/dghi0dg
         c=db/dbdg-hi0dg/dghi0dg
         Hi = Hi0+a+b+dghi0dg*c*c'
      else
         Hi = stat('Hi');
      end
   end
 
else
  error('UNKNOWN HESSIAN TYPE');
end
 
//   CHECK CONDITIONING AND RETURN RESULT
 
stat('Hcond')=cond(Hi)
if stat('Hcond')>infoz('cond') then
  stat('star')='*'
else
  stat('star')=' '
end
stat('Hi')=Hi
endfunction
