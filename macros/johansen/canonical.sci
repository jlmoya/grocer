function [lambda,du,aind]=canonical(s11,s10,s11,n)
 
sig = pinv(s11)*s10*pinv(s00)*s10';
[au,du]=bdiag(sig,1/%eps)
 
 
endfunction
 
