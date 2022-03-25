%%= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% clear();
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
Settings_XLX_Number_Profiles = 50; 
Settings_SheetName = 'Zeitreihen (Aus Analyse)';
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Additional Set Up
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Settings_XLX_Scenario = {
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
	13, '13_Low_load_Higher_infeed_Winter_Workda'                    ,[128,100,162]/256, '-'      , 'Schwachlast, h�here Einspeisung'  , 'Winter','Werktag';...
	14, '14_Low_load_Higher_infeed_Winter_Sunday'                    ,[128,100,162]/256, '-'      , 'Schwachlast, h�here Einspeisung'  , 'Winter','Sonntag';...
	15, '15_Low_load_Higher_infeed_Summer_Workda'                    ,[128,100,162]/256, '-'      , 'Schwachlast, h�here Einspeisung'  , 'Sommer','Werktag';...
	16, '16_Low_load_Higher_infeed_Summer_Sunday'                    ,[128,100,162]/256, '-'      , 'Schwachlast, h�here Einspeisung'  , 'Sommer','Sonntag';...
	17, '17_Higher_load_Medium_infeed_High_e_mobility_Winter_Workda' ,[247,150, 73]/256, '-'      , 'H�here Last, mittlere Einspeisung', 'Winter','Werktag';...
	18, '18_Higher_load_Medium_infeed_High_e_mobility_Winter_Sunday' ,[247,150, 73]/256, '-'      , 'H�here Last, mittlere Einspeisung', 'Winter','Sonntag';...
	19, '19_Higher_load_Medium_infeed_High_e_mobility_Summer_Workda' ,[247,150, 73]/256, '-'      , 'H�here Last, mittlere Einspeisung', 'Sommer','Werktag';...
	20, '20_Higher_load_Medium_infeed_High_e_mobility_Summer_Sunday' ,[247,150, 73]/256, '-'      , 'H�here Last, mittlere Einspeisung', 'Sommer','Sonntag';...
	};

Settings_XLX_Loadtype = {
% 1      2               3                 4
% ID  ,  Data Set ID  ,  Legendstr.        Exceldatei
	 1, 'Households'  , 'Haushaltslast'   ,[];...
	 2, 'Solar'       , 'PV Einspeisung'  ,'MS_Auswertungsexcel_Szenarien_PV.xlsm';...
	 3, 'El_Mobility' , 'Elektromobilit�t',[];...
	 4, 'LV_Griddata' , 'NS-Netzdaten'    ,[];...
	};
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Laden der Daten
for i_d = 1:size(Settings_XLX_Loadtype,1)
	Data_filename = Settings_XLX_Loadtype{i_d,4};
	if ~isempty(Data_filename)
		[Data_num,Data_txt] = xlsread([Path_Data_XLSX,filesep,Data_filename],Settings_SheetName);
		Saved_XLX_Data_Input.(['Loadtype_',Settings_XLX_Loadtype{i_d,2}]).Data_num = Data_num;
		Saved_XLX_Data_Input.(['Loadtype_',Settings_XLX_Loadtype{i_d,2}]).Data_txt = Data_txt;
	end
end

