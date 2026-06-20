function prtunitr(res,out)
 
// PURPOSE: prints the results of unit root tests on the file
// out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
meth=res('meth')
if nargin == 1 then
   out=%io(2)
end
 
if part(convstr(getversion()),1:9) == 'scilab-5.' then
   matspec=[' ' ' ']
else
   matspec=' '
end
 
 
if meth == 'ers' then
 
   prtuniv(res,out)
 
   write(out,' ')
   write(out,'............................................')
   p=res('test p-value')
   matspec(1)='* approximate p-value for ERS test is: '+string(p)
   write(out,'* approximate p-value for ERS test is: '+string(p))
   write(out,' ')
   txt='conclusion: the null hypothesis of non stationarity is '
   if p < 0.01 then
      write(out,txt+'rejected even at a 1% level')
   elseif p < 0.05 then
      write(out,txt+'accepted at a 1% level, but rejected at a 5% level')
   elseif p < 0.1 then
      write(out,txt+'accepted at a 5% level, but rejected at a 10% level')
   else
       write(out,txt+'accepted at even a 10% level')
   end
   write(out,' ')
   format(10)
   return
end
 
if meth == 'olsecm' then
 
   write(out,' ')
   write(out,'............................................')
   p=res('test p-value')
   cr=res('test crit. value')
   deter = res('deterministic')
   select deter
   case -1 then
     sd = 'no determnistic part';
   case 0 then
     sd = 'constant';
   case 1 then
     sd ='constant plus time-trend';
   case 2 then
     sd ='constant plus quadratic time-trend';
   end
   write(out,'Type of determistic part in the cointegrating vector: '+sd)
   if typeof(cr)=='string' then
      scr=cr;sp=p;
      p=evstr(part(p,3:length(p)));
   else
      scr=string(cr);sp=string(p);
   end
   write(out,'Ericsson-MacKinnon critical value for ECM test is: '+scr)
   write(out,'(*) approximate p-value for ECM test is: '+sp)
   write(out,' ')
   txt='conclusion: the null hypothesis of no-cointegration is '
 
   if p < 0.01 then
      write(out,txt+'rejected at a 1% level')
   elseif p < 0.05 then
      write(out,txt+'accepted at a 1% level, but rejected at a 5% level')
   elseif p < 0.1 then
      write(out,txt+'accepted at a 5% level, but rejected at a 10% level')
   else
       write(out,txt+'accepted even at a 10% level')
   end
   write(out,' ')
   format(10)
end
 
if or(meth == ['ADF' 'cadf' 'kpss' 'phillips-perron' 'Schmidt-Phillips']) then
 
if meth  == 'ADF' then
    crit1=[res('1% level') res('5% level') res('10% level') ]
    testv1=res('tstat')(1)-crit1
    test0='a unit root'
    prtuniv(res,out)
    write(out,' ')
    write(out,'............................................')
    matspec(1)='(*) t-value for variable '+res('namex')(1)+...
          ' should be compared to the following values:'
    write(out,matspec)
    mat2print =['1% level' '5% level' '10% level' ; string(round(crit1*1000)/1000)]
 
elseif meth == 'cadf' then
 
    crit1=[res('1% level') res('5% level') res('10% level') ]
    testv1=res('tstat')(1)-crit1
    test0='no cointegration'
    prtuniv(res,out)
    write(out,' ')
    write(%io(2),'* t-value for variable '+res('namex')(1)+': '+string(rescadf('tstat')(1)))
    write(%io(2),'should be compared to the following values:')
    mat2print =['1% level' '5% level' '10% level' ; string(crit1)]
 
elseif meth == 'kpss' then
 
    crit1=[res('1% level') res('5% level') res('10% level') ]
    testv1=crit1-res('test_value')
    test0='stationarity'
    write(out,' ')
    write(out,'KPSS stationarity test for variable: '+res('namey'))
    select res('p')
    case 0 then
      write(out,'with a constant term')
    case 1 then
      write(out,'with a time term')
    end
    if prests then
      ch='and estimation period: '
      for i=1:size(boundsvarb,1)/2
         ch=ch+boundsvarb(2*i-1)+'-'+boundsvarb(2*i)+'  '
      end
      write(out,ch)
    end
 
    write(out,'is equal to: '+string(res('test_value')))
    write(out,'this values should be compared to the following critical values:')
    mat2print =['1% level' '5% level' '10% level' ; string(crit1)]
 
  elseif or(meth == ['phillips-perron' 'Schmidt-Phillips']) then
    crit1=[res('cv_rho_1%') res('cv_rho_5%') res('cv_rho_10%') ]
    testv1=res('rho')-crit1
    test0='a unit root'
    write(out,' ')
    write(out,meth+' unit root test for variable: '+res('namey'))
    select res('p')
    case 0 then
      write(out,'with a constant term')
    else
      write(out,'with a time term of order '+string(res('p')))
    end
    if prests then
      ch='and estimation period: '
      for i=1:size(boundsvarb,1)/2
         ch=ch+boundsvarb(2*i-1)+'-'+boundsvarb(2*i)+'  '
      end
      write(out,ch)
    end
    mat2print =['1% level' '5% level' '10% level' ; string(crit1)]
    write(out,'rho test is equal to: '+string(res('rho')))
    write(out,' ')
    write(out,'this values should be compared to the following critical values:')
 
  end
 
  printmat(mat2print,out)
  write(out,' ')
 
  if testv1(1) < 0 then
     write(out,'conclusion: the null hypothesis of '+test0+' is rejected even at a 1% level')
  elseif testv1(2) < 0 then
     write(out,'conclusion: the null hypothesis of '+test0+' is accepted at a 1% level, but rejected at a 5% level')
  elseif testv1(3) < 0 then
     write(out,'conclusion: the null hypothesis of '+test0+' is accepted at a 5% level, but rejected at a 10% level')
  else
     write(out,'conclusion: the null hypothesis of '+test0+' is accepted even at a 10% level')
  end
 
end
 
 
if meth == 'schmiphi' | meth == 'phillips-perron' then
   crit2=[res('cv_tstat_1%') res('cv_tstat_5%') res('cv_tstat_10%') ]
   testv2=res('tstat')-crit2
   write(out,' ')
   write(out,'tstat test is equal to: '+string(res('tstat')))
   write(out,' ')
   write(out,'this values should be compared to the following critical values:')
   mat2print =['1% level' '5% level' '10% level' ; string(crit2)]
   printmat(mat2print,out)
   write(out,' ')
 
   if testv2(1) < 0 then
      write(out,'conclusion: the null hypothesis of '+test0+' is rejected at even a 1% level')
   elseif testv2(2) < 0 then
      write(out,'conclusion: the null hypothesis of '+test0+' is accepted at a 1% level, but rejected at a 5% level')
   elseif testv2(3) < 0 then
      write(out,'conclusion: the null hypothesis of '+test0+' is accepted at a 5% level, but rejected at a 10% level')
   else
      write(out,'conclusion: the null hypothesis of '+test0+' is accepted even at a 10% level')
   end
end
 
printsep(out)
endfunction
