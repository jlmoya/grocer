    function []=mpltseries(varargin)
 
// PURPOSE: Mutliple graphs on one window
// ------------------------------------------------------------
// INPUT:
// * (optional) varargin:
//   - a time series
//   - a real (nxp) vector
//   - a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   - a matrix or a list of such elements
//   - 'nseries = xx' number series per graph
//   - 'ncol = xx' graph page's number of columns  (default = 2)
//   - 'order=xx' to change the order of appearance of the series in the graphs.
//      The user can use this option in the following way:
//      * xx = (1 x p) or (p x 1) vector containing the user defined order of appearance of each series
//      * xx = -1 the whole list of data is decomposed into b=p/nseries consecutive
//      blocks (B) so that graph number i contains series (B_1(:,i),...B_b(:,i)).
//   - 'main_title=x' if the user wants to give a title to the whole graph page
//   - 'title=x' if the user wants to give its own title
//     (default: the name of the ts if it has been given
//      between quotes, the string 'ts' if not)
//   - 'main_legend=x'  for an identical legend for all graphs
//   - 'legend=x' with x the title of the legend for each graph
//   - 'bounds=[''b1'' ; ''b2'' ;...; ''bn'']' if the user
//     wants to give its own grocer_bounds
//     (default: the whole series)
//   - 'yaxex=xx' if the user wants to put the x axis at value
//      xx (default: y minimum value)
//   - 'yaxis=xx' where xx is a (1xp) matrix of 1 and 2, if the
//      user wants 2 axes, respectively at the left and the
//      right of the graph; the j the series is represented on
//      the left axis if xx(j)==1 and on the right one if
//      xx(j)==2
//      (default: only a left axis)
//   - 'bars = xx' with xx integer row vector of size p
//     representing the nature of the representation of the
//     series (1=bars; anything else = curves)
//   - 'x0(1)=xx' with xx integer representing the x location
//     of the first y axis (default: put at x=1)
//   - 'x0(2)=xx' with xx integer representing the x location
//     of the second y axis (default: put at x=nobs)
//   - 'x=xx' where xx is the (1xnobs) string vector to put
//     on the x axis
//   - 'ntics=xx' with xx an integer representing number of
//         of tics between 2 occurences of the axis values
//   - 'styleg =xx' with xx integer row vector of size p
//     representing the location of the legend
//     (default: 5, that is the legend is placed interactively
//   - 'style = xx' with xx integer row vector of size p or nseries
//     representing the line style of each series
//   - 'color = xx' with xx integer row vector of size p or nseries
//      representing the line color of each series
//   - 'mycolor=[r1,g1,b1;...;rp,gp,bp]' a matrix of size
//        (p x 3) or (nseries x 3) with with ri,gi,bi
//        the RGB integer values of a color
//   - 'thickn = xx' with xx integer row vector of size p or nseries
//     representing the thickness of the line drawn for each
//     series (default all equal to 1)
//   - 'shade=xx' a (nx1) vector composed of 0 and 1 where
//          1 delimits areas to be shaded
//   - 'xlabel=xx' with xx the label of x-axis
//   - 'ylabel=xx' with xx the label of y-axis
//   - 'font_title=xx' with xx the size of the title font
//   - 'font_main_title=xx' with xx the size of the main title font
//   - 'font_axis=xx' with xx the size of the axis font
//   - 'font_legend=xx' with xx the size of the legend font
//   - 'font_main_legend=xx' with xx the size of the main legend font
//   - 'font_xlabel=xx' with xx the size of the x-axis label
//   - 'font_ylabel=xx' with xx the size of the y-axis label
//   - 'style_title=xx' with xx the font style of the title
//   - 'window=x' if the user wants to specify the # x where
//     the graph is plotted
//     (default: the window 1)
//   - 'reverse = xx' with xx integer row vector of size 2
//     of 0 and 1: 0 if series are drawn in increasing order
//                 1 if series are drawn in decreasing
//   - 'just_scale=bool' with bool a boolean which is:
//      * %T if you want the y scale to be exactly the length [min(y),max(y)]
//      * %F if you want the y scale to begin and end with rounded numbers (default)
//     (default: all series plotted in increasing order)
//   - 'dropna' if the user wants to graph only the non NA
//     values
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008 / Emmanuel Michaux 2008-2009
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_nargin=length(varargin)
// set defaults
grocer_wind=1
grocer_y=[]
grocer_dleg=%t
grocer_y0=[]
grocer_l=list()
grocer_dropna=%f
grocer_ncol=1
grocer_nseries=1
grocer_styleg0='styleg=6'
grocer_f_leg='font_legend=2'
grocer_f_axis='font_axis=2'
grocer_font_main_legend=3
grocer_font_main_title=4
grocer_f_title=emptystr()
grocer_dtitp=%f
grocer_dlegp=%f
grocer_dftitp=%f
grocer_dflegp=%f
grocer_order=0
 
