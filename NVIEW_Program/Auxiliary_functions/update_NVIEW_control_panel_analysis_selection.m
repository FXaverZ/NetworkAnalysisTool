function handles = update_NVIEW_control_panel_analysis_selection(handles,text_input)

text_output = [];
Variant_selection_details = [];
Scenario_selection_details = [];
Timeperiod_selection_details = [];
Voltage_limit_selection_details = [];

% Update NVIEW control panel with result information data

% Grid variant selection
if sum(handles.NVIEW_Analysis_Selection.Variants) == handles.NVIEW_Control.Simulation_Options.Number_of_Variants
    Variant_selection_details = 'All grid variants selected';
else
    Variant_selection_details = 'Grid variants selected:';
    id_ = [];
    id_ = find(handles.NVIEW_Analysis_Selection.Variants==1);
    for i = 1 : numel(id_)
        Variant_selection_details = [Variant_selection_details,'\n   - ',handles.NVIEW_Control.Simulation_Description.Variants{id_(i),1}];
    end
end

% Scenario selection
if sum(handles.NVIEW_Analysis_Selection.Scenarios) == handles.NVIEW_Control.Simulation_Options.Number_of_Scenarios
    Scenario_selection_details = 'All scenarios selected';
else
    Scenario_selection_details = 'Scenarios selected:';
    id_ = [];
    id_ = find(handles.NVIEW_Analysis_Selection.Scenarios==1);
    for i = 1 : numel(id_)
        Scenario_selection_details = [Scenario_selection_details,'\n   - ',handles.NVIEW_Control.Simulation_Description.Scenario{id_(i),1}];
    end
end

% Timeperiod selection
if strcmp(handles.NVIEW_Analysis_Selection.SelectedTime_Id,strrep(int2str(ones(1,24)),' ',''))
    Timeperiod_selection_details = 'Simulation period of: 0 - 23 h selected';
else
    id_ = [];
    id_ = handles.NVIEW_Analysis_Selection.Hours;
    if isempty(find(id_(1:end-1)-id_(2:end)~=-1))
        Timeperiod_selection_details = ['Simulation period of: ' ,int2str(min(id_)),' - ', int2str(max(id_)) ,' h selected'];
    else
        Timeperiod_selection_details = 'Simulation period of: ';
        
        for i = 1 : numel(id_)
            if i == numel(id_)
                Timeperiod_selection_details = [Timeperiod_selection_details,int2str(id_(i)),' h selected'];
            else
                Timeperiod_selection_details = [Timeperiod_selection_details,int2str(id_(i)),','];
            end
        end
    end
end

% Voltage_limit_selection_details
Voltage_limit_selection_details = ['Voltage violation limits:','\n',...
                                   '- Umin set to ', int2str(handles.NVIEW_Analysis_Selection.Umin) ,' %%',...
                                   ', Umax set to ',int2str(handles.NVIEW_Analysis_Selection.Umax), ' %% of rated value'];

% Current limit selection
Current_limit_selection_details = ['Current limits:','\n',...
                                   '- Limit set to ', int2str(handles.NVIEW_Analysis_Selection.Ilim) ,' %% of thermal value'];

%------------------------------------------------------------------------------------------------

% Update static text result details - NVIEW Content panel
text_output = [text_input,'User result selection:\n',...
    '- ', Variant_selection_details, '\n',...
    '- ', Scenario_selection_details, '\n',...
    '- ', Timeperiod_selection_details, ' \n',...
    Voltage_limit_selection_details,'\n',...
    Current_limit_selection_details];

set(handles.static_text_result_details, 'String', ...
    sprintf(text_output));

return;