clear Data* i_* 
% = = = = = = = = = = = = = = = = =
%% Plot timeline summary figures 
% = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 1:2:20; % All, Workdays
Option_Active_Scenarios = 13; %and 15
%- - - - - - - - - - - - - - - - - -
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - -
% Option_Data_Scaling_Factor = 1/213;   % Umrechnung P/NS-Netz Baden IST (laut D5.1)
% Option_Data_Scaling_Factor = 1/175;   % Umrechnung P/NS-Netz Baden IST (siehe \Langfassung\05_Tabellen\Auswertungen_Baden_Zusammenfassung_140605.xlsx)
% Option_Data_Scaling_Factor = 1/26030; % Umrechnung Netzanschluss Baden IST (siehe \Langfassung\05_Tabellen\Auswertungen_Baden_Zusammenfassung_140605.xlsx)
Option_Data_Scaling_Factor = 1.4/26030; % Umrechnung Netzanschluss Baden IST + 40% Fehlerkorrektur Fl�chenfaktor
%- - - - - - - - - - - - - - - - - -
Option_Show_Title         = 0; % 1 = Show Plot Title
Option_Show_Min_Max       = 1; % 1 = Plot also min and max of the profiles    --+
Option_Distinct_Seasons   = 0; % 1 = Plot the season with different linestyle --+-- Only one of them should be 1! 
Option_Show_Zeroprofiles  = 0; % 0 = ignore profiles with only zero values
Option_Default_Line_Width = 1.5;
Option_Show_Legend        = 1; %and 0 
Option_Show_Legend_Detail = 1; % 1 = show 'Min/Max' entries in legend
Option_Show_Legend_Season = 1; % 1 = show 'Summer/Winter' entries in legend
Option_Show_Y_Label       = 1; %and 0 
Settings_Max_Fig_Area     = [0.0918    0.1236    0.0364    0.0294];
Option_Plot_Size          = 'medium'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Plot_x_max_Value  = 144; % x10 minutes (-1 ... autoscale)
Option_Plot_x_min_Value  =   0; % x10 minutes
Option_Plot_x_step_Value =  60; % minutes
Option_Plot_x_Label_Step =   2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Plot_y_max_Value  =   5; % 'kW' (-1 ... autoscale)
Option_Plot_y_min_Value  =   0; % 'kW'
Option_Plot_y_step_Value = 0.5; % 'kW'
Option_Plot_y_Label_Step =   2; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_Y_Direction = 'Leistung [kW]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figures:
for i_s = 1:numel(Option_Active_Scenarios)
	if i_s <= 1
		Active_Scenarios = Settings_XLX_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_XLX_Loadtype{Option_Type_Load,2};
		
		Data_Stored = Saved_XLX_Data_Input.(['Loadtype_',Active_LoadType]).Data_num;
		Data_Stored = Data_Stored(:,Option_Active_Scenarios);
		num_timepoints = size(Data_Stored,1)/Settings_XLX_Number_Profiles;
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
	if (sum(sum(Data_Stored)) == 0) && ~Option_Show_Zeroprofiles
		Data_Stored = [];
	end
	if isempty(Data_Stored)
		continue;
	end
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
			if Option_Show_Min_Max && Option_Show_Legend_Detail
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_mean_min_max_entry_to_legend(fig_profilesummary,...
					Labels_Scenarios, Labels_Scen_Style,[]);
			end
			if Option_Distinct_Seasons && Option_Show_Legend_Season
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

clear Active_* Data* f_* fig_* i_* Labels_* num_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

