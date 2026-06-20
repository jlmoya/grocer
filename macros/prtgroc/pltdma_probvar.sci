function pltdma_probvar(res,vari)
 
// PURPOSE: plots the probability that a variable belongs to a
// model and the expected coefficient of this variable
// ------------------------------------------------------------
// INPUT:
// * res = the results typed tlist from a DMA estimation
// * vari = a string, the name of the variable between quotes
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are plotted on a news graphing window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
probvar=res('vars proba');
namey=res('namey');
variable_namex=res('variable namex');
fixed_namex=res('fixed namex');
nfixed=size(fixed_namex,1)
namex=[fixed_namex ;variable_namex]
vars_proba=res('vars proba');
expected_coeff=res('exp theta');
 
if vari =='all' then
   ind_vars=1:size(fixed_namex,1)+size(variable_namex,1)
else
   nvari=size(vari,'*')
   ind_vars=zeros(nvari,1)
   for i=1:nvari
       ind_vars_i=find(vari(i) == namex );
       if isempty(ind_vars_i) then
          error('not a variable in the model: '+vari(i))
       else
          ind_vars(i)=ind_vars_i
       end
 
   end
end
 
if res('prests') then
   boundsres=res('bounds')
   dn=date2num_m(boundsres)
   dscale=[]
   for i=1:size(dn,1)/2
      dscale=[dscale dn(2*i-1):dn(2*i)]
   end
   xscaleres=num2date(dscale,date2fq(boundsres(1)))
else
   xscaleres=string(1:size(res('y'),1))
end
 
for i=ind_vars
   scf()
   impact_vari=expected_coeff(:,i)
   if i <= nfixed then
      pltseries0(impact_vari,[],'estimated impact of '+namex(i),xscaleres,-1)
   else
      proba_vari=vars_proba(:,i-nfixed)
      pltseries0([proba_vari , impact_vari],[],'estimated probability and impact of '+namex(i),xscaleres,-1,...
                'leg=probabilty of inclusion (lhs);expected coefficient (rhs)','yaxis=[1 2]')
   end
end
 
endfunction
