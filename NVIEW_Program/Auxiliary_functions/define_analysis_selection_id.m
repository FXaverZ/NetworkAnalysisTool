function Analysis_Selection_Id = define_analysis_selection_id(NVIEW_Analysis_Selection)

sc_id = int2str(NVIEW_Analysis_Selection.Scenarios');
sc_id = strrep(sc_id,' ','');
gv_id = int2str(NVIEW_Analysis_Selection.Variants');
gv_id = strrep(gv_id,' ','');
td_id = NVIEW_Analysis_Selection.SelectedTime_Id;
umin_id = int2str(NVIEW_Analysis_Selection.Umin);
umax_id = int2str(NVIEW_Analysis_Selection.Umax);
ilim_id = int2str(NVIEW_Analysis_Selection.Ilim);
Analysis_Selection_Id = [sc_id,'_',gv_id,'_',td_id,'_',umin_id,'_',umax_id,'_',ilim_id];


return
