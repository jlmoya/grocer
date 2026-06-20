function [statement,ind_statements]=gauss2sci_graphs(statement,i_stat,ind_statements)

stat1=statement(1)

true_asclabel=findobject(convstr(stat1),'asclabel',[' '],[' ' '('],%f)
true_axmargin=findobject(convstr(stat1),'axmargin',[' '],[' ' '('],%f)
true_bar=findobject(convstr(stat1),'bar',[' '],[' ' '('],%f)
true_begwind=findobject(convstr(stat1),'begwind',[' '],[' ' ';'],%f)
true_box=findobject(convstr(stat1),'box',[' '],[' ' '('],%f)
true_contour=findobject(convstr(stat1),'contour',[' '],[' ' '('],%f)
true_draw=findobject(convstr(stat1),'draw',[' '],[' ' ';'],%f)
true_endwind=findobject(convstr(stat1),'endwind',[' '],[' ' ';'],%f)
true_fonts=findobject(convstr(stat1),'fonts',[' '],[' ' '('],%f)
true_graphprt=findobject(convstr(stat1),'graphprt',[' '],[' ' '('],%f)
true_graphset=findobject(convstr(stat1),'graphset',[' '],[' ' ';'],%f)
true_histf=findobject(convstr(stat1),'histf',[' '],[' ' '('],%f)
true_loglog=findobject(convstr(stat1),'loglog',[' '],[' ' '('],%f)
true_logx=findobject(convstr(stat1),'logx',[' '],[' ' '('],%f)
true_logy=findobject(convstr(stat1),'logy',[' '],[' ' '('],%f)
true_makewind=findobject(convstr(stat1),'makewind',[' '],[' ' ';'],%f)
true_margin=findobject(convstr(stat1),'margin',[' '],[' ' '('],%f)
true_nextwind=findobject(convstr(stat1),'nextwind',[' '],[' ' ';'],%f)
true_polar=findobject(convstr(stat1),'polar',[' '],[' ' '('],%f)
true_pqgwin=findobject(convstr(stat1),'pqgwin',[' '],[' '],%f)
true_rerun=findobject(convstr(stat1),'rerun',[' '],[' ' ';'],%f)
true_scale=findobject(convstr(stat1),'scale',[' '],[' ' '('],%f)
true_scale3d=findobject(convstr(stat1),'scale3d',[' '],[' ' '('],%f)
true_setwind=findobject(convstr(stat1),'setwind',[' '],[' ' '('],%f)
true_surface=findobject(convstr(stat1),'surface',[' '],[' ' '('],%f)
true_title=findobject(convstr(stat1),'title',[' '],[' ' '('],%f)
true_view=findobject(convstr(stat1),'view',[' '],[' ' '('],%f)
true_viewxyz=findobject(convstr(stat1),'viewxyz',[' '],[' ' '('],%f)
true_volume=findobject(convstr(stat1),'volume',[' '],[' ' '('],%f)
true_window=findobject(convstr(stat1),'window',[' '],[' ' '('],%f)
true_xlabel=findobject(convstr(stat1),'xlabel',[' '],[' ' '('],%f)
true_xtics=findobject(convstr(stat1),'xtics',[' '],[' ' '('],%f)
true_xy=findobject(convstr(stat1),'xy',[' '],[' ' '('],%f)
true_xyz=findobject(convstr(stat1),'xyz',[' '],[' ' '('],%f)
true_ylabel=findobject(convstr(stat1),'ylabel',[' '],[' ' '('],%f)
true_ytics=findobject(convstr(stat1),'ytics',[' '],[' ' '('],%f)
true_zlabel=findobject(convstr(stat1),'zlabel',[' '],[' ' '('],%f)
true_ztics=findobject(convstr(stat1),'ztics',[' '],[' ' '('],%f)

true_graph=[true_asclabel;true_axmargin;true_bar;true_begwind;...
true_box;true_contour;true_draw;true_endwind;true_fonts;true_graphprt;...
true_graphset;true_histf;true_loglog;true_logx;true_logy;...
true_makewind;true_margin;true_nextwind;true_polar;true_pqgwin;...
true_rerun;true_scale;true_scale3d;true_setwind;true_surface;...
true_title;true_view;true_viewxyz;true_volume;true_window;...
true_xlabel;true_xtics;true_xy;true_xyz;true_ylabel;true_ytics;...
true_zlabel;true_ztics]
  
if or(true_graph) then
   ind_statements(ind_statements == i_stat)=[]
end  
endfunction