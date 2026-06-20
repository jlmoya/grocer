function [theta,theta2mat,thetalab,grocer_X,grocer_indtheta,grocer_ineq,mat2thet]=mat2theta(grocer_namex,grocer_indtheta,grocer_ineq,grocer_sym,grocer_m,grocer_nvar)
 
// PURPOSE: transforms a matrix into a vector of parameters
// ------------------------------------------------------------
// INPUT:
// * grocer_namex = a string representing the name of either:
//   - a (m x n) matrix of constant type
//   - a (m x 1) vector representing the diagonal of a
//      (m x m) matrix
//   - a list with 2 elements:
//      ° a (m x n) matrix of constant type
//      ° a (m x n) matrix of string type of constraints
//   ('' for no constraint, '=' for equality constraint,
//    'value<*', '*<value' or 'value1<*<value2' for inequality
//    constraints)
// * grocer_ineq = vector of grocer_inequality constraints
// * grocer_sym = %T if the matrix is symetric
//         %F if it is not
// * grocer_m = a scalar, the # of rows of matrix grocer_namex
// * grocer_nvar = a scalar, the # of endogenous variables
// ------------------------------------------------------------
// OUTPUT:
// * theta = a (p x 1) vector of parameters
// * theta2mat = a (q x 1) vector of strings, representing the
//   instructions that transform back theta into the input
//   matrix
// * theatlab = the names of the elements in the input matrix
//   that will be estimated
// * grocer_X = the (m x n) matrix corresponding to the input
// * grocer_indtheta = p = the # of parameters
// * grocer_ineq = %T if there are some grocer_inequality constraints
//         %F if not
// ------------------------------------------------------------
// NOTE: used by varma function arma2param
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2022
// http://grocer.toolbox.free.fr/grocer.html
 
 
theta=[]
mat2thet=[]
theta2mat=[]
thetalab=[]
grocer_indtheta0=grocer_indtheta
 
