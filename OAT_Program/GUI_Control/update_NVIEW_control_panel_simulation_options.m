function handles = update_NVIEW_control_panel_simulation_options(handles)

% Update NVIEW control panel with result information data
if isfield(handles.NVIEW_Control,'Simulation_Options')
    
    % Voltage analysis results
    if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
        Voltage_Analysis_result_details = 'Voltage analysis results available';
    else
        Voltage_Analysis_result_details = 'Voltage analysis results not available';
    end
    
    % Overcurrent analysis results
    if handles.NVIEW_Control.Simulation_Options.Overcurrent_Analysis == 1
        Overcurrent_Analysis_result_details = 'Branch overcurrent analysis results available';
    else
        Overcurrent_Analysis_result_details = 'Branch overcurrent analysis results not available';
    end
    
    % Active power losses results
    if handles.NVIEW_Control.Simulation_Options.Loss_Analysis == 1
        Loss_Analysis_result_details = 'Active power loss analysis results available';
    else
        Loss_Analysis_result_details = 'Active power loss analysis results not available';
    end
    
    % Check for scenarios used and datasets
    if handles.NVIEW_Control.Simulation_Options.Use_Scenarios == 1
        Use_Scenarios_result_details = [' - ', int2str(handles.NVIEW_Control.Simulation_Options.Number_of_Scenarios) ' load profile and infeed scenarios used\n'];
        Number_of_datasets_result_details = [ int2str(handles.NVIEW_Control.Simulation_Options.Number_of_datasets) ' different load profile and infeed datasets used per scenario\n'];
        
    else
        Use_Scenarios_result_details = [];
        Number_of_datasets_result_details = [ int2str(handles.NVIEW_Control.Simulation_Options.Number_of_datasets) ' different load profile and infeed datasets used\n'];
        
    end
    
    % Check for grid variant use
    if handles.NVIEW_Control.Simulation_Options.Use_Grid_Variants == 1
        Use_Grid_Variants_result_details = [' - ', int2str(handles.NVIEW_Control.Simulation_Options.Number_of_Variants) ' distribution networks compared\n'];
    else
        Use_Grid_Variants_result_details = [];
    end
    
    % Check for the number of files
    num_of_result_files = 0;
    for i = 1 : numel(handles.NVIEW_Control.Result_Files)
        if ischar(handles.NVIEW_Control.Result_Files{i,1})
            num_of_result_files = num_of_result_files + 1 ;
        else
            num_of_result_files = num_of_result_files + numel(handles.NVIEW_Control.Result_Files{i,1});
        end
        
    end
    % Check if all results are unpartitioned or partioned files exist
    if num_of_result_files == numel(handles.NVIEW_Control.Result_Files)
        condition_partitioned = 0;
    else
        condition_partitioned = 1;
    end
    
    % Update static text result details - NVIEW Content panel
    set(handles.static_text_result_details, 'String','');
    if condition_partitioned == 0
        set(handles.static_text_result_details, 'String', ...
            sprintf(['- ' int2str(numel(handles.NVIEW_Control.Result_Files)) ' result files found for selected simulation tests\n',...
            '- ''' handles.NVIEW_Control.Simulation_Options.Input_values_used ''' Input values used for simulations\n'...
            ' - ', Number_of_datasets_result_details,...
            Use_Scenarios_result_details,...
            Use_Grid_Variants_result_details,...
            '    - ', Voltage_Analysis_result_details,'\n',...
            '    - ', Overcurrent_Analysis_result_details,'\n',...
            '    - ', Loss_Analysis_result_details,'\n']));
    else
        set(handles.static_text_result_details, 'String', ...
            sprintf(['- ' int2str(numel(handles.NVIEW_Control.Result_Files)) ' scenarios found for selected simulation tests',...
            ' (located in ' , int2str(num_of_result_files), ' result files)\n',...
            '- ''' handles.NVIEW_Control.Simulation_Options.Input_values_used ''' Input values used for simulations\n'...
            ' - ', Number_of_datasets_result_details,...
            Use_Scenarios_result_details,...
            Use_Grid_Variants_result_details,...
            '    - ', Voltage_Analysis_result_details,'\n',...
            '    - ', Overcurrent_Analysis_result_details,'\n',...
            '    - ', Loss_Analysis_result_details,'\n']));
    end
    
end
return;