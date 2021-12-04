function Analysis_Selection_Id = define_analysis_selection_id(NVIEW_Analysis_Selection)

sc_id = int2str(NVIEW_Analysis_Selection.Scenarios');
sc_id = strrep(sc_id,' ','');
gv_id = int2str(NVIEW_Analysis_Selection.Variants');
gv_id = strrep(gv_id,' ','');
td_id = NVIEW_Analysis_Selection.SelectedTime_Id;
umin_id = int2str(NVIEW_Analysis_Selection.Umin);
umax_id = int2str(NVIEW_Analysis_Selection.Umax);
ilim_id = int2str(NVIEW_Analysis_Selection.Ilim);

Field_List = fields(NVIEW_Analysis_Selection.SelectedNodes);

nodes_id = [];
branchs_id = [];
for i = 1 : size(Field_List,1)
    if i ~= size(Field_List,1)
        nodes_id = [nodes_id,int2str(NVIEW_Analysis_Selection.SelectedNodes.(Field_List{i})'),','];
        branchs_id = [branchs_id,int2str(NVIEW_Analysis_Selection.SelectedBranches.(Field_List{i})'),','];
    else
        nodes_id = [nodes_id,int2str(NVIEW_Analysis_Selection.SelectedNodes.(Field_List{i})')];
        branchs_id = [branchs_id,int2str(NVIEW_Analysis_Selection.SelectedBranches.(Field_List{i})')];
        
    end
    nodes_id = strrep(nodes_id,' ','');
    branchs_id = strrep(branchs_id,' ','');
end

Analysis_Selection_Id = [sc_id,'_',gv_id,'_',td_id,'_',umin_id,'_',umax_id,'_',ilim_id,nodes_id,'_',branchs_id];


return
