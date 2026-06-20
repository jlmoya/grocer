function [expression,textinlags,listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namexo,text4coeff,deriv_lags_names,deriv_lags_expr,lags_endos,lags_exos,lags_resids,maxlag]=replace_delts_n_lagts(expression,nameqi,indeqi,listeqperendo,listeqperendo_wol,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,nameresid,namecoeff,nameparam,lag0,deriv_lags_names,deriv_lags_expr,lags_endos,lags_exos,lags_resids,maxlag)
 
// PURPOSE: in an expression (the text of an equation),
// replace all delts(lag,x) with x-lag_n and all lagts with
// lag_n; and tranform the expression for the needs of the
// simulation: lagts(j,x) becomes x(grocer_date_j)
// ------------------------------------------------------------
// INPUT:
// * expression = a string, the text of an equation
// * nameqi = a string, the name of this equation
// * indeqi = a scalar, the index of this equation
// * listeqperendo = a list of nendo elements (nendo = # of
//   endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters
// * listeqperendo_wol = a list of nendo elements (nendo = #
//   of endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters
//   contemporaneously
// * listeqperexo = a list of nexo elements (nexo = # of
//   exogenous variables in the model), each element
//   collecting the equation for which the exogenous enters
// * listeqperresid = a list of nres elements (nres = # of
//   residual variables in the model), each element
//   collecting the equation for which the residual enters
// * listeqpercoeff = a list of ncoeff elements (ncoeff = #
//   of coefficients in the model), each element
//   collecting the equation for which the coefficient enters
// * namendo = a string vector, the names of the endogenous
//   variables in the model
// * namexo = a string vector, the names of the exogenous
//   variables in the model
// * nameresid = a string vector, the names of the residuals
//   in the model
// * namecoeff = a string vector, the names of the ceofficients
//   in the model
// * lag0 = a scalar, the index of the lags already defined in
//   the equation (in practice: 0 for the lhs, and the number of
//   lags defined in the lhs for the rhs)
// ------------------------------------------------------------
// OUTPUT:
// * expression = the expression where all delts and lagts have
//   been transformed
// * lags = a (n x 2) string matrix with the grocer_lagi_ in
//   the first column and the corresponding text that will be
//   used in the simulations in the second column
// * listeqperendo = a list of nendo elements (nendo = # of
//   endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters,
//   updated with the variables found in the equation
// * listeqperendo_wol = a list of nendo elements (nendo = #
//   of endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters
//   contemporaneously, updated with the variables found in
//   the equation
// * listeqperexo = a list of nexo elements (nexo = # of
//   exogenous variables in the model), each element
//   collecting the equation for which the exogenous enters,
//   updated with the variables found in the equation
// * listeqperresid = a list of nres elements (nres = # of
//   residual variables in the model), each element
//   collecting the equation for which the residual enters,
//   updated with the variables found in the equation
// * listeqpercoeff = a list of ncoeff elements (ncoeff = #
//   of coefficients in the model), each element
//   collecting the equation for which the coefficient enters,
//   updated with the variables found in the equation
// * namexo = a string vector, the names of the exogenous
//   variables in the model, updated with the variables that
//   were not defined explictely and are tehrefore considered
//   as exogenous
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
 
global grocer_variables ;
listendo_eq=[]
listexo_eq=[]
listresid_eq=[]
listcoeff_eq=[]
 
// find the true delts
ind_delts=find_delts(expression,'delts')
 
// replace all delts(i,x) with x-lagts(i,x)
for j=size(ind_delts,2):-1:1
   endeq=part(expression,ind_delts(j)+5:length(expression))
   comma=[strindex(endeq,',') length(endeq)] // I add length(endeq) to avoid comma to be empty
   [leftpar,rightpar,fuspar]=sci_find_parenth_mod(endeq)
 
   strlag=stripblanks(part(endeq,leftpar(1)+1:comma(1)-1))
   closingpar=find(fuspar(4,:) == 0)
   endexpr=fuspar(1,closingpar(1))
 
   if ~isnum(strlag) then
      strlag='1,'
      expr=part(endeq,2:endexpr-1)
   else
      strlag=strlag+','
      expr=part(endeq,comma(1)+1:endexpr-1)
   end
 
   start_exp=stripblanks(part(expression,1:ind_delts(j)-1))
 
   if isempty(start_exp) then
      expression=expr+'-'+'lagts('+strlag+expr+...
              ')'+part(endeq,endexpr+1:length(endeq))
   elseif or(part(start_exp,length(start_exp)) == ['+' ; '(' ])
      expression=start_exp+expr+'-'+'lagts('+strlag+expr+...
              ')'+part(endeq,endexpr+1:length(endeq))
   else
      expression=start_exp+'('+expr+'-'+'lagts('+strlag+expr+...
              '))'+part(endeq,endexpr+1:length(endeq))
   end
 
end
 
