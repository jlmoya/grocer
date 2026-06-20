function mat=xlsreadm(filein,rangefile,sheet,vls)
 
// PURPOSE: mimic gauss function xlsreadm: Reads from an Excel
// spreadsheet into a matrix
// ------------------------------------------------------------
// INPUT:
// * filein = string, name of .xls file
// * range = string, range to read, e.g. a2:b20, or the
//   starting point of the read, e.g. a2
// * sheet = scalar, sheet number
// * vls = null string or (9 x 1) matrix, specifies the
//   conversion of Excel empty cells and special types into
//   Scilab:
//   1: empty cell
//   2: #N/A
//   3: #VALUE!
//   4: #DIV/0!
//   5: #NAME?
//   6: #REF!
//   7: #NUM!
//   8: #NULL!
//   9:
//   #ERR. A null string results in all empty cells and
//   special types being converted to Scilab missing values.
// ------------------------------------------------------------
// OUTPUT:
// * mat = matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
sheets=readxls(filein)
execstr('si=sheets('+string(sheet)+')')
sival=si.value
 
[ind_rows,ind_cols]=range2num(rangefile)
mat=sival(ind_rows,ind_cols)
 
if ~isempty(vls) then
   if typeof(vls) ~= 'constant' then
      error('4th arg should be a constant vector')
   elseif size(vls,'*') ~= 9 then
      error('4th arg should be a (9 x 1) constant vector')
   else
      sitxt=si.text
      sitxt=sitxt(ind_rows,ind_cols)
      if vls(1) == vls(2) then
         mat(isnan(mat))=vls(1)
      elseif nargin == 5 then
         mat(isnan(mat))=vls(choose)
      else
         error('cannot decide whether %nan values come from an empty cell or a #N/A in Excel file')
      end
 
      mat(sitxt == '#VALUE!')=vls(3)
      mat(sitxt == '#DIV/0!')=vls(4)
      mat(sitxt == '#NAME?')=vls(5)
      mat(sitxt == '#REF!')=vls(6)
      mat(sitxt == '#NUM!')=vls(7)
      mat(sitxt == '#NULL!')=vls(8)
      mat(sitxt == '#ERR')=vls(9)
   end
end
 
endfunction
