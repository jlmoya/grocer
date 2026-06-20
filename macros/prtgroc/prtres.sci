function []=prtres(res,out)
 
// PURPOSE: prints the results of a regression on the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// ols(), olsc(), ridge(), automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2014
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
meth=res('meth')
load(GROCERDIR+'\param\prt_foo.dat')
ind_foo=find(meth == prtuniv_foo(:,1)')
if isempty(ind_foo) then
   select meth
   case 'bkw' then
      plt_dfb(results)
      plt_dff(results)
   case 'auto' then
      prtauto(res,list(),out)
   case 'restricted var' then
      prtvarres(res,out)
   case 'johansen' then
      res1=res(1)
      if or(res1 == 'test type') then
         prtjohvec(res,res('nb of cointegration relations'),out)
         prt_johtest(res,out)
      else
         prtjohan(res,out)
      end
   case 'varma' then
      prtvarma(res,out)
   case 'brybos'
      prtbrybos(res,out)
   case 'diebmar' then
      prtdiebmar(res,out)
   case 'ms_quali' then
      prtms_quali(res,out)
   case 'pca factor' then
      prtfac_pca(res,out)
   case 'des_stat' then
      prt_des_stat(res,out)
   case 'GMM' then
      prtgmm(res,out)
   case 'olsecm' then
      prt_olsecm(res);
 
   else
      if or(meth == ['sur';'twosls';'threesls']) then
         prtsys(res,out)
      elseif or(meth == ['var';'bvar';'ecm';'becm']) then
         prtvar(res,out)
      elseif or(meth == ['archtest';'resular';'predfailin';'white']) then
         prtchi(res,out)
         prtfish(res,out)
      elseif or(meth == ['doornhans';'jbnorm';'chowtest';'reset';'predfail';'Ljung-Box';'Box-Pierce']) then
         prtchi(res,out)
      elseif or(meth == ['Chow-Lin';'Fernandez';'Litterman']) then
         prtdisag(res,out)
      elseif or(meth == ['bpagan';'hetero_sq']) then
         prtfish(res,out)
      elseif or(meth == ['varf';'varmaf']) then
         prtvarf(res,out)
      elseif or(meth == ['ms regression';'ms var';'ms mean']) then
         prtms(res,out)
      elseif or(meth == ['BNG panel ur test';'Chang IV';'Choi';'IPS';'Levin-Lin';'Maddala-Wu';'Moon Perron';'Pesaran']) then
         prt_panelur(res,out)
      elseif or(meth == ['CCEMG'; 'CCEP';'dynamic CCEMG';'jackknife dynamic CCEMG']) then
         prt_panel_cce(res,out)
      else
         error('sorry, these results are not available for printings with prtres')
      end
   end
else
   execstr(prtuniv_foo(ind_foo,2)+'(res,out)')
end
 
 
endfunction
