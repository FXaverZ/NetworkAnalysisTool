clear();
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (set up of of datastorage) and the next one (Set up and
% loading of data) have to be executed before every other cell!
Saved_Data_OAT   = [];

% Paths to source files:
Path_Data_OAT = ['C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\',...
	'Results_mean\01_Merged_OAT-Data\'];
% Path_Data_OAT = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

% Add folder with help functions / needed classes to path:
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
scriptfolderpath = fileparts(scriptpath);
addpath([scriptpath, filesep, 'Additional_Resources']);
addpath([fileparts(scriptfolderpath),filesep,'NAT_Common',filesep,'Analyzing']);
addpath([fileparts(scriptfolderpath),filesep,'NAT_Common',filesep,'Grid_Representation']);

clear scriptpath 
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Additional Set Up / Configuration / Loading of OAT Data
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Settings_Scenario = {...
% 1     2                                                3             4          5
% ID  , Filename                                       , Color       , LineStyle, String for legend 
	 1,'01_SB_Base_Winter_Workda'                      ,[ 74,126,187],'-','Base Winter';...
	 2,'02_SB_Base_Summer_Workda'                      ,[ 74,126,187],'-','Base Summer';...
	 3,'03_S1_LowLoadHighInfeed_Winter_Workda'         ,[190, 75, 72],'-','Low Load High Infeed Winter';...
	 4,'04_S1_LowLoadHighInfeed_Summer_Workda'         ,[190, 75, 72],'-','Low Load High Infeed Summer';...
	 5,'05_S2_HighLoadHighInfeed_Winter_Workda'        ,[152,185, 84],'-','High Load High Infeed Winter';...
	 6,'06_S2_HighLoadHighInfeed_Summer_Workda'        ,[152,185, 84],'-','High Load High Infeed Summer';...
	 7,'07_S3_HighLoadHighInfeed2Nodes_Winter_Workda'  ,[128,100,162],'-','High Load High Infeed (2 Nodes) Winter';...
	 8,'08_S3_HighLoadHighInfeed2Nodes_Summer_Workda'  ,[128,100,162],'-','High Load High Infeed (2 Nodes) Summer';...
	 9,'09_S4_MediumLoadHighInfeed2Nodes_Winter_Workda',[247,173, 36],'-','Medium Load High Infeed (2 Nodes) Winter';...
	10,'10_S4_MediumLoadHighInfeed2Nodes_Summer_Workda',[247,173, 36],'-','Medium Load High Infeed (2 Nodes) Summer';...
	};

Settings_GridVariants = {...
    'g01_Base_NS_50_Nodes',             'Basisnetz',               '-';...
    'g02_Repalce_OH_Lines_With_Cables', 'Ersatz Oberleitung',      '--';...
    'g03_Add_Cable_to_First_OH_Line',   'Verstärkung Oberleitung', ':';...
    'g04_Add_Cable_to_Weak_Cables',     'Verstärkung Kabel',       '-.';...
	};

Settings_Datasets = {
	1, 'Households'  , 'Haushaltslast'   ;...
	2, 'Solar'       , 'PV Einspeisung'  ;...
	3, 'El_Mobility' , 'Elektromobilität';...
	};

Settings_Number_Profiles = 10;

% Load OAT Data
folders = dir(Path_Data_OAT);
folders = struct2cell(folders);
folders = folders(1,3:end);

sep = cell(1,numel(folders));
sep(:) = {' - '};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
sep(:) = {'_Solar'}; % if solar pictures are also present...
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
folders = unique(folders);
disp('Loading OAT Data...');
for i = 1: numel(folders)
	disp(['    Reading File ',num2str(i),' of ',num2str(numel(folders))]);
	NVIEW_Data_Names = {'NVIEW_Results', 'NVIEW_Analysis_Selection', 'NVIEW_Control', 'NVIEW_Processed'};
	if ~isfield(Saved_Data_OAT,['Saved_',num2str(i)])
		Saved_Data_OAT.(['Saved_',num2str(i)]) = load([Path_Data_OAT,...
			folders{i},' - 000 - OAT-Data.mat'],NVIEW_Data_Names{:});
	end
end
disp('... done!');
Saved_Data_OAT.Number_Datasets = numel(folders);
clear sep folders i NVIEW_*

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot the distribution of voltage band violations per grid variant
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = 2:2:10;   % Sommer
% Option_Active_Scenarios = [6, 8];
% Option_Active_Scenarios = 8;
% Option_Active_Scenarios = 1:2:10; % Winter
% Option_Active_Scenarios = 1:10;   % All scenarios (not recomended!)
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Active_GridVariants = [2,3,4];     % 
% Option_Active_GridVariants = 2;
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% y-axis Settings (Option_y_max_Value = -1 ... autoscale)
Option_y_max_Value  = 1.05; % -1 ... autoscale
Option_y_min_Value  = 0.95;
Option_y_step_Value = 0.01; % -1 ... autostep
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
if numel(Option_Active_GridVariants) < 2
	Labels_Title = ['Mittlerer Verlauf Spannung für Netzvariante "',Settings_GridVariants{Option_Active_GridVariants,2},'"'];
else
	if numel(Option_Active_Scenarios) > 1
		Labels_Title = 'Mittlerer Verlauf Spannung';
	else
		Labels_Title = ['Mittlerer Verlauf Spannung für Scenario "',Settings_Scenario{Option_Active_Scenarios,2},'"'];
	end
end
Labels_X_Direction = 'Tageszeit [h]';
Labels_Y_Direction = 'Spannung [p.u.]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i = 1 : Saved_Data_OAT.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_GridVars  = Settings_GridVariants(Option_Active_GridVariants,:);
		
		fig_oat_voltage_sum = figure;
		set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
	end
	
	figure(fig_oat_voltage_sum); nexttile;
	Labels_Scenarios = {};
	Labels_Grid      = {};
	Labels_Gridstyle = [];
	d = Saved_Data_OAT.(['Saved_',num2str(i)]).NVIEW_Processed;
	
	for j = 1:size(Active_GridVars,1)
		for k = 1 : size(Active_Scenarios,1)
			voltage_timeline =...
				zeros(1,d.Control.Simulation_Options.Timepoints_per_dataset);
			for t = 1 : d.Control.Simulation_Options.Timepoints_per_dataset
				voltage_timeline(t) = nansum(nansum(squeeze(nansum(squeeze(d.(Active_GridVars{j,1}).bus_voltages(Active_Scenarios{k,1},:,t,:,:)))))) / ...
					(size(d.(Active_GridVars{j,1}).bus,1)*d.Control.Simulation_Options.Number_of_datasets*3);
			end
			figure(fig_oat_voltage_sum); l = plot(voltage_timeline);
			set(l, 'Color', Active_Scenarios{k,3}/256);
			set(l, 'LineStyle', Active_Scenarios{k,4});
			if size(Active_GridVars,1) > 1
				set(l, 'LineStyle', Active_GridVars{j,3});
			end
			drawnow;
			if j == 1
				Labels_Scenarios{end+1} = Active_Scenarios{k,5}; %#ok<SAGROW>
			end
			if k <=1
				figure(fig_oat_voltage_sum); hold on;
			end
		end
		l = plot(nan, nan);
		set(l, 'Color', 'k');
		set(l, 'LineStyle', Active_GridVars{j,3});
		Labels_Gridstyle(end+1) = l; %#ok<SAGROW>
		Labels_Grid{end+1} = Active_GridVars{j,2}; %#ok<SAGROW>
	end
	% Format Diagrams:
	figure(fig_oat_voltage_sum); 
	ax = gca;
	ax.Title.String = ['Profilsatz ',num2str(i)];
	% Legend
	if i == 1 && numel(Option_Active_Scenarios) > 1
		legend(Labels_Scenarios);
	end
	if i == 2 && numel(Option_Active_GridVariants) > 1
		l = legend(Labels_Gridstyle, Labels_Grid);
	end
	% X Axis
	[tick_x_Positions, tick_x_Labels] = get_tick_x_single_day_profile();
	ax.XAxis.Limits       = [0 144];
	ax.XAxis.TickValues   = tick_x_Positions;
	ax.XAxis.TickLabels   = tick_x_Labels;
	% Y Axis
	if Option_y_max_Value > 0
		ax.YAxis.Limits       = [Option_y_min_Value Option_y_max_Value];
		if Option_y_step_Value > 0
			tick_y_Positions = Option_y_min_Value:Option_y_step_Value:Option_y_max_Value;
			tick_y_Labels    = tick_y_Positions;
			ax.YAxis.TickValues   = tick_y_Positions;
			ax.YAxis.TickLabels   = tick_y_Labels;
		end

	end
	set_default_plot_properties(ax);
	figure(fig_oat_voltage_sum); hold off;
end

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =