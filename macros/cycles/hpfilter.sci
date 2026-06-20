function [hpy]=hpfilter(y,lambda)
 
// PURPOSE: Hodrick Prescott filter
// ------------------------------------------------------------
// INPUT:
// * y = either
//   . a time series, or
//   . a real (nx1) vector, or
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
// * lambda = the smoothing parameter
// ------------------------------------------------------------
// OUTPUT:
// hpy= the smoothed filtered series of the same type than y
// (if y is not a string) or evstr(y) (if y is a string)
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2020
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// Ivailo Izvorski,
//          Department of Economics
//          Yale University.
//          izvorski@econ.yale.edu
 
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
[s,namey,prests,boundsvarb]=explone(y)
 
if prests & exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) > 2 then
      error('bounds are discontinous in hpfilter')
   end
end
 
t = size(s,1);
a = 6*lambda+1;
b = -4*lambda;
c = lambda;
d = [c,b,a];
d = ones(t,1)*d;
m = diag(d(:,3))+diag(d(1:t-1,2),1)+diag(d(1:t-1,2),-1);
m = m+diag(d(1:t-2,1),2)+diag(d(1:t-2,1),-2);
 
m(1,1) = 1+lambda;
m(1,2) = -2*lambda;
m(2,1) = -2*lambda;
m(2,2) = 5*lambda+1;
m(t-1,t-1) = 5*lambda+1;
m(t-1,t) = -2*lambda;
m(t,t-1) = -2*lambda;
m(t,t) = 1+lambda;
 
s = inv(m)*s;
 
if prests then
   hpy=reshape(s,boundsvarb(1))
else
   hpy=s
end
endfunction
