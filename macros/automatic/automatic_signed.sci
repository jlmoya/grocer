function [rd,rf]=automatic_signed(grocer_namey,grocer_listx,grocer_signx,varargin)
 
// PURPOSE: automatic selection of a model by least-squares
// regressions as in Hendry and Krozlig, while imposing the
// sign of selected coefficients
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * grocer_listx = a matrix of exogenous variables, under as a
// (T x k) real matrix or a (T x 1) string vector of names
// * grocer_signx = a (T x 1) vector of -1, 1 or %nan values,
// each value indicating the expected sign of the coefficients,
// -1 for negative, +1 positive and %nan for indifferent.
// * varargin = any option to automatic (see function automatic
// for details
// ------------------------------------------------------------
// OUPTUT:
// * rd = a results tlist with:
//   - rd('meth') = 'signed automatic'
//   - rd('starting automatic') = original automatic results
//     tlist
//   - rd('ending automatic') = final automatic results tlist,
//     that is with all coefficient fo the good sign
//   - rd('removed var') = a string vector, the variables that
//     have been removed
// * rf = the results tlist of the final model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011-2023
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_lprt='final'
grocer_nargin=length(varargin)
//grocer_ncomp=0

for grocer_i=grocer_nargin:-1:1
   grocer_argi=strsubst(varargin(grocer_i),' ','')
   if  part(grocer_argi,1:3) == 'prt' then
      grocer_lprt=grocer_argi
      varargin(grocer_i)=null()
   end
end
size_namex=size(grocer_listx,'*')
size_listx=size(grocer_signx,'*')
if size_namex ~= size_listx then
   error('# of exogenous variables ('+string(size_namex)+') is different from the # of given signs ('+string(size_listx)+')')
end
 
rd=tlist(['results';'meth';'starting automatic';'final automatic';'removed var'],'signed automatic')
removed_var=[]
done=%f
r=automatic(grocer_namey,grocer_listx,'prt=nothing',varargin(:))
rd('starting automatic')=r
while ~done
   done=%t
   r0=r('initial model')
   r0_namex=r0('namex')
   rf=r('final model')
   ncomp=size(r('comp'),2)
   rf_tstat=rf('tstat')(ncomp+1:$)
   rf_namex=rf('namex')(ncomp+1:$)
   for j=1:size(rf_namex,'*')
      ind_namex_j=find(grocer_listx == rf_namex(j))
      rf_tstat(j)=rf_tstat(j)*grocer_signx(ind_namex_j)
   end
   if or(rf_tstat < 0) then
      if r('ending reason') == 'stage 2 models selected by bic criterion' then
         // search the stage 2 model with the smallest # of false signs
 
         r2=r('stage 2 models')
         nmodels=length(r2)/3
         min_tstat=zeros(nmodels,1)
         n_wrongtstat=zeros(nmodels,1)
         list_wrong_tstat=list()
         names_wrong_tstat=list()
 
         for imodel=1:nmodels
            r2_i=r2(3*imodel)
            tstat=r2_i('tstat')(ncomp+1:$)
            name=r2_i('namex')(ncomp+1:$)
 
            for j=1:size(name,1)
               ind_namex_j=find(grocer_listx == name(j))
               tstat(j)=tstat(j)*grocer_signx(ind_namex_j)
            end
            ind_wrong_tstat_imod=find(tstat<0)
            n_wrongtstat(imodel)=size(ind_wrong_tstat_imod,2)
            list_wrong_tstat($+1)=tstat(ind_wrong_tstat_imod)
            names_wrong_tstat($+1)=name(ind_wrong_tstat_imod)
         end
 
         good_models=find(n_wrongtstat == 0)
         ngood_models=size(good_models,2)
 
         if ~isempty(good_models) then
            crit=zeros(ngood_models,1)
            for imodel=1:ngood_models
               r2_i=r2(3*good_models(imodel))
               execstr('crit(imodel)=r2_i('''+r('criterion')+''')')
            end
            [junk,idef]=max(crit)
            rf=r2(3*good_models(idef))
            r('final model')=rf
            r('ending reason')=r('ending reason')+' under a sign constraint'
            resl=reliability(r('final model'),r('reliability parameters'),r('alpha'),'noprint')
            r('reliab')=resl
 
         else
            vari_wrong_tstats=[]
            nmods_wrong_tstats=[]
            sum_wrong_tstats=[]
            for j=1:length(list_wrong_tstat)
               names_j=names_wrong_tstat(j)
               tstat_j=list_wrong_tstat(j)
               for k=1:size(names_j,1)
                  prev_found=find(names_j(k) == vari_wrong_tstats)
                  if isempty(prev_found) then
                     vari_wrong_tstats=[vari_wrong_tstats ; names_j(k)]
                     nmods_wrong_tstats=[nmods_wrong_tstats ;1]
                     sum_wrong_tstats=[sum_wrong_tstats ; tstat_j(k)]
                  else
                     nmods_wrong_tstats(prev_found)=nmods_wrong_tstats(prev_found)+1
                     sum_wrong_tstats(prev_found)=sum_wrong_tstats(prev_found)+tstat_j(k)
                  end
               end
            end
            val=max(nmods_wrong_tstats)
            index=find(nmods_wrong_tstats == val)
            if size(index,2) == 1 then
               remove=vari_wrong_tstats(index)
            else
               [junk,ind_mintstat]=min(sum_wrong_tstats(index))
               remove=vari_wrong_tstats(index(ind_mintstat))
            end
            removed_var=[removed_var ; remove]
            ind_listx=find(grocer_listx == remove)
            grocer_listx(ind_listx)=[]
            grocer_signx(ind_listx)=[]
            done=%f
         end
 
      else
         [junk,min_tstat]=min(rf_tstat)
         remove=find(grocer_listx == rf_namex(min_tstat))
         removed_var=[removed_var ; rf_namex(min_tstat)]
         grocer_listx(remove)=[]
         grocer_signx(remove)=[]
         done=%f
 
      end
   end
   r=automatic(grocer_namey,grocer_listx,'prt=nothing',varargin(:))
 
end
 
rd('final automatic')=r
rd('removed var')=removed_var
prtauto_signed(rd,grocer_lprt,%io(2))
 
endfunction
