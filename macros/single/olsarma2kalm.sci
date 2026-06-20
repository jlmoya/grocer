function [Phi,Gam,E,H,D,C,Q,S,R]=olsarma2kalm(x,AR,MA)
 
// PURPOSE: transform the parameters entered bt the user into
// the standard matrices used by the Kalman filter
//
// The model is:
// Y = X*b + U
// with: AR(L) U = MA(L)*E
// ------------------------------------------------------------
// INPUT:
// * x = a (nobs x nvar) real matrix of exogenous variables
// * AR = a (nar x 1) or (1 x nar) string or real vector of
//   parameters corresponding to the AR part of the error
//   process
//     . if AR is a real then all parameters are estimated
//     . if AR is a string then all parameters with in AR
//     with an equality (such as '=0.5') are constrained to
//     the given value (0.5 in the example)
//     . if AR is a string then it can contain inequality
//    constraints; for instance '<0.5' indicates that coeff
//    must be lower than 0.5
//     . if initown is set to %F, then the user can give any
//     value to AR; only it size matters for the estimation
//     process
//    . if initown is set to %F,
// * MA = a (nmaf x 1) or (1 x nmaf) string or real vector of
//   corresponding to the AR part of the error, with the same
//   working as for AR
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
nAR=size(AR,'*')
nMA=size(MA,'*')
nmax=max([nAR nMA+1])
nx=size(x,2)
 
Phi=emptystr(nmax,nmax)+'=0'
nmax=max([nAR nMA+1])
// Note: nmax is calculated again because of bug in the emptystr
// function in Scilab versions 5.0 until 5.2.0
 
for i=1:nmax-1
   Phi(i+1,i)='=1'
end
 
AR=string(vec2row(AR))
Phi(1,1:nAR)=string(vec2row(AR))
 
Gam=emptystr(nmax,nx)+'=0'
E='='+string([1; zeros(nmax-1,1)])
Q=1
H=['=1'  emptystr(1,nmax-1)+'=0']
 
MA=string(vec2row(MA))
H(2:nMA+1)=string(MA)
 
D=ones(1,size(x,2))
R=[]
S=[]
C=[]
 
endfunction
