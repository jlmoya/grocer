function []=prt_panelur(res,out)
 
// PURPOSE: prints the results of a panel unit root test
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
meth=res('meth')
namey=res('namey')
write(out,' ')
write(out,meth+' estimation results for variables:')
write(out,' ')
write(out,joinstr(namey,' - '))
write(out,' ')
 
if res('prests') then
   ch='estimation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+' '
   end
   if res('dropna') then
      ch=ch+'(balanced panel)'
   else
      ch=ch+'(unbalanced panel)'
   end
   write(out,ch)
   write(out,' ')
end
 
select meth
 
case 'Levin-Lin' then
   mat2prt=['statistic' 'pvalue'; string(res('tstat')) string(res('pvalue'))]
 
case 'IPS' then
   mat2prt=[' ' 'statistic' 'pvalue'; 'Zbar' string(res('Zbar')) ...
   string(res('Zbar_pvalue')); 'Wbar' string(res('Wbar')) ...
   string(res('Wbar_pvalue'))]
 
case 'Maddala-Wu' then
   mat2prt=[' ' 'statistic' 'pvalue'; 'Maddala-Wu ' string(res('P')) ...
   string(res('P_pvalue')) ; 'Choi' string(res('Z')) string(res('Z_pvalue'))]
 
case 'Moon Perron' then
   write(out,'number of factors: '+string(res('nbfactors')))
   write(out,'pooled rho: '+string(res('rho_pool')))
   write(out,' ')
   mat2prt=[' ' 'statistic' 'p-value'; 'ta_star' string(res('ta_star')) ...
   string(res('ta_pvalue')) ;'tb_star' string(res('tb_star')) string(res('tb_pvalue'))]
 
case 'Choi' then
   mat2prt=[' ' 'statistic' 'p-value'; 'P_m' string([res('Pm') res('Pm_pvalue')]);...
          'Z' string([res('Z') res('Z_pvalue')]) ;...
          'L_star' string([res('Lstar') res('Lstar_pvalue')])]
 
case 'Pesaran' then
   mat2prt=[' ' 'statistic' 'p-value'; 'CIPS' string([res('CIPS') res('CIPS_pvalue')]);...
          'CIPS_star' string([res('CIPS_star') res('CIPS_star_pvalue')]) ]
 
case 'Chang IV' then
   write(out,'individual Unit Root tests')
   write(out,'**************************')
   mat2prt=[' ' 'ADF' 'IV ADF' ; res('namey') string([res('ADF_tstat') res('Zi')])]
   printmat(mat2prt,out)
   write(out,' ')
 
   write(out,'Combined Unit Root tests')
   write(out,'**************************')
 
   mat2prt=['statistic' 'p-value'; string([res('tstat') res('pvalue')])]
 
case 'BNG panel ur test' then
   write(out,'individual Unit Root tests')
   write(out,'**************************')
   mat2prt=[' ' 'idiosyncratic ADF' 'ratio of idiosyn. var.'; res('namey') ...
   string([res('ADFe') res('ratio1')])]
   printmat(mat2prt,out)
   write(out,' ')
 
   write(out,'Combined Unit Root tests')
   write(out,'**************************')
   write(out,' ')
   write(out,'# of estimated factors: '+string(res('nbfactors')))
   write(out,'criterion: '+string(res('criteria')))
   write(out,' ')
 
   if res('nbfactors') == 1 then
      mat2prt=[' ' 'statistic' 'p-value'; 'pooled idiosyncratic Choi test' string([res('PCe_Choi') res('PCe_Choi_pvalue')]) ; ...
               'pooled idiosyncratic Z test' string([res('PCe_MW') res('PCe_MW_pvalue')]) ;...
               'ADF common factor' string([res('ADF_F') res('ADF_F_pvalue')])]
   else
      mat2prt=[' ' 'statistic' 'p-value'; 'pooled idiosyncratic Choi test' string([res('PCe_Choi') res('PCe_Choi_pvalue')]) ; ...
               'pooled idiosyncratic Z test' string([res('PCe_MW') res('PCe_MW_pvalue')]) ; ...
                '# of stochastic trends at 5% - MQc test' , string(res('MQc_r1')) , ' ' ;....
                '# of stochastic trends at 5% - MQf test' , string(res('MQf_r1')) , ' ']
 
   end
 
 
end
 
printmat(mat2prt,out)
printsep(out)
 
endfunction
