function handles = get_input_from_results(handles)
%GET_INPUT_FROM_RESULTS Summary of this function goes here
%   Detailed explanation goes here

Result_Settings = handles.Result_Settings;

warning_user = 0;

% Reload the data extraktion settings:
handles.Current_Settings.Data_Extract = Result_Settings.Simulation_Options.Current_Settings.Data_Extract;

% Reset the network table:
[handles.Current_Settings.Table_Network, ...
    handles.Current_Settings.Data_Extract] = network_table_reset(handles);
% Adapt the householdnumbers
if ~isempty(handles.Current_Settings.Table_Network)
	for i=1:size(handles.System.housholds,1)
		handles.Current_Settings.Data_Extract.Households.(handles.System.housholds{i,1}).Number = ...
			sum(strcmp(...
			handles.System.housholds{i,1},...
			handles.Current_Settings.Table_Network.Data(:,strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Haush. Typ'))));
	end
end

% User dialogs to select the desired settings of Data
[Scen_Sel,Scen_ok] = listdlg(...
	'ListString',Result_Settings.Scenarios,...
	'Name','Auswahl der zu extrahierenden Szenarios',...
	'PromptString',{'Auswahl der zu extrahierenen Szenarios';...
	' (Mehrfachauswahl möglich):'},...
	'CancelString','Vorgang abbr.',...
	'ListSize', [320, 300]);
if ~Scen_ok
	return;
end

% adapt the Scenario-Settings according to the selection:
scen_old = Result_Settings.Simulation_Options.Current_Settings.Simulation.Scenarios;
scen_new.Number = numel(Scen_Sel);
scen_new.Names = cell(1,scen_new.Number);
for i=1:scen_new.Number
	scen_new.Names{i} = scen_old.Names{Scen_Sel(i)};
	scen_new.(['Sc_',num2str(i)]) = scen_old.(['Sc_',num2str(Scen_Sel(i))]);
end
handles.Current_Settings.Simulation.Scenarios = scen_new;

[Grid_Sel,Scen_ok] = listdlg(...
	'ListString',Result_Settings.Grid_Variants,...
	'Name','Auswahl der zu verwendenden Netz-Varianten',...
	'PromptString',{'Auswahl der zu berücksichtigten Netz Varianten';...
	' (Mehrfachauswahl möglich):';...
	'';
	'Bei Mehrfachauswahl werden zufällig Netzvarainten den ';...
	'korrespndierenden Netzanschlusspunkten zugeordnet...'},...
	'CancelString','Vorgang abbr.',...
	'ListSize', [320, 300]);
if ~Scen_ok
	return;
end

% load first scenario (for grid properties):
load([Result_Settings.Result_Filepath,filesep,Result_Settings.Result_Filenames{Scen_Sel(1)}]);
% delete the not needed data:
clear('Debug','Load_Infeed_Data');

% let the user select the point of each grid, from where the Power Data
% should be used (Transformers):
for i=1:numel(Result_Settings.Grid_Variants(Grid_Sel))
	Transf.(Result_Settings.Grid_Variants{i}) = ...
		{Grid.(Result_Settings.Grid_Variants{i}).Branches.Transf.Branch_Name};
	% When only one Transformer is parent in the grid.
	if numel(Transf.(Result_Settings.Grid_Variants{i})) == 1
		% use this one:
		Transf.(Result_Settings.Grid_Variants{i}) = ...
			Grid.(Result_Settings.Grid_Variants{i}).Branches.Transf(1).Branch_ID;
	else
		% let the user select the transformer:
		%TODO!!!
	end
	% create index selection of the results:
	Sel_idx.(Result_Settings.Grid_Variants{i}) = ...
		vertcat(Grid.(Result_Settings.Grid_Variants{i}).Branches.Grouped.Branch_ID) == ...
		Transf.(Result_Settings.Grid_Variants{i});
end

% Now process the scenario data:
for i=1:numel(Result_Settings.Scenarios(Scen_Sel))
	if i>1
		% The data of the first sceanrio is already loaded, so load the scenario data for
		% the other ones:
		load([Result_Settings.Result_Filepath,filesep,Result_Settings.Result_Filenames{Scen_Sel(i)}]);
	end
	% Get the data out of the secenarios:
	% First, preallocate array for the input data out of each grid variant:
	act_power_total = zeros(...
		numel(Result_Settings.Grid_Variants(Grid_Sel))*Result_Settings.Datasets,...
		Result_Settings.Timepoints,...
		3);
	rea_power_total = act_power_total;
	% Load the data of all the grid variants, which should be used:
	for j=1:numel(Result_Settings.Grid_Variants(Grid_Sel))
		act_power = squeeze(Result.(Result_Settings.Grid_Variants{j}).Branch_Values(:,:,Sel_idx.(Result_Settings.Grid_Variants{j}),[1,5,9]));
		rea_power = squeeze(Result.(Result_Settings.Grid_Variants{j}).Branch_Values(:,:,Sel_idx.(Result_Settings.Grid_Variants{j}),[2,6,10]));
		% invert the powers, to get the correct power behavior:
		act_power = act_power *-1;
		rea_power = rea_power *-1;
		% add the data to the final arrays:
		act_power_total((j-1)*Result_Settings.Datasets+1:j*Result_Settings.Datasets,:,:) = act_power;
		rea_power_total((j-1)*Result_Settings.Datasets+1:j*Result_Settings.Datasets,:,:) = rea_power;
	end
	% Ceck if NANs are present in the data - remove the respective profiles:
	idx = find(isnan(act_power_total));
	if ~isempty(idx)
		[idx,~,~] = ind2sub(size(act_power_total),idx);
		idx = unique(idx);
		act_power_total(idx,:,:) = [];
		rea_power_total(idx,:,:) = [];
		% inform user:
		if ~warning_user
			helpdlg({...
				'Warnung!';...
				['Simulationsdaten mit teilweise fehlerhaften Einträgen (NANs) sind '...
				'vorhanden, die betreffenden Profile werden nicht berücksichtigt!'];});
			warning_user = 1;
		end
	end
	
	% When all data is currupted --> Error!
	if isempty(act_power_total)
		errordlg({...
			'Fehler!';...
			['Keine Daten ohne fehlerhafte Einträge (NANs) für Szenario "',...
			handles.Current_Settings.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename,...
			'" vorhanden! Datenzusammenstellung wird abgebrochen!"']});
		return;
	end
	
	% Now all the power-consumption data is available, construct with this data according
	% to the current settings a Input-Data-Set "Households" with the combined
	% Load-Infeed-Data:
	Households.Content = handles.Current_Settings.Table_Network.Data(:,...
		strcmp(handles.Current_Settings.Table_Network.ColumnName, 'Haush. Typ'));
	for j=1:handles.Current_Settings.Simulation.Number_Runs
		Households.Data_Sample = [];
		Households.Data_Mean = [];
		Households.Data_Min = [];
		Households.Data_Max = [];
		Households.Data_05P_Quantil = [];
		Households.Data_95P_Quantil = [];
		% How many connectionpoints have to be treated?
		num_points = handles.Current_Settings.Data_Extract.Households.(Households.Content{1}).Number;
		% Draw a random number of profiles out of the pool (without repetition):
		pool = 1:size(rea_power_total,1);
		idx = zeros(1,num_points);
		for k=1:num_points
			fortu = floor(rand()*(numel(pool)))+1;
			idx(k) = pool(fortu);
			pool(fortu) = [];
		end
		% get this data and reconstruct it in the needed way (i.e. {P_L1, Q_L1, P_L2, ...
		% and alle points arranged in columns):
		power = zeros(Result_Settings.Timepoints,num_points*6);
		power(:,1:6:num_points*6) = squeeze(act_power_total(idx,:,1))';
		power(:,3:6:num_points*6) = squeeze(act_power_total(idx,:,2))';
		power(:,5:6:num_points*6) = squeeze(act_power_total(idx,:,3))';
		power(:,2:6:num_points*6) = squeeze(rea_power_total(idx,:,1))';
		power(:,4:6:num_points*6) = squeeze(rea_power_total(idx,:,2))';
		power(:,6:6:num_points*6) = squeeze(rea_power_total(idx,:,3))';
		
		% According to the data extraction settings also treat here the data to the
		% correct substructure
		if handles.Current_Settings.Data_Extract.get_Sample_Value
			Households.Data_Sample = power;
		end
		if handles.Current_Settings.Data_Extract.get_Mean_Value
			Households.Data_Mean = power;
		end
		if handles.Current_Settings.Data_Extract.get_Max_Value
			Households.Data_Max = power;
		end
		if handles.Current_Settings.Data_Extract.get_Min_Value
			Households.Data_Min = power;
		end
		if handles.Current_Settings.Data_Extract.get_05_Quantile_Value
			Households.Data_05P_Quantil = power;
		end
		if handles.Current_Settings.Data_Extract.get_95_Quantile_Value
			Households.Data_95P_Quantil = power;
		end
		% also store the number of different "households" (the allocation) for later
		% use - here dummy values:
		Households.Number = handles.Current_Settings.Data_Extract.Households;
		% save the created structure along with the current network table:
		Load_Infeed_Data.(['Set_',num2str(j)]).Households = Households;
		Load_Infeed_Data.(['Set_',num2str(j)]).Table_Network = handles.Current_Settings.Table_Network;
		
		% for the other possible times series fill them with empty arrays:
		Solar.Data_Sample = [];
		Solar.Data_Mean = [];
		Solar.Data_Min = [];
		Solar.Data_Max = [];
		Solar.Data_05P_Quantil = [];
		Solar.Data_95P_Quantil = [];
		% store the plants strukture for later use:
		Solar.Plants = handles.Current_Settings.Data_Extract.Solar.Plants;
		Load_Infeed_Data.(['Set_',num2str(j)]).Solar = Solar;
		El_Mobility.Data_Sample = [];
		El_Mobility.Data_Mean = [];
		El_Mobility.Data_Min = [];
		El_Mobility.Data_Max = [];
		El_Mobility.Data_05P_Quantil = [];
		El_Mobility.Data_95P_Quantil = [];
		El_Mobility.Number = handles.Current_Settings.Data_Extract.El_Mobility.Number;
		Load_Infeed_Data.(['Set_',num2str(j)]).El_Mobility = El_Mobility;
	end
	
	% Save the Scenario Data:
	if isempty(handles.Current_Settings.Simulation.Grid_List)
		path = [handles.Current_Settings.Files.Grid.Path,filesep,...
			handles.Current_Settings.Files.Grid.Name,'_files'];
	else
		path = handles.Current_Settings.Simulation.Grids_Path;
	end
	if ~isdir([path,filesep,'Load_Infeed_Data_f_Scenarios'])
		mkdir([path,filesep,'Load_Infeed_Data_f_Scenarios']);
	end
	name = handles.Current_Settings.Simulation.Scenarios.(['Sc_',num2str(i)]).Filename;
	Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
	save([path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,name,'.mat'],...
		'Load_Infeed_Data','Data_Extract');
end

handles.Current_Settings.Simulation.Scenarios_Path =...
	[path,filesep,'Load_Infeed_Data_f_Scenarios'];
handles.Current_Settings.Simulation.Scenarios.Data_avaliable = 1;
% Update the settings:
Scenarios_Settings = handles.Current_Settings.Simulation.Scenarios; %#ok<NASGU>
save([path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,'Scenario_Settings.mat'],...
	'Scenarios_Settings');

% save the latest input data set to the NAT-data structure, to show, that now valid data
% is available:
handles.NAT_Data.Load_Infeed_Data = Load_Infeed_Data;


