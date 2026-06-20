function rwd = gmmNlWald(rgmm,R,np)
 
// PURPOSE: performs nonlinear Wald test for GMM
// ------------------------------------------------------------
// INPUTS:
// . rgmm = tlist result for unrestricted estimation
// . R = (s x 1) vector  of linear or nonlinear restriction
//      of the form R(p)=0, example  R=['p1-1/p2';'p5-p3*p4'];
// . np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUTPUTS: rwd a tlist with
// . rd('chistat') = test statisitc
// . rd('pvalue') = pvalue of the test
// . rd('df') = number restriction
// ------------------------------------------------------------
// REFERENCE:
//  W.K. Newey & K. D. West (1987), "Hypothesis Testing With
//    Efficient Method of Moments Estimation",
//    International Economic Review, 28(3), 777-787
// ------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0);
if nargin < 3 then
   prt=%t;
else
   if np == 'noprint' then
      prt=%f;
   else
      error('argument 3 in aragan should be ''noprint''');
   end
end
 
if nargin < 2 then
  error('Restrictions are missing');
end
 
// test optimality of the weighting matrix
Wtype = rgmm('W type');
Wopti = ['I','Z','S','C'];
 
if ~or(Wtype == Wopti) then
  error('Weighting matrix is not optimal in unrestricted estimation');
end
 
 
nb = rgmm('nvar')
[nr,junk] =size(R);
if junk > nr then
  R=R'
  n=junk
end
for i=1:nr
  [kp,wp]=strindex(R,'p');
  if kp == [] then
    error('in constraint '+string(i)+' specification');
  end
end
 
// evaluate the restriction
bet = rgmm('beta');
fr = gmmRdef(bet,R);
s = size(fr,2);
// compute the numerical derivative
dfr = numz0(gmmRdef,bet,nb,zeros(nb,s),sqrt(%eps),R);
dfr = dfr';
 
V = rgmm('vcovar');
Sigma = dfr*V*dfr'
Wld = fr'*inv(Sigma)*fr
pval = 1 - cdfchi("PQ",Wld,s);
 
rwd = tlist(['results';'method';'chistat';'pvalue';'df'],'nl Wald test',Wld,pval,s);
 
if prt then
  out=%io(2)
  write(out,'GMM nonlinear Wald test of model restriction');
  write(out,'chi2('+string(s)+')='+string(Wld));
  write(out,'(p-value            = '+string(pval)+')');
  write(out,' ');
end
 
endfunction
 
 
 
 
 
 
