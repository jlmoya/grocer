function [r1_00,eta,x,namexos]=auto_gum(estimfull,test_func,y,z,x,namey,namexos,namecomp,prests,boundsvar,dropna,eta,m2prt_test,descent,ncomp,list_vararg)
 
// PURPOSE: in an automatic estimation, estimates the gum
// (Gerneralized Unrestricted Model)
// ------------------------------------------------------------
// INPUT:
// * estim_func = the function performing estimation
// * test-func = the function performing specification tests
// * y = vector of the endogenous variable
// * x = matrix of the exogenous variables
// * z = matrix of the compulsory variables (the ones that must
//   be in the regression whatever significance they have
// * namexos = a string vector containing the names of the
//   exoegnous variables
// * rmod = a predefined tlist result where estimation and tests
//   results will be stored
// * eta = a vector equal to the significance levels for the
//   specification tests
// * m2prt_test = the string vector collecting the names of the
//   specification tests
// * descent = the factor by which p-values of specifiaction
//   tests muts be divided to obtain the new levels used in the
//   subsequent estimations
// * varargin = any optional argument to function estim_func
// ------------------------------------------------------------
// OUPTUT:
// * r1_00 = results structure of the gum model
// * eta = the -if necessary adjusted- critical levels of
//   specification tests
// ------------------------------------------------------------
// NOTES:
// * used by automatic1()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2005
// http://grocer.toolbox.free.fr/grocer.html
 
nobs=size(y,1)
for i=1:length(varargin)
   argi=varargin(i)
   if typeof(argi) == 'string' & size(argi,'*') == 1 then
      if ~isempty(strindex(argi,'saturate')) then
         ind_leftpar=strindex(argi,'(')
         if ~isempty(ind_leftpar) then
            ind_rightpar=strindex(argi,')')
            execstr('alphasatur='+part(argi,ind_leftpar(1):ind_rightpar(1)))
         else
            alphasatur=1/nobs
         end
         [z,dummies]=indicator_saturation1(y,x,alphasatur)
         x=[x,z]
 
         if ~isempty(dummies) then
            if prests then
               [bnum,fq]=date2num_fq(boundsvar(1))
               bnum=bnum:date2num(boundsvar(2))
               for i=2:size(boundsvar,1)/2
                  bnum=[bnum , date2num(boundsvar(2*i-1)):date2num(boundsvar(2*i)) ]
               end
               datedum=num2date(bnum(dummies),fq)
               name_dummies='dum_'+datedum(:)
               namexos=[namexos ; name_dummies]
            end
         end
      end
   end
end
 
// estimate the initial model
r1_00=estimfull(y,x,z,namey,namexos,namecomp,prests,boundsvar,dropna,ncomp,list_vararg)
 
[val,p]=test_func(r1_00)
r1_00(1)($+1)='spec_test'
r1_00('spec_test')=[val p]
r1_00(1)($+1)='m_test'
r1_00('m_test')=m2prt_test
 
// if needed adjust the size of eta to the one of p
if ~isempty(eta) then
   if size(eta,'*') == 1 then
      eta=eta*ones(size(p,'*'),1)
   end
 
   for i=1:size(p,1)
 
    // must adjust the size level of the corresponding
    // specification test
      if p(i) < eta(i) then
         if p(i) < 0.8*eta(i)/descent then
         // the probability is too low to be meaningful
            eta(i)=0
         else
            eta(i)=p(i)/descent
         end
         write(%io(2),' ','(a)')
         chars='!!!!!!!!!!'
         write(%io(2),chars+chars+chars+chars+chars+chars,'(a)')
         warning('level of specification test '+ m2prt_test(i+1)+' had to be adjusted to:'+string(eta(i)))
         write(%io(2),'a) this can be the sign of a missing variable in your model','(a)')
         write(%io(2),'b) it could be worthwhile to check what happens if you run the ','(a)')
         write(%io(2),'program without the corresponding specification test','(a)')
         write(%io(2),chars+chars+chars+chars+chars+chars,'(a)')
         write(%io(2),' ','(a)')
      end
   end
end
 
endfunction
