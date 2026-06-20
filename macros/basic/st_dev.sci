function sd=st_dev(x,cr)
 
// PURPOSE: calculate the standard deviation of a vector,
// a timeseries or a tlist in tsmat format<<
// ------------------------------------------------------------
// INPUT:
// x = a vector of a time series
// cr = orientation
// ------------------------------------------------------------
// OUTPUT:
// sd = the vector of the time series values
// ------------------------------------------------------------
// Copyright Inria/Enpc
// Philippe.Castagliola Ecole des Mines de Nantes
// Eric Dubois 2002 for the part regarding time series
// http://grocer.toolbox.free.fr/grocer.html
// Emmanuel Michaux 2002 for the part regarding tsmat
 
[argout,argin]=argn(0);
 
if (argin<1)|(argin>2)
  error('incorrect number of arguments');
end
 
if typeof(x) == 'ts' then
 
   s=x('series')
   sd=sqrt((s-mean0(s))'*(s-mean0(s))/(size(s,1)-1))
 
elseif typeof(x) == 'tsmat' then
 
   sd=x
   x=x('series')
   [m n]=size(x)
   if argin==1
      sd=sqrt(sum((x-mean0(x)).^2)/(m*n-1));
   elseif cr=='c'|cr==2
      sd('series') =sqrt(sum((x-mean0(x,'c')*ones(x(1,:))).^2,'c')/(n-1));
      nam='var '+string(1:size(sd('series'),2))
      sd('names')=nam'
      sd(1)(1) ='ts'
   elseif cr=='r'|cr==1
      sd=sqrt(sum((x-ones(x(:,1))*mean0(x,'r')).^2,'r')/(m-1));
   else
      error('2nd argument cr must be equal to ''c'' or 2, ''r''or  1');
   end
 
else
   if x  == [] then sd=%nan;return ;end
 
   [m n]=size(x);
   if argin==1
      sd=sqrt(sum((x-mean0(x)).^2)/(m*n-1));
   elseif cr=='c'|cr==2
      sd=sqrt(sum((x-mean0(x,'c')*ones(x(1,:))).^2,'c')/(n-1));
   elseif cr=='r'|cr==1
      sd=sqrt(sum((x-ones(x(:,1))*mean0(x,'r')).^2,'r')/(m-1));
   else
      error('2nd argument cr must be equal to ''c'' or 2, ''r''or  1');
   end
end
 
endfunction
 