grocer_X=evstr(grocer_namex)
select typeof(grocer_X)
case 'constant' then
// there is no constraint on the coefficient of the matrix
   if grocer_X ~= [] then
   // matrix is not empty
      [nr,nc]=size(grocer_X)
      if nr==1 & nc==1 then
         theta=grocer_X
         theta2mat=[grocer_namex+'=theta('+string(grocer_indtheta+1)+')']
         mat2thet=['theta('+string(grocer_indtheta+1)+')='+grocer_namex]
         thetalab=[grocer_namex+' - lag 1']
         grocer_indtheta=grocer_indtheta+1
 
      elseif grocer_sym then
      // only the lower part of the matrix will be estimated
         if nr==1 | nc==1 then
         // only the diagonal is non zero
            theta=grocer_X
            theta2mat=[grocer_namex+'=diag(theta('+string(grocer_indtheta+1)+':'+..
               string(grocer_indtheta+max(nr,nc))+'))']
            mat2thet=['theta('+string(grocer_indtheta+1)+':'+..
               string(grocer_indtheta+max(nr,nc))+')=diag('+grocer_namex+')']
            thetalab=[grocer_namex+'('+string([1:max(nr,nc)]')+','+...
                   string([1:max(nr,nc)]')+')']
            grocer_X=diag(grocer_X)
            grocer_indtheta=grocer_indtheta+max(nr,nc)
         else
            theta=vech(grocer_X)
            theta2mat=[grocer_namex+'=invvech(theta('+string(grocer_indtheta+1)+':'+..
               string(grocer_indtheta+nr*(nr+1)/2)+'),'+string(nr)+')']
            mat2thet=['theta('+string(grocer_indtheta+1)+':'+..
               string(grocer_indtheta+nr*(nr+1)/2)+')=vech('+grocer_namex+')']
            thetalab=[vech(grocer_namex+'('+string([1:nr]' .*. ones(1,nc))+','+...
               string(ones(nr,1) .*. [1:nc])+')')]
            grocer_indtheta=grocer_indtheta+nr*(nr+1)/2
         end
 
      else
      // transforms the matrix into a vector of parameters
         theta=matrix(grocer_X,nr*nc,1)
         theta2mat=[grocer_namex+'=matrix(theta('+string(grocer_indtheta+1)+':'+...
            string(grocer_indtheta+nr*nc)+'),'+string(nr)+','+string(nc)+')']
         mat2thet=['theta('+string(grocer_indtheta+1)+':'+...
         string(grocer_indtheta+nr*nc)+')=matrix('+grocer_namex+','+string(nr)+'*'+string(nc)+',1)']
 
         nlags=nc/grocer_nvar
         str_lags=emptystr();
         str_eqs=emptystr();
         str_vars=emptystr();
         if nlags ~= 1 then
            str_lags=' - lag '+string([1:nlags]' .*. ones(grocer_nvar*nr,1))
         end
         if grocer_m ~= 1 then
            str_eqs=' eq '+string(ones(grocer_nvar*nlags,1) .*. [1:grocer_m]' )
         end
         if nr ~= 1 then
            str_vars=' - var # '+string(ones(nlags,1) .*. ([1:grocer_nvar]' .*. ones(nr,1) ))
         elseif grocer_nvar ~= 1 then
            str_vars=' - var # '+string(ones(nlags,1) .*. ([1:grocer_nvar]' .*. ones(nr,1) ))
         end
         str_all=str_eqs+str_vars+str_lags
         indt=strindex(str_all(1),'-')
         if isempty(indt) then
            thetalab=[thetalab ; grocer_namex]
         elseif indt(1) == 2 then
            thetalab=[thetalab ; stripblanks(grocer_namex+part(str_all,3:length(str_all($))))]
         else
            thetalab=[thetalab ; grocer_namex+str_all]
         end
         grocer_indtheta=grocer_indtheta+nr*nc
      end
      grocer_ineq=[grocer_ineq ; [-%inf  %inf] .*. ones(grocer_indtheta-grocer_indtheta0,1)]
   end
 
case 'string' then
   grocer_X=stripblanks(grocer_X)
   [grocer_nr,grocer_nc]=size(grocer_X)
   grocer_nlags=grocer_nc/grocer_nvar
   for grocer_i=1:grocer_nr
      if grocer_sym then
         grocer_endc=grocer_i
      else
         grocer_endc=grocer_nc
      end
 
      for grocer_j=1:grocer_endc
 
         grocer_ineq=[grocer_ineq ; -%inf %inf]
         grocer_xij=grocer_X(grocer_i,grocer_j)
         grocer_indineq=strindex(grocer_xij,'<')
 
         if ~isempty(grocer_indineq) then
            theta2mat=[theta2mat ; grocer_namex+'('+string(grocer_i)+','+string(grocer_j)+')=theta('+string(grocer_indtheta+1)+')']
            mat2thet=[mat2thet ; 'theta('+string(grocer_indtheta+1)+')='+grocer_namex+'('+string(grocer_i)+','+string(grocer_j)+')']
 
            grocer_indinf=part(grocer_xij,1:grocer_indineq(1)-1)
            grocer_indsup=part(grocer_xij,grocer_indineq($)+1:length(grocer_xij))
            if ~isempty(grocer_indinf) then
            // there is an inequality constraint of the type: m<coeff
               grocer_ineq($,1)=evstr(grocer_indinf)
               theta=[theta ; grocer_ineq($,1)+sqrt(%eps) ]
            end
            if ~isempty(grocer_indsup) then
               grocer_ineq($,2)=evstr(grocer_indsup)
               if isempty(grocer_indinf) then
                  theta=[theta ; grocer_ineq($,2)-sqrt(%eps) ]
               end
            end
            grocer_X(grocer_i,grocer_j)=string(theta($))
            grocer_indtheta=grocer_indtheta+1
 
            if grocer_nlags == 1 then
               thetalab=[thetalab ; grocer_namex+'('+string(grocer_i)+','+string(grocer_j)+')']
            else
               grocer_indlag=floor((grocer_j-1)/grocer_nvar)+1
               grocer_indvar=grocer_j-grocer_nvar*(grocer_indlag-1)
               thetalab=[thetalab ; grocer_namex+' - eq '+string(grocer_i)+...
                   ' - var '+string(grocer_indvar)+' - lag '+string(grocer_indlag)]
            end
 
         elseif ~isempty(strindex(grocer_xij,'=')) then
            grocer_X(grocer_i,grocer_j)=strsubst(grocer_xij,'=','')
            if grocer_sym then
               grocer_X(grocer_j,grocer_i)=grocer_X(grocer_i,grocer_j)
            end
 
         else
            theta2mat=[theta2mat ; grocer_namex+'('+string(grocer_i)+','+string(grocer_j)+')=theta('+string(grocer_indtheta+1)+')']
            mat2thet=[mat2thet ; 'theta('+string(grocer_indtheta+1)+')='+grocer_namex+'('+string(grocer_i)+','+string(grocer_j)+')']
            grocer_indlag=floor((grocer_j-1)/grocer_nvar)+1
            grocer_indvar=grocer_j-grocer_nvar*(grocer_indlag-1)
            thetalab=[thetalab ; grocer_namex+' - eq '+string(grocer_i)+...
                      ' - var '+string(grocer_indvar)+' - lag '+string(grocer_indlag)]
            theta=[theta ; evstr(grocer_xij)]
            grocer_indtheta=grocer_indtheta+1
         end
      end
   end
   grocer_X=evstr(grocer_X)
 
else
   error('type of '+grocer_namex+' should be string or constant, not '+typeof(grocer_X))
end
 
endfunction
