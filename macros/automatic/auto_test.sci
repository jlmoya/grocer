function [test_func,name_test,nvarmax]=auto_test(auto_names,auto_ltest,nobs,nvar,test_default)
 
// PURPOSE: from the specifications list given by the user,
// build the function which performs these specification tests
// and their corresponding names
// ------------------------------------------------------------
// INPUT:
// * auto_names = the tlist that associates a name to each
//   specification test function
// * auto_ltest = the list of options provided by the user
//   (default: an empty list)
// * nobs = # of observations
// ------------------------------------------------------------
// OUTPUT:
// * test_func = the function which gathers the specification
//   tests used by automatic()
// * name_test = the name of the specification tests which will
//   be used for the printings
// ------------------------------------------------------------
// NOTES: used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2014
// http://grocer.toolbox.free.fr/grocer.html
 
names_ini=auto_names(1)(2:$)
name_test=['test']
if length(auto_ltest) == 0 then
   // set default function
   test_func=test_default
   if test_default == test_spec0 then
      n1=round(0.5*nobs)
      n2=round(0.9*nobs)
      nvarmax=min(floor(0.5*nobs),nobs-nvar)
      name_test=[name_test ;...
        'Chow pred. fail. (50%)';...
        'Chow pred. fail. (90%)' ; ...
        'Doornik & Hansen' ;'AR(1-4)' ; 'hetero x_squared']
   elseif test_func == test_varspec0 then
      name_test=[name_test ;...
        'Doornik & Hansen' ;'AR(1-4)' ; 'hetero x_squared']
 
   end
else
   nvarmax=nobs
   auto_ltest=strsubst(auto_ltest,' ','')
   auto_ltest=strsubst(auto_ltest,'[','')
   auto_ltest=strsubst(auto_ltest,']','')
   chfunc='deff(''[val,p]=test_func(r)'',['
   ind1=[0 strindex(auto_ltest,',')]+1
   ind2=[strindex(auto_ltest,',') length(auto_ltest)+1]-1
   nbtest=size(ind1,2)
   chfunc=chfunc+'''val=ones('+string(nbtest)+',1)'','
   chfunc=chfunc+'''p=ones('+string(nbtest)+',1)'',''i=0'','
 
   for i=1:nbtest
      testi=part(auto_ltest,[ind1(i):ind2(i)])
 
      parleft0=strindex(testi,'(')
// determine the index of left and right parentheses
      if parleft0 == [] then
         testi=testi+'()'
         supname=''
      end
      parleft=strindex(testi,'(')
      parright=strindex(testi,')')
      if size(parright,2) ~= 1 then
         error('wrong test: '+testi)
      end
      n=part(testi,parleft+1:parright-1)
// store the name given by the user
      nametesti=part(testi,1:parleft-1)
// check if the given name is the name of an allowed test
      if and(names_ini ~= nametesti) then
         error(nametesti+' is not an available test')
      end
 
      if part(testi,[1:8]) == 'chowtest' |...
        part(testi,[1:10]) == 'predfailin'  then
         truen=string(round(evstr(n)*nobs))
         n=string(100*evstr(n))
// replace the proportion given by the user by the
// corresponding # of observations and add a 0 to
// the function whose quick call is defined by a 0
         testi=nametesti+'0('+truen+part(testi,parright:length(testi))
         nvarmax=min(nvarmax,floor(0.5*nobs))
      end
      if part(testi,[1:9]) == 'doornhans' |...
        part(testi,[1:6]) == 'jbnorm' then
         testi=strsubst(testi,'(','0(')
         nvarmax=min(nvarmax,nobs-3)
      elseif part(testi,[1:4]) == 'arlm' then
         testi=strsubst(testi,'(','0(')
         execstr('nar='+part(testi,7:strindex(testi,')')-1))
         nvarmax=min(nvarmax,nobs-nar-1)
      elseif part(testi,[1:4]) == 'arch' then
         testi=strsubst(testi,'(','z0(')
         execstr('nar='+part(testi,8:strindex(testi,')')-1))
         nvarmax=min(nvarmax,nobs-nar-1)
      elseif part(testi,[1:9]) == 'hetero_sq' then
         testi=strsubst(testi,'(','0_a(')
         nvarmax=min(nvarmax,nobs-nvar-1)
      elseif part(testi,[1:5]) == 'reset' then
         testi=strsubst(testi,'(','0(')
         if testi == 'reset0()' then
            testi='reset0(2)'
         end
         nvarmax=min(nvarmax,nobs-nvar-1)
      end
      testi=strsubst(testi,'(','(r,')
      testi=strsubst(testi,')',',''''noprint'''')''')
      if parleft0 ~= [] then
         if part(testi,[1:8]) == 'chowtest' |...
          part(testi,[1:10]) == 'predfailin'  then
             supname='('+n+'%)'
         else
            supname='('+n+')'
         end
      end
      chfunc=chfunc+'''[vali,pi]='+testi+',''i=i+1'',''val(i)=vali'',''p(i)=pi'','
      name_test=[name_test ; auto_names(nametesti)+supname]
   end
   chfunc=strsubst(chfunc,',,',',')
// for tests such as jbnorm who has no other argument than
// r and 'noprint' there are 2 consecutive ,
   chfunc=part(chfunc,[1:length(chfunc)-1])+'])'
   execstr(chfunc)
end
 
endfunction
