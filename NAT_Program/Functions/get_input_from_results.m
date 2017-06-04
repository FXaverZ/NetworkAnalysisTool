function [handles, error] = get_input_from_results(handles)
%GET_INPUT_FROM_RESULTS    creates input for MV-Grid out of LV-Grid-Simulation Results
%   Detailed explanation goes here

Result_Settings = handles.Result_Settings;

warning_user = 0;
error = 0; 

% get impoortant setting: 
LV_Grids_List = handles.Current_Settings.Data_Extract.LV_Grids_List;
Number_Data_Sets = handles.Current_Settings.Simulation.Number_Runs;
MV_input_generation_in_progress = handles.Current_Settings.Data_Extract.MV_input_generation_in_progress;

% Reload the data extraktion settings:
handles.Current_Settings.Data_Extract = Result_Settings.Data_Extract;

% Update this settings with the current settings in the GUI:
handles.Current_Settings.Data_Extract.Number_Data_Sets = Number_Data_Sets;


% % Reset the network table:
% [handles.Current_Settings.Table_Network, ...
% 	handles.Current_Settings.Data_Extract] = network_table_reset(handles);

% just quick check, if the correct kind of grid is present:
if strcmp(handles.Current_Settings.Grid.Type, 'LV')
	fprintf('Wrong destination grid!');
	return;
end

% update the grid-numbers:
idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
data = handles.Current_Settings.Table_Network.Data(:,idx_lv);
LV_Grids_Number = zeros(numel(LV_Grids_List),1);
for i=1:numel(LV_Grids_List)
	LV_Grids_Number(i) = sum(strcmp(data,LV_Grids_List{i}));
end

% User dialog to get information about the generation-process:
if 	~MV_input_generation_in_progress && ...
		(isempty(LV_Grids_List) || sum(LV_Grids_Number) == 0)
	% no grid allocation is present
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
elseif MV_input_generation_in_progress &&...
		(isempty(LV_Grids_List) || sum(LV_Grids_Number) == 0) 		
	errordlg({'No valid lv-grid-allocation found!';...
		'Please specify the lv-grid allocation in the main-GUI!'},...
		'Specifying data generation procedure');
	error = 1;
	return;
elseif 	~MV_input_generation_in_progress
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
end

if 	~MV_input_generation_in_progress
	% load first scenario (for grid properties):
	load([handles.Current_Settings.Files.Load.Result.Path,filesep,Result_Settings.Result_Files{1}]);
	% delete the not needed data:
	clear('Debug','Load_Infeed_Data');
	
	% Get the simulated grid names:
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
			error = 1;
			return;
		end
	else
		Grid_Sel = 1;
	end
	
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
		handles.Current_Settings.Data_Extract.MV_input_generation_in_progress = 1;
		return;
	end
end

% update the grid-numbers:
idx_lv = strcmp(handles.Current_Settings.Table_Network.ColumnName, 'LV-Grid');
data = handles.Current_Settings.Table_Network.Data(:,idx_lv);
LV_Grids_Number = zeros(numel(LV_Grids_List),1);
for i=1:numel(LV_Grids_List)
	LV_Grids_Number(i) = sum(strcmp(data,LV_Grids_List{i}));
end
	
