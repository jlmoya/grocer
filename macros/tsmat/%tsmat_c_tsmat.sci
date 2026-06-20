function tsmat=%tsmat_c_tsmat(tsmat1,tsmat2)
 
// PURPOSE: operates the concatenation of 2 tsmat, the resulting
// tsmat colelcting the variables of both tsmats on the union
// their time periods, with %nan for the period for which each
// tsmat has not been defined
// ------------------------------------------------------------
// INPUT:
// * tsmat1 = a tlist of type tsmat
// * tsmat2 = a tlist of type tsmat
// ------------------------------------------------------------
// OUTPUT:
// * tsmat1 = the concatenation of 2 tsmat
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux 2008-2018
// http://grocer.toolbox.free.fr/grocer.html
 
freq1=tsmat1('freq');
freq2=tsmat2('freq')
if sum(abs(freq1-freq2)) ~= 0 then
   error('frequency of first tsmat ('+string(freq1)+') is different from the frequency of second tsmat ('+string(freq2)+')')
end
 
freq1=tsmat1('freq');
freq2=tsmat2('freq')
if sum(abs(freq1-freq2)) ~= 0 then
   error('frequency of first tsmat ('+string(freq1)+') is different from the frequency of second tsmat ('+string(freq2)+')')
end
dat1=tsmat1('dates');
dat2=tsmat2('dates');
 
mind=min(dat1(1),dat2(1))
maxd=max(dat1($),dat2($))
 
names1=tsmat1('names');
n_names1=size(names1,1)
names2=tsmat2('names');
 
names=[names1 ; names2]
[namesd,ind_n]=unique(names)
n_names=size(namesd,1)
 
if n_names > n_names1 then
 
   ser=%nan*ones(maxd-mind+1,n_names)
   ser1=tsmat1('series');
   ser2=tsmat2('series');
   ser(dat1-mind+1,1:n_names1)=ser1
   ind_names2=gsort(ind_n(ind_n>n_names1),'g','i')
   ser(dat2-mind+1,n_names1+1:n_names)=ser2(:,ind_names2-n_names1)
 
   tsmat=tlist(['tsmat';'freq';'dates';'series';'names'],freq1,[mind:maxd]',...
         ser,[names1 ; names2(ind_names2-n_names1)]);
end
 
 
if or(tsmat1(1) == 'comments') then
   tsmat1('comments')=emptystr(size(tsmat1('names'),1),1)
end
 
endfunction
