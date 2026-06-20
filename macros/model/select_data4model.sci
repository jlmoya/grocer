function list_names=select_data4model(list_db,model)
 
// PURPOSE: in a database, find the names of the variables
// that are used in a model
// ------------------------------------------------------------
// INPUT:
// * db = a string, the .dat file of a database or a string
//   vector
// * model = a model tlist
// ------------------------------------------------------------
// OUTPUT:
// * list_names = a string vector, collecting the names of the
// variables of the database that are used in the model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
list_db=list_db(:)
if size(list_db,1) == 1 & part(list_db,length(list_db)+[-3:0]) == '.dat' then
   list_db=dblist(list_db)
end
list_exo=model('name exo')
list_endo=model('name endo')
list_resid=model('name resid')
 
list_vari=[list_endo ; list_exo]
n_vari=size(list_vari,1)
n_db=size(list_db,1)
 
if n_vari > n_db then
   list_names = list_db
   list_searched = list_vari
else
   list_names = list_vari
   list_searched = list_db
end
 
for i=size(list_names,1):-1:1
   ind_names=find(list_searched == list_names(i))
   if isempty(ind_names) then
      list_names(i)=[]
   end
end
write(%io(2),'n_outp: '+string(size(list_names,'*')),'(a)')
 
 
endfunction
