%%= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
clear();
Saved_XLX_Data_Input = [];
Saved_XLX_Data_Profiles = [];
% Add folder with help functions / needed classes to path:
addpath([fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'Additional_Resources']);
%#ok<*UNRCH>
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Paths to source files / Number profiles per Set:
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Path_Data_XLSX = 'C:\Cloudspeicher\OneDrive - Siemens AG\Dissertation\Langfassung\05_Diagramme\';
Settings_Number_Profiles = 50; 
Settings_SheetName = 'Zeitreihen (Aus Analyse)';
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Additional Set Up
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Settings_Scenario = {
% 1      2                                                             3                 4          5                                    6         7 
% ID  ,  Filename                                                    , Color           , LineStyle, Legendstr w.o. Season              , Season  , Weekday  
	 1, '01_Base_scenario_Winter_Workda'                             ,[ 74,126,187]/256, '-'      , 'Basisszenario'                    , 'Winter','Werktag';...
	 2, '02_Base_scenario_Winter_Sunday'                             ,[ 74,126,187]/256, '-'      , 'Basisszenario'                    , 'Winter','Sonntag';...
	 3, '03_Base_scenario_Summer_Workda'                             ,[ 74,126,187]/256, '-'      , 'Basisszenario'                    , 'Sommer','Werktag';...
	 4, '04_Base_scenario_Summer_Sunday'                             ,[ 74,126,187]/256, '-'      , 'Basisszenario'                    , 'Sommer','Sonntag';...
	 5, '05_Low_load_High_infeed_Winter_Workda'                      ,[190, 75, 72]/256, '-'      , 'Schwachlast, hohe Einspeisung'    , 'Winter','Werktag';...
	 6, '06_Low_load_High_infeed_Winter_Sunday'                      ,[190, 75, 72]/256, '-'      , 'Schwachlast, hohe Einspeisung'    , 'Winter','Sonntag';...
	 7, '07_Low_load_High_infeed_Summer_Workda'                      ,[190, 75, 72]/256, '-'      , 'Schwachlast, hohe Einspeisung'    , 'Sommer','Werktag';...
	 8, '08_Low_load_High_infeed_Summer_Sunday'                      ,[190, 75, 72]/256, '-'      , 'Schwachlast, hohe Einspeisung'    , 'Sommer','Sonntag';...
	 9, '09_High_load_Medium_infeed_High_e_mobility_Winter_Workda'   ,[152,185, 84]/256, '-'      , 'Hohe Last, mittlere Einspeisung'  , 'Winter','Werktag';...
	10, '10_High_load_Medium_infeed_High_e_mobility_Winter_Sunday'   ,[152,185, 84]/256, '-'      , 'Hohe Last, mittlere Einspeisung'  , 'Winter','Sonntag';...
	11, '11_High_load_Medium_infeed_High_e_mobility_Summer_Workda'   ,[152,185, 84]/256, '-'      , 'Hohe Last, mittlere Einspeisung'  , 'Sommer','Werktag';...
	12, '12_High_load_Medium_infeed_High_e_mobility_Summer_Sunday'   ,[152,185, 84]/256, '-'      , 'Hohe Last, mittlere Einspeisung'  , 'Sommer','Sonntag';...
	13, '13_Low_load_Higher_infeed_Winter_Workda'                    ,[128,100,162]/256, '-'      , 'Schwachlast, höhere Einspeisung'  , 'Winter','Werktag';...
	14, '14_Low_load_Higher_infeed_Winter_Sunday'                    ,[128,100,162]/256, '-'      , 'Schwachlast, höhere Einspeisung'  , 'Winter','Sonntag';...
	15, '15_Low_load_Higher_infeed_Summer_Workda'                    ,[128,100,162]/256, '-'      , 'Schwachlast, höhere Einspeisung'  , 'Sommer','Werktag';...
	16, '16_Low_load_Higher_infeed_Summer_Sunday'                    ,[128,100,162]/256, '-'      , 'Schwachlast, höhere Einspeisung'  , 'Sommer','Sonntag';...
	17, '17_Higher_load_Medium_infeed_High_e_mobility_Winter_Workda' ,[247,173, 36]/256, '-'      , 'Höhere Last, mittlere Einspeisung', 'Winter','Werktag';...
	18, '18_Higher_load_Medium_infeed_High_e_mobility_Winter_Sunday' ,[247,173, 36]/256, '-'      , 'Höhere Last, mittlere Einspeisung', 'Winter','Sonntag';...
	19, '19_Higher_load_Medium_infeed_High_e_mobility_Summer_Workda' ,[247,173, 36]/256, '-'      , 'Höhere Last, mittlere Einspeisung', 'Sommer','Werktag';...
	20, '20_Higher_load_Medium_infeed_High_e_mobility_Summer_Sunday' ,[247,173, 36]/256, '-'      , 'Höhere Last, mittlere Einspeisung', 'Sommer','Sonntag';...
	};

