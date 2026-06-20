function [rep,stat,err]=sci_unzip(zipfile,dir_out,replace)
 
// PURPOSE: unzip a file from Scilab
// ------------------------------------------------------------
// INPUT:
// * zipfile = the whole address of the zip file to unzip
// * dir_out = * the directory where to locate the unzipped
//   files
// ------------------------------------------------------------
// OUTPUT:
// * rep =  a column vector of character strings (standard output)
// * stat = an integer, the error status. stat=0 if no error occurred
// * err = a column vector of character strings (standard error)
// ------------------------------------------------------------
// Copyright (C) DIGITEO
// Copyright (C) 2013 - Eric Dubois
// http://www.ensae.net/grocer.html
 
[OSNAME] = getconfig()
 
if or(OSNAME == ["linux";"macosx";"solaris"; "bsd"]) then
    extract_cmd = "tar xzf "+ zipfile + " -C """+ dir_out + """";
 
elseif regexp(zipfile,"/\.zip$/","o") ~= [] then
   if OSNAME == 'windows' then
      extract_cmd = """" + getshortpathname(pathconvert(SCI+"/tools/zip/unzip.exe",%F)) + """";
   else
      extract_cmd = "unzip";
   end
   extract_cmd = extract_cmd + " -q """ + zipfile + """ -d """ + pathconvert(dir_out,%F) +"""";
 
elseif regexp(zipfile,"/\.gz$/","o") ~= []
   if OSNAME == 'windows' then
      extract_cmd = """" + getshortpathname(pathconvert(SCI+"/tools/gzip/gzip.exe",%F)) + """";
   else
      extract_cmd = "unzip";
   end
   extract_cmd = extract_cmd + " -q """ + zipfile + """ -d """ + pathconvert(dir_out,%F) +"""";
end
[rep,stat,err] = host(extract_cmd);
 
endfunction
