function [] = imp_panel(mat,fileout,savevar)
 
// PURPOSE: importation of a panel data matrix
// ------------------------------------------------------------
// INPUT:
// * mat = a string matrix
// * sep = separator used in the filein (between quotes)
// * fileout = name of the scilab file where to save the
// imported data (between quotes)
// ------------------------------------------------------------
// OUTPUT: nothing; the imported series are saved in the file
// named fileout
// ------------------------------------------------------------
// NOTES:
// * if one data is named dates or DATES (scilab distinguish
// capitals from small letters) then the following data are
// saved as timeseries
// * if a value is lacking or #N/A in a timeseries, it is given
// a NA value
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
sepfile=[strindex(fileout,'/') strindex(fileout,'\')]
indnamefile=max(sepfile)
namepanel=part(fileout,indnamefile+1:length(fileout))
inddot=strindex(namepanel,'.')
namepanel=part(namepanel,1:inddot-1)
namepanel=strsubst(namepanel,' ','_')
 
names=mat(:,1)
fd=find(names == 'dates')
if size(fd,1) > 1 then
   error('in a panel data you should have only one vector of dates')
end
dat=mat(fd,2:$)'
 
fi=find(names == 'id')
if size(fi,1) > 1 then
   error('in a panel data you should have only one vector of individuals')
end
 
id=mat(fi,2:$)'
name_indiv=unique(id)
id_number=%t
for i=1:size(name_indiv,1)
   if or(ascii(name_indiv(i)) < 46) | or(ascii(name_indiv(i)) >57) then
      id_number=%f
   end
end
 
if id_number then
   name_indiv='individual # '+string(name_indiv)
end
 
mat(:,1)=[]
mat([fi fd],:) = []
names([fi fd]) = []
 
panel=tlist(['panel data';'dates';'id';'x';'nameid';'namex'],...
dat,id,evstr(mat)',name_indiv,names)
execstr(namepanel+'=panel')
grocer_content=namepanel
savevar=savevar+','''+namepanel+''',''grocer_content'')'
execstr(savevar)
 
endfunction
 