% User dialogs to select the desired settings of Data
[Scen_Sel,Scen_ok] = listdlg (...
	'ListString',Result_Settings.Simulation.Scenarios.Names,...
	'Name','Auswahl der zu extrahierenden Szenarios',...
	'PromptString',{'Auswahl der zu extrahierenen Szenarios';...
	' (Mehrfachauswahl möglich):'},...
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
handles.Current_Settings.Simulation.Scenarios_Selection = ones(1,scen_new.Number);

% load first selected scenario (for grid properties):
load([handles.Current_Settings.Files.Load.Result.Path,filesep,Result_Settings.Result_Files{Scen_Sel(1)}]);
% delete the not needed data:
clear('Debug','Load_Infeed_Data');

% let the user select the point of each grid, from where the Power Data
% should be used (Transformers):
for i=1:numel(LV_Grids_List)
	Transf.(LV_Grids_List{i}) = ...
		{Grid.(LV_Grids_List{i}).Branches.Transf.Branch_Name};
	% When only one Transformer is parent in the grid.
	if numel(Transf.(LV_Grids_List{i})) == 1
		% use this one:
		Transf.(LV_Grids_List{i}) = ...
			Grid.(LV_Grids_List{i}).Branches.Transf(1).Branch_ID;
	else
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
			error = 1; 
			return;
		end
		Transf.(LV_Grids_List{i}) = ...
			Grid.(LV_Grids_List{i}).Branches.Transf(Tran_Sel).Branch_ID;
	end
	% create index selection of the results:
	Sel_idx.(LV_Grids_List{i}) = ...
		vertcat(Grid.(LV_Grids_List{i}).Branches.Grouped.Branch_ID) == ...
		Transf.(LV_Grids_List{i});
end

% Check, if a Subfolder for input-data within the current grid-folder is avaliable:
if isempty(handles.Current_Settings.Simulation.Grid_List)
	path = [handles.Current_Settings.Files.Grid.Path,filesep,...
		handles.Current_Settings.Files.Grid.Name,'_nat'];
else
	path = handles.Current_Settings.Simulation.Grids_Path;
end
if ~isdir([path,filesep,'Load_Infeed_Data_f_Scenarios'])
	mkdir([path,filesep,'Load_Infeed_Data_f_Scenarios']);
end

% Create a Subfolder for the extracted data, containing the extraction-moment:
handles.Current_Settings.Data_Extract.Date_Extraktion = now();
handles.Current_Settings.Simulation.Scenarios_Path = [...
	path,filesep,'Load_Infeed_Data_f_Scenarios',filesep,...
	datestr(handles.Current_Settings.Data_Extract.Date_Extraktion,'yyyy_mm_dd-HH.MM.SS'),...
	];
mkdir(handles.Current_Settings.Simulation.Scenarios_Path);

% Now process the scenario data:
for i=1:scen_new.Number
	% The data of the first sceanrio is already loaded, so load the scenario data for
	% the other ones:
	if i>1
		load([handles.Current_Settings.Files.Load.Result.Path,filesep,Result_Settings.Result_Files{Scen_Sel(i)}]);
		% delete the not needed data:
		clear('Debug','Load_Infeed_Data');
	end
	
	if scen_new.(['Sc_',num2str(i)]).Data_is_divided
		errordlg('Partitioned input-files are currently not supported!');
		error = 1;
		return;
	end
	
	Load_Infeed_Data = [];
	
	% Load the data the grid variant, which should be used:
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
				helpdlg({...
					'Warnung!';...
					['Simulationsdaten mit teilweise fehlerhaften Einträgen (NANs) sind '...
					'vorhanden, die betreffenden Profile werden nicht berücksichtigt!'];});
				warning_user = 1;
			end
		end
		% When all data is currupted --> Error!
		if isempty(act_power)
			errordlg({...
				'Fehler!';...
				['Keine Daten ohne fehlerhafte Einträge (NANs) für Szenario "',...
				scen_new.(['Sc_',num2str(i)]).Filename,' und Netz "',...
				LV_Grids_List{j},...
				'" vorhanden! Datenzusammenstellung wird abgebrochen!"']});
			error = 1;
			return;
		end
		
		% How many grids have to be treated?
		num_grd = LV_Grids_Number(j);
		
		% Now all the power-consumption data is available, construct with this data according
		% to the current settings a Input-Data-Set "LV_Grid_Input" with the combined
		% Load-Infeed-Data:
		for k=1:handles.Current_Settings.Simulation.Number_Runs
			if ~isfield(Load_Infeed_Data, ['Set_',num2str(k)])
				%First create empty Datastructures:
				Households.Data_Sample = [];
				Households.Data_Mean = [];
				Households.Data_Min = [];
				Households.Data_Max = [];
				Households.Data_05P_Quantil = [];
				Households.Data_95P_Quantil = [];
				Households.Content = {};
				Load_Infeed_Data.(['Set_',num2str(k)]).Households = Households;
				Load_Infeed_Data.(['Set_',num2str(k)]).Table_Network = handles.Current_Settings.Table_Network;
				
				Solar.Data_Sample = [];
				Solar.Data_Mean = [];
				Solar.Data_Min = [];
				Solar.Data_Max = [];
				Solar.Data_05P_Quantil = [];
				Solar.Data_95P_Quantil = [];
				Solar.Plants = handles.Current_Settings.Data_Extract.Solar.Plants;
				Load_Infeed_Data.(['Set_',num2str(k)]).Solar = Solar;
				
				El_Mobility.Data_Sample = [];
				El_Mobility.Data_Mean = [];
				El_Mobility.Data_Min = [];
				El_Mobility.Data_Max = [];
				El_Mobility.Data_05P_Quantil = [];
				El_Mobility.Data_95P_Quantil = [];
				El_Mobility.Number = handles.Current_Settings.Data_Extract.El_Mobility.Number;
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
			end
		end
	end
 		
	% According to the data extraction settings also treat here the data to the
	% correct substructure
	for k=1:handles.Current_Settings.Simulation.Number_Runs
		if handles.Current_Settings.Data_Extract.get_Mean_Value
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Mean = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample = [];
		end
		if handles.Current_Settings.Data_Extract.get_Max_Value
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Max = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample = [];
		end
		if handles.Current_Settings.Data_Extract.get_Min_Value
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Min = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample = [];
		end
		if handles.Current_Settings.Data_Extract.get_05_Quantile_Value
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_05P_Quantil = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample = [];
		end
		if handles.Current_Settings.Data_Extract.get_95_Quantile_Value
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_95P_Quantil = ...
				Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample;
			Load_Infeed_Data.(['Set_',num2str(k)]).LV_Grid_Input.Data_Sample = [];
		end
	end
 		
	% Save the Scenario Data:
	name = scen_new.(['Sc_',num2str(i)]).Filename;
	save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,name,'.mat'],...
		'Load_Infeed_Data');
end

% Update the settings:
handles.Current_Settings.Simulation.Scenarios.Data_avaliable = 1;
handles.Current_Settings.Data_Extract.LV_Grids_List = LV_Grids_List;
handles.Current_Settings.Data_Extract.LV_Grids_Number = LV_Grids_Number;
handles.Current_Settings.Data_Extract.MV_input_generation_in_progress = 0;

% Save the settings:
Scenarios_Settings = handles.Current_Settings.Simulation.Scenarios; %#ok<NASGU>
Data_Extract = handles.Current_Settings.Data_Extract; %#ok<NASGU>
save([handles.Current_Settings.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat'],...
	'Scenarios_Settings', 'Data_Extract');

% save the latest input data set to the NAT-data structure, to show, that now valid data
% is available:
handles.NAT_Data.Load_Infeed_Data = Load_Infeed_Data;


