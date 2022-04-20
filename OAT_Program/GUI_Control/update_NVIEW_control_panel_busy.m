function handles = update_NVIEW_control_panel_busy(handles)

% Update NVIEW control panel with busy text

    % Update static text result details - NVIEW Content panel
    set(handles.static_text_result_details, 'String','');
    set(handles.static_text_result_details, 'String', ...
        sprintf('Processing, please wait...\n'),'FontName','MS Sans Serif');
    
    drawnow;
return;