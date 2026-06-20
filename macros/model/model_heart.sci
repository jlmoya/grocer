function [func_hearttext,Jac_hearttext,Jac_indexes,Jac_rhs,gs_string2run,func_gstxts,Jac_gstxts,pivots]=model_heart(remaining_eq,remaining_endo,removed_eq,removed_endo,namendo,texts,analyses,indendos,indsigns,laginfos,grocer_GS)
 
// PURPOSE: determine the heart of a model and transform the
// corresponding equations into objects used in simulations
// ------------------------------------------------------------
// INPUT:
// * remaining_eq = a (1 x J) vector, collecting the indexes of
//   the equations that belong to the heart
// * remaining_endo = a (1 x J) vector, collecting the indexes
//   of the endogenous variables that belong to the heart
// * removed_eq = a (1 x K) vector, collecting the indexes of
//   the equations that do not belong to the heart
// * removed_endo = a (1 x J) vector, collecting the indexes
//   of the endogenous variables that do not belong to the
//   heart
// * namendo = a (N x 1) string vector, collecting the names
//   of the endogenous variables in the model
// * texts = a list inof neq string vetorss, each vector
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
// * func_hearttext = a (n x 1) string vector, collecting
//   the text of the function whose 0 will be searched by the
//   Newton method for the endognous at the heart of the model
// * Jac_hearttext = a (P x 1) string vector, collecting
//   the non zero elemnts of the Jacobian of the function whose
//   0 will be searched by the Newton method for the endognous
//   at the heart of the model
// * gs_string2run = a (N x 1) string vector, collecting
//   the text of the equations that will be run to calculate the
//   endogenous variables in the Gauss-Seidel method
// * func_gstxts = a (m x 1) string vector, collecting
//   the text of the functions that will be run to calculate the
//   endogenous variables belonging to the prolog of the
//   model, when the endogenous variable is the determined as
//   the zero of a function
// * Jac_gstxts = a (m x 1) string vector, collecting
//   the Jacobians of the functions that will be run to
//   calculate the endogenous variables belonging to the prolog
//   of the model, when the endogenous variable is the determined
//   as the zero fo a function
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015-2016
// http://grocer.toolbox.free.fr/grocer.html
 
global grocer_variables ;
load(GROCERDIR+'\param\symb_listfunc.dat')
load(GROCERDIR+'\data\functions.dat')
grocer_derivfuncb=['exp(' ; '1/(' ; '1/sqrt(1-(' ; '-1/sqrt(1-(' ; '1/(' ; 'log(10)*exp(log(10)*' ; '2*(']
grocer_derivfunca=[')' ; ')' ; ')^2)' ; ')^2)' ; ')/log(10)' ; ')' ; ')']
 
// initialize the text of the function representing
// the equations at the heart of the model and of its Jacobian
func_hearttext=[]
Jac_hearttext=[]
Jac_rhs=[]
Jac_indexes=[]
ind_endoheart=[1:size(namendo,1)]'
ind_endoheart(remaining_endo)=[1:size(remaining_endo,2)]'
ind_newendos=list()
removed_endo_eqs=list()
endo_eqs_unique=list()
 
func_gstxts=[]
Jac_gstxts=[]
gs_string2run=[]
 
for eq=remaining_eq
   removed_endo_eq=[]
   indendo_eq=indendos(eq)
 
   for j=size(indendo_eq,1):-1:1
      if or(indendo_eq(j,1) == removed_endo) then
         removed_endo_eq=[removed_endo_eq ; indendo_eq(j,1)]
         indendo_eq(j,:)=[]
      else
         // remove the index of the same endogenous variable
         // in the same equation to avoid adding several times
         // the same derivation
         ind_samendo=find(indendo_eq(1:j-1,1) == indendo_eq(j,1) & indendo_eq(1:j-1,2) == indendo_eq(j,2))
         if ~isempty(ind_samendo) then
            indendo_eq(j,:)=[]
         end
      end
   end
   indendos(eq)=indendo_eq
   ind_newendos($+1)=indendo_eq(:,1)
   removed_endo_eqs($+1)=removed_endo_eq
 
