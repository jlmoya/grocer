function num=date2num(dat,varargin)
 
// PURPOSE: return the numerical representation of a date
// ------------------------------------------------------------
// INPUT:
// * dat = a date string
// * varargin = 'w' if the date is given as a day date but
//   corresponds to a week
// ------------------------------------------------------------
// OUTPUT:
// num = the numerical representation of the dates
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2007
// http://grocer.toolbox.free.fr/grocer.html
 
num=date2num_fq(dat,varargin(:))
 
endfunction
