function [grocer_namexos,grocer_listts,grocer_vect,grocer_indts,grocer_indvec,grocer_indcte,grocer_nvar,grocer_listtsmat,grocer_indtsmat,grocer_comments]=explovars(grocer_names,grocer_defname)
 
// PURPOSE: from a list of series retrieve their names
// or give them names if they don't have (when an
// element is not string), store the ts in a list, store the
// values of the vectors and matrices in a unique matrix, store
// the index of the ts, the index of the vectors and the index
// of the 'cte' or 'const' string
// ------------------------------------------------------------
// INPUT:
// * grocer_names = either
//   - a list of variables
//   each element could be a timeseries, a matrix of ts (object
//   of type 'tsmat', a real vector, a real matrix or  a string
//   (the name of a variable with one of the types cited above,
//    between quotes)
//   - a matrix of strings, each one being the name of a
//   variable
//   - the string 'cte' or 'const' or 'trend^p'
// * grocer_defname = a string indicating the prefix used by
//   default to name the variables (default = 'endogenous')
// ------------------------------------------------------------
// OUTPUT:
// * grocer_namexos = a (k x 1) string vector
// * grocer_listts = a list of ts
// * grocer_vect = a (n x k) matrix of real values
// * grocer_indts = a (k1 x 1) vector of integers that indicates
//   the indexes of the ts in the original list
// * grocer_indvec = a (k2 x 1) vector of integers that indicates
//   the indexes of the real vectors in the original list
// * grocer_indcte = a (k3 x 1) vector of integers that indicates
//   the indexes of the terms 'cte' or 'const' in the original
//   list
// * grocer_nvar = # of variables in the list
// * grocer_listtsmat = a list of tsmat
// * grocer_indtsmat = a (k4 x 1) vector of integers that
//   indicates the indexes of the tsmat in the original list
// * grocer_comments = either an empty matrix or a (k x 1) 
//   string vector, collecting the comments in ts and tsmat
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
[grocer_nargout,grocer_nargin] = argn(0)
 
if grocer_nargin == 1 then
   grocer_defname='endogenous'
end
 
// intialize output
grocer_namexos=[]
grocer_comments=[]
grocer_listts=list()
grocer_listtsmat=list()
grocer_indtsmat=list()
grocer_indts=[]
grocer_indtsmat=[]
grocer_indvec=[]
grocer_indcte=[]
grocer_vect=[]
 
grocer_nvar=0
grocer_ndefname=0
 
// put all elements in a list if input is not a list
if is_empty(grocer_names) then
   return
end
 
select typeof(grocer_names)
case 'list' then
 
   grocer_nelem = length(grocer_names)
 
case 'string' then
   grocer_nelem = size(grocer_names,'*')
   if size(grocer_names,'*') == 1 then
      [grocer_cond,grocer_noncond]=cond_varspec('grocer_names')
      if and(evstr(grocer_noncond)) then
         if typeof(evstr(grocer_names)) == 'string' then
            grocer_names=evstr(grocer_names)
         end
      end
      grocer_nelem = size(grocer_names,'*')
   end
 
case 'tsmat' then
 
   grocer_namexos=grocer_names('names')
   grocer_listtsmat=list(grocer_names)
   grocer_nvar=size(grocer_namexos,1)
   grocer_indtsmat=[1:grocer_nvar]'
   return
 
else
   grocer_names = list(grocer_names)
   grocer_nelem =1
end

for grocer_i=1:grocer_nelem
   grocer_namei=grocer_names(grocer_i)
   grocer_t=typeof(grocer_namei)
 
   select grocer_t
 
   case 'string' then
