function [varargout]=balance_identity(grocer_namey0,varargin)
 
// PURPOSE: Balances an identity that does not numerically
// adjust; the residual is shared on each term according
// to its absolute weight
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a ts, a vector, or a string representing
//   the name of a ts or a vector, equal to the left hand
//   side of the identity
// * varargin = arguments that can be:
//   - a ts
//   - a matrix
//   - a string representing the name of a ts or a vector
//   - a list of such objects
//   - the string 'prefix=xxxx' where xxxx is the prefix added
//   to the name of the variables to produce the new variables
//   (optional: if not given, the names are given by the user
//   through the output)
// ------------------------------------------------------------
// OUTPUT:
// * varargout =
//   - either the new rhs terms of the identity
//   - or the string 'results of macro balance_identity have
//   been saved as variables: ' + the names of the variables
//   the new rhs terms are then put in the calling environment
//   under the original name (exogenousi if the anme was not
//   entered between quotes) prefixed by the prefix given by
//   the user
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_ispref=%f
grocer_pref='newx_'
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
grocer_nargin= length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      varargin(grocer_i)=stripblanks(varargin(grocer_i))
      if part(varargin(grocer_i),1:7) == 'prefix=' then
         grocer_ispref=%t
         grocer_pref=strsubst(varargin(grocer_i),'prefix=','')
         varargin(grocer_i)=null()
      end
   end
end
 
// explode the list of the arguments into the corresponding
// variable, its name, and, if necessary updates the bounds
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb]=explouniv(grocer_namey0,varargin)
 
nvar=size(grocer_x,2)
 
// if necessary, define y on the admissible bounds
if typeof(grocer_y) == 'ts' then
   grocer_y=ts2vec(grocer_y,grocer_boundsvarb)
else
   if typeof(grocer_y) ~= 'constant' then
      error('exogenous variable '+namey+' is neither a time series nor a constant vector')
   end
end
 
grocer_namexos=strsubst(grocer_namexos,' # ','')
resid=grocer_y-sum(grocer_x,'c')
abs_x=abs(grocer_x)
abs_sum0=sum(abs_x,'c')
abs_sum=abs_sum0
 
// if each term is 0 -a case that should be very seldom, then
// give an equal weight to each term
abs_sum(abs_sum==0)=1
 
// calculate the weights of the asbolute values of each term
// of the identity
weight=abs_x ./ (ones(1,nvar) .*. abs_sum)
weight(abs_sum0==0,:)=1/nvar
 
// share the residuals on each terme of the identity according to its
// weight
newx=grocer_x+weight .* (ones(1,nvar) .*. resid)
 
// transform the matrix back into vectors or ts
if grocer_prests then
   execstr(joinstr(grocer_pref+'_',grocer_namexos,'=vec2ts(newx(:,',string([1:nvar]'),'),grocer_boundsvarb)',';'))
else
   execstr(joinstr(grocer_pref+'_',grocer_namexos,'=newx(:,',string([1:nvar]'),')',';'))
end
 
// returns the new terms according to the option chosen by the user
if grocer_ispref then
   varargout=list('results of macro balance_identity have been saved as variables: '+...
   joinstr(grocer_pref+'_',grocer_namexos,','))
   execstr('['+joinstr(grocer_pref+'_',grocer_namexos,',')+']=resume('+joinstr(grocer_pref+'_',grocer_namexos,',')+')')
else
   execstr('varargout=list('+joinstr(grocer_pref+'_',grocer_namexos,',')+')')
end
endfunction
