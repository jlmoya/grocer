function [x,y,grocer_boundsvarb,grocer_prests,grocer_listcoef,grocer_namey,grocer_ncoefeqs,X]=explosys(grocer_namecoef,grocer_speccara,grocer_speccarb,grocer_unequal,grocer_dropna,varargin)
 
// PURPOSE: from a series of equations retrieve the matrix of
// exogenous variables, taking into acount the constraints (if
// any) imposed on the coefficients; the equations must be
// linear in the coefficients
// ------------------------------------------------------------
// INPUT:
// * grocer_namecoef = column vector of coefficients names
// * grocer_speccara = column vector of characters that must be
//   found after the name of a coefficient
// * grocer_speccarb = column vector of characters that must be
//   found before the name of a coefficient
// * grocer_uneven = a boolean indicating whether the equations
//   should keep their time bounds or must have common bounds
// * grocer_dropna = a boolean indicating whether the program
//   should keep only lines of matrices y and grocer_x
//   with non na values in both matrices (suppose that
//   grocer_testna has been set to %f)
// * varargin = equations containing the coefficients named in
//   grocer_namecoef or 'unbal' for un unabalanced panel in a
//   sur estimation (in that case must be in the first
//   position)
// ------------------------------------------------------------
// OUTPUT:
// * x = (nobs x k) matrix of exogenous variables in the
//   complete model
// * y = (nobs x 1) vector of endogenous variables in the
//   complete model
// * grocer_boundsvarb = bounds (if any) of the regression
// * grocer_prests = a boolean indicating the presence or
//   absence of ts in the regressions
// * grocer_listcoef = list of indexes of the coefficients in
//   each equation
// * grocer_namey = column vector of the names of the
//   endogenous variables
// * grocer_ncoefeqs = column vector of the # of coefficients
//   in each equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2006
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_nargin=length(varargin)
grocer_ncoef=size(grocer_namecoef,1)
grocer_listeq=varargin
grocer_listcoef=list()
grocer_namey=[]
 
if grocer_unequal then
   grocer_diffd=diff_date(grocer_boundsvar($),grocer_boundsvar(1))+1
   ts0=reshape(%nan*ones(grocer_diffd,1),grocer_boundsvar(1))
end
 
for grocer_j=1:grocer_nargin
   grocer_namey=[grocer_namey part(grocer_listeq(grocer_j),1:...
     strindex(grocer_listeq(grocer_j),'=')-1) ]
   grocer_listeq(grocer_j)=strsubst(grocer_listeq(grocer_j),'=','-(')+')'
   if grocer_unequal then
      grocer_listeq(grocer_j)='overlay(ts0,'+strsubst(grocer_listeq(grocer_j),'=','-(')+')'
   end
   res=analyse_eq(grocer_listeq)
   for grocer_i=1:size(grocer_namecoef,1)
      grocer_coefi=grocer_namecoef(grocer_i)
      grocer_namexoi=deriv_eq(res,grocer_coefi)
   end
end
 
 
[grocer_x,grocer_boundsvarb,grocer_prests,X,grocer_nonna]=...
eq2xcol(ones(grocer_ncoef,1),grocer_listeq,grocer_unequal,grocer_dropna)
grocer_totalnobs=size(grocer_x,1)
x=-numz0(eq2xcol,ones(grocer_ncoef,1),grocer_ncoef,...
ones(grocer_ncoef,grocer_totalnobs),1,grocer_listeq,grocer_unequal,grocer_dropna)'
y=grocer_x+x*ones(grocer_ncoef,1)
 
endfunction
