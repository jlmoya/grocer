function res=deming(grocer_namey,grocer_namex,varargin)
 
// PURPOSE: performs a linear Deming regression to find the
// linear coefficients:
//                     y = b(1) + b(2)*x
// under the assumptions that x and y *both* contain measurement
// error with measurement error variance related as
// lambda = sigma2_y/sigma2_x
// (sigma2_x and sigma2_y is the measurement error variance of
// the x and y variables, respectively).
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (n x 1) vector or a
// string equal to the name of a time series or a (n x 1) real
// vector between quotes
// * grocer_namex = a time series, a real (n x 1) vector or a
// string equal to the name of a time series or a (n x 1) real
// vector between quotes
// * varargin = arguments which can be:
//   . the string 'lambda=xx' where xx is the assumed ratio of
//     the error variance of t to x (default: 1)
//   . the string 'alpha=xx' where xx is the level of the
//     confidence interval
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . 'dropna' if the user wants to remove the NA values
//     from the data
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
// REFERENCE: Anders Christian Jenson in a
// May 2007 description of the Deming regression function for MethComp
// (web: http://staff.pubhealth.ku.dk/~bxc/MethComp/Deming.pdf)
// ------------------------------------------------------------
// Copyright Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
// uses the function deming1 adpated from a matlab program by:
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
 
// Set defaults
grocer_lambda = 1;
grocer_alpha = 0.95;
 
grocer_prt=%t
grocer_dropna =%f
grocer_nargin=length(varargin)
 
for grocer_i=1:grocer_nargin
 
   grocer_st=varargin(grocer_i)
 
   if typeof(grocer_st) == 'string' then
      if part(grocer_st,1:7) == 'lambda=' then
         execstr('grocer_'+grocer_st)
         if max(size(grocer_lambda)) ~= 1 then
            error("lambda must be a scalar value");
         end;
 
      elseif part(grocer_st,1:7) == 'alpha=' then
         execstr('grocer_'+grocer_st)
 
      elseif grocer_st == 'noprint' then
         grocer_prt=%f
 
      elseif grocer_st == 'dropna' then
         grocer_dropna=%t
      end
   end
end
 
[y,namey,x,namexos,prests,boundsvarb,nonna]=...
explouniv(grocer_namey,grocer_namex,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
res=deming1(y,x,grocer_lambda,grocer_alpha)
res(1)($+1) = 'prests'
res(1)($+1) = 'namey'
res(1)($+1) = 'namex'
res(1)($+1) = 'dropna'
res('prests')=prests
res('namey')=namey
res('namex')=namexos
res('dropna') =grocer_dropna
 
if prests then
   res(1)($+1) = 'bounds'
   res('bounds')=boundsvarb
end
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
if grocer_prt then
   prt_deming(res,%io(2))
end
 
endfunction
