function [t]=studentize(x)
 
// PURPOSE: If x is a vector, substract its mean and divide
//          by its standard deviation. If x is a matrix,
//          do the above for each column.
//---------------------------------------------------
// USAGE:   out = studentize(x)
// where:     x = a vector or matrix
//---------------------------------------------------
// RETURNS:
//          out = transformed matrix
// --------------------------------------------------
// Copyright Eric Dubois & Emmanuel Michaux 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// Kurt.Hornik@ci.tuwien.ac.at
// Dept of Probability Theory and Statistics TU Wien
 
global GROCERDIR;
 
select typeof(x)
 
case 'ts' then
   xs=x('series')
   t=x
   std=stdev(xs)
   if std ==0 then
      t('series') = zeros(nobs,1);
   else
      t('series') = (xs-mean0(xs))/std
   end
 
case 'tsmat' then
   xs=x('series')
   [nobs,nvar] = size(xs)
   t=x
   std=stdev(xs,1)
   for i=1:nvar
      if std(:,i)==0 then
        t('series')(:,i) = zeros(nobs,1);
      else
        t('series')(:,i) = (xs(:,i)-mean0(xs(:,i)))./std(i)
      end
   end
 
   load(GROCERDIR+'/param/tsmat_names.dat')
   select tsmat_names
 
   case 'reset' then
      t('names')='var'+string([1:size(tsmat('series'),2)]')
 
   case 'trace' then
      t('names')='stud. '+t('names')
 
   end
 
case 'constant' then
   [nobs,nvar] = size(x)
 
   if nvar==1 then
      if stdev(x)==0 then
         t = zeros(nobs,1);
      else
         t = (x-mean0(x))/stdev(x);
      end
   elseif nvar>1 then
      t=ones(nobs,nvar)
      for i=1:nvar
         if stdev(x(:,i))==0 then
            t(:,i) = zeros(nobs,1);
         else
            t(:,i) = (x(:,i)-mean0(x(:,i)))./stdev(x(:,i))
         end
      end
   end
 
else
  error('studentize:  x must be a vector, a matrix or a ts');
end
 
endfunction
 
