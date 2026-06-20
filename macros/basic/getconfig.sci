function OSNAME = getconfig()
 
// PURPOSE: gets the name of the OS
// ------------------------------------------------------------
// INPUT:
// nothing
// ------------------------------------------------------------
// OUTPUT:
// OSNAME = the name of the O/S
// ------------------------------------------------------------
// Copyright (C) 2009 - DIGITEO - Pierre MARECHAL <pierre.marechal@scilab.org>
// Copyright (C) 2013 - Eric Dubois
// http://www.ensae.net/grocer.html
 
 
if getos() == 'Windows' then
   OSNAME = "windows";
else
   OSNAME   = host("uname");
   MACOSX   = (strcmpi(OSNAME,"darwin") == 0);
   LINUX    = (strcmpi(OSNAME,"linux")  == 0);
   SOLARIS  = (strcmpi(OSNAME,"sunos")  == 0);
   BSD      = (regexp(OSNAME ,"/BSD$/") <> []);
   if LINUX then
        OSNAME = "linux";
   elseif MACOSX then
        OSNAME = "macosx";
   elseif SOLARIS then
        OSNAME = "solaris";
   elseif BSD then
        OSNAME = "bsd";
   end
 
end
 
endfunction
