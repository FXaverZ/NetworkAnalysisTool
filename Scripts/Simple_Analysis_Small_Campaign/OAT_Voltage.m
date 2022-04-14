%%= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% clear();
Saved_Data_OAT           = [];
Saved_Recalculation_Data = []; % Hint: Save this structure for later use...
% Add folder with help functions / needed classes to path:
addpath([fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'Additional_Resources']);
addpath([fileparts(fileparts(fileparts(matlab.desktop.editor.getActiveFilename))),filesep,'NAT_Common',filesep,'Analyzing']);
addpath([fileparts(fileparts(fileparts(matlab.desktop.editor.getActiveFilename))),filesep,'NAT_Common',filesep,'Grid_Representation']);
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up / Loading of OAT Data
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (loading the data) and the next one (set up of
% information) have to be executed before every other cell!

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Paths to source files:
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Path_Data_OAT = ['C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\',...
Path_Data_OAT = ['D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\'...
	'Results_mean\01_Merged_OAT-Data\'];

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Load OAT Data
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
folders = dir(Path_Data_OAT);
folders = struct2cell(folders);
folders = folders(1,3:end);

sep = cell(1,numel(folders));
sep(:) = {' - '};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
folders = unique(folders);
disp('Loading OAT Data...');
NVIEW_Data_Names = {'NVIEW_Results', 'NVIEW_Analysis_Selection', 'NVIEW_Control', 'NVIEW_Processed'};
if ~isfield(Saved_Data_OAT, 'Extraction_Dates')
	Saved_Data_OAT.Extraction_Dates = zeros(1,numel(folders));
end
for i_d = 1: numel(folders)
	disp(['    Reading File ',num2str(i_d),' of ',num2str(numel(folders))]);
	if ~isfield(Saved_Data_OAT,['Saved_',num2str(i_d)])
		Saved_Data_OAT.(['Saved_',num2str(i_d)]) = load([Path_Data_OAT,...
			folders{i_d},' - 000 - OAT-Data.mat'],NVIEW_Data_Names{:});
		% Get the date of input data extraction:
		NVIEW_Extraction_Date = Saved_Data_OAT.(['Saved_',...
			num2str(i_d)]).NVIEW_Control.Simulation_Options.NAT_Settings.Simulation.Scenarios_Path;
		[~,NVIEW_Extraction_Date_1,NVIEW_Extraction_Date_2] = fileparts(NVIEW_Extraction_Date);
		NVIEW_Extraction_Date = [NVIEW_Extraction_Date_1,NVIEW_Extraction_Date_2];
		NVIEW_Extraction_Date = datenum(NVIEW_Extraction_Date,'yyyy_mm_dd-HH.MM.SS');
		Saved_Data_OAT.Extraction_Dates(i_d) = NVIEW_Extraction_Date;
	end
end
disp('... done!');
Saved_Data_OAT.Number_Datasets = numel(folders);
[~,NVIEW_IX] = sort(Saved_Data_OAT.Extraction_Dates);
Saved_Data_OAT.Sorting_Idxs = NVIEW_IX;
clear sep folders i_* NVIEW_*

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Additional Set Up / Configuration
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Settings_Scenarios = {...
	% 1      2                                                3                 4          5
	% ID  ,  Filename                                       , Color           , LineStyle, String for legend
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
	% 1     2                                                 3                 4          5
	% ID ,  Sub-Structure Name                              , Color           , LineStyle, String for legend
	1, 'g01_Base_NS_50_Nodes'                           ,[  0,  0,  0]/256, '--'     , 'Basisnetz';...
	2, 'g02_Repalce_OH_Lines_With_Cables'               ,[153,102, 51]/256, '-.'     , 'Ersatz Oberleitung';...
	3, 'g03_Add_Cable_to_First_OH_Line'                 ,[128,100,162]/256, ':'      , 'Verstärkung Oberleitung';...
	4, 'g04_Add_Cable_to_Weak_Cables'                   ,[  0,153,153]/256, '-'      , 'Verstärkung Kabel';...
	};

Settings_VoltageBands = {
	% 1     2     3      4                 5          6
	% ID ,  Umin, Umax,  Color           , LineStyle, Alpha, String for legend
	1,    90,  110, [  0,176, 80]/256, '-'      ,  0.25, '±10%';...
	2,    95,  105, [255,  0,  0]/256, '-'      ,  0.25, '±5%';...
	3,    98,  107, [255,192,  0]/256, '-'      ,  0.25, '+7%…2%';...
	4,    97,  103, [  0,  0,  0]/256, '-'      ,  0.15, '±3%';...
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
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Label and title strings:
Labels_Title_full_Comparison =  'Mittlerer Verlauf Spannung'; % Title, if > 1 scenario and > 1 grid variant...
Labels_Title_one_Variant     = ['Mittlerer Verlauf Spannung für Netzvariante "',Settings_GridVariants{Option_Active_GridVariants,2},'"'];
Labels_Title_one_Scenario    = ['Mittlerer Verlauf Spannung für Szenario "',Settings_Scenarios{Option_Active_Scenarios,2},'"'];
Option_show_Title  = 1; % 1 ... show Title, 0 ... no Title for export to Word...
Labels_X_Direction = 'Tageszeit [h]';
Labels_Y_Direction = 'Spannung [p.u.]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
for i_d = 1 : Saved_Data_OAT.Number_Datasets
	i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
	if i_d <= 1
		Active_Scenarios = Settings_Scenarios(Option_Active_Scenarios,:);
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
	Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
	
	for i_g = 1:size(Active_GridVars,1)
		for i_s = 1 : size(Active_Scenarios,1)
			Data_Voltage_Timeline =...
				zeros(1,Data.Control.Simulation_Options.Timepoints_per_dataset);
			for i_t = 1 : Data.Control.Simulation_Options.Timepoints_per_dataset
				Data_Voltage_Timeline(i_t) = nansum(nansum(squeeze(nansum(squeeze(Data.(Active_GridVars{i_g,2}).bus_voltages(Active_Scenarios{i_s,1},:,i_t,:,:)))))) / ...
					(size(Data.(Active_GridVars{i_g,2}).bus,1)*Data.Control.Simulation_Options.Number_of_datasets*3);
			end
			figure(fig_oat_voltage_sum); f_l = plot(Data_Voltage_Timeline);
			set(f_l, 'Color', Active_Scenarios{i_s,3});
			set(f_l, 'LineStyle', Active_Scenarios{i_s,4});
			if size(Active_GridVars,1) > 1
				set(f_l, 'LineStyle', Active_GridVars{i_g,4});
			end
			drawnow;
			if i_g == 1
				% get the legend entries for the scenarios:
				Labels_Scenarios{end+1} = Active_Scenarios{i_s,5}; %#ok<SAGROW>
				f_l = plot(nan, nan);	                         % make an invisible line for legend
				set(f_l,...
					'Color', Active_Scenarios{i_s,3},...       % set color of invisible line
					'LineStyle', Active_Scenarios{i_s,4});         % set linestyle of invisible line
				Labels_Scen_Style(end+1) = f_l; %#ok<SAGROW>
			end
			if i_s <=1
				figure(fig_oat_voltage_sum); hold on;
			end
		end
		% get the legend entries for the grid variants:
		Labels_Grid{end+1} = Active_GridVars{i_g,5}; %#ok<SAGROW>
		f_l = plot(nan, nan);	                   % make an invisible line for legend
		set(f_l,...
			'Color', 'k',...                       % set color of invisible line
			'LineStyle', Active_GridVars{i_g,4});    % set linestyle of invisible line
		Labels_Grid_Style(end+1) = f_l; %#ok<SAGROW>
	end
	% Format Diagrams:
	figure(fig_oat_voltage_sum);
	f_ax = gca;
	f_ax.Title.String = ['Profilsatz ',num2str(i_d)];
	% Legend
	if i_d == 1 && numel(Option_Active_Scenarios) > 1
		legend(Labels_Scen_Style, Labels_Scenarios);
	end
	if i_d == 2 && numel(Option_Active_GridVariants) > 1
		legend(Labels_Grid_Style, Labels_Grid);
	end
	% X Axis
	[tick_x_Positions, tick_x_Labels] = get_tick_x_single_day_profile();
	f_ax.XAxis.Limits       = [0 144];
	f_ax.XAxis.TickValues   = tick_x_Positions;
	f_ax.XAxis.TickLabels   = tick_x_Labels;
	% Y Axis
	if Option_y_max_Value > 0
		f_ax.YAxis.Limits       = [Option_y_min_Value Option_y_max_Value];
		if Option_y_step_Value > 0
			tick_y_Positions = Option_y_min_Value:Option_y_step_Value:Option_y_max_Value;
			tick_y_Labels    = tick_y_Positions;
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
	end
	set_default_plot_properties(f_ax);
	figure(fig_oat_voltage_sum); hold off;
end

clear Active_* Data* f_* i_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Voltage Band Violation Summary
% = = = = = = = = = = = = = = = = =
Option_Number_Datasets_to_Use = 15;
%- - - - - - - - - - - - - - - - - -
Option_VoltageBand = 3; % 1: +-10% Default (no recalculations!), 2: +-5%, 3: -2...+7%, 4: +-3%
%- - - - - - - - - - - - - - - - - -
Option_Active_Scenarios = 1;%1:1:10;
%- - - - - - - - - - - - - - - - - -
Option_Active_GridVariants = 2;%1:4;     % all grid varaiants
%- - - - - - - - - - - - - - - - - -
Option_Bar_x_max_Value  = 100;  % (-1 ... autoscale)
Option_Number_Bins      = 100;
Option_Bar_x_min_Value  =   0;
Option_Bar_x_Label_Step =  10; % Spacing between label entries
Option_Bar_x_Last_GT    =   0; % 1 = show last label with leading ">" sign
%- - - - - - - - - - - - - - - - - -
Option_Bar_y_max_Value  = -1; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =  0; % '%'
Option_Bar_y_step_Value =  4; % '%'
% = = = = = = = = = = = = = = = = =
Option_show_Title            = 1; % 1 ... show Title, 0 ... no Title for export to Word...
Labels_Title_full_Comparison =  'Histogramm '; % Title, if > 1 scenario and > 1 grid variant...
Labels_Title_one_Variant     = ['Histogramm für Netzvariante "',Settings_GridVariants{Option_Active_GridVariants,5},'"'];
Labels_Title_one_Scenario    = ['Histogramm für Szenario "',Settings_Scenarios{Option_Active_Scenarios,5},'"'];
Labels_Title                 = 'Spannungsbandverletzungen';
Labels_X_Direction           = 'Spannungsbandverletzung in % der Profilzeit';
Labels_Y_Direction           = 'Relative Häufigkeit [%]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
for i_d = 1 : Option_Number_Datasets_to_Use
	i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	%     Preprocessing...
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenarios(Option_Active_Scenarios,:);
		Active_GridVars  = Settings_GridVariants(Option_Active_GridVariants,:);
		
		Option_Umin =  Settings_VoltageBands{Option_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_VoltageBand,3};
		
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
		
		fig_oat_histogram = set_up_singleplot();
		
		% [gridvariant datasets scenarios]:
		Data_Violation_Numbers      = zeros(...
			numel(Option_Active_GridVariants),...
			Option_Number_Datasets_to_Use * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Recalculation_Needed = [];
	end
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	%     Prepare Data...
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if isempty(Data_Recalculation_Needed)
		% Check, if data has to be recalculated...
		Data_ID = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed.Control.ID;
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		Data_IDs = split(Data_ID,'_');
		Data_Umin = str2double(Data_IDs{4})/100;
		Data_Umax = str2double(Data_IDs{5})/100;
		if (abs(Data_Umin - Option_Umin/100) > 0.001) || (abs(Data_Umax - Option_Umax/100) > 0.001)
			Data_Recalculation_Needed = true;
			disp('Recalculation of OAT Data...');
			if(~isfield(Saved_Recalculation_Data,['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]))
				Saved_Recalculation_Data.(...
					['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]) = [];
			end
		else
			Data_Recalculation_Needed = false;
		end
	end
	idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
	i_recalc_counter = 0;
	if (Data_Recalculation_Needed)
		disp(['    Processing profile set ',num2str(i_d),' of ',num2str(Option_Number_Datasets_to_Use)]);
		% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
		%     Recalculation Voltage Band Violation Analysis
		% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
		for i_g = 1:size(Active_GridVars,1)
			% First look up, if data is allready present:
			if(isfield(Saved_Recalculation_Data.(['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]),['Saved_',num2str(i_d)]))
				% Data for this dataset is present
				Data_save = Saved_Recalculation_Data.(['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(['Saved_',num2str(i_d)]);
				if(isfield(Data_save,Active_GridVars{i_g,2}))
					% Data for this grid variant is present
					Data_Recalculate_Scenarios = [];
					for i_s = 1 : numel(Option_Active_Scenarios)
						if(~isfield(Data_save.(Active_GridVars{i_g,2}), ['Sc_',num2str(Active_Scenarios{i_s,1})]))
							Data_Recalculate_Scenarios(end+1) = Active_Scenarios{i_s,1}; %#ok<SAGROW>
						end
					end
				else
					% Grid-Data is missing
					Data_Recalculate_Scenarios = Option_Active_Scenarios;
				end
			else
				% Datafile-Data is missing
				Data_Recalculate_Scenarios = Option_Active_Scenarios;
			end
			i_recalc_counter = i_recalc_counter + numel(Data_Recalculate_Scenarios);
			% Recalculate needed data...
			Data_bus_voltages_raw = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Results.(Active_GridVars{i_g,2}).bus_voltages;
			Data_bus_voltages_raw = Data_bus_voltages_raw(Data_Recalculate_Scenarios,:,:,:,:);
			Data_bus_info     = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Results.(Active_GridVars{i_g,2}).bus;
			[...
				Data_voltage_violations,...
				Data_bus_violations,...
				Data_bus_statistics,...
				Data_bus_violations_at_datasets, ...
				Data_bus_violated_at_datasets, ...
				Data_bus_deviations, ...
				Data_bus_voltages...
				] = analysis_voltage (Data_bus_voltages_raw, Data_bus_info, Data_Timepoints, Settings_Number_Profiles, Option_Umin/100, Option_Umax/100);
			
			% Save the values for later use...
			Data_res = [];
			for i_s = 1 : numel(Data_Recalculate_Scenarios)
				Data_res.voltage_violations         = Data_voltage_violations(i_s,:,:,:);
				Data_res.bus_violations             = Data_bus_violations(:,i_s);
				Data_res.bus_statistics             = Data_bus_statistics(:,i_s);
				Data_res.bus_violations_at_datasets = Data_bus_violations_at_datasets(:,i_s);
				Data_res.bus_violated_at_datasets   = Data_bus_violated_at_datasets(:,i_s);
				Data_res.bus_deviations             = Data_bus_deviations(i_s,:,:);
				Data_res.bus_voltages               = Data_bus_voltages(i_s,:,:,:,:);
				Saved_Recalculation_Data.(...
					['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
					['Saved_',num2str(i_d)]).(...
					Active_GridVars{i_g,2}).(...
					['Sc_',num2str(Settings_Scenarios{Data_Recalculate_Scenarios(i_s),1})]) = Data_res;
			end
			
			% Read out out the needed data...
			for i_s = 1 : numel(Option_Active_Scenarios)
				Data_Violation_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
					['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
					['Saved_',num2str(i_d)]).(...
					Active_GridVars{i_g,2}).(...
					['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets;
			end
		end
		disp(['        Processed ',num2str(i_recalc_counter),' Datasets.'])
		% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	else
		Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
		% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
		%     Data Extraction of Voltage Band Violation Analysis
		% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
		for i_g = 1:size(Active_GridVars,1)
			Data_Violation_Numbers(i_g,idx_datasets,:) = ...
				Data.(Active_GridVars{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios);
		end
		% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	end
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	%     Plotting Data...
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d >= Option_Number_Datasets_to_Use
		if (Data_Recalculation_Needed)
			disp('    ... done!');
		end
		Option_Histogramm_Autoscale = true;
		
		Labels_Scenarios  = {};
		Labels_Scen_Style = [];
		
		% Convert from Number of Timepoints voilation occured to % of
		% profile time:
		Data_Violation_Numbers = Data_Violation_Numbers * 100 ./ Data_Timepoints;
		
		if Option_Bar_x_max_Value < 0
			Option_Bar_x_max_Value = max(Data_Violation_Numbers,[],'all');
			Option_Bar_x_min_Value = min(Data_Violation_Numbers,[],'all');
		else
			Option_Histogramm_Autoscale = false;
		end
		Hist_binEdges = linspace(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins+1);
		Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2;
		
		for i_s = 1 : numel(Option_Active_Scenarios)
			for i_g = 1 : numel(Option_Active_GridVariants)
				Hist_Data = Data_Violation_Numbers(i_g,:,i_s)';
				[~,Hist_binIdx] = histc(Hist_Data,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
				Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
				
				figure(fig_oat_histogram);
				f_b = bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
				set(f_b,...
					'EdgeColor',Active_Scenarios{i_s,3},...
					'LineStyle',Active_GridVars{i_g,4},...
					'LineWidth',1.0,...
					'EdgeAlpha',1.0,...
					'FaceColor',Active_Scenarios{i_s,3},...
					'FaceAlpha',0.5);
				hold on;
			end
			% get the legend entries for the scenarios:
			Labels_Scenarios{end+1} = Active_Scenarios{i_s,5}; %#ok<SAGROW>
			f_l = plot(nan, nan);	                         % make an invisible line for legend
			set(f_l,...
				'Color', Active_Scenarios{i_s,3},...       % set color of invisible line
				'LineStyle', Active_Scenarios{i_s,4});         % set linestyle of invisible line
			Labels_Scen_Style(end+1) = f_l; %#ok<SAGROW>
		end
		figure(fig_oat_histogram);
		f_ax = gca;
		if ~Option_Histogramm_Autoscale
			set_tick_x_histogramms(...
				Option_Bar_x_min_Value,...
				Option_Bar_x_max_Value,...
				Option_Number_Bins,...
				Option_Bar_x_Label_Step,...
				Option_Bar_x_Last_GT,...
				f_ax)
		end
		if numel(Option_Active_Scenarios) > 1
			legend(Labels_Scen_Style, Labels_Scenarios);
		end
		set_default_plot_properties(f_ax);
		set_single_plot_properties(f_ax, Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_show_Title);
		hold off;
	end
end

clear Active_* Data* f_* Hist_* i_* idx_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot violation Summary over all Scenarios
% = = = = = = = = = = = = = = = = =
Option_VoltageBand         = 1:4;
Option_Active_Scenarios    = 1:1:10;
Option_Active_GridVariants = 1; % only one can be active here!
Option_Used_Data           = 'Time'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 105; % (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; %
Option_Plot_x_step_Value =  10; %
Option_Plot_x_Label_Step =   1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - -
Option_Plot_Size =   'medium'; % 'compact', 'medium', 'large'
Option_Scen_Divider = 2;       % Divider every X scenarios
Option_Show_Legend  = 1;
Option_Show_Max_Marker = 1; % 1 = a marker indicates the maximum value occuring in the datasets
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_v = 1:numel(Option_VoltageBand)
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	%     Preprocessing...
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_v <= 1
		Active_Scenarios = Settings_Scenarios(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_VoltageBand,:);
		% get the Timepointsnumber from the first saved Dataset
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		% [voltagebands datasets scenarios]:
		Data_Violation_Numbers      = zeros(...
			numel(Option_VoltageBand),...
			Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Violation_Bus_Numbers = Data_Violation_Numbers;
	end
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	%     Prepare Data...
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Option_Umin =  Settings_VoltageBands{i_v,2};
	Option_Umax =  Settings_VoltageBands{i_v,3};
	for i_d = 1 : Saved_Data_OAT.Number_Datasets
		idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
		% Read out out the needed data...
		if Settings_VoltageBands{i_v,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(i_v,idx_datasets,:) = ...
				Data.(Settings_GridVariants{Option_Active_GridVariants,2}).bus_violations_at_datasets(:,Option_Active_Scenarios);
			Data_Violation_Bus_Numbers(i_v,idx_datasets,:) = ...
				Data.(Settings_GridVariants{Option_Active_GridVariants,2}).bus_violated_at_datasets(:,Option_Active_Scenarios);
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(i_v,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{Option_Active_GridVariants,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets;
					Data_Violation_Bus_Numbers(i_v,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{Option_Active_GridVariants,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violated_at_datasets;
				catch
					% if this error occurs, the previous cell has to to be run
					% or the correct data has to be loaded into the
					% "Saved_Recalculation_Data" structure!
					error('Error loading data, get sure, the structure "Saved_Recalculation_Data" has all needed data!')
				end
			end
		end
	end
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	%     Plotting Data...
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_v >= numel(Option_VoltageBand)
		% rearrange data for plot
		
		switch Option_Used_Data
			case 'Time'
				Data_Plot = squeeze(sum(Data_Violation_Numbers,2));
				Data_Plot = Data_Plot * 100 / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles * Data_Timepoints);
				Data_Plot_Max = squeeze(max(Data_Violation_Numbers,[],2));
				Data_Plot_Max = Data_Plot_Max * 100 / Data_Timepoints;
				Data_Plot_Max = Data_Plot_Max - Data_Plot;
			case 'Node'
				Data_Plot = squeeze(sum(Data_Violation_Bus_Numbers,2));
				Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{Option_Active_GridVariants,2}).bus_name);
				Data_Plot = Data_Plot * 100 / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles * Number_total_Busses);
				Data_Plot_Max = squeeze(max(Data_Violation_Bus_Numbers,[],2));
				Data_Plot_Max = Data_Plot_Max * 100 / Number_total_Busses;
				Data_Plot_Max = Data_Plot_Max - Data_Plot;
		end
		
		% Reverse order
		Data_Plot     = flip(Data_Plot',2);
		Data_Plot_Max = flip(Data_Plot_Max',2);
		
		fig_oat_summary_violation = set_up_singleplot(Option_Plot_Size);
		% crate a axis under the real one for Labeling between the Ticks
		f_under_ax = cla();
		% creat the visible axis
		f_ax = copyobj(f_under_ax, ancestor(f_under_ax,'figure'));
		
		% plot the data
		f_b = barh(f_ax, cell2mat(Active_Scenarios(:,1)),Data_Plot,'BarLayout','grouped');
		% plot invisible data to underlying axis:
		f_under_b = barh(f_under_ax, cell2mat(Active_Scenarios(:,1)),nan);
		% format the bars:
		idx_fliped = flip(1 : numel(Option_VoltageBand));
		for i_vb = 1 : numel(Option_VoltageBand)
			f_bb = f_b(i_vb);
			f_bb.LineStyle = 'none';
			f_bb.FaceColor = Active_Voltagebands{idx_fliped(i_vb),4};
			f_bb.FaceAlpha = Active_Voltagebands{idx_fliped(i_vb),6};
			f_bb.BarWidth = 1;
		end
		if Option_Show_Max_Marker
			hold(f_ax,'on');
			f_ngroups = size(Data_Plot, 1);
			f_nbars = size(Data_Plot, 2);
			f_groupwidth = min(0.8, f_nbars/(f_nbars + 1.5));
			for i_eb = 1:f_nbars
				f_x = (1:f_ngroups) - f_groupwidth/2 + (2*i_eb-1) * f_groupwidth / (2*f_nbars);
				f_er = errorbar(f_ax,Data_Plot(:,i_eb),f_x, zeros(1,f_ngroups),Data_Plot_Max(:,i_eb),'horizontal','k', 'linestyle', 'none');
				f_er.Color = Active_Voltagebands{idx_fliped(i_eb),4};
				% Set transparency (undocumented)
				set(f_er.Bar, 'ColorType', 'truecoloralpha', 'ColorData', [f_er.Line.ColorData(1:3); 255*Active_Voltagebands{idx_fliped(i_vb),6}])
				set(f_er.Line, 'ColorType', 'truecoloralpha', 'ColorData', [f_er.Line.ColorData(1:3); 255*Active_Voltagebands{idx_fliped(i_vb),6}])
				set(f_er.CapH, 'EdgeColorType', 'truecoloralpha', 'EdgeColorData', [f_er.CapH.EdgeColorData(1:3); 255*Active_Voltagebands{idx_fliped(i_vb),6}])
				set(f_er.MarkerHandle, 'visible', 'off')
			end
		end
		
		figure(fig_oat_summary_violation);
		% X Axis
		if Option_Plot_x_max_Value > 0
			f_ax.XAxis.Limits = [Option_Plot_x_min_Value, Option_Plot_x_max_Value];
			[tick_x_Positions, tick_x_Labels] = get_tick(...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step);
			f_ax.XAxis.TickValues   = tick_x_Positions;
			f_ax.XAxis.TickLabels   = tick_x_Labels;
		end
		% Legend
		if Option_Show_Legend
			legend(f_ax, Active_Voltagebands(:,7));
		end
		
		set_default_plot_properties(f_ax);
		
		% Set the special properties for this plot
		f_ax.YDir = 'reverse';
		f_under_ax.YDir = 'reverse';
		% Set y tick to 1/2 way between bar groups
		f_ax.YTick = (floor(min(ylim(f_ax))) : Option_Scen_Divider : ceil(max(ylim(f_ax)))) + 0.5;
		f_ax.YTickLabel = [];
		f_under_ax.XTickLabel = [];
		f_under_ax.YAxis.Limits = f_ax.YAxis.Limits;
		f_under_ax.Position = f_ax.Position;
		% Generate the labels:
		YTickLabel = cell(1,numel(Option_Active_Scenarios));
		for i_s = 1 : numel(Option_Active_Scenarios)
			YTickLabel{i_s} = num2str(Active_Scenarios{i_s,1},'%02.0f');
		end
		f_under_ax.YTickLabel = YTickLabel;
		f_under_ax.FontName   = 'Palatino Linotype';
		f_under_ax.FontSize   = 16; %Fontsize_normal  = 16; in "set_default_plot_properties"
		
		if Option_Show_Legend
			legend(f_ax, flip(Active_Voltagebands(:,7)));
		end
	end
end

clear Active_* Data* f_* i_* idx_* Option_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Show development profilnumber with boxplots
% = = = = = = = = = = = = = = = = =
Option_VoltageBand         = 4; % only one can be active here!
Option_Active_Scenarios    = 2; % only one can be active here!
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  =  15; % (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; %
Option_Plot_x_step_Value =   5; %
Option_Plot_x_Label_Step =   1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - -
Option_Plot_y_max_Value  = 100; % (-1 ... autoscale)
Option_Plot_y_min_Value  =   0; %
Option_Plot_y_step_Value =  10; %
Option_Plot_y_Label_Step =   1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - -
Option_Default_Line_Width = 1.5;
Option_Show_Legend_Plot   =   4; % determines in which plot should the legend is shown; -1: Show no legend
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
for i_g = 1:size(Settings_GridVariants,1)
	if i_g <= 1
		fig_oat_development_boxplot = set_up_tiledlayout_small([],[],[]);
		warning('off','MATLAB:handle_graphics:Layout:NoPositionSetInTiledChartLayout');
	end
	nexttile();
	for i_d = 1:Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		if i_d <= 1
			Active_Scenarios = Settings_Scenarios(Option_Active_Scenarios,:);
			Active_Voltagebands = Settings_VoltageBands(Option_VoltageBand,:);
			Active_GridVariant = Settings_GridVariants(i_g,:);
			% get the Timepointsnumber from the first saved Dataset
			Data_Timepoints = ...
				Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
			% [datapoints scenarios]:
			Data_Violation_Numbers      = NaN(...
				Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
				numel(Option_Active_Scenarios));
			Data_Violation_Development = NaN(...
				Saved_Data_OAT.Number_Datasets,...
				Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
				numel(Option_Active_Scenarios));
		end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Option_Umin =  Settings_VoltageBands{Option_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_VoltageBand,3};
		
		idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
		% Read out out the needed data...
		if Settings_VoltageBands{Option_VoltageBand,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios);
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets;
				catch
					% if this error occurs, the previous cell has to to be run
					% or the correct data has to be loaded into the
					% "Saved_Recalculation_Data" structure!
					error('Error loading data, get sure, the structure "Saved_Recalculation_Data" has all needed data!')
				end
			end
		end
		Data_Violation_Development(i_d,:,:) = Data_Violation_Numbers;
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		if i_d >= Saved_Data_OAT.Number_Datasets
			
			Data_Violation_Development = Data_Violation_Development * 100/ Data_Timepoints;
			figure(fig_oat_development_boxplot);
			boxplot(Data_Violation_Development',...
				'Widths',0.5,...
				'OutlierSize',3);
			
			f_ax = gca;
			f_bx = findobj(f_ax,'Tag','boxplot');
			set(findobj(f_bx,'Tag','Box'),'LineWidth',Option_Default_Line_Width, 'Color', Active_GridVariant{1,3});
			set(findobj(f_bx,'Tag','Upper Whisker'),'LineStyle','-', 'Color', Active_GridVariant{1,3});
			set(findobj(f_bx,'Tag','Lower Whisker'),'LineStyle','-', 'Color', Active_GridVariant{1,3});
			set(findobj(f_bx,'Tag','Median'),'LineWidth',2, 'Color', Active_GridVariant{1,3});
			set(findobj(f_bx,'Tag','Lower Adjacent Value'), 'Color', Active_GridVariant{1,3});
			set(findobj(f_bx,'Tag','Upper Adjacent Value'), 'Color', Active_GridVariant{1,3});
			f_ol = findobj(f_ax,'tag','Outliers');
			for i_ol = 1:numel(f_ol)
				f_ol(i_ol).MarkerEdgeColor = [190, 75, 72]/256;
			end
			% X Axis
			if Option_Plot_x_max_Value > 0
				%f_ax.XAxis.Limits = [Option_Plot_x_min_Value, Option_Plot_x_max_Value];
				[tick_x_Positions, tick_x_Labels] = get_tick(...
					Option_Plot_x_min_Value,...
					Option_Plot_x_step_Value,...
					Option_Plot_x_max_Value,...
					Option_Plot_x_Label_Step);
				f_ax.XAxis.TickValues   = tick_x_Positions;
				f_ax.XAxis.TickLabels   = tick_x_Labels;
			end
			% Y Axis
			if Option_Plot_y_max_Value > 0
				f_ax.YAxis.Limits = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
				[tick_y_Positions, tick_y_Labels] = get_tick(...
					Option_Plot_y_min_Value,...
					Option_Plot_y_step_Value,...
					Option_Plot_y_max_Value,...
					Option_Plot_y_Label_Step);
				f_ax.YAxis.TickValues   = tick_y_Positions;
				f_ax.YAxis.TickLabels   = tick_y_Labels;
			end
			set_default_plot_properties(f_ax);
			f_ax.XMinorGrid = 'on';
			f_ax.XAxis.MinorTick = 'on';
			f_ax.XGrid = 'off';
		end
	end
	if (Option_Show_Legend_Plot > 0) && (Option_Show_Legend_Plot == i_g)
		
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
		hold(f_ax,'on');
		for i_gg = 1 : size(Settings_GridVariants,1)
			if ~any(strcmpi(Labels_Scenarios, Settings_GridVariants{i_gg,5}))
				Labels_Scenarios{end+1} = Settings_GridVariants{i_gg,5}; %#ok<SAGROW>
				f_b = bar(f_ax, nan, nan);	                        % make an invisible line for legend
				f_b.EdgeColor = Settings_GridVariants{i_gg,3};
				f_b.FaceColor = Settings_GridVariants{i_gg,3};
				f_b.FaceAlpha = 0.5;
				f_b.LineStyle = '-'; % set linestyle of invisible line
				f_b.LineWidth = Option_Default_Line_Width;
				Labels_Scen_Style(end+1) = f_b; %#ok<SAGROW>
			end
		end
		
		legend(f_ax, Labels_Scenarios, 'Location','northeast');
		set_default_plot_properties(f_ax);
		f_ax.XMinorGrid = 'on';
		f_ax.XAxis.MinorTick = 'on';
		f_ax.XGrid = 'off';
		hold(f_ax,'off');
	end
	if i_g >= size(Settings_GridVariants,1)
		warning('on','MATLAB:handle_graphics:Layout:NoPositionSetInTiledChartLayout');
	end
end

clear Active_* Data* f_* i_* Labels_* idx_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =