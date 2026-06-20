function [] = impexc2bd(grocer_filein,grocer_sep,grocer_fileout,varargin)
 
// PURPOSE: importation of an excel file saved under csv format
// ------------------------------------------------------------
// INPUT:
// * grocer_filein = name of the file to be imported (between quotes)
// * grocer_sep = separator used in the grocer_filein (between quotes)
// * grocer_fileout = name of the scilab file where to save the
// imported data (between quotes)
// * varargin = options that can be:
//   - 'namedat=xxx' where xxx is the name given to the field
//     dates in the .csv file (default: dates)
//   - 'namena=x1;x2;...xn' where xi are the values that the
//     Non Available data can take in the .csv file
//     ('default: ' ' and '#N/A')
// ------------------------------------------------------------
// OUTPUT: nothing; the imported series are saved in the file
// named grocer_fileout
// ------------------------------------------------------------
// NOTES:
// * if one data is named dates or DATES (scilab distinguish
// capitals from small letters) then the following data are
// saved as timeseries
// * if a value is lacking or #N/A in a timeseries, it is given
// a NA value
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
// (with a few lines of code from the scilab group)
 
// set defaults:
// 2 possibilities are considered here for NA values:
// a #N/A (default value in EXCEL) and an empty string;
// other cases can be added by the option 'namena=..."
 
 
grocer_typedat='constant'
grocer_content=[]
grocer_namena=[' ' ; '#N/A']
grocer_namedat='dates'
grocer_prefix=emptystr()
 
// deal with the options that the user can enter reagrding na
// values or the name of the date
grocer_nargin=length(varargin)
for grocer_i=1:grocer_nargin
   grocer_argi=strsubst(varargin(grocer_i),' ','')
   if typeof(grocer_argi) == 'string' then
      if part(grocer_argi,1:7) == 'namena=' then
         grocer_namena=str2vec(grocer_argi)
      elseif part(grocer_argi,1:7) == 'prefix=' then
         grocer_prefix=part(grocer_argi,8:length(grocer_argi))
      elseif part(grocer_argi,1:8) == 'namedat=' then
         grocer_namedat=str2vec(grocer_argi)
      else
         error('not an available option: '+grocer_argi)
      end
   else
      error('arg # '+string(grocer_i)+' is not an available option in impexc2bd')
   end
end
 
[grocer_lhs,grocer_rhs]=argn(0)
if grocer_rhs<2 then
   grocer_sep=','
   grocer_fileout=strsubst(grocer_filein,'.csv','.dat')
end
 
grocer_savevar='save('+''''+grocer_fileout+''''
 
grocer_v=mgetl(grocer_filein)
grocer_v=strsubst(grocer_v,'''','')
grocer_v=strsubst(grocer_v,''"','')
if grocer_sep ~= ',' then
   grocer_v=strsubst(grocer_v,',','.')
end
grocer_nl=size(grocer_v,1)
 
// read the first grocer_line, to fix the # of colums grocer_nc
grocer_line=grocer_v(1)
grocer_ln=length(grocer_line)
grocer_ind_sep2=strindex(grocer_line,grocer_sep)-1
 
if grocer_ind_sep2 == [] then
   warning('there is no separator '+grocer_sep+' in the 1st grocer_line: suspect this is not the true separator')
end
 
grocer_endline=[]
// deal the case when the ending character is not the separator:
// it can alas happen!
if grocer_ind_sep2(size(grocer_ind_sep2,2)) ~= grocer_ln-1 then
   grocer_endline=1
end
grocer_ind_sep2=[grocer_ind_sep2 grocer_endline*(grocer_ln-1)]
grocer_ind_sep1=[1 grocer_ind_sep2+2]
grocer_nc=size(grocer_ind_sep2,2)
grocer_mat=emptystr(grocer_nl,grocer_nc)
 
if grocer_ln ~= grocer_nc then
   for grocer_i=1:grocer_nc
      grocer_mat(1,grocer_i)=part(grocer_line,grocer_ind_sep1(grocer_i):grocer_ind_sep2(grocer_i))
   end
end
 
// read the file, extract each cell of the file and fill
// the predefined matrix grocer_mat
for grocer_i=2:grocer_nl
  grocer_line=grocer_v(grocer_i)
  grocer_ln=length(grocer_line)
  if grocer_ln ~= grocer_nc then
     grocer_ind_sep2=[strindex(grocer_line,grocer_sep)-1 grocer_endline*(grocer_ln-1)]
     grocer_ind_sep1=[1 grocer_ind_sep2+2 ]
     ngrocer_sep=size(grocer_ind_sep2,2)
     for grocer_j=1:ngrocer_sep
        grocer_mat(grocer_i,grocer_j)=part(grocer_line,grocer_ind_sep1(grocer_j):grocer_ind_sep2(grocer_j))
     end
  end
end
 
if or(convstr(grocer_mat(:,1)) == 'dates') & or(convstr(grocer_mat(:,1)) == 'id') then
// we have a panel
   imp_panel(grocer_mat,grocer_fileout,grocer_savevar)
 
elseif (or(convstr(grocer_mat(1,:)) == 'dates') & or(convstr(grocer_mat(1,:)) == 'id')) then
   imp_panel(grocer_mat',grocer_fileout,grocer_savevar)
 
else
 
   if grocer_nc ~=1 then
      grocer_carnum=part(grocer_mat(1,:),1)
      if and((ascii(grocer_carnum) < 46 | ascii(grocer_carnum) > 57) & grocer_carnum ~= '-') then
         // suspect that names are given in a row and not in a column: the second element
         // in the first row does not start by a number
         grocer_mat=grocer_mat'
      end
   else
      grocer_mat=grocer_mat'
   end
 
   [grocer_nl,grocer_nc]=size(grocer_mat)
   // delete empty cols
   grocer_emptycol=emptystr(grocer_nl,1)
   for grocer_i=grocer_nc:-1:1
      if isempty(strsubst(grocer_mat(:,grocer_i),' ','')) then
         grocer_mat(:,grocer_i)=[]
      end
   end
 
   // update the number of columns
   grocer_nc=size(grocer_mat,2)
 
   // delete empty rows
   for grocer_i=grocer_nl:-1:1
      if isempty(strsubst(grocer_mat(grocer_i,:),' ','')) then
         grocer_mat(grocer_i,:)=[]
      end
   end
   // update the number of rows
   grocer_nl=size(grocer_mat,1)
   grocer_comment=emptystr(grocer_nl,1)+' '
 
   for grocer_i=1:grocer_nl
      grocer_nomvar=grocer_prefix+strsubst(grocer_mat(grocer_i,1),' ','_')
      if ascii(part(grocer_nomvar,1)) >=  46 & ascii(part(grocer_nomvar,1)) <= 57 then
         error(grocer_nomvar+': name of variable starts with a number')
      end
      grocer_lvar=length(grocer_nomvar)
      if grocer_lvar ~=0 & size(strindex(grocer_nomvar,' '),2) ~= grocer_lvar then
      // if variable has no name (a case which may occur
      // with .csv files), then ignore it
 
         grocer_d=strsubst(grocer_mat(grocer_i,1),' ','')
         if or(convstr(grocer_namedat) == convstr(grocer_d)) then
         // the line is filled with dates
            grocer_dat=convstr(grocer_mat(grocer_i,2:grocer_nc)')
            grocer_dat=strsubst(grocer_dat,' ','')
            if ascii(grocer_dat(1)) < 46 | ascii(grocer_dat(1))> 57 then
               grocer_comment(grocer_i+1:grocer_nl)=grocer_mat(grocer_i+1:grocer_nl,2)
               grocer_comment=strsubst(grocer_comment,'''','''''')
               grocer_mat(:,2)=[]
               grocer_nc=grocer_nc-1
               grocer_dat(1)=[]
               grocer_typedat='tsc'
            else
              grocer_exvar=grocer_nomvar+'=tlist([''ts'';''freq'';''dates'';''series''],grocer_fq,grocer_datn,grocer_s)'
              grocer_typedat='tsnc'
            end
            [grocer_datn,grocer_inddates,grocer_fq,grocer_rev]=read_dates(grocer_dat)
 
            if grocer_rev then
               grocer_mat(grocer_i+1:grocer_nl,2:$)=grocer_mat(grocer_i+1:grocer_nl,$:-1:2)
            end
 
            grocer_ndates=size(grocer_datn,1)
            grocer_s0=%nan*zeros(grocer_ndates,1)
 
 
         elseif (part(convstr(grocer_nomvar),1:5) == 'names') then
            grocer_nomvar=part(grocer_nomvar,strindex(grocer_nomvar,'(')+1:strindex(grocer_nomvar,')')-1)
            execstr(grocer_nomvar+'=grocer_mat(grocer_i,2:grocer_nc)''')
            grocer_savevar=grocer_savevar+','''+grocer_nomvar+''''
            grocer_content=[grocer_content ; grocer_nomvar']
 
         else
            grocer_r=strsubst(grocer_mat(grocer_i,2:grocer_nc),',','.')'
      // deal now with the na values;
            for grocer_j=1:size(grocer_namena,'*')
               grocer_lna=(grocer_namena(grocer_j) == strsubst(grocer_r,' ',''))
               grocer_r(grocer_lna)='%nan'
            end
      // do tests to replace other non numerical values by NA
            for grocer_j=1:size(grocer_r,1)
 
               grocer_asc=ascii(grocer_r(grocer_j))
               if grocer_r(grocer_j) ~= '%nan' & and(grocer_asc < 48 | grocer_asc > 57) then
                  warning('value '+grocer_r(grocer_j)+' at entry '+string(grocer_j)+' of series '+grocer_nomvar+' has been set to NA')
                  grocer_r(grocer_j) = '%nan'
               end
            end
            grocer_r=evstr(grocer_r)
 
            select grocer_typedat
 
            case 'constant' then
               execstr(grocer_nomvar+'=grocer_r')
 
            case 'tsnc' then
              // ts without comment
               grocer_s=grocer_s0
               grocer_s(grocer_inddates)=grocer_r
               grocer_exvar=grocer_nomvar+'=tlist([''ts'';''freq'';''dates'';''series''],grocer_fq,grocer_datn,grocer_s)'
               execstr(grocer_exvar)
 
            case 'tsc' then
              // ts with comment
               grocer_s=grocer_s0
               grocer_s(grocer_inddates)=grocer_r
               grocer_exvar=grocer_nomvar+'=tlist([''ts'';''freq'';''dates'';''series'';''comment''],grocer_fq,grocer_datn,grocer_s,'''+grocer_comment(grocer_i)+''')'
               execstr(grocer_exvar)
            end
            grocer_content=[grocer_content ; grocer_nomvar grocer_comment(grocer_i)]
            grocer_savevar=grocer_savevar+','''+grocer_nomvar+''''
 
 
         end
      end
   end
 
   if isempty(grocer_content) then
      grocer_content=['VARIABLES' ; '*********' ; grocer_content]
   else
      grocer_content=['VARIABLES' 'DESCRIPTION' ; '*********' '***********'; grocer_content]
   end
   grocer_savevar=grocer_savevar+',''grocer_content'')'
   execstr(grocer_savevar)
end
 
endfunction
 
