function db=db4model(model)
 
// PURPOSE: create the database associated to a model, provided
// taht the corresponding variables exist in the environment
// ------------------------------------------------------------
// INPUT:
// * model = a model typed list created by the function
//   create_model
// ------------------------------------------------------------
// OUTPUT:
// * db = a tsmat containg the database associated to the model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
 
names=[model('name endo') ; model('name exo') ; model('name resid')]
bounds()
[y,namey,grocer_prests,grocer_b]=explone(names,[],'vari',%f,%f,%t)
 
[d1,fq]=date2num_fq(grocer_b(1))
d2=date2num_fq(grocer_b(2))
db=tlist(['tsmat';'freq';'dates';'series';'names'],fq,[d1:d2]',y,names)
 
endfunction
