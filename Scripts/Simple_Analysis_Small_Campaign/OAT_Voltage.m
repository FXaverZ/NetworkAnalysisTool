clear();
Saved_Data_OAT           = [];
Saved_Recalculation_Data = []; % Hint: Save this structure for later use...
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
for i_d = 1: numel(folders)
	disp(['    Reading File ',num2str(i_d),' of ',num2str(numel(folders))]);
	NVIEW_Data_Names = {'NVIEW_Results', 'NVIEW_Analysis_Selection', 'NVIEW_Control', 'NVIEW_Processed'};
	if ~isfield(Saved_Data_OAT,['Saved_',num2str(i_d)])
		Saved_Data_OAT.(['Saved_',num2str(i_d)]) = load([Path_Data_OAT,...
			folders{i_d},' - 000 - OAT-Data.mat'],NVIEW_Data_Names{:});
	end
end
disp('... done!');
Saved_Data_OAT.Number_Datasets = numel(folders);
clear script* sep folders i_* NVIEW_*

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
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Label and title strings:
Labels_Title_full_Comparison =  'Mittlerer Verlauf Spannung'; % Title, if > 1 scenario and > 1 grid variant...
Labels_Title_one_Variant     = ['Mittlerer Verlauf Spannung für Netzvariante "',Settings_GridVariants{Option_Active_GridVariants,2},'"'];
Labels_Title_one_Scenario    = ['Mittlerer Verlauf Spannung für Szenario "',Settings_Scenario{Option_Active_Scenarios,2},'"'];
Option_show_Title  = 1; % 1 ... show Title, 0 ... no Title for export to Word...
Labels_X_Direction = 'Tageszeit [h]';
Labels_Y_Direction = 'Spannung [p.u.]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
for i_d = 1 : Saved_Data_OAT.Number_Datasets
	if i_d <= 1
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
	Data = Saved_Data_OAT.(['Saved_',num2str(i_d)]).NVIEW_Processed;
	
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
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Number_Datasets_to_Use = 15;
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Option_Umin =  90; Option_Umax = 110; % '%' NAT Default (no recalculations!)
Option_Umin =  95; Option_Umax = 105; % '%'
% Option_Umin =  92; Option_Umax = 108; % '%'
% Option_Umin =  93; Option_Umax = 107; % '%'
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Active_Scenarios = 2:2:10;
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Active_GridVariants = 3:4;%1:4;     % all grid varaiants
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Histogramm_x_max_Value  = 100;  % (-1 ... autoscale)
Option_Number_Bins             = 50;
Option_Histogramm_x_min_Value  =  0; 
Option_Histogramm_x_step_Value =  2;
Option_Histogramm_x_Mark_every =  2;  % label every X bins in plot 
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = -1; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  4; % '%'
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_show_Title            = 1; % 1 ... show Title, 0 ... no Title for export to Word...
Labels_Title_full_Comparison =  'Histogramm '; % Title, if > 1 scenario and > 1 grid variant...
Labels_Title_one_Variant     = ['Histogramm für Netzvariante "',Settings_GridVariants{Option_Active_GridVariants,5},'"'];
Labels_Title_one_Scenario    = ['Histogramm für Szenario "',Settings_Scenario{Option_Active_Scenarios,5},'"'];
Labels_Title                 = 'Spannungsbandverletzungen';
Labels_X_Direction           = 'Spannungsbandverletzung in % der Profilzeit';
Labels_Y_Direction           = 'Relative Häufigkeit [%]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
for i_d = 1 : Option_Number_Datasets_to_Use
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	if i_d <= 1
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
		Data_ID = Saved_Data_OAT.(['Saved_',num2str(i_d)]).NVIEW_Processed.Control.ID;
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(i_d)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
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
			Data_bus_voltages_raw = Saved_Data_OAT.(['Saved_',num2str(i_d)]).NVIEW_Results.(Active_GridVars{i_g,2}).bus_voltages;
			Data_bus_voltages_raw = Data_bus_voltages_raw(Data_Recalculate_Scenarios,:,:,:,:);
			Data_bus_info     = Saved_Data_OAT.(['Saved_',num2str(i_d)]).NVIEW_Results.(Active_GridVars{i_g,2}).bus;
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
					['Sc_',num2str(Settings_Scenario{Data_Recalculate_Scenarios(i_s),1})]) = Data_res;
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
		Data = Saved_Data_OAT.(['Saved_',num2str(i_d)]).NVIEW_Processed;
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
		Labels_Scenarios  = {};
		Labels_Scen_Style = [];
		
		if Option_Histogramm_x_max_Value < 0
			Option_Histogramm_x_max_Value = max(Data_Violation_Numbers,[],'all');
			Option_Histogramm_x_min_Value = min(Data_Violation_Numbers,[],'all');
			Option_Number_Bins            = Option_Histogramm_x_max_Value - Option_Histogramm_x_min_Value;
		end
		Hist_binEdges = linspace(Option_Histogramm_x_min_Value,Option_Histogramm_x_max_Value,Option_Number_Bins+1);
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
		if Option_Histogramm_x_max_Value > 0
			[tick_x_Positions, tick_x_Labels] = set_tick_x_histogramms(...
				Option_Histogramm_x_min_Value,...
				Option_Histogramm_x_max_Value,...
				Option_Histogramm_x_step_Value,...
				Option_Histogramm_x_Mark_every,...
				f_ax);
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