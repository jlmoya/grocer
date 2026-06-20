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

function [num,txt] = xlread_scan(raw,isText,isNum,tightFlag)

    num = [];
    txt = [];

    if ~exists("tightFlag","local")
        tightFlag = %f;
    end
    
   [x,y] = find(isText);
    if ~isempty(x)
        if tightFlag
            rawtxt = raw(min(x):max(x),min(y):max(y));
        else
            rawtxt = raw;
        end
        txt = resize_matrix("",size(rawtxt))
        for i = 1:size(rawtxt,'*')
            if iscell(rawtxt{i})
                r = rawtxt{i};
                txt(i) = r{2};
            elseif type(rawtxt{i}) == 10 && ~isempty(rawtxt{i})
                txt(i) = rawtxt{i};
            end
        end
    end

    [x,y] = find(isNum);
    if ~isempty(x)
        if  tightFlag
            rawnum = raw(min(x):max(x),min(y):max(y));
        else
            rawnum = raw;
        end
        num = resize_matrix(%nan,size(rawnum),%nan);
        for i = 1:size(rawnum,'*')
            if iscell(rawnum{i})
                r = rawnum{i};
                num(i) = r{1};
            elseif type(rawnum{i}) == 1 && ~isempty(rawnum{i})
                num(i) = rawnum{i};
            end
        end
    end
end
