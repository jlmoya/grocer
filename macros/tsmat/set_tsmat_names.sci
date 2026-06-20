function set_tsmat_names(tsmat_names)
 
// PURPOSE: Change how names change after an operation
//    performed on a tsmat
// ------------------------------------------------------------
// INPUT:
// * opt = nothing, 'trace' or 'var'
//    . if nothing: load the default mode i.e. variable names
//       are not altered after each operation
//    . if 'trace': operations made on the data are contained in the names;
//      ex: a log transform on a tsmat with names x and y, will create a
//          tsmat with names log(x) and log(y)
//    . if 'reset': tsmat names are changed into 'var1',...,'varn'
//       after each operation
// ------------------------------------------------------------
// OUTPUT:
// * nothing, the corresponding functions are loaded
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux (2009)
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
 
if or(tsmat_names==['trace';'reset';'ini']) then
   save(GROCERDIR+'/param/tsmat_names.dat','tsmat_names')
else
   error('not an available option :'+tsmat_names)
end
 
endfunction
