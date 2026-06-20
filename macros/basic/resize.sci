function varargout=resize(varargin)
 
// PURPOSE: tranform matrices with different sizes in matrices
// conformables with
// sizes (mx,nx): needs that one of the dimensions is a is one
// or
// ------------------------------------------------------------
// INPUT:
// * a = a (na x ma) matrix
// * nx = # of rows of the resized matrix
// * mx = # of cols of the resized matrix
// ------------------------------------------------------------
// OUTPUT:
// * a = (nx x mx) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
nrows=ones(nargin,1)
ncols=ones(nargin,1)
for i=1:length(varargin)
   nrows(i)=size(varargin(i),1)
   ncols(i)=size(varargin(i),2)
end
 
nrmax=max(nrows)
ncmax=max(ncols)
varargout=varargin
for i=1:length(varargin)
   nri=nrows(i)
   nci=ncols(i)
   if or([nri,nci] ~= [nrmax,ncmax]) then
      if nri == nrmax & nci ==1 then
         varargout(i)=ones(1,ncmax) .*. varargin(i)
      elseif nci == ncmax & nri == 1 then
         varargout(i)=ones(nrmax,1) .*. varargin(i)
      elseif nci ==1 & nri==1 then
         varargout(i)=varargin(i)*ones(nrmax,ncmax)
      else
         error('dimensions of a not conformable to: '+string(nx)+' and '+string(mx))
      end
   end
end
 
endfunction
