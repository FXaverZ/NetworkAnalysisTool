function handles = load_input_from_results(handles)
%LOAD_INPUT_FROM_RESULTS Summary of this function goes here
%   Detailed explanation goes here

Result_Settings = handles.Result_Settings;

% Reload the data extraktion settings:
handles.Current_Settings.Data_Extract = Result_Settings.Simulation_Options.Current_Settings.Data_Extract;

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

% Now process the scenario data:
for i=1:numel(Result_Settings.Scenarios(Scen_Sel))
	% load results data:
	load([Result_Settings.Result_Filepath,filesep,Result_Settings.Result_Filenames{Scen_Sel(i)}]);

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
end