function S = readxlsx(filename,sheet)

// PURPOSE: read xls or xlsx files into Scilab
// ------------------------------------------------------------
// INPUT:
// * filename = a string, the name of the Excel file
// * sheet = a vector of strings or numbers, indicating the
//   sheets to select in the Excel file
// ------------------------------------------------------------
// OUTPUT:
// * S = a mlist file ot type xls with fields 'name', 'text'
//      and 'value' 
// ------------------------------------------------------------
// NOTES:
// * S = a  mlist data structure of type xls, with one field
//   named sheets. The sheets field itself contains a list of
//   sheet data structures:
//   sheet=mlist(['xlssheet','name','text','value'],...
//   sheetname,Text,Value) 
//   where sheetname is a character string containing the name
//   of the sheet, Text is a matrix of string which contains
//   the cell's strings and Value is a matrix of numbers which
//   contains the cell's values.
// ------------------------------------------------------------
// Copyright (C) 2018 - Thomas PFAU  (Matlab version)
// Copyright (C) 2018-2020 - Stéphane MOTTELET
// Copyright: Eric Dubois 2020
// http://grocer.toolbox.free.fr/grocer.html
//
// This file is hereby licensed under the terms of the GNU GPL v2.0.
// For more information, see the COPYING file which you should have received
// along with this program.
//
// Based on the Matlab version:
// https://fr.mathworks.com/matlabcentral/fileexchange/65824-xlread
//
[nargout,nargin]=argn(0)
if nargin == 1 then
    sheet=[]
end
if getscilabmode() == "NWNI" then
   error(msprintf(_("Scilab ''%s'' function disabled in -nogui or -nwni mode.\n"), "xlread"));
end

// Check if POI lib is loaded
try
   // Import required POI Java Classes
   jimport org.apache.poi.ss.usermodel.WorkbookFactory;
   jimport org.apache.poi.ss.usermodel.FormulaError;
   jimport org.apache.poi.ss.usermodel.DateUtil
   jimport org.apache.poi.ss.usermodel.CellType
   jimport org.apache.poi.hssf.usermodel.HSSFWorkbook
   jimport org.apache.poi.xssf.usermodel.XSSFWorkbook;
   jimport org.apache.poi.ss.util.CellReference;
   jimport org.apache.poi.ss.util.WorkbookUtil;
catch
   error(msprintf(_("%s: cannot find the POI library in Scilab Java path.\n"),'xlread'));
end

jimport java.lang.System
jimport java.io.File
jimport java.io.FileOutputStream
jimport java.io.FileInputStream
jimport java.text.SimpleDateFormat

// Set java path to same path as Scilab path
System.setProperty('user.dir', pwd());

// Open a file
xlsFile = File.new(filename);
//And get the extension.
[_path,_filename,extension] = fileparts(filename);

num = [];
txt = [];raw=[];
// If file exists create a new workbook
if xlsFile.isFile()
// create XSSF or HSSF workbook from existing workbook
   try
      fileIn = FileInputStream.new(xlsFile);
      xlsWorkbook = WorkbookFactory.create(fileIn);
   catch
      error(msprintf(_("%s: File ''%s'' is not an Excel file.\n"),'xlread',filename)), ..
   end
else
   error(msprintf(_("%s: File not found: ''%s''.\n"),'xlread',filename)), ..
end

nSheets = xlsWorkbook.getNumberOfSheets();

//Read from the given sheet.
if ~isempty(sheet)
   if type(sheet) == 1
   // Use Sheet -1 as POI is 0 based, and scilab is 1-based.
      if xlsWorkbook.getNumberOfSheets() >= sheet & sheet >= 1
         sheetIndex=sheet 
      else
         error(msprintf(_('%s: The workbook has only %d sheets while sheet %d is requested.'), 'xlread',xlsWorkbook.getNumberOfSheets(), sheet));
      end
   else
      //If its a name, we will first have to collect the sheet names:
      sheetIndex=zeros(sheet(:))'
      for i = 1:nSheets
         sheeti =  xlsWorkbook.getSheetAt(i-1);
         sheetNames_i =sheeti.getSheetName();
         sheetIndex_i = find(sheet == sheetNames_i);
         if ~isempty(sheetIndex_i)
            sheetIndex(sheetIndex_i) = i;
         end
      end
      if or(sheetIndex==0) then
         warning('the following sheet(s) has(ve) not been found:'+strcat(sheet(sheetIndex==0),' - '))
      end
   end
else
   // check number of sheets

   // If no sheets, return empty data
   if nSheets < 1
      return
   else
      sheetIndex = 1:nSheets
   end
end

S=mlist(['xls';'sheets'],list())    
// Now, we get the requested XLS sheet(s).
for sheet_index=sheetIndex
   xlsSheet = xlsWorkbook.getSheetAt(sheet_index-1);
   iRowStart = 0;
   iColStart = 0;
   iRowEnd = xlsSheet.getLastRowNum();

   selRows = (iRowEnd - iRowStart) + 1;

   numCols = 0;
   //get the maximal number of cells in a row
   for i = 0:xlsSheet.getLastRowNum()
      row_i = xlsSheet.getRow(i);
      if ~isempty(row_i)
         numCols = max(numCols,row_i.getLastCellNum());
      end
   end

   //Lets get a rough estimation on the size of the sheet in order to
   //initialize our outputs.

   numRows = double(min(selRows,xlsSheet.getLastRowNum()+1));

   //isText = resize_matrix(%f,[numRows,numCols]);
   //isNum  = isText;
   num=%nan*zeros(numRows,numCols);
   txt=emptystr(numRows,numCols);


   // Iterate over all data
  for ir=1:numRows
      currentRow = xlsSheet.getRow(ir-1);
      if ~isempty(currentRow)

         // enter data for all cols
        for ic=1:numCols
             // Check if cell exists
            currentCell = currentRow.getCell(ic-1);  
            try
               currentCell.class();
            catch
               currentCell = [];
            end
      
            if ~isempty(currentCell) //No information, pass
               ct = currentCell.getCellType();

               select ct.toString()
          
               case "NUMERIC"
                  num(ir,ic)=currentCell.getNumericCellValue();
                  if DateUtil.isCellDateFormatted(currentCell)
                     simpdf = SimpleDateFormat.new('d/M/yyyy');
                     formattedDate = simpdf.format(currentCell.getDateCellValue());
                     txt(ir,ic)=formattedDate
                  end

               case "STRING"
                  txt(ir,ic) = currentCell.getStringCellValue();

               case "FORMULA"
                  //This is a bit more interesting.
                  ct = currentCell.getCachedFormulaResultType();
                  select ct.toString()

                  case "STRING"
                     txt(ir,ic)=currentCell.getStringCellValue();

                  case "NUMERIC"
                     num(ir,ic)=currentCell.getNumericCellValue();
                  end
               else
                  txt(ir,ic) =''
               end
            end
         end
      end

   end
   name_i=xlsSheet.getSheetName()
   sheet_i=mlist(["xlssheet","name","text","value"],name_i,txt,num);
   S.sheets($+1) = sheet_i;
end
    
fileIn.close();

jremove() //  final Java GC
endfunction

