function []=expbd2xls(grocer_bd,grocer_output,grocer_sheetname,grocer_transpose,grocer_names)
 
 
// PURPOSE: export the content of a data base or a list of
// variables bd to a xls or xlxs Excel file
//-------------------------------------------------------------
// INPUT:
// * grocer_bd = the name of a database or of a list of
//   variables loaded in the environment
// * grocer_output = the excel file where to save the data
// * sep = decimal separator (optional: if not given then sep= '.')
// * transpose = a boolean indicating whether the data must be
//   transposed or not (default = %f)
// * grocer_names = (k x 1) string vectors, the names that the
//   variables will have in the csv files (optional; default:
//   the names of the data in Scilab)
//-------------------------------------------------------------
// OUTPUT:
// nothing
//-------------------------------------------------------------
// Copyright Eric Dubois 2021
// http://grocer.toolbox.free.fr/grocer.html
  
if typeof(grocer_bd) == 'list' then
   grocer_nvar=length(grocer_bd)

elseif typeof(grocer_bd) == 'string' then
   if size(grocer_bd,'*') == 1 & isfile(grocer_bd(1)) then
      // this is the name of a database: load it 
      load(grocer_bd)
      // recover the names in the database; option short 'entered' in the cas of the variable
      // grocer_content exists in the database and the first lines are not the names of teh variables,
      // but strings used for printing
      grocer_bd=dblist(grocer_bd,'short')
   end
   grocer_nvar=size(grocer_bd,1)
      
else
   error('not and admissible type for exportation; '+typeof(grocer_bd))
end
 
grocer_boundsvar=[]; 
[y,namey,grocer_prests,grocer_b,grocer_nonna,comments]=explone(grocer_bd,[],'unnamed',%f,%f,%t)

[nargout,nargin]=argn(0)
if nargin < 4 then
   grocer_transpose=%f
end

if nargin > 4 then
   if ~isempty(grocer_names) then
      namey=grocer_names(:)
   end
end

if grocer_prests then
   if isempty(comments) then
      cell1=num2cell(['dates',namey'])
   elseif and(comments == '') then
      cell1=num2cell(['dates',namey'])
   else
      cell1=num2cell(['dates' , namey';' ' , comments'])
   end
   [grocer_d1,grocer_f1]=date2num_fq(grocer_b(1))
   cell2=num2cell(num2date([grocer_d1:date2num(grocer_b(2))]',grocer_f1))
   cell2export=[cell1 ; [cell2,num2cell(y)]]

else
   cell2export=[num2cell(namey') ; num2cell(y)]        
end
if grocer_transpose then
   cell2export=cell2export' ;
end

xlwrite(grocer_output,cell2export,grocer_sheetname)


endfunction
 