// find the true lagts
ind_lagts=find_delts(expression,'lagts')
 
nlagts=size(ind_lagts,2)
 
grocer_lags=zeros(nlagts,1)
equations=emptystr(nlagts,1)
textlags=emptystr(nlagts,1)
listvaris=list()
varlags_list=list()
text4coeff=emptystr(nlagts,1)
 
for j=nlagts:-1:1
// replace all "lagts(vari) with "lagi_" to avoid derivating with respect to
// the lags of endogenous grocer_variables and store the replaced text to be able to reintroduce it
// at the end
// NB: it may happen that a grocer_lagj disapears because it is replaced by another
// one that encapsulates it; this is not a problem since we go from the right to the left
 
   deriv_lags_coeffs_j=[]
   deriv_lags_expr_j=[]
   endeq=part(expression,ind_lagts(j):length(expression))
   comma=[strindex(endeq,',') length(endeq)] // I add length(endeq) to avoid comma to be empty
   // find the left and right parentheses and collect them in
   // a matrix fuspar, whcich contains a row with the indexes
   // incremented by +1 for each '(' and -1 for each ')'
   [leftpar,rightpar,fuspar]=sci_find_parenth_mod(endeq)
 
   grocer_lagj=stripblanks(part(endeq,leftpar(1)+1:comma(1)-1))
   closingpar=find(fuspar(4,:) == 0)
   endexpr=fuspar(1,closingpar(1))
 
   listendo_eq_j=[]
   listexo_eq_j=[]
   listresid_eq_j=[]
   coeffs_eq_j=[]
 
   if ~isnum(grocer_lagj) then
      // the lagts is defined as lagts(x), without explicit lag
      // set it to 1 and defined the lagged member as the whole
      // text between parentheses
      grocer_lagj=1
      equation=part(endeq,leftpar(1)+1:endexpr-1)
 
   else
      // the lagged is defined explictely: recover it as well as the
      // lagged member
      grocer_lagj=strtod(grocer_lagj)
      equation=part(endeq,comma(1)+1:endexpr-1)
 
   end
 
   if grocer_lagj == 0 then
      // odd case when there is indeed no lag; remove the lagts from the equation
      expression=part(expression,1:ind_lagts(j)-1)+'('+part(endeq,comma(1)+1:endexpr)+')'+...
                part(endeq,endexpr+1:length(endeq))
      ind_lagts(j)=[]
      grocer_lags(j)=[]
      gocer_equations(j)=[]
      nlagts=nlagts-1
 
   else
      expression=part(expression,1:ind_lagts(j)-1)+'grocer_lag'+string(j+lag0)+'_'+...
                part(endeq,endexpr+1:length(endeq))
 
      ind_hat=sci_find_simple(equation,'^',85)
      ind_star=sci_find_simple(equation,'*',80)
      ind_slash=sci_find_simple(equation,'/',80)
      ind_plus=sci_find_plus_minus(equation,'+',70)
      ind_minus=sci_find_plus_minus(equation,'-',70)
      ind_all=[ind_hat,ind_star,ind_slash,ind_plus,ind_minus]
      [ind_leftpar,ind_rightpar,ind_fuspar]=sci_find_parenth(equation,['(';')'],11)
 
      if isempty(ind_all) & isempty(ind_fuspar) then
         // there is no sign in the considered member: the member should represent
         // name of a variable
         vari_part10=part(equation,1:10)
         if vari_part10 == 'grocer_lag' then
            // the variable is of the type grocer_lagi_
            varlags=equation
         else
            // this is a true variable
            varlags=[]
            // check if the variable has already been declared as en endogenous, exogenous,
            // residual or coefficient, if not consider it as exogenous; update the list
            // of equations where the variable can be found
            [listendo_eq_j,indendo_eq_j,ind_endo_j,ind_exo_j,ind_resid_j,listexo_eq_j,listresid_eq_j,coeffs_eq_j,...
            listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
            namexo,typevari,lags_exos]=...
            check_variables_ineq2(equation,nameqi,indeqi,listendo_eq_j,[],listexo_eq_j,listresid_eq_j,coeffs_eq_j,...
            listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
            namendo,namexo,nameresid,namecoeff,nameparam,lags_exos)
             listvari=[listendo_eq_j ; listexo_eq_j ; listresid_eq_j]
         end
 
      else
         [junk,ind]=gsort(ind_all(1,:),'g','i')
         ind_all=ind_all(:,ind)
         grocer_variables=[]
         // run the syntactic analyser to find the variables in the text encapsulated in the lagts
         ana=analyse_eq1(equation,ind_all,ind_fuspar)
         grocer_variables=unique(grocer_variables)
         // find the variables that are of the form: grocer_lagi_
         indlags=find(part(grocer_variables,1:10) == 'grocer_lag')
         if ~isempty(indlags) then
            for k=indlags
               ind_lag=strtod(part(grocer_variables(k),11:length(grocer_variables(k))-1))
               if or(definedfields(deriv_lags_names) == ind_lag) then
                  deriv_lags_coeffs_j=[deriv_lags_coeffs_j ; ...
                                    deriv_lags_names(ind_lag)]
                  for m=1:size(deriv_lags_names(ind_lag),1)
                     deriv_lags_expr_j=[ deriv_lags_expr_j ; deriv_eq(ana,grocer_variables(k))+'*('+deriv_lags_expr(ind_lag)(m)+')']
                  end
               end
            end
         end
 
         varlags=grocer_variables(indlags)
         grocer_variables(indlags)=[]
         for k=1:size(grocer_variables,1)
            // check if the variables have already been declared as en endogenous, exogenous,
            // residual or coefficient, if not consider it as exogenous; update the list
            // of equations where the variable can be found
            [listendo_eq_j,indendo_eq,ind_endo_j,ind_exo_j,ind_resid_j,listexo_eq_j,listresid_eq_j,coeffs_eq_j,listeqperendo,listeqperexo,...
            listeqperresid,listeqpercoeff,listeqperparam,namexo,typevari,lags_exos]=...
            check_variables_ineq2(grocer_variables(k),nameqi,indeqi,listendo_eq_j,[],listexo_eq_j,listresid_eq_j,coeffs_eq_j,...
            listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,nameresid,namecoeff,nameparam,lags_exos)
 
            if ~isempty(coeffs_eq_j) then
               deriv_lags_coeffs_j=[deriv_lags_coeffs_j ; ...
                               coeffs_eq_j]
               deriv_lags_expr_j=[ deriv_lags_expr_j ; 'lagts('+string(grocer_lagj)+','+deriv_eq(ana,coeffs_eq_j)+')']
            end
         end
         listvari=[listendo_eq_j ; listexo_eq_j ; listresid_eq_j]
         if ~isempty(deriv_lags_coeffs_j) then
            deriv_lags_names(j+lag0)=deriv_lags_coeffs_j
            deriv_lags_expr(j+lag0)=deriv_lags_expr_j
         end
      end
      grocer_lags(j)=grocer_lagj
      equations(j)=equation
      textlags(j)='grocer_lag'+string(j+lag0)+'_'
      listvaris($+1)=listvari
      varlags_list($+1)=varlags
      text4coeff(j)=part(endeq,1:endexpr)
   end
