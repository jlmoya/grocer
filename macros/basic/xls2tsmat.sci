function tsm=xls2tsmat(xls_file)
    
S=readxls(xls_file)
S1=S.sheets(1);    
[grocer_sitxt,grocer_sival]=clean_sheet(S1);
[grocer_rdat,grocer_cdat]=find(grocer_sitxt == 'dates')
[grocer_nrows,grocer_ncols]=size(grocer_sitxt)
if ~isempty(grocer_rdat) then
   [grocer_sitxt,grocer_sival,grocer_dates,grocer_names,grocer_typedat,grocer_comment]=...
       readxls2bd_dates(grocer_sitxt,grocer_sival,grocer_cdat,grocer_rdat,grocer_nrows,grocer_ncols,'');
   grocer_freq=date2fq(grocer_dates(1))
   grocer_datenum=date2num_m(grocer_dates)
   if isempty(grocer_comment)
      tsm=tlist(['tsmat';'freq';'dates';'series';'names'],grocer_freq,grocer_datenum,grocer_sival,grocer_names')
       
   else
      tsm=tlist(['tsmat';'freq';'dates';'series';'names';'comments'],grocer_freq,grocer_datenum,grocer_sival,grocer_names',grocer_comment)
   end
         
end


endfunction
