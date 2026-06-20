function res = deming1(y,x,lambda,alpha)
 
 
// PURPOSE: performs a linear Deming regression to find the linear
// coefficients:
//                     y = b(1) + b(2)*x
// under the assumptions that x and y *both* contain measurement
// error with measurement error variance related as
// lambda = sigma2_y/sigma2_x
// (sigma2_x and sigma2_y is the measurement error variance of the x and y
// variables, respectively).
// ------------------------------------------------------------
// INPUT:
// * y = (N x 1) vector of the endogenous variable measured
//       with error
//  * x= (N x 1) vector of the endogenous variable measured
//       with error
//  * lambda  = a scalar, the assumed ratio of the measurement
//             errors of y and x:   sigma2_y / sigma2_x
//  * alpha = a scalar, the confidence level
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with
// - res('meth')  = 'deming'
// - res('y')  = the y vector of endogenous variables
// - res('x')  = the x vector of exogenous variables
// - res('errors variance ratio')  = the assumed ratio of the
//   measurement errors of y and x
// - res('Estimated x values')  = the estimated "true" x values
// - res('Estimated y values')  = the estimated "true" y values
// - res('regression st. error')  = Standard error of regression
//   estimate
// - res('coeff st. error')  = estimate of standard error of the
//   slope and intercept
// - res('tstat') = Sutnedt's T of the estimated coefficients
// - res(string(100*alpha)+'% confidence interval') = the
//   confidence interval of the coefficients at the chosen level
// ------------------------------------------------------------
// REFERENCE: Anders Christian Jenson in a
// May 2007 description of the Deming regression function for MethComp
// (web: http://staff.pubhealth.ku.dk/~bxc/MethComp/Deming.pdf)
// ------------------------------------------------------------
// Copyright Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
// translated and signifcantly adpated from a matlab program by:
// James S. Hall
// (Hidden Solutions, LLC - www.hiddensolutionsllc.com)
// with the following disclaimer:
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name Hidden Solutions, LLC nor the names of any
//      contributors may be used to endorse or promote products deresed from
//      this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS """"AS IS"""" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL HIDDEN SOLUTIONS, LLC BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 
p=1-alpha
n = size(y,1);// Number of elements
m_x = sum(x)/n;// Mean value of x
m_y =  sum(y)/n;// Mean value of y
c_xy = cov(x,y);// Covariance matrix of x and y
s_xx = c_xy(1,1);// Variance of x
s_xy = c_xy(1,2);// Covarince of x and y
s_yy = c_xy(2,2);// Variance of y
 
// Assign slope an intercept (in closed-form)
b = zeros(2,1);
 
b(2) = (s_yy - lambda*s_xx + sqrt((s_yy - lambda*s_xx).^2 + 4*lambda*s_xy^2)) /(2*s_xy);
b(1) = m_y - b(2)*m_x;
 
// Assign x/y estimated values
x_est=x+b(2)./(b(2)^2 + lambda)*(y -b(1) - b(2)*x);
y_est = b(1) + b(2)*x_est;
 
  // Determine sigma2
sigma2_x = sum(lambda*(x-x_est).^2 + (y - b(1) - b(2)*x_est).^2)/(2*lambda*(n-2));
 
// Compute standard error of the linear regression
s_e = sqrt((1 + lambda)*sigma2_x);
 
// Perform deming regression with one less sample for jacknife analysis
b_sub = zeros(2,n);
for i = 1:n
   x_sub=x([1:i-1 , i+1:n])
   y_sub=x([1:i-1 , i+1:n])
   m_x_sub = sum(x_sub)/(n-1);// Mean value of x
   m_y_sub =  sum(y_sub)/(n-1);// Mean value of y
   c_xy_sub = cov(x_sub,y_sub);// Covariance matrix of x and y
   s_xx_sub = c_xy(1,1);// Variance of x
   s_xy_sub = c_xy_sub(1,2);// Covarince of x and y
   s_yy_sub = c_xy_sub(2,2);// Variance of y
   b_sub(2) = (s_yy_sub - lambda*s_xx_sub + sqrt((s_yy_sub - lambda*s_xx_sub).^2 + 4*lambda*s_xy_sub^2)) /(2*s_xy_sub);
   b_sub(1) = m_y_sub - b(2)*m_x_sub;
 
 
end;
 
s_b = stdev(b_sub,'c')*(n-1)/sqrt(n);
t_c = cdft("T",n-2,1-p/2,p/2)
b_ci = b*[1,1]+(t_c*s_b)*[-1,1];
 
res=tlist(['results';'meth';'y';'x';'errors variance ratio';'bhat';'x variance';'Estimated x values';...
'Estimated y values';'regression st. error';'coeff st. error';'tstat';string(100*alpha)+'% confidence interval'],...
'deming',y,x,lambda,b,sigma2_x,x_est,y_est,s_e,s_b,b ./ s_b,b_ci)
 
endfunction
