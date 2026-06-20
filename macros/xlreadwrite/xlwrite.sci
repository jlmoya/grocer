// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
//
//   Copyright (C) 2012-2013 - Alec de Zegher (Matlab version)
//   Copyright (C) 2018-2020 - Stéphane MOTTELET
//
// This file is hereby licensed under the terms of the GNU GPL v2.0.
// For more information, see the COPYING file which you should have received
// along with this program.

function status = xlwrite(filename,A,sheet, range)

    if getscilabmode() == "NWNI" then
        error(msprintf(_("Scilab ''%s'' function disabled in -nogui or -nwni mode.\n"), "xlwrite"));
    end
    // Check if POI lib is loaded
    try
        // Import required POI Java Classes
        jimport org.apache.poi.ss.usermodel.WorkbookFactory;
        jimport org.apache.poi.ss.usermodel.FormulaError;
        jimport org.apache.poi.hssf.usermodel.HSSFWorkbook
        jimport org.apache.poi.xssf.usermodel.XSSFWorkbook;
        jimport org.apache.poi.ss.util.CellReference;
        jimport org.apache.poi.ss.util.WorkbookUtil;
    catch
        error(msprintf(_("%s: cannot find the POI library in Scilab Java path.\n"), 'xlwrite'));
    end

    jimport java.lang.System
    jimport java.io.File
    jimport java.io.FileOutputStream
    jimport java.io.FileInputStream

    status=%f;

    [nargout,nargin] = argn();

    // If no sheet & xlrange is defined, attribute an empty value to it
    if nargin < 3 then sheet = [] end
    if nargin < 4 then range = [] end

    // Check if sheetvariable contains range data
    if nargin < 4 && type(sheet) == 10 && ~isempty(strindex(sheet, ':'))
        range = sheet;
        sheet = [];
    end

    // check if input data is given
    if isempty(A)
        error(msprintf(_("%s: Wrong size for input argument #%d: A not empty matrix expected.\n"), 'xlwrite', 1));
    end
    // Check that input data is not bigger than 2D
    if size(size(A)) > 2
        error(msprintf(_('%s: Dimension of input argument #%d should not be higher than two.\n'), 'xlwrite', 1));
    end

    // Set java path to same path as Scilab path
    System.setProperty('user.dir', pwd());

    filename = pathconvert(filename, %f, %t);
    // Open a file
    xlsFile = File.new(filename);

    // If file does not exist create a new workbook
    if xlsFile.isFile()
        // create XSSF or HSSF workbook from existing workbook
        fileIn = FileInputStream.new(xlsFile);
        try
            xlsWorkbook = WorkbookFactory.create(fileIn);
        catch
            error(msprintf(_("%s: File ''%s'' is not an Excel file.\n"), 'xlwrite', filename));
        end
    else
        // Create a new workbook based on the extension.
        fileExt = fileext(filename);

        // Check based on extension which type to create. If no (valid)
        // extension is given, create XLSX file
        select convstr(fileExt)
            case '.xls'
                xlsWorkbook = HSSFWorkbook.new();
            case '.xlsx'
                xlsWorkbook = XSSFWorkbook.new();
            otherwise
                xlsWorkbook = XSSFWorkbook.new();
                // Also update filename with added extension
                filename = filename + '.xlsx';
        end
    end

    // If sheetname given, enter data in this sheet
    if ~isempty(sheet)
        if type(sheet) == 1
            // Java uses 0-indexing, so take sheetnumer-1
            // Check if the sheet can exist
            if xlsWorkbook.getNumberOfSheets() >= sheet && sheet >= 1
                xlsSheet = xlsWorkbook.getSheetAt(sheet - 1);
            else
                // There are less number of sheets, that the requested sheet, so
                // return an empty sheet
                xlsSheet = [];
            end
        else
            xlsSheet = xlsWorkbook.getSheet(sheet);
        end

        // Create a new sheet if it is empty
        if isempty(xlsSheet)
            warning(msprintf(_("%s: added specified worksheet.\n"), 'xlwrite'));

            // Add the sheet
            if type(sheet) == 1
                xlsSheet = xlsWorkbook.createSheet('Sheet ' + string(sheet));
            else
                // Create a safe sheet name
                sheet = WorkbookUtil.createSafeSheetName(sheet);
                xlsSheet = xlsWorkbook.createSheet(sheet);
            end
        end

    else
        // check number of sheets
        nSheets = xlsWorkbook.getNumberOfSheets();

        // If no sheets, create one
        if nSheets < 1
            xlsSheet = xlsWorkbook.createSheet('Sheet 1');
        else
            // Select the first sheet
            xlsSheet = xlsWorkbook.getSheetAt(0);
        end
    end

    // if range is not specified take start row & col at A1
    // locations are 0 indexed
    if isempty(range)
        iRowStart = 0;
        iColStart = 0;
        iRowEnd = size(A, 1)-1;
        iColEnd = size(A, 2)-1;
    else
        // Split range in start & end cell
        iSeperator = strindex(range, ':');
        if isempty(iSeperator)
            // Only start was defined as range
            // Create a helper to get the row and column
            cellStart = CellReference.new(range);
            iRowStart = cellStart.getRow();
            iColStart = cellStart.getCol();
            // End column calculated based on size of A
            iRowEnd = iRowStart + size(A, 1)-1;
            iColEnd = iColStart + size(A, 2)-1;
        else
            // Define start & end cell
            cellStart = range(1:iSeperator-1);
            cellEnd = range(iSeperator+1:$);

            // Create a helper to get the row and column
            cellStart = CellReference.new(cellStart);
            cellEnd = CellReference.new(cellEnd);

            // Get start & end locations
            iRowStart = cellStart.getRow();
            iColStart = cellStart.getCol();
            iRowEnd = cellEnd.getRow();
            iColEnd = cellEnd.getCol();
        end
    end

    // Get number of elements in A (0-indexed)
    nRowA = size(A, 1)-1;
    nColA = size(A, 2)-1;

    // If data is not a cell, convert it
    if ~iscell(A)
        A = num2cell(A);
    end

    // Iterate over all data
    for iRow = iRowStart:iRowEnd
        // Fetch the row (if it exists)
        currentRow = xlsSheet.getRow(iRow);
        if isempty(currentRow)
            // Create a new row, as it does not exist yet
            currentRow = xlsSheet.createRow(iRow);
        end

        currentRow = xlsSheet.getRow(iRow); // should not be necessary but prevents failure here
        // enter data for all cols
        for iCol = iColStart:iColEnd
            // Check if cell exists

            currentCell = currentRow.getCell(iCol);
            if isempty(currentCell)
                // Create a new cell, as it does not exist yet
                currentCell = currentRow.createCell(iCol);
                
            end

            // Check if we are still in array A
            if (iRow-iRowStart)<=nRowA && (iCol-iColStart)<=nColA
                // Fetch the data
                data = A{iRow-iRowStart+1, iCol-iColStart+1};

                if ~isempty(data)
                    // if it is a NaN value, convert it to an empty string
                    if type(data) == 1 && isnan(data)
                        data = '';
                    end

                    // Write data to cell
                    currentCell.setCellValue(data);
                end

            else
                // Set field to NA
                currentCell.setCellErrorValue(FormulaError.NA.getCode());
            end
            jremove(currentCell)
        end
        jremove(currentRow)
    end

    // Write & close the workbook
    fileOut = FileOutputStream.new(filename);
    xlsWorkbook.write(fileOut);
    fileOut.close();

    jremove() // Final Java GC

    status = %t;

endfunction
