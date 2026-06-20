function [E4OPTION]=e4init()
// E4INIT   - Initializes the global variables in the toolbox.
//    e4init
// This function must be executed once at the toolbox operation beginning.
//
// 11/3/97
// Copyright (c) Jaime Terceiro, 1997
 
E4OPTION = zeros(51,1);
 
E4OPTION(1) = 1       // Kalman filter
E4OPTION(2) = 0       // No scaling of B
E4OPTION(3) = 4       // Inverse De Jong
E4OPTION(4) = 5       // Automatic selection
E4OPTION(5) = 0       // Variances
E4OPTION(6) = 1       // BFGS algorithm
E4OPTION(7) = .1      // step length
E4OPTION(8) = .00001  // stop tolerance
E4OPTION(9) = 75      // Maximum number of iterations
E4OPTION(10) = 1      // Verbose optimization
  // Options not user modifiable
 
E4OPTION(11) = .00001       // Box-Cox trans. mimimum value
E4OPTION(12) = 1-.00001     // Tolerance for unitary eigenvalues
E4OPTION(13) = .0000000001  // DJCCL: pseudoinverse tolerance for M
E4OPTION(14) = .0001        // DJCCL: pseudoinverse tolerance for Q
E4OPTION(15) = .0000000001  // pseudoinverse general tolerance (LFMOD)
E4OPTION(16) = 100000       // LFMODINI: De Jong's k
E4OPTION(17) = .000001      // FISMOD: pseudoinverse tolerance
 
 
endfunction
