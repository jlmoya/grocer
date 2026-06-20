function m=mean(x,varargin)
 
// Copyright INRIA, Eric Dubois for the part regarding ts
// http://grocer.toolbox.free.fr/grocer.html
// & Emmanuel Michaux for the part regarding tsmat
[lhs,rhs] = argn()
 
if rhs == 0 | rhs > 2 then
  error(msprintf(gettext("%s: Wrong number of input argument: %d to %d expected.\n"),"mean",1,2)),
end
 
if rhs == 2 then
   select varargin(1)
 
   case 'r' then
	  varargin(1)=1
 
   case 'c' then
	  varargin(1)=2
 
   case 'm' then
 
	  varargin(1)=find(size(x)>1,1)
	  if varargin(1)==[] then
         varargin(1)=1
	  end
 
   end
   if floor(varargin(1))~=varargin(1) | varargin(1) < 1 | ...
     ( and(typeof(x) ~= ['tsmat' ; 'ts']) & varargin(1) > length(size(x))) then
      error(msprintf(gettext("%s: Wrong type for input argument #%d: Scalar or vector expected.\n"),"mean",2)),
   end
end
 
select typeof(x)
 
case 'tsmat' then
   m=x
   x=x('series')
   y=mean0(x,varargin(:))
   if ~isempty(varargin) then
      m('series') = y
      nam='var '+string(1:size(m('series'),2))
      m('names')=nam'
      m(1)(1) = 'ts'
   else
      m =y
   end
   return
 
case 'ts' then
   x=x('series')
 
case 'hypermat' then
   if type(x.entries) ~= 1 then
	  error(msprintf(gettext("%s: Wrong type for input argument #%d.\n"),"mean",1))
   end
	
else
   if typeof(x) ~= 'constant' then
	  error(msprintf(gettext("%s: Wrong type for input argument #%d: Real vector or matrix expected.\n"), "mean",1))
   end
end
m=mean0(x,varargin(:))
 
endfunction
