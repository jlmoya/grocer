function [txt_eq,analysed_eq,indendo_eq,ind_signs_eq,lags_info_eq,listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namexo,namex4regression,linear,lags_endos,lags_exos,lags_resids,maxlag,namendo,namresid,namecoeff,nameparam,eqi]=model_transfeq1(indeqi,eqi,nameqi,listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,namresid,namecoeff,nameparam,lags_endos,lags_exos,lags_resids,maxlag,grocer_verbose)
 
// PURPOSE: from an equation, build various objects needed for
// estimation, simulation etc.
// ------------------------------------------------------------
// INPUT:
// * indeqi = the index of the equation
// * eqi = the text of the equation
// * nameqi = the name of the equation
// * liseqperendo = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   endogenous appears
// * liseqperendo_wolgas = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   endogenous appears contemporaneously
// * liseqperexo = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   exogenous appears
// * liseqpercoeff = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   residual appears
// * namendo = the name of the model endogneous
// * namexo = the name of the model exogneous
// * namresid = the name of the model residuals
// * namecoeff = the name of the model coefficients
// ------------------------------------------------------------
// OUTPUT:
// * txt_eq = a string vector, collecting pieces of a text, with
//   the 'groder_date-k' that will be used in simulations
// * analysed_eq = a list, each element of the list representing
//   an additive element of the equation (that is, the text is
//   built from the elements of the list by teh addition or the
//   subtraction of them), that is:
//   - either a string, the name of an object of the model
//     (variable, constant, parameter,...)
//   - or a list of 2 elements, the tlist result from the
//     syntactic analysis (by analyse_eq1) and the names of the
//     variables (exogenousn endogenous and residuals) found in
//     the corresponding part of the text
// * indendo_eq = a (n x 2) real matrix, collecting on the first
//   column the indexes of the endogenous variables found in the
//   equation and on the second column the index of the piece of
//   the equation it belongs to
// * ind_signs_eq =
// * lags_info_eq =
// * coeffs_eq =
// * listeqperendo =
// * listeqperendo_wolags =
// * listeqperexo =
// * listeqperresid =
// * listeqpercoeff =
// * namexo =
// * namex4regression =
// * linear =
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2018
// http://grocer.toolbox.free.fr/grocer.html
 
if grocer_verbose then
   write(%io(2),eqi,'(a)')
end
 
eqi=strsubst(eqi,' ','')
 
