function prtmod(model,fileout,maxlength)

namendo=model('name endo')
nendo=size(namendo,1)
txt=['model: '+model('namemod')]
if nendo > 0 then
   nlines_endo=ceil(nendo/5)
   matendo_prt=emptystr(nlines_endo,1)
   for j=1:nlines_endo-1
      matendo_prt(j)=strcat(namendo(1+(j-1)*5:5*j),' ')
   end
   matendo_prt(nlines_endo)=strcat(namendo(1+(nlines_endo-1)*5:nendo),' ')+' ;'
   txt=[txt ;...
        ' ';...
        'endogenous: ';...
        matendo_prt]
end

namexo=model('name exo')
nexo=size(namexo,1)
if nexo > 0 then
   nlines_exo=ceil(nexo/5)
   matexo_prt=emptystr(nlines_exo,1)
   for j=1:nlines_exo-1
      matexo_prt(j)=strcat(namexo(1+(j-1)*5:5*j),' ')
   end
   matexo_prt(nlines_exo)=strcat(namendo(1+(nlines_exo-1)*5:nexo),' ')+' ;'

   txt=[txt;...
        ' ';...
        'exogenous: ';...
        matexo_prt]
end

namresid=model('name resid')
nresid=size(namresid,1)
if nresid > 0 then
   nlines_resid=ceil(nresid/5)
   matresid_prt=emptystr(nlines_resid,1)
   for j=1:nlines_resid-1
      matresid_prt(j)=strcat(namresid(1+(j-1)*5:5*j),' ')
   end
   matresid_prt(nlines_resid)=strcat(namendo(1+(nlines_resid-1)*5:nresid),' ')+' ;'

   txt=[txt;...
        ' ';...
        'residuals: ';...
        matresid_prt]
end


namcoeff=model('name coeff')
ncoeff=size(namcoeff,1)
if ncoeff > 0 then
   nlines_coeff=ceil(ncoeff/5)
   matcoeff_prt=emptystr(nlines_coeff,1)
   for j=1:nlines_coeff-1
      matcoeff_prt(j)=strcat(namcoeff(1+(j-1)*5:5*j),' ')
   end
   matcoeff_prt(nlines_coeff)=strcat(namendo(1+(nlines_coeff-1)*5:ncoeff),' ')+' ;'

   txt=[txt;...
        ' ';...
        'coefficients: ';...
        matcoeff_prt]
end

namparam=model('name param')
nparam=size(namparam,1)
if nparam > 0 then
   nlines_param=ceil(nparam/5)
   matparam_prt=emptystr(nlines_param,1)
   for j=1:nlines_param-1
      matparam_prt(j)=strcat(namparam(1+(j-1)*5:5*j),' ')
   end
   matparam_prt(nlines_param)=strcat(namendo(1+(nlines_param-1)*5:nparam),' ')+' ;'

   txt=[txt;...
        ' ';...
        'parameteres: ';...
        matparam_prt]
end

nameqs=model('name eq')
eqs=model('equations')
neq=size(nameqs,1)

for i=1:neq
   eqi=nameqs(i)+': '+eqs(i)
   l_eqi=length(eqi)
   while l_eqi > maxlength then
      l1=part(eqi,l_eqi:maxlength)
      ind_hat=strindex(eqi,'^')
      ind_star=strindex(eqi,'*')
      ind_slash=strindex(eqi,'/')
      ind_plus=strindex(eqi,'+')
      ind_minus=strindex(eqi,'-')
      ind_all=[ind_hat,ind_star,ind_slash,ind_plus,ind_minus]
      ind_end=max(ind_all)
      txt=[txt ; part(eqi,1:ind_end-1)]
      eqi=part(eqi,ind_end:l_eqi)
      l_eqi=length(eqi)
   end
   txt=[txt ; eqi+';']
end

if typeof(fileout) == 'string' then
   mputl(txt,fileout)
elseif fileout == %io(2) then
   write(%io(2),txt)
end
    
endfunction
