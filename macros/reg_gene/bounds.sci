function []=bounds(varargin)
 
// PURPOSE: sets the bounds of a regression
// ------------------------------------------------------------
// INPUT:
// a series of dates strings
// ------------------------------------------------------------
// OUTPUT:
// Nothing: the bounds are transferred to the upper level in a
// (p x 1) vector by the argument resume
// ------------------------------------------------------------
// NOTES: the choice made to have bounds which remain valid
// until the user leaves the environment (a working space or
// a function) can be discussed: it is not without danger,
// since bounds used by a program can be different from the
// ones the user intended to use; it mimics the Portable
// Troll choice and is very convenient...
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
boundsvar=[]
fq=[]
bnum=[]
 
if modulo(nargin,2) == 1 then
   error('the number of your arguments is not even')
end
 
for i=1:nargin
   boundsvar=[boundsvar ; varargin(i)]
   [bnumi,fqi]=date2num_fq(varargin(i))
   bnum=[bnum;bnumi]
   fq=[fq;fqi]
end
 
if ~isempty(boundsvar) then
   if or(fq- (fq(1,:) .*. ones(size(fq,1),1)) ~=0) then
      error('your bounds have not the same ferquency')
   end
 
   if or(bnum(2:$)-bnum(1:$-1) < 0) then
      error('your bounds are not increasing')
   end
end
[grocer_boundsvar,grocer_boundsvarnum,grocer_boundsfq]=resume(boundsvar,bnum,fq(1,:))
 
endfunction
