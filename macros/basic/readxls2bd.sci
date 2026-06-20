function [] = readxls2bd(grocer_filein,grocer_fileout,varargin)
 
// PURPOSE: importation of an excel file saved under csv format
// ------------------------------------------------------------
// INPUT:
// * grocer_filein = name of the file to be imported (between quotes)
// * grocer_fileout = name of the scilab file where to save the
// imported data (between quotes)
// * varargin = options that can be:
//   - 'namedat=xxx' where xxx is the name given to the field
//     dates in the .csv file (default: dates)
//   - 'sheetsnum=x1;x2;...;xn' where the xi's are the n�s of
//     the sheets to import
//   - 'prefix=xxx' where xxx is the prefix that will be added
//     to the names of the variables in the .csv database to
//     obtain their names in the Scilab .dat database
// ------------------------------------------------------------
// OUTPUT: nothing; the imported series are saved in the file
// named grocer_fileout
// ------------------------------------------------------------
// NOTES:
// * if one data is named dates or DATES (scilab distinguish
// capitals from small letters) then the following data are
// saved as timeseries
// * if a value is non numerical, it is set to NA
// * empty lines and columns are removed
// * variables whose name is lacking are removed
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007-2018
// http://dubois.ensae.net/grocer.html
 
 
global GROCERDIR;
vers=getversion("scilab")(1)
// set defaults:
// 2 possibilities are considered here for NA values:
// a #N/A (default value in EXCEL) and an empty string;
// other cases can be added by the option 'namena=..."
grocer_namedat='dates'
grocer_prefix=''
grocer_content=[]
grocer_comment=[]
grocer_datean=%t
 
// deal with the options that the user can enter regarding na
// values or the name of the date
grocer_nargin=length(varargin)
for grocer_i=1:grocer_nargin
   grocer_argi=strsubst(varargin(grocer_i),' ','')
   if typeof(grocer_argi) == 'string' then
      if  part(grocer_argi,1:8) == 'namedat=' then
         grocer_namedat=str2vec(grocer_argi)
      elseif  part(grocer_argi,1:10) == 'sheetsnum=' then
         grocer_sheetsnum=str2vec(grocer_argi)
      elseif part(grocer_argi,1:7) == 'prefix=' then
         grocer_prefix=str2vec(grocer_argi)
      elseif part(grocer_argi,1:7) == 'datean=' then
         execstr(grocer_argi)
      else
         error('not an available option: '+grocer_argi)
      end
   else
      error('arg # '+string(grocer_i)+' is not an available option in impexc2bd')
   end
end
 
[grocer_lhs,grocer_rhs]=argn(0)
if grocer_rhs<2 then
   grocer_fileout=strsubst(grocer_filein,'.xls','.dat')
end
 
if vers >= 5.4 then
   grocer_savevar="save("+''''+grocer_fileout+''',''grocer_content'''
else
   grocer_savevar="save("+''''+grocer_fileout+''',grocer_content'
end
 
try
   grocer_sheets=readxls(grocer_filein)
catch
   grocer_sheets=readxlsx(grocer_filein,varargin(:))
end

if ~exists('grocer_sheetsnum','local') then
   grocer_sheetsnum=1:size(grocer_sheets.sheets)
end
grocer_nbsheets=size(grocer_sheetsnum,'*')
 
