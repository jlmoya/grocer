function mlatex=mat2latex(grocer_mat,varargin)
 
// PURPOSE: LaTex matrix or LaTex table representation of
//    a scilab matrix
// ------------------------------------------------------------
// INPUT:
// * grocer_mat = (n x k) matrix
// * varargin = arguments which can be
//  .'rowtit=xx' a n-dimension string vector of row titles
//  .'coltit=xx' a k-dimension string vector of columns titles
//  .'caption=xx' the table caption or title
//  .'digits=xx' with xx
//      - a scalar indicating the number of digits to display in each column
//      - a (k x 1) vector indicating the number of digits to display in each column
//      - a (1 x k) vector indicating the number of digits to display in each row
//  .'align=xx' a (1 x 1) or a k-dimensional vector indicating
//      the alignment of the corresponding columns
//      -'c': center
//      -'l'; left
//      -'r'; right
//      (default = center for all)
//  .'float=xx' a string indicating the position of table
//     - 'b': bottom of the page
//     - 't': top of the page
//     - 'h': at the very place in the text where it occurs
//     - 'p': on a special page containing only floats
//     - '!': without considering most of the internal parameters
//            which could stop this float from being placed
//    (default='!ht')
//  .'label=xx' the LaTex anchor
//  .'path=xx' a path where the file has to be saved and the name
//      of the file ex: c:\mypath\mytable.tex'
// ------------------------------------------------------------
// OUTPUT:
// * mlatex = a string formed of LaTex represenation of the matrix
// ------------------------------------------------------------
// REMARKS:
//  When no row titles, column titles, caption are not
//  specidfied then simple matrix is created. If the label
//  option is used then the converted matrix is be numbered by LaTex.
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2009
// http://grocer.toolbox.free.fr/grocer.html
 
out = %io(2)
 
grocer_rowtit=[]
grocer_coltit=[]
grocer_digits=[]
grocer_caption=[]
grocer_label=[]
grocer_float=[]
grocer_path=[]
grocer_align='c'
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_st=strsubst(varargin(grocer_i),' ','')
      st4=part(grocer_st,1:4)
      st5=part(grocer_st,1:5)
      st6=part(grocer_st,1:6)
      st7=part(grocer_st,1:7)
      if st4=='path' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif st5=='align' | st5=='label' | st5=='float' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif st6=='rowtit' | st6=='coltit' | st6=='digits' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif st7=='caption' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      end
   else
      error(typeof(varargin(grocer_i))+': not a valid type in mat2latex')
   end
end
 
 
dlm='\\'
[n,k]=size(grocer_mat)
[nr,kr]=size(grocer_rowtit)
[nc,kc]=size(grocer_coltit)
 
if kc~=0 then
  if (kc==1) & (kc<nc) then
    grocer_coltit=grocer_coltit'
    kc=nc
  end
  // creates column title
  if (kc~=0) & (kc~=k) then
    error("# of columns titles doesn''t match with the # columns of the input matrix")
  elseif (kc==k) then
     grocer_coltit=[grocer_coltit,dlm]
     grocer_coltit=strcat(grocer_coltit,' & ')
     grocer_coltit=strsubst(grocer_coltit,'& \\','\\')
     grocer_coltit=grocer_coltit+' \hline \hline '
  end
else
  kc=k
  grocer_coltit=[]
end
 
if (length(grocer_rowtit)>0) & (length(grocer_coltit)>0)
  grocer_coltit=' & '+grocer_coltit
  kc=kc+1
elseif (length(grocer_rowtit)>0) & (length(grocer_coltit)==0)
  kc=kc+1
end
 
if (nr==1) & (nr<kr) then
  grocer_rowtit=grocer_rowtit'
  nr=kr
end
 
if (nr~=0) & (nr~=n) then
  error("# of row titles doesn''t match with the # rows of the input matrix")
end
 
if (size(grocer_align,'*')~=1) & (size(grocer_align,'*')~=kc)
  error("alignement option doesn''t not match with the number of columns")
elseif (size(grocer_align,'*')==1)
  grocer_align=grocer_align(ones(1,k+nc))
  grocer_align=strcat(grocer_align,' ')
end
 
// round to the desire decimal
if length(grocer_digits)==1 then
  mat=ndigits(grocer_mat,grocer_digits)
elseif size(grocer_digits,2)==size(grocer_mat,2) then
  mat=[]
  for d=1:size(grocer_digits,2)
    matd=ndigits(grocer_mat(:,d),grocer_digits(d))
    mat=[mat,matd];
  end
elseif size(grocer_digits,1)==size(grocer_mat,1) then
  mat=[]
  for d=1:size(grocer_digits,1)
    matd=ndigits(grocer_mat(d,:),grocer_digits(d))
    mat=[mat;matd];
  end
elseif length(grocer_digits)==0 then
  mat=string(grocer_mat)
else
  error('# different desired digits ~= # of columns of the table')
end
 
mat=[grocer_rowtit,mat]
mat=[mat,dlm(ones(n,1))];
mat=strcat(mat',' & ')
mat=strsubst(mat,'& \\ &','\\')
mat=strsubst(mat,'& \\','\\')
mat=grocer_coltit+mat
 
if (nr==0) & (kc==0) & (length(grocer_caption)==0) then
  if (length(grocer_label)>0) then
    txtb='\begin{equation} \label{'+grocer_label+'} \left( \begin{array}{'+strcat(grocer_align)+'}'
    txte=' \end{array} \right) \end{equation}'
  else
    txtb='\begin{equation*} \left( \begin{array}{'+grocer_align+'}'
    txte=' \end{array} \right) \end{equation*}'
  end
 
else
  if length(grocer_float)>0 then
    txtb='\begin{table}['+grocer_float+'] \begin{center} \begin{tabular}{'+strcat(grocer_align)+'} \hline \hline '
  else
    txtb='\begin{table} \begin{center} \begin{tabular}{'+strcat(grocer_align)+'} \hline \hline '
  end
 
  if length(grocer_coltit)>0
    if length(grocer_caption)>0 then
      if length(grocer_label)>0 then
        txte='\hline \end{tabular} \caption{'+grocer_caption+'} \label{'+grocer_label+'} \end{center} \end{table}'
      else
        txte='\hline \end{tabular} \caption{'+grocer_caption+'} \end{center} \end{table}'
      end
    else
      txte='\hline \end{tabular} \end{center} \end{table}'
    end
  else
    if length(grocer_caption)>0 then
      if length(grocer_label)>0 then
        txte='\hline \hline \end{tabular} \caption{'+grocer_caption+'} \label{'+grocer_label+'} \end{center} \end{table}'
      else
        txte='\hline \hline \end{tabular} \caption{'+grocer_caption+'} \end{center} \end{table}'
      end
    else
      txte='\hline \hline \end{tabular} \end{center} \end{table}'
    end
 
  end
end
mlatex=txtb+mat+txte
if length(grocer_path)>0 then
  mputl(mlatex,grocer_path)
end
endfunction
 