// the entry can be the name of a ts, a vector, a matrix or a special character
      grocer_nvari=size(grocer_namei,'*')
      for grocer_j = 1:grocer_nvari
         grocer_namexosj=grocer_namei(grocer_j)
         str6=part(grocer_namexosj,1:6)
         str4=part(grocer_namexosj,1:5)
         [grocer_cond,grocer_noncond]=cond_varspec('grocer_namexosj')

         if ~exists(strsubst(grocer_namexosj,'trend','trend^1')) & or(evstr(grocer_cond)) then
            grocer_nvar=grocer_nvar+1
            grocer_indcte=[grocer_indcte ; grocer_nvar]
            grocer_namexos=[grocer_namexos ; grocer_namexosj]

         else
            grocer_varexosj=evstr(grocer_namexosj)

            select(typeof(grocer_varexosj))
 
            case 'ts' then
               grocer_nvar=grocer_nvar+1
               if or(grocer_varexosj(1) == 'comment') then
                  grocer_comments=[grocer_comments ; emptystr(size(grocer_namexos,1)-size(grocer_comments,1),1) ;...
                                   grocer_varexosj('comment')]
               end
               grocer_namexos=[grocer_namexos ; grocer_namexosj]
               grocer_indts=[grocer_indts ; grocer_nvar]
               grocer_listts($+1)=grocer_varexosj
 
            case 'tsmat' then
 
                grocer_nam=grocer_varexosj('names')
                if or(grocer_varexosj(1) == 'comment') then
                   grocer_comments=[grocer_comments ; emptystr(size(grocer_namexos,1)-size(grocer_comments,1),1) ;...
                                   grocer_varexosj('comment')]
                end
                grocer_nvari=size(grocer_nam,1)
                grocer_indtsmat=[grocer_indtsmat;grocer_nvar+[1:grocer_nvari]']
                grocer_listtsmat($+1)=grocer_varexosj
                grocer_nvar=grocer_nvar+grocer_nvari
                grocer_namexos=[grocer_namexos ; grocer_namexosj+':'+grocer_varexosj('names')]
 
            case 'constant' then
               grocer_nplus=size(grocer_varexosj,2)
               if grocer_nplus == 1 then
                  grocer_namexos=[grocer_namexos ; grocer_namexosj]
               else
                  grocer_namexos=[grocer_namexos ; grocer_namexosj+'_'+string([1:grocer_nplus]')]
               end
               grocer_indvec=[grocer_indvec ; grocer_nvar+[1:grocer_nplus]']
               grocer_vect=[grocer_vect  grocer_varexosj]
               grocer_nvar=grocer_nvar+grocer_nplus
 
            else
               write(%io(2),'error: '+typeof(grocer_namexosj)+' is not allowed as a name of the variable:')
               write(%io(2),grocer_namexosj)
               abort
            end
         end
      end
 
   case 'tsmat' then
 
      grocer_nam=grocer_namei('names')
      grocer_nvari=size(grocer_nam,1)
      grocer_indtsmat=[grocer_indtsmat;grocer_nvar+[1:grocer_nvari]']
      grocer_listtsmat($+1)=grocer_namei
      grocer_nvar=grocer_nvar+grocer_nvari
      if or(grocer_namei(1) == 'comment') then
         grocer_comments=[grocer_comments ; emptystr(size(grocer_namexos,1)-size(grocer_comments,1),1) ;...
                          grocer_namei('comment')]
      end
      grocer_namexos=[grocer_namexos ; grocer_nam]
 
   case 'ts' then
      grocer_nvar=grocer_nvar+1
      grocer_ndefname=grocer_ndefname+1
      grocer_indts=[grocer_indts ; grocer_nvar]
      grocer_listts($+1)=grocer_namei
      if or(grocer_namei(1) == 'comment') then
         grocer_comments=[grocer_comments ; emptystr(size(grocer_namexos,1)-size(grocer_comments,1),1) ;...
                          grocer_namei('comment')]
      end
      grocer_namexos=[grocer_namexos ; grocer_defname+' # '+string(grocer_ndefname)]
 
   case 'constant' then
      grocer_nplus=size(grocer_namei,2)
      grocer_namexos=[grocer_namexos ; grocer_defname+' # '+string(grocer_ndefname+[1:grocer_nplus]')]
      grocer_indvec=[grocer_indvec ; grocer_nvar+[1:grocer_nplus]']
      grocer_vect=[grocer_vect grocer_namei]
      grocer_nvar=grocer_nvar+grocer_nplus
      grocer_ndefname=grocer_ndefname+grocer_nplus

   case 'boolean' then
      grocer_nplus=size(grocer_namei,2)
      grocer_namexos=[grocer_namexos ; grocer_defname+' # '+string(grocer_ndefname+[1:grocer_nplus]')]
      grocer_indvec=[grocer_indvec ; grocer_nvar+[1:grocer_nplus]']
      grocer_vect=[grocer_vect bool2s(grocer_namei)]
      grocer_nvar=grocer_nvar+grocer_nplus
      grocer_ndefname=grocer_ndefname+grocer_nplus
 
   else
      error(grocer_t+' is an invalid type for entry in explovars')
   end
 
end
 
if grocer_ndefname == 1 then
   grocer_namexos=strsubst(grocer_namexos,grocer_defname+' # 1',grocer_defname)
end
grocer_namexos=strsubst(grocer_namexos,'trend^1','trend')
 
endfunction
 
