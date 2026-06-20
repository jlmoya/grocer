function []=gauss2sci(filein,dirout,grocer_verbose)
 
// PURPOSE: translate a file containing gauss programs
// ------------------------------------------------------------
// INPUT:
// * filein = the name of the file to translate
// * dirout = the directory where
// ------------------------------------------------------------
// OUTPUT:
// * nothing: the result of the transaltion is sent to text
//   files, suffixed either by .sci (for gauss functions) or
//   .sce (for gauss commands)
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
ncall=0
 
[nargout,nargin]=argn(0)
// if no directory for the Scilab functions is given,
// then set it to blank, i.e the default one
if nargin == 1 then
   dirout=''
   grocer_verbose=%f
elseif nargin == 2 then
   grocer_verbose=%f
end
 
// read the file
v=read(filein,-1,1,'(a)')
filein=strsubst(filein,'\','/')
ind_sep=strindex(filein,'/')
name_sce=part(filein,ind_sep($)+1:length(filein))
ind_dot=strindex(name_sce,'.')
if ~isempty(ind_dot) then
   name_sce=part(name_sce,1:ind_dot($)-1)
end
 
v=strsubst(v,'...','gauss2sci_threedots')
// first deal with the statements 'local'
v=gauss2sci_local(v)
 
// then deal with comments
[v,comments,comments_start,comments_end]=gauss2sci_comments(v)
// now all comments begin with '//'
 
comments_end=[0 ; comments_end]
 
lines_proc=[]
lines_endp=[]
nlines=size(v,1)
 
for j=1:nlines
// gauss is not case sensitive: to recover the name of fucntions
// that are equivalent in gauss and Scilab (log, sqrt,...), it is
// necessary to transform all names into lower cases
// since Gauss is not case sensitive, it should not have any consequence
// on the working of the programm, only on its appearance
// this not done for comments, to keep the relevant upper cases (names
// for instance)
   // add print to lines satrting with a ""
   starting_comment=[strindex(v(j),'//') length(v(j))+1]
   if starting_comment(1) ~= 1 then
      vj=part(convstr(v(j)),1:starting_comment(1)-1)
      v(j)=vj+part(v(j),starting_comment(1):length(v(j)))
      pres_proc=findobject(vj,'proc',[' ',';'],[' ','('],%f)
      if pres_proc then
         lines_proc=[lines_proc ; j]
      end
      pres_endp=findobject(vj,'endp',[' ',';'],[' ',';'],%t)
      if pres_endp then
         lines_endp=[lines_endp ; j]
      end
   end
 
end
 
//if isempty(lines_proc) then
//   error('your file does not contain the keyword ''proc''')
//end
//
n_proc=size(lines_proc,1)
n_endp=size(lines_endp,1)
 
if n_proc ~= n_endp then
   error('# of keywords ''proc'' ('+string(n_proc)+') not equal to the # of keywords ''endp'' ('+string(n_endp)+')')
end
 
lines_proc_aux=lines_proc
lines_endp_aux=lines_endp
for j=1:n_proc
   if or(lines_endp-lines_proc < 0) then
      error('keywords ''proc'' and ''endp'' must alternate')
   end
   lines_proc_aux(1)=[]
   lines_endp_aux(1)=[]
end
 
lines_endp=[0 ; lines_endp]
comments_end(1)=[]
 
cumproc=0
 
if n_proc == 0 then
   v_sce=v
   comments_sce=comments
   comments_start_sce=comments_start
   comments_end_sce=comments_end
 
else
   v_sce=[]
   comments_sce=[]
   comments_start_sce=[]
   comments_end_sce=[]
 
   for proc=1:n_proc
// the lines between the keyword endp and the keyword proc belong to the
// script, not to a function: add them (if any) to the matrices
// pertaining to the script
      v_sce=[v_sce ; v(lines_endp(proc)+1:lines_proc(proc)-1)]
      comments_sce=[comments_sce ; comments(lines_endp(proc)+1:lines_proc(proc)-1)]
 
      comments_start_scej=comments_start((comments_start(:,1)<lines_proc(proc))&(comments_start(:,1)>lines_endp(proc)),:)
      if ~isempty(comments_start_scej) then
         comments_start_scej(:,1)=comments_start_scej(:,1)-cumproc
      end
      comments_start_sce=[comments_start_sce ; comments_start_scej]
 
      comments_start_endj=comments_end((comments_end(:,1)<lines_proc(proc))&(comments_end(:,1)>lines_endp(proc)),:)
      if ~isempty(comments_start_endj) then
         comments_start_endj(:,1)=comments_start_endj(:,1)-cumproc
      end
      comments_end_sce=[comments_end_sce ; comments_start_endj]
 
      comments_startj=comments_start((comments_start(:,1) <= lines_endp(proc+1)) & (comments_start(:,1) >= lines_proc(proc)),:)
      if ~isempty(comments_startj) then
         comments_startj(:,1)=comments_startj(:,1)-lines_proc(proc)+1
      end
      comments_endj=comments_end((comments_end <= lines_endp(proc+1)) & (comments_end >= lines_proc(proc)))
      if ~isempty(comments_endj) then
         comments_endj=comments_endj-lines_proc(proc)+1
      end
      vj=v(lines_proc(proc):lines_endp(proc+1))
      commentsj=comments(lines_proc(proc):lines_endp(proc+1))
      gauss2sci_proc(vj,dirout,commentsj,comments_startj,comments_endj)
      cumproc(1)=cumproc(1)+lines_endp(proc+1)-lines_proc(proc)+1
   end
 
end
 
gauss2sci_script(v_sce,dirout,name_sce,comments_sce,comments_start_sce,comments_end_sce)
 
endfunction
 
