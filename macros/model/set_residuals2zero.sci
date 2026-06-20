function db=set_residuals2zero(db,model)
 
// PURPOSE: in a tsmat associated to a model, set all residuals
// to 0 (useful for estimation purposes)
// ------------------------------------------------------------
// INPUT:
// * db = a tsmat
// * model = a model tlist
// ------------------------------------------------------------
// OUTPUT:
// * db = the original tsmat where all series corresponding to
//   a residuals in the input model are set to 0
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
name_resid=model('name resid')
ser=db('series')
ind_resid=[]
for i=1:size(name_resid,1)
   ind_resid=[ind_resid , find(db('names') == name_resid(i))]
end
ser(:,ind_resid)=0
db('series')=ser
 
endfunction
