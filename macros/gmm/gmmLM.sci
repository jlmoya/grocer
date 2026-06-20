function rlm = gmmLM(ugmm,rgmm,R,nr,np)
 
// PURPOSE: performs LM test for efficient GMM
// ------------------------------------------------------------
// INPUTS:
// . ugmm = tlist result for unrestricted estimation
// . rgmm = tlist result for restricted estimation
// . R = (#parameters x 1) vector indicating if some parameters have been
//      sat to zero (ex: R=[1,0,0,1]) to recover ugmm('beta') dimension
//      from rgmm('beta')
// . nr = number of restrictions
// . np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUPUTS: rlm a tlist with:
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
if nargin < 5 then
   prt=%t;
else
   if np == 'noprint' then
      prt=%f;
   else
      error('argument 3 in aragan should be ''noprint''');
   end
end
 
if nargin ==3 then
  error('Number of parameter restrictions is missing');
end
 
if nargin == 2 then
  error('R matrix is missing');
end
 
// test optimality of the weighting matrix
uWtype = ugmm('W type');
rWtype = rgmm('W type');
Wopti = ['I','Z','S','C'];
 
if ~or(uWtype == Wopti) then
  error('Weighting matrtix is not optimal in unrestricted estimation');
elseif ~or(rWtype == Wopti) then
  error('Weighting matrtix is not optimal in restricted estimation');
end
 
if uWtype~=rWtype then
  error('Weighting matrtix are not identical in unrestricted and restricted estimation');
end
 
[junk,f0] = find(R~=0);
nub = ugmm('nvar');
betr=zeros(nub,1);
if f0~=[] then
	betr(f0) = rgmm('beta');
else
	betr = rgmm('beta');
end
 
// test satisitics
momt = rgmm('momt');
jake = rgmm('jake');
Wr =rgmm('W');
y = ugmm('y');
X = ugmm('x');
Z = ugmm('z');
execstr('m='+momt+'(betr,rgmm,y,X,Z)');   // Reeval moment conditions
execstr('M='+jake+'(betr,rgmm,y,X,Z)');   // Reeval Jacobian
LM = rgmm('nobs')^2*(M'*Wr*m)'*inv(M'*Wr*M)*(M'*Wr*m);
pval = 1 - cdfchi("PQ",LM,nr);
rlm = tlist(['results';'method';'chistat';'pvalue';'df'],'LM test',LM,pval,nr);
 
if prt then
  out=%io(2)
  write(out,'Efficient GMM LM test of model restriction');
  write(out,'chi2('+string(nr)+')='+string(LM));
  write(out,'(p-value            = '+string(pval)+')');
  write(out,' ')
end
 
endfunction
 
 
 
 
 
 
