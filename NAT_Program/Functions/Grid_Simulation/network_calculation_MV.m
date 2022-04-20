function handles = network_calculation_MV(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 2.0
% Erstellt von:            Franz Zeilinger - 05.02.2013
% Letzte Änderung durch:   Franz Zeilinger - 29.01.2019

% Zugriff auf Datenobjekte:
nd = handles.NAT_Data;
mh = handles.text_message_main_handler;
ch = handles.cancel_button_main_handler;
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

% give the user feedback 25 times during the simulation of one profile:
num_gui_update = floor(dat_ext.Timepoints_per_dataset/25);


% which data typ has to be simulated?
% if cur_set.Simulation.use_Sample_Value
% 	data_typ = '_Sample';
% end
% if cur_set.Simulation.use_Mean_Value
% 	data_typ = '_Mean';
% end
% if cur_set.Simulation.use_Max_Value
% 	data_typ = '_Max';
% end
% if cur_set.Simulation.use_Min_Value
% 	data_typ = '_Min';
% end
% if cur_set.Simulation.use_05_Quantile_Value
% 	data_typ = '_05P_Quantil';
% end
% if cur_set.Simulation.use_95_Quantile_Value
% 	data_typ = '_95P_Quantil';
% end

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
	mh.level_up; 
	
	% load the network data:
	handles = network_load (handles);
	
	% current grid name
	cg = handles.sin.Settings.Grid_name;
	
	fprintf(['Start with grid-calculation ',num2str(grid_counter)',' of ',num2str(numel(Grid_List)),...
		' (',cg,')\n']);
	
	% create an empty network substrucure for the results:
	nd.Result.(cg) = [];
	% Clear the previous simulation information:
	cur_scen = nd.Simulation.Scenario;
	nd.Simulation = [];
	nd.Simulation.Scenario = cur_scen;
	clear cur_scen;
	
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
			mh.level_up;
			reset_counter = reset_counter + 1;
			% re-load the network data:
			handles = network_load (handles);
			mh.level_down();
			mh.add_line('...done!');
		end
		
		mh.add_line('Using set No. ',dataset_counter,' of ', num_data_set,' ...');
		mh.level_up();
		drawnow();
		
		%----------------------------------------------------------------------------
		% Übernehmen der akutell geladenen Daten:
		%----------------------------------------------------------------------------

		Load_Data = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Households.(['Data',sim_set.Data_typ]);
		Sola_Data = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Solar.(['Data',sim_set.Data_typ]);
		Elmo_Data = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).El_Mobility.(['Data',sim_set.Data_typ]);
		LVGr_Data = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).LV_Grid_Input.(['Data',sim_set.Data_typ]);
		cur_set.Table_Network = nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Table_Network;

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =		
% 		% Debug: generate debug input data:
% 		if dataset_counter==1
% 			factor = 1;
% 		elseif dataset_counter==2;
% 			factor = 1.25;
% 		else
% 			factor = 3;
% 		end
% 		
% 		% Debug: set all Values to zero:
% 		Load_Data = zeros(size(Load_Data));
% 		Sola_Data = zeros(size(Sola_Data));
% 		Elmo_Data = zeros(size(Elmo_Data));
% 		LVGr_Data = zeros(size(LVGr_Data));
% 		
% 		idx = 0:15;
% 		
% 		idx_1 = [(0:71),(72:-1:1)]';
% 		idx_1 = idx_1 / max(idx_1);
% 		idx_2 = [(71:-1:0),(1:1:72)]';
% 		idx_2 = idx_2 / max(idx_2);
% 		idx_3 = [idx_1(50:end);idx_1(1:49)];
% % 		figure;plot([idx_1,idx_2,idx_3]);
% 		Elmo_Data(:,idx*6+1) = repmat(idx_1,1,size(Elmo_Data(:,idx*6+1),2))*25000*factor;
% 		Elmo_Data(:,idx*6+3) = repmat(idx_2,1,size(Elmo_Data(:,idx*6+3),2))*25000*factor;
% 		Elmo_Data(:,idx*6+5) = repmat(idx_3,1,size(Elmo_Data(:,idx*6+5),2))*25000*factor;
% % 		figure;plot(Elmo_Data(:,[1 3 5]+18));
% 		
% 		Load_Data(:,1:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
% 		Load_Data(:,3:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
% 		Load_Data(:,5:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
% 		LVGr_Data = Load_Data + Elmo_Data;
% % 		figure;plot(LVGr_Data(:,[1 3 5]));
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =	

		if ~isempty(Load_Data)
			[Load_Data, Sola_Data, Elmo_Data] = adapt_input_data(Load_Data, Sola_Data, Elmo_Data);
		end
		
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
		% Quick Add-in: If a day is simulated in seconds resolution, just simulate a
		% few hours:
		curtailed_data = false; 
		if size(Load_Data,1) > 86000
			curtailed_data = true;
			% section of day to be simulated in h:
			time_start = 7;
			time_end = time_start + 6;
			time_start = time_start*60*60;
			time_end = time_end*60*60;
			Load_Data = Load_Data(time_start:time_end,:);
			cur_set.Data_Extract.Time_Series.Date_Start = time_start/(24*60*60);
			cur_set.Data_Extract.Time_Series.Duration = (time_end - time_start)/(24*60*60);
			cur_set.Data_Extract.Timepoints_per_dataset = size(Load_Data,1);
		end
		cur_set.Data_Extract.Time_Series.curtailed_data = curtailed_data;
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 		
		
        % Save the maybe altered Data for the NVIEW-Programm:
		nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Households.(['Data',sim_set.Data_typ]) = Load_Data;
		nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).Solar.(['Data',sim_set.Data_typ]) = Sola_Data;
		nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).El_Mobility.(['Data',sim_set.Data_typ]) = Elmo_Data;
		nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).LV_Grid_Input.(['Data',sim_set.Data_typ]) = LVGr_Data;
		
		if isempty(LVGr_Data) && isempty(Load_Data)
			errordlg('Not enough input-Data for simulation!');
			fprintf('\nNo load data found! Abort simulation...\n')
			return;
		end
		
		% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
