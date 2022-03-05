clear();
Saved_Data_OAT   = [];

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up / Loading of OAT Data
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (loading the data) and the next one (set up of
% information) have to be executed before every other cell! 


% Paths to source files:
Path_Data_OAT = ['C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\',...
	'Results_mean\01_Merged_OAT-Data\'];

% Add folder with help functions / needed classes to path:
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
scriptfolderpath = fileparts(scriptpath);
addpath([scriptpath, filesep, 'Additional_Resources']);
addpath([fileparts(scriptfolderpath),filesep,'NAT_Common',filesep,'Analyzing']);
addpath([fileparts(scriptfolderpath),filesep,'NAT_Common',filesep,'Grid_Representation']);

% Load OAT Data
folders = dir(Path_Data_OAT);
folders = struct2cell(folders);
folders = folders(1,3:end);

sep = cell(1,numel(folders));
sep(:) = {' - '};
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
clear script* sep folders i NVIEW_*

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Additional Set Up / Configuration
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Settings_Scenario = {...
% 1     2                                                 3                 4          5
% ID ,  Filename                                        , Color           , LineStyle, String for legend 
	 1, '01_SB_Base_Winter_Workda'                      ,[ 74,126,187]/256, '-'      , 'SB Winter';...
	 2, '02_SB_Base_Summer_Workda'                      ,[ 74,126,187]/256, '-'      , 'SB Summer';...
	 3, '03_S1_LowLoadHighInfeed_Winter_Workda'         ,[190, 75, 72]/256, '-'      , 'S1 Winter';...
	 4, '04_S1_LowLoadHighInfeed_Summer_Workda'         ,[190, 75, 72]/256, '-'      , 'S1 Summer';...
	 5, '05_S2_HighLoadHighInfeed_Winter_Workda'        ,[152,185, 84]/256, '-'      , 'S2 Winter';...
	 6, '06_S2_HighLoadHighInfeed_Summer_Workda'        ,[152,185, 84]/256, '-'      , 'S2 Summer';...
	 7, '07_S3_HighLoadHighInfeed2Nodes_Winter_Workda'  ,[128,100,162]/256, '-'      , 'S3 Winter';...
	 8, '08_S3_HighLoadHighInfeed2Nodes_Summer_Workda'  ,[128,100,162]/256, '-'      , 'S3 Summer';...
	 9, '09_S4_MediumLoadHighInfeed2Nodes_Winter_Workda',[247,173, 36]/256, '-'      , 'S4 Winter';...
	10, '10_S4_MediumLoadHighInfeed2Nodes_Summer_Workda',[247,173, 36]/256, '-'      , 'S4 Summer';...
	};

Settings_GridVariants = {...
% 1     2                                  3                 4          5
% ID ,  Sub-Structure Name               , Color           , LineStyle, String for legend 
    1, 'g01_Base_NS_50_Nodes'            ,[256,256,256]/256, '--'     , 'Basisnetz';...
    2, 'g02_Repalce_OH_Lines_With_Cables',[256,256,256]/256, '-.'     , 'Ersatz Oberleitung';...
    3, 'g03_Add_Cable_to_First_OH_Line'  ,[256,256,256]/256, ':'      , 'Verstärkung Oberleitung';...
    4, 'g04_Add_Cable_to_Weak_Cables'    ,[256,256,256]/256, '-'      , 'Verstärkung Kabel';...
	};

Settings_Datasets = {
	1, 'Households'  , 'Haushaltslast'   ;...
	2, 'Solar'       , 'PV Einspeisung'  ;...
	3, 'El_Mobility' , 'Elektromobilität';...
	};

Settings_Number_Profiles = 10;
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot the Mean Voltage Values
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = [6, 8];
% Option_Active_Scenarios = 2:2:10;   % Sommer
% Option_Active_Scenarios = 1:2:10;   % Winter
% Option_Active_Scenarios = 1:10;     % All scenarios (not recomended!)
% Option_Active_Scenarios = 8;
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Active_GridVariants = 1:4;     % all grid varaiants
% Option_Active_GridVariants = 2;
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Y-axis Settings
Option_y_max_Value  = -1;   % -1 ... autoscale
Option_y_min_Value  = 0.97;
Option_y_step_Value = 0.02; % -1 ... autostep
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Label and title strings:
Labels_Title_full_Comparison =  'Mittlerer Verlauf Spannung'; % Title, if > 1 scenario and > 1 grid variant...
Labels_Title_one_Variant     = ['Mittlerer Verlauf Spannung für Netzvariante "',Settings_GridVariants{Option_Active_GridVariants,2},'"'];
Labels_Title_one_Scenario    = ['Mittlerer Verlauf Spannung für Scenario "',Settings_Scenario{Option_Active_Scenarios,2},'"'];
Option_show_Title  = 1; % 1 ... show Title, 0 ... no Title for export to Word...
Labels_X_Direction = 'Tageszeit [h]';
Labels_Y_Direction = 'Spannung [p.u.]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i = 1 : Saved_Data_OAT.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_GridVars  = Settings_GridVariants(Option_Active_GridVariants,:);
		
		if Option_show_Title
			if numel(Option_Active_GridVariants) < 2
				Labels_Title = Labels_Title_one_Variant;
			else
				if numel(Option_Active_Scenarios) > 1
					Labels_Title = Labels_Title_full_Comparison;
				else
					Labels_Title = Labels_Title_one_Scenario;
				end
			end
		else
			Labels_Title = []; %#ok<UNRCH>
		end
		
		fig_oat_voltage_sum = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
		
	end
	
	figure(fig_oat_voltage_sum); nexttile;
	Labels_Scenarios  = {};
	Labels_Scen_Style = [];
	Labels_Grid       = {};
	Labels_Grid_Style = [];
	Data = Saved_Data_OAT.(['Saved_',num2str(i)]).NVIEW_Processed;
	
	for j = 1:size(Active_GridVars,1)
		for k = 1 : size(Active_Scenarios,1)
			Data_Voltage_Timeline =...
				zeros(1,Data.Control.Simulation_Options.Timepoints_per_dataset);
			for t = 1 : Data.Control.Simulation_Options.Timepoints_per_dataset
				Data_Voltage_Timeline(t) = nansum(nansum(squeeze(nansum(squeeze(Data.(Active_GridVars{j,2}).bus_voltages(Active_Scenarios{k,1},:,t,:,:)))))) / ...
					(size(Data.(Active_GridVars{j,2}).bus,1)*Data.Control.Simulation_Options.Number_of_datasets*3);
			end
			figure(fig_oat_voltage_sum); pl = plot(Data_Voltage_Timeline);
			set(pl, 'Color', Active_Scenarios{k,3});
			set(pl, 'LineStyle', Active_Scenarios{k,4});
			if size(Active_GridVars,1) > 1
				set(pl, 'LineStyle', Active_GridVars{j,4});
			end
			drawnow;
			if j == 1
				% get the legend entries for the scenarios:
				Labels_Scenarios{end+1} = Active_Scenarios{k,5}; %#ok<SAGROW>
				pl = plot(nan, nan);	                         % make an invisible line for legend	
				set(pl,...
					'Color', Active_Scenarios{k,3},...       % set color of invisible line
					'LineStyle', Active_Scenarios{k,4});         % set linestyle of invisible line
				Labels_Scen_Style(end+1) = pl; %#ok<SAGROW>
			end
			if k <=1
				figure(fig_oat_voltage_sum); hold on;
			end
		end
		% get the legend entries for the grid variants:
		Labels_Grid{end+1} = Active_GridVars{j,5}; %#ok<SAGROW>
		pl = plot(nan, nan);	                   % make an invisible line for legend
		set(pl,...
			'Color', 'k',...                       % set color of invisible line
			'LineStyle', Active_GridVars{j,4});    % set linestyle of invisible line
		Labels_Grid_Style(end+1) = pl; %#ok<SAGROW>
	end
	% Format Diagrams:
	figure(fig_oat_voltage_sum); 
	ax = gca;
	ax.Title.String = ['Profilsatz ',num2str(i)];
	% Legend
	if i == 1 && numel(Option_Active_Scenarios) > 1
		legend(Labels_Scen_Style, Labels_Scenarios);
	end
	if i == 2 && numel(Option_Active_GridVariants) > 1
		legend(Labels_Grid_Style, Labels_Grid);
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

clear Active_* ax Data i j k t Labels_* Option_* pl tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =