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
Path_Data_OAT = ['C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\',...
	'Results_mean\01_Merged_OAT-Data\'];
% Path_Data_OAT = ['D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\'...
% 	'Results_mean\01_Merged_OAT-Data\'];

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
Settings_Scenario = {
% 1      2                                                3                 4          5                      6 
% ID  ,  Filename                                       , Color           , LineStyle, Legendstr w.o. Season, Season 
	 1, '01_SB_Base_Winter_Workda'                      ,[ 74,126,187]/256, '-'      , 'SB'                 , 'Winter';...
	 2, '02_SB_Base_Summer_Workda'                      ,[ 74,126,187]/256, '-'      , 'SB'                 , 'Sommer';...
	 3, '03_S1_LowLoadHighInfeed_Winter_Workda'         ,[190, 75, 72]/256, '-'      , 'S1'                 , 'Winter';...
	 4, '04_S1_LowLoadHighInfeed_Summer_Workda'         ,[190, 75, 72]/256, '-'      , 'S1'                 , 'Sommer';...
	 5, '05_S2_HighLoadHighInfeed_Winter_Workda'        ,[152,185, 84]/256, '-'      , 'S2'                 , 'Winter';...
	 6, '06_S2_HighLoadHighInfeed_Summer_Workda'        ,[152,185, 84]/256, '-'      , 'S2'                 , 'Sommer';...
	 7, '07_S3_HighLoadHighInfeed2Nodes_Winter_Workda'  ,[128,100,162]/256, '-'      , 'S3'                 , 'Winter';...
	 8, '08_S3_HighLoadHighInfeed2Nodes_Summer_Workda'  ,[128,100,162]/256, '-'      , 'S3'                 , 'Sommer';...
	 9, '09_S4_MediumLoadHighInfeed2Nodes_Winter_Workda',[247,150, 73]/256, '-'      , 'S4'                 , 'Winter';...
	10, '10_S4_MediumLoadHighInfeed2Nodes_Summer_Workda',[247,150, 73]/256, '-'      , 'S4'                 , 'Sommer';...
	};

Settings_GridVariants = {...
	% 1     2                                                 3                 4          5
	% ID ,  Sub-Structure Name                              , Color           , LineStyle, String for legend
	1, 'g01_Base_NS_50_Nodes'                           ,[ 72, 72, 72]/256, '--'     , 'GB Basisnetz';...
	2, 'g02_Repalce_OH_Lines_With_Cables'               ,[153,102, 51]/256, '-.'     , 'G1 Ersatz Oberleit.';...
	3, 'g03_Add_Cable_to_First_OH_Line'                 ,[128,100,162]/256, ':'      , 'G2 Verstärk. Oberleit.';...
	4, 'g04_Add_Cable_to_Weak_Cables'                   ,[  0,153,153]/256, '-'      , 'G3 Verstärk. Kabel';...
	};

Settings_VoltageBands = {
% 1     2     3      4                 5          6      7                , 8 
% ID ,  Umin, Umax,  Color           , LineStyle, Alpha, String for legend, Color after alpha 
	1,    90,  110, [255,  0,  0]/256, '-'      ,  0.25, '±10%'           , [255,191,192]/256;...
	2,    95,  105, [255,192,  0]/256, '-'      ,  0.25, '±5%'            , [255,239,191]/256;...
	3,    98,  107, [  0,  0,  0]/256, '-'      ,  0.35, '+7%…-2%'       , [210,210,210]/256;...
	4,    97,  103, [  0,176, 80]/256, '-'      ,  0.25, '±3%'            , [191,235,211]/256;...
	5,    90, 1000, [255,  0,  0]/256, '-'      ,  0.25, '-10%'           , [255,191,192]/256;...
	6,     0,  110, [255,  0,  0]/256, '-'      ,  0.25, '+10%'           , [255,191,192]/256;...
	7,    95, 1000, [255,192,  0]/256, '-'      ,  0.25, '-5%'            , [255,239,191]/256;...
	8,     0,  105, [255,192,  0]/256, '-'      ,  0.25, '+5%'            , [255,239,191]/256;...
	9,    98, 1000, [  0,  0,  0]/256, '-'      ,  0.35, '-2%'            , [210,210,210]/256;...
   10,     0,  107, [  0,  0,  0]/256, '-'      ,  0.35, '+7%'            , [210,210,210]/256;...
   11,    97, 1000, [  0,176, 80]/256, '-'      ,  0.25, '-3%'            , [191,235,211]/256;...
   12,     0,  103, [  0,176, 80]/256, '-'      ,  0.25, '+3%'            , [191,235,211]/256;...
	};

Settings_Number_Profiles = 10;
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Voltage Band Violation Histogramm Summary per Scenario
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand = 4; % 1: +-10% Default (no recalculations!), 2: +-5%, 3: -2...+7%, 4: +-3%
Option_Active_Scenarios = 1:1:10;
Option_Active_GridVariants = 1:4;     % all grid varaiants
%- - - - - - - - - - - - - - - - - -
Option_Bar_x_max_Value  = 100;  % (-1 ... autoscale)
Option_Number_Bins      = 100;
Option_Bar_x_min_Value  =   0;
Option_Bar_x_Label_Step =  10; % Spacing between label entries
Option_Bar_x_Last_GT    =   0; % 1 = show last label with leading ">" sign
% = = = = = = = = = = = = = = = = =
Option_show_Title            = 1; % 1 ... show Title, 0 ... no Title for export to Word...
Labels_Title_full_Comparison =  'Histogramm '; % Title, if > 1 scenario and > 1 grid variant...
Labels_Title_one_Variant     = ['Histogramm für Netzvariante "',Settings_GridVariants{Option_Active_GridVariants,5},'"'];
Labels_Title_one_Scenario    = ['Histogramm für Szenario "',Settings_Scenario{Option_Active_Scenarios,5},'"'];
Labels_Title                 = 'Spannungsbandverletzungen';
Labels_X_Direction           = 'Spannungsbandverletzung in % der Profilzeit';
Labels_Y_Direction           = 'Relative Häufigkeit [%]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_v = 1: numel(Option_Active_VoltageBand)
	disp(['Displaying voltage band "',Settings_VoltageBands{Option_Active_VoltageBand(i_v),7},'"...'])
	for i_d = 1 : Saved_Data_OAT.Number_Datasets
		i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		if i_d <= 1
			Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
			Active_GridVariants  = Settings_GridVariants(Option_Active_GridVariants,:);
			
			Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand(i_v),2};
			Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand(i_v),3};
			
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
				Labels_Title = [];
			end
			
			fig_oat_histogram = set_up_singleplot();
			
			% [gridvariant datasets scenarios]:
			Data_Violation_Numbers      = zeros(...
				numel(Option_Active_GridVariants),...
				Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
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
			disp(['    Processing profile set ',num2str(i_d),' of ',num2str(Saved_Data_OAT.Number_Datasets)]);
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%     Recalculation Voltage Band Violation Analysis
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
			for i_g = 1:size(Active_GridVariants,1)
				% First look up, if data is allready present:
				if(isfield(Saved_Recalculation_Data.(['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]),['Saved_',num2str(i_d)]))
					% Data for this dataset is present
					Data_save = Saved_Recalculation_Data.(['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(['Saved_',num2str(i_d)]);
					if(isfield(Data_save,Active_GridVariants{i_g,2}))
						% Data for this grid variant is present
						Data_Recalculate_Scenarios = [];
						for i_s = 1 : numel(Option_Active_Scenarios)
							if(~isfield(Data_save.(Active_GridVariants{i_g,2}), ['Sc_',num2str(Active_Scenarios{i_s,1})]))
								Data_Recalculate_Scenarios(end+1) = Active_Scenarios{i_s,1};
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
				Data_bus_voltages_raw = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Results.(Active_GridVariants{i_g,2}).bus_voltages;
				Data_bus_voltages_raw = Data_bus_voltages_raw(Data_Recalculate_Scenarios,:,:,:,:);
				Data_bus_info     = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Results.(Active_GridVariants{i_g,2}).bus;
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
						Active_GridVariants{i_g,2}).(...
						['Sc_',num2str(Settings_Scenario{Data_Recalculate_Scenarios(i_s),1})]) = Data_res;
				end
				
				% Read out out the needed data...
				for i_s = 1 : numel(Option_Active_Scenarios)
					Data_Violation_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Active_GridVariants{i_g,2}).(...
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
			for i_g = 1:size(Active_GridVariants,1)
				Data_Violation_Numbers(i_g,idx_datasets,:) = ...
					Data.(Active_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios);
			end
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
		end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		if i_d >= Saved_Data_OAT.Number_Datasets
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
						'LineStyle',Active_GridVariants{i_g,4},...
						'LineWidth',1.0,...
						'EdgeAlpha',1.0,...
						'FaceColor',Active_Scenarios{i_s,3},...
						'FaceAlpha',0.5);
					hold on;
				end
				% get the legend entries for the scenarios:
				Labels_Scenarios{end+1} = [Active_Scenarios{i_s,5},' - ',Active_Scenarios{i_s,6}];
				f_l = plot(nan, nan);	                         % make an invisible line for legend
				set(f_l,...
					'Color', Active_Scenarios{i_s,3},...       % set color of invisible line
					'LineStyle', Active_Scenarios{i_s,4});         % set linestyle of invisible line
				Labels_Scen_Style(end+1) = f_l;
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
end

clear Active_* Data* f_* Hist_* i_* idx_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot violation Summary over all Scenarios
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = [1,2,4];%1:4; %
Option_Active_Scenarios    = 1:1:10;
Option_Active_GridVariants = 4; % only one can be active here!
Option_Used_Data           = 'Node'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 100; % (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; %
Option_Plot_x_step_Value =  10; %
Option_Plot_x_Label_Step =   2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - -
Option_Plot_Size =   'medium'; % 'compact', 'medium', 'large'
Option_Scen_Divider = 2;       % Divider every X scenarios
Option_Show_Legend  = 1;
Option_Show_X_Label = 1;
Option_Show_Max_Marker = 0; % 1 = a marker indicates the maximum value occuring in the datasets
% = = = = = = = = = = = = = = = = =
Labels_X_Time = 'Anteil Profilzeit mit Spannungsbandverletzung';
Labels_X_Node = 'Anteil Knoten mit Spannungsbandverletzung';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_v = 1:numel(Option_Active_VoltageBand)
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	%     Preprocessing...
	%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_v <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		% get the Timepointsnumber from the first saved Dataset
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		% [voltagebands datasets scenarios]:
		Data_Violation_Numbers      = zeros(...
			numel(Option_Active_VoltageBand),...
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
	if i_v >= numel(Option_Active_VoltageBand)
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
				Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{Option_Active_GridVariants,2}).bus_name);
				Data_Plot = Data_Plot * 100 / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles * Data_Number_total_Busses);
				Data_Plot_Max = squeeze(max(Data_Violation_Bus_Numbers,[],2));
				Data_Plot_Max = Data_Plot_Max * 100 / Data_Number_total_Busses;
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
		idx_fliped = flip(1 : numel(Option_Active_VoltageBand));
		for i_vb = 1 : numel(Option_Active_VoltageBand)
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
		if ~Option_Show_X_Label
			Labels_X_Direction = [];
		else
			switch Option_Used_Data
				case 'Time'
					Labels_X_Direction = Labels_X_Time;
				case 'Node'
					Labels_X_Direction = Labels_X_Node;
			end
		end
		if Option_Plot_x_max_Value > 0
			f_ax.XAxis.Limits = [Option_Plot_x_min_Value, Option_Plot_x_max_Value];
			[tick_x_Positions, tick_x_Labels] = get_tick(...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step,...
				'%');
			f_ax.XAxis.TickValues   = tick_x_Positions;
			f_ax.XAxis.TickLabels   = tick_x_Labels;
		end
		% Legend
		if Option_Show_Legend
			legend(f_ax, Active_Voltagebands(:,7));
		end
		
		set_default_plot_properties(f_ax);
		set_single_plot_properties(f_ax, ...
			[],...
			Labels_X_Direction,...
			[],...
			0,...
			[]);
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
%% Plot violation difference summary over all scenarios
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 1:4; %[1,2,4];%1:4; %
Option_Active_Scenarios    = 1:1:10;
Option_Active_GridVariants = 1; % only one can be active here!
Option_Compare_GridVariant = 4; % only one can be active here!
Option_Used_Data           = 'Time'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  =  3; % (-1 ... autoscale)
Option_Plot_x_min_Value  =  0; %
Option_Plot_x_step_Value =0.5; %
Option_Plot_x_Label_Step =  2; % Spacing between label entries
Option_Sign_x_Labels     = -1; % sign of the label numbers
%- - - - - - - - - - - - - - - - - -
Option_Plot_Size =   'compact'; % 'compact', 'medium', 'large'
Settings_Max_Fig_Area = [0.0759    0.1316    0.0585    0.0102];
Option_Scen_Divider = 2;       % Divider every X scenarios
Option_Show_Legend  = 1;
Option_Show_X_Label = 0;
Option_Show_Y_Ticks = 1;
% = = = = = = = = = = = = = = = = =
Labels_X_Time = 'Differenz Anteil Profilzeit mit Spannungsbandverletzung';
Labels_X_Node = 'Differenz Anteil Knoten mit Spannungsbandverletzung';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_v = 1:numel(Option_Active_VoltageBand)
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_v <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		% get the Timepointsnumber from the first saved Dataset
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		% [voltagebands datasets scenarios]:
		Data_Violation_Numbers      = zeros(...
			numel(Option_Active_VoltageBand),...
			Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Violation_Bus_Numbers         = Data_Violation_Numbers;
		Data_Violation_Compare_Numbers     = Data_Violation_Numbers;
		Data_Violation_Compare_Bus_Numbers = Data_Violation_Numbers;
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
			Data_Violation_Compare_Numbers(i_v,idx_datasets,:) = ...
				Data.(Settings_GridVariants{Option_Compare_GridVariant,2}).bus_violations_at_datasets(:,Option_Active_Scenarios);
			Data_Violation_Bus_Compare_Numbers(i_v,idx_datasets,:) = ...
				Data.(Settings_GridVariants{Option_Compare_GridVariant,2}).bus_violated_at_datasets(:,Option_Active_Scenarios);
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
					Data_Violation_Compare_Numbers(i_v,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{Option_Compare_GridVariant,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets;
					Data_Violation_Bus_Compare_Numbers(i_v,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{Option_Compare_GridVariant,2}).(...
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
	if i_v >= numel(Option_Active_VoltageBand)
		% rearrange data for plot
		
		switch Option_Used_Data
			case 'Time'
				Data = squeeze(sum(Data_Violation_Numbers,2));
				Data = Data * 100 / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles * Data_Timepoints);
				Data_Compare = squeeze(sum(Data_Violation_Compare_Numbers,2));
				Data_Compare = Data_Compare * 100 / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles * Data_Timepoints);
			case 'Node'
				Data = squeeze(sum(Data_Violation_Bus_Numbers,2));
				Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{Option_Active_GridVariants,2}).bus_name);
				Data = Data * 100 / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles * Data_Number_total_Busses);
				Data_Compare = squeeze(sum(Data_Violation_Bus_Compare_Numbers,2));
				Data_Compare = Data_Compare * 100 / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles * Data_Number_total_Busses);
		end
		Data_Plot = Data - Data_Compare;
		% Reverse order
		Data_Plot     = flip(Data_Plot',2);
		
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
		idx_fliped = flip(1 : numel(Option_Active_VoltageBand));
		for i_vb = 1 : numel(Option_Active_VoltageBand)
			f_bb = f_b(i_vb);
			f_bb.LineStyle = 'none';
			f_bb.FaceColor = Active_Voltagebands{idx_fliped(i_vb),4};
			f_bb.FaceAlpha = Active_Voltagebands{idx_fliped(i_vb),6};
			f_bb.BarWidth = 1;
		end
		
		figure(fig_oat_summary_violation);
		% X Axis
		if ~Option_Show_X_Label
			Labels_X_Direction = [];
		else
			switch Option_Used_Data
				case 'Time'
					Labels_X_Direction = Labels_X_Time;
				case 'Node'
					Labels_X_Direction = Labels_X_Node;
			end
		end
		if Option_Plot_x_max_Value > 0
			f_ax.XAxis.Limits = [Option_Plot_x_min_Value, Option_Plot_x_max_Value];
			[tick_x_Positions, tick_x_Labels] = get_tick(...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step,...
				'%',...
				[],...
				Option_Sign_x_Labels);
			f_ax.XAxis.TickValues   = tick_x_Positions;
			f_ax.XAxis.TickLabels   = tick_x_Labels;
		end
		if ~Option_Show_Y_Ticks
			f_max_area         = Settings_Max_Fig_Area;
		else
			f_max_area = [];
		end
		% Legend
		if Option_Show_Legend
			legend(f_ax, Active_Voltagebands(:,7));
		end
		
		set_default_plot_properties(f_ax);
		f_max_area = set_single_plot_properties(f_ax, ...
			[],...
			Labels_X_Direction,...
			[],...
			0,...
			f_max_area);
			Settings_Max_Fig_Area = f_max_area;
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
		if Option_Show_Y_Ticks
			YTickLabel = cell(1,numel(Option_Active_Scenarios));
			for i_s = 1 : numel(Option_Active_Scenarios)
				YTickLabel{i_s} = num2str(Active_Scenarios{i_s,1},'%02.0f');
			end
			f_under_ax.YTickLabel = YTickLabel;
			f_under_ax.FontName   = 'Palatino Linotype';
			f_under_ax.FontSize   = 16; %Fontsize_normal  = 16; in "set_default_plot_properties"
		else
			f_under_ax.YTickLabel = [];
		end
		if Option_Show_Legend
			legend(f_ax, flip(Active_Voltagebands(:,7)));
		end
	end
end

clear Active_* Data* f_* i_* idx_* Option_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Show development profilnumber with boxplots
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 4; % only one can be active here!
Option_Active_Scenarios    = 2; % only one can be active here!
Option_Used_Data           = 'Node'; % 'Time'; 'Node'
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
Option_Legend_Pos = 'northeast'; 
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
			Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
			Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
			Active_GridVariants = Settings_GridVariants(i_g,:);
			% get the Timepointsnumber from the first saved Dataset
			Data_Timepoints = ...
				Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
			% [datapoints scenarios]:
			Data_Violation_Numbers      = NaN(...
				Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
				numel(Option_Active_Scenarios));
			Data_Violation_Bus_Numbers = Data_Violation_Numbers;
			Data_Violation_Development = NaN(...
				Saved_Data_OAT.Number_Datasets,...
				Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
				numel(Option_Active_Scenarios));
		end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand,3};
		
		idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
		% Read out out the needed data...
		if Settings_VoltageBands{Option_Active_VoltageBand,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios);
			Data_Violation_Bus_Numbers(idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violated_at_datasets(:,Option_Active_Scenarios);
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets;
					Data_Violation_Bus_Numbers(idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violated_at_datasets;
				catch
					% if this error occurs, the previous cell has to to be run
					% or the correct data has to be loaded into the
					% "Saved_Recalculation_Data" structure!
					error('Error loading data, get sure, the structure "Saved_Recalculation_Data" has all needed data!')
				end
			end
		end
		switch Option_Used_Data
			case 'Time'
				Data_Violation_Development(i_d,:,:) = Data_Violation_Numbers * 100 / Data_Timepoints;
			case 'Node'
				Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
				Data_Violation_Development(i_d,:,:) = Data_Violation_Bus_Numbers * 100 / Data_Number_total_Busses;
		end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		if i_d >= Saved_Data_OAT.Number_Datasets
			
			figure(fig_oat_development_boxplot);
			boxplot(Data_Violation_Development',...
				'Widths',0.5,...
				'OutlierSize',3);
			
			f_ax = gca;
			f_bx = findobj(f_ax,'Tag','boxplot');
			set(findobj(f_bx,'Tag','Box'),'LineWidth',Option_Default_Line_Width, 'Color', Active_GridVariants{1,3});
			set(findobj(f_bx,'Tag','Upper Whisker'),'LineStyle','-', 'Color', Active_GridVariants{1,3});
			set(findobj(f_bx,'Tag','Lower Whisker'),'LineStyle','-', 'Color', Active_GridVariants{1,3});
			set(findobj(f_bx,'Tag','Median'),'LineWidth',2, 'Color', Active_GridVariants{1,3});
			set(findobj(f_bx,'Tag','Lower Adjacent Value'), 'Color', Active_GridVariants{1,3});
			set(findobj(f_bx,'Tag','Upper Adjacent Value'), 'Color', Active_GridVariants{1,3});
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
					Option_Plot_x_Label_Step,[],[],10);
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
				Labels_Scenarios{end+1} = Settings_GridVariants{i_gg,5}; 
				f_b = bar(f_ax, nan, nan);	                        % make an invisible line for legend
				f_b.EdgeColor = Settings_GridVariants{i_gg,3};
				f_b.FaceColor = Settings_GridVariants{i_gg,3};
				f_b.FaceAlpha = 0.5;
				f_b.LineStyle = '-'; % set linestyle of invisible line
				f_b.LineWidth = Option_Default_Line_Width;
				Labels_Scen_Style(end+1) = f_b; 
			end
		end
		
		legend(f_ax, Labels_Scenarios, 'Location',Option_Legend_Pos);
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
%% Show min-max of voltage scenario comparison
% = = = = = = = = = = = = = = = = =
Option_Active_Scenarios    = [1,4];%1:10;%10;
Option_Active_VoltageBand  = [1,2,4]; 
Option_Active_GridVariants = 1; % only one can be active here!
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles
Option_Show_Legend        = 1;
Option_Show_Legend_Details= 0;
Option_Show_Title         = 0;
Option_Show_Y_Label       = 0;
Option_Show_Mean_Values   = 1;
Settings_Max_Fig_Area     = [0.1184    0.1236    0.0364    0.0294];
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'medium'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 144; % x10 minutes (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; % x10 minutes
Option_Plot_x_step_Value =  60; % minutes
Option_Plot_x_Label_Step =   2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Plot_y_max_Value  =  1.15; % '%' (-1 ... autoscale)
Option_Plot_y_min_Value  = 0.70; % '%'
Option_Plot_y_step_Value = 0.05; % '%'
Option_Plot_y_Label_Step =    2; % Spacing between label entries
Option_Plot_y_Num_Format = '%1.1f';
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_Y_Direction = 'Spannung [p.u.]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1:Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Data_Timepoints = ...
				Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		Data_Voltage_max  = zeros(Data_Timepoints,numel(Option_Active_Scenarios));
		Data_Voltage_min  = ones(Data_Timepoints,numel(Option_Active_Scenarios))*100; % a big value, which will be overwritten by the min funstion later on
		Data_Voltage_mean = [];
		
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
	Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed.(Settings_GridVariants{Option_Active_GridVariants,2});
	%[scenario, profileset, timepoint, node, phase]
	Data_Voltages = Data.bus_voltages(Option_Active_Scenarios,:,:,:,:);
	% over all phases
	Data_Voltages_tmp_max = max(Data_Voltages,[],5);
	Data_Voltages_tmp_min = min(Data_Voltages,[],5);
	Data_Voltages_tmp_mean= mean(Data_Voltages,5);
	% over all nodes
	Data_Voltages_tmp_max = max(Data_Voltages_tmp_max,[],4);
	Data_Voltages_tmp_min = min(Data_Voltages_tmp_min,[],4);
	Data_Voltages_tmp_mean= mean(Data_Voltages_tmp_mean,4);
	% over all profilesets
	Data_Voltages_tmp_max = squeeze(max(Data_Voltages_tmp_max,[],2))';
	Data_Voltages_tmp_min = squeeze(min(Data_Voltages_tmp_min,[],2))';
	Data_Voltages_tmp_mean= squeeze(mean(Data_Voltages_tmp_mean,2))';
	% save the values:
	Data_Voltage_max = max(Data_Voltage_max, Data_Voltages_tmp_max);
	Data_Voltage_min = min(Data_Voltage_min, Data_Voltages_tmp_min);
	if isempty(Data_Voltage_mean)
		Data_Voltage_mean = Data_Voltages_tmp_mean;
	else
		Data_Voltage_mean = 0.5 * (Data_Voltage_mean + Data_Voltages_tmp_mean);
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	if i_d >= Saved_Data_OAT.Number_Datasets
		fig_oat_voltage_minmax = set_up_singleplot(Option_Plot_Size);
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
		
		% plot the voltage timelines
		for i_s = 1 : size(Active_Scenarios,1)
			% Plot the mean value:
			if Option_Show_Mean_Values
				f_l = plot(Data_Voltage_mean(:,i_s)); %#ok<*UNRCH>
				f_l.Color = Active_Scenarios{i_s,3};
				f_l.LineStyle = '-';
				f_l.LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Seasons
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_l.LineStyle = ':';
						case 'Winter'
							f_l.LineStyle = '-';
					end
				end
			end
			
			% Plot the max value, first a black line as background:
			f_pu = patchline(1:Data_Timepoints,Data_Voltage_max(:,i_s));
			f_pu.LineWidth = Option_Default_Line_Width;
			f_pu.EdgeColor = 'k';
			% now a patchline with alpha in the foreground (color, but
			% darker):
			f_p = patchline(1:Data_Timepoints,Data_Voltage_max(:,i_s));
			f_p.EdgeColor = Active_Scenarios{i_s,3};
			f_p.EdgeAlpha = 0.8;
			f_p.LineStyle = '-';
			f_p.LineWidth = Option_Default_Line_Width;
			if Option_Distinct_Seasons
				switch Active_Scenarios{i_s, 6}
					case 'Sommer'
						f_p.LineStyle = ':';
						f_pu.LineStyle = ':';
					case 'Winter'
						f_p.LineStyle = '-';
						f_pu.LineStyle = '-';
				end
			end
			drawnow;
			hold on;
			
			% Plot the min value, first a white line as background:
			f_pu = patchline(1:Data_Timepoints,Data_Voltage_min(:,i_s));
			f_pu.LineWidth = Option_Default_Line_Width;
			f_pu.EdgeColor = 'w';
			% now a patchline with alpha in the foreground (color, now
			% brighter): 
			f_p = patchline(1:Data_Timepoints,Data_Voltage_min(:,i_s));
			f_p.EdgeColor = Active_Scenarios{i_s,3};
			f_p.EdgeAlpha = 0.8;
			f_p.LineStyle = '-';
			f_p.LineWidth = Option_Default_Line_Width;
			if Option_Distinct_Seasons
				switch Active_Scenarios{i_s, 6}
					case 'Sommer'
						f_p.LineStyle = ':';
						f_pu.LineStyle = ':';
					case 'Winter'
						f_p.LineStyle = '-';
						f_pu.LineStyle = '-';
				end
			end
			drawnow;
			
			% get the data for the legend:
			if ~any(strcmpi(Labels_Scenarios, Active_Scenarios{i_s,5}))
				Labels_Scenarios{end+1} = Active_Scenarios{i_s,5}; 
				f_l = plot(nan, nan);	                 % make an invisible line for legend
				f_l.Color = Active_Scenarios{i_s,3};     % set color of invisible line
				f_l.LineStyle = Active_Scenarios{i_s,4}; % set linestyle of invisible line
				f_l.LineWidth = Option_Default_Line_Width;
				Labels_Scen_Style(end+1) = f_l; 
			end
		end
		
		% plot the voltage bands:
		for i_v = 1:numel(Option_Active_VoltageBand)
			Data_Umin =  ones(Data_Timepoints,1)*Active_Voltagebands{i_v,2}/100;
			Data_Umax =  ones(Data_Timepoints,1)*Active_Voltagebands{i_v,3}/100;
			f_pu = patchline(1:Data_Timepoints,Data_Umin);
			f_po = patchline(1:Data_Timepoints,Data_Umax);
			f_pu.EdgeColor = Active_Voltagebands{i_v,4};
			f_po.EdgeColor = Active_Voltagebands{i_v,4};
			f_pu.EdgeAlpha = Active_Voltagebands{i_v,6};
			f_po.EdgeAlpha = Active_Voltagebands{i_v,6};
			f_pu.LineWidth = Option_Default_Line_Width;
			f_po.LineWidth = Option_Default_Line_Width;
		end
		
		% format the plot:
		f_ax = gca;
		
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area         = Settings_Max_Fig_Area;
		else
			f_max_area = [];
		end
		
		% X Axis
		if Option_Plot_x_max_Value > 0
			set_tick_x_dayprofile(f_ax,...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step);
		end
		% Y Axis
		if Option_Plot_y_max_Value > 0
			f_ax.YAxis.Limits  = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Plot_y_min_Value,...
				Option_Plot_y_step_Value,...
				Option_Plot_y_max_Value,...
				Option_Plot_y_Label_Step,...
				'',... % no unit
				Option_Plot_y_Num_Format);
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Distinct_Seasons && Option_Show_Legend_Details
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_oat_voltage_minmax,...
					Option_Default_Line_Width, Labels_Scenarios, Labels_Scen_Style, 'line');
			end
			legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
		end
		% Configuration
		set_default_plot_properties(f_ax);
		f_max_area = set_single_plot_properties(f_ax, ...
			Labels_Title,...
			[],...
			Labels_Y_Direction,...
			Option_Show_Title,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		% adjust legend properties a little bit for this kind of graph
		if Option_Show_Legend
			f_lg = get(f_ax, 'Legend');
			f_lg.ItemTokenSize = [17, 6];
		end
		hold off
	end
end

clear Active_* Data* f_* i_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Show min-max of voltage grid variant comparison
% = = = = = = = = = = = = = = = = =
Option_Active_Scenarios    = [3,4]; % only one scenario (differnent seasons) can be active here!
Option_Active_VoltageBand  = [1,2,4];  
Option_Active_GridVariants = [1,3,4]; 
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles
Option_Show_Legend        = 1;
Option_Show_Legend_Details= 1;
Option_Show_Title         = 0;
Option_Show_Y_Label       = 0;
Option_Show_Mean_Values   = 1;
Settings_Max_Fig_Area     = [0.1184    0.1236    0.0364    0.0294];
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'medium'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 144; % x10 minutes (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; % x10 minutes
Option_Plot_x_step_Value =  60; % minutes
Option_Plot_x_Label_Step =   2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Plot_y_max_Value  =  1.15; % '%' (-1 ... autoscale)
Option_Plot_y_min_Value  = 0.70; % '%'
Option_Plot_y_step_Value = 0.05; % '%'
Option_Plot_y_Label_Step =    2; % Spacing between label entries
Option_Plot_y_Num_Format = '%1.1f';
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_Y_Direction = 'Spannung [p.u.]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1:Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
				Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		Data_Voltage_max  = zeros(numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios));
		Data_Voltage_min  = ones(numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios))*100; % a big value, which will be overwritten by the min funstion later on
		Data_Voltage_mean = Data_Voltage_max;
		
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
	for i_g = 1 : numel(Option_Active_GridVariants)
		Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed.(Active_GridVariants{i_g,2});
		%[scenario, profileset, timepoint, node, phase]
		Data_Voltages = Data.bus_voltages(Option_Active_Scenarios,:,:,:,:);
		% over all phases
		Data_Voltages_tmp_max = max(Data_Voltages,[],5);
		Data_Voltages_tmp_min = min(Data_Voltages,[],5);
		Data_Voltages_tmp_mean= mean(Data_Voltages,5);
		% over all nodes
		Data_Voltages_tmp_max = max(Data_Voltages_tmp_max,[],4);
		Data_Voltages_tmp_min = min(Data_Voltages_tmp_min,[],4);
		Data_Voltages_tmp_mean= mean(Data_Voltages_tmp_mean,4);
		% over all profilesets
		Data_Voltages_tmp_max = squeeze(max(Data_Voltages_tmp_max,[],2))';
		Data_Voltages_tmp_min = squeeze(min(Data_Voltages_tmp_min,[],2))';
		Data_Voltages_tmp_mean= squeeze(mean(Data_Voltages_tmp_mean,2))';
		% save the values:
		Data_Voltage_max(i_g,:,:) = max(squeeze(Data_Voltage_max(i_g,:,:)), Data_Voltages_tmp_max);
		Data_Voltage_min(i_g,:,:) = min(squeeze(Data_Voltage_min(i_g,:,:)), Data_Voltages_tmp_min);
		if i_d <= 1
			Data_Voltage_mean(i_g,:,:) = Data_Voltages_tmp_mean;
		else
			Data_Voltage_mean(i_g,:,:) = 0.5 * (squeeze(Data_Voltage_mean(i_g,:,:)) + Data_Voltages_tmp_mean);
		end
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	if i_d >= Saved_Data_OAT.Number_Datasets
		fig_oat_voltage_minmax = set_up_singleplot(Option_Plot_Size);
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
		
		% plot the voltage timelines
		for i_g = 1 : numel(Option_Active_GridVariants)
			for i_s = 1 : size(Active_Scenarios,1)
				% Plot the mean value:
				if Option_Show_Mean_Values
					f_l = plot(Data_Voltage_mean(i_g,:,i_s)); %#ok<*UNRCH>
					f_l.Color = Active_GridVariants{i_g,3};
					f_l.LineStyle = '-';
					f_l.LineWidth = Option_Default_Line_Width;
					if Option_Distinct_Seasons
						switch Active_Scenarios{i_s, 6}
							case 'Sommer'
								f_l.LineStyle = ':';
							case 'Winter'
								f_l.LineStyle = '-';
						end
					end
				end
				
				% Plot the max value, first a black line as background:
				f_pu = patchline(1:Data_Timepoints,Data_Voltage_max(i_g,:,i_s));
				f_pu.LineWidth = Option_Default_Line_Width;
				f_pu.EdgeColor = 'k';
				% now a patchline with alpha in the foreground (color, but
				% darker):
				f_p = patchline(1:Data_Timepoints,Data_Voltage_max(i_g,:,i_s));
				f_p.EdgeColor = Active_GridVariants{i_g,3};
				f_p.EdgeAlpha = 0.60;
				f_p.LineStyle = '-';
				f_p.LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Seasons
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_p.LineStyle = ':';
							f_pu.LineStyle = ':';
						case 'Winter'
							f_p.LineStyle = '-';
							f_pu.LineStyle = '-';
					end
				end
				drawnow;
				hold on;
				
				% Plot the min value, first a white line as background:
				f_pu = patchline(1:Data_Timepoints,Data_Voltage_min(i_g,:,i_s));
				f_pu.LineWidth = Option_Default_Line_Width;
				f_pu.EdgeColor = 'w';
				% now a patchline with alpha in the foreground (color, now
				% brighter):
				f_p = patchline(1:Data_Timepoints,Data_Voltage_min(i_g,:,i_s));
				f_p.EdgeColor = Active_GridVariants{i_g,3};
				f_p.EdgeAlpha = 0.8;
				f_p.LineStyle = '-';
				f_p.LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Seasons
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_p.LineStyle = ':';
							f_pu.LineStyle = ':';
						case 'Winter'
							f_p.LineStyle = '-';
							f_pu.LineStyle = '-';
					end
				end
				drawnow;
				
				% get the data for the legend:
				if ~any(strcmpi(Labels_Scenarios, Active_GridVariants{i_g,5}))
					Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
					f_l = plot(nan, nan);	                 % make an invisible line for legend
					f_l.Color = Active_GridVariants{i_g,3};     % set color of invisible line
					f_l.LineStyle = '-'; % set linestyle of invisible line
					f_l.LineWidth = Option_Default_Line_Width;
					Labels_Scen_Style(end+1) = f_l;
				end
			end
		end
		
		% plot the voltage bands:
		for i_v = 1:numel(Option_Active_VoltageBand)
			Data_Umin =  ones(Data_Timepoints,1)*Active_Voltagebands{i_v,2}/100;
			Data_Umax =  ones(Data_Timepoints,1)*Active_Voltagebands{i_v,3}/100;
			f_pu = patchline(1:Data_Timepoints,Data_Umin);
			f_po = patchline(1:Data_Timepoints,Data_Umax);
			f_pu.EdgeColor = Active_Voltagebands{i_v,4};
			f_po.EdgeColor = Active_Voltagebands{i_v,4};
			f_pu.EdgeAlpha = Active_Voltagebands{i_v,6};
			f_po.EdgeAlpha = Active_Voltagebands{i_v,6};
			f_pu.LineWidth = Option_Default_Line_Width;
			f_po.LineWidth = Option_Default_Line_Width;
		end
		
		% format the plot:
		f_ax = gca;
		
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area         = Settings_Max_Fig_Area;
		else
			f_max_area = [];
		end
		
		% X Axis
		if Option_Plot_x_max_Value > 0
			set_tick_x_dayprofile(f_ax,...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step);
		end
		% Y Axis
		if Option_Plot_y_max_Value > 0
			f_ax.YAxis.Limits  = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Plot_y_min_Value,...
				Option_Plot_y_step_Value,...
				Option_Plot_y_max_Value,...
				Option_Plot_y_Label_Step,...
				'',... % no unit
				Option_Plot_y_Num_Format);
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Distinct_Seasons && Option_Show_Legend_Details
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_oat_voltage_minmax,...
					Option_Default_Line_Width, Labels_Scenarios, Labels_Scen_Style, 'line');
			end
			legend(Labels_Scen_Style, Labels_Scenarios, 'Location','southwest');
		end
		% Configuration
		set_default_plot_properties(f_ax);
		f_max_area = set_single_plot_properties(f_ax, ...
			Labels_Title,...
			[],...
			Labels_Y_Direction,...
			Option_Show_Title,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		% adjust legend properties a little bit for this kind of graph
		if Option_Show_Legend
			f_lg = get(f_ax, 'Legend');
			f_lg.ItemTokenSize = [17, 6];
		end
		hold off
	end
end

clear Active_* Data* f_* i_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Timeline with affected Nodes grid variant comparison
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 1; % only one can be active here!
Option_Active_Scenarios    = 7; % only one szenario (different seasons)!
Option_Active_GridVariants = [1,4];
%- - - - - - - - - - - - - - - - - -
Option_Show_Min_Max       = 1; % 1 = Plot also min and max of the profiles    --+
Option_Distinct_Seasons   = 0; % 1 = Plot the season with different linestyle --+-- Only one of them should be 1! 
Option_Show_Legend        = 1;
Option_Show_Legend_Details= 1;
Option_Show_Title         = 0;
Option_Show_Y_Label       = 1;
Settings_Max_Fig_Area     = [0.1367    0.1236    0.0364    0.0294];
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 144; % x10 minutes (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; % x10 minutes
Option_Plot_x_step_Value =  60; % minutes
Option_Plot_x_Label_Step =   1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Plot_y_max_Value  =  35; % '%' (-1 ... autoscale)
Option_Plot_y_min_Value  =   0; % '%'
Option_Plot_y_step_Value =   5; % '%'
Option_Plot_y_Label_Step =   2; % Spacing between label entries
Option_Plot_y_Num_Format =  [];
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_Y_Direction = 'Anteil Knoten mit Spannungsbandverletzung';
% = = = = = = = = = = = = = = = = =

for i_d = 1:Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		
		Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand,3};
		
		Data_Node_Violations_Mean = zeros(numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios));
		Data_Node_Violations_Min  = ones(numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios))*10000; % a big value, which will be overwritten by the min funstion later on
		Data_Node_Violations_Max  = zeros(numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios)); 
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
	for i_g = 1 : numel(Option_Active_GridVariants)
		Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Active_GridVariants{i_g,2}).bus_name);
		if Settings_VoltageBands{Option_Active_VoltageBand,1} == 1
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed.(Active_GridVariants{i_g,2});
			Data_Node_Violations = Data.voltage_violations(Option_Active_Scenarios,:,:,:);
		else
			Data_Node_Violations = [];
			for i_s = 1 : numel(Option_Active_Scenarios)
				Data = Saved_Recalculation_Data.(...
					['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
					['Saved_',num2str(i_d)]).(...
					Active_GridVariants{i_g,2}).(...
					['Sc_',num2str(Active_Scenarios{i_s,1})]);
				if i_s == 1
					Data_Node_Violations = Data.voltage_violations;
				else
					Data_Node_Violations(end+1,:,:,:) = Data.voltage_violations; %#ok<*SAGROW>
				end
			end
		end
		%[scenario, profileset, timepoint, node]; 1 = violation at node
		%occured,,,
		Data_Node_Violations_Sum = sum(Data_Node_Violations,4) * 100 / Data_Number_total_Busses;
		Data_Node_Violations_tmp_Mean = squeeze(mean(Data_Node_Violations_Sum,2))';
		Data_Node_Violations_tmp_Min  = squeeze(min(Data_Node_Violations_Sum,[],2))';
		Data_Node_Violations_tmp_Max  = squeeze(max(Data_Node_Violations_Sum,[],2))';
		Data_Node_Violations_Min(i_g,:,:) = min(squeeze(Data_Node_Violations_Min(i_g,:,:)),Data_Node_Violations_tmp_Min);
		Data_Node_Violations_Max(i_g,:,:) = max(squeeze(Data_Node_Violations_Max(i_g,:,:)),Data_Node_Violations_tmp_Max);
		if i_d <= 1
			Data_Node_Violations_Mean(i_g,:,:) = Data_Node_Violations_tmp_Mean;
		else
			Data_Node_Violations_Mean(i_g,:,:) = 0.5 * (squeeze(Data_Node_Violations_Mean(i_g,:,:)) + Data_Node_Violations_tmp_Mean);
		end
	end
	
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d >= Saved_Data_OAT.Number_Datasets
		fig_oat_node_timeline = set_up_singleplot(Option_Plot_Size);
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
		
		for i_g = 1: numel(Option_Active_GridVariants)
			f_l = plot(squeeze(Data_Node_Violations_Mean(i_g,:,:)));
			hold on;
			for i_s = 1 : numel(Option_Active_Scenarios)
				f_l(i_s).Color = Active_GridVariants{i_g,3};
				f_l(i_s).LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Seasons
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_l(i_s).LineStyle = ':';
						case 'Winter'
							f_l(i_s).LineStyle = '-';
					end
				end
			end
			
			if ~any(strcmpi(Labels_Scenarios, Active_GridVariants{i_g,5}))
				Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
				f_l = plot(nan, nan);	                % make an invisible line for legend
				f_l.Color = Active_GridVariants{i_g,3}; % set color of invisible line
				f_l.LineStyle = '-';                    % set linestyle of invisible line
				f_l.LineWidth = Option_Default_Line_Width;
				Labels_Scen_Style(end+1) = f_l;
			end
			
			if Option_Show_Min_Max
				for i_s = 1 : numel(Option_Active_Scenarios)
					Data_Plot_Max = squeeze(Data_Node_Violations_Max(i_g,:,i_s))';
					Data_Plot_Min = squeeze(Data_Node_Violations_Min(i_g,:,i_s))';
					if numel(Option_Active_Scenarios) <= 1
						% fill the area between min and max:
						f_inBetweenRegionX = [1:length(Data_Plot_Max), length(Data_Plot_Min):-1:1];
						f_inBetweenRegionY = [Data_Plot_Max', fliplr(Data_Plot_Min')];
						f_f = fill(f_inBetweenRegionX, f_inBetweenRegionY, 'g');
						f_f.FaceColor = Active_GridVariants{i_g,3};
						f_f.FaceAlpha = 0.25;
						f_f.LineStyle = 'none';
					end
					% Plot max
					f_l = plot(Data_Plot_Max);
					f_l.Color = Active_GridVariants{i_g,3};
					f_l.LineStyle = '-.';
					f_l.LineWidth = Option_Default_Line_Width;
					drawnow;
					%plot min
					f_l = plot(Data_Plot_Min);
					f_l.Color = Active_GridVariants{i_g,3};
					f_l.LineStyle = ':';
					f_l.LineWidth = Option_Default_Line_Width;
					drawnow;
				end
			end
		end
		% Format the plot:
		f_ax = gca;
		
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area         = Settings_Max_Fig_Area;
		else
			f_max_area = [];
		end
		
		% X Axis
		if Option_Plot_x_max_Value > 0
			set_tick_x_dayprofile(f_ax,...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step);
		end
		% Y Axis
		if Option_Plot_y_max_Value > 0
			f_ax.YAxis.Limits  = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Plot_y_min_Value,...
				Option_Plot_y_step_Value,...
				Option_Plot_y_max_Value,...
				Option_Plot_y_Label_Step,...
				'%',... % no unit
				Option_Plot_y_Num_Format);
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Show_Min_Max && Option_Show_Legend_Details
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_mean_min_max_entry_to_legend(fig_oat_node_timeline,...
					Labels_Scenarios, Labels_Scen_Style, []);
			end
			if Option_Distinct_Seasons && Option_Show_Legend_Details
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_oat_node_timeline,...
					Option_Default_Line_Width, Labels_Scenarios, Labels_Scen_Style, 'line');
			end
			legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
		end
		% Configuration
		set_default_plot_properties(f_ax,'axes_on_top');
		f_max_area = set_single_plot_properties(f_ax, ...
			Labels_Title,...
			[],...
			Labels_Y_Direction,...
			Option_Show_Title,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		% adjust legend properties a little bit for this kind of graph
		if Option_Show_Legend
			f_lg = get(f_ax, 'Legend');
			f_lg.ItemTokenSize = [17, 6];
		end
		hold off
	end
end

clear Active_* Data* f_* i_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Timeline with affected Nodes scenario variant comparison
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = [1,2,4]; %[6,8,12]-1;% if more than one, curves are marked with a background in voltage band color...
Option_Active_Scenarios    = 3:4; % 1:2; %
Option_Active_GridVariants = 1;%[4,1]; % max. two grid variants! First one '-', second ':' Linestyle
%- - - - - - - - - - - - - - - - - -
Option_Show_Min_Max       = 0; % 1 = Plot also min and max of the profiles                --+
Option_Distinct_Grids     = 0; % 1 = Plot the two grid variants with different linestyles --+-- Only one of them should be 1! 
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles            --+
Option_Show_Legend        = 1;
Option_Show_Legend_Details= 1;
Option_Show_Title         = 0;
Option_Show_Y_Label       = 0;
Settings_Max_Fig_Area     = [0.1400    0.1236    0.0364    0.0294];
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'medium'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 144; % x10 minutes (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; % x10 minutes
Option_Plot_x_step_Value =  60; % minutes
Option_Plot_x_Label_Step =   2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Plot_y_max_Value  =  30; % '%' (-1 ... autoscale)
Option_Plot_y_min_Value  =   0; % '%'
Option_Plot_y_step_Value =   5; % '%'
Option_Plot_y_Label_Step =   2; % Spacing between label entries
Option_Plot_y_Num_Format =  [];
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_Y_Direction = 'Anteil Knoten mit Spannungsbandverletzung';
% = = = = = = = = = = = = = = = = =

for i_d = 1:Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		
		% [i_v, i_g, time, i_s]
		Data_Node_Violations_Mean = zeros(numel(Option_Active_VoltageBand),numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios));
		Data_Node_Violations_Min  = ones(numel(Option_Active_VoltageBand),numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios))*10000; % a big value, which will be overwritten by the min funstion later on
		Data_Node_Violations_Max  = zeros(numel(Option_Active_VoltageBand),numel(Option_Active_GridVariants),Data_Timepoints,numel(Option_Active_Scenarios)); 
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
	for i_g = 1 : numel(Option_Active_GridVariants)
		for i_v = 1 : numel(Option_Active_VoltageBand)
			Option_Umin =  Active_Voltagebands{i_v,2};
			Option_Umax =  Active_Voltagebands{i_v,3};
			Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Active_GridVariants{i_g,2}).bus_name);
			if Active_Voltagebands{i_v,1} == 1
				Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed.(Active_GridVariants{i_g,2});
				Data_Node_Violations = Data.voltage_violations(Option_Active_Scenarios,:,:,:);
			else
				Data_Node_Violations = [];
				for i_s = 1 : numel(Option_Active_Scenarios)
					Data = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Active_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]);
					if i_s == 1
						Data_Node_Violations = Data.voltage_violations;
					else
						Data_Node_Violations(end+1,:,:,:) = Data.voltage_violations; %#ok<*SAGROW>
					end
				end
			end
			%[scenario, profileset, timepoint, node]; 1 = violation at node occured
			Data_Node_Violations_Sum = sum(Data_Node_Violations,4) * 100 / Data_Number_total_Busses;
			Data_Node_Violations_tmp_Mean = squeeze(mean(Data_Node_Violations_Sum,2))';
			Data_Node_Violations_tmp_Min  = squeeze(min(Data_Node_Violations_Sum,[],2))';
			Data_Node_Violations_tmp_Max  = squeeze(max(Data_Node_Violations_Sum,[],2))';
			if numel(Option_Active_Scenarios) > 1
				Data_Node_Violations_Min(i_v,i_g,:,:) = min(squeeze(Data_Node_Violations_Min(i_v,i_g,:,:)),Data_Node_Violations_tmp_Min);
				Data_Node_Violations_Max(i_v,i_g,:,:) = max(squeeze(Data_Node_Violations_Max(i_v,i_g,:,:)),Data_Node_Violations_tmp_Max);
			else
				Data_Node_Violations_Min(i_v,i_g,:,:) = min(squeeze(Data_Node_Violations_Min(i_v,i_g,:,:))',Data_Node_Violations_tmp_Min);
				Data_Node_Violations_Max(i_v,i_g,:,:) = max(squeeze(Data_Node_Violations_Max(i_v,i_g,:,:))',Data_Node_Violations_tmp_Max);
			end
			if i_d <= 1
				Data_Node_Violations_Mean(i_v,i_g,:,:) = Data_Node_Violations_tmp_Mean;
			else
				if numel(Option_Active_Scenarios) > 1
					Data_Node_Violations_Mean(i_v,i_g,:,:) = 0.5 * (squeeze(Data_Node_Violations_Mean(i_v,i_g,:,:)) + Data_Node_Violations_tmp_Mean);
				else
					Data_Node_Violations_Mean(i_v,i_g,:,:) = 0.5 * (squeeze(Data_Node_Violations_Mean(i_v,i_g,:,:))' + Data_Node_Violations_tmp_Mean);
				end
			end
		end
	end
	
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d >= Saved_Data_OAT.Number_Datasets
		fig_oat_node_timeline = set_up_singleplot(Option_Plot_Size);
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
		
		if numel(Option_Active_VoltageBand) >= 2
			% make a background line with voltage band color
			for i_g = 1: numel(Option_Active_GridVariants)
				for i_v = 1 : numel(Option_Active_VoltageBand)
					for i_s = 1 : numel(Option_Active_Scenarios)
						Data_Plot_Mean = squeeze(Data_Node_Violations_Mean(i_v,i_g,:,i_s));
						f_p = patchline(1:Data_Timepoints,Data_Plot_Mean);
						hold on;
						f_p.EdgeColor = Active_Voltagebands{i_v,8};
						f_p.EdgeAlpha = 1;
						f_p.LineStyle = '-';
						f_p.LineWidth = Option_Default_Line_Width * 3;
					end
				end
			end
		end
		for i_g = 1: numel(Option_Active_GridVariants)
			for i_v = 1 : numel(Option_Active_VoltageBand)
				for i_s = 1 : numel(Option_Active_Scenarios)
					Data_Plot_Mean = squeeze(Data_Node_Violations_Mean(i_v,i_g,:,i_s));
					f_l = plot(Data_Plot_Mean);
					hold on;
					f_l.Color = Active_Scenarios{i_s,3};
					f_l.LineWidth = Option_Default_Line_Width;
					if Option_Distinct_Seasons
						switch Active_Scenarios{i_s, 6}
							case 'Sommer'
								f_l.LineStyle = ':';
							case 'Winter'
								f_l.LineStyle = '-';
						end
					end
					if Option_Distinct_Grids
						if i_g <= 1
							f_l.LineStyle = '-';
						else
							f_l.LineStyle = ':';
						end
					end
					if ~any(strcmpi(Labels_Scenarios, Active_Scenarios{i_s,5}))
						Labels_Scenarios{end+1} = Active_Scenarios{i_s,5};
						f_l = plot(nan, nan);	                % make an invisible line for legend
						f_l.Color = Active_Scenarios{i_s,3}; % set color of invisible line
						f_l.LineStyle = '-';                    % set linestyle of invisible line
						f_l.LineWidth = Option_Default_Line_Width;
						Labels_Scen_Style(end+1) = f_l;
					end
					
					if Option_Show_Min_Max
						Data_Plot_Max = squeeze(Data_Node_Violations_Max(i_v,i_g,:,i_s))';
						Data_Plot_Min = squeeze(Data_Node_Violations_Min(i_v,i_g,:,i_s))';
						if numel(Option_Active_GridVariants) <= 1
							% fill the area between min and max:
							f_inBetweenRegionX = [1:length(Data_Plot_Max), length(Data_Plot_Min):-1:1];
							f_inBetweenRegionY = [Data_Plot_Max, fliplr(Data_Plot_Min)];
							f_f = fill(f_inBetweenRegionX, f_inBetweenRegionY, 'g');
							f_f.FaceColor = Active_Scenarios{i_s,3};
							f_f.FaceAlpha = 0.25;
							f_f.LineStyle = 'none';
						end
						% Plot max
						f_l = plot(Data_Plot_Max);
						f_l.Color = Active_Scenarios{i_s,3};
						f_l.LineStyle = '-.';
						f_l.LineWidth = Option_Default_Line_Width;
						drawnow;
						%plot min
						f_l = plot(Data_Plot_Min);
						f_l.Color = Active_Scenarios{i_s,3};
						f_l.LineStyle = ':';
						f_l.LineWidth = Option_Default_Line_Width;
						drawnow;
					end
				end
			end
		end
		% Format the plot:
		f_ax = gca;
		
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area         = Settings_Max_Fig_Area;
		else
			f_max_area = [];
		end
		
		% X Axis
		if Option_Plot_x_max_Value > 0
			set_tick_x_dayprofile(f_ax,...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step);
		end
		% Y Axis
		if Option_Plot_y_max_Value > 0
			f_ax.YAxis.Limits  = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Plot_y_min_Value,...
				Option_Plot_y_step_Value,...
				Option_Plot_y_max_Value,...
				Option_Plot_y_Label_Step,...
				'%',... % no unit
				Option_Plot_y_Num_Format);
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Show_Min_Max && Option_Show_Legend_Details
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_mean_min_max_entry_to_legend(fig_oat_node_timeline,...
					Labels_Scenarios, Labels_Scen_Style, []);
			end
			if Option_Distinct_Seasons && Option_Show_Legend_Details
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_oat_node_timeline,...
					Option_Default_Line_Width, Labels_Scenarios, Labels_Scen_Style, 'line');
			end
			if Option_Distinct_Grids && Option_Show_Legend_Details
				for i_g = 1 : numel(Option_Active_GridVariants)
					f_l = plot(nan);	                % make an invisible bar for legend
					f_l.Color = 'k';
					f_l.LineWidth = Option_Default_Line_Width;
					if i_g <= 1
						f_l.LineStyle = '-';
					else
						f_l.LineStyle = ':';
					end
					Labels_Scen_Style(end+1) = f_l;
					Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
				end
			end
			legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
		end
		% Configuration
		set_default_plot_properties(f_ax,'axes_on_top');
		f_max_area = set_single_plot_properties(f_ax, ...
			Labels_Title,...
			[],...
			Labels_Y_Direction,...
			Option_Show_Title,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		% adjust legend properties a little bit for this kind of graph
		if Option_Show_Legend
			f_lg = get(f_ax, 'Legend');
			f_lg.ItemTokenSize = [17, 6];
		end
		hold off
	end
end

clear Active_* Data* f_* i_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramm with affected Nodes grid variant comparison
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 3; % only one can be active here!
Option_Active_Scenarios    = 7:8; % only one szenario (different seasons)!
Option_Active_GridVariants = 1:4;
Option_Used_Data           = 'Time'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles
Option_Show_Legend        = 1;
Option_Show_X_Label       = 1;
Option_Show_Y_Label       = 1;
Settings_Max_Fig_Area     = [0.1367    0.1236    0.0364    0.0294];
Option_Default_Line_Width = 1.5;
Option_Bar_Width          = 0.6; %0.6... in Word; 1... when small bars
Option_Grouped_Bar        = 1;
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Bar_x_max_Value  =  100;  % (-1 ... autoscale)
Option_Number_Bins      =  20;
Option_Bar_x_min_Value  =   0;
Option_Bar_x_Label_Step =   2; % Spacing between label entries
Option_Bar_x_Last_GT    =   0; % 1 = show last label with leading ">" sign
%- - - - - - - - - - - - - - - - - -
Option_Bar_y_max_Value  = -1; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =  0; % '%'
Option_Bar_y_step_Value =  4; % '%'
Option_Bar_y_Label_Step =  1; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_Y_Direction = 'rel. Häufigkeit';
Labels_X_Time = 'Anteil Profilzeit mit Spannungsbandverletzung [%]';
Labels_X_Node = 'Anteil Knoten mit Spannungsbandverletzung [%]';
% = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		
		Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand,3};
		
		Data_Violation_Numbers      = NaN(...
			numel(Option_Active_GridVariants),...
			Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Violation_Bus_Numbers = Data_Violation_Numbers;
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
	% Read out out the needed data...
	for i_g = 1:size(Settings_GridVariants,1)
		if Settings_VoltageBands{Option_Active_VoltageBand,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Timepoints;
			Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
			Data_Violation_Bus_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violated_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Number_total_Busses;
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets * 100 / Data_Timepoints;
					Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
					Data_Violation_Bus_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violated_at_datasets * 100 / Data_Number_total_Busses;
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
	if i_d >=  Saved_Data_OAT.Number_Datasets
		fig_oat_histogram_grid_compare = set_up_singleplot(Option_Plot_Size);
		
		Option_Histogramm_Autoscale = true;
		Labels_Scenarios  = {};
		Labels_Scen_Style = [];
		
		switch Option_Used_Data
			case 'Time'
				Data_Violation = Data_Violation_Numbers;
			case 'Node'
				Data_Violation = Data_Violation_Bus_Numbers;
		end
		
		if Option_Bar_x_max_Value < 0
			Option_Bar_x_max_Value = max(Data_Violation,[],'all');
			Option_Bar_x_min_Value = min(Data_Violation,[],'all');
		else
			Option_Histogramm_Autoscale = false;
		end
		Hist_binEdges = linspace(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins+1);
		Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2;
		
		for i_s = 1 : numel(Option_Active_Scenarios)
			Data_Plot = [];
			for i_g = 1 : numel(Option_Active_GridVariants)
				Hist_Data = Data_Violation(i_g,:,i_s)';
				[~,Hist_binIdx] = histc(Hist_Data,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
				Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
				
				% Plot "normal" histogramm
				if ~Option_Grouped_Bar 
					figure(fig_oat_histogram_grid_compare);
					f_ax = gca;
					f_bb = bar(f_ax, Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
					hold(f_ax,'on');
					f_bb.EdgeColor = Active_GridVariants{i_g,3};
					f_bb.LineWidth = Option_Default_Line_Width;
					f_bb.EdgeAlpha = 1.0;
					f_bb.FaceColor = Active_GridVariants{i_g,3};
					f_bb.FaceAlpha = 0.5;
					if Option_Distinct_Seasons
						switch Active_Scenarios{i_s, 6}
							case 'Sommer'
								f_bb.LineStyle = ':';
							case 'Winter'
								f_bb.LineStyle = '-';
						end
					end
				end
				% prepare the date for maybe grouped plot:
				if i_g <= 1
					Data_Plot = 100*Hist_nj/sum(Hist_nj);
				else
					Data_Plot(:,end+1) = 100*Hist_nj/sum(Hist_nj);
				end
				% get the legend entries for the scenarios:
				if ~any(strcmpi(Labels_Scenarios, Active_GridVariants{i_g,5}))
					Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
					f_l = bar(nan);	                % make an invisible bar for legend
					f_l.EdgeColor = Active_GridVariants{i_g,3};
					f_l.LineWidth = Option_Default_Line_Width;
					f_l.EdgeAlpha = 1.0;
					f_l.FaceColor = Active_GridVariants{i_g,3};
					f_l.FaceAlpha = 0.5;
					Labels_Scen_Style(end+1) = f_l;
				end
			end
			if Option_Grouped_Bar
				figure(fig_oat_histogram_grid_compare);
				if i_s <= 1
					% crate a axis under the real one for Labeling between the Ticks
					f_under_ax = cla();
					% creat the visible axis
					f_ax = copyobj(f_under_ax, ancestor(f_under_ax,'figure'));
					hold(f_ax,'on');
				end
				% plot the data
				f_b = bar(f_ax,Hist_cj,Data_Plot,'BarLayout','grouped');
				for i_g = 1 : numel(Option_Active_GridVariants)
					f_bb = f_b(i_g);
					f_bb.EdgeColor = Active_GridVariants{i_g,3};
					f_bb.LineWidth = 1;
					f_bb.EdgeAlpha = 1.0;
					f_bb.FaceColor = Active_GridVariants{i_g,3};
					f_bb.FaceAlpha = 0.5;
					f_bb.BarWidth = Option_Bar_Width;
					if Option_Distinct_Seasons
						switch Active_Scenarios{i_s, 6}
							case 'Sommer'
								f_bb.LineStyle = ':';
							case 'Winter'
								f_bb.LineStyle = '-';
						end
					end
				end
			end
		end
		
		% Format the plot:
		figure(fig_oat_histogram_grid_compare);
		
		% X Axis
		if ~Option_Show_X_Label
			Labels_X_Direction = [];
		else
			switch Option_Used_Data
				case 'Time'
					Labels_X_Direction = Labels_X_Time;
				case 'Node'
					Labels_X_Direction = Labels_X_Node;
			end
		end
			
		if ~Option_Histogramm_Autoscale
			set_tick_x_histogramms(...
				Option_Bar_x_min_Value,...
				Option_Bar_x_max_Value,...
				Option_Number_Bins,...
				Option_Bar_x_Label_Step,...
				Option_Bar_x_Last_GT,...
				f_ax)
		end
		% Y Axis
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area = Settings_Max_Fig_Area;
		else
			f_max_area = [];
		end
		if Option_Bar_y_max_Value > 0
			f_ax.YAxis.Limits  = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Bar_y_min_Value,...
				Option_Bar_y_step_Value,...
				Option_Bar_y_max_Value,...
				Option_Bar_y_Label_Step,...
				'%');
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Grouped_Bar
				legend(f_ax, Labels_Scenarios, 'Location','northeast');
			else
				if Option_Distinct_Seasons
					[Labels_Scenarios,Labels_Scen_Style] =...
						add_season_entry_to_legend(fig_oat_histogram_grid_compare,...
						Option_Default_Line_Width, Labels_Scenarios, Labels_Scen_Style, 'bar');
				end
				legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
			end
		end
		
		set_default_plot_properties(f_ax);
		f_max_area = set_single_plot_properties(f_ax, ...
			[],...
			Labels_X_Direction,...
			Labels_Y_Direction,...
			0,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		
		% reformat the underlying axis if needed
		if Option_Grouped_Bar
			% locate the underlying axis according to visible axis
			f_under_ax.Position = f_ax.Position;
			f_under_ax.YAxis.Limits = f_ax.YAxis.Limits;
			f_under_ax.XAxis.Limits = f_ax.XAxis.Limits;
			% take over all needed values (keep the ticklabels where they are): 
			f_under_ax.YTickLabel = [];
			f_under_ax.XLabel = f_ax.XLabel;
			f_under_ax.XLabel.Position = f_ax.XLabel.Position;
			f_under_ax.XLabel.FontName = f_ax.XLabel.FontName;
			f_under_ax.XLabel.FontSize = f_ax.XLabel.FontSize;
			f_under_ax.XTickLabel = f_ax.XTickLabel;
			f_under_ax.XTick = f_ax.XTick;
			f_under_ax.XAxis.FontSize = f_ax.XAxis.FontSize;
			f_under_ax.FontName = f_ax.FontName;
			% disable the ticklables of the visible axis
			f_ax.XTickLabel = [];
			% adjust the ticks + grid of visible axis (to be between the bar groups):
			f_divider = (Option_Bar_x_max_Value - Option_Bar_x_min_Value)/Option_Number_Bins;
			f_ax.XTick = (floor(min(xlim(f_ax))) : f_divider : ceil(max(xlim(f_ax)))) + f_divider;
			f_ax.XMinorGrid = 'off';
			f_ax.XMinorTick = 'off';
		end
		
		hold off;
	end
end

clear Active_* Data* f_* i_* idx_* Hist_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramm with affected nodes szenario comparison
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 4; % only one can be active here!
Option_Active_Scenarios    = 2:2:6; % only szenarios from one season (no distinction!)
Option_Active_GridVariants = [4,1]; % max. two grid variants! First one '-', second ':' Linestyle
Option_Used_Data           = 'Node'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Grids     = 1; % 1 = Plot the two grid variants with different linestyles
Option_Distinct_Seasons   = 1;
Option_Show_Legend        = 1;
Option_Show_Title         = 0;
Option_Show_X_Label       = 1;
Option_Show_Y_Label       = 1;
Settings_Max_Fig_Area     = [0.1367    0.1236    0.0364    0.0294];
Option_Default_Line_Width = 1.5;
Option_Bar_Width          = 0.6; %0.6... in Word; 1... when small bars
Option_Grouped_Bar        = 0;
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Bar_x_max_Value  =  100;  % (-1 ... autoscale)
Option_Number_Bins      =  50;
Option_Bar_x_min_Value  =   0;
Option_Bar_x_Label_Step =   5; % Spacing between label entries
Option_Bar_x_Last_GT    =   0; % 1 = show last label with leading ">" sign
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_logScale   =   0;
Option_Bar_y_logLimits  = [-1, 2]; % 10^x
%- - - - - - - - - - - - - - - - - -
Option_Bar_y_max_Value  = 16; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =  0; % '%'
Option_Bar_y_step_Value =  4; % '%'
Option_Bar_y_Label_Step =  1; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_Y_Direction = 'rel. Häufigkeit';
Labels_X_Time = 'Anteil Profilzeit mit Spannungsbandverletzung [%]'; 
Labels_X_Node = 'Anteil Knoten mit Spannungsbandverletzung [%]'; 
% = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		
		Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand,3};
		
		Data_Violation_Numbers      = NaN(...
			numel(Option_Active_GridVariants),...
			Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Violation_Bus_Numbers = Data_Violation_Numbers;
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
	% Read out out the needed data...
	for i_g = 1:size(Settings_GridVariants,1)
		if Settings_VoltageBands{Option_Active_VoltageBand,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Timepoints;
			Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
			Data_Violation_Bus_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violated_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Number_total_Busses;
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets * 100 / Data_Timepoints;
					Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
					Data_Violation_Bus_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violated_at_datasets * 100 / Data_Number_total_Busses;
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
	if i_d >=  Saved_Data_OAT.Number_Datasets
		fig_oat_histogram_grid_compare = set_up_singleplot(Option_Plot_Size);
		
		Option_Histogramm_Autoscale = true;
		Labels_Scenarios  = {};
		Labels_Scen_Style = [];
		
		switch Option_Used_Data
			case 'Time'
				Data_Violation = Data_Violation_Numbers;
			case 'Node'
				Data_Violation = Data_Violation_Bus_Numbers;
		end
		
		if Option_Bar_x_max_Value < 0
			Option_Bar_x_max_Value = max(Data_Violation,[],'all');
			Option_Bar_x_min_Value = min(Data_Violation,[],'all');
		else
			Option_Histogramm_Autoscale = false;
		end
		Hist_binEdges = linspace(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins+1);
		Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2;
		
		for i_g = 1 : numel(Option_Active_GridVariants)
			Data_Plot = [];
			for i_s = 1 : numel(Option_Active_Scenarios)
				Hist_Data = Data_Violation(i_g,:,i_s)';
				[~,Hist_binIdx] = histc(Hist_Data,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
				Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
				
				% Plot "normal" histogramm
				if ~Option_Grouped_Bar 
					figure(fig_oat_histogram_grid_compare);
					f_ax = gca;
					f_bb = bar(f_ax, Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
					hold(f_ax,'on');
					f_bb.EdgeColor = Active_Scenarios{i_s,3};
					f_bb.LineWidth = Option_Default_Line_Width;
					f_bb.EdgeAlpha = 1.0;
					f_bb.FaceColor = Active_Scenarios{i_s,3};
					f_bb.FaceAlpha = 0.5;
					if Option_Distinct_Grids
						if i_g <= 1
							f_bb.LineStyle = '-';
						else
							f_bb.LineStyle = ':';
						end
					end
					if Option_Distinct_Seasons
						switch Active_Scenarios{i_s, 6}
							case 'Sommer'
								f_bb.LineStyle = ':';
								f_bb.LineWidth = Option_Default_Line_Width;
							case 'Winter'
								f_bb.LineStyle = '-';
								f_bb.LineWidth = Option_Default_Line_Width;
						end
					end
				end
				% prepare the date for maybe grouped plot:
				if i_s <= 1
					Data_Plot = 100*Hist_nj/sum(Hist_nj);
				else
					Data_Plot(:,end+1) = 100*Hist_nj/sum(Hist_nj);
				end
				% get the legend entries for the scenarios:
				if ~any(strcmpi(Labels_Scenarios, Active_Scenarios{i_s,5}))
					Labels_Scenarios{end+1} = Active_Scenarios{i_s,5};
					f_l = bar(nan);	                % make an invisible bar for legend
					f_l.EdgeColor = Active_Scenarios{i_s,3};
					f_l.LineWidth = Option_Default_Line_Width;
					f_l.EdgeAlpha = 1.0;
					f_l.FaceColor = Active_Scenarios{i_s,3};
					f_l.FaceAlpha = 0.5;
					Labels_Scen_Style(end+1) = f_l;
				end
			end
			if Option_Grouped_Bar
				figure(fig_oat_histogram_grid_compare);
				if i_g <= 1
					% crate a axis under the real one for Labeling between the Ticks
					f_under_ax = cla();
					% creat the visible axis
					f_ax = copyobj(f_under_ax, ancestor(f_under_ax,'figure'));
					hold(f_ax,'on');
				end
				% plot the data
				f_b = bar(f_ax,Hist_cj,Data_Plot,'BarLayout','grouped');
				for i_s = 1 : numel(Option_Active_Scenarios)
					f_bb = f_b(i_s);
					f_bb.EdgeColor = Active_Scenarios{i_s,3};
					f_bb.LineWidth = 1;
					f_bb.EdgeAlpha = 1.0;
					f_bb.FaceColor = Active_Scenarios{i_s,3};
					f_bb.FaceAlpha = 0.5;
					f_bb.BarWidth = Option_Bar_Width;
					if Option_Distinct_Grids 
						if i_g <= 1
							f_bb.LineStyle = '-';
						else
							f_bb.LineStyle = ':';
						end
					end
				end
			end
		end
		
		% Format the plot:
		figure(fig_oat_histogram_grid_compare);
		
		% X Axis
		if ~Option_Show_X_Label 
			Labels_X_Direction = []; 
		else 
			switch Option_Used_Data 
				case 'Time' 
					Labels_X_Direction = Labels_X_Time; 
				case 'Node' 
					Labels_X_Direction = Labels_X_Node; 
			end 
		end
		if ~Option_Histogramm_Autoscale
			set_tick_x_histogramms(...
				Option_Bar_x_min_Value,...
				Option_Bar_x_max_Value,...
				Option_Number_Bins,...
				Option_Bar_x_Label_Step,...
				Option_Bar_x_Last_GT,...
				f_ax)
		end
		% Y Axis
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area         = Settings_Max_Fig_Area;
		else
			f_max_area = [];
		end
		if Option_Bar_y_logScale
			f_ax.YAxis.Scale = 'log';
			f_ax.YAxis.Limits  = 10.^Option_Bar_y_logLimits;
			f_ax.YAxis.TickValues = 10.^(Option_Bar_y_logLimits(1):Option_Bar_y_logLimits(2));
		end
		if Option_Bar_y_max_Value > 0 && ~Option_Bar_y_logScale
			f_ax.YAxis.Limits  = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Bar_y_min_Value,...
				Option_Bar_y_step_Value,...
				Option_Bar_y_max_Value,...
				Option_Bar_y_Label_Step,...
				'%');
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Grouped_Bar
				legend(f_ax, Labels_Scenarios, 'Location','northeast');
			else
				if Option_Distinct_Grids && Option_Show_Legend_Details
					for i_g = 1 : numel(Option_Active_GridVariants)
						f_l = bar(nan);	                % make an invisible bar for legend
						f_l.EdgeColor = 'k';
						f_l.LineWidth = Option_Default_Line_Width;
						f_l.EdgeAlpha = 1.0;
						f_l.FaceColor = 'k';
						f_l.FaceAlpha = 0.25;
						if i_g <= 1
							f_l.LineStyle = '-';
						else
							f_l.LineStyle = ':';
						end
						Labels_Scen_Style(end+1) = f_l;
						Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
					end
				end
				if Option_Distinct_Seasons && Option_Show_Legend_Details
					[Labels_Scenarios,Labels_Scen_Style] =...
						add_season_entry_to_legend(fig_oat_histogram_grid_compare,...
						Option_Default_Line_Width,Labels_Scenarios, Labels_Scen_Style, 'bar');
				end
				legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
			end
		end
		
		set_default_plot_properties(f_ax);
		f_max_area = set_single_plot_properties(f_ax, ...
			[],...
			Labels_X_Direction,...
			Labels_Y_Direction,...
			0,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		
		% reformat the underlying axis if needed
		if Option_Grouped_Bar
			% locate the underlying axis according to visible axis
			f_under_ax.Position = f_ax.Position;
			f_under_ax.YAxis.Limits = f_ax.YAxis.Limits;
			f_under_ax.XAxis.Limits = f_ax.XAxis.Limits;
			% take over all needed values (keep the ticklabels where they are): 
			f_under_ax.YTickLabel = [];
			f_under_ax.XLabel = f_ax.XLabel;
			f_under_ax.XLabel.Position = f_ax.XLabel.Position;
			f_under_ax.XLabel.FontName = f_ax.XLabel.FontName;
			f_under_ax.XLabel.FontSize = f_ax.XLabel.FontSize;
			f_under_ax.XTickLabel = f_ax.XTickLabel;
			f_under_ax.XTick = f_ax.XTick;
			f_under_ax.XAxis.FontSize = f_ax.XAxis.FontSize;
			f_under_ax.FontName = f_ax.FontName;
			% disable the ticklables of the visible axis
			f_ax.XTickLabel = [];
			% adjust the ticks + grid of visible axis (to be between the bar groups):
			f_divider = (Option_Bar_x_max_Value - Option_Bar_x_min_Value)/Option_Number_Bins;
			f_ax.XTick = (floor(min(xlim(f_ax))) : f_divider : ceil(max(xlim(f_ax)))) + f_divider;
			f_ax.XMinorGrid = 'off';
			f_ax.XMinorTick = 'off';
		end
		
		hold off;
	end
end

clear Active_* Data* f_* i_* idx_* Hist_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Duration line with affected nodes grid variant comparison
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 2; % only one can be active here!
Option_Active_Scenarios    = 7:8; % only one szenario (different seasons)!
Option_Active_GridVariants = 2:4;
Option_Used_Data           = 'Node'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles
Option_Show_Legend        = 0;
Option_Show_X_Label       = 1;
Option_Show_Y_Label       = 1;
Settings_Max_Fig_Area     = [0.0719    0.0708    0.0208    0.0257];
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_relative   =  1; % 1: plot against share of all profiles [%]
Option_Plot_x_max_Value  =100; % '-' (-1 ... autoscale)
Option_Plot_x_min_Value  =  0; % '-'
Option_Plot_x_step_Value =  5; % '-'
Option_Plot_x_Label_Step =  5; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
%- - - - - - - - - - - - - - - - - -
Option_Plot_y_max_Value  = 80; % '%' (-1 ... autoscale)
Option_Plot_y_min_Value  =  0; % '%'
Option_Plot_y_step_Value = 10; % '%'
Option_Plot_y_Label_Step =  2; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_X_Direction     = 'Anzahl der Profile';
Labels_X_Direction_rel = 'Anteil der Profile';
Labels_Y_Time = 'Anteil Profilzeit mit Spannungsbandverletzung';
Labels_Y_Node = 'Anteil Knoten mit Spannungsbandverletzung';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		
		Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand,3};
		
		Data_Violation_Numbers      = NaN(...
			numel(Option_Active_GridVariants),...
			Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Violation_Bus_Numbers = Data_Violation_Numbers;
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
	% Read out out the needed data...
	for i_g = 1:size(Settings_GridVariants,1)
		if Settings_VoltageBands{Option_Active_VoltageBand,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Timepoints;
			Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
			Data_Violation_Bus_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violated_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Number_total_Busses;
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets * 100 / Data_Timepoints;
					Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
					Data_Violation_Bus_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violated_at_datasets * 100 / Data_Number_total_Busses;
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
	if i_d >=  Saved_Data_OAT.Number_Datasets
		fig_oat_duration_grid_compare = set_up_singleplot(Option_Plot_Size);
		
		Labels_Scenarios  = {};
		Labels_Scen_Style = [];
		
		switch Option_Used_Data
			case 'Time'
				Data_Violation = Data_Violation_Numbers;
			case 'Node'
				Data_Violation = Data_Violation_Bus_Numbers;
		end
		
		for i_s = 1 : numel(Option_Active_Scenarios)
			for i_g = 1 : numel(Option_Active_GridVariants)
				Data_Plot = Data_Violation(i_g,:,i_s)';
				Data_Plot = sort(Data_Plot,'descend'); %#ok<UDIM>
				f_xdiv = 1:(Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles);
				if Option_Plot_x_relative
					f_xdiv = 100 * f_xdiv / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles);
				end
				f_l = plot(f_xdiv,Data_Plot);
				hold on;
				f_l.Color = Active_GridVariants{i_g,3};
				f_l.LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Seasons
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_l.LineStyle = ':';
						case 'Winter'
							f_l.LineStyle = '-';
					end
				end
				if ~any(strcmpi(Labels_Scenarios, Active_GridVariants{i_g,5}))
					Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
					f_l = plot(nan, nan);	                % make an invisible line for legend
					f_l.Color = Active_GridVariants{i_g,3}; % set color of invisible line
					f_l.LineStyle = '-';                    % set linestyle of invisible line
					f_l.LineWidth = Option_Default_Line_Width;
					Labels_Scen_Style(end+1) = f_l;
				end
			end
		end
		
		% Format the plot:
		figure(fig_oat_duration_grid_compare);
		f_ax = gca;
		
		% X Axis
		if ~Option_Show_X_Label
			Labels_X_Direction = [];
		else
			if Option_Plot_x_relative
				Labels_X_Direction = Labels_X_Direction_rel;
			end
		end
		if Option_Plot_x_relative
			f_x_unit = '%';
		else
			f_x_unit = [];
		end
		if Option_Plot_x_max_Value > 0
			f_ax.XAxis.Limits  = [Option_Plot_x_min_Value, Option_Plot_x_max_Value];
			[tick_x_Positions, tick_x_Labels] = get_tick(...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step,...
				f_x_unit);
			f_ax.XAxis.TickValues   = tick_x_Positions;
			f_ax.XAxis.TickLabels   = tick_x_Labels;
		end
		% Y Axis
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area = Settings_Max_Fig_Area;
		else
			switch Option_Used_Data
				case 'Time'
					Labels_Y_Direction = Labels_Y_Time;
				case 'Node'
					Labels_Y_Direction = Labels_Y_Node;
			end
			f_max_area = [];
		end
		if Option_Plot_y_max_Value > 0
			f_ax.YAxis.Limits  = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Plot_y_min_Value,...
				Option_Plot_y_step_Value,...
				Option_Plot_y_max_Value,...
				Option_Plot_y_Label_Step,...
				'%');
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Distinct_Seasons
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_oat_duration_grid_compare,...
					Option_Default_Line_Width, Labels_Scenarios, Labels_Scen_Style, 'line');
			end
			legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
		end
		% Configuration
		set_default_plot_properties(f_ax);
		f_max_area = set_single_plot_properties(f_ax, ...
			[],...
			Labels_X_Direction,...
			Labels_Y_Direction,...
			0,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		% adjust legend properties a little bit for this kind of graph
		if Option_Show_Legend
			f_lg = get(f_ax, 'Legend');
			f_lg.ItemTokenSize = [17, 6];
		end
		hold off
	end
end

clear Active_* Data* f_* i_* idx_* Hist_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Duration line with affected nodes scenrario comparison
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 2; % only one can be active here!
Option_Active_Scenarios    = 1:2:6; % only szenarios from one season (no distinction!)
Option_Active_GridVariants = [4,1]; % max. two grid variants! First one '-', second ':' Linestyle
Option_Used_Data           = 'Time'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Grids     = 0; % 1 = Plot the grid variants with different linestyles
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles
Option_Show_X_Label       = 1;
Option_Show_Y_Label       = 1;
Settings_Max_Fig_Area     = [0.0719    0.0708    0.0208    0.0257];
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_relative   =  0; % 1: plot against share of all profiles [%]
Option_Plot_x_max_Value  =150; % '-' (-1 ... autoscale)
Option_Plot_x_min_Value  =  0; % '-'
Option_Plot_x_step_Value =  5; % '-'
Option_Plot_x_Label_Step =  5; % Spacing between label entries
%- - - - - - - - - - - - - - - - - -
Option_Plot_y_max_Value  = 80; % '%' (-1 ... autoscale)
Option_Plot_y_min_Value  =  0; % '%'
Option_Plot_y_step_Value = 10; % '%'
Option_Plot_y_Label_Step =  2; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_X_Direction     = 'Anzahl der Profile';
Labels_X_Direction_rel = 'Anteil Profile [-]';
Labels_Y_Time = 'Anteil Profilzeit mit Spannungsbandverletzung';
Labels_Y_Node = 'Anteil Knoten mit Spannungsbandverletzung';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		
		Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand,3};
		
		Data_Violation_Numbers      = NaN(...
			numel(Option_Active_GridVariants),...
			Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Violation_Bus_Numbers = Data_Violation_Numbers;
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
	% Read out out the needed data...
	for i_g = 1:size(Settings_GridVariants,1)
		if Settings_VoltageBands{Option_Active_VoltageBand,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Timepoints;
			Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
			Data_Violation_Bus_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violated_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Number_total_Busses;
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets * 100 / Data_Timepoints;
					Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
					Data_Violation_Bus_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violated_at_datasets * 100 / Data_Number_total_Busses;
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
	if i_d >=  Saved_Data_OAT.Number_Datasets
		fig_oat_duration_grid_compare = set_up_singleplot(Option_Plot_Size);
		
		Labels_Scenarios  = {};
		Labels_Scen_Style = [];
		
		switch Option_Used_Data
			case 'Time'
				Data_Violation = Data_Violation_Numbers;
			case 'Node'
				Data_Violation = Data_Violation_Bus_Numbers;
		end
		
		for i_g = 1 : numel(Option_Active_GridVariants)
			for i_s = 1 : numel(Option_Active_Scenarios)
				Data_Plot = Data_Violation(i_g,:,i_s)';
				Data_Plot = sort(Data_Plot,'descend'); %#ok<UDIM>
				f_xdiv = 1:(Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles);
				if Option_Plot_x_relative
					f_xdiv = 100 * f_xdiv / (Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles);
				end
				f_l = plot(f_xdiv,Data_Plot);
				hold on;
				f_l.Color = Active_Scenarios{i_s,3};
				f_l.LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Grids
					if i_g <= 1
						f_l.LineStyle = '-';
					else
						f_l.LineStyle = ':';
					end
				end
				if Option_Distinct_Seasons 
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_l.LineStyle = ':';
						case 'Winter'
							f_l.LineStyle = '-';
					end
				end
				if ~any(strcmpi(Labels_Scenarios, Active_Scenarios{i_s,5}))
					Labels_Scenarios{end+1} = Active_Scenarios{i_s,5};
					f_l = plot(nan, nan);	                % make an invisible line for legend
					f_l.Color = Active_Scenarios{i_s,3}; % set color of invisible line
					f_l.LineStyle = '-';                    % set linestyle of invisible line
					f_l.LineWidth = Option_Default_Line_Width;
					Labels_Scen_Style(end+1) = f_l;
				end
			end
		end
		
		% Format the plot:
		figure(fig_oat_duration_grid_compare);
		f_ax = gca;
		
		% X Axis
		if ~Option_Show_X_Label
			Labels_X_Direction = [];
		else
			if Option_Plot_x_relative
				Labels_X_Direction = Labels_X_Direction_rel;
			end
		end
		if Option_Plot_x_relative
			f_x_unit = '%';
		else
			f_x_unit = [];
		end
		if Option_Plot_x_max_Value > 0
			f_ax.XAxis.Limits  = [Option_Plot_x_min_Value, Option_Plot_x_max_Value];
			[tick_x_Positions, tick_x_Labels] = get_tick(...
				Option_Plot_x_min_Value,...
				Option_Plot_x_step_Value,...
				Option_Plot_x_max_Value,...
				Option_Plot_x_Label_Step,...
				f_x_unit);
			f_ax.XAxis.TickValues   = tick_x_Positions;
			f_ax.XAxis.TickLabels   = tick_x_Labels;
		end
		% Y Axis
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area = Settings_Max_Fig_Area;
		else
			switch Option_Used_Data
				case 'Time'
					Labels_Y_Direction = Labels_Y_Time;
				case 'Node'
					Labels_Y_Direction = Labels_Y_Node;
			end
			f_max_area = [];
		end
		if Option_Plot_y_max_Value > 0
			f_ax.YAxis.Limits  = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Plot_y_min_Value,...
				Option_Plot_y_step_Value,...
				Option_Plot_y_max_Value,...
				Option_Plot_y_Label_Step,...
				'%');
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Distinct_Grids
				for i_g = 1 : numel(Option_Active_GridVariants)
					f_l = plot(nan);	                % make an invisible bar for legend
					f_l.Color = 'k';
					f_l.LineWidth = Option_Default_Line_Width;
					if i_g <= 1
						f_l.LineStyle = '-';
					else
						f_l.LineStyle = ':';
					end
					Labels_Scen_Style(end+1) = f_l;
					Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
				end
			end
			if Option_Distinct_Seasons
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_oat_duration_grid_compare,...
					Option_Default_Line_Width,Labels_Scenarios, Labels_Scen_Style, 'line');
			end
			legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
		end
		% Configuration
		set_default_plot_properties(f_ax);
		f_max_area = set_single_plot_properties(f_ax, ...
			[],...
			Labels_X_Direction,...
			Labels_Y_Direction,...
			0,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		% adjust legend properties a little bit for this kind of graph
		if Option_Show_Legend
			f_lg = get(f_ax, 'Legend');
			f_lg.ItemTokenSize = [17, 6];
		end
		hold off
	end
end

clear Active_* Data* f_* i_* idx_* Hist_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Development of the duration line with affected nodes scenrario comparison
% = = = = = = = = = = = = = = = = =
Option_Active_VoltageBand  = 4; % only one can be active here!
Option_Active_Scenarios    = [8,9,2]; % only szenarios from one season (no distinction!)
Option_Active_GridVariants = [4,1]; % max. two grid variants! First one '-', second ':' Linestyle
Option_Used_Data           = 'Time'; % 'Time'; 'Node'
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Grids     = 1; % 1 = Plot the season with different linestyles
Option_Show_SubTitle      = 1;
Option_Show_Legend        = 1;
Option_Show_X_Label       = 1;
Option_Show_Y_Label       = 1;
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
Option_Show_Errors        = 1;
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  =100; % '%' (-1 ... autoscale)
Option_Plot_x_min_Value  =  0; % '%'
Option_Plot_x_step_Value =  5; % '%'
Option_Plot_x_Label_Step =  5; % Spacing between label entries
%- - - - - - - - - - - - - - - - - -
Option_Plot_y_max_Value  =100; % '%' (-1 ... autoscale)
Option_Plot_y_min_Value  =  0; % '%'
Option_Plot_y_step_Value = 10; % '%'
Option_Plot_y_Label_Step =  2; % Spacing between label entries
Option_Plot_y_Err_Scale  =100; % where should the 100%-error be? 
% = = = = = = = = = = = = = = = = =
Labels_X_Direction = 'Anteil Profile [%]';
Labels_Y_Time = 'Anteil Profilzeit mit Spannungsbandverletzung [%]';
Labels_Y_Node = 'Anteil Knoten mit Spannungsbandverletzung [%]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_OAT.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Voltagebands = Settings_VoltageBands(Option_Active_VoltageBand,:);
		Active_GridVariants = Settings_GridVariants(Option_Active_GridVariants,:);
		Data_Timepoints = ...
			Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset;
		
		Option_Umin =  Settings_VoltageBands{Option_Active_VoltageBand,2};
		Option_Umax =  Settings_VoltageBands{Option_Active_VoltageBand,3};
		
		Data_Violation_Numbers      = NaN(...
			numel(Option_Active_GridVariants),...
			Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles,...
			numel(Option_Active_Scenarios));
		Data_Violation_Bus_Numbers = Data_Violation_Numbers;
		
		% X Axis
		if ~Option_Show_X_Label
			Labels_X_Direction = [];
		end
		% Y Axis
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
		else
			switch Option_Used_Data
				case 'Time'
					Labels_Y_Direction = Labels_Y_Time;
				case 'Node'
					Labels_Y_Direction = Labels_Y_Node;
			end
		end
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	idx_datasets = (i_d-1)*Settings_Number_Profiles+1:i_d*Settings_Number_Profiles;
	% Read out out the needed data...
	for i_g = 1:size(Settings_GridVariants,1)
		if Settings_VoltageBands{Option_Active_VoltageBand,1} == 1
			% when using OAT data directly, use the sorted idxs to have
			% always the correct order of used data based on the input data
			% creation time!
			i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
			Data = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Processed;
			% idx == 1 means, default values of OAT analysis can be used
			Data_Violation_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violations_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Timepoints;
			Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
			Data_Violation_Bus_Numbers(i_g,idx_datasets,:) = ...
				Data.(Settings_GridVariants{i_g,2}).bus_violated_at_datasets(:,Option_Active_Scenarios) * 100 / Data_Number_total_Busses;
		else
			for i_s = 1 : numel(Option_Active_Scenarios)
				try
					Data_Violation_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violations_at_datasets * 100 / Data_Timepoints;
					Data_Number_total_Busses = numel(Saved_Data_OAT.(['Saved_',num2str(1)]).NVIEW_Processed.(Settings_GridVariants{i_g,2}).bus_name);
					Data_Violation_Bus_Numbers(i_g,idx_datasets,i_s) = Saved_Recalculation_Data.(...
						['U_',num2str(Option_Umin),'_',num2str(Option_Umax)]).(...
						['Saved_',num2str(i_d)]).(...
						Settings_GridVariants{i_g,2}).(...
						['Sc_',num2str(Active_Scenarios{i_s,1})]).bus_violated_at_datasets * 100 / Data_Number_total_Busses;
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
	if i_d >=  Saved_Data_OAT.Number_Datasets
		fig_oat_duration_grid_compare = set_up_tiledlayout([],Labels_X_Direction,Labels_Y_Direction,Option_Plot_Size);
		
		Labels_Scenarios  = {};
		Labels_Scen_Style = [];
		switch Option_Used_Data
			case 'Time'
				Data_Violation = Data_Violation_Numbers;
			case 'Node'
				Data_Violation = Data_Violation_Bus_Numbers;
		end
		for i_dd = 1 : Saved_Data_OAT.Number_Datasets
			nexttile();
			
			for i_g = 1 : numel(Option_Active_GridVariants)
				for i_s = 1 : numel(Option_Active_Scenarios)
					% Prepare the data to be plotted:
					Data_Plot_total = Data_Violation(i_g,:,i_s)';
					Data_Plot_total = sort(Data_Plot_total,'descend'); %#ok<UDIM>
					f_xdiv_total = 1:size(Data_Plot_total,1);
					f_xdiv_total = 100 * f_xdiv_total / size(Data_Plot_total,1);
					Data_Plot = Data_Violation(i_g,1:i_dd*Settings_Number_Profiles,i_s)';
					Data_Plot = sort(Data_Plot,'descend'); %#ok<UDIM>
					f_xdiv = 1:(i_dd * Settings_Number_Profiles);
					f_xdiv = 100 * f_xdiv / (i_dd * Settings_Number_Profiles);
					
					% Plot the error
					if Option_Show_Errors
						Data_error = [];
						Data_Num_Total_Profiles = Saved_Data_OAT.Number_Datasets * Settings_Number_Profiles;
						Data_Num_Profiles       = i_dd * Settings_Number_Profiles;
						f_xdiv_ind_total = 1 : Data_Num_Total_Profiles;
						f_xdiv_ind       = 1 : Data_Num_Profiles;
						f_xdiv_ind = f_xdiv_ind * Data_Num_Total_Profiles / Data_Num_Profiles;
						f_xdiv_ind = floor(f_xdiv_ind);
						for i_ps = 1:size(Data_Plot,1)
							% find the next idx of the same value:
							idx_val = f_xdiv_ind_total == f_xdiv_ind(i_ps);
							% Calculate the error:
							if Option_Plot_y_max_Value < 0
								f_error_scale = Option_Plot_y_Err_Scale / 100;
							else
								f_error_scale = Option_Plot_y_Err_Scale / Option_Plot_y_max_Value;
							end
							f_error_value = abs((Data_Plot(i_ps) - Data_Plot_total(idx_val)));
							Data_error(end+1) = f_error_value * 100 * f_error_scale / mean(Data_Plot_total);
						end
						f_b = bar(f_xdiv,Data_error);
						f_b.EdgeColor = Active_Scenarios{i_s,3};
						f_b.EdgeAlpha = 0.5;
						f_b.FaceColor = Active_Scenarios{i_s,3};
						f_b.FaceAlpha = 0.125;
						f_b.BarWidth = 1;
						if Option_Distinct_Grids
						if i_g <= 1
							f_b.LineStyle  = '-';
						else
							f_b.LineStyle  = ':';
						end
					end
					end
					
					% Plot the final duration line (all profile sets), first a white line as background:
					f_pu = patchline(f_xdiv_total,Data_Plot_total);
					hold on;
					f_pu.LineWidth = Option_Default_Line_Width * 0.75;
					f_pu.EdgeColor = 'w';
					f_p = patchline(f_xdiv_total,Data_Plot_total);
					f_p.EdgeColor = Active_Scenarios{i_s,3};
					f_p.EdgeAlpha = 0.75;
					f_p.LineStyle = '-';
					f_p.LineWidth = Option_Default_Line_Width * 0.75;
					if Option_Distinct_Grids
						if i_g <= 1
							f_p.LineStyle  = '-';
							f_pu.LineStyle = '-';
						else
							f_p.LineStyle  = ':';
							f_pu.LineStyle = ':';
						end
					end
					
					% Plot the partial data set
					f_l = plot(f_xdiv,Data_Plot);
					hold on;
					f_l.Color = Active_Scenarios{i_s,3};
					f_l.LineWidth = Option_Default_Line_Width;
					if Option_Distinct_Grids
						if i_g <= 1
							f_l.LineStyle = '-';
						else
							f_l.LineStyle = ':';
						end
					end
				end
			end
			
			% Format the plot:
			figure(fig_oat_duration_grid_compare);
			f_ax = gca;
			% General:
			if Option_Show_SubTitle
				f_ax.Title.String = [num2str(i_dd*Settings_Number_Profiles),' Profile'];
			end
			% X Axis
			if Option_Plot_x_max_Value > 0
				[tick_x_Positions, tick_x_Labels] = get_tick(...
					Option_Plot_x_min_Value,...
					Option_Plot_x_step_Value,...
					Option_Plot_x_max_Value,...
					Option_Plot_x_Label_Step,...
					[]);
				f_ax.XAxis.TickValues   = tick_x_Positions;
				f_ax.XAxis.TickLabels   = tick_x_Labels;
				if Option_Show_Errors
					f_ax.XAxis.Limits  = [Option_Plot_x_min_Value, Option_Plot_x_max_Value + Option_Plot_x_step_Value * 0.5];
				else
					f_ax.XAxis.Limits  = [Option_Plot_x_min_Value, Option_Plot_x_max_Value];
				end
			end
			% Y Axis
			if Option_Plot_y_max_Value > 0
				f_ax.YAxis.Limits  = [Option_Plot_y_min_Value, Option_Plot_y_max_Value];
				[tick_y_Positions, tick_y_Labels] = get_tick(...
					Option_Plot_y_min_Value,...
					Option_Plot_y_step_Value,...
					Option_Plot_y_max_Value,...
					Option_Plot_y_Label_Step,...
					[]);
				f_ax.YAxis.TickValues   = tick_y_Positions;
				f_ax.YAxis.TickLabels   = tick_y_Labels;
			end
			% Legend
			if Option_Show_Legend && i_dd == 13
				Labels_Scen_Style = [];
				Labels_Scenarios  = {};
				for i_s = 1 : numel(Option_Active_Scenarios)
					Labels_Scenarios{end+1} = Active_Scenarios{i_s,5};
					f_l = plot(nan, nan);	                % make an invisible line for legend
					f_l.Color = Active_Scenarios{i_s,3}; % set color of invisible line
					f_l.LineStyle = '-';                    % set linestyle of invisible line
					f_l.LineWidth = Option_Default_Line_Width;
					Labels_Scen_Style(end+1) = f_l;
				end
				legend(Labels_Scen_Style, Labels_Scenarios, 'Location','southwest');
			end
			if Option_Show_Legend && i_dd == 14
				Labels_Scen_Style = [];
				Labels_Scenarios  = {};
				for i_s = 1 : numel(Option_Active_Scenarios)
					f_b = bar(nan);
					f_b.EdgeColor = Active_Scenarios{i_s,3};
					f_b.EdgeAlpha = 0.5;
					f_b.FaceColor = Active_Scenarios{i_s,3};
					f_b.FaceAlpha = 0.125;
					f_b.BarWidth = 1;
					Labels_Scen_Style(end+1) = f_b;
					Labels_Scenarios{end+1}  = ['Abw. ',Active_Scenarios{i_s,5}];
				end
				legend(Labels_Scen_Style, Labels_Scenarios, 'Location','southwest');
			end
			if Option_Show_Legend && Option_Distinct_Grids && i_dd == 15
				Labels_Scen_Style = [];
				Labels_Scenarios  = {};
				for i_g = 1 : numel(Option_Active_GridVariants)
					f_l = plot(nan);	                % make an invisible bar for legend
					f_l.Color = 'k';
					f_l.LineWidth = Option_Default_Line_Width;
					if i_g <= 1
						f_l.LineStyle = '-';
					else
						f_l.LineStyle = ':';
					end
					Labels_Scen_Style(end+1) = f_l;
					Labels_Scenarios{end+1} = Active_GridVariants{i_g,5};
				end
				legend(Labels_Scen_Style, Labels_Scenarios, 'Location','southwest');
			end
			% Configuration
			set_default_plot_properties(f_ax);
			hold off
		end
	end
end

clear Active_* Data* f_* i_* idx_* Hist_* Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =