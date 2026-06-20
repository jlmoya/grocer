function rwd = gmmWald(rgmm,R,r,np)
 
// PURPOSE: performs linear Wald test for GMM
// ------------------------------------------------------------
// INPUTS:
// . rgmm = tlist result for unrestricted estimation
// . R = is the (s x #parameters) R matrix of linear constraints in Rb = r
// . r = (s x 1) r vector in Rb = r
// . np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUTPUTS: rwd a tlist with
// . rd('chistat') = test statisitc
// . rwd('pvalue') = pvalue of the test
// . rwd('df') = number restriction
// ------------------------------------------------------------
// REFERENCE:
//  W.K. Newey & K. D. West (1987), "Hypothesis Testing With
//    Efficient Method of Moments Estimation",
//    International Economic Review, 28(3), 777-787
// ------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0);
if nargin < 4 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f;
   else
      error('argument 3 in aragan should be ''noprint''');
   end
end
 
if nargin == 2 then
  error('elements of Rb = r are missing');
end
 
// test optimality of the weighting matrix
Wtype = rgmm('W type');
Wopti = ['I','Z','S','C'];
 
if ~or(Wtype == Wopti) then
  error('Weighting matrix is not optimal in unrestricted estimation');
end
 
// test if constraints are well defined
[nrow_R,ncol_R]=size(R);
[nrow_r,ncol_r]=size(r);
nvar = rgmm('nvar');
 
if nrow_R ~= nrow_r then
   error('R and r must have the same # of rows in a constrained estiamtion');
end
 
if ncol_R ~= nvar then
   error('R and X must have the same # of cols in a constrained estiamtion');
end
 
// evaluate the restriction
bet = rgmm('beta');
V = rgmm('vcovar');
Wld = (R*bet - r)'*inv(R*V*R')*(R*bet - r);
pval = 1 - cdfchi("PQ",Wld,nrow_R);
 
rwd = tlist(['results';'method';'chistat';'pvalue';'df'],'Wald test',Wld,pval,nrow_R);
 
if prt then
  out=%io(2)
  write(out,'GMM Wald test of model restriction');
  write(out,'chi2('+string(nrow_R)+')='+string(Wld));
  write(out,'(p-value            = '+string(pval)+')');
  write(out,' ');
end
 
endfunction
 
 
 
 
 
 