% 		Load_Data = Load_Data/1e6;
		LVGr_Data = LVGr_Data/1e6;
% 		Elmo_Data = Elmo_Data/1e6;
% 		Sola_Data = Sola_Data/-1e6; %Einspeiser negativ!
		
		% Wieviele Zeitpunkte werden berechnet?
		sim_set.Timepoints = cur_set.Data_Extract.Timepoints_per_dataset;
		
		% Resetting the connection points:
		nd.Grid.(cg).P_Q_Node.Points.reset_connections;
		
		% write back maybe altered data:
		cur_set.Simulation = sim_set;
		handles.Current_Settings = cur_set;
		
		%--------------------------------------------------------------------------------
        % Result preallocation
        %--------------------------------------------------------------------------------
        % Options for result preallocation are currently defined within
		% result_preallocation function
		if dataset_counter == 1
			% We predefine the results for all datasets for specific (cg)
			% grid at first dataset iteration
			handles = result_preallocation(handles,cg);
			
			% Add an error-counter array
			nd.Result.(cg).Error_Counter = zeros(num_data_set, sim_set.Timepoints);
		end
		
		%-----------------------------------------------------------------------------
		% Integrate LV-Grids
		%-----------------------------------------------------------------------------
		nd.Grid.(cg).Load.Loads = Unit_Time_Dependent.empty(0,numel(nd.Grid.(cg).P_Q_Node.ids));
		% update the grid-numbers:
		idx_lv = strcmp(cur_set.Table_Network.ColumnName, 'LV-Grid');
		data = cur_set.Table_Network.Data(:,idx_lv);
		LV_Grids_List = cur_set.Data_Extract.LV_Grids_List;
		LV_Grids_Number = zeros(numel(LV_Grids_List),1);
		for k=1:numel(LV_Grids_List)
			LV_Grids_Number(k) = sum(strcmp(data,LV_Grids_List{k}));
		end
		
		for k=1:numel(nd.Grid.(cg).P_Q_Node.ids)
			% Which lv grid should be connected
			lv_grd = cur_set.Table_Network.Data{k,idx_lv};
			% find theses grids in the content list
			idx = find(strcmp(lv_grd,nd.Load_Infeed_Data.(['Set_',num2str(dataset_counter)]).LV_Grid_Input.Content));
			% how many grids are left?
			num_grds = LV_Grids_Number(strcmp(lv_grd,LV_Grids_List));
			% select the last one of these grids:
			idx = idx(num_grds);
			% reduce the number of these grids by one (so the previous grid will be
			% used in the next iteration...)
			LV_Grids_Number(strcmp(lv_grd,LV_Grids_List)) = num_grds - 1;
			% create the load-object
			obj = Unit_Time_Dependent(...
				nd.Grid.(cg).P_Q_Node.Points(k),...               % Anschlusspunkt-Objekt
				true,...                                         % Objekt aktiv
				LVGr_Data(:,((idx-1)*6)+1:((idx-1)*6)+6));       % Lastgang des Last
			% 	disp([Grid.P_Q_Node.Points(grid_counter).P_Q_Name,' --> ',hh_typ]);
			nd.Grid.(cg).Load.Loads(k) = obj;
		end
		clear obj k Elmo_Data num_grds branch idx_br lv_grd idx_lv controler_counter
		clear Contr_selector idx_emob_ctr
		
		%----------------------------------------------------------------------------
		% Netzberechnungen durchführen:
		%----------------------------------------------------------------------------
		
		% noch die aktuellen Einstellungen speichern:
		nd.Simulation.Grid_act = cg;
		nd.Simulation.Input_Data_act = dataset_counter;
		
		mh.add_line('Load profile simulation started.');
		linemarker_time_sim_started = mh.mark_current_displayline();
		
		
		timepoint_counter_timer = tic;
		wb.add_end_position('timepoint_counter',sim_set.Timepoints);
		for timepoint_counter=1:sim_set.Timepoints
			wb.update_counter('timepoint_counter', timepoint_counter);
			
			try
                % aktuellen Zeipunkt speichern:
				nd.Simulation.Current_timepoint = timepoint_counter;
				
				% Last- und Einspeisedaten aktualisieren:
				nd.Grid.(cg).Load.Loads.update_power(timepoint_counter);
				% der Berechnung die neuen Leistungswerte übermitteln:
				nd.Grid.(cg).P_Q_Node.Points.update_power;%(cg, dataset_counter, timepoint_counter, nd);
				
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
				
				if mod(timepoint_counter,num_gui_update) == 0
					% Statusinfo zum Gesamtfortschritt an User:
					wb.update();
					err_count = sum(nd.Result.(cg).Error_Counter(dataset_counter,:));
					mh.set_display_back_to_marker(linemarker_time_sim_started, false);
					if err_count > 0
						mh.add_error(err_count,' error(s) occured during calculations!');
					end
					mh.add_line(timepoint_counter,' Timepoints calculated (',100*timepoint_counter/sim_set.Timepoints,'%).');
					t = toc(timepoint_counter_timer);
					progress = timepoint_counter/sim_set.Timepoints;
					time_elapsed = t/progress - t;
					if timepoint_counter < sim_set.Timepoints
						mh.level_up();%4
						mh.add_line('Runtime: ', sec2str(t),'. Remaining: ',...
							sec2str(time_elapsed));
						mh.level_down();%3
					end
					mh.write_sub_logs();
					if ch.was_cancel_pushed()
						% Cancel Button pushed!
						errorstr = 'Simulation canceled by user!';
						mh.add_line(errorstr);
						exception = MException(...
							'NAT:NetworkCalculationLV:CanceledByUser',...
							errorstr);
						throw(exception);
					end
				end
				
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
				mh.level_up();
				mh.add_error('Currently simulating timepoint ',ct);
				mh.add_error(strrep(ME.message, newline, ''));
				for l=1:3
					mh.level_up();
					mh.add_line('in "',ME.stack(l).name,...
						'" (line: ',ME.stack(l).line,')');
					mh.level_down();
				end
				mh.level_down();
			end
		end
		
		% Statusinfo zum Gesamtfortschritt an User:
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

