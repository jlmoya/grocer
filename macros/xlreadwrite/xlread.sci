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

function [num,txt,raw,custom] = xlread(filename,varargin)

    if getscilabmode() == "NWNI" then
        error(msprintf(_("Scilab ''%s'' function disabled in -nogui or -nwni mode.\n"), "xlread"));
    end
    
    [raw,isText,isNum,custom,rangeGiven] = xlread_data(filename,varargin(:));    
    [num,txt] = xlread_scan(raw,isText,isNum, ~rangeGiven);

endfunction
