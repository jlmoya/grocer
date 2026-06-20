function uninstall_grocer()
 
global GROCERDIR ;
 
version=getversion("scilab")(1)
if version >= 5 then
   help_dir='\help_grocer'
else
   help_dir='\man\groc_man'
end
 
write(%io(2),'warning: you are beginning the uninstallation of grocer;')
write(%io(2),'this operation will remove the content of the directory ')
write(%io(2),GROCERDIR+' except for file grocer_uninstalled.dat and loader.sce')
 
verif=x_dialog('do you really want to uninstall grocer?','click on Ok if yes; on Cancel if not')
 
if verif == 'click on Ok if yes; on Cancel if not' then
   if version >= 5.2 then
      del_help_chapter('GROCER')
      help_dir='/help'
 
   elseif version >= 5 then
      del_help_chapter('Grocer manipulation of time series');
      del_help_chapter('Grocer matrices of time series');
      del_help_chapter('GROCER basic functions');
      del_help_chapter('Grocer General Functions fore stimation');
      del_help_chapter('Grocer optimisation');
      del_help_chapter('Grocer Single equation regressions');
      del_help_chapter('Grocer Qualitative Econometrics Functions');
      del_help_chapter('Grocer econometric tests and diagnostics');
      del_help_chapter('Grocer Unit roots and cointegration');
      del_help_chapter('Grocer Johansen cointegration method');
      del_help_chapter('Grocer Panel Unit roots');
      del_help_chapter('Grocer multivariate regressions');
      del_help_chapter('Grocer VAR estimations');
      del_help_chapter('Grocer ARMA and VARMA tools');
      del_help_chapter('Grocer GARCH models');
      del_help_chapter('Grocer Panel equation regressions');
      del_help_chapter('Grocer Kalman filter estimation');
      del_help_chapter('Grocer Automatic estimation');
      del_help_chapter('Grocer Supplementary distibution functions');
      del_help_chapter('Grocer Business cycle tools');
      del_help_chapter('Grocer Contributions');
      del_help_chapter('Grocer time series disaggregation');
      del_help_chapter('Grocer Markov-switching models');
      del_help_chapter('Grocer Bayesian Model Averaging');
      del_help_chapter('Grocer Generalized Method of Moments');
      del_help_chapter('Grocer Factor Analysis');
      del_help_chapter('Gauss to Scilab translation');
      del_help_chapter('GROCER printings and graphs');
      help_dir='/help_grocer'
 
   else
      help_dir='/man'
   end
 
   rmdir(GROCERDIR+help_dir,'s')
   rmdir(GROCERDIR+'\macros','s')
   rmdir(GROCERDIR+'\data','s')
   rmdir(GROCERDIR+'\param','s')
   rmdir(GROCERDIR+'\jar','s')
   rmdir(GROCERDIR+'\etc','s')
 
   if getos() == "Windows" then
      rmdir(strsubst(GROCERDIR+help_dir,'/','\'),'s')
   else
      rmdir(GROCERDIR+help_dir,'s')
   end
 
   mdelete(GROCERDIR+'\readme_grocer.pdf')
   mdelete(GROCERDIR+'\grocer_license.txt')
   mdelete(GROCERDIR+'\builder.sce')
   mdelete(GROCERDIR+'\genlib_grocer.sci')
   mdelete(GROCERDIR+'\xmltojar_g.sci')
   mdelete(GROCERDIR+'\loader.sce')
   grocer_uninstalled=%t
   vers=getversion("scilab")(1)
   if vers >= 5.4 then
      save(GROCERDIR+'/grocer_uninstalled.dat','grocer_uninstalled')
   else
      save(GROCERDIR+'/grocer_uninstalled.dat',grocer_uninstalled)
   end
   write(%io(2),' ')
   write(%io(2),'grocer now unsintalled')
 
else
   write(%io(2),'grocer has not been unsintalled')
end
 
endfunction
 
 