Settings_Loadtype = {
% 1      2               3                 4
% ID  ,  Data Set ID  ,  Legendstr.        Exceldatei
	 1, 'Households'  , 'Haushaltslast'   ,[];...
	 2, 'Solar'       , 'PV Einspeisung'  ,'MS_Auswertungsexcel_Szenarien_PV.xlsm';...
	 3, 'El_Mobility' , 'Elektromobilität',[];...
	 4, 'LV_Griddata' , 'NS-Netzdaten'    ,[];...
	};
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Laden der Daten
for i_d = 1:size(Settings_Loadtype,1)
	Data_filename = Settings_Loadtype{i_d,4};
	if ~isempty(Data_filename)
		[Data_num,Data_txt] = xlsread([Path_Data_XLSX,filesep,Data_filename],Settings_SheetName);
		Saved_XLX_Data_Input.(['Loadtype_',Settings_Loadtype{i_d,2}]).Data_num = Data_num;
		Saved_XLX_Data_Input.(['Loadtype_',Settings_Loadtype{i_d,2}]).Data_txt = Data_txt;
	end
end

clear Data* i_* 
% = = = = = = = = = = = = = = = = =
%% Plot timeline summary figures 
% = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = 1:2:20; % All, Workdays
% Option_Active_Scenarios = 15; %and 15
%- - - - - - - - - - - - - - - - - -
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - -
Option_Data_Scaling_Factor = 1/213; % Umrechnung P/NS-Netz Baden IST
%- - - - - - - - - - - - - - - - - -
Option_Show_Title         = 0; % 1 = Show Plot Title
Option_Show_Min_Max       = 0; % 1 = Plot also min and max of the profiles    --+
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyle --+-- Only one of them should be 1! 
Option_Default_Line_Width = 1.5;
Option_Show_Legend        = 1; %and 0
Option_Show_Y_Label       = 1; %and 0
Settings_Max_Fig_Area     = [0.1080    0.1118    0.0298    0.0256];
Option_Plot_Size          = 'large'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 144; % x10 minutes (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; % x10 minutes
Option_Plot_x_step_Value =  60; % minutes
Option_Plot_x_Label_Step =   1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Plot_y_max_Value  = 225; % 'kW' (-1 ... autoscale)
Option_Plot_y_min_Value  =   0; % 'kW'
Option_Plot_y_step_Value =  25; % 'kW'
Option_Plot_y_Label_Step =   2; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_Y_Direction = 'Leistung [kW]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figures:
for i_s = 1:numel(Option_Active_Scenarios)
	if i_s <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_Loadtype{Option_Type_Load,2};
		
		Data_Stored = Saved_XLX_Data_Input.(['Loadtype_',Active_LoadType]).Data_num;
		Data_Stored = Data_Stored(:,Option_Active_Scenarios);
		num_timepoints = size(Data_Stored,1)/Settings_Number_Profiles;
		% Reformat Data_Stored to desired format.
		for i_ss = 1:numel(Option_Active_Scenarios)
			if ~isfield(Saved_XLX_Data_Profiles, ['Loadtype_',Active_LoadType])
				Saved_XLX_Data_Profiles.(['Loadtype_',Active_LoadType]) = [];
			end
			if ~isfield(Saved_XLX_Data_Profiles.(['Loadtype_',Active_LoadType]), ['Saved_',num2str(Active_Scenarios{i_ss,1})])
				Data_Scen = reshape(Data_Stored(:,i_ss),num_timepoints,[]);
				Saved_XLX_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_ss,1})]) = Data_Scen;
			end
		end
		
		fig_profilesummary = set_up_singleplot(Option_Plot_Size);
		
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
	end
	
	Data_Stored = Option_Data_Scaling_Factor * ...
		Saved_XLX_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]);
	Data_Plot_Mean = mean(Data_Stored,2);
	% excluding all zero profiles (no infeed):
	num_idx_nonzero_profiles = sum(Data_Stored)>0;
	Data_Plot_Min  = min(Data_Stored(:,num_idx_nonzero_profiles),[],2);
	Data_Plot_Max  = max(Data_Stored,[],2);
	% Plot mean
	figure(fig_profilesummary);
	if isempty(Data_Plot_Mean)
		continue
	end
	f_l = plot(Data_Plot_Mean);
	f_l.Color = Active_Scenarios{i_s,3};
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
		f_l.Color = Active_Scenarios{i_s,3}; % set color of invisible line
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
	
	if i_s >= numel(Option_Active_Scenarios)
		
		if ~Option_Show_Y_Label
			Labels_Y_Direction = [];
			f_max_area         = Settings_Max_Fig_Area;
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
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Plot_y_min_Value,...
				Option_Plot_y_step_Value,...
				Option_Plot_y_max_Value,...
				Option_Plot_y_Label_Step);
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Show_Min_Max
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_mean_min_max_entry_to_legend(fig_profilesummary,...
					Labels_Scenarios, Labels_Scen_Style);
			end
			if Option_Distinct_Seasons
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_profilesummary,...
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

clear Active_* Data* f_* i_* Labels_* num_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =