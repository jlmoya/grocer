function [sheet_text,sheet_value]=clean_sheet(sheet)
 
// PURPOSE: remove empty lines and columns from a sheet
// imported from Excel and give the coresponding extracted
// values and text tabs
// ------------------------------------------------------------
// INPUT:
// * sheet = a sheet imported from Excel
// ------------------------------------------------------------
// OUTPUT:
// * sheet_text = the clean sheet text field
// * sheet_value = the clean sheet value field
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2016
// http://grocer.toolbox.free.fr/grocer.html
 
sheet_text=sheet.text
sheet_value=sheet.value
 
ind_rownan=find(and(isnan(sheet_value),'c'))
for j=ind_rownan($:-1:1)
   if isempty(stripblanks(sheet_text(j,:))) then
      sheet_value(j,:)=[]
      sheet_text(j,:)=[]
   end
end
 
ind_colnan=find(and(isnan(sheet_value),'r'))
for j=ind_colnan($:-1:1)
   if isempty(stripblanks(sheet_text(:,j))) then
      sheet_value(:,j)=[]
      sheet_text(:,j)=[]
   end
end
 
endfunction
