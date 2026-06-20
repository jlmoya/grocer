function [rep, stat, err]=internet2sci(url_in,file_out,option)
 
// PURPOSE: download a file from internet
// ------------------------------------------------------------
// INPUT:
// * url_in = the url to be downloaded
// * file_out = the full name (path included) of the destination
//   file
// * OSNAME =  the name of the OS ('linux',''solaris',''sbd',
//   'macosx' or 'windows', 'optional')
// ------------------------------------------------------------
// OUTPUT:
// * rep = a column vector of character strings (standard
//   output)
// * stat = an integer, the error status. stat=0 if no error
//   occurred
// * err = a column vector of character strings (standard error)
// ------------------------------------------------------------
// Copyright (C) 2009 - DIGITEO - Pierre MARECHAL <pierre.marechal@scilab.org>
// Copyright (C) 2011 - DIGITEO - Allan CORNET
// Copyright (C) 2013 - Eric Dubois
// http://www.ensae.net/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   option=''
end
OSNAME=getconfig()
 
file_out2=strsubst(file_out,'/','\')
ind_slash=strindex(file_out2,'\')
if ~isempty('ind_slash') then
   list_dir=[]
   file_out2=part(file_out2,1:ind_slash($)-1)
   while ~isdir(file_out2)
       list_dir=[file_out2 ; list_dir]
       ind_slash($)=[]
       file_out2=part(file_out2,1:ind_slash($)-1)
   end
   for i=1:size(list_dir,1)
      mkdir(list_dir(i))
   end
end
 
if or(OSNAME == ['linux';'solaris';'sbd']) then
   // Need to detect under Linux platforms
   [rep, stat, err] = host("wget --version");
 
   if stat == 0 then
       [rep,stat,err] = host("wget"+" "+url_in + " -O " + file_out);
   else
      [rep, stat, err] = host("curl --version");
      if stat == 0 then
         host("curl "+" -X PURGE " + url_in);
         [rep,stat,err] = host("curl "+" -s "+url_in + " -o " + file_out);
      else
         error(msprintf(gettext("%s: Neither Wget or Curl found: Please install one of them\n")));
      end
   end
 
elseif OSNAME == 'macosx' then
   [rep,stat,err] = host("curl "+" -s "+url_in + " -o " + file_out);
 
elseif OSNAME == 'windows' then
 
   [rep,stat,err] = host("""" + pathconvert(SCI+"/tools/curl/curl.exe",%F) + """ -s """ + option+ url_in + """ -o """ + file_out + """");
   if stat then
      // try with httpdownload
      imode = ilib_verbose();
      ilib_verbose(0) ;
      id  = link(SCI+"/bin/windows_tools.dll","httpdownload","c");
      stat  = call("httpdownload", url_in, 1, "c", file_out, 2, "c", "out", [1,1], 3, "d");
      ulink(id);
      ilib_verbose(imode);
 
   end
end
 
if stat then
   warning('file '+url_in+' not loaded')
end
 
endfunction
