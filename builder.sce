// Copyright (C) 2009 - DIGITEO - Pierre MARECHAL <pierre.marechal@scilab.org>
//               2021 Éric Dubois
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
// GROCER builder — ported for Scilab 2027 / macOS arm64.
// Original was Windows-only (backslash paths) with version detection via
// part(getversion(),8:10), which breaks on "scilab-branch-2027.0".
// Fixed: filesep() paths + numeric major version via getversion('scilab')(1).

mode(-1);
lines(0);

TOOLBOX_NAME  = "Grocer";
TOOLBOX_TITLE = "Grocer";

toolbox_dir = get_absolute_file_path("builder.sce");
fs = filesep();

load(toolbox_dir+fs+"param"+fs+"GROCER_version.dat")

scimajor = getversion("scilab");
scimajor = scimajor(1);   // numeric major: 2027 on this build

if scimajor < 6 then
   rmdir(toolbox_dir+fs+"macros"+fs+"xlreadwrite")
   rmdir(toolbox_dir+fs+"help"+fs+"en_US"+fs+"z2_xlreadwrite")
   deletefile(toolbox_dir+fs+"help"+fs+"en_US"+fs+"a3_basic"+fs+"readxlsx.xml")
   deletefile(toolbox_dir+fs+"help"+fs+"en_US"+fs+"a3_basic"+fs+"expbd2xls.xml")
end

// NOTE: the original builder swapped in *_SCI6_0.sci variants for Scilab 6+,
// but this v1.87 source distribution does NOT ship those variants — its
// model_transfeq1.sci / check_variables_ineq*.sci are already Scilab-6+
// compatible, so no swap is needed on 2027.

tbx_builder_macros(toolbox_dir);
// help build skipped in NWNI/dev mode (tbx_builder_help fails) — macros only
v = getversion("scilab");
if v(1)>=6 then
    tbx_build_loader(toolbox_dir);
else
    tbx_build_loader(TOOLBOX_NAME,toolbox_dir);
end

clear v TOOLBOX_NAME TOOLBOX_TITLE toolbox_dir scimajor fs ;
