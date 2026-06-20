function [x0,f0,maxf0]=newton_GGN11_sp_d()
    
// Search the zero of function test_func in the optsci folder. The function codes the problem 7 provided by
// Sharma, Sharma and Bahl (2016), An improved Newton–Traub composition for solving systems of nonlinear equations,
// Applied Mathematics and Computation, N. 290, p. 98-110.
// The function to minimize is:
// x(i)x(i+1)=1 for i=1:98
// x(99)x(1)=1
// The corresponding Jacobian function is coded in function test_Jac_sp
// Starting values are the ones provided in the paper: -4*ones(99,1)
// Convergence criterion is set to 1e-10, maximum # of iterations is set to 1000, minimum value used to dampen the step is set to
 
 
ind_sp=[[1:99 1:99]' , [1:99 2:99 1]']; 
[x0,f0,maxf0]=newton_GGN11_sp(-4*ones(99,1),newton_testfunc_sp,newton_testJac_sp,ind_sp,1e-8,100,0.05)
 
endfunction