for grocer_i=1:grocer_nbsheets
   grocer_sheetsnumi=grocer_sheetsnum(grocer_i)
   execstr('grocer_si=grocer_sheets('+string(grocer_sheetsnumi)+')')
   // Nb: grocer_sheetsi=grocer_sheets(grocer_sheetsnumi) ==> error
   if ~isempty(grocer_si) then
      [grocer_sitxt,grocer_sival]=clean_sheet(grocer_si)
      // find the names of the variables and the orientation of the data
      grocer_ln1=and(length(grocer_sitxt) ~= 0,'c')
      [grocer_nr,grocer_junk]=find(grocer_ln1)
      grocer_ln2=and(length(grocer_sitxt) ~= 0,'r')
      [grocer_junk,grocer_nc]=find(grocer_ln2)
      [grocer_rdat,grocer_cdat]=find(grocer_sitxt == grocer_namedat)
      [grocer_rid,grocer_cid]=find(grocer_sitxt == 'id')
      [grocer_nrows,grocer_ncols]=size(grocer_sitxt)
 
      if ~isempty(grocer_rid) then
      // we have a panel
         [namepanel,panel]=imp_panel2(grocer_sival,grocer_sitxt,grocer_fileout,grocer_namedat)
         execstr(namepanel+'=panel')
         grocer_content=namepanel
 
         if vers >= 5.4 then
            grocer_savevar=grocer_savevar+','''+namepanel+''''
         else
            grocer_savevar=grocer_savevar+','+namepanel
         end
 
      elseif ~isempty(grocer_rdat) then
      // the sheet contain the name 'dates' and therefore ts
 
         [grocer_sitxt,grocer_sival,grocer_dates,grocer_names,grocer_typedat,grocer_comment]=...
         readxls2bd_dates(grocer_sitxt,grocer_sival,grocer_cdat,grocer_rdat,grocer_nrows,grocer_ncols,grocer_prefix)
 
         if typeof(grocer_dates) == 'constant' then
            grocer_deldat=grocer_dates(2:$)-grocer_dates(1:$-1)
            grocer_datn=grocer_dates
            grocer_rev=%f
 
            if and(grocer_deldat < 0) then
               warning('dates were entered in reverse chronological order: function puts them in chronological order and sort the data after accordingly')
               write(%io(2),' ','(a)')
               grocer_datn=grocer_datn($:-1:1)
               grocer_sival=grocer_sival($:-1:1,:)
            end
            grocer_inddates=grocer_datn-grocer_datn(1)+1
 
            if grocer_datean then
               grocer_fq=1
                else
               grocer_fq=[365 1]
               if 7*size(grocer_deldat,1)-6 <= sum(grocer_deldat) & sum(grocer_deldat) <= 7*size(grocer_deldat,1)+6 then
                  // suspect that series are weekly
                  warning('series are supposed to be weekly ones')
                    grocer_datn=date2num_m(grocer_datn,'w')
                  fq=[52 1]
               end
 
               load(GROCERDIR+'\param\dailyform.dat')
               grocer_newdat=datevec(grocer_dates)
               grocer_y2k=find(grocer_newdat(1:$-1,1) == 99 & grocer_newdat(2:$,1) ==100)
 
               if ~isempty(grocer_y2k) then
                  grocer_datn=693960+grocer_datn
               end
               grocer_diffan=grocer_newdat(2:$,1)-grocer_newdat(1:$-1,1)
               grocer_ind=find(grocer_diffan < 0)
               grocer_dates=string(grocer_newdat(:,grocer_dailypart(1)))+grocer_dailysep+...
                            string(grocer_newdat(:,grocer_dailypart(2)))+grocer_dailysep+...
                            string(grocer_newdat(:,grocer_dailypart(3)))
            end
 
         else
             [grocer_datn,grocer_inddates,grocer_fq,grocer_rev]=read_dates(grocer_dates)
             if grocer_rev then
                grocer_sival=grocer_sival($:-1:1,:)
             end
         end
 
         grocer_ndates=size(grocer_datn,1)
         grocer_s0=%nan*zeros(grocer_ndates,1)
 
         if grocer_typedat == 'tsnc' then
            grocer_ts=tlist(['ts';'freq';'dates';'series'],grocer_fq,grocer_datn,grocer_s0)
         else
            grocer_ts=tlist(['ts';'freq';'dates';'series';'comment'],grocer_fq,grocer_datn,grocer_s0,[])
         end
 
         grocer_names=strsubst(grocer_names,' ','_')
         for grocer_j=1:size(grocer_names,'*')
            grocer_namej=grocer_names(grocer_j)
            if grocer_namej == '' then
               warning('series # '+string(grocer_j)+' has no name: it is removed')
            else
               execstr(grocer_namej+'=grocer_ts')
               grocer_s0(grocer_inddates)=grocer_sival(:,grocer_j)
               execstr(grocer_namej+'(''series'')=grocer_s0')
               if grocer_typedat == 'tsc' then
                  execstr(grocer_namej+'(''comment'')=grocer_comment(grocer_j)')
               end
               if vers >= 5.4 then
                  grocer_savevar=grocer_savevar+",''"+grocer_names(grocer_j)+''''
               else
                  grocer_savevar=grocer_savevar+","+grocer_names(grocer_j)
               end
            end
         end
         grocer_content=[grocer_content ; vec2col(grocer_names)]
 
      elseif isempty(grocer_nc) then
         // data in column
         if size(grocer_nr,2) ~= 1 then
             error('there are several lines of names in sheet # '+string(grocer_i)'+': split the sheet in several ones with only one line of names')
         end
 
         grocer_names=strsubst(grocer_prefix+grocer_sitxt(grocer_nr,:),' ','_')
         grocer_nobs=size(grocer_sitxt,1)-1
         grocer_data=grocer_sival([1:grocer_nr-1 grocer_nr+1:grocer_nobs+1],:)
         grocer_nnames=size(grocer_names,2)
         grocer_ndata=size(grocer_data,2)
 
         if grocer_nnames ~= grocer_ndata then
            error('# of series names ('+grocer_nnames+') and # of series columns ('+grocer_nnames+') do not match')
         end
 
         for grocer_j=1:grocer_nnames
            execstr(grocer_names(grocer_j)+'=grocer_data(:,grocer_j)')
            if vers >= 5.4 then
                  grocer_savevar=grocer_savevar+",''"+grocer_names(grocer_j)+''''
            else
                  grocer_savevar=grocer_savevar+","+grocer_names(grocer_j)
            end
         end
         grocer_content=[grocer_content ; grocer_names']
 
      elseif isempty(grocer_nr) then
         // data in row
         if size(grocer_nc,2) ~= 1 then
             error('there are several lines of names in sheet # '+string(grocer_i)'+': split the sheet in several ones with only one line of names')
         end
         grocer_names=grocer_prefix+grocer_sitxt(:,grocer_nc)
         grocer_nobs=size(grocer_sitxt,2)-1
         grocer_data=grocer_sival(:,[1:grocer_nc-1 grocer_nc+1:grocer_nobs+1])
         grocer_nnames=size(grocer_names,1)
         grocer_ndata=size(grocer_data,1)
 
         if grocer_nnames ~= grocer_ndata then
            error('# of series names ('+string(grocer_nnames)+') and # of series columns ('+string(grocer_ndata)+') do not match')
         end
 
         for grocer_j=1:grocer_nnames
            execstr(grocer_names(grocer_j)+'=grocer_data(grocer_j,:)''')
            if vers >= 5.4 then
                grocer_savevar=grocer_savevar+",''"+grocer_names(grocer_j)+''''
            else
                grocer_savevar=grocer_savevar+","+grocer_names(grocer_j)
            end
         end
         grocer_content=[grocer_content ; grocer_names]
 
      end
   end
end
 
if ~isempty(grocer_comment) then
   grocer_content=['VARIABLES' 'DESCRIPTION' ; '---------' '-----------'; grocer_content grocer_comment(:)]
end
 
grocer_savevar=grocer_savevar+')'
execstr(grocer_savevar)
 
endfunction
 
