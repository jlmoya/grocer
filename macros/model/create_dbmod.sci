function tsmat=create_dbmod(model,varargin)
 
// PURPOSE: create a database collecting the data corresponding
// to all variables in a model
// ------------------------------------------------------------
// INPUT:
// * model = a molde tlist
// * varargin = optional arguments collecting the names of the
//   databases to load (if the corresponding variables have not
//   been already loaded)
// ------------------------------------------------------------
// OUTPUT:
// * tsmat = the tsmat collecting the data corresponding
//   to all variables in a model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(model) ~= 'modelg' then
   error("first arg should be a modelg tlist")
end
 
nargin=length(varargin)
for argi = 1:nargin
    load(varargin(argi))
end
 
[y,namey,prests,b,nonna]=explone([model('name endo');model('name exo');...
model('name resid')],[],'var',%f,%f,%t)
tsmat=tlist(['tsmat';'freq';'dates';'series';'names'],...
date2fq(b(1)),[date2num(b(1)):date2num(b(2))]',y,namey)
 
endfunction
