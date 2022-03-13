%%= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
clear();
Saved_Data_Input = [];
Saved_Data_Profiles = [];
% Add folder with help functions / needed classes to path:
addpath([fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'Additional_Resources']);
%#ok<*UNRCH>
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (set up) and the next one (and loading the data) have to
% be executed before every other cell! 

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Paths to source files / Number profiles per Set:
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Settings_Number_Profiles = 10; Path_Data_LoadInfeed = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
% Settings_Number_Profiles = 30; Path_Data_LoadInfeed = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios_30erSets';
% Settings_Number_Profiles = 10; Path_Data_LoadInfeed = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Additional Set Up
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Settings_Scenario = {
% 1      2                                                3             4          5                      6 
% ID  ,  Filename                                       , Color       , LineStyle, Legendstr w.o. Season, Season 
	 1, '01_SB_Base_Winter_Workda'                      ,[ 74,126,187], '-'      , 'SB'                 , 'Winter';...
	 2, '02_SB_Base_Summer_Workda'                      ,[ 74,126,187], '-'      , 'SB'                 , 'Sommer';...
	 3, '03_S1_LowLoadHighInfeed_Winter_Workda'         ,[190, 75, 72], '-'      , 'S1'                 , 'Winter';...
	 4, '04_S1_LowLoadHighInfeed_Summer_Workda'         ,[190, 75, 72], '-'      , 'S1'                 , 'Sommer';...
	 5, '05_S2_HighLoadHighInfeed_Winter_Workda'        ,[152,185, 84], '-'      , 'S2'                 , 'Winter';...
	 6, '06_S2_HighLoadHighInfeed_Summer_Workda'        ,[152,185, 84], '-'      , 'S2'                 , 'Sommer';...
	 7, '07_S3_HighLoadHighInfeed2Nodes_Winter_Workda'  ,[128,100,162], '-'      , 'S3'                 , 'Winter';...
	 8, '08_S3_HighLoadHighInfeed2Nodes_Summer_Workda'  ,[128,100,162], '-'      , 'S3'                 , 'Sommer';...
	 9, '09_S4_MediumLoadHighInfeed2Nodes_Winter_Workda',[247,173, 36], '-'      , 'S4'                 , 'Winter';...
	10, '10_S4_MediumLoadHighInfeed2Nodes_Summer_Workda',[247,173, 36], '-'      , 'S4'                 , 'Sommer';...
	};

Settings_Loadtype = {
% 1      2               3
% ID  ,  Data Set ID  ,  Legendstr. 
	 1, 'Households'  , 'Haushaltslast'   ;...
	 2, 'Solar'       , 'PV Einspeisung'  ;...
	 3, 'El_Mobility' , 'Elektromobilit�t';...
	};

