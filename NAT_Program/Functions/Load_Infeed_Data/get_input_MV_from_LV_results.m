function [handles, error] = get_input_MV_from_LV_results(handles)
%GET_INPUT_FROM_RESULTS    creates input for MV-Grid out of LV-Grid-Simulation Results
%   Detailed explanation goes here

mh = handles.text_message_main_handler;

Result_Settings = handles.Result_Settings;
warning_user = 0;
error = 0;

% get important settings:
LV_Grids_List = handles.Current_Settings.Data_Extract.LV_Grids_List;
MV_input_generation_in_progress = handles.Current_Settings.Data_Extract.MV_input_generation_in_progress;

% Reload the data extraktion settings:
handles.Current_Settings.Data_Extract = Result_Settings.Data_Extract;

% Check, if a Subfolder for input-data within the current grid-folder is avaliable:
if ~MV_input_generation_in_progress
	if isempty(handles.Current_Settings.Simulation.Grid_List)
		path = [handles.Current_Settings.Files.Grid.Path,filesep,...
			handles.Current_Settings.Files.Grid.Name,'_nat'];
	else
		path = handles.Current_Settings.Simulation.Grids_Path;
	end
	if ~isfolder([path,filesep,'Load_Infeed_Data_f_Scenarios'])
		mkdir([path,filesep,'Load_Infeed_Data_f_Scenarios']);
	end
	% Create a Subfolder for the extracted data, containing the extraction-moment:
	handles.Current_Settings.Data_Extract.Date_Extraktion = now();
	handles.Current_Settings.Simulation.Scenarios_Path = [...
		path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,...
		datestr(handles.Current_Settings.Data_Extract.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS'),...
		];
	mkdir(handles.Current_Settings.Simulation.Scenarios_Path);
	mh.mark_sub_log([handles.Current_Settings.Simulation.Scenarios_Path,filesep,'Log.log']);
end

mh.add_line('Using data specified in "',...
	handles.Current_Settings.Files.Load.Result.Name,...
	'" from "',...
	handles.Current_Settings.Files.Load.Result.Path,'".');

% Use the datatyp an number of sets out of the simulation, also set this in
% the data extraction part of the current settings:
datatyps = {...
	'Sample_Value'     ,'_Sample';...
	'Mean_Value'       ,'_Mean';...
	'Max_Value'        ,'_Max';...
	'Min_Value'        ,'_Min';...
	'05_Quantile_Value','_05P_Quantil';...
	'95_Quantile_Value','_95P_Quantil';...
	};
sel_datatyp = 0;
for a=1:size(datatyps,1)
	if Result_Settings.Simulation.(['use_',datatyps{a,1}])
		data_typ = datatyps{a,2};
		handles.Current_Settings.Data_Extract.(['get_',datatyps{a,1}])=1;
		sel_datatyp = a;
	else
		handles.Current_Settings.Data_Extract.(['get_',datatyps{a,1}])=0;
	end
end
handles.Current_Settings.Data_Extract.Grid_type = handles.Current_Settings.Grid.Type;
mh.add_line('Datatyp in results is "',datatyps{sel_datatyp,1},'"');
mh.add_line(handles.Current_Settings.Data_Extract.Number_Data_Sets,' Datasets are present');

% % Reset the network table:
% [handles.Current_Settings.Table_Network, ...
% 	handles.Current_Settings.Data_Extract] = network_table_reset(handles);

% just quick check, if the correct kind of grid is present:
if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	errorstr = 'Wrong destination grid!';
	mh.add_error(errorstr);
	exception = MException(...
		'NAT:GetInputMVfromLVResults:WrongDestinationGrid',...
		errorstr);
	throw(exception);
end

% update the grid-numbers:
idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
data = handles.Current_Settings.Table_Network.Data(:,idx_lv);
LV_Grids_Number = zeros(numel(LV_Grids_List),1);
for i=1:numel(LV_Grids_List)
	LV_Grids_Number(i) = sum(strcmp(data,LV_Grids_List{i}));
end
clear data idx_lv

% User dialog to get information about the generation-process:
if 	~MV_input_generation_in_progress && ...
		(isempty(LV_Grids_List) || sum(LV_Grids_Number) == 0)
	% no grid allocation is present
	mh.add_line('Ask user about LV-grid allocation...');
	mh.level_up();
	answer = questdlg({'Another question:';...
		'';...
		[...
		'Do you want the allocation of the lv-grids be generated randomly, ',...
		'or do you want to make the allocation previously (just load ',...
		'the the available lv-grids)?'...
		];...
		'';...
		'Please specify desired procedure:'},...
		'Specifying data generation procedure',...
		'Random allo.', 'Make allo.', 'Make allo.');
	if isempty(answer)
		mh.add_line('Canceled by user.');
		error = 1;
		return;
	end
	mh.add_line('"',answer,'" was selected');
	mh.level_down();
elseif MV_input_generation_in_progress &&...
		(isempty(LV_Grids_List) || sum(LV_Grids_Number) == 0)
	errorstr1 = 'No valid lv-grid-allocation found! ';
	errorstr2 = 'Please specify the lv-grid allocation in the main-GUI!';
	mh.add_error(errorstr1,errorstr2)
	errordlg({errorstr1;errorstr2},'Specifying data generation procedure');
	error = 1;
	return;
elseif 	~MV_input_generation_in_progress
	mh.add_line('Ask user about LV-grid allocation...');
	mh.level_up();
	answer = questdlg({'Another question:';...
		'';...
		[...
		'Do you want the allocation of the lv-grids be generated randomly, ',...
		'should the current allocation in the main-GUI be used (column "LV-Grid" in ',...
		'Node-Table) or do you want to make the allocation previously (just load ',...
		'the the available lv-grids)?'...
		];...
		'';...
		'Please specify desired procedure:'},...
		'Specifying data generation procedure',...
		'Random allo.', 'Use GUI allo.', 'Make allo.', 'Use GUI allo.');
	if isempty(answer)
		mh.add_line('Canceled by user.');
		error = 1;
		return;
	end
	mh.add_line('"',answer,'" was selected');
	mh.level_down();
end

if 	~MV_input_generation_in_progress
	% load 'Grid' from first scenario (for grid properties):
	load([handles.Current_Settings.Files.Load.Result.Path,filesep,Result_Settings.Result_Files{1}],'Grid');
	
	% Get the simulated grid names:
	mh.add_line('Selection of the grids to be used by user...');
	LV_Grids_List = fields(Grid);
	if numel(LV_Grids_List) > 1
		[Grid_Sel,Scen_ok] = listdlg(...
			'ListString',LV_Grids_List,...
			'Name','Selection of the grid variants to be used',...
			'PromptString',...
			{...
			'Selection of the grid variants, which should be available for ';...
			' allocation (multiple selection possible):';...
			},...
			'CancelString','Vorgang abbr.',...
			'ListSize', [320, 300]);
		if ~Scen_ok
			mh.add_line('Canceled by user.');
			error = 1;
			return;
		end
	else
		Grid_Sel = 1;
	end
	% Output of selected grids:
	mh.add_listselection(LV_Grids_List, Grid_Sel);
	
	% Save the Grid-List for later allocation of the single grids to MV-Connection points:
	LV_Grids_List = LV_Grids_List(Grid_Sel);
	
	% Update the pull-down-menues of the network-table and handles-structure
	idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
	handles.Current_Settings.Table_Network.ColumnFormat{idx_lv} = [handles.System.lv_grids(1,2),LV_Grids_List'];
	handles.Current_Settings.Data_Extract.LV_Grids_List = LV_Grids_List;
	handles.Current_Settings.Data_Extract.LV_Grids_Number = LV_Grids_Number;
	
	if strcmp(answer, 'Make allo.')
		% the user wants to go back to the main GUI to make the allocation of the lv-grids
		% manually, so leave this function:
		mh.add_line('LV-grid allocation has to be made in NAT GUI...');
		handles.Current_Settings.Data_Extract.MV_input_generation_in_progress = 1;
		return;
	end
	
	if strcmp(answer, 'Random allo.')
		mh.add_line('LV-grid allocation is made randomly.');
		idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
		num_dif_grds = numel(LV_Grids_List);
		for i=1:numel(handles.Current_Settings.Table_Network.Data(:,idx_lv))
			% draw a random number
			sel = floor(rand()*num_dif_grds)+1;
			handles.Current_Settings.Table_Network.Data{i,idx_lv} = LV_Grids_List{sel};
		end
	end
end

% update the grid-numbers:
idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
data = handles.Current_Settings.Table_Network.Data(:,idx_lv);
LV_Grids_Number = zeros(numel(LV_Grids_List),1);
for i=1:numel(LV_Grids_List)
	LV_Grids_Number(i) = sum(strcmp(data,LV_Grids_List{i}));
end
clear data idx_lv

% User dialogs to select the desired settings of Data
mh.add_line('Selection of the scenarios to be used by user...');
[Scen_Sel,Scen_ok] = listdlg (...
	'ListString',Result_Settings.Simulation.Scenarios.Names,...
	'Name','Auswahl der zu extrahierenden Szenarios',...
	'PromptString',{'Auswahl der zu extrahierenen Szenarios';...
	' (Mehrfachauswahl m�glich):'},...
	'CancelString','Vorgang abbr.',...
	'ListSize', [320, 300]);
if ~Scen_ok
	error = 1;
	return;
end

% adapt the Scenario-Settings according to the selection:
scen_old = Result_Settings.Simulation.Scenarios;
scen_new.Number = numel(Scen_Sel);
scen_new.Names = cell(1,scen_new.Number);
for i=1:scen_new.Number
	scen_new.Names{i} = scen_old.Names{Scen_Sel(i)};
	scen_new.(['Sc_',num2str(i)]) = scen_old.(['Sc_',num2str(Scen_Sel(i))]);
end
scen_new.Data_avaliable = 1;
handles.Current_Settings.Simulation.Scenarios = scen_new;
% mark all scenarios as active for simulation:
handles.Current_Settings.Simulation.Scenarios_Selection = [];
% Output of selected scenarios:
mh.add_listselection(scen_old.Names, Scen_Sel);
clear i scen_old Scen_ok

% load data from first scenario (for grid properties), without 'Debug':
load([handles.Current_Settings.Files.Load.Result.Path,filesep,Result_Settings.Result_Files{Scen_Sel(1)}],...
	'Grid','Load_Infeed_Data','Result');

% let the user select the point of each grid, from where the Power Data
% should be used (Transformers):
mh.add_line('Prepare simulation data...');
mh.level_up();
for i=1:numel(LV_Grids_List)
	Transf.(LV_Grids_List{i}) = ...
		{Grid.(LV_Grids_List{i}).Branches.Transf.Branch_Name};
	% When only one Transformer is parent in the grid.
	if numel(Transf.(LV_Grids_List{i})) == 1
		% use this one:
		Transf.(LV_Grids_List{i}) = ...
			Grid.(LV_Grids_List{i}).Branches.Transf(1).Branch_ID;
	else
		mh.add_line('Selection of Transformer within grid "',LV_Grids_List{i},'"...');
		[Tran_Sel,Tran_ok] = listdlg(...
			'ListString',Transf.(LV_Grids_List{i}),...
			'Name','Selection of the Transformer' ,...
			'PromptString',{'Selection of the Transformer of Grid ';['"',LV_Grids_List{i},'"']; ...
			' which power flow is used for input creation';...
			' (only single selection is possible):';...
			''},...
			'SelectionMode','single',...
			'CancelString','Cancel',...
			'ListSize', [320, 300]);
		if ~Tran_ok
			mh.add_error('No transformer selected!')
			error = 1;
			return;
		end
		mh.add_listselection(Transf.(LV_Grids_List{i}), Tran_Sel);
		Transf.(LV_Grids_List{i}) = ...
			Grid.(LV_Grids_List{i}).Branches.Transf(Tran_Sel).Branch_ID;
	end
	% create index selection of the results:
	Sel_idx.(LV_Grids_List{i}) = ...
		vertcat(Grid.(LV_Grids_List{i}).Branches.Grouped.Branch_ID) == ...
		Transf.(LV_Grids_List{i});
end
mh.level_down();

% Flag, if user once seleced, when to few LV grid simulation
% data is available that the allready used profiles should be used
% again:
repeat = 0;

% Now process the scenario data:
mh.add_line('Start with data extraction...');
mh.level_up();
for i=1:scen_new.Number
	% The data of the first sceanrio is already loaded, so load the scenario data for
	% the other ones:
	if i>1
		mh.add_line('Loading "',Result_Settings.Result_Files{Scen_Sel(i)},'" from "',...
			handles.Current_Settings.Files.Load.Result.Path,filesep,'"');
		mh.add_line('(Scenario ',i,' from ',scen_new.Number,')...');
		mh.level_up();
		load([handles.Current_Settings.Files.Load.Result.Path,filesep,Result_Settings.Result_Files{Scen_Sel(i)}],...
		'Grid','Load_Infeed_Data','Result');
	else
		mh.add_line('Using allready loaded result data (Scenario 1 from ',scen_new.Number,')...');
		mh.level_up();
	end
	if scen_new.(['Sc_',num2str(i)]).Data_is_divided
		errorstr = 'Partitioned input-files are currently not supported!';
		mh.add_error(errorstr);
		errordlg(errorstr);
		error = 1;
		return;
	end
	
	Load_Infeed_Data_old = Load_Infeed_Data;
	Load_Infeed_Data = [];
	
	% Load the data of the grid variant, which should be used:
	for j=1:numel(LV_Grids_List)
		act_power = squeeze(Result.(LV_Grids_List{j}).Branch_Values(:,:,Sel_idx.(LV_Grids_List{j}),[1,5,9]));
		rea_power = squeeze(Result.(LV_Grids_List{j}).Branch_Values(:,:,Sel_idx.(LV_Grids_List{j}),[2,6,10]));
% 		% invert the powers, to get the correct power behavior:
% 		act_power = act_power *-1;
% 		rea_power = rea_power *-1;
		
		% Ceck if NANs are present in the data - remove the respective profiles:
		idx = find(isnan(act_power));
		if ~isempty(idx)
			[idx,~,~] = ind2sub(size(act_power),idx);
			idx = unique(idx);
			act_power(idx,:,:) = [];
			rea_power(idx,:,:) = [];
			% inform user:
			if ~warning_user
				warnstr1 = 'Warnung! ';
				warnstr2 = ['Simulationsdaten mit teilweise fehlerhaften Eintr�gen (NANs) sind ',...
					'vorhanden, die betreffenden Profile werden nicht ber�cksichtigt!'];
				mh.add_warning(warnstr2);
				helpdlg({warnstr1;warnstr2;});
				warning_user = 1;
			end
		end
		% When all data is currupted --> Error!
		if isempty(act_power)
			errorstr1 = 'Fehler!';
			errorstr2 = ['Keine Daten ohne fehlerhafte Eintr�ge (NANs) f�r Szenario "',...
				scen_new.(['Sc_',num2str(i)]).Filename,' und Netz "',...
				LV_Grids_List{j},...
				'" vorhanden! Datenzusammenstellung wird abgebrochen!"'];
			mh.add_error(errorstr2);
			errordlg({errorstr1; errorstr2;});
			error = 1;
			return;
		end
		
		% get the underlying Load- and Infeedinformation, first householdloads:
		if isfield(Load_Infeed_Data_old,'Set_1') && ~isempty(Load_Infeed_Data_old.Set_1.Households.(['Data',data_typ]))
			act_power_hou = zeros(Result_Settings.Simulation.Number_Runs,Result_Settings.Data_Extract.Timepoints_per_dataset,3);
			rea_power_hou = act_power_hou;
			
			for k=1:Result_Settings.Simulation.Number_Runs
				set = Load_Infeed_Data_old.(['Set_',sprintf('%d',k)]);
				
				Hous_Data = set.Households.(['Data',data_typ]);
% 				hhs = set.Households.Number;
				hhs = cell2struct(set.Households.Number(:,2),set.Households.Number(:,1));
				idx_hh = strcmp(set.Table_Network.ColumnName, 'Housh.type');
				data_hou = zeros(size(Hous_Data,1),6);
				
				for l=1:numel(Grid.(LV_Grids_List{j}).P_Q_Node.ids)
					hh_typ = set.Table_Network.Data{l,idx_hh};
					idx = find(strcmp(hh_typ,set.Households.Content));
% 					idx = idx(hhs.(hh_typ).Number)-1;
					idx = idx(hhs.(hh_typ))-1;
% 					hhs.(hh_typ).Number = hhs.(hh_typ).Number - 1;
					hhs.(hh_typ) = hhs.(hh_typ) - 1;
					data_hou = data_hou + Hous_Data(:,(idx*6)+1:(idx*6)+6);
				end
				act_power_hou(k,:,:) = data_hou(:,[1 3 5]);
				rea_power_hou(k,:,:) = data_hou(:,[2 4 6]);
			end
			clear Hous_Data hhs idx_hh data_hou hh_typ idx data_hou k l
			
		elseif isfield(Load_Infeed_Data_old, LV_Grids_List{j}) && ...
            ~isempty(Load_Infeed_Data_old.(LV_Grids_List{j}).Set_1.Households.(['Data',data_typ]))
			
			act_power_hou = zeros(Result_Settings.Simulation.Number_Runs,Result_Settings.Data_Extract.Timepoints_per_dataset,3);
			rea_power_hou = act_power_hou;
			
			for k=1:Result_Settings.Simulation.Number_Runs
				set = Load_Infeed_Data_old.(LV_Grids_List{j}).(['Set_',sprintf('%d',k)]);
				
				Hous_Data = set.Households.(['Data',data_typ]);
% 				hhs = set.Households.Number;
				hhs = cell2struct(set.Households.Number(:,2),set.Households.Number(:,1));
				idx_hh = strcmp(set.Table_Network.ColumnName, 'Housh.type');
				data_hou = zeros(size(Hous_Data,1),6);
				
				for l=1:numel(Grid.(LV_Grids_List{j}).P_Q_Node.ids)
					hh_typ = set.Table_Network.Data{l,idx_hh};
					idx = find(strcmp(hh_typ,set.Households.Content));
% 					idx = idx(hhs.(hh_typ).Number)-1;
					idx = idx(hhs.(hh_typ))-1;
% 					hhs.(hh_typ).Number = hhs.(hh_typ).Number - 1;
					hhs.(hh_typ) = hhs.(hh_typ) - 1;
					data_hou = data_hou + Hous_Data(:,(idx*6)+1:(idx*6)+6);
				end
				act_power_hou(k,:,:) = data_hou(:,[1 3 5]);
				rea_power_hou(k,:,:) = data_hou(:,[2 4 6]);
			end
			clear Hous_Data hhs idx_hh data_hou hh_typ idx data_hou k l
		else
			act_power_hou = [];
			rea_power_hou = [];
		end
		
		% Solar-Infeed:
		if isfield(Load_Infeed_Data_old,'Set_1') && ~isempty(Load_Infeed_Data_old.Set_1.Solar.(['Data',data_typ]))
			act_power_sol = zeros(Result_Settings.Simulation.Number_Runs,Result_Settings.Data_Extract.Timepoints_per_dataset,3);
			rea_power_sol = act_power_sol;
			
			for k=1:Result_Settings.Simulation.Number_Runs
				set = Load_Infeed_Data_old.(['Set_',sprintf('%d',k)]);
				
				Sola_Data = set.Solar.(['Data',data_typ]);
				add_data = set.Table_Network.Additional_Data;
				idx_pv_add = strcmp(set.Table_Network.Additional_Data_Content, 'PV_Plant_Name');
				plants =  set.Solar.Plants;
				data_sol = zeros(size(Sola_Data,1),6);
				
				for l=1:numel(Grid.(LV_Grids_List{j}).P_Q_Node.ids)
					gen_unit_name = add_data{l,idx_pv_add};
					if isempty(gen_unit_name)
						continue;
					end
					idx = find(strcmp(gen_unit_name,set.Solar.Content));
					idx = idx(plants.(gen_unit_name).Number) - 1;
					plants.(gen_unit_name).Number = plants.(gen_unit_name).Number - 1;
					data_sol = data_sol + Sola_Data(:,(idx*6)+1:(idx*6)+6);
				end
				act_power_sol(k,:,:) = data_sol(:,[1 3 5]);
				rea_power_sol(k,:,:) = data_sol(:,[2 4 6]);
			end
			clear set Sola_Data add_data idx_pv_add plants data_sol l k gen_unit_name idx
		elseif isfield(Load_Infeed_Data_old, LV_Grids_List{j}) && ...
                ~isempty(Load_Infeed_Data_old.(LV_Grids_List{j}).Set_1.Solar.(['Data',data_typ]))
			act_power_sol = zeros(Result_Settings.Simulation.Number_Runs,Result_Settings.Data_Extract.Timepoints_per_dataset,3);
			rea_power_sol = act_power_sol;
			
			for k=1:Result_Settings.Simulation.Number_Runs
				set = Load_Infeed_Data_old.(LV_Grids_List{j}).(['Set_',sprintf('%d',k)]);
				
				Sola_Data = set.Solar.(['Data',data_typ]);
				add_data = set.Table_Network.Additional_Data;
				idx_pv_add = strcmp(set.Table_Network.Additional_Data_Content, 'PV_Plant_Name');
				plants =  set.Solar.Plants;
				data_sol = zeros(size(Sola_Data,1),6);
				
				for l=1:numel(Grid.(LV_Grids_List{j}).P_Q_Node.ids)
					gen_unit_name = add_data{l,idx_pv_add};
					if isempty(gen_unit_name)
						continue;
					end
					idx = find(strcmp(gen_unit_name,set.Solar.Content));
					idx = idx(plants.(gen_unit_name).Number) - 1;
					plants.(gen_unit_name).Number = plants.(gen_unit_name).Number - 1;
					data_sol = data_sol + Sola_Data(:,(idx*6)+1:(idx*6)+6);
				end
				act_power_sol(k,:,:) = data_sol(:,[1 3 5]);
				rea_power_sol(k,:,:) = data_sol(:,[2 4 6]);
			end
			clear set Sola_Data add_data idx_pv_add plants data_sol l k gen_unit_name
		else
			act_power_sol = [];
			rea_power_sol = [];
		end
		
		% Elektromobility
		if isfield(Load_Infeed_Data_old,'Set_1') && ~isempty(Load_Infeed_Data_old.Set_1.El_Mobility.(['Data',data_typ]))
			act_power_elm = zeros(Result_Settings.Simulation.Number_Runs,Result_Settings.Data_Extract.Timepoints_per_dataset,3);
			rea_power_elm = act_power_elm;
			
			for k=1:Result_Settings.Simulation.Number_Runs
				set = Load_Infeed_Data_old.(['Set_',sprintf('%d',k)]);
				
				Elmo_Data = set.El_Mobility.(['Data',data_typ]);
				elm_count = 0;
				idx_em = strcmp(set.Table_Network.ColumnName, 'El. Mob.');
				data_elm = zeros(size(Elmo_Data,1),6);
				
				for l=1:numel(Grid.(LV_Grids_List{j}).P_Q_Node.ids)
					elmoby = set.Table_Network.Data{l,idx_em};
					for m=1:elmoby
						data_elm = data_elm + Elmo_Data(:,(elm_count*6)+1:(elm_count*6)+6); % Lastgang des Last
						elm_count = elm_count + 1;
					end
				end
				act_power_elm(k,:,:) = data_elm(:,[1 3 5]);
				rea_power_elm(k,:,:) = data_elm(:,[2 4 6]);
			end
			clear set Elmo_Data elm_count idx_em data_elm elmoby k l m elm_num
		elseif isfield(Load_Infeed_Data_old, LV_Grids_List{j}) && ...
                ~isempty(Load_Infeed_Data_old.(LV_Grids_List{j}).Set_1.El_Mobility.(['Data',data_typ]))
			act_power_elm = zeros(Result_Settings.Simulation.Number_Runs,Result_Settings.Data_Extract.Timepoints_per_dataset,3);
			rea_power_elm = act_power_elm;
			
			for k=1:Result_Settings.Simulation.Number_Runs
				set = Load_Infeed_Data_old.(LV_Grids_List{j}).(['Set_',sprintf('%d',k)]);
				
				Elmo_Data = set.El_Mobility.(['Data',data_typ]);
				elm_count = 0;
				idx_em = strcmp(set.Table_Network.ColumnName, 'El. Mob.');
				data_elm = zeros(size(Elmo_Data,1),6);
				
				for l=1:numel(Grid.(LV_Grids_List{j}).P_Q_Node.ids)
					elmoby = set.Table_Network.Data{l,idx_em};
					for m=1:elmoby
						data_elm = data_elm + Elmo_Data(:,(elm_count*6)+1:(elm_count*6)+6); % Lastgang des Last
						elm_count = elm_count + 1;
					end
				end
				act_power_elm(k,:,:) = data_elm(:,[1 3 5]);
				rea_power_elm(k,:,:) = data_elm(:,[2 4 6]);
			end
			clear set Elmo_Data elm_count idx_em data_elm elmoby k l m elm_num
		else
			act_power_elm = [];
			rea_power_elm = [];
		end
		
		% How many grids have to be treated?
		num_grd = LV_Grids_Number(j);
		
		% Now all the power-consumption data is available, construct with this data according
		% to the current settings a Input-Data-Set "LV_Grid_Input" with the combined
		% Load-Infeed-Data:
		for k=1:handles.Current_Settings.Simulation.Number_Runs
			if ~isfield(Load_Infeed_Data, ['Set_',num2str(k)])
				%First create empty Datastructures:
				if isempty(act_power_hou)
					Households.Data_Sample = [];
				else
					% Save the data first in this field, later follows reordering!
					Households.Data_Sample = zeros(...
						Result_Settings.Data_Extract.Timepoints_per_dataset,...
						sum(LV_Grids_Number)*6);
				end
				Households.Data_Mean = [];
				Households.Data_Min = [];
				Households.Data_Max = [];
				Households.Data_05P_Quantil = [];
				Households.Data_95P_Quantil = [];
				Households.Content = {};
				Load_Infeed_Data.(['Set_',num2str(k)]).Households = Households;
				Load_Infeed_Data.(['Set_',num2str(k)]).Table_Network = handles.Current_Settings.Table_Network;
				
				if isempty(act_power_sol)
					Solar.Data_Sample = [];
				else
					% Save the data first in this field, later follows reordering!
					Solar.Data_Sample = zeros(...
						Result_Settings.Data_Extract.Timepoints_per_dataset,...
						sum(LV_Grids_Number)*6);
				end
				Solar.Data_Mean = [];
				Solar.Data_Min = [];
				Solar.Data_Max = [];
				Solar.Data_05P_Quantil = [];
				Solar.Data_95P_Quantil = [];
				Solar.Plants = [];
				Load_Infeed_Data.(['Set_',num2str(k)]).Solar = Solar;
				
				if isempty(act_power_elm)
					El_Mobility.Data_Sample = [];
				else
					% Save the data first in this field, later follows reordering!
					El_Mobility.Data_Sample = zeros(...
						Result_Settings.Data_Extract.Timepoints_per_dataset,...
						sum(LV_Grids_Number)*6);
				end
				El_Mobility.Data_Mean = [];
				El_Mobility.Data_Min = [];
				El_Mobility.Data_Max = [];
				El_Mobility.Data_05P_Quantil = [];
				El_Mobility.Data_95P_Quantil = [];
				El_Mobility.Number = 0;
				Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility = El_Mobility;
				
				% Save the data first in this field, later follows reordering!
				LV_Grid_Input.Data_Sample = zeros(...
					Result_Settings.Data_Extract.Timepoints_per_dataset,...
					sum(LV_Grids_Number)*6);
				
				LV_Grid_Input.Data_Mean = [];
				LV_Grid_Input.Data_Min = [];
				LV_Grid_Input.Data_Max = [];
				LV_Grid_Input.Data_05P_Quantil = [];
				LV_Grid_Input.Data_95P_Quantil = [];
				LV_Grid_Input.Content = cell(1,sum(LV_Grids_Number));
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input = LV_Grid_Input;
			end
			
			if j>1
				grd_count = sum(LV_Grids_Number(1:j-1));
			else
				grd_count = 0;
			end
			
			pool = 1:size(act_power,1);
			
			for l=1:num_grd
				if isempty(pool) && ~ repeat
					mh.add_warning('To few LV grid simulation data available, ask user how to proceed...')
					mh.level_up();
					answer = questdlg({...
						'To few LV grid simulation data available than needed!';...
						'';...
						'Should the allready used data be used again?'},...
						'Running out of LV grid simulation data...',...
						'Yes','Abort','Abort');
					if strcmp(answer, 'Yes')
						mh.add_info('Allready used data will be used again.')
						repeat = 1;
					else
						mh.add_error('Canceld by user.');
						error = 1;
						return;
					end
					mh.level_down();
				end
				
				if isempty(pool) && repeat
					pool = 1:size(act_power,1);
				end
				
				fortu = floor(rand()*(numel(pool)))+1;
				idx = pool(fortu);
				pool(fortu) = [];
				
				grd_count = grd_count + 1;
				
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample(:,(grd_count-1)*6+1) = ...
					act_power(idx,:,1);
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample(:,(grd_count-1)*6+3) = ...
					act_power(idx,:,2);
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample(:,(grd_count-1)*6+5) = ...
					act_power(idx,:,3);
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample(:,(grd_count-1)*6+2) = ...
					rea_power(idx,:,1);
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample(:,(grd_count-1)*6+4) = ...
					rea_power(idx,:,2);
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample(:,(grd_count-1)*6+6) = ...
					rea_power(idx,:,3);
				
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Content{grd_count} = LV_Grids_List{j};
				
				% Add the additional Load-Infeed-Information:
				if ~isempty(act_power_hou)
					Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample(:,(grd_count-1)*6+1) = ...
						act_power_hou(idx,:,1);
					Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample(:,(grd_count-1)*6+3) = ...
						act_power_hou(idx,:,2);
					Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample(:,(grd_count-1)*6+5) = ...
						act_power_hou(idx,:,3);
					Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample(:,(grd_count-1)*6+2) = ...
						rea_power_hou(idx,:,1);
					Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample(:,(grd_count-1)*6+4) = ...
						rea_power_hou(idx,:,2);
					Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample(:,(grd_count-1)*6+6) = ...
						rea_power_hou(idx,:,3);
				end
				
				if ~isempty(act_power_sol)
					Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample(:,(grd_count-1)*6+1) = ...
						act_power_sol(idx,:,1);
					Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample(:,(grd_count-1)*6+3) = ...
						act_power_sol(idx,:,2);
					Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample(:,(grd_count-1)*6+5) = ...
						act_power_sol(idx,:,3);
					Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample(:,(grd_count-1)*6+2) = ...
						rea_power_sol(idx,:,1);
					Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample(:,(grd_count-1)*6+4) = ...
						rea_power_sol(idx,:,2);
					Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample(:,(grd_count-1)*6+6) = ...
						rea_power_sol(idx,:,3);
				end
				
				if ~isempty(act_power_elm)
					Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample(:,(grd_count-1)*6+1) = ...
						act_power_elm(idx,:,1);
					Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample(:,(grd_count-1)*6+3) = ...
						act_power_elm(idx,:,2);
					Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample(:,(grd_count-1)*6+5) = ...
						act_power_elm(idx,:,3);
					Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample(:,(grd_count-1)*6+2) = ...
						rea_power_elm(idx,:,1);
					Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample(:,(grd_count-1)*6+4) = ...
						rea_power_elm(idx,:,2);
					Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample(:,(grd_count-1)*6+6) = ...
						rea_power_elm(idx,:,3);
				end
			end
		end
	end
	
	clear Result Load_Infeed_Data_old
	
	% According to the data extraction settings also treat here the data to the
	% correct substructure
	for k=1:handles.Current_Settings.Simulation.Number_Runs
		if ~strcmp(data_typ,'_Sample')
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.(['Data',data_typ]) = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample = [];
			Load_Infeed_Data.(['Set_',num2str(k)]).Households.(['Data',data_typ]) = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).Households.Data_Sample = [];
			Load_Infeed_Data.(['Set_',num2str(k)]).Solar.(['Data',data_typ]) = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).Solar.Data_Sample = [];
			Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.(['Data',data_typ]) = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).El_Mobility.Data_Sample = [];
		end
	end
	
	% Save the Scenario Data:
	name = scen_new.(['Sc_',num2str(i)]).Filename;
	mh.add_line('Saving load and infeed data to "',name,' in "',handles.Current_Settings.Simulation.Scenarios_Path,filesep,'"');
	save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,name,'.mat'],...
		'Load_Infeed_Data');
	mh.level_down();
end
mh.level_down();


% Update the settings:
handles.Current_Settings.Simulation.Scenarios.Data_avaliable = 1;
handles.Current_Settings.Simulation.Number_Runs = Result_Settings.Simulation.Number_Runs;
handles.Current_Settings.Data_Extract.LV_Grids_List = LV_Grids_List;
handles.Current_Settings.Data_Extract.LV_Grids_Number = LV_Grids_Number;
handles.Current_Settings.Data_Extract.MV_input_generation_in_progress = 0;

% Save the settings:
mh.add_line('Saving settings "Scenario_Settings.mat" in "',handles.Current_Settings.Simulation.Scenarios_Path,filesep,'"');
Scenarios_Settings = handles.Current_Settings.Simulation.Scenarios; %#ok<NASGU>
Data_Extract = handles.Current_Settings.Data_Extract;
save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat'],...
	'Scenarios_Settings', 'Data_Extract');

% save the latest input data set to the NAT-data structure, to show, that now valid data
% is available:
handles.NAT_Data.Load_Infeed_Data = Load_Infeed_Data;
handles.NAT_Data.Data_Extract = Data_Extract;


