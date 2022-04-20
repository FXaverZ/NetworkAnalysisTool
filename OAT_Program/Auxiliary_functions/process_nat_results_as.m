function handles = process_nat_results_as(handles)

% Check if Any results are open yet
if ~isfield(handles,'NVIEW_Results')
    return;
end

% Check if NVIEW_Processed exists
  if isfield(handles,'NVIEW_Processed')
     % NVIEW_Processed exists, check if Analysis selection equals current
     % settings
      Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);
      if strcmp(handles.NVIEW_Processed.Control.ID,Analysis_Selection_Id)
          % NVIEW_Processed already encompasses the selected settings
          return;
      else
         % NVIEW_Processed must be recalculated for new analysis selection
          handles = rmfield(handles,'NVIEW_Processed');
      end
  end

% Busy display
handles = update_NVIEW_control_panel(handles, 'Processing analysis, please wait...\n', 'clear');

% Transfer from handles
NVIEW_Control = handles.NVIEW_Control;
NVIEW_Results = handles.NVIEW_Results;
NVIEW_Analysis_Selection = handles.NVIEW_Analysis_Selection;

[NVIEW_Results,NVPRO_Control] = limit_nat_results_as(NVIEW_Results,NVIEW_Control,NVIEW_Analysis_Selection);
NVPRO_Control.ID = define_analysis_selection_id(NVIEW_Analysis_Selection);

% Analysis_Selection_Id defines the observed NAT results
handles.NVIEW_Processed = [];

% Get simulation data
Grid_List = NVPRO_Control.Simulation_Description.Variants;
Timepoints = NVPRO_Control.Simulation_Options.Timepoints_per_dataset;
Datasets = NVPRO_Control.Simulation_Options.Number_of_datasets;

% --------------------------------------------------------------------------
% PROCESS DATA FOR ANALYSIS SELECTION
% --------------------------------------------------------------------------
clear res % Clear variables
for i = 1 : numel(Grid_List)   
    res.(Grid_List{i}).bus = NVIEW_Results.(Grid_List{i}).bus;
    res.(Grid_List{i}).bus_name = NVIEW_Results.(Grid_List{i}).bus_name;
    res.(Grid_List{i}).branch = NVIEW_Results.(Grid_List{i}).branch;
    res.(Grid_List{i}).branch_name = NVIEW_Results.(Grid_List{i}).branch_name;
    
    % VOLTAGE ANALYSIS
    if handles.NVIEW_Control.Simulation_Options.Voltage_Analysis == 1
        clear bus_info voltage_violations voltage_violation_numbers violated_nodes_number
        clear voltage_violation_statistics bus_deviation_summary bus_violations_number  voltage_statistics
        
        bus_voltages = NVIEW_Results.(Grid_List{i}).bus_voltages;
        bus_info = NVIEW_Results.(Grid_List{i}).bus;
        Umin = NVIEW_Analysis_Selection.Umin/100; % pu
        Umax = NVIEW_Analysis_Selection.Umax/100; % pu
        
		[...
			voltage_violations,...
			bus_violations_number,...
			voltage_violation_statistics,...
			voltage_violation_numbers, ...
			violated_nodes_number, ...
			bus_deviation_summary, ...
			voltage_values...
			] = analysis_voltage (bus_voltages, bus_info, Timepoints, Datasets, Umin, Umax);
        
        res.(Grid_List{i}).voltage_violations = voltage_violations;
        res.(Grid_List{i}).bus_violations = bus_violations_number;
        res.(Grid_List{i}).bus_statistics = voltage_violation_statistics;
        res.(Grid_List{i}).bus_violations_at_datasets = voltage_violation_numbers;
        res.(Grid_List{i}).bus_violated_at_datasets = violated_nodes_number;
        res.(Grid_List{i}).bus_deviations = bus_deviation_summary;
		res.(Grid_List{i}).bus_voltages = voltage_values;
        
        clear bus_info voltage_violations bus_voltages voltage_violation_numbers violated_nodes_number counter
        clear voltage_violation_statistics bus_deviations bus_deviation_summary bus_violations_number  nodes_afflicted voltage_values
    end % VOLTAGE ANALYSIS
    
    if handles.NVIEW_Control.Simulation_Options.Overcurrent_Analysis == 1
        clear branch_limits branch_values branch_info branches_afflicted branch_currents branch_violations
        % Branch data
        % 1..From bus, 2..To bus, 3..Vpp from, 4..Vpp to, 5..Vpe from,
        % 6..Vpe to, 7..Ilim (A), 8..Slim (VA)
    
        Ilim = NVIEW_Analysis_Selection.Ilim/100; % pu
        % Values saved in W, VAr, VA and A: [P1 Q1 S1 I1 P2 Q2 S2 I2 P3 Q3 S3 I3 Pe Qe Se Ie]

        branch_values = NVIEW_Results.(Grid_List{i}).branch_values;
        branch_info = NVIEW_Results.(Grid_List{i}).branch;
        
        branches_afflicted = cell(size(branch_values,2),size(branch_values,1));
        branch_currents = zeros(size(branch_values,1),size(branch_values,2),size(branch_values,3),size(branch_values,4),3);
        branch_violations = zeros(size(branch_values,1),size(branch_values,2),size(branch_values,3),size(branch_values,4));
       
       % violated_nodes_number = zeros(size(bus_voltages,2),size(bus_voltages,1));
        
        for s = 1 : size(branch_values,1) % scenario
            for d = 1 : size(branch_values,2) % dataset
                for t = 1 : size(branch_values,3) % timepoint
                    for n = 1 : size(branch_values,4) % branch
                        branch_currents(s,d,t,n,:) = branch_values(s,d,t,n,[4,8,12]);
                        branch_violations(s,d,t,n) = nansum(squeeze(branch_currents(s,d,t,n,:)) > (branch_info(n,7)*Ilim)) > 0;
                        
                    end % node
                    branches_afflicted{d,s} = unique([branches_afflicted{d,s}; find(squeeze(branch_violations(s,d,t,:)) == 1)]);
                end % timepoint
            end % dataset
        end % scenario
        
        branch_violation_numbers = nansum(nansum(branch_violations,4)>0,3);
        for s = 1 : size(branch_values,1) % scenario
            for d = 1 : size(branch_values,2) % dataset
                violated_branches_number(d,s) = numel(branches_afflicted{d,s});
            end
        end
        
        for s = 1 : size(branch_values,1) % scenario
            branch_violation_statistics(:,s) =[sum(branch_violation_numbers(s,:));
                100*sum(branch_violation_numbers(s,:))/(Timepoints*Datasets);
                sum(violated_branches_number(:,s));
                100*sum(violated_branches_number(:,s))/(size(branch_info,1)*Datasets);];
        end
        
        branch_violation_numbers = branch_violation_numbers';
        
        branch_violations_number = zeros(size(branch_values,4),size(branch_values,1));
        for s = 1 : size(branch_values,1) % scenario
            for d = 1 : size(branch_values,2) % dataset
                if ~isempty(branches_afflicted{d,s})
                    for n = 1 : numel(branches_afflicted{d,s})
                        
                        branch_violations_number(branches_afflicted{d,s}(n),s) = branch_violations_number(branches_afflicted{d,s}(n),s) + 1;
                    end
                end
            end
        end
        
        branch_loading_analysis = zeros(size(branch_values,1),size(branch_values,2),size(branch_values,3));
        branch_limits = branch_info(:,7) * Ilim;
        branch_limits(branch_limits > 9999,1) = NaN;
        for s = 1 : size(branch_values,1) % scenario
            for d = 1 : size(branch_currents,2)
                for t = 1 : size(branch_currents,3)  
                    if size(branch_limits,1) ~= 1
                        branch_loading_analysis(s,d,t) = ...
                        nanmean(nanmean( 100* squeeze(branch_currents(s,d,t,:,:)) ./ repmat(branch_limits,1,3),2));
                    else
                        branch_loading_analysis(s,d,t) = ...
                        nanmean(nanmean( 100* squeeze(branch_currents(s,d,t,:,:))' ./ repmat(branch_limits,1,3),2));
                    end
                end
            end
        end
                
        res.(Grid_List{i}).current_violations = branch_violations;
        res.(Grid_List{i}).branch_currents = branch_currents;
        res.(Grid_List{i}).branch_violations = branch_violations_number;
        res.(Grid_List{i}).branch_statistics = branch_violation_statistics;
        res.(Grid_List{i}).branch_violations_at_datasets = branch_violation_numbers;
        res.(Grid_List{i}).branch_violated_at_datasets = violated_branches_number;
        res.(Grid_List{i}).branch_loading_analysis = branch_loading_analysis; 
         
    end
    
    if handles.NVIEW_Control.Simulation_Options.Loss_Analysis == 1
        clear electric_losses branch_info
        electric_losses_at_branch = NVIEW_Results.(Grid_List{i}).loss_statistics;
        
        electric_losses = zeros(size(electric_losses_at_branch,1),size(electric_losses_at_branch,2),size(electric_losses_at_branch,3));
        branch_info = NVIEW_Results.(Grid_List{i}).branch;
         for s = 1 : size(electric_losses_at_branch,1) % scenario
            for d = 1 : size(electric_losses_at_branch,2)
                for t = 1 : size(electric_losses_at_branch,3)  
                    electric_losses(s,d,t) = nansum(electric_losses_at_branch(s,d,t,:));
                end
                electric_losses_at_dataset(d,s) = nansum(squeeze(electric_losses(s,d,:)));
                          
            end
         end
         res.(Grid_List{i}).electric_losses = electric_losses;
         res.(Grid_List{i}).electric_losses_at_dataset = electric_losses_at_dataset;
         
    end

end  % All grids
clear i n d s t
handles.NVIEW_Processed = res;

% Assign Load/Infeed Analysis to NVIEW_Processed
handles.NVIEW_Processed.Input_Data = NVIEW_Results.Input_Data;

% Get analysis selection information and append to NVIEW_Processed
handles.NVIEW_Processed.Control = NVPRO_Control;

handles = update_NVIEW_control_panel_analysis_selection(handles,'NAT Results processed for selected analysis parameters. All results available\n\n');


end