newcoeff=model_defaultvar(eqi,'''c')
if ~isempty(newcoeff) then
   for i=size(newcoeff,'*'):-1:1
      if or(namecoeff == newcoeff(i)) then
         newcoeff(i)=[]
      end
   end
   if ~isempty(newcoeff) then
      [namecoeff2,indold,indnew]=union(namecoeff,newcoeff)
      namecoeff=[namecoeff ; newcoeff(gsort(indnew,'g','i'))]
      n_newcoeff=size(indnew,1)
      listeqpercoeff=[listeqpercoeff ; spzeros(n_newcoeff,grocer_neq)]
   end
   eqi=strsubst(eqi,'''c','')
end
 
newparam=model_defaultvar(eqi,'''p')
if ~isempty(newparam) then
   for i=size(newparam,'*'):-1:1
      if or(nameparam == newparam(i)) then
         newparam(i)=[]
      end
   end
   [nameparam2,indold,indnew]=union(nameparam,newparam)
   nameparam=[nameparam ; newparam(gsort(indnew,'g','i'))]
   n_newparam=size(indnew,'*')
   listeqperparam=[listeqperparam ; spzeros(n_newparam,grocer_neq)]
   eqi=strsubst(eqi,'''p','')
end
 
newendo=model_defaultvar(eqi,'''y')
if ~isempty(newendo) then
   for i=size(newendo,'*'):-1:1
      if or(namendo == newendo(i)) then
         newendo(i)=[]
      end
   end
   if ~isempty(newendo) then
      [namendo2,indold,indnew]=union(namendo,newendo)
      namendo=[namendo ; newendo(gsort(indnew,'g','i'))]
      n_newendo=size(indnew,'*')
      listeqperendo=[listeqperendo ; spzeros(n_newendo,grocer_neq)]
      for i=1:n_newendo
         lags_endos($+1)=[]
      end
   end
   eqi=strsubst(eqi,'''y','')
end
 
newexo=model_defaultvar(eqi,'''x')
if ~isempty(newexo) then
   for i=size(newexo,'*'):-1:1
      if or(namexo == newexo(i)) then
         newexo(i)=[]
      end
   end
   if ~isempty(newexo) then
      [namexo2,indold,indnew]=union(namexo,newexo)
      namexo=[namexo ; newexo(gsort(indnew,'g','i'))]
      n_newendo=size(indnew,'*')
      listeqperexo=[listeqperexo ; spzeros(n_newexo,grocer_neq)]
      for i=1:n_newexo
         lags_exos($+1)=[]
      end
   end
   eqi=strsubst(eqi,'''x','')
end
 
newresid=model_defaultvar(eqi,'''r')
if ~isempty(newresid) then
   for i=size(newresid,'*'):-1:1
      if or(namresid == newresid(i)) then
         newresid(i)=[]
      end
   end
   if ~isempty(newresid) then
      [nameresid2,indold,indnew]=union(namresid,newresid)
      namresid=[namresid ; newendo(gsort(indnew,'g','i'))]
      n_newresid=size(indnew,'*')
      listeqperresid=[listeqperresid ; spzeros(n_newresid,grocer_neq)]
      for i=1:n_newresid
         lags_resids($+1)=[]
      end
   end
   eqi=strsubst(eqi,'''r','')
end
 
indeq=strindex(eqi,'=')
lhsi=stripblanks(part(eqi,1:indeq-1))
rhsi=stripblanks(part(eqi,indeq+1:length(eqi)))
 
// replace the delts and lagts expressions in order to be able to derivate the
// equations
[lhsi_wolags0,lhsi_lags,listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
namexo,lhs_lags4coeff,deriv_lags_names,deriv_lags_expr,lags_endos,lags_exos,lags_resids,maxlag]=...
replace_delts_n_lagts(lhsi,nameqi,indeqi,listeqperendo,listeqperendo_wolags,listeqperexo,...
listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,namresid,namecoeff,nameparam,...
0,list(),list(),lags_endos,lags_exos,lags_resids,maxlag)
 
ind_lags=definedfields(deriv_lags_names)
if ~isempty(ind_lags) then
   for i=ind_lags
      deriv_lags_expr(i)='-('+deriv_lags_expr(i)+')'
   end
end
 
[rhsi_wolags0,rhsi_lags,listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
namexo,rhs_lags4coeff,deriv_lags_names,deriv_lags_expr,lags_endos,lags_exos,lags_resids,maxlag]=...
replace_delts_n_lagts(rhsi,nameqi,indeqi,listeqperendo,listeqperendo_wolags,listeqperexo,...
listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,namresid,namecoeff,nameparam,...
size(lhsi_lags,1),deriv_lags_names,deriv_lags_expr,lags_endos,lags_exos,lags_resids,maxlag)
 
// explode the lhs into smaller pieces
[txt_lhs4coeff,txt_lhs,analysed_eq_lhs,indendo_eq_lhs,coeffs_eq_lhs,ind_coeffs_eq_lhs,indsigns_lhs,...
listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
namexo,list_lags_lhs,lags_endos,lags_exos,lags_resids]=...
explode_eqside(lhsi_wolags0,indeqi,nameqi,listeqperendo,listeqperendo_wolags,listeqperexo,...
listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,namresid,namecoeff,nameparam,...
lhsi_lags,lags_endos,lags_exos,lags_resids)
 
// explode the rhs into smaller pieces
[txt_rhs4coeff,txt_rhs,analysed_eq_rhs,indendo_eq_rhs,coeffs_eq_rhs,ind_coeffs_eq_rhs,indsigns_rhs,...
listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
namexo,list_lags_rhs,lags_endos,lags_exos,lags_resids]=...
explode_eqside(rhsi_wolags0,indeqi,nameqi,listeqperendo,listeqperendo_wolags,listeqperexo,...
listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,namresid,namecoeff,nameparam,...
rhsi_lags,lags_endos,lags_exos,lags_resids)
// stick together lhs and rhs pieces
 
lags_info_eq=[lhsi_lags ;rhsi_lags]
txt_eq4coeff=[txt_lhs4coeff ; txt_rhs4coeff]
lags4coeff=[lhs_lags4coeff ; rhs_lags4coeff]
txt_eq=[txt_lhs ; txt_rhs]
analysed_eq=lstcat(analysed_eq_lhs,analysed_eq_rhs)
 
lags_with_coeffs=definedfields(deriv_lags_names)
list_lags=[list_lags_lhs ; list_lags_rhs]
for i=size(list_lags,1):-1:1
    if and(lags_with_coeffs ~= list_lags(i)) then
       // lag without coeff
       list_lags(i)=[]
    end
end
 
if ~isempty(indendo_eq_rhs) then
   indendo_eq_rhs(:,2)=indendo_eq_rhs(:,2)+size(txt_lhs,1)
end
indendo_eq=[indendo_eq_lhs ; indendo_eq_rhs]
ind_signs_eq=[-indsigns_lhs(2,1:$-1) , indsigns_rhs(2,1:$-1)]
 
if ~isempty(coeffs_eq_rhs) then
   ind_coeffs_eq_rhs=ind_coeffs_eq_rhs+size(txt_lhs,1)
end
coeffs_eq=[coeffs_eq_lhs ; coeffs_eq_rhs ]
 
ind_coeffs_eq=[ind_coeffs_eq_lhs ; ind_coeffs_eq_rhs ]
// now recover the explicative variables associated to the coefficients of the regression,
// if any
linear=%t
namex4regression=[]
 
coeffs_eq_unique=[]
if ~isempty(coeffs_eq) then
   ncoeffs=size(coeffs_eq,1)
   ana_eq1=analysed_eq(ind_coeffs_eq(1))(1)
   coeff1=coeffs_eq(1)
   ind_coeff1=ind_coeffs_eq(1)
   indsign_eq1=string(ind_signs_eq(ind_coeff1))
   indsign_eq1=strsubst(indsign_eq1,'-1','-')
   indsign_eq1=strsubst(indsign_eq1,'1','+')
   txt_member=txt_eq4coeff(ind_coeff1)
 
   if typeof(ana_eq1) == 'string' then
      namex4regression=strsubst(indsign_eq1,'+','')+'grocer_one'
   else
      // find the derivate of the equation with respect to
      // the coefficient
      start_eq_1=part(txt_member,1:length(coeff1)+1)
      if start_eq_1 == coeff1+'*' & size(strindex(txt_member,coeff1),2) == 1 then
         deriv_coeff=part(txt_member,length(coeff1)+2:length(txt_member))
      elseif start_eq_1 == coeff1+'/' & size(strindex(txt_member,coeff1),2) == 1 then
         deriv_coeff='1/'+part(txt_member,length(coeff1)+2:length(txt_member))
      else
         deriv_coeff=deriv_eq(ana_eq1,coeff1)
      end
 
      if indsign_eq1 == '+' then
         namex4regression=deriv_coeff
      else
         namex4regression='-('+deriv_coeff+')'
      end
   end
 
   coeffs_eq_unique=coeffs_eq(1)
   for j=2:size(coeffs_eq,1)
      ind_coeffj=ind_coeffs_eq(j)
      txt_member=txt_eq4coeff(ind_coeffj)
      ana_eqj=analysed_eq(ind_coeffj)(1)
      coeffj=coeffs_eq(j)
      indsign_eqj=string(ind_signs_eq(ind_coeffj))
      indsign_eqj=strsubst(indsign_eqj,'-1','-')
      indsign_eqj=strsubst(indsign_eqj,'1','+')
 
      if typeof(ana_eqj) == 'string' then
         deriv_coeff='grocer_one'
 
      else
         start_eq_j=part(txt_member,1:length(coeffj)+1)
         if start_eq_j == coeffj+'*' & size(strindex(txt_member,coeffj),2) == 1 then
            deriv_coeff=part(txt_member,length(coeffj)+2:length(txt_member))
         elseif start_eq_j == coeffj+'/' & size(strindex(txt_member,coeffj),2) == 1 then
            deriv_coeff='1/'+part(txt_member,length(coeffj)+2:length(txt_member))
         else
            deriv_coeff1=deriv_eq1(ana_eqj,coeffs_eq(j))
            reseq_ds=simplify_eq(deriv_coeff1)
            // transform the tlist into the text of the equation
            deriv_coeff=rebuild_eq(reseq_ds)
 
         end
 
      end
 
      ind_oldcoeff=find(coeffs_eq_unique == coeffj)
 
      if ~isempty(ind_oldcoeff) then
         if indsign_eqj == '+' then
            namex4regression(ind_oldcoeff(1))=namex4regression(ind_oldcoeff(1))+'+'+deriv_coeff
         elseif deriv_coeff == 'grocer_one' then
            namex4regression(ind_oldcoeff(1))=namex4regression(ind_oldcoeff(1))+'-'+deriv_coeff
         else
            namex4regression(ind_oldcoeff(1))=namex4regression(ind_oldcoeff(1))+'-('+deriv_coeff+')'
         end
 
      elseif indsign_eqj == '+' then
         coeffs_eq_unique=[coeffs_eq_unique ; coeffj]
         namex4regression=[namex4regression ; deriv_coeff ]
 
      elseif deriv_coeff == 'grocer_one' then
         coeffs_eq_unique=[coeffs_eq_unique ; coeffj]
         namex4regression=[namex4regression ; '-'+deriv_coeff ]
 
      else
         coeffs_eq_unique=[coeffs_eq_unique ; coeffj]
         namex4regression=[namex4regression ; '-('+deriv_coeff+')']
      end
   end
 
   for k=1:size(lags4coeff,1)
      namex4regression=strsubst(namex4regression,'grocer_lag'+string(k)+'_',lags4coeff(k))
   end
 
end
 
for i=list_lags
   deriv_lags_namei=deriv_lags_names(i)
   deriv_lags_expri=deriv_lags_expr(i)
   for k=1:length(analysed_eq)
      if length(analysed_eq(k)) == 2 then
         if or(analysed_eq(k)(2) == 'grocer_lag'+string(i)+'_') then
            deriv_lag=deriv_eq(analysed_eq(k)(1),'grocer_lag'+string(i)+'_')
            for j=1:size(deriv_lags_namei,1)
                coeffj=deriv_lags_namei(j)
                deriv_coeff='('+deriv_lag+')*('+deriv_lags_expri(j)+')'
                ind_oldcoeff=find(coeffs_eq_unique == coeffj)
                if isempty(ind_oldcoeff) then
                   coeffs_eq_unique=[coeffs_eq_unique ; coeffj]
                   namex4regression=[namex4regression ; deriv_coeff ]
                else
                   namex4regression(ind_oldcoeff(1))=namex4regression(ind_oldcoeff(1))+'+'+deriv_coeff
                end
             end
          end
      end
   end
end
 
if ~isempty(coeffs_eq_unique) then
   linear=%t
   for j=1:size(namex4regression,1)
      for k=1:size(coeffs_eq_unique,'*')
         true_coeff=findobject(namex4regression(j),coeffs_eq(k),...
         ['+' ;'-';'*';'/';' ';'^';'('],...
         ['+' ;'-';'*';'/';' ';'^';')';'.'],%t)
         linear=linear & ~true_coeff
      end
   end
end
namex4regression=[coeffs_eq_unique , namex4regression]
 
endfunction