Settings_Datatype = {
% 1      2                   3
% ID ,  Data Typ ID      ,  Legendstr.
	1, 'Data_Sample'     , 'Sample';...
	2, 'Data_Mean'       , 'Mittelwert';...
	3, 'Data_Min'        , 'Minimum';...
	4, 'Data_Max'        , 'Maximum';...
	5, 'Data_05P_Quantil', '5% Quantille';...
	6, 'Data_95P_Quantil', '95% Quantille';...
	};

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Load Data (Load Infeed Data)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
folders = dir(Path_Data_LoadInfeed);
folders = struct2cell(folders);
folders = folders(1,3:end);
disp('Loading Input Data...');
for i_d = 1: numel(folders)
	disp(['    Reading File ',num2str(i_d),' of ',num2str(numel(folders))]);
	if ~isfield(Saved_Data_Input,['Saved_',num2str(i_d)])
		Saved_Data_Input.(['Saved_',num2str(i_d)]) = [];
	end
	for i_s = 1 : size(Settings_Scenario,1)
		if ~isfield(Saved_Data_Input.(['Saved_',num2str(i_d)]),['Saved_',num2str(Settings_Scenario{i_s,1})])
			Saved_Data_Input.(['Saved_',num2str(i_d)]).(['Saved_',num2str(Settings_Scenario{i_s,1})]) = ...
				load([Path_Data_LoadInfeed,filesep,folders{i_d},'\',Settings_Scenario{i_s,2},'.mat'],'Load_Infeed_Data');
		end
	end
end
disp('... done!');
Saved_Data_Input.Number_Datasets = numel(folders);

clear folders i_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot sum over single appliance profiles over scenarios
% = = = = = = = = = = = = = = = = = 
% Option_Active_Scenarios = 2:2:10; Option_Show_Season = 0; % Sommer
Option_Active_Scenarios = [6, 8]; Option_Show_Season = 0;
% Option_Active_Scenarios = 1:2:10; Option_Show_Season = 0; % Winter
% Option_Active_Scenarios = 1:10; Option_Show_Season = 1; % All scenarios (not recomended!)
%- - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = 'El_Mobility'
%- - - - - - - - - - - - - - - - - - 
% y-axis Settings (Option_Plot_max_Value = -1 ... autoscale)
Option_Plot_max_Value  =  75; % kW
Option_Plot_step_Value =  15; % kW
Option_Plot_Label_Step =   2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_Activity   =   1; % Show, how many profiles are active
Option_Show_SubTitle   =   0; % 1 = Show supplot titles
Option_Plot_Size  = 'medium'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Profilsummen �ber Szenarien f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
% Labels_X_Direction = 'Datensets';
Labels_Y_Direction = 'Leistung [kW]';
Labels_X_Direction = []; % No label for Word output
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		
		fig_infeedsummary = set_up_tiledlayout(Labels_Title,...
			Labels_X_Direction, Labels_Y_Direction, Option_Plot_Size);
		
		% Set up the needed ticks:
		[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
		[tick_y_Positions, tick_y_Labels] = get_tick(0,Option_Plot_step_Value, Option_Plot_max_Value, Option_Plot_Label_Step);
	end
	figure(fig_infeedsummary); nexttile;
	Labels_Activity  = {};
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data_Mean_Shuffled = [];
		for i_sp = 1 : Settings_Number_Profiles
			Data_Mean_Shuffled = [Data_Mean_Shuffled;...
				Data_Input.(['Set_',num2str(i_sp)]).(Active_LoadType).Data_Mean]; %#ok<AGROW>
		end
		Data_Mean_Shuffled = sum(Data_Mean_Shuffled,2);
		% from W to kW
		Data_Mean_Shuffled = Data_Mean_Shuffled ./ 1000;
		if (~isempty(Data_Mean_Shuffled))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			if Option_Show_Season
				Labels_Scenarios{end} = [Labels_Scenarios{end},' ',Active_Scenarios{j,6}]; 
			end
		end
		switch Active_LoadType
			case 'Households'
				Data_num_active = sum(cell2mat(Data_Input.Set_1.Households.Number(:,2)));
				Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
			case 'Solar'
				Data_num_active = size(Data_Input.(['Set_',num2str(i_sp)]).Solar_Plants.Selectable,1)-2;
				if Data_num_active > 0
					Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
				end
			case 'El_Mobility'
				Data_num_active = Data_Input.(['Set_',num2str(i_sp)]).(Active_LoadType).Number;
				if Data_num_active > 0
					Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
				end
			otherwise
				Data_num_active = 9999;
				Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
		end
		figure(fig_infeedsummary); f_l = plot(Data_Mean_Shuffled);
		set(f_l, 'Color', Active_Scenarios{j,3}/256);
		set(f_l, 'LineStyle', Active_Scenarios{j,4});
		drawnow;
		if j <=1
			figure(fig_infeedsummary); hold on;
		end
	end
	% Format Diagrams:
	figure(fig_infeedsummary); 
	f_ax = gca;
	if Option_Show_SubTitle
		f_ax.Title.String = ['Profilsatz ',num2str(i)]; 
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','northeast');
	elseif (i == 2) && Option_Show_Activity
		legend(Labels_Activity{:}, 'Location','northeast');
	end
	% X Axis
	f_ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	f_ax.XAxis.TickValues   = tick_x_Positions;
	f_ax.XAxis.TickLabels   = tick_x_Labels;
	% Y Axis
	if Option_Plot_max_Value > 0
		f_ax.YAxis.Limits  = [0 Option_Plot_max_Value];
		f_ax.YAxis.TickValues   = tick_y_Positions;
		f_ax.YAxis.TickLabels   = tick_y_Labels;
	end
	set_default_plot_properties(f_ax);
	figure(fig_infeedsummary); hold off;
end

clear Active_* Option_* Labels_* Data* tick_* i j k l f_* 
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot timeline summary figures 
% = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = 1:10;%[4, 6, 8, 10];
% Option_Active_Scenarios = 1:2:10; % Winter
% Option_Active_Scenarios = 2;
%- - - - - - - - - - - - - - - - - -
Option_Type_Load = 3; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
Option_Type_Data = [2,5,6]; % 2 ='Mean', 3 ='min', 4 ='max', 5 ='5%q', 6='95%q' 
%- - - - - - - - - - - - - - - - - -
Option_Show_Title         = 1; % 1 = Show Plot Title
Option_Show_Min_Max       = 0; % 1 = Plot also min and max of the profiles    --+
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyle --+-- Only one of them should be 1! 
Option_Default_Line_Width = 1.5;
Option_Show_Legend        = 1;
Option_Plot_Size          = 'medium'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 144; % x10 minutes (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; % x10 minutes
Option_Plot_x_step_Value =  60; % minutes
Option_Plot_x_Label_Step =   4; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Plot_y_max_Value  =   1; % 'kW' (-1 ... autoscale)
Option_Plot_y_min_Value  =   0; % 'kW'
Option_Plot_y_step_Value =   0.25; % 'kW'
Option_Plot_y_Label_Step =   2; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_Y_Direction = 'Leistung [kW]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_Input.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		Active_Datatype = Settings_Datatype(Option_Type_Data,:);
		
		f_max_area = [];
		
		if ~isfield(Saved_Data_Profiles, ['Loadtype_',Active_LoadType])
			Saved_Data_Profiles.(['Loadtype_',Active_LoadType])= [];
		end
		
		[tick_y_Positions, tick_y_Labels] = get_tick(...
			Option_Plot_y_min_Value,...
			Option_Plot_y_step_Value,...
			Option_Plot_y_max_Value,...
			Option_Plot_y_Label_Step);
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	for i_s = 1 : size(Active_Scenarios,1)
		if ~isfield(Saved_Data_Profiles.(['Loadtype_',Active_LoadType]), ['Saved_',num2str(Active_Scenarios{i_s,1})])
			Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]) = [];
		end
		Data_Input = [];
		for i_t = 1 : size(Active_Datatype,1)
			if ~isfield(Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]),Active_Datatype{i_t,2})
				Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2}) = [];
			else
				continue;
			end
			if isempty(Data_Input)
				Data_Input = Saved_Data_Input.(['Saved_',num2str(i_d)]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).Load_Infeed_Data;
			end
			Data = [];
			for i_p = 1 : Settings_Number_Profiles
				Data = [Data, Data_Input.(['Set_',num2str(i_p)]).(Active_LoadType).(Active_Datatype{i_t,2})]; %#ok<AGROW>
			end
			% from W to kW
			Data = Data ./ 1000;
			% get the single appliances profiles
			Data_Singlephase = [];
			Data_Stored = Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2});
			num_single_profiles = size(Data, 2)/ 6;
			for i_sp = 1 : num_single_profiles
				Data_Sing = sum(Data(:,1+(i_sp-1)*6:2:(i_sp)*6),2);
				Data_Singlephase = [Data_Singlephase, Data_Sing]; %#ok<AGROW>
			end
			Data_Stored = [Data_Stored, Data_Singlephase]; %#ok<AGROW>
			Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2}) = Data_Stored;
		end
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d >= Saved_Data_Input.Number_Datasets
		% Timelines
		for i_t = 1 : size(Active_Datatype,1)
			fig_profilesummary.(Active_Datatype{i_t,2}) = set_up_singleplot(Option_Plot_Size);
			Labels_Scenarios = {};
			Labels_Scen_Style = [];
			for i_s = 1 : size(Active_Scenarios,1)
				Data_Stored = Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2});
				Data_Plot_Mean = mean(Data_Stored,2);
				% excluding all zero profiles (no infeed):
				num_idx_nonzero_profiles = sum(Data_Stored)>0;
				Data_Plot_Min  = min(Data_Stored(:,num_idx_nonzero_profiles),[],2);
				Data_Plot_Max  = max(Data_Stored,[],2);
				% Plot mean
				figure(fig_profilesummary.(Active_Datatype{i_t,2}));
				if isempty(Data_Plot_Mean)
					continue
				end
				f_l = plot(Data_Plot_Mean);
				f_l.Color = Active_Scenarios{i_s,3} / 256;
				f_l.LineStyle = '-';
				f_l.LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Seasons 
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_l.LineStyle = ':';
							f_l.LineWidth = Option_Default_Line_Width;
						case 'Winter'
							f_l.LineStyle = '-';
							f_l.LineWidth = Option_Default_Line_Width;
					end
				end
				drawnow;
				hold on;
				% get the data for the legend:
				if ~any(strcmpi(Labels_Scenarios, Active_Scenarios{i_s,5}))
					Labels_Scenarios{end+1} = Active_Scenarios{i_s,5}; %#ok<SAGROW>
					f_l = plot(nan, nan);	                        % make an invisible line for legend
					f_l.Color = Active_Scenarios{i_s,3} / 256; % set color of invisible line
					f_l.LineStyle = Active_Scenarios{i_s,4}; % set linestyle of invisible line
					f_l.LineWidth = Option_Default_Line_Width;
					Labels_Scen_Style(end+1) = f_l; %#ok<SAGROW>
				end
				if Option_Show_Min_Max
					if size(Active_Scenarios,1) <= 1 
						% fill the area between min and max:
						f_inBetweenRegionX = [1:length(Data_Plot_Max), length(Data_Plot_Min):-1:1];
						f_inBetweenRegionY = [Data_Plot_Max', fliplr(Data_Plot_Min')];
						f_f = fill(f_inBetweenRegionX, f_inBetweenRegionY, 'g');
						f_f.FaceColor = Active_Scenarios{i_s,3} / 256;
						f_f.FaceAlpha = 0.25;
						f_f.LineStyle = 'none';
					end
					% Plot max
					f_l = plot(Data_Plot_Max);
					f_l.Color = Active_Scenarios{i_s,3} / 256;
					f_l.LineStyle = '-.';
					f_l.LineWidth = Option_Default_Line_Width;
					drawnow;
					%plot min
					f_l = plot(Data_Plot_Min);
					f_l.Color = Active_Scenarios{i_s,3} / 256;
					f_l.LineStyle = ':';
					f_l.LineWidth = Option_Default_Line_Width;
					drawnow;
				end
			end
			
			% Disable y-label and legend in subsequent plots
			if (strcmp(Option_Plot_Size, 'compact') && i_t >= 2)
				Labels_Y_Direction = [];
				Option_Show_Legend = 0;
			else
				f_max_area = [];
			end
			
			% Format the plot:
			f_ax = gca;
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
				f_ax.YAxis.TickValues   = tick_y_Positions;
				f_ax.YAxis.TickLabels   = tick_y_Labels;
			end
			% Legend
			if Option_Show_Legend
				if Option_Show_Min_Max
					[Labels_Scenarios,Labels_Scen_Style] =...
						add_mean_min_max_entry_to_legend(fig_profilesummary.(Active_Datatype{i_t,2}),...
						Labels_Scenarios, Labels_Scen_Style);
				end
				if Option_Distinct_Seasons
					[Labels_Scenarios,Labels_Scen_Style] =...
						add_season_entry_to_legend(fig_profilesummary.(Active_Datatype{i_t,2}),...
						Option_Default_Line_Width, Labels_Scenarios, Labels_Scen_Style, 'line');
				end
				legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
			end
			% Configuration
			set_default_plot_properties(f_ax);
 			f_max_area = set_single_plot_properties(f_ax, ...
				[Labels_Title,Active_Datatype{i_t,3}],...
				[],...
				Labels_Y_Direction,...
				Option_Show_Title,...
				f_max_area);
			% adjust legend properties a little bit for this kind of graph
			if Option_Show_Legend
				f_lg = get(f_ax, 'Legend');
				f_lg.ItemTokenSize = [17, 6];
			end
			hold off
		end
	end
