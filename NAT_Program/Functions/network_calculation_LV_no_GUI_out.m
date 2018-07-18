function handles = network_calculation_LV_no_GUI_out (handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 3.3
% Erstellt von:            Franz Zeilinger - 05.02.2013
% Letzte Änderung durch:   Franz Zeilinger - 18.07.2018

% Zugriff auf Datenobjekt und sontige handler:
nd = handles.NAT_Data;
mh = handles.text_message_main_handler;
wb = handles.waitbar_main_handler;

% get the Current Settings:
cur_set = handles.Current_Settings;
dat_ext = cur_set.Data_Extract;
sim_set = cur_set.Simulation;

% getting infos about the grids to be simulated:
Grid_List = sim_set.Grid_List;
Grids_Path = sim_set.Grids_Path;
% If just one grid has to be simulated, adopt the informations of this one
% grid:
if isempty(sim_set.Grid_List)
	Grid_List{1} = [cur_set.Files.Grid.Name,...
		cur_set.Files.Grid.Exte];
	Grids_Path = cur_set.Files.Grid.Path;
elseif ~sim_set.Use_Grid_Variants
	Grid_List = Grid_List(1);
end

cur_set.Files.Grid.Path = Grids_Path;
clear Grids_Path

mh.add_info('Grid-Calculations are using datatyp "',sim_set.Data_typ(2:end),'" with ',dat_ext.Timepoints_per_dataset,...
	' timepoints.');
mh.level_up; %1
num_data_set = dat_ext.Number_Data_Sets;

% Iterate over all grids
linemarker_grid_sim_started = mh.mark_current_displayline();
grid_counter_timer = tic();
wb.add_end_position('grid_counter',numel(Grid_List));
for grid_counter=1:numel(Grid_List)
	wb.update_counter('grid_counter', grid_counter);
	
	% Set the current Grid
	cg = Grid_List{grid_counter}(1:end-4);
	cur_set.Files.Grid.Name = cg;
	handles.Current_Settings = cur_set;
	
	if numel(Grid_List) > 1
		mh.add_line('Start with grid-calculation ',num2str(grid_counter)',' of ',num2str(numel(Grid_List)),...
			' (',cg,')...');
	else
		mh.add_line('Start with grid-calculation',' (',cg,')...');
	end
	mh.level_up; %2
	
	% load the network data:
	handles = network_load (handles);
	
	% create an empty network substrucure for the results:
	nd.Result.(cg) = [];
	if sim_set.Use_Scenarios
		% Clear the previous simulation information:
		cur_scen = nd.Simulation.Scenario;
		nd.Simulation = [];
		nd.Simulation.Scenario = cur_scen;
		clear cur_scen;
	else
		nd.Simulation = [];
		nd.Simulation.Scenario = 'No_Scenario';
	end
	
	%--------------------------------------------------------------------------------
	% Result preallocation
	%--------------------------------------------------------------------------------
	% Options for result preallocation are currently defined within
	% result_preallocation function
	% We predefine the results for all datasets for specific (cg)
	% grid at first dataset iteration
	handles = result_preallocation(handles,cg);
	
	reset_counter = 1;
	linemarker_dataset_sim_started = mh.mark_current_displayline();
	dataset_counter_timer = tic; %Zeitmessung start
	wb.add_end_position('dataset_counter',num_data_set);
	for dataset_counter=1:num_data_set
		wb.update_counter('dataset_counter', dataset_counter);
		
		% Reset auf RPC Connection after defnined number of profiles
		% simulted (because of problems, if more profiles are simulated in
		% one row! SINCAL chrushes then!)
		if dataset_counter > (reset_counter * handles.System.number_max_profiles_simulated)
			mh.add_line('Reset of RPC-Connection...');
			mh.level_up;%3
			reset_counter = reset_counter + 1;
			% re-load the network data:
			handles = network_load (handles);
			mh.level_down();%2
			mh.add_line('...done!');
		end
		
		mh.add_line('Using set No. ',dataset_counter,' of ', num_data_set,' ...');
		mh.level_up();%3
		drawnow();
		
		% Wieviele Zeitpunkte werden berechnet?
		sim_set.Timepoints = dat_ext.Timepoints_per_dataset;
		
		% write back maybe altered data:
		cur_set.Simulation = sim_set;
		handles.Current_Settings = cur_set;
		
		%----------------------------------------------------------------------------
		% Übernehmen der akutell geladenen Daten
		%----------------------------------------------------------------------------
		nd = network_insert_LV_loadinfeed_data(nd, cg, sim_set.Data_typ, dataset_counter);
		
		%----------------------------------------------------------------------------
		% Netzberechnungen durchführen
		%----------------------------------------------------------------------------
		% noch die aktuellen Einstellungen speichern:
		nd.Simulation.Grid_act = cg;
		nd.Simulation.Input_Data_act = dataset_counter;
		
		mh.add_line('Load profile simulation started.');
		linemarker_time_sim_started = mh.mark_current_displayline();
		
% 		wb.add_end_position('timepoint_counter',sim_set.Timepoints);
		for timepoint_counter=1:sim_set.Timepoints
% 			wb.update_counter('timepoint_counter', timepoint_counter);
			
			try
				% aktuellen Zeipunkt speichern:
				nd.Simulation.Current_timepoint = timepoint_counter;
				
				% Last- und Einspeisedaten aktualisieren:
				nd.Grid.(cg).Load.Loads.update_power(timepoint_counter);
				nd.Grid.(cg).Load.Elmob.update_power(timepoint_counter);
				nd.Grid.(cg).Sola.Gen_Units.update_power(timepoint_counter);
				% der Berechnung die neuen Leistungswerte übermitteln:
				nd.Grid.(cg).P_Q_Node.Points.update_power;%(cg, j, k, nd);
				
				% Lastfluss rechnen:
				handles.sin.start_calculation;
				
				% here the analyzing functions are called. Because the data is stored
				% within the NAT_Data-object, on which this function has access, no
				% return value is neccesary:
				
				% Perform online voltage violation analysis (true/false
				% results)
				if sim_set.Voltage_Violation_Analysis
					online_voltage_violation_analysis(handles);
					% An additional condition for saving voltages is
					% inside the online function
				end
				
				% Perform online branch violation analysis (true/false results)
				if sim_set.Branch_Violation_Analysis
					online_branch_violation_analysis(handles);
					if sim_set.Save_Branch_Results
						% Save branch results in result structure
						save_branch_values(handles);
					end
				end
				
				% Perform online active power loss analysis (values in W)
				if sim_set.Power_Loss_Analysis
					online_power_loss_analysis(handles);
					% An additional condition for power loss saving is
					% inside the online function
				end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%               % For Testing Purposes:
%   				pause(0.001);
% 				if timepoint_counter == 207 % i == 1 && j==2 && timepoint_counter == 207
% 					errorstr = 'Test Error thrown';
% 					exception = MException(...
% 						'NAT:NetworkCalculationLV:ErrorDuringCalculation',...
% 						errorstr);
% 					throw(exception);
% 				end
% 				if timepoint_counter == 727 % i == 1 && j==2 && timepoint_counter == 727
% 					errorstr = 'Another test Error thrown';
% 					exception = MException(...
% 						'NAT:NetworkCalculationLV:ErrorDuringCalculation',...
% 						errorstr);
% 					throw(exception);
% 				end
% 				
% 				if timepoint_counter == 2 % j==4 && timepoint_counter == 2
% 					errorstr = 'Test Error at Beginning thrown';
% 					exception = MException(...
% 						'NAT:NetworkCalculationLV:ErrorDuringCalculation',...
% 						errorstr);
% 					throw(exception);
% 				end
% 				if timepoint_counter == 777 % j==4 && timepoint_counter == 777
% 					errorstr = 'Another test Error thrown';
% 					exception = MException(...
% 						'NAT:NetworkCalculationLV:ErrorDuringCalculation',...
% 						errorstr);
% 					throw(exception);
% 				end
% 				if timepoint_counter == 1435 % j==4 && timepoint_counter == 1435
% 					errorstr = 'Test Error at the end thrown';
% 					exception = MException(...
% 						'NAT:NetworkCalculationLV:ErrorDuringCalculation',...
% 						errorstr);
% 					throw(exception);
% 				end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			catch ME
				% If canceled by user, leave function:
				if strcmp(ME.identifier,'NAT:NetworkCalculationLV:CanceledByUser')
					rethrow(ME);
				end
				nd = handles.NAT_Data;
				ct = nd.Simulation.Current_timepoint;
				cg = nd.Simulation.Grid_act;
				cd = nd.Simulation.Input_Data_act;
				if isfield(nd.Result.(cg), 'Voltage_Violation_Analysis')
					nd.Result.(cg).Voltage_Violation_Analysis(cd,ct,:) = NaN;
				end
				if isfield(nd.Result.(cg), 'Node_Voltages')
					nd.Result.(cg).Node_Voltages(cd,ct,:,:) = NaN;
				end
				if isfield(nd.Result.(cg), 'Branch_Violation_Analysis')
					nd.Result.(cg).Branch_Violation_Analysis(cd,ct,:) = NaN;
				end
				if isfield(nd.Result.(cg), 'Branch_Values')
					nd.Result.(cg).Branch_Values(cd,ct,:,:) = NaN;
				end
				nd.Result.(cg).Error_Counter(cd,ct) = nd.Result.(cg).Error_Counter(cd,ct) + 1;
				% Give Informations about the occoured error:
				mh.level_up();%4
				mh.add_error('Currently simulating timepoint ',ct);
				mh.add_error(strrep(ME.message, sprintf('\n'), ''));
				for l=1:3
					mh.level_up();%5
					mh.add_line('in "',ME.stack(l).name,...
						'" (line: ',ME.stack(l).line,')');
					mh.level_down();%4
				end
				mh.level_down();%3
			end
		end
		
		mh.set_display_back_to_marker(linemarker_dataset_sim_started, false);
		
		error_all_count = sum(sum(nd.Result.(cg).Error_Counter));
		if error_all_count > 0
			mh.level_down();%2
			mh.add_error('During the calculations ',...
				error_all_count,' errors occured!');
			mh.level_up();%3
		end
		
		mh.level_down();%2
		t = toc(dataset_counter_timer);
		if dataset_counter < num_data_set
			mh.add_line('Set No. ',dataset_counter,' of ', num_data_set,' finished. Runtime: ',...
				sec2str(t),...
				'. Remaining: ',...
				sec2str(t/(dataset_counter/num_data_set) - t));
		else
			mh.level_down();%1
			mh.add_line('... ',num_data_set,' sets done (in ',sec2str(t),')!');
		end
		mh.reset_display_marker(linemarker_time_sim_started);
		wb.update();
	end
	
	mh.set_display_back_to_marker(linemarker_grid_sim_started, true);
	
	error_all_count = 0;
	for done_grid_counter = 1 : grid_counter
		error_all_count = error_all_count + sum(sum(nd.Result.(Grid_List{done_grid_counter}(1:end-4)).Error_Counter));
	end
	if error_all_count > 0
		mh.add_error('During the calculations ',...
			error_all_count,' errors occured!');
	end
	
	if grid_counter < numel(Grid_List)
		tg = toc(grid_counter_timer);
		mh.add_line('Grid No. ',grid_counter,' of ', numel(Grid_List),' finished. Runtime: ',...
			sec2str(tg),...
			'. Remaining: ',...
			sec2str(tg/(grid_counter/numel(Grid_List)) - tg));
	elseif grid_counter == numel(Grid_List)
		tg = toc(grid_counter_timer);
		mh.add_line('Grid No. ',grid_counter,' of ', numel(Grid_List),' finished. Runtime: ',...
			sec2str(tg));
	end
	
	mh.reset_display_marker(linemarker_dataset_sim_started);
	% select again the first grid (because here the load-& infeeeddata is
	% stored):
	cur_set.Files.Grid.Name = Grid_List{1}(1:end-4);
	
	% write back maybe altered data:
	cur_set.Simulation = sim_set;
	handles.Current_Settings = cur_set;
end
mh.reset_display_marker(linemarker_grid_sim_started);
end

