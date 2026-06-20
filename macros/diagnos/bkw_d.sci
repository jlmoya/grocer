function []=bkw_d()
 
 
n = 200;
k = 5;
x = grand(n,k,'nor',0,1);
x(:,1) = ones(n,1);
x(:,3) = x(:,2) + grand(n,1,'nor',0,1)*0.05;
 
// demonstrate BKW collinearity diagnostics
bkw('x');
 
endfunction
