function handles = network_calculation_MV_controller_active(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 16.06.2014
% Letzte Änderung durch:   Franz Zeilinger - 01.07.2014

handles.Error = 0;

% Zugriff auf Datenobjekt:
d = handles.NAT_Data;
% Current Settings:
cur_set = handles.Current_Settings;
% Simulation Settings:
sim_set = cur_set.Simulation;

if ~(sim_set.Voltage_Violation_Analysis || ...
		sim_set.Branch_Violation_Analysis || ...
		sim_set.Power_Loss_Analysis)
	fprintf('\nNo active analysis function! Abort simulation...\n')
	errordlg('No active analysis function! Abort simulation...');
	return;
end

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

% which data typ has to be simulated?
if cur_set.Data_Extract.get_Sample_Value
	data_typ = '_Sample';
end
if cur_set.Data_Extract.get_Mean_Value
	data_typ = '_Mean';
end
if cur_set.Data_Extract.get_Max_Value
	data_typ = '_Max';
end
if cur_set.Data_Extract.get_Min_Value
	data_typ = '_Min';
end
if cur_set.Data_Extract.get_05_Quantile_Value
	data_typ = '_05P_Quantil';
end
if cur_set.Data_Extract.get_95_Quantile_Value
	data_typ = '_95P_Quantil';
end

fprintf('\nStart with Grid-Calculations...\n');
num_data_set = cur_set.Data_Extract.Number_Data_Sets;

for i=1:numel(Grid_List)
	cur_set.Files.Grid.Name = Grid_List{i}(1:end-4);
    
	% load the network data:
	handles = network_load (handles);
	
	% current grid name
	cg = handles.sin.Settings.Grid_name;
	
	fprintf(['Start with grid-calculation ',num2str(i)',' of ',num2str(numel(Grid_List)),...
		' (',Grid_List{i},')\n']);
	
	% create an empty network substrucure for the results:
	d.Result.(cg) = [];
	% Clear the previous simulation information:
	cur_scen = d.Simulation.Scenario;
	d.Simulation = [];
	d.Simulation.Scenario = cur_scen;
	clear cur_scen;
	
	tic; %Zeitmessung start
	reset_counter = 1;
	for j=1:num_data_set;
		% Reset auf RPC Connection after defnined number of profiles
		% simulted (because of problems, if more profiles are simulated in
		% one row! SINCAL chrushes then!)
		if j > (reset_counter * handles.System.number_max_profiles_simulated)
			fprintf('\t\t\tReset of RPC-Connection...');
			reset_counter = reset_counter + 1;
			% re-load the network data:
			handles = network_load (handles);
			fprintf('\t done!\n');
		end
		
		%----------------------------------------------------------------------------
		% Übernehmen der akutell geladenen Daten:
		%----------------------------------------------------------------------------

		Load_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.(['Data',data_typ]);
		Sola_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.(['Data',data_typ]);
		Elmo_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.(['Data',data_typ]);
		LVGr_Data = d.Load_Infeed_Data.(['Set_',num2str(j)]).LV_Grid_Input.(['Data',data_typ]);
		% Reloading the Settings of the Network, keeping needed data from the GUI:
		try
			idx_emob_ctr = strcmp(cur_set.Table_Network.ColumnName, 'EMob Ctr.');
			cur_set.Table_Network.Data(:,~idx_emob_ctr) = ...
				d.Load_Infeed_Data.(['Set_',num2str(j)]).Table_Network.Data(:,~idx_emob_ctr);
			d.Load_Infeed_Data.(['Set_',num2str(j)]).Table_Network.Data = cur_set.Table_Network.Data;
		catch ME
			fprintf('\t\tError during reloading network table data:\n')
			fprintf(['\t\t',ME.message,'\n']);
			cur_set.Table_Network = d.Load_Infeed_Data.(['Set_',num2str(j)]).Table_Network;
		end
		cur_set.Table_Network = d.Load_Infeed_Data.(['Set_',num2str(j)]).Table_Network;

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =		
		% Debug: generate debug input data:
		if j==1
			factor = 1;
		elseif j==2;
			factor = 1.25;
		else
			factor = 3;
		end
		
		% Debug: set all Values to zero:
		Load_Data = zeros(size(Load_Data));
		Sola_Data = zeros(size(Sola_Data));
		Elmo_Data = zeros(size(Elmo_Data));
		LVGr_Data = zeros(size(LVGr_Data));
		
		idx = 0:15;
		
		idx_1 = [(0:71),(72:-1:1)]';
		idx_1 = idx_1 / max(idx_1);
		idx_2 = [(71:-1:0),(1:1:72)]';
		idx_2 = idx_2 / max(idx_2);
		idx_3 = [idx_1(50:end);idx_1(1:49)];
% 		figure;plot([idx_1,idx_2,idx_3]);
		Elmo_Data(:,idx*6+1) = repmat(idx_1,1,size(Elmo_Data(:,idx*6+1),2))*25000*factor;
		Elmo_Data(:,idx*6+3) = repmat(idx_2,1,size(Elmo_Data(:,idx*6+3),2))*25000*factor;
		Elmo_Data(:,idx*6+5) = repmat(idx_3,1,size(Elmo_Data(:,idx*6+5),2))*25000*factor;
% 		figure;plot(Elmo_Data(:,[1 3 5]+18));
		
		Load_Data(:,1:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
		Load_Data(:,3:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
		Load_Data(:,5:6:end) = ones(size(Load_Data(:,1:6:end))) * 30000;
		LVGr_Data = Load_Data + Elmo_Data;
% 		figure;plot(LVGr_Data(:,[1 3 5]));
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
		d.Load_Infeed_Data.(['Set_',num2str(j)]).Households.(['Data',data_typ]) = Load_Data;
		d.Load_Infeed_Data.(['Set_',num2str(j)]).Solar.(['Data',data_typ]) = Sola_Data;
		d.Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility.(['Data',data_typ]) = Elmo_Data;
		d.Load_Infeed_Data.(['Set_',num2str(j)]).LV_Grid_Input.(['Data',data_typ]) = LVGr_Data;
		
		if isempty(LVGr_Data) && isempty(Load_Data)
			errordlg('Not enough input-Data for simulation!');
			fprintf('\nNo load data found! Abort simulation...\n');
			handles.Error = 1;
			return;
		end
		
		% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
% 		Load_Data = Load_Data/1e6;
		LVGr_Data = LVGr_Data/1e6;
		Elmo_Data = Elmo_Data/1e6;
% 		Sola_Data = Sola_Data/-1e6; %Einspeiser negativ!
		
		% Wieviele Zeitpunkte werden berechnet?
		sim_set.Timepoints = cur_set.Data_Extract.Timepoints_per_dataset;
		
		% Resetting the connection points:
		d.Grid.(cg).P_Q_Node.Points.reset_connections;
		
		% write back maybe altered data:
		cur_set.Simulation = sim_set;
		handles.Current_Settings = cur_set;
		
		%--------------------------------------------------------------------------------
        % Result preallocation
        %--------------------------------------------------------------------------------
        % Options for result preallocation are currently defined within
		% result_preallocation function
		if j == 1
			% We predefine the results for all datasets for specific (cg)
			% grid at first dataset iteration
			handles = result_preallocation(handles,cg);
			
			% Add an error-counter array
			d.Result.(cg).Error_Counter = zeros(num_data_set, sim_set.Timepoints);
		end
		
		% add needed empty fields:
		d.Grid.(cg).Sola.Gen_Units = Unit_Time_Dependent.empty(0,0);
		d.Grid.(cg).Load.Elmob = Unit_Time_Dependent.empty(0,0);
		d.Grid.(cg).Controller.Elmob = Charge_Controller.empty(0,0);
		
		%-----------------------------------------------------------------------------
		% Integrate LV-Grids
		%-----------------------------------------------------------------------------
		d.Grid.(cg).Load.Loads = Unit_Time_Dependent.empty(0,numel(d.Grid.(cg).P_Q_Node.ids));
		% update the grid-numbers:
		idx_lv = strcmp(cur_set.Table_Network.ColumnName, 'LV-Grid');
		data = cur_set.Table_Network.Data(:,idx_lv);
		LV_Grids_List = cur_set.Data_Extract.LV_Grids_List;
		LV_Grids_Number = zeros(numel(LV_Grids_List),1);
		for k=1:numel(LV_Grids_List)
			LV_Grids_Number(k) = sum(strcmp(data,LV_Grids_List{k}));
		end
		
		% prepare additional fields:
		if ~isempty(Elmo_Data)
			d.Grid.(cg).Load.Elmob = Unit_Time_Dependent.empty(0,numel(d.Grid.(cg).P_Q_Node.ids));
			idx_emob_ctr = strcmp(cur_set.Table_Network.ColumnName, 'EMob Ctr.');
			Contr_selector = cell2mat(cur_set.Table_Network.Data(:,idx_emob_ctr));
			d.Grid.(cg).Controller.Elmob = Charge_Controller.empty(0,sum(Contr_selector));
			% get the maximum power of charging of the Profiles (in W):
			Elmo_Data_max = max(Elmo_Data)*1e6;
		end
		
		controler_counter = 1;
		for k=1:numel(d.Grid.(cg).P_Q_Node.ids)
			% Which lv grid should be connected
			lv_grd = cur_set.Table_Network.Data{k,idx_lv};
			% find theses grids in the content list
			idx = find(strcmp(lv_grd,d.Load_Infeed_Data.(['Set_',num2str(j)]).LV_Grid_Input.Content));
			% how many grids are left?
			num_grds = LV_Grids_Number(strcmp(lv_grd,LV_Grids_List));
			% select the last one of these grids:
			idx = idx(num_grds);
			% reduce the number of these grids by one (so the previous grid will be
			% used in the next iteration...)
			LV_Grids_Number(strcmp(lv_grd,LV_Grids_List)) = num_grds - 1;
			% create the load-object
			obj = Unit_Time_Dependent(...
				d.Grid.(cg).P_Q_Node.Points(k),...               % Anschlusspunkt-Objekt
				true,...                                         % Objekt aktiv
				LVGr_Data(:,((idx-1)*6)+1:((idx-1)*6)+6));       % Lastgang des Last
			% 	disp([Grid.P_Q_Node.Points(i).P_Q_Name,' --> ',hh_typ]);
			d.Grid.(cg).Load.Loads(k) = obj;
			if ~isempty(Elmo_Data)
				% create the e-mobility-load-object (just a dummy which holds the
				% information about the power consumption for the controller):
				obj = Unit_Time_Dependent(...
					d.Grid.(cg).P_Q_Node.Points(k),...           % Anschlusspunkt-Objekt
					false,...                                    % Objekt inaktiv
					Elmo_Data(:,((idx-1)*6)+1:((idx-1)*6)+6));   % Lastgang des Last
				d.Grid.(cg).Load.Elmob(k) = obj;
				
				if Contr_selector(k) && sim_set.Controller.El_Mobility.Charge_Controller.Active
					% where is this element connected?
					cn_point = d.Grid.(cg).P_Q_Node.Points(k);
					% find connected branch:
					branch_node_ids_1 = [d.Grid.(cg).Branches.Grouped.Node_1_ID];
					branch_node_ids_2 = [d.Grid.(cg).Branches.Grouped.Node_2_ID];
					
					idx_br = find(branch_node_ids_1 == cn_point.Node_ID);
					if isempty(idx_br)
						idx_br = find(branch_node_ids_2 == cn_point.Node_ID);
					end
					branch = d.Grid.(cg).Branches.Grouped(idx_br);
					
					d.Grid.(cg).Controller.Elmob(controler_counter) = ...
						Charge_Controller(cn_point,...
						'Controlled_Unit', obj,...
						'Connected_Branch', branch,...
						'Max_Power', Elmo_Data_max(:,((idx-1)*6)+1:((idx-1)*6)+6),...
						'Shifting_Factor', sim_set.Controller.El_Mobility.Charge_Controller.Shifting_Factor,...
						'Limit_Factor', sim_set.Controller.El_Mobility.Charge_Controller.Limit_Factor);
					controler_counter = controler_counter + 1;
				end
			end
		end
		clear obj k Elmo_Data num_grds branch idx_br lv_grd idx_lv controler_counter
		clear Contr_selector idx_emob_ctr
		
		if isempty(d.Grid.(cg).Controller.Elmob)
			fprintf('\nNo controller active! Abort Simulation...');
			fprintf('\n================================== \n');
			handles.Error = 1;
			return;
		end
		
		%----------------------------------------------------------------------------
		% Netzberechnungen durchführen:
		%----------------------------------------------------------------------------
		
		% noch die aktuellen Einstellungen speichern:
		d.Simulation.Grid_act = cg;
		d.Simulation.Input_Data_act = j;
		
		fprintf(['\t\tLoadprofile No. ',num2str(j),' of ',...
			num2str(num_data_set),...
			' (',num2str(cur_set.Data_Extract.Timepoints_per_dataset),...
			' Timepoints)']);
		
		% Complete reset of the controllers:
		d.Grid.(cg).Controller.Elmob.reset_controller('total');
		
		for k=1:sim_set.Timepoints
			try
                % aktuellen Zeipunkt speichern:
				d.Simulation.Current_timepoint = k;
				% reset the controllers:
				d.Grid.(cg).Controller.Elmob.reset_controller('in_simulation');
				
				% Last- und Einspeisedaten aktualisieren:
				d.Grid.(cg).Load.Loads.update_power(k);
				d.Grid.(cg).Load.Elmob.update_power(k);
				d.Grid.(cg).Sola.Gen_Units.update_power(k);
				% der Berechnung die neuen Leistungswerte übermitteln:
				d.Grid.(cg).P_Q_Node.Points.update_power;%(cg, j, k, d);
				
				% Lastfluss rechnen:
				handles.sin.start_calculation;
				
				% let the controller work
				d.Grid.(cg).Controller.Elmob.regulate;
				
				% If controller action is detected, make controll cycles till every
				% controller is finished:
				if any([d.Grid.(cg).Controller.Elmob.Control_happened])
					count = 0;
					while (any([d.Grid.(cg).Controller.Elmob.Controller_Active]) && count <= 100)
						% der Berechnung die neuen Leistungswerte übermitteln:
						d.Grid.(cg).P_Q_Node.Points.update_power;%(cg, j, k, d);
						% Lastfluss rechnen:
						handles.sin.start_calculation;
						d.Grid.(cg).Controller.Elmob.regulate;
						count = count + 1;
					end
					% Check, if problems in loop occured:
					if count >= 100
						fprintf('\n100 controll cycles reached!');
						fprintf(['\tCurrently simulating timepoint ',num2str(k)]);
					end
					% Controllers are ready, update their storage:
					d.Grid.(cg).Controller.Elmob.update_storage;
				end
				
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
			catch ME
				d = handles.NAT_Data;
				ct = d.Simulation.Current_timepoint;
				cg = d.Simulation.Grid_act;
				cd = d.Simulation.Input_Data_act;
				if isfield(d.Result.(cg), 'Voltage_Violation_Analysis')
					d.Result.(cg).Voltage_Violation_Analysis(cd,ct,:) = NaN;
				end
				if isfield(d.Result.(cg), 'Node_Voltages')
					d.Result.(cg).Node_Voltages(cd,ct,:,:) = NaN;
				end
				if isfield(d.Result.(cg), 'Branch_Violation_Analysis')
					 d.Result.(cg).Branch_Violation_Analysis(cd,ct,:) = NaN;
				end
				if isfield(d.Result.(cg), 'Branch_Values')
					d.Result.(cg).Branch_Values(cd,ct,:,:) = NaN;
				end
				d.Result.(cg).Error_Counter(cd,ct) = d.Result.(cg).Error_Counter(cd,ct) + 1;
				% Give Informations about the occoured error:
				
				fprintf(['\t\t\t', strrep(ME.message, sprintf('\n'),'')]);
				fprintf(['\t\t\t\tCurrently simulating timepoint ',num2str(ct),'\n']);
				for l=1:3
					fprintf(['\t\t\t\tfile: ',regexprep(ME.stack(l).file, '\\', '\\\\'),...
						'; name: ',ME.stack(l).name,...
						'; line: ',num2str(ME.stack(l).line),'\n']);
				end
			end
		end
		
		% Statusinfo zum Gesamtfortschritt an User:
		t = toc;
		fprintf([' finished. Elapsed time: ',...
			sec2str(t),...
			'. Remaining time: ',...
			sec2str(t/(j/num_data_set) - t),'\n']);
		err_count = sum(d.Result.(cg).Error_Counter(j,:));
		if err_count > 0
			fprintf(['\t\t\tDuring the calculations ',...
				num2str(err_count),' errors occured!\n']);
		end
	end
	
	% select again the first grid (because here the load-& infeeeddata is
	% stored):
	cur_set.Files.Grid.Name = Grid_List{1}(1:end-4);
	
	% write back maybe altered data:
	cur_set.Simulation = sim_set;
	handles.Current_Settings = cur_set;
end

