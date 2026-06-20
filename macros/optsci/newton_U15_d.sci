function [x0,f0,maxf0]=newton_U15_d()
    
// Search the zero of function test_func in the optsci folder. The function codes the example 3 provided by
// Liu, Zheng and Huang (2016), Third- and fifth-order Newton–Gauss methods for solving nonlinear equations with n variables,
// Applied Mathematics and Computation, n. 290, p. 250-257.
// The function to minimize is:
// 4*(x(1)-x(2)^2)+x(2)-x(3)^2 = 0
// x(2)*(x(2)^2-x(1))-2*(1-x(2))+4*(x(2)-x(3)^2)+x(3)-x(4)^2=0
// (3)*(x(3)^2-x(2))-2*(1-x(3))+4*(x(3)-x(4)^2)+x(2)^2-x(1)+x(4)-x(5)^2=0
// x(4)*(x(4)^2-x(3))-2*(1-x(4))+4*(x(4)-x(5)^2)+x(3)^2-x(2)=0
// x(5)*(x(5)^2-x(4))-2*(1-x(5))+x(4)^2-x(3)=0
// The corresponding Jacobian function is coded in function test_Jac
// Starting values are the ones provided in the paper: [1.2 ; 1.2 ; 1.2 ; 1.2 ; 1.2]
// Convergence criterion is set to 1e-10, maximum # of iterations is set to 1000, minimum value used to dampen the step is set to
 
[x0,f0,maxf0]=newton_U15(1.2*ones(5,1),newton_testfunc,newton_testJac,1e-10,1000,0.05)

endfunction
