function [namepanel,panel] = imp_panel2(sival,sitxt,fileout,namedat)
 
// PURPOSE: importation of a panel data matrix from readxls2bd
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
// Copyright: Eric Dubois 2007-2018
// http://grocer.toolbox.free.fr/grocer.html
 
sepfile=[strindex(fileout,'/') strindex(fileout,'\')]
indnamefile=max(sepfile)
namepanel=part(fileout,indnamefile+1:length(fileout))
inddot=strindex(namepanel,'.')
namepanel=part(namepanel,1:inddot-1)
namepanel=strsubst(namepanel,' ','_')
 
[rid,cid]=find(convstr(sitxt) == 'id')
[rdat,cdat]=find(convstr(sitxt) == convstr(namedat))
 
if size(rdat,1) > 1 then
   error('in a panel data you should have only one vector of dates')
end
 
if size(rid,1) > 1 then
   error('in a panel data you should have only one vector of individuals')
end
 
nrows=size(sitxt,1)
if rid == nrows then
   // names in columns, data in rows
   sitxt=sitxt'
   sival=sival'
   rid0=rid
   rid=cid
   crid=rid0
   rdat0=rdat
   rdat=cdat
   crdat=rdat0
 
elseif ~isempty(sitxt(rid+1,cid)) then
   // names in columns, data in rows
   sitxt=sitxt'
   sival=sival'
   rid0=rid
   rid=cid
   crid=rid0
   rdat0=rdat
   rdat=cdat
   crdat=rdat0
 
end
 
    id=sival(rid+1:$,cid)
if or(isnan(id))
   isnan_id=isnan(id)
   id(isnan_id)=sitxt(isnan_id,cid)
   name_indiv=unique(id)
else
   indiv=unique(id)
   name_indiv='individual # '+string(indiv)
end
 
dat=sival(rdat+1:$,cdat)
if and(isnan(dat)) then
   dat=sitxt(rdat+1:$,cdat)
end
 
names=sitxt(rid,:)
names([cid cdat]) = []
sival(:,[cid cdat])=[]
sival(rid,:)=[]
 
panel=tlist(['panel data';'dates';'id';'x';'nameid';'namex'],...
dat,id,sival,name_indiv,names)
 
endfunction
 
