function [oldtxt,newtxt,analysed_eq,indendo_eq,coeffs_eq,ind_coeffs_eq,indsigns,listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namexo,list_lags,lags_endos,lags_exos,lags_resids]=explode_eqside(txt,indeqi,nameqi,listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,nameresid,namecoeff,nameparam,laginfo_eq,lags_endos,lags_exos,lags_resids)
 
// PURPOSE: from a piece of equation, build various objects
// needed for estimation, simulation etc.
// ------------------------------------------------------------
// INPUT:
// * txt = a string, part of the text of an equation
// * nameqi = the name of the equation
// * listeqperendo = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   endogenous appears
// * listeqperendo_wolags = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   endogenous appears contemporaneously
// * listeqperexo = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   exogenous appears
// * listeqpercoeff = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   residual appears
// * namendo = the name of the model endogneous
// * namexo = the name of the model exogneous
// * namresid = the name of the model residuals
// * namecoeff = the name of the model coefficients
// * laginfo_eq = a (n x 2) string matrix, each line collecting
//   the representation of a lagged variable and the way the
//   variable will be used in the simulation (such as
//   x(grocer_date-1))
// * lags_endos =  a list of vectors, each vector
//   collecting the lags of the corresponding endogenous
//   variable, as they can be found in the equations where the
//   variable is present
// * lags_exos =  a list of vectors, each vector
//   collecting the lags of the corresponding exogenous
//   variable, as they can be found in the equations where the
//   variable is present
// * lags_resids =  a list of vectors, each vector
//   collecting the lags of the corresponding residual
//   variable, as they can be found in the equations where the
//   variable is present
// ------------------------------------------------------------
// OUTPUT:
// * oldtxt = a string vector, collecting pieces of a text
// * newtxt = a string vector, collecting pieces of a text, with
//   the 'groder_date-k' that will be used in simulations
// * analysed_eq = a list, each element of the list representing
//   an additive element of the text (that is, the text is built
//   from the elements of the list by teh addition or the
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
// * coeffs_eq = a string vector, collecting the names of the
//   coeffs in the equation
// * indsigns = a (2 x n) matrix collecting on the first row the
//   indexes of the isolated members of the equation, on the
//   second row 1 if the member is preceded by '+' and 0 if it
//   is preceded by 0
// * listeqperendo = a list colle
// * listeqperendo = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   endogenous appears, updated with the considered equation
// * listeqperendo_wolgas = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   endogenous appears contemporaneously, updated with the
//   considered equation
// * listeqperexo = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   exogenous appears, updated with the considered equation
// * listeqpercoeff = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   residual appears, updated with the considered equation
// * namexo = the name of the model exogneous, updated with the
//   exogenous variables discovered in the equation
// * lags_endos =  a list of vectors, each vector
//   collecting the lags of the corresponding endogenous
//   variable, as they can be found in the equations where the
//   variable is present; the list has been updated in the
//   function with the lags found in the examined equation
// * lags_exos =  a list of vectors, each vector
//   collecting the lags of the corresponding exogenous
//   variable, as they can be found in the equations where the
//   variable is present; the list has been updated in the
//   function with the lags found in the examined equation
// * lags_resids =  a list of vectors, each vector
//   collecting the lags of the corresponding residual
//   variable, as they can be found in the equations where the
//   variable is present; the list has been updated in the
//   function with the lags found in the examined equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
 
global grocer_variables
txt=explode_log(txt)
// find all parantheses and gather information on their location
// in the text
[ind_leftpar,ind_rightpar,ind_fuspar]=sci_find_parenth(txt,['(';')'],11)
// find the location of the '+' and '-' signs
indplus=strindex(txt,'+')
indminus=strindex(txt,'-')
// find the "high level" parentheses (that is not encapsulated
// in other parentheses) in the text
ind_hl_leftpar=ind_fuspar(1,find(ind_fuspar(4,:) == 1))
ind_hl_rightpar=ind_fuspar(1,find(ind_fuspar(4,:) == 0))
// eliminate from the list of '+' and '-' drop the ones
// that are inside parentheses
while ~isempty(ind_hl_leftpar)
   i1=ind_hl_leftpar(1)
   f2=find(ind_hl_rightpar > i1)
   i2=ind_hl_rightpar(f2(1))
   indplus(indplus > i1 & indplus < i2)=[]
   indminus(indminus > i1 & indminus < i2)=[]
   ind_hl_leftpar=ind_hl_leftpar(:,ind_hl_leftpar(1,:)>i1)
