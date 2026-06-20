function [prolog_string2run,func_txts,Jac_txts,remaining_eq,remaining_endo,removed_eq,removed_endo]=model_prolog(model,namendo,texts,analyses,indendos,indsigns,laginfos)
 
// PURPOSE: determine the prolog of a model and transform the
// corresponding equations into obkects used in simulations
// ------------------------------------------------------------
// INPUT:
// * model = a model typed list created by the function
//   create_model
// * namendo = a (N x 1) string vector, collecting the names
//   of the endogenous variables in the model
// * texts = a listof neq string vetorss, each vector
//   collecting elentary pieces of an equation
// * analyses = a list of neq lists, each element of one list
//   representing an additive element of the correspondind
//   equation (that is, the text is built from the elements
//   of the list by teh addition or the subtraction of them),
//   that is:
//   - either a string, the name of an object of the model
//     (variable, constant, parameter,...)
//   - or a list of 2 elements, the tlist result from the
//     syntactic analysis (by analyse_eq1) and the names of the
//     variables (exogenousn endogenous and residuals) found in
//     the corresponding part of the text
// * indendos = a list of (n x 2) real matrices, each matrix
//   collecting on the first column the indexes of the
//   endogenous variables found in the equation and on the
//   second column the index of the piece of the equation it
//   belongs to
// * indsigns = a list of (n x 2) real matrices, each matrix
//   collecting on the first row the indexes of the isolated
//   members of the equation, on the second row 1 if the
//   member is preceded by '+' and 0 if it is preceded by 0
// * laginfos = a list of (n x 2) string matrices, each line
//   collecting of the matrix being the representation of a
//   lagged variable and the way the variable will be used in
//   the simulation (such as x(grocer_date-1))
// ------------------------------------------------------------
// OUTPUT:
// * prolog_string2run = a (N x 1) string vector, collecting
//   the text of the equations that will bre run to calculate the
//   endogenous variables belonging to the prolog of the model
// * func_txts = a (m x 1) string vector, collecting
//   the text of the functions that will be run to calculate the
//   endogenous variables belonging to the prolog of the
//   model, when the endogenous variable is the determined as
//   the zero of a function
// * Jac_txts = a (m x 1) string vector, collecting
//   the Jacobians of the functions that will be run to
//   calculate the endogenous variables belonging to the prolog
//   of the model, when the endogenous variable is the determined
//   as the zero fo a function
// * remaining_eq = a (1 x J) vector, collecting the indexes of
//   the equations that do not belong to the prolog
// * remaining_endo = a (1 x J) vector, collecting the indexes
//   of the endogenous variables that are not determined in the
//   prolog
// * removed_eq = a (1 x K) vector, collecting the indexes of
//   the equations that belong to the prolog
// * removed_endo = a (1 x J) vector, collecting the indexes
//   of the endogenous variables that are determined in the
//   prolog
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015-2018
// http://grocer.toolbox.free.fr/grocer.html
 
global grocer_variables ;
load(GROCERDIR+'\param\symb_listfunc.dat')
load(GROCERDIR+'\data\functions.dat')
 
// set starting values for the prolog objects and the equation and variables
// that do not belong to the prolog
 
neq=size(grocer_model('equations'),1)
remaining_eq=[1:neq]
remaining_endo=1:size(namendo,1)
removed_eq=zeros(1,neq)
removed_endo=zeros(1,neq)
prolog_string2run=emptystr(neq,1)
func_txts=emptystr(neq,1)
Jac_txts=emptystr(neq,1)
 
ind_prolog_endo=[]
prolog=%t
n_prolog=0
n_func=0
 
