function [indmin,indmax]=longest_nonna_span(y,orient)
 
// PURPOSE: find the longest sequence of non na lines or
// columns in a matrix
// ------------------------------------------------------------
// INPUT:
// * y = a (N x k) matrix
// * orient = an optional argument inidcating the type of the
//  resulting matrix ('c' - default- or 'r')
// ------------------------------------------------------------
// OUTPUT:
// * indmin = the first index of the sequence
// * indmax = the last index of the sequence
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   orient='c'
end
nonna=find(and(~isnan(y),orient))
if isempty(nonna) then
   error('there is no date with non %nan value')
end
indmin=nonna(1)
del_nonna=nonna-nonna(1)-[0:size(nonna,'*')-1]
ind_del0=find(del_nonna==0)
indmax=nonna(ind_del0($))
length_per=ind_del0($)
 
 
while del_nonna($) ~= 0
    nonna=nonna(ind_del0($)+1:$)
    indmin1=nonna(1)
    del_nonna=nonna-nonna(1)-[0:size(nonna,'*')-1]
    ind_del0=find(del_nonna==0)
    indmax1=nonna(ind_del0($))
    length_per1=ind_del0($)
    if length_per1 > length_per then
       indmin=indmin1
       indmax=indmax1
    end
 
end
 
endfunction