end
 
textinlags=emptystr(nlagts,2)
 
// lags will contain the grocer_lagi_ in the first column and their counterpart
// used for simulations in the second column
for j=1:nlagts
 
   lagj=grocer_lags(j)// lag
   maxlag=max(maxlag,lagj)
   textj=equations(j) // original lagged text
 
   namevari=listvaris(nlagts-j+1) // name of the variables in the original text
 
   if textj == namevari then
      // the text is the name of a variable; add only '(grocer_date-lag)' to the text
      textj=textj+'(grocer_date-'+string(lagj)+')'
      ind_resid_eq=find(nameresid == namevari)
      if ~isempty(ind_resid_eq) then
         lags_resids(ind_resid_eq)=[lags_resids(ind_resid_eq) ; lagj]
 
      else
         ind_exo_eq=find(namexo == namevari)
         if ~isempty(ind_exo_eq) then
            lags_exos(ind_exo_eq)=[lags_exos(ind_exo_eq) ; lagj]
 
         else
            ind_endo_eq=find(namendo == namevari)
            lags_endos(ind_endo_eq)=[lags_endos(ind_endo_eq) ; lagj]
         end
      end
 
 
   else
      // there are several variable; add only '(grocer_date-lag)' to them,
      // ensuring that only the variables are changed
      for k=1:size(namevari,1)
         varik=namevari(k)
         textj=strsubst_trueobj_mod(textj,varik,varik+'(grocer_date-'+string(lagj)+')')
         ind_resid_eq=find(nameresid == varik)
         if ~isempty(ind_resid_eq) then
            lags_resids(ind_resid_eq)=[lags_resids(ind_resid_eq) ; lagj]
 
         else
            ind_exo_eq=find(namexo == varik)
            if ~isempty(ind_exo_eq) then
               lags_exos(ind_exo_eq)=[lags_exos(ind_exo_eq) ; lagj]
 
            else
               ind_endo_eq=find(namendo == varik)
               lags_endos(ind_endo_eq)=[lags_endos(ind_endo_eq) ; lagj]
            end
         end
      end
   end
 
   for m=j+1:nlagts
      if or(textlags(m) == varlags_list(nlagts-j+1)) then
      // the lag # m is encapsulated in lag # j:
      // add the lag j to the lag m to obtain the final lag
         grocer_lags(m)=grocer_lags(m)+lagj
      end
   end
 
   textinlags(j,:)=[textlags(j) , '('+textj+')']
 
end
 
 
endfunction