end

clear Active_* Data* f_* i_* Labels_* num_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot histogramm summary figures 
% = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
% Option_Active_Scenarios = 1:10; % All
Option_Active_Scenarios = [5,6];
% Option_Active_Scenarios = 1:2:10; % Winter
% Option_Active_Scenarios = 2;
%- - - - - - - - - - - - - - - - - -
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
% Option_Type_Data = [2,5,6]; % 2 ='Mean', 3 ='min', 4 ='max', 5 ='5%q', 6='95%q' 
% Option_Type_Data = [2,3,4]; % 2 ='Mean', 3 ='min', 4 ='max', 5 ='5%q', 6='95%q' 
Option_Type_Data = 2;
%- - - - - - - - - - - - - - - - - -
Option_Show_Title         = 0; % 1 = Show Plot Title
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles
Option_Default_Line_Width = 1.5;
Option_Show_Legend        = 1;
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Number_Bins      =  24;
Option_Bar_x_max_Value  =  12; % kW (-1 ... autoscale)
Option_Bar_x_min_Value  =   0; % kW
Option_Bar_x_Label_Step =   2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_logScale   =   0;
Option_Bar_y_logLimits  = [-3, 2]; % 10^x
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_max_Value  =  -1; % 'kW' (-1 ... autoscale)
Option_Bar_y_min_Value  =   0; % 'kW'
Option_Bar_y_step_Value =  10; % 'kW'
Option_Bar_y_Label_Step =   2; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = 'rel. H�ufigkeit [%]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_Input.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		Active_Datatype = Settings_Datatype(Option_Type_Data,:);
		
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Bar_y_min_Value,Option_Bar_y_step_Value, Option_Bar_y_max_Value, Option_Bar_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Bar_x_min_Value,Option_Bar_x_step_Value, Option_Bar_x_max_Value, Option_Bar_x_Label_Step);
		
		f_max_area = [];
		
		if ~isfield(Saved_Data_Profiles, ['Loadtype_',Active_LoadType])
			Saved_Data_Profiles.(['Loadtype_',Active_LoadType])= [];
		end
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	for i_s = 1 : size(Active_Scenarios,1)
		if ~isfield(Saved_Data_Profiles.(['Loadtype_',Active_LoadType]), ['Saved_',num2str(Active_Scenarios{i_s,1})])
			Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]) = [];
		end
		Data_Input = [];
		for i_t = 1 : size(Active_Datatype,1)
			if ~isfield(Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]),Active_Datatype{i_t,2})
				Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2}) = [];
			else
				continue;
			end
			if isempty(Data_Input)
				Data_Input = Saved_Data_Input.(['Saved_',num2str(i_d)]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).Load_Infeed_Data;
			end
			Data = [];
			for i_p = 1 : Settings_Number_Profiles
				Data = [Data, Data_Input.(['Set_',num2str(i_p)]).(Active_LoadType).(Active_Datatype{i_t,2})]; %#ok<AGROW>
			end
			% from W to kW
			Data = Data ./ 1000;
			% get the single appliances profiles
			Data_Singlephase = [];
			Data_Stored = Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2});
			num_single_profiles = size(Data, 2)/ 6;
			for i_sp = 1 : num_single_profiles
				Data_Sing = sum(Data(:,1+(i_sp-1)*6:2:(i_sp)*6),2);
				Data_Singlephase = [Data_Singlephase, Data_Sing]; %#ok<AGROW>
			end
			Data_Stored = [Data_Stored, Data_Singlephase]; %#ok<AGROW>
			Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2}) = Data_Stored;
		end
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d >= Saved_Data_Input.Number_Datasets
		for i_t = 1 : size(Active_Datatype,1)
			fig_histogrammsummary.(Active_Datatype{i_t,2}) = set_up_singleplot(Option_Plot_Size);
			Labels_Scenarios = {};
			Labels_Scen_Style = [];
			for i_s = 1 : size(Active_Scenarios,1)
				Data_Stored = Saved_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).(Active_Datatype{i_t,2});
				if isempty(Data_Stored)
					continue;
				end
				Data = reshape(Data_Stored,[],1);
				if Option_Bar_x_max_Value < 1
					f_x_min_Value = min(Data);
					f_x_max_Value = ceil(max(Data));
				else
					f_x_min_Value = Option_Bar_x_min_Value;
					f_x_max_Value = Option_Bar_x_max_Value;
				end
				Hist_binEdges = linspace(f_x_min_Value,f_x_max_Value,Option_Number_Bins+1);
				Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2; % center
				[~,Hist_binIdx] = histc(Data,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
				% calculate the number of elements in bins
				Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
				switch Active_LoadType
					case 'Solar'
						% In case of solar, don't plot the "0" bin, becaus this
						% is almost 50% of the data (nigthtime!)
						f_b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
					otherwise
						f_b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
				end
				f_b.EdgeColor = Active_Scenarios{i_s,3}/256;
				f_b.FaceColor = Active_Scenarios{i_s,3}/256;
				f_b.FaceAlpha = 0.5;
				f_b.LineStyle = Active_Scenarios{i_s,4}; 
				f_b.LineWidth = Option_Default_Line_Width;
				if Option_Distinct_Seasons 
					switch Active_Scenarios{i_s, 6}
						case 'Sommer'
							f_b.LineStyle = ':';
							f_b.LineWidth = Option_Default_Line_Width;
						case 'Winter'
							f_b.LineStyle = '-';
							f_b.LineWidth = Option_Default_Line_Width;
					end
				end
				drawnow;
				hold on;
				% get the data for the legend:
				if ~any(strcmpi(Labels_Scenarios, Active_Scenarios{i_s,5}))
					Labels_Scenarios{end+1} = Active_Scenarios{i_s,5}; %#ok<SAGROW>
					f_b = bar(nan, nan);	                        % make an invisible line for legend
					f_b.EdgeColor = Active_Scenarios{i_s,3}/256;
					f_b.FaceColor = Active_Scenarios{i_s,3}/256;
					f_b.FaceAlpha = 0.5;
					f_b.LineStyle = Active_Scenarios{i_s,4}; % set linestyle of invisible line
					f_b.LineWidth = Option_Default_Line_Width;
					Labels_Scen_Style(end+1) = f_b; %#ok<SAGROW>
				end
			end
			
			% Disable y-label and legend in subsequent plots
			if (strcmp(Option_Plot_Size, 'compact') && i_t >= 2)
				Labels_Y_Direction = [];
				Option_Show_Legend = 0;
			else
				f_max_area = [];
			end
			% Format the plot:
			f_ax = gca;
			% X Axis
			if Option_Bar_x_max_Value > 0
				set_tick_x_histogramms(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins,Option_Bar_x_Label_Step, f_ax)
			end
			% Y Axis
			if Option_Bar_y_logScale
				f_ax.YAxis.Scale = 'log';
				f_ax.YAxis.Limits  = 10.^Option_Bar_y_logLimits;
				f_ax.YAxis.TickValues = 10.^(Option_Bar_y_logLimits(1):Option_Bar_y_logLimits(2));
			end
			if Option_Bar_y_max_Value > 0 && ~Option_Bar_y_logScale
				f_ax.YAxis.Limits  = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
				f_ax.YAxis.TickValues   = tick_y_Positions;
				f_ax.YAxis.TickLabels   = tick_y_Labels;
			end
			% Legend
			if Option_Show_Legend
				if Option_Distinct_Seasons
					[Labels_Scenarios,Labels_Scen_Style] =...
						add_season_entry_to_legend(fig_histogrammsummary.(Active_Datatype{i_t,2}),...
						Option_Default_Line_Width,Labels_Scenarios, Labels_Scen_Style, 'bar');
				end
				legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
			end
			% Configuration
			set_default_plot_properties(f_ax);
 			f_max_area = set_single_plot_properties(f_ax, ...
				[Labels_Title,Active_Datatype{i_t,3}],...
				Labels_X_Direction,...
				Labels_Y_Direction,...
				Option_Show_Title,...
				f_max_area);
			% adjust legend properties a little bit for this kind of graph
			if Option_Show_Legend
				f_lg = get(f_ax, 'Legend');
				f_lg.ItemTokenSize = [17, 6];
			end
			hold off
		end
	end
end

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot the single profiles for a specific scenario
% = = = = = = = = = = = = = = = = = 
Option_Active_Scenarios = 8; % Select only one scenario!
%- - - - - - - - - - - - - - - - - - 
Option_Type_Load        = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - 
% y-axis Settings (Option_Plot_max_Value = -1 ... autoscale)
Option_Plot_max_Value   = 12; % kW
Option_Plot_step_Value  =  2; % kW
Option_Plot_Label_Step  =  2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      0; % 1 = Show supplot titles
Option_Plot_Size =  'compact'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Einzelprofile �ber Szenario "',Settings_Scenario{Option_Active_Scenarios,5},...
% 	'" f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
% Labels_X_Direction = 'Datensets';
Labels_Y_Direction = 'Leistung [kW]';
Labels_X_Direction = []; % No label for Word output
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		
		fig_infeedsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction,...
			Labels_Y_Direction, Option_Plot_Size);
		
		% Set up the needed ticks:
		[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
		[tick_y_Positions, tick_y_Labels] = get_tick(0,Option_Plot_step_Value, Option_Plot_max_Value, Option_Plot_Label_Step);
	end
	figure(fig_infeedsingle); nexttile;
	for j = 1 : size(Active_Scenarios,1)
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data_Mean_Shuffled = [];
		for i_sp = 1 : Settings_Number_Profiles
			Data_Mean_Shuffled = [Data_Mean_Shuffled;...
				Data_Input.(['Set_',num2str(i_sp)]).(Active_LoadType).Data_Mean];  %#ok<AGROW>
		end
		% from W to kW
		Data_Mean_Shuffled = Data_Mean_Shuffled ./ 1000;
		% remove zero profiles
		Data_Mean_Shuffled = Data_Mean_Shuffled(:,sum(Data_Mean_Shuffled)>0);
		% add up all phase data:
		Data_Mean_Shuffled = Data_Mean_Shuffled(:,1:3:end)+Data_Mean_Shuffled(:,2:3:end)+Data_Mean_Shuffled(:,3:3:end);
		figure(fig_infeedsingle); plot(Data_Mean_Shuffled);
		drawnow;
% 		if j <=1
% 			figure(fig_infeedsingle); hold on;
% 			legend([num2str(size(Data,2)),' aktive Profile']);
% 		end
	end
	% Format Diagrams:
	figure(fig_infeedsingle); 
	f_ax = gca;
	if Option_Show_SubTitle
		f_ax.Title.String = ['Profilsatz ',num2str(i)]; 
	end
	% X Axis
	f_ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	f_ax.XAxis.TickValues   = tick_x_Positions;
	f_ax.XAxis.TickLabels   = tick_x_Labels;
	% Y Axis
	if Option_Plot_max_Value > 0
		f_ax.YAxis.Limits  = [0 Option_Plot_max_Value];
		f_ax.YAxis.TickValues   = tick_y_Positions;
		f_ax.YAxis.TickLabels   = tick_y_Labels;
	end
	set_default_plot_properties(f_ax);
	figure(fig_infeedsingle); hold off;
end

clear Option_* Active_* tick_* Data* i j k f_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms over the profile sums over different scenarios
% = = = = = = = = = = = = = = = = = 
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - 
Option_Number_Bins             = 75;
Option_Bar_x_max_Value  = 75; %kW
Option_Bar_x_min_Value  =  0; %kW
Option_Bar_x_step_Value =  5;
Option_Bar_x_Label_Step =  2;
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_max_Value  = 12; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =  0; % '%'
Option_Bar_y_step_Value =  2; % '%'
Option_Bar_y_Label_Step =  2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      0; % 1 = Show subplot titles
Option_Plot_Size =   'compact'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Histogramme �ber Szenarien f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		% Prepare everything:
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Bar_y_min_Value,Option_Bar_y_step_Value, Option_Bar_y_max_Value, Option_Bar_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Bar_x_min_Value,Option_Bar_x_step_Value, Option_Bar_x_max_Value, Option_Bar_x_Label_Step);
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		
		fig_histogrammsummary = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_Plot_Size);
		
	end
	figure(fig_histogrammsummary); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data_Mean_Shuffled = [];
		for i_sp = 1 : Settings_Number_Profiles
			Data_Mean_Shuffled = [Data_Mean_Shuffled;...
				Data_Input.(['Set_',num2str(i_sp)]).(Active_LoadType).Data_Mean];  %#ok<AGROW>
		end
		% from W to kW
		Data_Mean_Shuffled = Data_Mean_Shuffled ./ 1000;
		% Sum all single appliance profiles up
		Data_Mean_Shuffled = sum(Data_Mean_Shuffled,2);
		if (~isempty(Data_Mean_Shuffled))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			
			% histogramms of sum
			Hist_binEdges = linspace(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins+1);
			Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2;     % center
			[~,Hist_binIdx] = histc(Data_Mean_Shuffled,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC> % histc
			% calculate the number of elements in bins
			Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
			figure(fig_histogrammsummary);
			switch Active_LoadType
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					f_b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					f_b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(f_b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(f_b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammsummary); 
	f_ax = gca;
	% General:
	if Option_Show_SubTitle
		f_ax.Title.String = ['Profilsatz ',num2str(i)]; 
	end
	% X Axis
	if Option_Bar_x_max_Value > 0
		f_ax.XAxis.Limits       = [Option_Bar_x_min_Value, Option_Bar_x_max_Value];
		f_ax.XAxis.TickValues   = tick_x_Positions;
		f_ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Bar_y_max_Value > 0
		f_ax.YAxis.Limits       = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
		f_ax.YAxis.TickValues   = tick_y_Positions;
		f_ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(f_ax);
	figure(fig_histogrammsummary); hold off;
end

clear Option_* Active_* Data* Labels_* Hist_* i j k f_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms over the single profiles over different scenarios
% = = = = = = = = = = = = = = = = = 
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - 
Option_Number_Bins      = 60;
Option_Bar_x_max_Value  = 12; %kW (-1 ... autoscale)
Option_Bar_x_min_Value  =  0; %kW
Option_Bar_x_step_Value =  1; %kW
Option_Bar_x_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_max_Value  = 20; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =  0; % '%'
Option_Bar_y_step_Value =  5; % '%'
Option_Bar_y_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      0; % 1 = Show subplot titles
Option_Plot_Size =   'compact'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Histogramme �ber die Einzelprofile f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Bar_y_min_Value,Option_Bar_y_step_Value, Option_Bar_y_max_Value, Option_Bar_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Bar_x_min_Value,Option_Bar_x_step_Value, Option_Bar_x_max_Value, Option_Bar_x_Label_Step);
		
		fig_histogrammsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_Plot_Size);
	end
	figure(fig_histogrammsingle); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data_Mean_Shuffled = [];
		for i_sp = 1 : Settings_Number_Profiles
			Data_Mean_Shuffled = [Data_Mean_Shuffled;...
				Data_Input.(['Set_',num2str(i_sp)]).(Active_LoadType).Data_Mean];  %#ok<AGROW>
		end
		% from W to kW
		Data_Mean_Shuffled = Data_Mean_Shuffled ./ 1000;
		Data_Singlephase = [];
		for m = 1 : size(Data_Mean_Shuffled, 2)/ 6
			Data_Sing = Data_Mean_Shuffled(:,1+(m-1)*6:6+(m-1)*6);
			Data_Singlephase = [Data_Singlephase; Data_Sing]; %#ok<AGROW>
		end
		Data_Singlephase = sum(Data_Singlephase,2);
		if (~isempty(Data_Mean_Shuffled))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			% histogramms of single appliances
			Hist_binEdges = linspace(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins+1);
			Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2; % center
			[~,Hist_binIdx] = histc(Data_Singlephase,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
			% calculate the number of elements in bins
			Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
			figure(fig_histogrammsingle);
			switch Active_LoadType
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					f_b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					f_b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(f_b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(f_b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammsingle); 
	f_ax = gca;
	% General:
	if Option_Show_SubTitle
		f_ax.Title.String = ['Profilsatz ',num2str(i)]; 
	end
	% X Axis
	if Option_Bar_x_max_Value > 0
		f_ax.XAxis.Limits       = [Option_Bar_x_min_Value, Option_Bar_x_max_Value];
		f_ax.XAxis.TickValues   = tick_x_Positions;
		f_ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Bar_y_max_Value > 0
		f_ax.YAxis.Limits  = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
		f_ax.YAxis.TickValues   = tick_y_Positions;
		f_ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(f_ax);
	figure(fig_histogrammsingle); hold off;
end

clear Active_* Option_* f_* Data* Hist_* i j k m Labels_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms with adding up profile number (sum over appliance profiles)
% = = = = = = = = = = = = = = = = = 
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - -  
Option_Number_Bins             = 75;
Option_Bar_x_max_Value  = 75; %kW (-1 ... autoscale)
Option_Bar_x_min_Value  =  0; %kW
Option_Bar_x_step_Value =  5; %kW
Option_Bar_x_Label_Step =  2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_max_Value  = 12; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =  0; % '%'
Option_Bar_y_step_Value =  2; % '%'
Option_Bar_y_Label_Step =  2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      1; % 1 = Show subplot titles
Option_Plot_Size =   'medium'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Entwicklung der Histogramme mit anwachsender Profilzahl f�r Datensatz "',...
% 	Settings_Datasets{Option_Type_Load,3},'" (Summe)'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
Labels_Title = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Bar_y_min_Value,Option_Bar_y_step_Value, Option_Bar_y_max_Value, Option_Bar_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Bar_x_min_Value,Option_Bar_x_step_Value, Option_Bar_x_max_Value, Option_Bar_x_Label_Step);
		
		fig_histogrammdevsummary = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_Plot_Size);
		
		Data_Dev_Hist = [];
	end
	
	figure(fig_histogrammdevsummary); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		% prepare a structure to keep the scenario data
		if (~isfield(Data_Dev_Hist, ['Saved_',num2str(Active_Scenarios{j,1})]))
			Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})]) = [];
		end
		% load the raw data
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data_Mean_Shuffled = [];
		for i_sp = 1 : Settings_Number_Profiles
			Data_Mean_Shuffled = [Data_Mean_Shuffled; Data_Input.(['Set_',num2str(i_sp)]).(Active_LoadType).Data_Mean]; %#ok<AGROW>
		end
		% from W to kW
		Data_Mean_Shuffled = Data_Mean_Shuffled ./ 1000;
		if (~isempty(Data_Mean_Shuffled))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			% combine the profiles
			Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})]) = ...
				[Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})]); sum(Data_Mean_Shuffled,2)];
			% histogramms of development of profile numbers:
			if Option_Bar_x_max_Value > 0
				Hist_binEdges = linspace(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins+1);
			else
				Hist_x_max_Value = max(Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})]));
				Hist_x_min_Value = min(Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})]));
				Hist_binEdges = linspace(Hist_x_min_Value,Hist_x_max_Value,Option_Number_Bins+1);
			end
			Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2; % center
			[~,Hist_binIdx] = histc(Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})])...
				,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
			% calculate the number of elements in bins
			Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
			figure(fig_histogrammdevsummary);
			switch Active_LoadType
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					f_b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					f_b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(f_b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(f_b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammdevsummary); 
	f_ax = gca;
	% General:
	if Option_Show_SubTitle
		f_ax.Title.String = [num2str(i*Settings_Number_Profiles),' Profile'];
	end
	% X Axis
	if Option_Bar_x_max_Value > 0
		f_ax.XAxis.Limits       = [Option_Bar_x_min_Value, Option_Bar_x_max_Value];
		f_ax.XAxis.TickValues   = tick_x_Positions;
		f_ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Bar_y_max_Value > 0
		f_ax.YAxis.Limits  = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
		f_ax.YAxis.TickValues   = tick_y_Positions;
		f_ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(f_ax);
	figure(fig_histogrammdevsummary); hold off;
end

clear Active_* f_* Data* Hist_* i j k Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms with adding up profile number (single appliance profiles)
% = = = = = = = = = = = = = = = = = 
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - -  
Option_Number_Bins             = 60;
Option_Bar_x_max_Value  = 12; %kW (-1 ... autoscale)
Option_Bar_x_min_Value  =  0; %kW
Option_Bar_x_step_Value =  1; %kW
Option_Bar_x_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_max_Value  = 20; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =  0; % '%'
Option_Bar_y_step_Value =  5; % '%'
Option_Bar_y_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      1; % 1 = Show subplot titles
Option_Plot_Size =   'medium'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Entwicklung der Histogramme mit anwachsender Profilzahl f�r Datensatz "',...
% 	Settings_Datasets{Option_Type_Load,3},'" (Einzelprofile)'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
Labels_Title = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Bar_y_min_Value,Option_Bar_y_step_Value, Option_Bar_y_max_Value, Option_Bar_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Bar_x_min_Value,Option_Bar_x_step_Value, Option_Bar_x_max_Value, Option_Bar_x_Label_Step);
		
		fig_histogrammdevsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_Plot_Size);
		
		Data_Dev_Hist_Single = [];
	end
	
	figure(fig_histogrammdevsingle); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		% prepare a structure to keep the scenario data
		if (~isfield(Data_Dev_Hist_Single, ['Saved_',num2str(Active_Scenarios{j,1})]))
			Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})]) = [];
		end
		% load the raw data
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data_Mean_Shuffled = [];
		for i_sp = 1 : Settings_Number_Profiles
			Data_Mean_Shuffled = [Data_Mean_Shuffled; Data_Input.(['Set_',num2str(i_sp)]).(Active_LoadType).Data_Mean]; %#ok<AGROW>
		end
		% from W to kW
		Data_Mean_Shuffled = Data_Mean_Shuffled ./ 1000;
		if (~isempty(Data_Mean_Shuffled))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			% combine the profiles
			Data_Singlephase = [];
			for i_sp = 1 : size(Data_Mean_Shuffled, 2)/ 6
				Data_Sing = Data_Mean_Shuffled(:,1+(i_sp-1)*6:6+(i_sp-1)*6);
				Data_Singlephase = [Data_Singlephase; Data_Sing]; %#ok<AGROW>
			end
			Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})]) = ...
				[Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})]); sum(Data_Singlephase,2)];
			% histogramms of development of profile numbers:
			if Option_Bar_x_max_Value > 0
				Hist_binEdges = linspace(Option_Bar_x_min_Value,Option_Bar_x_max_Value,Option_Number_Bins+1);
			else
				Hist_x_max_Value = max(Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})]));
				Hist_x_min_Value = min(Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})]));
				Hist_binEdges = linspace(Hist_x_min_Value,Hist_x_max_Value,Option_Number_Bins+1);
			end
			Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2; % center
			[~,Hist_binIdx] = histc(Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})])...
				,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
			% calculate the number of elements in bins
			Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
			figure(fig_histogrammdevsingle);
			switch Active_LoadType
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					f_b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					f_b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(f_b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(f_b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammdevsingle); 
	f_ax = gca;
	% General:
	if (Option_Show_SubTitle)
		f_ax.Title.String = [num2str(i*Settings_Number_Profiles),' Profile'];
	end
	% X Axis
	if Option_Bar_x_max_Value > 0
		f_ax.XAxis.Limits  = [Option_Bar_x_min_Value, Option_Bar_x_max_Value];
		f_ax.XAxis.TickValues   = tick_x_Positions;
		f_ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Bar_y_max_Value > 0
		f_ax.YAxis.Limits  = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
		f_ax.YAxis.TickValues   = tick_y_Positions;
		f_ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(f_ax);
	figure(fig_histogrammdevsingle); hold off;
end

clear Active_* f_* Data* Hist_* i j k Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Show development of the RMS between the single runs
% = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6, 8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - -
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
Option_Type_Data = 2; % 2 = 'Mean', 3 ='min', 4 ='max', 5 ='5%q', 6='95%q' 
%- - - - - - - - - - - - - - - - - -
Option_Profile_Shuffles = 10;
%- - - - - - - - - - - - - - - - - -
Option_Show_Title =        0; % 1 = Show Plot Title
% = = = = = = = = = = = = = = = = =
Labels_Title = ['Entwicklung des RMS zwischen den einzelnen Profilen mit ',...
 	num2str(Option_Profile_Shuffles),' Permutationen'];
Labels_X_Direction = 'Profile';
Labels_Y_Direction = 'RMS [%]';
% Labels_Title = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i_d = 1 : Saved_Data_Input.Number_Datasets
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%     Preprocessing...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	if i_d <= 1
		Data_Mean_Profile = [];
		Data_Min_Profile = [];
		Data_Max_Profile = [];
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		Active_Datatype = Settings_Datatype{Option_Type_Data,2};
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Prepare Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	for i_s = 1 : size(Active_Scenarios,1)
		if ~isfield(Data_Mean_Profile, ['Saved_',num2str(Active_Scenarios{i_s,1})])
			Data_Mean_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]) = [];
			Data_Min_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]) = [];
			Data_Max_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]) = [];
		end
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i_d)]).(['Saved_',num2str(Active_Scenarios{i_s,1})]).Load_Infeed_Data;
		Data = [];
		for i_p = 1 : Settings_Number_Profiles
			Data = [Data, Data_Input.(['Set_',num2str(i_p)]).(Active_LoadType).(Active_Datatype)]; %#ok<AGROW>
		end
		% from W to kW
		Data = Data ./ 1000;
		% get the single appliances profiles
		Data_Singlephase = [];
		num_single_profiles = size(Data, 2)/ 6;
		for i_sp = 1 : num_single_profiles
			Data_Sing = sum(Data(:,1+(i_sp-1)*6:2:(i_sp)*6),2);
			Data_Singlephase = [Data_Singlephase, Data_Sing]; %#ok<AGROW>
		end
		% get the mean profile
		num_profiles_per_dataset = size(Data_Singlephase, 2)/Settings_Number_Profiles;
		for i_sp = 1 : Settings_Number_Profiles
			Data_Sing = sum(Data_Singlephase(:,1+(i_sp-1)*num_profiles_per_dataset:i_sp*num_profiles_per_dataset),2)/num_profiles_per_dataset;
			Data_Mean_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]) =...
				[Data_Mean_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]), Data_Sing];
			Data_Sing = quantile(Data_Singlephase(:,1+(i_sp-1)*num_profiles_per_dataset:i_sp*num_profiles_per_dataset),0.05,2);
			Data_Min_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]) =...
				[Data_Min_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]), Data_Sing];
			Data_Sing = quantile(Data_Singlephase(:,1+(i_sp-1)*num_profiles_per_dataset:i_sp*num_profiles_per_dataset),0.95,2);
			Data_Max_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]) =...
				[Data_Max_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]), Data_Sing];
		end
	end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     Plotting Data...
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if i_d >= Saved_Data_Input.Number_Datasets
		fig_profiledevelopment = set_up_singleplot();
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
		for i_s = 1 : size(Active_Scenarios,1)
			disp(['Preparing Szenario "',Active_Scenarios{i_s,2},'"']);
			Data_Mean_Start = Data_Mean_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]);
			Data_Min_Start = Data_Min_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]);
			Data_Max_Start = Data_Max_Profile.(['Saved_',num2str(Active_Scenarios{i_s,1})]);
			Data_Mean = zeros([size(Data_Mean_Start),Option_Profile_Shuffles]);
			Data_Min = zeros([size(Data_Min_Start),Option_Profile_Shuffles]);
			Data_Max = zeros([size(Data_Max_Start),Option_Profile_Shuffles]);
			for i_rs = 1 : Option_Profile_Shuffles
				if mod(i_rs,Option_Profile_Shuffles/40) == 0
					disp(['   ',num2str(i_rs*100/Option_Profile_Shuffles),'% finished.']);
				end
				num_shuffle_idx = randperm(size(Data_Mean_Start,2));
				Data_Mean_Shuffled = Data_Mean_Start(:,num_shuffle_idx);
				Data_Min_Shuffled = Data_Min_Start(:,num_shuffle_idx);
				Data_Max_Shuffled = Data_Max_Start(:,num_shuffle_idx);
				for i_sp = 1 : size(Data_Mean_Start,2)
					Data_Mean_Sing = Data_Mean_Shuffled(:,i_sp);
					Data_Min_Sing = Data_Min_Shuffled(:,i_sp);
					Data_Max_Sing = Data_Max_Shuffled(:,i_sp);
					if i_sp <= 1
						Data_Mean(:,i_sp,i_rs) = Data_Mean_Sing;
						Data_Min(:,i_sp,i_rs) = Data_Min_Sing;
						Data_Max(:,i_sp,i_rs) = Data_Max_Sing;
					else
						Data_Mean(:,i_sp,i_rs) = mean([Data_Mean(:,1:i_sp-1,i_rs),Data_Mean_Sing],2);
						Data_Min(:,i_sp,i_rs) = min([Data_Min(:,1:i_sp-1,i_rs),Data_Min_Sing],[],2);
						Data_Max(:,i_sp,i_rs) = max([Data_Max(:,1:i_sp-1,i_rs),Data_Max_Sing],[],2);
					end
				end
			end
			
			Data_Mean_Boundaries = calculate_rms_error(Data_Mean);
			Data_Min_Boundaries = calculate_rms_error(Data_Min);
			Data_Max_Boundaries = calculate_rms_error(Data_Max);
			
			f_l = plot(Data_Mean_Boundaries);
			set(f_l, 'Color', Active_Scenarios{i_s,3}/256);
			set(f_l, 'LineStyle', '-');
			drawnow;
			hold on;
			
			% get the data for the legend:
			Labels_Scenarios{end+1} = Active_Scenarios{i_s,5}; %#ok<SAGROW>
			f_l = plot(nan, nan);	                     % make an invisible line for legend
			set(f_l,...
				'Color', Active_Scenarios{i_s,3}/256,... % set color of invisible line
				'LineStyle', Active_Scenarios{i_s,4});   % set linestyle of invisible line
			Labels_Scen_Style(end+1) = f_l; %#ok<SAGROW>
			
			f_l = plot(Data_Max_Boundaries);
			set(f_l, 'Color', Active_Scenarios{i_s,3}/256);
			set(f_l, 'LineStyle', '-.');
			drawnow;
			f_l = plot(Data_Min_Boundaries);
			set(f_l, 'Color', Active_Scenarios{i_s,3}/256);
			set(f_l, 'LineStyle', ':');
			drawnow;
			if i_s <=1
				hold on;
			end
		end
		
		f_ax = gca;
		f_ax.YAxis.Scale = 'log';
		legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
		set_default_plot_properties(f_ax);
		set_single_plot_properties(f_ax, Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_Show_Title)
	end
end

clear Active_* Data* f_* i_* Labels_* num_* Option_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =