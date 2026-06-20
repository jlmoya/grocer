function [epilog_string2run,func_txts,Jac_txts,remaining_eq,remaining_endo,removed_eq2,removed_endo2]=model_epilog(remaining_eq,remaining_endo,removed_eq,removed_endo,listeqperendo_wol,namendo,texts,analyses,indendos,indsigns,laginfos)
 
// PURPOSE: determine the epilog of a model and transform the
// corresponding equations into obkects used in simulations
// ------------------------------------------------------------
// INPUT:
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
// * listeqperendo_wol = a list of vectors, each vector
//   collecting the indexes of the equations where the i-th
//   endogenous appears contemporaneously
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
// * epilog_string2run = a (N x 1) string vector, collecting
//   the text of the equations that will bre run to calculate the
//   endogenous variables belonging to the epilog of the model
// * func_txts = a (m x 1) string vector, collecting
//   the text of the functions that will be run to calculate the
//   endogenous variables belonging to the epilog of the
//   model, when the endogenous variable is the determined as
//   the zero of a function
// * Jac_txts = a (m x 1) string vector, collecting
//   the Jacobians of the functions that will be run to
//   calculate the endogenous variables belonging to the epilog
//   of the model, when the endogenous variable is the determined
//   as the zero fo a function
// * remaining_eq = a (1 x J) vector, collecting the indexes of
//   the equations that do not belong to the prolog or the epilog
// * remaining_endo = a (1 x J) vector, collecting the indexes
//   of the endogenous variables that are not determined in the
//   prolog or the epilog
// * removed_eq = a (1 x K) vector, collecting the indexes of
//   the equations that belong to the epilog
// * removed_endo = a (1 x J) vector, collecting the indexes
//   of the endogenous variables that are determined in the
//   epilog
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015-2016
// http://grocer.toolbox.free.fr/grocer.html
 
global grocer_variables ;
load(GROCERDIR+'\param\symb_listfunc.dat')
load(GROCERDIR+'\data\functions.dat')
 
nendo=size(namendo,1)
n_remaining_endo=size(remaining_endo,'*')
n_removed_endo=size(removed_endo,'*')
removed_endo2=zeros(1,nendo)
removed_endo2(1:n_removed_endo)=removed_endo
removed_eq2=zeros(1,nendo)
removed_eq2(1:n_removed_endo)=removed_eq
 
epilog=%t
ind_epilog_eq=[]
ind_epilog_endo=[]
epilog_string2run=emptystr(n_remaining_endo,1)
func_txts=emptystr(n_remaining_endo,1)
Jac_txts=emptystr(n_remaining_endo,1)
epilog=%t
n_epilog=0
n_func=0
 
while epilog
   n_epilog0=n_epilog
   for endo=remaining_endo
      eq=find(listeqperendo_wol(endo,:) == 1)
      if size(eq,'*') == 1 then
         n_epilog=n_epilog+1
         n_removed_endo=n_removed_endo+1
         text_eq=texts(eq)
         analyses_eq=analyses(eq)
         laginfo_eq=laginfos(eq)
         indsign_eq=indsigns(eq)
         indendo_eq=indendos(eq)
         indendo_eq0=indendo_eq
         indendo_eq_unique=unique(indendo_eq(:,1))
         nameparam='grocer_param'+string(endo)+'_'
         nameparam2='grocer_param('+string(endo)+')'
         ind_txteqendo=find(text_eq == nameparam)
         txtwithendo=find(indendo_eq(:,1) == endo)
         n_txtwithendo=size(txtwithendo,2)
         ind_func=find(grocer_func+'('+nameparam+')' == text_eq)
 
         if size(ind_txteqendo,2) == 1 & n_txtwithendo == 1 then
            ind_remaining=[1:size(text_eq,1)]
            ind_remaining(ind_txteqendo)=[]
            indsign_eq_txt=string(indsign_eq(ind_remaining))
            if indsign_eq(ind_txteqendo) == 1 then
               indsign_eq_txt=strsubst(indsign_eq_txt,'-1','+')
               indsign_eq_txt=strsubst(indsign_eq_txt,'1','-')
            else
               indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
               indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
            end
            epilog_string2run_eq=nameparam2+'='+strcat(indsign_eq_txt+text_eq(ind_remaining)')
            for j=1:size(laginfo_eq,1)
               laginfo_txtnew_j=laginfo_eq(j)
               epilog_string2run_eq=strsubst(epilog_string2run_eq,laginfo_eq(j,1),laginfo_eq(j,2))
            end
 
         elseif n_txtwithendo == 1 & ~isempty(ind_func) then
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
            epilog_string2run_eq=nameparam2+'='+grocer_invfunc(ind_func)+'('+strcat(indsign_eq_txt+text_eq(ind_remaining)')+')'
            for j=1:size(laginfo_eq,1)
               epilog_string2run_eq=strsubst(epilog_string2run_eq,laginfo_eq(j,1),laginfo_eq(j,2))
            end
 
         else
            n_func=n_func+1
            indsign_eq_txt=string(indsign_eq)
            indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
            indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
            indendo_eq0(indendo_eq0(:,1) == endo,:)=[]
            namendo_eq(indendo_eq0(:,1) == endo,:)=[]
            Jac_part=''
            namendo_eq=namendo(endo)
            for j=1:n_txtwithendo
               ana_eq_endo=analyses_eq(indendo_eq(txtwithendo(j),2))
               if typeof(ana_eq_endo) == 'string' then
                  deriv_endo='1'
               else
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
               end
 
               if indsign_eq_txt(indendo_eq(txtwithendo(j),2)) == '+' then
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
 
            func_txt_endo='deff(''fval=grocer_func'+string(endo)+'(grocer_param'+string(endo)+'_)'',''fval='+ftext+''')'
            for ind_endo=1:size(indendo_eq0,1)
               func_txt_endo=strsubst(func_txt_endo,'grocer_param'+string(indendo_eq0(ind_endo,1))+'_','grocer_param('+string(indendo_eq0(ind_endo,1))+')')
            end
            func_txts(n_func)=func_txt_endo
 
            Jac_txts(n_func)='deff(''fval=grocer_Jac'+string(endo)+'(grocer_param'+string(endo)+'_)'', ''fval='+Jac_part+''')'
 
            epilog_string2run_eq=nameparam2+'=grocer_newtons(grocer_param('+string(endo)+'),grocer_func'+string(endo)+...
                           ',grocer_Jac'+string(endo)+',0.5*grocer_ftol,grocer_itermax,grocer_alphamin)'
 
         end
         indendo_eq(indendo_eq == endo,:)=[]
         for ind_endo=1:size(indendo_eq,1)
            epilog_string2run_eq=strsubst(epilog_string2run_eq,'grocer_param'+string(indendo_eq(ind_endo,1))+'_','grocer_param('+string(indendo_eq(ind_endo,1))+')')
         end
         epilog_string2run(n_epilog)= epilog_string2run_eq
         remaining_eq(remaining_eq == eq)=[]
         removed_endo2(n_removed_endo)= endo
         removed_eq2(n_removed_endo)= eq
      end
   end
   remaining_endo=[1:size(namendo,1)]
   remaining_endo(removed_endo2(1:n_removed_endo))=[]
   epilog=(n_epilog ~= n_epilog0)
end
 
removed_eq2=removed_eq2(1:n_removed_endo)
removed_endo2=removed_endo2(1:n_removed_endo)
epilog_string2run=epilog_string2run(1:n_epilog)
func_txts=func_txts(1:n_func)
Jac_txts=Jac_txts(1:n_func)
 
endfunction
