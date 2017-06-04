function handles = reset_display_nview_main_gui(handles)
%reset_display_nview_main_gui    

Limit_static_text_display_charsize = 60; % Default: 40
Limit_number_of_filesep = 4; % Default: 4
Limit_last_shown_folder = 2; % If no folder shown, set to 0! % Default: 0

% Set menu "Settings > Save time-domain" label to the value set in
% config.ini
if handles.System.Settings.Save_Time_Domain == 1
    set(handles.menu_save_time_domain,'Label','Disable time-domain files saving');    
else    
    set(handles.menu_save_time_domain,'Label','Enable time-domain files saving');    
end

if isempty(handles.NVIEW_Control.Result_Information_File.Name) & isempty(handles.NVIEW_Control.NVIEW_Result_Information_File.Name)
    % static_text_import_results default display
    set(handles.static_text_import_results, 'String', 'No result information file loaded!');
    % NVIEW Content panel default display and empty text
    set(handles.panel_result_details,'Title','NVIEW Content Panel');
    set(handles.static_text_result_details, 'String','');
    
else
    if isempty(handles.NVIEW_Control.NVIEW_Result_Information_File.Name)
        % Static text import results display
        str = [handles.NVIEW_Control.Result_Information_File.Path,filesep,...
            handles.NVIEW_Control.Result_Information_File.Name,...
            handles.NVIEW_Control.Result_Information_File.Exte];
        if length(str) > Limit_static_text_display_charsize
            idx = strfind(str, '\');
            if numel(idx) > Limit_number_of_filesep
                str = [str(1:idx(1)),' ... ',str(idx(end-Limit_last_shown_folder):end)];
            end
        end
        set(handles.static_text_import_results, 'String', str);
    else
        str = [handles.NVIEW_Control.NVIEW_Result_Information_File.Path,filesep,...
            handles.NVIEW_Control.NVIEW_Result_Information_File.Name,...
            handles.NVIEW_Control.NVIEW_Result_Information_File.Exte];
        if length(str) > Limit_static_text_display_charsize
            idx = strfind(str, '\');
            if numel(idx) > Limit_number_of_filesep
                str = [str(1:idx(1)),' ... ',str(idx(end-Limit_last_shown_folder):end)];
            end
        end
        set(handles.static_text_import_results, 'String', str);
    end
    
    % NVIEW Content panel update
    % Default option - view simulation options
     handles = update_NVIEW_control_panel_simulation_options(handles);

end
  

end