function handles = append_selected_time_results(handles,Selected_Time_Results,Selected_Timestamp_Id,Selected_Timestamps,Selected_Hours)

% Does the main root structure exist?
if ~isfield(handles,'NVIEW_Appended_Results')
    handles.NVIEW_Appended_Results = [];
end

% Does the structure for the selected timestamp exist?
if ~isfield(handles.NVIEW_Appended_Results,['TD_',Selected_Timestamp_Id])
    handles.NVIEW_Appended_Results.(['TD_',Selected_Timestamp_Id]) = Selected_Time_Results;
else
    % Results already exist!
    return;
end

end
