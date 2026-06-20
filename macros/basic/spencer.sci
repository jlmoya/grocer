function xsp = spencer(x)
 
// PURPOSE: Filter a series using a 15-term two-sided Spencer filter
//----------------------------------------------------------------------
// INPUT:
// * x = a (n x 1) real vector
//----------------------------------------------------------------------
// OUTPUT:
// * xsp = a (n x 1) real vector
//----------------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// from Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
s = [-3,-6,-5,3,21,46,67,74,67,46,21,3,-5,-6,-3];
s = s/sum(s);
 
xpad = [x(1,1)*ones(7,1) ; x ; x(size(x,1),1)*ones(7,1) ] ;
xsp = zeros(size(x,1),1) ;
 
for i =1:size(x,1)
   xsp(i) = s*xpad(i:i+14,1);
end
 
endfunction
 
