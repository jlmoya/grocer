function [r]=autoprobit_d()
// PURPOSE: An example of logit(),
//                        prt_reg().
//  maximum likelihood estimation
//  (data from Spector and Mazzeo, 1980)
//---------------------------------------------------
// USAGE: logit_d
//---------------------------------------------------
 
// grade variable
 
 
grade = zeros(32,1);
grade(5,1)  = 1;
grade(10,1) = 1;
grade(14,1) = 1;
grade(20,1) = 1;
grade(22,1) = 1;
grade(25,1) = 1;
grade(25:27,1) = ones(3,1);
grade(29,1) = 1;
grade(30,1) = 1;
grade(32,1) = 1;
 
// psi variable
psi = [zeros(18,1) ; ones(14,1)]
tuce = [20 22 24 12 21 17 17 21 25 29 20 23 23 25 26 19 ...
        25 19 23 25 22 28 14 26 24 27 17 24 21 23 21 19]'
 
gpa = [2.66 2.89 3.28 2.92 4.00 2.86 2.76 2.87 3.03 3.92 ...
       2.63 3.32 3.57 3.26 3.53 2.74 2.75 2.83 3.12 3.16 ...
       2.06 3.62 2.89 3.51 3.54 2.83 3.39 2.67 3.65 4.00 ...
       3.10 2.39]'
 
x1=grand(32,1,'unf',0,5)
x2=grand(32,1,'unf',0,10)
x3=grand(32,1,'unf',2,6)
write(%io(2),' ','(a)')
disp([x1 x2 x3])
write(%io(2),' ','(a)')
r = automatic('grade','const','psi','tuce','gpa','x1','x2','x3'...
,'estim=probit');
 
endfunction
