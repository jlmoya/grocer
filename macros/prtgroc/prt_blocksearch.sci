function prt_blocksearch(res,out)
 
// PURPOSE: prints the results of automatic() along the
// options given by the user and stored in lnp
// ------------------------------------------------------------
// INPUT:
// * results = a tlist provided by automatic
// * lnp = the list of options provided by the user
// * out = the file where to print the results
// ------------------------------------------------------------
// out:
// nothing, just print the results
// ------------------------------------------------------------
// NOTES: used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
 // http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   out=%io(2)
end
 
rf=res('final model')
r_stage=res('stage A reduction results')
 
chars=' __________________________________________________ '
write(out,chars)
write(out,'| results of the block search regression package      |')
write(out,chars)
write(out,' ')
 
 
mat2print=['strategy' ': '+r_stage('strategy');
           'F presearch significance level' ': '+string(r_stage('f0_tdo')) ;
           't-test significance level' ': '+string(r_stage('alpha')) ;
           'F test significance level' ': '+string(r_stage('gam'))]
eta=r_stage('eta')
if ~isempty(eta) then
   if and(eta == eta(1)) then
      mat2print=[mat2print ; 'specification tests significance level' ': '+string(eta(1))]
   else
      write(out,'specification tests significance level:')
      nametest=r_stage('m_test')
      ntest=size(nametest,1)-1
      mat2print=[mat2print ; '  '+nametest(2:$) , ': '+string(eta) ]
   end
end
mat2print=[mat2print ; 'Information criterion' ': '+r_stage('criterion')]
printmat(mat2print,out)
write(out,' ')
 
prt_ols(rf,out)
 
   write(out,' ')
   write(out,'tests results:')
   write(out,'**************')
   m=['test value' 'p-value']
   m= [m ; string(rf('spec_test'))]
   m2prt=[rf('m_test') m]
   printmat(m2prt,out)
   write(out,' ')
   printsep(out)
 
pltuniv(rf,'all')
 
endfunction
