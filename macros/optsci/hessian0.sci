function [Hess] = hessian0(fun,x,delta,varargin)


//hessian Compute the numeric Hessian matrix of a multivariate function
// 
// Syntax:
// 
//   Hess = hessian(fun,x)
//   Hess = hessian(fun,x,varargin)
// 
// Description:
// 
//   The Hessian matrix is computed by finite difference
//   Central difference (default)
//   5 points are used to evaluate the diagonal elements
//   4 points are used to evaluate other elements
//   Forward/backward difference
//   4 points are used to evaluate each elements. Many evaluations can reuse
// 
// Input Arguments:
// 
//   fun - a function handle that takes a vector input
// 
//   x   -   evaluation point of the Hessian matrix
// 
//   varargin - other input arguments to the user supplied function
// 
// 
// Output Argument:
// 
//   Hess - numeric Hessian matrix
// 
// Notes:
// 
// For central difference, the user supplied function must be able to
// evaluate in a neighborhood (both sides) around the evaluation point of
// the Hessian. If only one side can be evaluated, use forward/backeard
// difference instead.
// 
// Written by Hang Qian, Iowa State University
// Contact me: matlabist@gmail.com

// Size of the Hessian
x =x(:);
dim = size(x,1);

// Step size
deltaVec = max(delta*abs(x),%eps^0.25);
deltaVec = x+deltaVec-x;// This may or may not be useful
deltaMat = diag(deltaVec);

fx = fun(x,varargin(:));

// Compute Hessian by central difference
Hess = zeros(dim,dim);
for m = 1:dim

  // Diagnoal elements use Richardson central difference
  // It has a higher precision than (f(x+2*h) - 2f(x) + f(x-2h)) / 4h^2
   deltam = deltaMat(:,m);
   Hess(m,m) = (- fun(x+2*deltam,varargin(:)) + 16 * fun(x+deltam,varargin(:)) - 30 * fx ...
        + 16 * fun(x-deltam,varargin(:)) -fun(x-2*deltam,varargin(:))) / 12;

   // Other elements use central difference
   for n = m+1:dim
      delta2 = deltaMat(:,n);
      Hess(m,n) = (fun(x+deltam+delta2,varargin(:)) - fun(x+deltam-delta2,varargin(:)) ...
                - fun(x-deltam+delta2,varargin(:)) + fun(x-deltam-delta2,varargin(:))) / 4;
      Hess(n,m) = Hess(m,n);
   end;
end;
Hess = Hess ./(deltaVec*deltaVec');

// If the function cannot be evaluated at both sides, compute forward
// difference Hessian 
mask = ~(abs(Hess)<%inf);

if or(mask) then
   // Compute the Hessian by forward difference
   // One step evaluation will be reused
   funOneStep = zeros(1,dim);
   for m = 1:dim
      funOneStep(m) = fun(x+deltaMat(:,m),varargin(:));
   end;

   HessForward = zeros(dim,dim);
   for m = 1:dim
      HessForward(m,m) = fun(x+2*deltaMat(:,m),varargin(:)) - 2*funOneStep(m) + fx;
      for n = m+1:dim
         HessForward(m,n) = fun(x+deltaMat(:,m)+deltaMat(:,n),varargin(:)) - funOneStep(m) - funOneStep(n) + fx;
         HessForward(n,m) = HessForward(m,n);
      end;
   end;
   HessForward = HessForward ./ (deltaVec*deltaVec');    
   Hess(mask)=HessForward(mask);
   mask = ~abs(Hess)<%inf;

   if or(mask) then
     // Compute the Hessian by backward difference
     // One step evaluation will be reused
      funOneStep = zeros(1,dim);
      for m = 1:dim
         funOneStep(m) = fun(x-deltaMat(:,m),varargin(:));
      end;
  
      HessBackward = zeros(dim,dim);
      for m = 1:dim
         HessBackward(m,m) = fun(x-2*deltaMat(:,m),varargin(:)) - 2*funOneStep(m) + fx;
         for n = m+1:dim
            HessBackward(m,n) = fun(x-deltaMat(:,m)-deltaMat(:,n),varargin(:)) - funOneStep(m) - funOneStep(n) + fx;
            HessBackward(n,m) = Hess(m,n);
         end;
      end;
      HessBackward = HessBackward ./(deltaVec*deltaVec');
      Hess(mask)=HessBackward(mask);
   end;
end;


endfunction
