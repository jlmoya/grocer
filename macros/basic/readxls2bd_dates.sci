function [sitxt,sival,dates,names,typedat,comments]=readxls2bd_dates(sitxt,sival,cdat,rdat,n1,n2,prefix)
 
// PURPOSE: importation of an excel file saved under csv format
// ------------------------------------------------------------
// INPUT:
// * sitxt = a (n1 x n2) string matrix, gathering the string
//   cells of an Excel sheet
// * sival = a (n1 x n2) real matrix, gathering the numerical
//   cells of an Excel sheet
// * cdat = the column index of the keyword signaling dates
//   (in general 'dates')
// * rdat = the row index of the keyword signaling dates
//   (in general 'dates')
// * n1 = the # of rows in the sheet
// * n2 = the # of columns in the sheet
// ------------------------------------------------------------
// OUTPUT:
// * sitxt = a (n1 x n2) string matrix, gathering the string
//   cells of an Excel sheet
// * sival = a (n1 x n2) real matrix, gathering the numerical
//   cells of an Excel sheet
// * cdat = the column index of the keyword signaling dates
//   (in general 'dates')
// * rdat = the row index of the keyword signaling dates
//   (in general 'dates')
// * n1 = the # of rows in the sheet
// * n2 = the # of columns in the sheet
// ------------------------------------------------------------
// NOTES:
// * the normal case is one when the first row (or col) is
//   filled with dates and the fist col (or row) is filled
//   with names; in that case, the second row (or col) can be
//   filled with comments and the program is able to recognize
//   if this is the case; the program deals also a case that
//   should hapen very, very occasionnaly when the dates are
//   not in the first row or col, but in that case the names
//   must be on the first col or row and the sheet cannot
//   contain comments
// ------------------------------------------------------------
// Copyright: Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
typedat='tsnc'
comments=[]
 
if n1 == 1 | n2 == 1 then
   error('your file contains only dates')
end
 
if cdat == 1 & rdat == 1 then
// dates in the left upper corner
// first determine whether dates are in a row or in a col
   firstcar=part(stripblanks(sitxt(1,(min(3,n2):n2))),1)
   if isempty(sitxt(1,min(3,n2):n2)) | (and(ascii(firstcar) >= 46 & ascii(firstcar) <= 57)) then
     // dates are in a row: transpose the matrices
      sitxt=sitxt'
      sival=sival'
   end
 
elseif cdat == 1 then
   // names in column
   sitxt=[sitxt(rdat,:) sitxt(1:rdat-1,:) sitxt(rdat+1:n1,:)]
   sival=[sival(rdat,:) sitxt(1:rdat-1,:) sitxt(rdat+1:n1,:)]
   sitxt=sitxt'
   sival=sival'
 
elseif rdat == 1 then
   // names in row
   sitxt=[sitxt(:,cdat) ; sitxt(:,1:cdat-1) ; sitxt(:,cdat+1:n2)]
   sival=[sival(:,cdat) ; sitxt(:,1:cdat-1) ; sitxt(:,cdat+1:n2)]
 
else
   error('names should be in the first not empty row or column')
end
 
asc=ascii(sitxt(2,1))
if (asc(1) < 46 | asc(1) > 57) then
   // cell (1,2) is not a date: this indicates comments
   typedat='tsc'
   comments=sitxt(2,2:$)
   sitxt(2,:)=[]
   sival(2,:)=[]
end
 
[n1,n2]=size(sitxt)
dates=sitxt(2:n1,1)
if isempty(dates) then
   dates=sival(2:n1,1)
end
nobs=n1-1
names=prefix+sitxt(1,2:n2)
sitxt=sitxt(2:n1,2:n2)
sival=sival(2:n1,2:n2)
 
endfunction
