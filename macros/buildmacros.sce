// Copyright (C) 2009 - DIGITEO - Pierre MARECHAL <pierre.marechal@scilab.org>
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt

if getversion("scilab")(1) < 6 then
   directories = [ ..
    "automatic"    ; .. 
    "basic"        ; .. 
    "bma"          ; .. 
    "cointsci"     ; .. 
    "contrib"      ; .. 
    "cycles"       ; .. 
    "diagnos"      ; .. 
    "disag"        ; .. 
    "distrib"      ; .. 
    "e4"           ; .. 
    "factors"      ; .. 
    "gauss2sci"    ; .. 
    "gauss_mimics" ; .. 
    "garch"        ; .. 
    "gmm"          ; .. 
    "johansen"     ; .. 
    "kalman"       ; .. 
    "likesci"      ; .. 
    "model"        ; .. 
    "ms"           ; .. 
    "multi"        ; .. 
    "optsci"       ; .. 
    "panel"        ; .. 
    "panel_unitr"  ; ..
    "pltg_new"     ; .. 
    "prtgroc"      ; .. 
    "qualitative"  ; .. 
    "reg_gene"     ; .. 
    "single"       ; .. 
    "symbolic"     ; .. 
    "ts"           ; .. 
    "tsmat"        ; .. 
    "tvp_var"      ; .. 
    "var"          ; .. 
    "varma"        ];

else
   directories = [ ..
    "automatic"    ; .. 
    "basic"        ; .. 
    "bma"          ; .. 
    "cointsci"     ; .. 
    "contrib"      ; .. 
    "cycles"       ; .. 
    "diagnos"      ; .. 
    "disag"        ; .. 
    "distrib"      ; .. 
    "e4"           ; .. 
    "factors"      ; .. 
    "gauss2sci"    ; .. 
    "gauss_mimics" ; .. 
    "garch"        ; .. 
    "gmm"          ; .. 
    "johansen"     ; .. 
    "kalman"       ; .. 
    "likesci"      ; .. 
    "model"        ; .. 
    "ms"           ; .. 
    "multi"        ; .. 
    "optsci"       ; .. 
    "panel"        ; .. 
    "panel_unitr"  ; ..
    "pltg_new"     ; .. 
    "prtgroc"      ; .. 
    "qualitative"  ; .. 
    "reg_gene"     ; .. 
    "single"       ; .. 
    "symbolic"     ; .. 
    "ts"           ; .. 
    "tsmat"        ; .. 
    "tvp_var"      ; .. 
    "var"          ; .. 
    "varma"        ;..
    "xlreadwrite"  ];
end

directories = pathconvert(get_absolute_file_path("buildmacros.sce")+"/"+directories);

mprintf('Installing GROCER '+ GROCER_version+' - Copyright '+ascii([195 137])+'ric Dubois, Emmanuel Michaux et al. 2002-'+GROCER_Cyear+'\n');

for i=1:size(directories,"*")
	chdir(directories(i));
	exec("buildmacros.sce");
end
