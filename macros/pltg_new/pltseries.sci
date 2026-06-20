function []=pltseries(varargin)
 
// PURPOSE: plots series... (scilab function plot2d, but with
// some scilab parameters fixed and new possibilities, such as
// ts)
// ------------------------------------------------------------
// INPUT:
// * (optional) varargin:
//   - a time series
//   - a real (nxp) vector
//   - a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   - a matrix or a list of such elements
//   - 'title=x' if the user wants to give its own title
//     (default: the name of the ts if it has been given
//     between quotes, the string 'ts' if not)
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
//   - 'styleg =xx' with xx integer row vector of size p
//     representing the location of the legend
//     (default: 5, that is the legend is placed interactively)
//   - 'style = xx' with xx integer row vector of size p
//     representing the line style of each series
//   - 'color = xx' with xx integer row vector of size p
//      representing the line color of each series
//   - 'mycolor=[r1,g1,b1;...;rp,gp,bp]' for user defined colors
//            with ri,gi,bi the RGB integer values of a color
//   - 'thickn = xx' with xx integer row vector of size p
//     representing the thickness of the line drawn for each
//     series (default all equal to 1)
//   - 'legend=xx' with xx the title of the legend
//   - 'shade=xx' a (nx1) vector composed of 0 and 1 where
//          the 1 delimit areas to be shaded
//   - 'wsize = [horizontal scaling, vertical scaling]'
//        to change the size of the graph window
//   - 'xlabel=xx' with xx the label of x-axis
//   - 'ylabel=xx' with xx the label of y-axis
//   - 'ntics=xx' with xx an integer representing number of
//         of tics between 2 occurences of the axis values
//   - 'font_title=xx' with xx the size of the title font
//   - 'font_axis=xx' with xx the size of the axis font
//   - 'font_legend=xx' with xx the size of the legend font
//   - 'font_xlabel=xx' with xx the size of the x-axis label
//   - 'font_ylabel=xx' with xx the size of the y-axis label
//        if the graph has 2 axes xx  could be (2x1) or a scalar
//   - 'style_title=xx' with xx the font style of the title
//   - 'window=x' if the user wants to specify the # x where
//     the graph is plotted
//     (default: the window 1)
//   - 'dropna' if the user wants to graph only the non NA
//     values
//   - 'reverse = xx' with xx integer row vector of size 2
//     of 0 and 1: 0 if series are drawn in increasing order
//                 1 if series are drawn in decreasing
//     (default: all series plotted in increasing order)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2008
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_nargin=length(varargin)
// set defaults
grocer_wind=1
grocer_y=[]
grocer_leg=%t
grocer_y0=[]
grocer_l=list()
grocer_dropna=%f
grocer_mindat=%f
 
for grocer_i=length(varargin):-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_indeq=strindex(grocer_argi,'=')
      if isempty(grocer_indeq) then
         select strsubst(grocer_argi,' ','')
         case 'dropna' then
            grocer_dropna=%t
            varargin(grocer_i)=null()
         case 'noleg' then
            grocer_leg=%f
            varargin(grocer_i)=null()
         else
            if grocer_argi ~= 'nogrid' then
               grocer_l($+1)=varargin(grocer_i)
               varargin(grocer_i)=null()
            end
         end
      else
         grocer_begc=strsubst(part(grocer_argi,1:grocer_indeq-1),' ','')
         grocer_endc=part(grocer_argi,grocer_indeq+1:length(grocer_argi))
 
         select grocer_begc
         case 'bounds' then
            execstr('grocer_boundsvar='+grocer_endc)
            varargin(grocer_i)=null()
         case 'window' then
            execstr('grocer_wind='+grocer_endc)
            varargin(grocer_i)=null()
         case 'title' then
            grocer_tit=grocer_endc
            varargin(grocer_i)=null()
         case 'yaxex' then
            execstr('grocer_y0='+grocer_endc)
            varargin(grocer_i)=null()
         case 'yaxis' then
            grocer_yax=varargin(grocer_i)
            varargin(grocer_i)=null()
         case 'legend' then
            grocer_strleg=grocer_endc
            varargin(grocer_i)=null()
         case 'x' then
            execstr('grocer_xscale0='+grocer_endc)
            varargin(grocer_i)=null()
         end
      end
   elseif (typeof(varargin(grocer_i)) == 'constant') | ...
               (typeof(varargin(grocer_i)) == 'ts') | ...
               (typeof(varargin(grocer_i))=='tsmat') then
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
   grocer_mindat=%t
else
   grocer_boundsvar=[]
end
 
grocer_lb=list()
for i=1:length(grocer_l)
   grocer_lb($+1)=grocer_l(length(grocer_l)+1-i)
end
[grocer_y,grocer_namexos,grocer_prests,grocer_boundsvarb]=explone(grocer_lb,grocer_boundsvar,'series',%f,grocer_dropna,grocer_mindat)
nobs=size(grocer_y,1)
 
// if the user has not given any tittle, then generate it
if ~exists('grocer_tit','local') then
   grocer_tit=''
end
 
// if the user has not given any legend, then generate it
if ~exists('grocer_strleg','local') & grocer_leg then
   if exists('grocer_yax','local') then
      execstr(grocer_yax)
      yaxis=string(yaxis)
      yaxis= strsubst(yaxis,'1','lhs')
      yaxis= strsubst(yaxis,'2','rhs')
      grocer_strleg=joinstr(grocer_namexos,' (',yaxis,')',';')
   else
      grocer_strleg='['+joinstr(grocer_namexos,';')+']'
   end
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
 
if ~exists('grocer_yax','local') then
   grocer_yax='yaxis=['+joinstr(string(ones(1,size(grocer_y,2))),',')+']'
end
 
if grocer_dropna then
// drop na from the series and from the scale
   nonna=or(isnan(grocer_y),'c')
   grocer_y=grocer_y(~nonna,:)
   grocer_xscale0=grocer_xscale0(~nonna)
end
 
if grocer_leg then
   pltseries0(grocer_y,grocer_y0,grocer_tit,grocer_xscale0,grocer_wind,'leg='+grocer_strleg,grocer_yax,varargin(:))
else
   pltseries0(grocer_y,grocer_y0,grocer_tit,grocer_xscale0,grocer_wind,grocer_yax,varargin(:))
end
 
endfunction
