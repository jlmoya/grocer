function define_recession(grocer_peak,grocer_trough)
 
// PURPOSE: define whether peaks and troughs belong to a
// recession phase
//---------------------------------------------------------
// INPUT:
// * grocer_peak  = 0 if a peak does not not belong to the
//   recession
// * grocer_trough  = 0 if a trough does not not belong to
//   the recession
//---------------------------------------------------------
// OUTPUT:
// nothing: data are saved in the database:
// SCI/data/define_recession.dat
//---------------------------------------------------------
// Copyright E. Dubois (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
save(GROCERDIR+'/data/define_recession.dat','grocer_peak','grocer_trough')
 
endfunction
 