end
pivots=remaining_endo
// search a set of nheart endogenous, so that:
// - the i-th endogenous variable is found in the i-th equation
//   in the heart of the model
// - these endogenous variables are all different, so that each of
//   the remaining endogenous will be calculated by an equation
 
if grocer_GS then
   ind_eqheart=0
   pivots=set_cover(remaining_endo,ind_newendos)
   ind_endoheart(pivots)=[1:size(remaining_endo,2)]'
   for eq=remaining_eq
      text_eq=texts(eq)
      indendo_eq=indendos(eq)
      namendo_eq=namendo(indendo_eq(:,1))
      analyses_eq=analyses(eq)
      ind_eqheart=ind_eqheart+1
      pivot_eq=pivots(ind_eqheart)
      indsign_eq=indsigns(eq)
      laginfo_eq=laginfos(eq)
      ind_endo=find(indendo_eq(:,1) == pivot_eq)
      nameparam='grocer_param'+string(pivot_eq)+'_'
 
      if size(ind_endo,1) ==1 & text_eq(indendo_eq(ind_endo,2)) == nameparam then
         // the endogenous variable calculated by the Gauss-Seidel method is isolated as such
         // as a part of the equation, the calculation is then straightforward
         ind_remaining=[1:size(text_eq,1)]
         ind_remaining(indendo_eq(ind_endo,2))=[]
         indsign_eq_txt=string(indsign_eq)
         if indsign_eq(indendo_eq(ind_endo,2)) == 1 then
            indsign_eq_txt=strsubst(indsign_eq_txt,'-1','+')
            indsign_eq_txt=strsubst(indsign_eq_txt,'1','-')
         else
            indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
            indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
         end
 
         gs_string2run_eq=nameparam+'=real('+strcat(indsign_eq_txt(ind_remaining)+text_eq(ind_remaining)')+')'
         for j=1:size(laginfo_eq,1)
            gs_string2run_eq=strsubst(gs_string2run_eq,laginfo_eq(j,1),laginfo_eq(j,2))
         end
 
      else
      // either the endogenous variable is determined by a complex function or appears
      // more than once in the equation
      // it will be determined in Gauss-Seidel through the search of the 0 of the
      // corresponding implicit function
         indsign_eq_txt=string(indsign_eq)
         indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
         indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
         Jac_part=''
         namendo_pivot=namendo(pivot_eq)
         // calculated the Jacobian of the equation with respect to all endogenous varaibles
         for j=1:size(ind_endo,1)
            ana_eq_endo=analyses_eq(indendo_eq(ind_endo(j),2))
