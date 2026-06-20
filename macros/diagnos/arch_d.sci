function [rarch]=arch_d()
 
// PURPOSE: demo of arch() test for ARCH(p)
//
//---------------------------------------------------
// USAGE: arch_d()
//---------------------------------------------------
 
// generate heteroscedastic regression model
 
 
 
x = rand(100,3,'n');
b = ones(3,1);
tt = 1:100
tt = tt';
 
y = x*b+rand(100,1,'n') .* tt;
tt=sqrt(autocum(4*ones(1,100),0.95)').*rand(100,1,'n')
y = x*b+ tt;
 
// do regression
 
result = ols('y','x');
rarch = archz(result,2)
 
// call arch() function using ols residuals
// and a vector of orders 1,2
endfunction