for grocer_i=length(varargin):-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argis=strsubst(grocer_argi,' ','')
      grocer_str2=part(grocer_argis,1:2)
      grocer_str3=part(grocer_argis,1:3)
      grocer_str4=part(grocer_argis,1:4)
      grocer_str5=part(grocer_argis,1:5)
      grocer_str6=part(grocer_argis,1:6)
      grocer_str7=part(grocer_argis,1:7)
      grocer_str8=part(grocer_argis,1:8)
      grocer_str9=part(grocer_argis,1:9)
      grocer_str10=part(grocer_argis,1:10)
      grocer_str11=part(grocer_argis,1:11)
      grocer_str13=part(grocer_argis,1:13)
      grocer_str15=part(grocer_argis,1:15)
      grocer_str16=part(grocer_argis,1:16)
      grocer_length=length(grocer_argi)
      grocer_indeq=strindex(grocer_argi,'=')
      if ~isempty(grocer_indeq) then
         grocer_endc=part(grocer_argi,grocer_indeq+1:grocer_length)
      end
      if grocer_str10 == 'font_title' then
         grocer_f_title='font_title='+string(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str10 == 'main_title' then
         grocer_titp=grocer_endc
         grocer_dtitp=%t
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'bounds' then
         grocer_boundsvar=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'window' then
         grocer_wind=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'styleg' then
         grocer_styleg0=string(varargin(grocer_i))
         grocer_styleg=varargin(grocer_i)
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'style=' then
         execstr('grocer_'+string(varargin(grocer_i)))
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'legend' then
         grocer_strleg0=str2vec(varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'thickn' then
         execstr('grocer_'+string(varargin(grocer_i)))
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'xlabel' then
         grocer_xlabel=strsubst(varargin(grocer_i),',',';')
         grocer_xlabel=str2vec(grocer_xlabel)
         varargin(grocer_i)=null()
      elseif grocer_str6 == 'ylabel' then
         grocer_ylabel=strsubst(varargin(grocer_i),',',';')
         grocer_ylabel=str2vec(grocer_ylabel)
         varargin(grocer_i)=null()
      elseif grocer_str5 == 'yaxex' then
         grocer_y0=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str5 == 'yaxis' then
         grocer_yax=varargin(grocer_i)
         varargin(grocer_i)=null()
      elseif grocer_str5 == 'title' then
         grocer_tit=strsubst(varargin(grocer_i),',',';')
         grocer_tit=str2vec(grocer_tit)
         varargin(grocer_i)=null()
      elseif grocer_str5 == 'noleg' then
         grocer_dleg=%f
         varargin(grocer_i)=null()
      elseif grocer_str5 == 'color' then
         grocer_pltcol=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str5 == 'order' then
         execstr('grocer_'+string(varargin(grocer_i)))
         varargin(grocer_i)=null()
      elseif grocer_argis == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif grocer_str2 == 'x=' then
         grocer_xscale0=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str4 == 'ncol' then
         grocer_ncol=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str7 == 'nseries' then
         grocer_nseries=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str7 == 'mycolor' then
         grocer_pltcolu=evstr(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str9 == 'font_axis' then
         grocer_f_axis='font_axis='+string(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str15 == 'font_main_title' then
         execstr('grocer_'+string(varargin(grocer_i)))
         grocer_dftitp=%t
         varargin(grocer_i)=null()
      elseif grocer_str11 == 'main_legend' then
         grocer_dlegp=%t
         grocer_strleg=str2vec(varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif grocer_str11 == 'font_legend' then
         grocer_f_leg='font_legend='+string(grocer_endc)
         varargin(grocer_i)=null()
      elseif grocer_str16 == 'font_main_legend' then
         execstr('grocer_'+string(varargin(grocer_i)))
         varargin(grocer_i)=null()
      elseif grocer_str2 ~= 'x0' & grocer_str4 ~= 'bars' & ...
         grocer_str5 ~= 'ntics' & grocer_str5 ~= 'shade' & ...
         grocer_str6 ~= 'nogrid' & grocer_str10 ~= 'style_axis' & ...
         grocer_str11 ~= 'font_ylabel' & grocer_str11 ~= 'font_xlabel' & ...
         grocer_str11 ~= 'just_scale=' & grocer_str11 ~= 'style_title' then
 
         grocer_l($+1)=varargin(grocer_i)
         varargin(grocer_i)=null()
      end
 
   elseif (typeof(varargin(grocer_i)) == 'constant') | (typeof(varargin(grocer_i))=='tsmat') then
      grocer_l($+1)=varargin(grocer_i)
      varargin(grocer_i)=null()
   end
end
 
if exists('grocer_boundsvar','local') then
// ! warning: where they are written, these lines of code
// allow one to draw ts which are defined only as a vector
// very useful (cf. garch.sci), but a little bit dangerous !
   if size(grocer_boundsvar,2) ~= 1  then
      if size(grocer_boundsvar,1) == 1 then
         grocer_boundsvar=grocer_boundsvar'
      else
         error('your grocer_bounds are not a vector of strings')
      end
   end
   for i=1:size(grocer_boundsvar,1)/2
      [d1,fq]=date2num_fq(grocer_boundsvar(i*2-1))
      grocer_xscale0=num2date([d1:d1+diff_date(grocer_boundsvar(2*i),...
           grocer_boundsvar(2*i-1))]',date2fq(grocer_boundsvar(i*2-1)))'
   end
else
   grocer_boundsvar=[]
end
 
grocer_lb=list()
for i=1:length(grocer_l)
   grocer_lb($+1)=grocer_l(length(grocer_l)+1-i)
end
[grocer_y,grocer_namexos,grocer_prests,grocer_boundsvarb]=...
      explone(grocer_lb,grocer_boundsvar,'series',%f,grocer_dropna)
 
// number of series
nobs=size(grocer_y,1)
if length(grocer_nseries)==[]
  grocer_nseries=size(grocer_y,2)
end
 
// number of graph to compute
grocer_k=size(grocer_y,2)
grocer_ny = grocer_k/grocer_nseries
if round(grocer_ny) ~= grocer_ny then
  error('wrong number of graphs')
end
grocer_nplot=grocer_ny
 
// add a window for the legend if necessary
if grocer_dleg & grocer_dlegp then
  grocer_nplot=grocer_nplot+1
end
 
// add a window for the graph page title if necessary
begg=0
if grocer_dtitp then
  grocer_nplot=grocer_nplot+1
  begg=1
end
 
if int(grocer_nplot/grocer_ncol) ~= (grocer_nplot/grocer_ncol)
  grocer_nplot=grocer_nplot+1
end
grocer_nl=grocer_nplot/grocer_ncol
 
if grocer_order==-1 then
  seld=matrix(1:grocer_k,grocer_ny,grocer_nseries)
elseif grocer_order==0 then
  seld=matrix(1:grocer_k,grocer_nseries,grocer_ny)'
elseif size(grocer_order,'*')==grocer_k then
  seld=matrix(grocer_order,grocer_nseries,grocer_ny)'
else
  error('size of vector order don''t match with the number of series')
end
 
// test size of the title
if exists('grocer_tit','local') then
  if size(grocer_tit,'*')~=grocer_ny
    error('size of the title vector don''t match with the number of series')
  end
end
 
// size of the title page font
if grocer_dtitp & ~grocer_dftitp then
  grocer_f_page_title=max(1,5-floor(length(grocer_titp)/20))
end
 
// size of the legend page font
if grocer_dleg & grocer_dlegp & ~grocer_dflegp
  grocer_font_page_leg=3
end
 
// style of lines
// The code below is temporary and should fix the
// following bug in pltseries:
//  with subplot, axes inherate style properties
//  of lines. So each curve is drawn with line_style=1
if exists('grocer_style','local') then
  if size(grocer_style,1)>size(grocer_style,2) then
    grocer_style=grocer_style'
  end
 
  nsty=size(grocer_style,'*')
  if nsty~=grocer_nseries & nsty~=grocer_k then
     error('# of colors doesn''t macth with the number of series to be drawn')
  end
 
  if nsty==grocer_nseries then
    msty=string(ones(grocer_ny,1).*.grocer_style)
  end
 
  if nsty==grocer_k then
    if grocer_dleg & grocer_dlegp then
      warning('# of font style > number needed with main_legend option: only the first '+string(grocer_nseries)+' were kept')
      grocer_style=grocer_style(1:grocer_nseries)
      msty=string(ones(grocer_ny,1).*.grocer_pltcol)
    else
      msty=string(matrix(grocer_style,grocer_ny,grocer_nseries)')
    end
  end
 
  grocer_style0=[]
  for i=1:grocer_ny
    sty='['+strcat(string(msty(i,:)),',')+']'
    grocer_style0=[grocer_style0;'style='+sty]
  end
 
else
  ty='[1'
  if grocer_nseries>1 then
    for i=1:(grocer_nseries-1)
      ty=ty+',1'
//      ty=ty+','+string(i+1)
    end
  end
  ty=ty+']'
  grocer_style0='style='+string(ty)
  grocer_style0=grocer_style0(ones(grocer_ny,1),:)
  grocer_style=ones(1,grocer_nseries)
//  grocer_style=1:grocer_nseries
end
 
 
// thickness of lines
if exists('grocer_thickn','local') then
  if size(grocer_thickn,1)>size(grocer_thickn,2) then
    grocer_thickn=grocer_thickn'
  end
 
  nsty=size(grocer_thickn,'*')
  if nsty~=grocer_nseries & nsty~=grocer_k then
     error('# of thickness parameters doesn''t macth with the number of series to be drawn')
  end
 
  if nsty==grocer_nseries then
    msty=string(ones(grocer_ny,1).*.grocer_thickn)
  end
 
  if nsty==grocer_k then
    if grocer_dleg & grocer_dlegp then
      warning('# of font thickn > number needed with main_legend option: only the first '+string(grocer_nseries)+' were kept')
      grocer_thickn=grocer_thickn(1:grocer_nseries)
      msty=string(ones(grocer_ny,1).*.grocer_pltcol)
    else
      msty=string(matrix(grocer_thickn,grocer_ny,grocer_nseries))
    end
  end
 
  grocer_thickn0=[]
  for i=1:grocer_ny
    sty='['+strcat(string(msty(i,:)),',')+']'
    grocer_thickn0=[grocer_thickn0;'thickn='+sty]
  end
 
else
  ty='[1'
  if grocer_nseries>1 then
    for i=1:(grocer_nseries-1)
      ty=ty+',1'
    end
  end
  ty=ty+']'
  grocer_thickn0='thickn='+string(ty)
  grocer_thickn0=grocer_thickn0(ones(grocer_ny,1),:)
  grocer_thickn=ones(1,grocer_nseries)
end
 
// if the user has not given any x axis legend, then generate it
if ~exists('grocer_xscale0','local') then
   if grocer_prests then
      dn=date2num_m(grocer_boundsvarb)
      dscale=[]
      for i=1:size(dn,1)/2
         dscale=[dscale dn(2*i-1):dn(2*i)]
      end
      grocer_xscale0=num2date(dscale,date2fq(grocer_boundsvarb(1)))
   else
      grocer_xscale0=string([1:nobs])
   end
end
 
if grocer_dropna then
// drop na from the series and from the scale
   nonna=or(isnan(grocer_y),'c')
   grocer_y=grocer_y(~nonna,:)
   grocer_xscale0=grocer_xscale0(~nonna)
end
 
// open a new window
if isempty(grocer_wind) then
   grocer_wind=scf()
   grocer_wind=grocer_wind.figure_id
else
   scf(grocer_wind)
   clf(grocer_wind)
end
 
// if the user has not given any tittle, then generate it
if ~exists('grocer_tit','local') then
   grocer_tit=emptystr(grocer_ny,1)
end
 
// number of y-axis
if ~exists('grocer_yax','local') then
   grocer_yax='yaxis=['+joinstr(string(ones(1,grocer_nseries)),',')+']'
   yaxis=ones(grocer_k,1)
   grocer_yax=grocer_yax(ones(grocer_ny,1))
   nyax=1
else
  execstr(grocer_yax)
  if (size(yaxis,'*')>1) & (grocer_nseries==1) then
   error('no 2nd axis is needed when only one serie is drawn on each graph')
  else
    if size(yaxis,1)~=grocer_k then
      if size(yaxis,2)==grocer_k then
        yaxis=yaxis'
      elseif size(yaxis,'*')==grocer_nseries then
        yaxis=ones(grocer_ny,1).*.yaxis'
      else
        error('size of the the legend don''t match with the # of series')
      end
    end
  end
  nyax=max(yaxis)
  grocer_yax=[]
  myaxis=matrix(yaxis,grocer_nseries,grocer_ny)'
  for i=1:grocer_ny
    syax='['+strcat(string(myaxis(i,:)),',')+']'
    grocer_yax=[grocer_yax;'yaxis='+syax]
  end
end
 
// graphs legend
if ~exists('grocer_strleg0','local') & grocer_dleg & ~grocer_dlegp then
  if exists('grocer_yax','local') then
    // test size of yaxis option
    yaxis=string(yaxis)
    yaxis=strsubst(yaxis,'1','lhs')
    yaxis=strsubst(yaxis,'2','rhs')
    grocer_strleg0=grocer_namexos+' ('+yaxis+')'
  else
    grocer_strleg0=grocer_namexos
  end
end
 
// colors of the graph
if exists('grocer_pltcol','local') & ~exists('grocer_pltcolu','local') then
  nco=length(grocer_pltcol)
  if nco~=grocer_k & nco~=grocer_nseries then
    error('# of colors doesn''t macth with the number of series to be drawn')
  end
 
  if nco==grocer_nseries then
    mscol=string(ones(grocer_ny,1).*.grocer_pltcol)
  end
 
  if nco==grocer_k then
    if grocer_dleg & grocer_dlegp then
      warning('# of colors > number of colors needed with main_legend option: only the first '+string(grocer_nseries)+' were kept')
      grocer_pltcol=grocer_pltcol(1:grocer_nseries)
      mscol=string(ones(grocer_ny,1).*.grocer_pltcol)
    else
      mscol=string(matrix(grocer_pltcol,grocer_ny,grocer_nseries))
    end
  end
 
  grocer_pltcol0=[]
  for i=1:grocer_ny
    scol='['+strcat(string(mscol(i,:)),',')+']'
    grocer_pltcol0=[grocer_pltcol0;'color='+scol]
  end
 
elseif ~exists('grocer_pltcol','local') & ~exists('grocer_pltcolu','local') then
  grocer_pltcol=[1 2 5 14 24 3:4 6:13];
  grocer_pltcol=grocer_pltcol(1:grocer_nseries);
 
  mscol=string(ones(grocer_ny,1).*.grocer_pltcol)
  grocer_pltcol0=[]
  for i=1:grocer_ny
    scol='['+strcat(string(mscol(i,:)),',')+']'
    grocer_pltcol0=[grocer_pltcol0;'color='+scol]
  end
 
 
elseif ~exists('grocer_pltcol','local') & exists('grocer_pltcolu','local')
  if size(grocer_pltcolu,2)~=3
    error('matrix of user defined colors should have 3 columns');
  end
  nco=size(grocer_pltcolu,1)
  if nco~=grocer_nseries & nco~=grocer_k then
    error('# of user defined colors doesn''t macth with the # of series to be plotted')
  end
 
  if nco==grocer_nseries then
    grocer_pltcol=[]
    if grocer_dleg & grocer_dlegp then
      for c=1:nco
        execstr('grocer_pltcol=[grocer_pltcol,color(grocer_pltcolu('+string(c)+',1),grocer_pltcolu('+string(c)+',2),grocer_pltcolu('+string(c)+',3))]')
      end
    end
 
    mscol=string(grocer_pltcolu)
    scol='['+strcat(mscol(1,:),',')
    for i=2:grocer_nseries
      scol=scol+';'+strcat(mscol(i,:),',')
    end
    scol=scol+']'
 
    grocer_pltcol0=[]
    for i=1:grocer_ny
      grocer_pltcol0=[grocer_pltcol0;'mycolor='+scol]
    end
 
  elseif nco==grocer_k
    if grocer_dleg & grocer_dlegp then
      warning('# of colors > number of colors needed with main_legend option: only the first '+string(grocer_nseries)+' were kept')
      grocer_pltcol=[]
      for c=1:grocer_nseries
        execstr('grocer_pltcol=[grocer_pltcol,color(grocer_pltcolu('+string(c)+',1),grocer_pltcolu('+string(c)+',2),grocer_pltcolu('+string(c)+',3))]')
      end
 
      mscol=string(grocer_pltcolu(1:grocer_nseries,:))
      scol='['+strcat(mscol(1,:),',')
      for i=2:grocer_nseries
        scol=scol+';'+strcat(mscol(i,:),',')
      end
      scol=scol+']'
 
      grocer_pltcol0=[]
      for i=1:grocer_ny
        grocer_pltcol0=[grocer_pltcol0;'mycolor='+scol]
      end
 
    else
 
      mscol=string(grocer_pltcolu)
      grocer_pltcol0=[]
      sg=matrix(1:grocer_k,grocer_nseries,grocer_ny)
      for g=1:grocer_ny
        scol='['+strcat(mscol(sg(1,g),:),',')
        for i=2:grocer_nseries
          scol=scol+';'+strcat(mscol(sg(i,g),:),',')
        end
        scol=scol+']'
        grocer_pltcol0=[grocer_pltcol0;'mycolor='+scol]
      end
    end
  end
end
 
// label on x-axis
if ~exists('grocer_xlabel','local') then
  grocer_xlabel0='xlabel='+emptystr(grocer_ny,1);
else
  if size(grocer_xlabel,'*')~=1 & size(grocer_xlabel,'*')~= grocer_ny
    error("# of x-axis labels doesn''t macth with # of graphs")
  elseif size(grocer_xlabel,'*')==1
    grocer_xlabel0=[]
    for i=1:grocer_ny
     grocer_xlabel0=[grocer_xlabel0;'xlabel='+grocer_xlabel]
    end
  elseif size(grocer_xlabel,'*')==grocer_ny
    grocer_xlabel0=[]
    for i=1:grocer_ny
     grocer_xlabel0=[grocer_xlabel0;'xlabel='+grocer_xlabel(i)]
    end
  end
end
 
// label on y-axis
if ~exists('grocer_ylabel','local') then
//  grocer_ylabel0='ylabel='+emptystr(grocer_ny,nyax);
  grocer_ylabel0='ylabel='+emptystr(grocer_ny,1);
else
  if size(grocer_ylabel,1)~=1 & size(grocer_ylabel,1)~= grocer_ny*nyax
    error("# of y-axis labels doesn''t macth with # of graphs")
  elseif size(grocer_ylabel,'*')==nyax
    grocer_ylabel0=[]
    for i=1:grocer_ny
      grocer_ylabel0=[grocer_ylabel0;'ylabel='+grocer_ylabel]
    end
  elseif size(grocer_ylabel,1)==nyax*grocer_ny
    grocer_ylabel0=[]
    mlab=matrix(grocer_ylabel,nyax,grocer_ny)'
    for g=1:grocer_ny
      slab='['+strcat(mlab(g,:),',')+']'
      grocer_ylabel0=[grocer_ylabel0;'ylabel='+slab]
    end
  end
end
 
// draw page graph title if necessary
if grocer_dtitp then
  drawlater()
  subplot(grocer_nl,grocer_ncol,1)
  plot2d([0,1],[0,1],[-1,-1],"010",rect=[0,0,1,1])
  ha=gca()
  hlt=ha.title
  hlt.text=grocer_titp
  hlt.font_size=grocer_font_main_title
  hlt.auto_position="off"
  hlt.position=[0,0.5]
  h1=ha.children(1)
  h1.visible="off"
  drawnow()
end
 
// draw graphs
if ~grocer_dlegp & grocer_dleg then
  for t=1:grocer_ny
    grocer_strleg='['+joinstr(grocer_strleg0(seld(t,:)),';')+']'
    subplot(grocer_nl,grocer_ncol,t+begg)
    pltseries0(grocer_y(:,seld(t,:)),grocer_y0,grocer_tit(t),grocer_xscale0,[],grocer_yax(t,:),...
    grocer_f_title,grocer_f_axis,grocer_f_leg,grocer_style0(t,:),grocer_thickn0(t,:),...
    'leg='+grocer_strleg,grocer_styleg0,grocer_pltcol0(t,:),grocer_xlabel0(t),...
    grocer_ylabel0(t,:),varargin(:))
  end
else
  for t=1:grocer_ny
    subplot(grocer_nl,grocer_ncol,t+begg)
    pltseries0(grocer_y(:,seld(t,:)),grocer_y0,grocer_tit(t),grocer_xscale0,[],grocer_yax(t,:),...
    grocer_f_title,grocer_f_axis,grocer_style0(t,:),grocer_thickn0(t,:),...
    grocer_pltcol0(t,:),grocer_xlabel0(t),grocer_ylabel0(t,:),varargin(:))
  end
end
 
// draw a global legend if necessary
if grocer_dleg & grocer_dlegp then
  if size(grocer_strleg,'*')~=grocer_nseries
    error('number of arguments in legend not equal to the number of series')
  end
 
  drawlater()
  subplot(grocer_nl,grocer_ncol,t+begg+1)
  plot2d(zeros(4,1),zeros(4,grocer_nseries),grocer_pltcol,'010')
  legends_groc(grocer_strleg,[evstr(grocer_pltcol);grocer_style],2,with_box=%f,grocer_font_main_legend)
  h=gce()
  nleg=size(grocer_strleg,'*');
  for i=1:nleg
    hi=h.children(2*(nleg-i+1));
    hi.thickness=grocer_thickn(i);
    hi.line_style=grocer_style(i);
  end
  drawnow()
end
 
// the following lines correct a bug in scilab:
// current axes and tic inherit the color style of the
// line drawn. These line change the color into black
h1=gcf()
nch=size(h1.children,'*')
if grocer_dtitp then
  nch=nch-1
end
for i=nch:-1:2
  h2=h1.children(i)
  tstc=h2.children
  if size(tstc,'*')==grocer_nseries+5
    h3=h2.children(grocer_nseries+3)
    h3.labels_font_color=0
    h3.tics_color=0
    h3=h2.children(grocer_nseries+5)
    h3.labels_font_color=0
    h3.tics_color=0
  end
end
 
endfunction