while prolog
   n_prolog0=n_prolog
   for index_eq=1:size(remaining_eq,2)
      ind_eq=remaining_eq(index_eq)
      text_eq=texts(ind_eq)
      analyses_eq=analyses(ind_eq)
      laginfo_eq=laginfos(ind_eq)
      indsign_eq=indsigns(ind_eq)
      indendo_eq=indendos(ind_eq)
      indendo_eq0=indendo_eq
      for j=size(indendo_eq,1):-1:1
         if or(indendo_eq(j,1) == removed_endo) then
            indendo_eq(j,:)=[]
         end
      end
      indendo_eq_unique=unique(indendo_eq(:,1))
 
      nendo=size(indendo_eq_unique,1)
 
      if nendo == 1 then
 
         n_prolog=n_prolog+1
         ind_endo=unique(indendo_eq(:,2))
         ind_prolog_endo=[ind_prolog_endo ; indendo_eq(1)]
         nameparam='grocer_param'+string(indendo_eq(1))+'_'
         nameparam2='grocer_param('+string(indendo_eq(1))+')'
         namendo_eq=namendo(indendo_eq(1))
         if size(ind_endo,'*') == 1 then
            ind_func=find(grocer_func+'('+nameparam+')' == text_eq(ind_endo))
         else
            ind_func=[]
         end
         // find if the text of the member where the endo appears is equal
         // to a predefined function that can be inversed
         if size(indendo_eq,1) ==1 & text_eq(indendo_eq(2)) == nameparam then
            ind_remaining=[1:size(text_eq,1)]
            ind_remaining(ind_endo)=[]
            indsign_eq_txt=string(indsign_eq(ind_remaining))
            if indsign_eq(ind_endo) == 1 then
               indsign_eq_txt=strsubst(indsign_eq_txt,'-1','+')
               indsign_eq_txt=strsubst(indsign_eq_txt,'1','-')
            else
               indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
               indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
            end
            prolog_string2run_eq=nameparam2+'='+strcat(indsign_eq_txt+text_eq(ind_remaining)')
            for j=1:size(laginfo_eq,1)
               prolog_string2run_eq=strsubst(prolog_string2run_eq,laginfo_eq(j,1),laginfo_eq(j,2))
            end
 
         elseif size(indendo_eq,1) ==1 & ~isempty(ind_func) then
            ind_remaining=[1:size(text_eq,1)]
            ind_remaining(ind_endo)=[]
            indsign_eq_txt=string(indsign_eq(ind_remaining))
            if indsign_eq(ind_endo) == 1 then
               indsign_eq_txt=strsubst(indsign_eq_txt,'-1','+')
               indsign_eq_txt=strsubst(indsign_eq_txt,'1','-')
            else
               indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
               indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
            end
            prolog_string2run_eq=nameparam2+'='+grocer_invfunc(ind_func)+'('+strcat(indsign_eq_txt+text_eq(ind_remaining)')+')'
            for j=1:size(laginfo_eq,1)
               prolog_string2run_eq=strsubst(prolog_string2run_eq,laginfo_eq(j,1),laginfo_eq(j,2))
            end
 
         else
 
            n_func=n_func+1
            indsign_eq_txt=string(indsign_eq)
            indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
            indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
            indendo_eq0(indendo_eq0(:,1) == indendo_eq_unique,:)=[]
            namendo_eq(indendo_eq0(:,1) == indendo_eq_unique,:)=[]
            Jac_part=''
            for j=1:size(indendo_eq,1)
               ana_eq_endo=analyses_eq(indendo_eq(j,2))
               deriv_endo=deriv_eq(ana_eq_endo(1),namendo_eq)
               deriv_endo=strsubst_trueobj(deriv_endo,namendo_eq,nameparam,[' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                  [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
               grocer_vari=ana_eq_endo(2)
               for k=1:size(grocer_vari,'*')
                  ind_namendo=find(grocer_vari(k) == namendo)
                  if ~isempty(ind_namendo) then
                      deriv_endo=strsubst_trueobj(deriv_endo,grocer_vari(k),'grocer_param('+string(ind_namendo)+')',...
                              [' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                              [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
                  elseif ~isempty([find(grocer_vari(k) == model('name exo')) , find(grocer_vari(k) == model('name resid')) ]) then
                      deriv_endo=strsubst_trueobj(deriv_endo,grocer_vari(k),grocer_vari(k)+'(grocer_date)',...
                              [' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                              [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
 
                   end
                end
 
 
               if indsign_eq_txt(indendo_eq(j,2)) == '+' then
                  Jac_part=Jac_part+'+'+deriv_endo
               else
                  Jac_part=Jac_part+'-('+deriv_endo+')'
               end
            end
 
            ftext=strcat(indsign_eq_txt+text_eq')
            for j=1:size(laginfo_eq,1)
               laginfo_txtold_j=laginfo_eq(j,1)
               laginfo_txtnew_j=laginfo_eq(j,2)
               ftext=strsubst(ftext,laginfo_txtold_j,laginfo_txtnew_j)
               Jac_part=strsubst(Jac_part,laginfo_txtold_j,laginfo_txtnew_j)
            end
 
            func_txt_endo='deff(''fval=grocer_func'+string(indendo_eq(1))+'(grocer_param'+string(indendo_eq(1))+'_)'',''fval='+ftext+''')'
            for ind_endo=1:size(indendo_eq0,1)
               func_txt_endo=strsubst(func_txt_endo,'grocer_param'+string(indendo_eq0(ind_endo,1))+'_','grocer_param('+string(indendo_eq0(ind_endo,1))+')')
            end
            func_txts(n_func)=func_txt_endo
 
            Jac_txt_endo='deff(''fval=grocer_Jac'+string(indendo_eq(1))+'(grocer_param'+string(indendo_eq(1))+'_)'',''fval='+Jac_part+''')'
            Jac_txts(n_func)=Jac_txt_endo
 
            prolog_string2run_eq=nameparam2+'=grocer_newtons(grocer_param('+string(indendo_eq(1))+'),grocer_func'+string(indendo_eq(1))+...
                           ',grocer_Jac'+string(indendo_eq(1))+',0.5*grocer_ftol,grocer_itermax,grocer_alphamin )'
         end
         for ind_endo=1:size(indendo_eq0,1)
            prolog_string2run_eq=strsubst(prolog_string2run_eq,'grocer_param'+string(indendo_eq0(ind_endo,1))+'_','grocer_param('+string(indendo_eq0(ind_endo,1))+')')
         end
         prolog_string2run(n_prolog)=prolog_string2run_eq
         removed_eq(n_prolog)=ind_eq
         removed_endo(n_prolog)=indendo_eq(1)
      end
   end
   prolog=(n_prolog0 ~= n_prolog) &  (n_prolog ~= neq)
   remaining_eq=1:neq
   remaining_eq(removed_eq(1:n_prolog))=[]
 
end
 
removed_eq=removed_eq(1:n_prolog)
removed_endo=removed_endo(1:n_prolog)
remaining_endo(removed_endo)=[]
prolog_string2run=prolog_string2run(1:n_prolog)
func_txts=func_txts(1:n_func)
Jac_txts=Jac_txts(1:n_func)
 
endfunction
 
