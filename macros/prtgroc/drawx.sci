function [x_tics]=drawx(xscale0,dilat,ref_nbinter,font_axis,y0,x0,xn,ninter,ntics)
 
// PURPOSE: draw an x axis for a graph which is readable
// whatever number of values it contains
// ------------------------------------------------------------
// INPUT:
// * xscale0 = a (1 x nobs) string vector, representing the scale
// * dilat = a scalar, representing the # of series pertaining
// to a given date (for bar graphics)
// * ref_nbinter = a number indicating the maximum numbers of
//   chars that can be displayed
// * font_axis = size of characters on the axis
// * y0 = value of the y axis where to draw the x axis
// * x0 = number of blanks to put before the true axis
// * xn = number of blanks to put after the true axis
// * ninter = interval between 2 occurences of the axis values
// * ntics = # of tics between 2 occurences of the axis values
// ------------------------------------------------------------
// OUPTUT:
// * x_tics = the coordinates of the displayed tics on the
//   axis
/// the function also draws the x axis
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2022
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
// determine the range of the x axis
if nargin <= 6 then
   xn=0
end
if nargin == 5 then
   x0=0
end
xscale0=vec2row(string(xscale0))
 
// calulates the max # of cars in order to avoid overlapping
// chars on the scale
ncars=max(length(xscale0))
nobs=size(xscale0,2)
// determine the # of intervals consistent with the max # of
// chars and the # of nobs
// deduct the # of tics reported on scale
// approximatively the # of obs divided by the # of intervals
if nargin < 8 then
   ninter=floor(ref_nbinter/ncars)
   ntics=max(floor(nobs/ninter)+1,1)
   ninter=floor(nobs/ntics)
end
flagint=bool2s(ninter*ntics == nobs)
lasttics=ntics*(ninter-flagint)+1
 
xaux=xscale0(1+ntics*[0:ninter-flagint])
xscale=emptystr(1,dilat*(ninter-flagint+1))+''
xscale(-floor((dilat-1)/2)+dilat*[1:ninter-flagint+1])=xaux
 
scale=matrix(xscale,dilat*(ninter-flagint+1))
// before the true axis
if x0 > 0 then
   drawaxis(x=[1 x0-floor((dilat-1)/2)+dilat 1],y=y0,dir='d',tics='r',fontsize=font_axis,sub_int=1,val=[' ' ' '])
end
 
// the axis itself
x_tics=[x0-floor((dilat-1)/2)+dilat x0-floor((dilat-1)/2)+dilat*lasttics ninter-flagint]
drawaxis(x=x_tics,y=y0,dir='d',tics='r',fontsize=font_axis,sub_int=ntics*bool2s(nobs<=100),val=xaux)
 
// after the axis
if dilat*nobs > dilat*lasttics-floor((dilat-1)/2) then
   drawaxis(x=[x0-floor((dilat-1)/2)+dilat*lasttics x0+dilat*nobs 1],y=y0,dir='d',tics='r',fontsize=font_axis,sub_int=(nobs-lasttics)*bool2s(nobs<=100),val=[' ' ' '])
   drawaxis(x=[x0+dilat*nobs x0+dilat*nobs+xn 1 ],y=y0,dir='d',tics='r',fontsize=font_axis,sub_int=1,val=[' ' ' '])
end
 
endfunction
