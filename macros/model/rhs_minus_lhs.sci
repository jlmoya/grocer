function rhs_minus_lhs(grocer_model,grocer_dbmat,grocer_boun,grocer_tol)
 
// PURPOSE: for a model and an associated database calculate
// the rhs minus the lhs of each equation and displays the
// absolute maximum value if it is above a threshold
// ------------------------------------------------------------
// INPUT:
// * model = a model tlist
// * dbmat= a tsmat, representing the database associated to
//   the model
// * boun = a [2 x 1] string vector, the bound over which to
//   perform the calcualtions
// * tol = a scalar, the tolerance criterion
// ------------------------------------------------------------
// OUTPUT:
// nothing : resulst are displayed on screen
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_nameq=grocer_model('name eq');
grocer_neq=size(grocer_nameq,1);
grocer_name_vars=[grocer_model('name endo') ; grocer_model('name exo') ; grocer_model('name resid') ]
tsmat2ts(grocer_dbmat,grocer_name_vars,[],'noprint')
grocer_name_coeffs=grocer_model('name coeff')
grocer_coeffs=grocer_model('coeffs')
for grocer_i=1:size(grocer_name_coeffs,1)
   execstr(grocer_name_coeffs(grocer_i)+'=grocer_coeffs('+string(grocer_i+1)+')')
end
 
grocer_name_params=grocer_model('name param')
grocer_params=grocer_model('params')
for grocer_i=1:size(grocer_name_params,1)
   execstr(grocer_name_params(grocer_i)+'=grocer_params('+string(grocer_i+1)+')')
end
write(%io(2),'equations whose maximum absolue difference between rhs and lhs is above '+string(grocer_tol)+':','(a)')
for grocer_i=1:grocer_neq
   grocer_eqi=grocer_model('equations')(grocer_i);
   grocer_ind_equal=strindex(grocer_eqi,'=')
   execstr('grocer_difference=subper('+part(grocer_eqi,1:grocer_ind_equal-1)+'-('+part(grocer_eqi,grocer_ind_equal+1:length(grocer_eqi))+'),grocer_boun)')
   grocer_maxdiff=max(abs(grocer_difference('series')))
   if grocer_maxdiff > grocer_tol then
      write(%io(2),grocer_nameq(grocer_i)+':' +string(grocer_maxdiff),'(a)')
   end
end
 
endfunction
