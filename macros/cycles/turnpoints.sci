function [bcp,bct] = turnpoints(y,k)
 
// PURPOSE: rough selection of peaks and troughs indexes
//---------------------------------------------------------------------
// INPUT:
// . y = vector of data
// . k = x(t-i)>x(t) & x(t+i)>x(t), i=1:k defines a trough at t
//       x(t-i)<x(t) & x(t+i)<x(t), i=1:k defines a peak at t
//---------------------------------------------------------------------
// OUTPUTS :
// . bcp = vector of peak indexes
// . bct = vector of trough indexes
//---------------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// from Julien Matheron
// Banque de France, centre de recherche, sept. 2002
 
[T,n] = size(y);
if T<n then
   y = y';
   [T,n] = size(y);
end;
v = zeros(T,n);
 
// ------------------------------------------
// I. Defines the k-dependent logical
// argument of the following "if-loops"
// ------------------------------------------
 
s_up = "(y(i)>y(i-1))";
s_do = "(y(i)<y(i-1))";
 
for step = 2:k;
   s_up = joinstr(s_up,msprintf("&(y(i)>y(i-%d))",step),'+');
   s_do = joinstr(s_do,msprintf("&(y(i)<y(i-%d))",step),'+');
end;
 
for step=1:k
   s_up = joinstr(s_up,msprintf("&(y(i)>y(i+%d))",step),'+');
   s_do = joinstr(s_do,msprintf("&(y(i)<y(i+%d))",step),'+');
end;
 
 
// ------------------------------------------
// II. Defines peaks
// ------------------------------------------
 
for i = k+1:T-k ;
   if evstr(s_up) then
      v(i) = 1;
   end;
end
bcp = find(v>0)'; // selects indexes such that a peak occurs
 
// ------------------------------------------
// III. Defines troughs
// ------------------------------------------
 
v = zeros(T,n); // reinitializes v
 
for i = k+1:T-k
   if evstr(s_do) then
      v(i) = 1 ;
   end;
end;
bct = find(v>0)'; // selects indexes such that a trough occurs
endfunction
