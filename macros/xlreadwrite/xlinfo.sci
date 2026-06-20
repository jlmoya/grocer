// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
//
//   Copyright (C) 2018-2020 - Stéphane MOTTELET
//
// This file is hereby licensed under the terms of the GNU GPL v2.0.
// For more information, see the COPYING file which you should have received
// along with this program.

function [status,sheets,format_]=xlinfo(filename)

    if getscilabmode() == "NWNI" then
        error(msprintf(_("Scilab ''%s'' function disabled in -nogui or -nwni mode.\n"), "xlinfo"));
    end

    // Check if POI lib is loaded
    try
        // Import required POI Java Classes
        jimport org.apache.poi.ss.usermodel.WorkbookFactory;
        jimport org.apache.poi.ss.SpreadsheetVersion
    catch
        error(msprintf(_("%s: cannot find the POI library in Scilab Java path.\n"),'xlinfo'));
    end

    jimport java.lang.System
    jimport java.io.File
    jimport java.io.FileInputStream

    // Set java path to same path as Scilab path
    System.setProperty('user.dir', pwd());

    // Open a file
    xlsFile = File.new(filename);

    status = %f;
    sheets=[];
    format_=[];
    // If file exist create a new workbook
    if xlsFile.isFile()
        // create XSSF or HSSF workbook from existing workbook
        fileIn = FileInputStream.new(xlsFile);
        try
            xlsWorkbook = WorkbookFactory.create(fileIn);
            ver = xlsWorkbook.getSpreadsheetVersion();
            if ver.equals(SpreadsheetVersion.EXCEL2007)
                format_ = "xlOpenXMLWorkbook";
            else // xlsWorkbook.getSpreadsheetVersion().equals(SpreadsheetVersion.EXCEL97)
                format_ = "xlWorkbookNormal";
            end

            status = %t;
            for i = 1:xlsWorkbook.getNumberOfSheets()
                sheet =  xlsWorkbook.getSheetAt(i-1);
                sheets(i) = sheet.getSheetName();
            end
        catch
        end
    else
        error(msprintf(_("%s: File not found: ''%s''.\n"),'xlinfo',filename)), ..
    end
    jremove() // Final Java GC
endfunction
