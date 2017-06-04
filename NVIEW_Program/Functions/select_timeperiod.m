function handles = select_timeperiod(handles)

% Select timeperiod for analysis
[Selected_Timestamp_Id, Selected_Timestamps, Selected_Hours] = timeperiod_user_selection(handles);

if ~isempty(Selected_Hours) 
    if ~strcmp(Selected_Timestamp_Id,handles.NVIEW_Analysis_Selection.DefaultTime_Id)
        if ~isfield(handles,'NVIEW_Appended_Results')
            handles.NVIEW_Appended_Results = [];
        end
        
        handles.NVIEW_Analysis_Selection.Hours = [];
        handles.NVIEW_Analysis_Selection.Timepoints = [];
        handles.NVIEW_Analysis_Selection.SelectedTime_Id = [];
        
        handles.NVIEW_Analysis_Selection.Hours = Selected_Hours;
        handles.NVIEW_Analysis_Selection.Timepoints = Selected_Timestamps;
        handles.NVIEW_Analysis_Selection.SelectedTime_Id = Selected_Timestamp_Id;
        handles = update_NVIEW_control_panel_display_options(handles);
        
        if isfield(handles.NVIEW_Appended_Results,['TD_',Selected_Timestamp_Id])
            % Results already exist, exit function
            return;
        else
            % Set possible filename to store or read time-domain results            
            exclude_text = 'Settings';
            File_Selected_Timestamp_Id.Name =...
                [handles.NVIEW_Control.Result_Information_File.Name(1: end-size(exclude_text,2)),'TD_',Selected_Timestamp_Id];
            File_Selected_Timestamp_Id.Exte = handles.NVIEW_Control.NVIEW_Result_Information_File.Exte;
            File_Selected_Timestamp_Id.Path = handles.System.Time_Domain_Path;

            if exist([File_Selected_Timestamp_Id.Path,filesep,File_Selected_Timestamp_Id.Name,File_Selected_Timestamp_Id.Exte],'file')
                % File exists, get data from mat file
                Selected_Time_Results = [];
                load([File_Selected_Timestamp_Id.Path,filesep,File_Selected_Timestamp_Id.Name,File_Selected_Timestamp_Id.Exte]);
            else
                % Get the results for selected time analysis
                Selected_Time_Results = get_nat_results_for_selected_time(handles,Selected_Timestamps);
                
                % If condition for saving time domain files is enabled,
                % save file
                if handles.System.Settings.Save_Time_Domain == 1 
                    save([File_Selected_Timestamp_Id.Path,filesep,File_Selected_Timestamp_Id.Name,File_Selected_Timestamp_Id.Exte],'Selected_Time_Results');
                end
                
            end
            % Append the results
            handles = append_selected_time_results(handles,Selected_Time_Results,Selected_Timestamp_Id,Selected_Timestamps,Selected_Hours);

        end
        handles = clear_table_results(handles);
    end
end