end
 
// merge the locations of the remaining '+' and '-' signs
// along with the corresponding sign
indplus=[0 indplus ; ones(1,size(indplus,2)+1)]
indminus=[indminus length(txt)+1 ; -ones(1,size(indminus,2)+1)]
indsigns=[indplus indminus]
[junk,indsigns_sorted]=gsort(indsigns(1,:),'g','i')
indsigns=indsigns(:,indsigns_sorted)
 
ind_coeffs_eq=[]
coeffs_eq=[]
listendo_eq=[]
indendo_eq=[]
listcoeff_eq=[]
analysed_eq=list()
list_lags=[]
 
nsigns=size(indsigns,2)-1
newtxt=emptystr(nsigns,1)
oldtxt=emptystr(nsigns,1)
indsign=nsigns
// analyse of the pieces of text, starting from the right
 
while indsign >= 1
 
   // take the grocer_j-th piece of text
   partj=stripblanks(part(txt,indsigns(1,indsign)+1:indsigns(1,indsign+1)-1))
   if isempty(stripblanks(partj)) then
      // empty piece of text, do not take into consideration
      // and remove all corresponding references in indisigns,
      // indendo_eq and ind_coeffs_eq
      indsigns=[indsigns(:,1:indsign-1) , [indsigns(1,indsign+1) ; indsigns(2,indsign+1)*indsigns(2,indsign)] , indsigns(:,indsign+2:$)]
      analysed_eq(indsign)=null()
      if ~isempty(indendo_eq) then
         indendo_eq(:,2)=indendo_eq(:,2)-1
      end
      if ~isempty(ind_coeffs_eq)
        ind_coeffs_eq=ind_coeffs_eq-1
      end
      oldtxt(indsign)=[]
      newtxt(indsign)=[]
 
   else
 
      oldtxt(indsign)=partj
      // find all operating signs
      ind_hat=sci_find_simple(partj,'^',85)
      ind_star=sci_find_simple(partj,'*',80)
      ind_slash=sci_find_simple(partj,'/',80)
      ind_plus=sci_find_plus_minus(partj,'+',70)
      ind_minus=sci_find_plus_minus(partj,'-',70)
      ind_leftpar=strindex(partj,'(')
      ind_rightpar=strindex(partj,')')
      ind_all=[ind_hat,ind_star,ind_slash,ind_plus,ind_minus]
 
      if isempty(ind_all) & isempty([ind_leftpar ind_rightpar]) then
         // there is no parentheses and no operating sign in the
         // considered piece of text
         grocer_vari_part10=part(partj,1:10)
         if grocer_vari_part10 == 'grocer_lag' then
            list_lags=[list_lags ; strtod(part(partj,11:length(partj)-1))]
 
         else
            // the variable is not a lag
            // find if it is in the list of already defined variables or
            // coeffs and if this is not the case, add it to the list
            // of exogenous variables
            [listendo_eq,indendo_eq_j,ind_endo_j,ind_exo_j,ind_resid_j,coeffs_eq_j,...
            listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namexo,...
            typevari,lags_exos,listeqperendo_wolags]=...
            check_variables_ineq(partj,nameqi,indeqi,listendo_eq,[],coeffs_eq,...
            listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
            namendo,namexo,nameresid,namecoeff,nameparam,lags_exos)
 
            if typevari == 'exo' then
               // add the suffix '(grocer_date)' for the simulation
               partj=partj+'(grocer_date)'
               lags_exos(ind_exo_j)=[lags_exos(ind_exo_j) ;0]
 
            elseif typevari =='resid' then
               partj=partj+'(grocer_date)'
               lags_resids(ind_resid_j)=[lags_resids(ind_resid_j) ;0]
 
            elseif typevari == 'endo' then
                // transform the variable into the corresponding parameter
                // which will be the unknown to determine in the
                // simulations
               partj='grocer_param'+string(indendo_eq_j)+'_'
               lags_endos(ind_endo_j)=[lags_endos(ind_endo_j) ;0]
               indendo_eq=[indendo_eq_j , indsign ; indendo_eq ]
 
            elseif typevari ==  'coeff'
               // add the name of the coeff to the list of coefficients in the equation
               coeffs_eq=[ coeffs_eq_j  ; coeffs_eq ]
               ind_coeffs_eq=[indsign ; ind_coeffs_eq]
 
            end
         end
         // fill the indsign-th element of analysed_eq with the name of the variable
         analysed_eq(indsign)=partj
 
      else
         grocer_variables=[]
         is_endo=%f
         is_coeff=%f
         grocer_vari=tokens(partj,[' ';'(';')';'+';'-';'*';'^';'/'])
         grocer_vari(isnum(grocer_vari))=[]
         for j=1:size(grocer_listfunctions,1);
            grocer_vari(grocer_vari == grocer_listfunctions(j))=[];
         end
         if ~isempty(grocer_vari) then
            // the grocer_variables has been filled with the "true" variables
            // in the text
            // proceeds as above with all the variables
            grocer_vari_part10=part(grocer_vari,1:10)
            ind_laginvar=find(grocer_vari_part10 == 'grocer_lag')
            for k=ind_laginvar
               list_lags=[list_lags ; strtod(part(grocer_vari(k),11:length(grocer_vari(k))-1))]
            end
            // delete the lags from the list of variables
            grocer_vari(ind_laginvar)=[]
            nvari=size(grocer_vari,'*')
            grocer_strsubstvari=emptystr(nvari,1)
 
            for j=nvari:-1:1
               [listendo_eq,indendo_eq_j,ind_endo_j,ind_exo_j,ind_resid_j,coeffs_eq_j,...
               listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namexo,...
               typevari,lags_exos,listeqperendo_wolags]=...
               check_variables_ineq(grocer_vari(j),nameqi,indeqi,listendo_eq,[],coeffs_eq,...
               listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,...
               namendo,namexo,nameresid,namecoeff,nameparam,lags_exos)
 
               if typevari == 'exo'  then
                  grocer_strsubstvari(j)=grocer_vari(j)+'(grocer_date)'
                  lags_exos(ind_exo_j)=[lags_exos(ind_exo_j) ;0]
 
               elseif typevari =='resid'
                  grocer_strsubstvari(j)=grocer_vari(j)+'(grocer_date)'
                  lags_resids(ind_resid_j)=[lags_resids(ind_resid_j) ;0]
 
               elseif typevari == 'endo' then
                  grocer_strsubstvari(j)='grocer_param'+string(indendo_eq_j)+'_'
                  lags_endos(ind_endo_j)=[lags_endos(ind_endo_j) ;0]
                  indendo_eq=[[indendo_eq_j , indsign ] ; indendo_eq ]
                  is_endo=%t
 
               else
                  grocer_vari(j)=[]
                  grocer_strsubstvari(j)=[]
                  if typevari ==  'coeff'
                     coeffs_eq=[coeffs_eq_j  ; coeffs_eq ]
                     ind_coeffs_eq=[indsign ; ind_coeffs_eq]
                     is_coeff=%t
                   end
 
               end
            end
         end
 
        if is_endo | is_coeff then
            [junk,ind]=gsort(ind_all(1,:),'g','i')
            ind_all=ind_all(:,ind)
            [ind_leftpar,ind_rightpar,ind_fuspar]=sci_find_parenth_mod(partj)
            // run the syntactic analyser on the text
 
            res_eq_j=analyse_eq1(partj,ind_all,ind_fuspar)
            for j=size(grocer_vari,'*'):-1:1
               partj=strsubst_trueobj_mod(partj,grocer_vari(j),grocer_strsubstvari(j))
            end
            for j=1:size(laginfo_eq,1)
               partj=strsubst(partj,laginfo_eq(j,1),laginfo_eq(j,2))
            end
            // fill the indisgn-th element of analyses_eq with the result of the
            // syntactic analysis and the variables in the text
            analysed_eq(indsign)=list(res_eq_j,grocer_vari)
            // replace the lagged variables with their litteral text, with the
            // needed indexes (grocer_date and grocer_date-k)
         else
            for j=size(grocer_vari,'*'):-1:1
               partj=strsubst_trueobj_mod(partj,grocer_vari(j),grocer_strsubstvari(j))
            end
            for j=1:size(laginfo_eq,1)
               partj=strsubst(partj,laginfo_eq(j,1),laginfo_eq(j,2))
            end
            analysed_eq(indsign)=partj
         end
 
      end
      newtxt(indsign)=partj
   end
 
   indsign=indsign-1
 
end
 
endfunction
