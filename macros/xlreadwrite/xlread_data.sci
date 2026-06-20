// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
//
//   Copyright (C) 2018 - Thomas PFAU  (Matlab version)
//   Copyright (C) 2018-2021 - Stéphane MOTTELET
//
// This file is hereby licensed under the terms of the GNU GPL v2.0.
// For more information, see the COPYING file which you should have received
// along with this program.
//
// Based on the Matlab version https://fr.mathworks.com/matlabcentral/fileexchange/65824-xlread
//

function [raw,isText,isNum,custom,rangeGiven] = xlread_data(filename,varargin)

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

    [sheet,xlrange,processFcn] = parseXlsReadInput(varargin(:));

    // Set java path to same path as Scilab path
    System.setProperty('user.dir', pwd());

    // Open a file
    xlsFile = File.new(filename);
    //And get the extension.
    [_path,_filename,extension] = fileparts(filename);

    raw = {};
    // If file exist create a new workbook
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
    //Read from the given sheet.
    if ~isempty(sheet)
        if type(sheet) == 1
            // Use Sheet -1 as POI is 0 based, and scilab is 1-based.
            if xlsWorkbook.getNumberOfSheets() >= sheet && sheet >= 1
                xlsSheet = xlsWorkbook.getSheetAt(sheet-1);
            else
                error(msprintf(_('%s: The workbook has only %d sheets while sheet %d is requested.'), 'xlread',xlsWorkbook.getNumberOfSheets(), sheet));
            end
        else
            //If its a name, we will first have to collect the sheet names:
            for i = 1:xlsWorkbook.getNumberOfSheets()
                sheeti =  xlsWorkbook.getSheetAt(i-1);
                sheetNames(i) =sheeti.getSheetName();
            end

            sheetIndex = find(sheet == sheetNames);
            if isempty(sheetIndex)
                error(msprintf(_('%s: sheet ''%s'' does not exists.'), 'xlread',sheet));
            end

            xlsSheet = xlsWorkbook.getSheetAt(sheetIndex-1);
        end
    else
        // check number of sheets
        nSheets = xlsWorkbook.getNumberOfSheets();

        // If no sheets, return empty data
        if nSheets < 1
            return
        else
            xlsSheet = xlsWorkbook.getSheetAt(0);
        end
    end
    
    //Now, we got the requested XLS sheet.

    iRowStart = 0;
    iColStart = 0;
    iRowEnd = xlsSheet.getLastRowNum();
    iColEnd = %inf;

    if ~isempty(xlrange)
        if strindex(xlrange,':')
            xlranges = strsplit(xlrange,':');
            cellStart = xlranges(1);
            cellEnd = xlranges(2);
        else
            cellStart = xlrange;
            cellEnd = xlrange;
        end
        // Define start & end cell

        // Create a helper to get the row and column

        cellStart = CellReference.new(cellStart);
        cellEnd = CellReference.new(cellEnd);

        // Get start & end locations
        if cellStart.getRow() >= 0
            iRowStart = double(cellStart.getRow());
        end
        
        if cellStart.getCol() >= 0
            iColStart =  double(cellStart.getCol());
        end
        
        if cellEnd.getRow() >= 0
            iRowEnd =  double(cellEnd.getRow());
        end
        
        if cellEnd.getCol() >= 0
            iColEnd =  double(cellEnd.getCol());
        end
        
        jremove(cellStart)
        jremove(cellEnd)
    end

    selCols = (iColEnd - iColStart) + 1;
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

    numCols = double(min(selCols,numCols));
    numRows = double(min(selRows,xlsSheet.getLastRowNum()+1));

    raw = cell(numRows,numCols);
    isText = resize_matrix(%f,[numRows,numCols]);
    isDate = resize_matrix(%f,[numRows,numCols]);
    isNum  = isText;

    realCols = 0;
    realRows = 0;

    // Iterate over all data
    for iRow = iRowStart:iRowEnd
        // Fetch the row (if it exists)
        currentRow = xlsSheet.getRow(iRow);
        if isempty(currentRow)
            jremove(currentRow)
            continue
        end

        // enter data for all cols
        ir = iRow - iRowStart+1;
        for iCol = iColStart:min(iColEnd,currentRow.getLastCellNum())

            ic = iCol - iColStart+1;
            // Check if cell exists
            currentCell = currentRow.getCell(iCol);            
            try
                currentCell.class();
            catch
                currentCell = [];
            end
            
            if ~isempty(currentCell)  //No information, pass
                currentRow = xlsSheet.getRow(iRow);
                currentCell = currentRow.getCell(iCol);
                ct = currentCell.getCellType();
                select ct.toString()
                case "NUMERIC"
                    raw{ir,ic} = currentCell.getNumericCellValue();
                    isNum(ir,ic) = %t;
                    if DateUtil.isCellDateFormatted(currentCell)
                        cs=currentCell.getCellStyle();
                        simpdf = SimpleDateFormat.new(cs.getDataFormatString());
                        formattedDate = simpdf.format(currentCell.getDateCellValue());
                        raw{ir,ic} = {raw{ir,ic},formattedDate};
                        isText(ir,ic) = %t;
                    end
                case "BOOLEAN"
                    raw{ir,ic} = currentCell.getBooleanCellValue();
                case "STRING"
                    raw{ir,ic} = currentCell.getStringCellValue();
                    isText(ir,ic) = %t;
                case "ERROR"
                    raw{ir,ic} = currentCell;
                case "FORMULA"
                    //This is a bit more interesting.
                    ct = currentCell.getCachedFormulaResultType();
                    select ct.toString()
                    case "STRING"
                        raw{ir,ic} = currentCell.getStringCellValue();
                        isText(ir,ic) = %t;
                    case "NUMERIC"
                        raw{ir,ic} = currentCell.getNumericCellValue();
                        isNum(ir,ic) = %t;
                    case "BOOLEAN"
                        raw{ir,ic} = currentCell.getBooleanCellValue();
                    case 5 "ERROR"
                        raw{ir,ic} = 'ActiveX VT_ERROR: ';
                    end
                end
                if ct.toString() <> "BLANK"
                    realCols = max(realCols,ic)
                    realRows = max(realRows,ir)
                end
            end
            jremove(currentCell)
        end

        jremove(currentRow)
    end

    if realCols <> numCols || realRows <> numRows
        raw    = raw(1:realRows,1:realCols)
        isText = isText(1:realRows,1:realCols)
        isNum  = isNum(1:realRows,1:realCols)
        numCols = realCols;
        numRows = realRows;
    end
    
    rangeGiven = ~isempty(xlrange);

    custom = [];
    if type(processFcn) == 13
        Data.Value = raw;
        Data.Count = size(raw,'*');
        Data.WorkSheet = xlsSheet;

        try
            [Data,custom] = processFcn(Data);
        catch //probably not two outputs...
            [Data] = processFcn(Data);
        end

        raw = Data.Value;
    end

    jremove(xlsSheet)
    jremove(xlsWorkbook)

    fileIn.close();

    jremove(fileIn)
    jremove(xlsFile)
    jremove() //  final Java GC

endfunction

function [sheet,x1xlrange,processFcn] = parseXlsReadInput(varargin)
    // Parse the input of the xlread function to obtain all relevant outputs for
    // the input of an xls/xlsx file (independent on matlab implementations).

    sheet = 1;
    x1xlrange = '';
    processFcn = [];

    if size(varargin) == 0
        return;
    end

    sheetDone = %f;
    xlrangeDone = %f;

    varargpos = 1;

    while varargpos <= size(varargin)
        carg = varargin(varargpos);
        if xlrangeDone //Now, we have to be in the last element, which is the process function
            processFcn = carg;
            return;
        end

        if ~sheetDone
            if type(carg) == 1 || type(carg) == 10 && size(strsplit(carg,':'),'*') < 2
                sheet = carg;
                sheetDone = %t;
            else //its not numeric, and looks like a x1xlrange
                x1xlrange = carg;
                //We did not yet parse the sheet, but got a xlrange -> only xlrange provided.
                break;
            end
        else //if sheet is done, we got a second argument, which has to be xlrange.
            if ~xlrangeDone
                x1xlrange = carg;
                xlrangeDone = %t;
            end
        end

        varargpos = varargpos + 1;
    end
endfunction
