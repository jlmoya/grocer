function model=create_model(filein,varargin)
 
// PURPOSE: from a txt file create a model
// ------------------------------------------------------------
// INPUT:
// * filein = the text file of the model
// * varargin = optional arguments that can be:
//  - 'verbose' if the user wants the function to display the
//    text of the equations when they are analysed
//  - 'GS' if the user wants the model to be simulated with the
//    Gauss-Seidel method
// ------------------------------------------------------------
// OUTPUT:
// * model = a model tlist, with:
// - model('namemod') = a string, the name of the model
// - model('name endo') = a string vector, the names of the
//   endogenous variables
// - model('name exo') = a string vector, the names of the
//   exogenous variables
// - model('name resid') = a string vector, the names of the
//   residuals
// - model('name coeff') = a string vector, the names of the
//   coefficients
// - model('name param') = a string vector, the names of the
//   parameters
// - model('name eq') = a string vector, the names of the
//   equations
// - model('equations') = a string vector, the texts of the
//   equations
// - model('coeffs') = a tlist, whose type is 'coeffs' with:
//   * model('coeffs')(i) = name of the i-th coeff
//   * model(i) = value of the (i+1)-th coeff
//   (example : if c0 is a coefficient of the model, and c0 has
//   been saved in an estimation function -olsmod, ivmod, etc.-
//   then model('coeffs')('c0') will contain the value of
//   coefficient c0)
// - model('params') = a tlist, the equivalent of model('coeffs')
//   for parameters
// - model('eq coeffs') = a (ncoeffs x neqs) sparse matrix, with
//   the (i,j) non zero coefficients corresponding to the
//   coefficient i being present in the equation j
// - model('eq endos') = a (nendo x neqs) sparse matrix, with
//   the (i,j) non zero coefficients corresponding to the
//   endogenous i being present in the equation j
// - model('eq exos') = a (nexo x neqs) sparse matrix, with
//   the (i,j) non zero coefficients corresponding to the
//   exogenous i being present in the equation j
// - model('eq exos') = a (nexo x neqs) sparse matrix, with
//   the (i,j) non zero coefficients corresponding to the
//   exogenous i being present in the equation j
// - model('eq resids') = a (nresid x neqs) sparse matrix, with
//   the (i,j) non zero coefficients corresponding to the
//   residual i being present in the equation j
// - model('eq params') = a (nparam x neqs) sparse matrix, with
//   the (i,j) non zero coefficients corresponding to the
//   parameter i being present in the equation j
// - model('lags endos') = a list of vectors, each vector
//   collecting the various lags the corresponding endogenous
//   variable appears in the model
// - model('lags exos') = a list of vectors, each vector
//   collecting the various lags the corresponding exogenous
//   variable appears in the model
// - model('non empty lagged endos') = a vector of integers,
//   collecting the endogenous that is lagged at least in an
//   equation
// - model('lags exos') = a list of vectors, each vector
//   collecting the various lags the corresponding exogenous
//   variable appears in the model
// - model('maxlag') = the lag maximum in the model
// - model('names for regressions') = a list of (2 x n_i) matrix
//  that for each equation collects on column 1 the names of the
//  coefficients in this equation (equivalent to the names of
//  the exogenous variables in an ols estimation) and in column
//  2 the derivative of the equation with respect to each
//  coefficient
// - model('linearity') =  a (neq x 1) vector of booleans, set
//  to %f if the equation is non linear with respect to its
//  coefficients, %t if it is (or has no coefficients)
// - model('transf') = a boolean, set to %t if the model has been
//   transformed for simulation, %f if not
// - model('prolog string2run') = a (k x 1) string vector,
//   collecting the equations that will be incorporated in
//   the text of the function called by function simulate
//   to run the prologue
// - model('prolog func txts') = a (k x 1) string vector,
//   collecting the texts of the functions that are to be
//   solved for equations in the prologue that cannot be solved
//   directly as 'endogenous=rhs'
// - model('prolog Jac txts') = a (k x 1) string vector,
//   collecting the texts of the corresponding Jacobians
// - model('prolog endo') = a (k x 1) vector of integers,
//   collecting the indexes of the endogenous variables that
//   are calculated by the prologue
// - model('prolog eq') = a (k x 1) vector of integers,
//   collecting the indexes of the equations that are solved by
//   the prologue
// - model('epilog string2run') = a (m x 1) string vector,
//   collecting the equations that will be incorporated in
//   the text of the function called by function simulate
//   to run the epilogue
// - model('epilog func txts') = a (m x 1) string vector,
//   collecting the texts of the functions that are to be
//   solved for equations in the epilogue that cannot be solved
//   directly as 'endogenous=rhs'
// - model('epilog Jac txts') = a (m x 1) string vector,
//   collecting the texts of the corresponding Jacobians
// - model('epilog endo') = a (m x 1) vector of integers,
//   collecting the indexes of the endogenous variables that
//   are calculated by the epilogue
// - model('epilog eq') = a (m x 1) vector of integers,
//   collecting the indexes of the equations that are solved by
//   the epilogue
// - model('heart func txt') = a (n x 1) string vector,
//   collecting the equations that will be incorporated in
//   the text of the function called by function simulate
//   to run the heart of the model
// - model('heart Jac txt') = a (p x 1) string vector,
//   collecting the equations of the non zero Jacobian
//   matrix values
// - model('heart Jac trhs') = a (p x 1) string vector,
//   collecting only the rhs of the equations of the non zero
//   Jacobian matrix values
// - model('heart Jac indexes') = a (p x 2) matrix of integers,
//   collecting the corresponding coordinates in the Jacabian
//   matrix
// - model('heart endogenous') = a (n x 1) vector of integers,
//   collecting the indexes of the endogenous variables that
//   are calculated by the heart
// - model('heart equations') = a (n x 1) vector of integers,
//   collecting the indexes of the equations that are solved by
//   the heart
// - model('gs string2run') = a (q x 1) string vector,
//   collecting the equations that will be calculated by the
//   Gauss-Seidel method (if option 'GS' has been entered)
// - model('gs func txts') = a (q x 1) string vector,
//   collecting the texts of the functions that are to be
//   solved at each Gsuss-Seidel step
// - model('gs Jac txts') = a (q x 1) string vector,
//   collecting the texts of the corresponding Jacobians
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2019
// http://grocer.toolbox.free.fr/grocer.html
 
