function hpy = hpofilter(y,q)
 
// PURPOSE: one-sided HP filter
//  one-sided detrended versions of a series
//  using a white-noise + I(2) model
//--------------------------------------------------------
// INPUT
// * y = series to be detrended
//   . a time series, or
//   . a real (nx1) vector, or
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
// * q = relative variance of I(2) component
//    (default values are 0.675*10^(-3) or 0.75*10^(-6)
//     for quarterly or monthly data respectively)
//--------------------------------------------------------
// OUTPUT
// * hpy = the smoothed filtered series of the same type than y
// (if y is not a string) or evstr(y) (if y is a string)
//--------------------------------------------------------
// NOTE: HP quarterly uses 0.675*10^(-3)
//      for monthly data a value of q=0.75*10^(-6)
//--------------------------------------------------------
// REFERENCE:
// * A. C. Harvey & A. Jaeger (1993), "Detrending, Stylized Fact, and
//    the Business Cycle", Journal of Applied Econometrics, 8, pp. 231-247
// * M. W. Waston & J. Stock (1999), "Forecasting Inflation",
//      Journal of Monetary Economics, 44, pp. 293-335.
//--------------------------------------------------------
// Emmanuel Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0);
 
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
[s,namey,prests,boundsvarb]=explone(y);
 
 
if prests & (nargin<2) then
  q = (0.75*10^(-6)) *(y('freq')(1)== 12) + (0.675*10^(-3))*(y('freq')(1)==4);
  warning("relative variance of I(2) component is missing, it is set to "+string(q))
elseif ~prests & (nargin<2) then
  error("relative variance of I(2) component is missing")
end
 
if prests & exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) > 2 then
      error('bounds are discontinous in hpofilter')
   end
end
 
ny = size(s,1);
 
prior= 10000 ; // initialization of the trend component variance
f = [2 -1;1 0]; // state eq. coef
h =[1 0] ;	     // measure eq. coef
x =zeros(2,1) ; // initial value of the trend
qm = zeros(2,2) ; // initial condition for trend vcv
qm(1,1) = q ; // initial condition for trend vcv
p =prior*ones(2,2) + qm ; // initial condition for the error term
 
xt = zeros(ny,1);
 
for i= 1:ny
	x =f*x ;
	p =f*p*f'+ qm  ;
	yy = h*p*h' + 1 ;
	e = s(i) - h*x ;
	k = p*h'*inv(yy);
	x = x + k*e ;
	p = p - k*h*p ;
	xt(i) =h*x;
end
 
 
if prests then
   hpy=reshape(xt,boundsvarb(1))
else
   hpy=xt
end
 
 
endfunction