%% Plot histogramm summary figures 
% = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios    = [1,5,9,13,17];
% Option_Active_Scenarios    = [2,6,10,14,18];
% Option_Active_Scenarios    = [5,9,13,17];
Option_Active_Scenarios = [13,15];
%- - - - - - - - - - - - - - - - - -
Option_Type_Load           = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - -
% Option_Data_Scaling_Factor = 1/213;   % Umrechnung P/NS-Netz Baden IST (laut D5.1)
Option_Data_Scaling_Factor = 1.4/26030; % Umrechnung Netzanschluss Baden IST + 40% Fehlerkorrektur Fl�chenfaktor
%- - - - - - - - - - - - - - - - - -
Option_Distinct_Seasons   = 1; % 1 = Plot the season with different linestyles
Option_Show_Zeroprofiles  = 0; % 0 = ignore profiles with only zero values
Option_Show_Title         = 0; % 1 = Show Plot Title
Option_Show_Legend        = 1;
Option_Show_Legend_Season = 1; % 1 = show 'Summer/Winter' entries in legend
Option_Show_Y_Label       = 1;
Settings_Max_Fig_Area     = [0.1142    0.1242    0.0027    0.0313];
Option_Default_Line_Width = 1.5;
Option_Plot_Size          = 'medium'; % 'compact', 'medium', 'large'
%- - - - - - - - - - - - - - - - - -
Option_Number_Bins      =  50;
Option_Bar_x_max_Value  =   5; % kW (-1 ... autoscale)
Option_Bar_x_min_Value  =   0; % kW
Option_Bar_x_Label_Step =  10; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_logScale   =   1;
Option_Bar_y_logLimits  = [-2, 2]; % 10^x
%- - - - - - - - - - - - - - - - - - 
Option_Bar_y_max_Value  =  30; % '%' (-1 ... autoscale)
Option_Bar_y_min_Value  =   0; % '%'
Option_Bar_y_step_Value =   5; % '%'
Option_Bar_y_Label_Step =   2; % Spacing between label entries
% = = = = = = = = = = = = = = = = =
Labels_Title       = '';
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = 'rel. H�ufigkeit [-]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_s = 1:numel(Option_Active_Scenarios)
	if i_s <= 1
		Active_Scenarios = Settings_XLX_Scenario(Option_Active_Scenarios,:);
		Active_LoadType = Settings_XLX_Loadtype{Option_Type_Load,2};
		
		Data_Stored = Saved_XLX_Data_Input.(['Loadtype_',Active_LoadType]).Data_num;
		Data_Stored = Data_Stored(:,Option_Active_Scenarios);
		num_timepoints = size(Data_Stored,1)/Settings_XLX_Number_Profiles;
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
		
		fig_histogrammsummary = set_up_singleplot(Option_Plot_Size);
		
		Labels_Scenarios = {};
		Labels_Scen_Style = [];
	end
	
	Data_Stored = Option_Data_Scaling_Factor * ...
		Saved_XLX_Data_Profiles.(['Loadtype_',Active_LoadType]).(['Saved_',num2str(Active_Scenarios{i_s,1})]);
	if (sum(sum(Data_Stored)) == 0) && ~Option_Show_Zeroprofiles
		Data_Stored = [];
	end
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
			if Option_Bar_y_logScale
				f_b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			else
				f_b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
			end
		otherwise
			f_b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
	end
	f_b.EdgeColor = Active_Scenarios{i_s,3};
	f_b.FaceColor = Active_Scenarios{i_s,3};
	f_b.FaceAlpha = 0.25;
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
		f_b.EdgeColor = Active_Scenarios{i_s,3};
		f_b.FaceColor = Active_Scenarios{i_s,3};
		f_b.FaceAlpha = 0.25;
		f_b.LineStyle = Active_Scenarios{i_s,4}; % set linestyle of invisible line
		f_b.LineWidth = Option_Default_Line_Width;
		Labels_Scen_Style(end+1) = f_b; %#ok<SAGROW>
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
			[tick_y_Positions, tick_y_Labels] = get_tick(...
				Option_Bar_y_min_Value,...
				Option_Bar_y_step_Value,...
				Option_Bar_y_max_Value,...
				Option_Bar_y_Label_Step,...
				'%');
			f_ax.YAxis.Limits  = [Option_Bar_y_min_Value, Option_Bar_y_max_Value];
			f_ax.YAxis.TickValues   = tick_y_Positions;
			f_ax.YAxis.TickLabels   = tick_y_Labels;
		end
		% Legend
		if Option_Show_Legend
			if Option_Distinct_Seasons && Option_Show_Legend_Season
				[Labels_Scenarios,Labels_Scen_Style] =...
					add_season_entry_to_legend(fig_histogrammsummary,...
					Option_Default_Line_Width,Labels_Scenarios, Labels_Scen_Style, 'bar');
			end
			legend(Labels_Scen_Style, Labels_Scenarios, 'Location','northeast');
		end
		% Configuration
		set_default_plot_properties(f_ax,'axes_on_top');
		f_max_area = set_single_plot_properties(f_ax, ...
			Labels_Title,...
			Labels_X_Direction,...
			Labels_Y_Direction,...
			Option_Show_Title,...
			f_max_area);
		Settings_Max_Fig_Area = f_max_area;
		% adjust legend properties a little bit for this kind of graph
		if Option_Show_Legend
			f_lg = get(f_ax, 'Legend');
			f_lg.ItemTokenSize = [8, 8];
		end
		hold off
	end
end

clear Active_* Data* f_* fig_* i_* Hist_* Labels_* num_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =