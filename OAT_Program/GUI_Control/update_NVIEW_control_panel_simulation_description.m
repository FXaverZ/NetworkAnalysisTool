function handles = update_NVIEW_control_panel_simulation_description(handles,option)

% Update NVIEW control panel with result information data
if isfield(handles.NVIEW_Control,'Simulation_Description')
    switch option
        case 'scenario'            
            % Update static text result details - NVIEW Content panel
            set(handles.static_text_result_details, 'String','');            
            static_text_result_details = [];
            
            static_text_result_details = ...
                [{'SCENARIO description'};handles.NVIEW_Control.Simulation_Description.Scenario(:,2)];

            for i = 2 : size(static_text_result_details,1)
                static_text_result_details{i,1}= [int2str(i-1),': ', static_text_result_details{i,1}];
            end
            
            set(handles.static_text_result_details, 'String', static_text_result_details)
            
        case 'grid'
             % Update static text result details - NVIEW Content panel
            set(handles.static_text_result_details, 'String','');            
            static_text_result_details = [];
            % Currently, no grid information exists, only use names of grid
            % (first column)
            static_text_result_details = ...
                [{'GRID description'};handles.NVIEW_Control.Simulation_Description.Variants(:,1)];

            for i = 2 : size(static_text_result_details,1)
                static_text_result_details{i,1}= [int2str(i-1),': ', static_text_result_details{i,1}];
            end
            set(handles.static_text_result_details, 'String', static_text_result_details)
            
    end
end

return;