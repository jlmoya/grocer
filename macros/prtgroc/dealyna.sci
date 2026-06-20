function [listx,listy]=dealyna(y)
 
// PURPOSE: Split a vector y into a series of vectors, each
// containing only non NA successive values;save them into a
// list and save into another list the vectors of corresponding
// observations
// ------------------------------------------------------------
// INPUT:
// * y = a row or column vector
// ------------------------------------------------------------
// OUPTUT:
// * listx = list of coordinates corresponding to non NA
//   vectors
// * listy = list of vectors of Successive non NA values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
y=vec2row(y)
nobs=size(y,2)
yna=isnan(y)
// miny=min(y(~yna))
// maxy=max(y(~yna))
if and(~yna) then
   listx=list([1:nobs])
   listy=list(y)
else
   ynas=bool2s(yna)
   ynadif = ynas(:,2:nobs) - ynas(:,1:nobs-1)
   diffyr= (ynadif ~= 0)
   [ir,ic]=find(diffyr)
   // diffna is true when a series becomes na or stops to be na
   changena=[0 gsort(ic,'g','i') nobs]
   changena=changena+1
   // changena is true for observations when the state of the
   // series changes
   listx=list()
   listy=list()
   for i=1:size(changena,2)-1
      if ~isnan(y(changena(i))) then
         xaux=[changena(i):changena(i+1)-1]
         yaux=y(:,xaux)
         listx($+1) = xaux
         listy($+1) = yaux
      end
   end
end
 
endfunction
