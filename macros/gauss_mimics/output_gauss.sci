function output_gauss(str)

global grocer_output;
    
[true_on,ind_on_def,statk]=findobject(str,'on',[' ' ],[';' ' '],%t)
[true_off,ind_off_def,statk]=findobject(str,'off',[' ' ],[';' ' '],%t)
[true_reset,ind_reset_def,statk]=findobject(str,'reset',[' ' ],[';' ' '],%t)

if true_off then
   mclose(grocer_output(2))


else
   if true_on then
      str=part(str,1:ind_on_def($)-1)
      mode_open='a'
   elseif true_reset then
      str=part(str,1:ind_reset_def($)-1)
      mode_open='w'
   end       

   ind_file=strindex(str,'file')
   if isempty(ind_file) then
      fd= mopen(grocer_output(1),mode_open)
      grocer_output(2)=fd
      
   else
      ind_hat=strindex(str,'^')
      if isempty(ind_hat) then
         namefile=part(str,ind_file(1)+5:length(str))
      else
         exectsr('namefile='+part(str,ind_hat(1)+1:length(str)))
      end
      grocer_output=list(namefile)
      fd= mopen(namefile,mode_open)
      grocer_output($+1)=fd
   end   
end

endfunction