// read the file of the model
v=read(filein,-1,1,'(a)')
 
nlines=size(v,1)
model=create_emptymodel([])
 
speccar=['+' '(' '-' '*' '/' ')' '^']
// intialiaze matrices that will be progressively filled
name_coeff_eq=[]
name_param_eq=[]
name_endo_eq=[]
name_exo_eq=[]
name_resid_eq=[]
namcoeff=' '
namemod=' '
namendo=' '
namexo=' '
namresid=' '
namparam=' '
nameq=[]
eq=[]
 
// remove comments from the text
lines_comment=grep(v,'//')
for i=lines_comment
   ind_comment=strindex(v(i),'//')
   v(i)=part(v(i),1:ind_comment(1)-1)
end
 
i=1
while i<=nlines
   // start analysing line i in file
   vi=v(i)
   // remove special characters from the line
   if part(vi,1) == ascii([239.   187.   191.]) then
      vi2=stripblanks(part(vi,2:length(vi)))
   else
      vi2=stripblanks(vi)
   end
 
   if part(strsubst(vi2,' ',''),1:6) == 'model:' then
      // this gives the name of the model, after the colon
      ind_col=strindex(vi2,':')
      endline=part(vi2,ind_col(1)+1:length(vi2))
      ind_semicol=strindex(endline,';')
      // search the ";" that ends the definition of the model name
      while isempty(ind_semicol) then
         namemod=namemod+endline+' '
         i=i+1
         endline=clean_string(v(i))
         ind_semicol=strindex(endline,';')
      end
 
      namemod=namemod+part(endline,1:ind_semicol(1)-1)
      // keep from the current line the text after the ";" that ends the definition of the model name
      v(i)=part(endline,ind_semicol(1)+1:length(endline))
      model('namemod')=stripblanks(namemod)
 
   elseif part(strsubst(vi2,' ',''),1:11) == 'endogenous:' then
      ind_col=strindex(vi2,':')
      endline=part(vi2,ind_col(1)+1:length(vi2))
      ind_semicol=strindex(endline,';')
      // search the ";" that ends the definition of the endogenous variables
      // and until it is reached, adds the lines to the string defining
      // the endogenous names
      while isempty(ind_semicol) then
         if ~isempty(endline) then
             namendo=namendo+endline+' '
         end
         i=i+1
         endline=v(i)
         if part(endline,1) == ascii([239.   187.   191.]) then
            endline=part(endline,2:length(endline))
         end
         ind_semicol=strindex(endline,';')
      end
      start_line=part(endline,1:ind_semicol(1)-1)
      if ~isempty(start_line) then
         namendo=namendo+start_line
      end
      v(i)=part(endline,ind_semicol(1)+1:length(endline))
 
      // transforms the string defining the endogenous variables into a
      // vector of names using function token and remove duplicates
      namendo=unique(tokens(namendo))
 
   elseif part(strsubst(vi2,' ',''),1:10) == 'exogenous:' then
      // operate as with endogenous variables
      ind_col=strindex(vi2,':')
      endline=part(vi2,ind_col(1)+1:length(vi2))
      ind_semicol=strindex(endline,';')
 
      while isempty(ind_semicol) then
         if ~isempty(endline) then
             namexo=namexo+endline+' '
         end
         i=i+1
         endline=v(i)
         if part(endline,1) == ascii([239.   187.   191.]) then
            endline=part(endline,2:length(endline))
         end
         ind_semicol=strindex(endline,';')
      end
      start_line=part(endline,1:ind_semicol(1)-1)
      if ~isempty(start_line) then
         namexo=namexo+' '+start_line
      end
      v(i)=part(endline,ind_semicol(1)+1:length(endline))
      namexo=unique(tokens(namexo))
 
   elseif part(strsubst(vi2,' ',''),1:10) == 'residuals:' then
      // operate as with endogenous variables
      ind_col=strindex(vi2,':')
      endline=part(vi2,ind_col(1)+1:length(vi2))
      ind_semicol=strindex(endline,';')
 
      while isempty(ind_semicol) then
         if ~isempty(endline) then
             namresid=namresid+endline+' '
         end
         i=i+1
         endline=v(i)
         if part(endline,1) == ascii([239.   187.   191.]) then
            endline=part(endline,2:length(endline))
         end
         ind_semicol=strindex(endline,';')
      end
      start_line=part(endline,1:ind_semicol(1)-1)
      if ~isempty(start_line) then
         namresid=namresid+' '+start_line
      end
      v(i)=part(endline,ind_semicol(1)+1:length(endline))
      namresid=unique(tokens(namresid))
 
   elseif part(strsubst(vi2,' ',''),1:13) == 'coefficients:' then
      // operate as with endogenous variables
      ind_col=strindex(vi2,':')
      endline=part(vi2,ind_col(1)+1:length(vi2))
      ind_semicol=strindex(endline,';')
      while isempty(ind_semicol) then
         if ~isempty(endline) then
            namcoeff=namcoeff+endline+' '
         end
         i=i+1
         endline=v(i)
         if part(endline,1) == ascii([239.   187.   191.]) then
            endline=part(endline,2:length(endline))
         end
         ind_semicol=strindex(endline,';')
      end
      start_line=part(endline,1:ind_semicol(1)-1)
      if ~isempty(start_line) then
         namcoeff=namcoeff+' '+start_line
      end
      v(i)=part(endline,ind_semicol(1)+1:length(endline))
      namcoeff=unique(tokens(namcoeff))
 
   elseif part(strsubst(vi2,' ',''),1:13) == 'parameters:' then
      // operate as with endogenous variables
      ind_col=strindex(vi2,':')
      endline=part(vi2,ind_col+1:length(vi2))
      ind_semicol=strindex(endline,';')
 
      while isempty(ind_semicol) then
         if ~isempty(endline) then
            namparam=namparam+endline+' '
         end
         i=i+1
         endline=v(i)
         if part(endline,1) == ascii([239.   187.   191.]) then
            endline=stripblanks(part(endline,2:length(endline)))
         else
            endline=stripblanks(endline)
         end
         ind_semicol=strindex(endline,';')
      end
      start_line=part(endline,1:ind_semicol(1)-1)
      if ~isempty(start_line) then
         namparam=namparam+' '+start_line
      end
      v(i)=part(endline,ind_semicol(1)+1:length(endline))
      namparam=unique(tokens(namparam))
 
   elseif part(strsubst(vi2,' ',''),1:10) == 'equations:' then
      ind_col=strindex(vi2,':')
      v(i)=part(vi2,ind_col+1:length(vi2))
      ind_semicol=strindex(endline,';')
      eqj=emptystr()
      while i <= nlines
         ind_semicol=strindex(v(i),';')
         if isempty(ind_semicol) then
            // add the line to the current equation
            eqj=eqj+v(i)
            // switch to the next line
            i=i+1
         else
            // add the part of the line ending before the foudn ";"
            eqj=eqj+' '+part(v(i),1:ind_semicol(1)-1)
            if ~isempty(stripblanks(eqj)) then
               // seacrh for the name of the equation
               ind_col=strindex(eqj,':')
               if isempty(ind_col) then
                  // no name; give it its index in the list poof equatiosn as a name
                  nameq=[nameq ; string(size(eq,1)+1)]
               else
                  // name found, recover it
                  nameq_i=strsubst(part(eqj,1:ind_col(1)-1),ascii(9),'')
                  nameq_i=stripblanks(nameq_i)
                  nameq=[nameq ; nameq_i]
                  // remove from the text of the equations the part related to its name
                  eqj=part(eqj,ind_col(1)+1:length(eqj))
               end
               if or(nameq($) == nameq(1:$-1)) then
                  warning('name for equation '+nameq($)+' has already been given')
               end
               // find in the equation the name of coeff defined implicitely by the suffix 'c
               name_coeff_eq= [name_coeff_eq ; model_defaultvar(eqj,'''c')]
               eqj=strsubst(eqj,'''c','')
               // the same for parameters, endogenous, exogenous and residuals
               name_param_eq=[name_param_eq ; model_defaultvar(eqj,'''p')]
               eqj=strsubst(eqj,'''p','')
               name_endo_eq=[name_endo_eq ; model_defaultvar(eqj,'''y')]
               eqj=strsubst(eqj,'''y','')
               name_exo_eq=[name_exo_eq ; model_defaultvar(eqj,'''x')]
               eqj=strsubst(eqj,'''x','')
               name_resid_eq=[name_resid_eq ; model_defaultvar(eqj,'''r')]
               eqj=strsubst(eqj,'''r','')
               eqj=strsubst(eqj,ascii(9),'')
               // reove duplicate "+"
               ind_plus2=strindex(eqj,'++')
               if ~isempty(ind_plus2) then
                  for k=size(ind_plus2,1):-1:1
                     eqj=part(eqj,1:ind_plus2(k))+part(eqj,ind_plus2(k)+2:length(eqj))
                  end
               end
               // add the text of the equation to the list of equation
               eq=[eq ; eqj]
               ind_semicol=strindex(v(i),';')
               v(i)=part(v(i),ind_semicol(1)+1:length(v(i)))
               eqj=emptystr()
            else
               i=i+1
            end
         end
      end
 
   else
 
      i=i+1
   end
end
 
// fill the model tlist with found objects
model('name eq')=nameq
model('equations')=eq
if namcoeff == ' ' then
   model('name coeff')= name_coeff_eq
else
   model('name coeff')=[namcoeff ; name_coeff_eq]
end
 
if namparam == ' ' then
   model('name param')=name_param_eq
else
   model('name param')=[stripblanks(namparam) ; name_param_eq]
end
 
if namendo == ' ' then
   model('name endo')=name_endo_eq
else
   model('name endo')=[stripblanks(namendo) ; name_endo_eq]
end
 
if namexo == ' ' then
   model('name exo')=name_exo_eq
else
   model('name exo')=[stripblanks(namexo) ; name_exo_eq]
end
 
if namresid == ' ' then
   model('name resid')=name_resid_eq
else
   model('name resid')=[stripblanks(namresid) ; name_resid_eq]
end
 
coeffs=tlist(['coeffs';model('name coeff')])
for i=1:size(model('name coeff'),1)
   coeffs(i+1)=[]
end
model('coeffs')=coeffs
 
params=tlist(['params';model('name param')])
for i=1:size(model('name param'),1)
   params(i+1)=[]
end
model('params')=params
 
model=model_transf(model,varargin(:))
 
endfunction
