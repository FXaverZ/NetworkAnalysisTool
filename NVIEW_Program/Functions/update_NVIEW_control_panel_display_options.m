function handles = update_NVIEW_control_panel_analysis_selection(handles)

text_output = [];
Variant_selection_details = [];
Scenario_selection_details = [];
Timeperiod_selection_details = [];

% Update NVIEW control panel with result information data

% Grid variant selection
if sum(handles.NVIEW_Analysis_Selection.Variants) ~= handles.NVIEW_Control.Simulation_Options.Number_of_Variants
    Variant_selection_details = 'Grid variants selected:';
    id_ = [];
    id_ = find(handles.NVIEW_Analysis_Selection.Variants==1);
    for i = 1 : numel(id_)
        Variant_selection_details = [Variant_selection_details,'\n   - ',handles.NVIEW_Control.Simulation_Description.Variants{id_(i),1}];
    end
else
    Variant_selection_details = 'All grid variants selected';
end

% Scenario selection
if sum(handles.NVIEW_Analysis_Selection.Scenarios) ~= handles.NVIEW_Control.Simulation_Options.Number_of_Scenarios
    Scenario_selection_details = 'Scenarios selected:';
    id_ = [];
    id_ = find(handles.NVIEW_Analysis_Selection.Scenarios==1);
    for i = 1 : numel(id_)
        Scenario_selection_details = [Scenario_selection_details,'\n   - ',handles.NVIEW_Control.Simulation_Description.Scenario{id_(i),1}];
    end
else
    Scenario_selection_details = 'All scenarios selected';
end

% Timeperiod selection
if numel(handles.NVIEW_Analysis_Selection.Timepoints) ~= handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset
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
else
    Timeperiod_selection_details = 'Simulation period of: 0 - 23 h selected';
end



%------------------------------------------------------------------------------------------------

% Update static text result details - NVIEW Content panel
text_output = ['User result selection:\n',...
    '- ', Variant_selection_details, '\n',...
    '- ', Scenario_selection_details, '\n',...
    '- ', Timeperiod_selection_details];

% Give warning if time domain settings are changed from full day
if ~strcmp(Timeperiod_selection_details,'Simulation period of: 0 - 23 h selected')
    text_output=['Warning: NAT results or time period result files must be available for different time period observations!\n',...
        ' - For faster time-period observation analyses from NAT files, time-period NVIEW results must be created. ''Save time-domain'' option must be set to ENABLED in ''Settings''\n\n',...
        text_output];
    
end
set(handles.static_text_result_details, 'String', ...
    sprintf(text_output));

return;