//            deriv_endo=deriv_eqmod(ana_eq_endo(1),namendo_pivot)
            deriv_endo1=deriv_eq1(ana_eq_endo(1),namendo_pivot)
            reseq_ds=simplify_eq(deriv_endo1)
            // transform the tlist into the text of the equation
            deriv_endo=rebuild_eq(reseq_ds)
            grocer_vari=ana_eq_endo(2)
 
 
            // in the derivate, add (grocer_date) to the exogenous variables and replace the
           // endogenous variables by their grocer_param#i__ represnation
            for k=1:size(grocer_vari,'*')
               ind_namendo=find(grocer_vari(k) == namendo_eq)
               if isempty(ind_namendo) then
                  deriv_endo=strsubst_trueobj(deriv_endo,grocer_vari(k),grocer_vari(k)+'(grocer_date)',...
                    [' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                    [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
               else
                  deriv_endo=strsubst_trueobj(deriv_endo,grocer_vari(k),'grocer_param'+string(indendo_eq(ind_namendo(1),1))+'_',...
                       [' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                       [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
               end
            end
 
            if indsign_eq_txt(indendo_eq(ind_endo,2)) == '+' then
               Jac_part=Jac_part+'+'+deriv_endo
            else
               Jac_part=Jac_part+'-('+deriv_endo+')'
            end
         end
 
         // build the text of the equation and the Jacobian and replace
         // all grocer_lag#i_ by their expression adapted to simulation needs
         ftext=strcat(indsign_eq_txt+text_eq')
         for j=1:size(laginfo_eq,1)
            laginfo_txtold_j=laginfo_eq(j,1)
            laginfo_txtnew_j=laginfo_eq(j,2)
            ftext=strsubst(ftext,laginfo_txtold_j,laginfo_txtnew_j)
            Jac_part=strsubst(Jac_part,laginfo_txtold_j,laginfo_txtnew_j)
         end
 
         // update the vectors collecting the functions and the corresponding
         // Jacobian for the endogenous defined implicitely and the text that
         // will be used accordingly in the correspdoning Gauss-Seidel step
         func_gstxts=[func_gstxts ; ...
         'deff(''fval=grocer_gsfunc'+string(pivot_eq)+'(grocer_param'+string(pivot_eq)+'_)'',''fval='+ftext+''')']
 
         Jac_gstxts=[Jac_gstxts ; ...
         'deff(''fval=grocer_gsJac'+string(pivot_eq)+'(grocer_param'+string(pivot_eq)+'_)'',''fval='+Jac_part+''')']
 
         gs_string2run_eq='grocer_param'+string(pivot_eq)+...
                           '_=real(grocer_newton(grocer_param'+string(pivot_eq)+'_,grocer_gsfunc'+string(pivot_eq)+...
                           ',grocer_gsJac'+string(pivot_eq)+',0.1*grocer_ftol,0.1*grocer_deltol))'
      end
      gs_string2run=[gs_string2run ; gs_string2run_eq]
   end
end
 
compteur=0
ind_eqheart=0
 
for eq=remaining_eq
   compteur=compteur+1
   ind_eqheart=ind_eqheart+1
 
   // recover the details of the chosen equation
   text_eq=texts(eq)
   analyses_eq=analyses(eq)
   laginfo_eq=laginfos(eq)
   indsign_eq=indsigns(eq)
   indendo_eq=indendos(eq)
   endo_eq_unique=unique(indendo_eq(:,1))
   namendo_eq=namendo(indendo_eq(:,1))
   nendo_eq=size(endo_eq_unique,1)
   removed_endo_eq=removed_endo_eqs(compteur)
   nendo_eq=size(endo_eq_unique,1)
   Jac_rhs_eq=emptystr(nendo_eq,1)
   Jac_text_eq=emptystr(nendo_eq,1)
   indsign_eq_txt=string(indsign_eq)
   indsign_eq_txt=strsubst(indsign_eq_txt,'-1','-')
   indsign_eq_txt=strsubst(indsign_eq_txt,'1','+')
 
   for j=1:size(indendo_eq,1)
      indendo_eq_j=indendo_eq(j,1)
      member_eq=indendo_eq(j,2)
      ind_Jac_text=find(indendo_eq_j == endo_eq_unique)
      indsign_member=indsign_eq_txt(member_eq)
      ana_eq_endo=analyses_eq(member_eq)
 
      if typeof(ana_eq_endo) == 'string' then
         // the endogenous is isolated in part of an equation
         // (it appeared as +endogenous or -endogenous)
         // the derivative is then +1 or -1
         Jac_rhs_eq(ind_Jac_text)=Jac_rhs_eq(ind_Jac_text)+indsign_member+'1'
 
      else
         // the endogenous is not the pivot one and appears in a complex form
         // in the corresponding part of the equation
         // perform the derivation
         deriv_endo1=deriv_eq1(ana_eq_endo(1),grocer_namendo(indendo_eq_j))
         reseq_ds=simplify_eq(deriv_endo1)
         // transform the tlist into the text of the equation
         deriv_endo=rebuild_eq(reseq_ds)
         grocer_vari=ana_eq_endo(2)
 
         // in the derivate, add (grocer_date) to the exogenous variables and replace the
         // endogenous variables by their grocer_param#i_ representation (for endogenous
         // not in the heart of the model) or grocer_feart(#j)(for endogenous
         // in the heart of the model)
         for k=1:size(grocer_vari,'*')
            ind_namendo=find(grocer_vari(k) == namendo(pivots))
            ind_removed_endo=find(grocer_vari(k) == namendo(removed_endo_eq))
            if ~isempty(ind_namendo) then
               deriv_endo=strsubst_trueobj(deriv_endo,grocer_vari(k),'grocer_heart('+...
                   string(ind_namendo)+')',[' ' ;'+' ;'-';'*';'/';',';'^';'('],...
                  [' ' ;'+' ;'-';'*';'/';'^';')'],%f,%f)
 
            elseif ~isempty(ind_removed_endo) then
               deriv_endo=strsubst_trueobj(deriv_endo,grocer_vari(k),'grocer_param('+...
                  string(removed_endo_eq(ind_removed_endo(1)))+')',[' ' ;'+' ;'-';'*';'/';',';'^';'('],...
                  [' ' ;'=';'+' ;'-';'*';'/';'^';')'],%f,%f)
 
            else
 
               deriv_endo=strsubst_trueobj(deriv_endo,grocer_vari(k),grocer_vari(k)+'(grocer_date)',[' ' ;'+' ;'-';'*';'/';',';'^';'('],...
                  [' ' ;'+' ;'-';'*';'/';'^';')'],%f,%f)
            end
 
         end
 
         if indsign_eq_txt(indendo_eq(j,2)) == '+' then
            Jac_rhs_eq(ind_Jac_text)=Jac_rhs_eq(ind_Jac_text)+'+'+deriv_endo
         else
            Jac_rhs_eq(ind_Jac_text)=Jac_rhs_eq(ind_Jac_text)+'-('+deriv_endo+')'
         end
      end
 
   end
 
   for j=1:size(laginfo_eq,1)
      laginfo_txtold_j=laginfo_eq(j,1)
      laginfo_txtnew_j=laginfo_eq(j,2)
      text_eq=strsubst(text_eq,laginfo_txtold_j,laginfo_txtnew_j)
      for k=1:nendo_eq
         Jac_rhs_eq(k)=strsubst(Jac_rhs_eq(k),laginfo_txtold_j,laginfo_txtnew_j)
      end
   end
 
   func_text_eq=strcat(indsign_eq_txt+text_eq')
   ind_heart=zeros(nendo_eq,1)
   for k=1:nendo_eq
      ind_heart(k)=find(endo_eq_unique(k,1) == pivots)
      func_text_eq=strsubst(func_text_eq,'grocer_param'+string(endo_eq_unique(k))+'_',...
                   'grocer_heart('+string(ind_heart(k))+')')
   end
   for k=1:size(removed_endo_eq,1)
      func_text_eq=strsubst(func_text_eq,'grocer_param'+string(removed_endo_eq(k))+'_',...
                  'grocer_param('+string(removed_endo_eq(k))+')')
   end
 
   for k=1:nendo_eq
      Jac_text_eq(k)='grocer_Jac('+string(ind_eqheart)+','+string(ind_heart(k))+')='+Jac_rhs_eq(k)
 
   end
 
   // update the text of the functions used by the Newton method
   func_hearttext=[func_hearttext ; func_text_eq]
   Jac_rhs=[Jac_rhs ; Jac_rhs_eq]
   Jac_hearttext=[Jac_hearttext ; Jac_text_eq]
   Jac_indexes=[Jac_indexes ; [ones(nendo_eq,1)*ind_eqheart , ind_heart]]
 
 
end
 
endfunction
