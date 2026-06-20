function prtgmm(res,out)
 
// PURPOSE: Prints output using GMM res structure
//---------------------------------------------------
// INPUTS:
// . res = a tlist returned by GMM
//---------------------------------------------------
//  OUPUTS: nothing, just prints the regression res
//---------------------------------------------------
// VERSION: 1.1.9 (7/11//02)
// written by:
// Mike Cliff, Purdue Finance  mcliff@mgmt.purdue.edu
// CREATED: 12/9/98
// UPDATED: 11/1/99  (1.1.2 Max # minz iterations)
//	   5/4/00   (1.1.3 fixed fid as arg to mprint1)
//          7/12/00  (1.1.4 Fixed Max # minz iterations)
//          8/8/00   (1.1.5 Label assoc w/ W0)
//          9/23/00  (1.1.6 gmmopt.W and fcnchk)
//          11/30/00 (1.1.7 tidy up sub-optimal W)
//          7/5/01   (1.1.8 label for optimal W)
//	   7/11/02  (1.1.9 minor label adj: hess, jake, S)
//
// Adapted from PRT_REG in Jim LeSage's Econometrics Toolbox
// Translated to scilab and arranged by E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
  out=%io(2)
end
 
meth=res('meth')
nobs = res('nobs');
north = res('north');
neq = res('neq');
k = res('nvar');
nz = res('nz');
namey =joinstr(res('namey'),',');
namex=joinstr(res('namex'),',');
nameivar=joinstr(res('nameivar'),',');
namep = res('namep');
 
 
// ATTENTION DONNER NOM A DERIVEE
if res('S type') == 'I' then
  stype='Identity';
elseif res('S type') == 'P' then
  stype='Plain';
elseif res('S type') == 'W' then
    stype='White';
elseif res('S type') =='H' then
//  if isfield(res,'wtvec')
  tr=or(allr=='wtvec')
  if ~tr then
    stype='User-defined weights to '+string(size(res('wtvec'),1))+' lags';
  else
    stype='Hansen ('+string(res('lags'))+' lags)';
  end
elseif res('S type')== 'NW' then
  stype='Newey-West ('+string(res('lags'))+' lags)';
elseif res('S type') == 'G' then
   stype='Gallant ('+string(res('lags'))+' lags)';
elseif res('S type') == 'AM' then
  if res('aminfo')('nowhite') == 1
    stype='Andrews (automatic bandwidth)';
  else
    stype='Andrews-Monahan (automatic bandwidth)';
  end
else
  stype = ['User''s']
end
//('+res('S')+')'];
 
if res('W0 type') =='Z' then
  W0type ='inv(Z''Z)';
elseif res('W0 type') =='I' then
  W0type='I';
elseif res('W0 type') =='Win' then
  W0type='Fixed';
elseif res('W0 type') == 'C' then
  W0type='Calc from b0';
else
  W0type=res('W0 type');
end
if res('gmmit') == 1 then
  Wtype = 'N/A';
else
  if res('W type') == 'S' then
    Wtype = 'Optimal';
  else
    Wtype = res('W type');
  end
end
 
 
write(out,'')
write(out,'   '+meth+' estimation results')
write(out,'''dependent'' variables: '+namey)
write(out,'''exogenous'' variables: '+namex)
write(out,'instruments: '+nameivar)
if res('prests') then
  ch='estimation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
       ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
      write(out,ch)
end
write(out,'number of observations: '+string(nobs));
write(out,string(k)+' parameters, '+string(north)+' moment conditions')
write(out,string(neq)+' equations model, '+string(nz)+' instruments')
write(out,'initial Weighting Matrix: '+W0type);
write(out,'weighting Matrix: '+Wtype);
write(out,'spectral Density Matrix: '+stype);
write(out,'');
 
write(out,'   Parameters estimates ')
write(out,'')		
tmp = string([res('beta') res('se') res('null') res('tstat') res('pvalue') ]);
cnames = ['Coeff','Std Err','Null','t-stat','p-val'];
 
[n1,n2]=size(namep)
if n2>n1 then
  namep=namep'
end
rnames = ['Parameters';namep];
m2p = [cnames;tmp];
m2p = [rnames,m2p];
printmat(m2p,out)
 
 
// Do This Stuff for Over-Identified Models
if  res('df') >= 1 then
  write(out,'')
  write(out,'   Moment conditions');
  write(out,'')		
  tmp2 = string([res('m') res('mse') res('m tstat') res('m pvalue')]);
  cnames2 = ['Moment','Std Err','t-stat','p-val'];
  Vnames2= [''];
  for vn = 1:north
    execstr('Vnames2 =[Vnames2;''Moment '+string(vn)+''']')
  end
  m2p = [cnames2;tmp2];
  m2p = [Vnames2,m2p];
  printmat(m2p,out)
  write(out,'')
  mprintf('      J-stat = %5.4f    Prob[Chi-sq.(%d) > J] = %5.4f\n',...
    res('J'),res('df'),res('pvalue'));
 
// Otherwise, Make Sure Moments to Zero
else
    write(out,'')
	  mprintf('  *** Moments <> 0 in Just-Identified Model.');
    mprintf('  J-stat = %10.8f ***\n',res('J'));
    mprintf('    Moments = ');
    mprintf('%6.4f ',res('m'));
    mprintf('\n  Check Convergence tolerances \n');
end
 
printsep(out)
endfunction
