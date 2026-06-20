function mat=ts2mat(grocer_bd)
 
// PURPOSE: export the content of a data base or a list of
// variables bd to a file that Excel can read
//-------------------------------------------------------------
// INPUT:
// * grocer_bd = the name of a database or of a list of ts
// loaded in the environment or a string vector representing
// names of ts
//-------------------------------------------------------------
// OUTPUT:
// * a real matrix (eventually with nas)
//-------------------------------------------------------------
// Copyright Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
select typeof(grocer_bd)
case 'string' then
   load(grocer_bd)
   grocer_bd=dblist(grocer_bd)
   grocer_nvar=size(grocer_bd,1)
case 'list' then
   grocer_nvar=length(grocer_bd)
else
   error(typeof(grocer_bd)+' is not an admissible type')
end
 
 
select typeof(grocer_bd(1))
case 'string' then
   grocer_x=evstr(grocer_bd(1))
   if typeof(grocer_x) ~= 'ts' then
      error(grocer_bd(1)+' is not a ts')
   end
case 'ts' then
   grocer_x=grocer_bd(1)
else
   error('not an admissible type: '+typeof(grocer_bd(1)))
end
 
grocer_fq=grocer_x('freq')
grocer_d=grocer_x('dates')
grocer_dmin=grocer_d(1)
grocer_dmax=grocer_d(size(grocer_d,1))
 
for grocer_i=2:grocer_nvar
   select typeof(grocer_bd(1))
   case 'string' then
      grocer_x=evstr(grocer_bd(grocer_i))
      if typeof(grocer_x) ~= 'ts' then
         execstr('error(''grocer_bd('+string(grocer_i)+') is not a ts'')')
      end
   case 'ts' then
      grocer_x=grocer_bd(grocer_i)
   else
      error('not an admissible type: '+typeof(grocer_bd(1)))
   end
 
   grocer_fq2=grocer_x('freq')
   if cumprod(grocer_fq2) ~= cumprod(grocer_fq) | grocer_fq2(1) ~= grocer_fq(1) then
      error('all ts have not the same frequency')
   end
   grocer_d=grocer_x('dates')
   grocer_dmin=min(grocer_d(1),grocer_dmin)
   grocer_dmax=max(grocer_d(size(grocer_d,1)),grocer_dmax)
end
 
mat=%nan*ones(grocer_dmax-grocer_dmin+1,grocer_nvar)
for grocer_i=1:grocer_nvar
   select typeof(grocer_bd(1))
   case 'string' then
      grocer_x=evstr(grocer_bd(grocer_i))
      if typeof(grocer_x) ~= 'ts' then
         execstr('error(''grocer_bd('+string(grocer_i)+') is not a ts'')')
      end
   case 'ts' then
      grocer_x=grocer_bd(grocer_i)
   end
   grocer_d=grocer_x('dates')
   mat(grocer_d(1)-grocer_dmin+1:...
      grocer_d(size(grocer_d,1))-grocer_dmin+1,grocer_i)=series(grocer_x)
end
endfunction
