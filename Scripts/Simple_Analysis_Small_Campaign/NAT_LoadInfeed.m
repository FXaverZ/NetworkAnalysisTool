%%= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
clear();
Saved_Data_Input = [];
% Add folder with help functions / needed classes to path:
addpath([fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'Additional_Resources']);
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

Settings_Datasets = {
% 1      2               3
% ID  ,  Data Typ ID  ,  Legendstr.	
	 1, 'Households'  , 'Haushaltslast'   ;...
	 2, 'Solar'       , 'PV Einspeisung'  ;...
	 3, 'El_Mobility' , 'Elektromobilität';...
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
% Labels_Title = ['Profilsummen über Szenarien für Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
% Labels_X_Direction = 'Datensets';
Labels_Y_Direction = 'Leistung [kW]';
Labels_X_Direction = []; % No label for Word output
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
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
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Data_Input.(['Set_',num2str(k)]).(Active_Type).Data_Mean]; %#ok<AGROW>
		end
		Data = sum(Data,2);
		% from W to kW
		Data = Data ./ 1000;
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			if Option_Show_Season
				Labels_Scenarios{end} = [Labels_Scenarios{end},' ',Active_Scenarios{j,6}]; %#ok<UNRCH>
			end
		end
		switch Active_Type
			case 'Households'
				Data_num_active = sum(cell2mat(Data_Input.Set_1.Households.Number(:,2)));
				Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
			case 'Solar'
				Data_num_active = size(Data_Input.(['Set_',num2str(k)]).Solar_Plants.Selectable,1)-2;
				if Data_num_active > 0
					Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
				end
			case 'El_Mobility'
				Data_num_active = Data_Input.(['Set_',num2str(k)]).(Active_Type).Number;
				if Data_num_active > 0
					Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
				end
			otherwise
				Data_num_active = 9999;
				Labels_Activity{end+1} = [num2str(Data_num_active),' Akt.']; %#ok<SAGROW>
		end
		figure(fig_infeedsummary); l = plot(Data);
		set(l, 'Color', Active_Scenarios{j,3}/256);
		set(l, 'LineStyle', Active_Scenarios{j,4});
		drawnow;
		if j <=1
			figure(fig_infeedsummary); hold on;
		end
	end
	% Format Diagrams:
	figure(fig_infeedsummary); 
	ax = gca;
	if Option_Show_SubTitle
		ax.Title.String = ['Profilsatz ',num2str(i)]; %#ok<UNRCH>
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','northeast');
	elseif (i == 2) && Option_Show_Activity
		legend(Labels_Activity{:}, 'Location','northeast');
	end
	% X Axis
	ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	ax.XAxis.TickValues   = tick_x_Positions;
	ax.XAxis.TickLabels   = tick_x_Labels;
	% Y Axis
	if Option_Plot_max_Value > 0
		ax.YAxis.Limits  = [0 Option_Plot_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	set_default_plot_properties(ax);
	figure(fig_infeedsummary); hold off;
end

clear Active_* Option_* Labels_* Data* tick_* i j k l ax  
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
% Labels_Title = ['Einzelprofile über Szenario "',Settings_Scenario{Option_Active_Scenarios,5},...
% 	'" für Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
% Labels_X_Direction = 'Datensets';
Labels_Y_Direction = 'Leistung [kW]';
Labels_X_Direction = []; % No label for Word output
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		fig_infeedsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction,...
			Labels_Y_Direction, Option_Plot_Size);
		
		% Set up the needed ticks:
		[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
		[tick_y_Positions, tick_y_Labels] = get_tick(0,Option_Plot_step_Value, Option_Plot_max_Value, Option_Plot_Label_Step);
	end
	figure(fig_infeedsingle); nexttile;
	for j = 1 : size(Active_Scenarios,1)
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Data_Input.(['Set_',num2str(k)]).(Active_Type).Data_Mean];  %#ok<AGROW>
		end	
		% from W to kW
		Data = Data ./ 1000;
		% remove zero profiles
		Data = Data(:,sum(Data)>0);
		% add up all phase data:
		Data = Data(:,1:3:end)+Data(:,2:3:end)+Data(:,3:3:end);
		figure(fig_infeedsingle); plot(Data);
		drawnow;
% 		if j <=1
% 			figure(fig_infeedsingle); hold on;
% 			legend([num2str(size(Data,2)),' aktive Profile']);
% 		end
	end
	% Format Diagrams:
	figure(fig_infeedsingle); 
	ax = gca;
	if Option_Show_SubTitle
		ax.Title.String = ['Profilsatz ',num2str(i)]; %#ok<UNRCH>
	end
	% X Axis
	ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	ax.XAxis.TickValues   = tick_x_Positions;
	ax.XAxis.TickLabels   = tick_x_Labels;
	% Y Axis
	if Option_Plot_max_Value > 0
		ax.YAxis.Limits  = [0 Option_Plot_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	set_default_plot_properties(ax);
	figure(fig_infeedsingle); hold off;
end

clear Option_* Active_* tick_* Data* i j k ax
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
Option_Histogramm_x_max_Value  = 75; %kW
Option_Histogramm_x_min_Value  =  0; %kW
Option_Histogramm_x_step_Value =  5;
Option_Histogramm_x_Label_Step =  2;
%- - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = 12; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  2; % '%'
Option_Histogramm_y_Label_Step =  2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      0; % 1 = Show subplot titles
Option_Plot_Size =   'compact'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Histogramme über Szenarien für Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. Häufigkeit';
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		% Prepare everything:
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Histogramm_y_min_Value,Option_Histogramm_y_step_Value, Option_Histogramm_y_max_Value, Option_Histogramm_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Histogramm_x_min_Value,Option_Histogramm_x_step_Value, Option_Histogramm_x_max_Value, Option_Histogramm_x_Label_Step);
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		fig_histogrammsummary = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_Plot_Size);
		
	end
	figure(fig_histogrammsummary); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Data_Input.(['Set_',num2str(k)]).(Active_Type).Data_Mean];  %#ok<AGROW>
		end	
		% from W to kW
		Data = Data ./ 1000;
		% Sum all single appliance profiles up
		Data = sum(Data,2);
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			
			% histogramms of sum
			Hist_binEdges = linspace(Option_Histogramm_x_min_Value,Option_Histogramm_x_max_Value,Option_Number_Bins+1);
			Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2;     % center
			[~,Hist_binIdx] = histc(Data,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC> % histc
			% calculate the number of elements in bins
			Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
			figure(fig_histogrammsummary);
			switch Active_Type
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammsummary); 
	ax = gca;
	% General:
	if Option_Show_SubTitle
		ax.Title.String = ['Profilsatz ',num2str(i)]; %#ok<UNRCH>
	end
	% X Axis
	if Option_Histogramm_x_max_Value > 0
		ax.XAxis.Limits       = [Option_Histogramm_x_min_Value, Option_Histogramm_x_max_Value];
		ax.XAxis.TickValues   = tick_x_Positions;
		ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits       = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammsummary); hold off;
end

clear Option_* Active_* Data* Labels_* Hist_* i j k b ax
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms over the single profiles over different scenarios
% = = = = = = = = = = = = = = = = = 
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - 
Option_Number_Bins             = 60;
Option_Histogramm_x_max_Value  = 12; %kW (-1 ... autoscale)
Option_Histogramm_x_min_Value  =  0; %kW
Option_Histogramm_x_step_Value =  1; %kW
Option_Histogramm_x_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = 20; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  5; % '%'
Option_Histogramm_y_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      0; % 1 = Show subplot titles
Option_Plot_Size =   'compact'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Histogramme über die Einzelprofile für Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. Häufigkeit';
Labels_Title       = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Histogramm_y_min_Value,Option_Histogramm_y_step_Value, Option_Histogramm_y_max_Value, Option_Histogramm_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Histogramm_x_min_Value,Option_Histogramm_x_step_Value, Option_Histogramm_x_max_Value, Option_Histogramm_x_Label_Step);
		
		fig_histogrammsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction, Option_Plot_Size);
	end
	figure(fig_histogrammsingle); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Data_Input = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Data_Input.(['Set_',num2str(k)]).(Active_Type).Data_Mean];  %#ok<AGROW>
		end	
		% from W to kW
		Data = Data ./ 1000;
		Data_Singlephase = [];
		for m = 1 : size(Data, 2)/ 6
			Data_Sing = Data(:,1+(m-1)*6:6+(m-1)*6);
			Data_Singlephase = [Data_Singlephase; Data_Sing]; %#ok<AGROW>
		end
		Data_Singlephase = sum(Data_Singlephase,2);
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			% histogramms of single appliances
			Hist_binEdges = linspace(Option_Histogramm_x_min_Value,Option_Histogramm_x_max_Value,Option_Number_Bins+1);
			Hist_cj = (Hist_binEdges(1:end-1)+Hist_binEdges(2:end))./2; % center
			[~,Hist_binIdx] = histc(Data_Singlephase,[Hist_binEdges(1:end-1),Inf]); %#ok<HISTC>
			% calculate the number of elements in bins
			Hist_nj = accumarray(Hist_binIdx,1,[Option_Number_Bins,1], @sum);
			figure(fig_histogrammsingle);
			switch Active_Type
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammsingle); 
	ax = gca;
	% General:
	if Option_Show_SubTitle
		ax.Title.String = ['Profilsatz ',num2str(i)]; %#ok<UNRCH>
	end
	% X Axis
	if Option_Histogramm_x_max_Value > 0
		ax.XAxis.Limits       = [Option_Histogramm_x_min_Value, Option_Histogramm_x_max_Value];
		ax.XAxis.TickValues   = tick_x_Positions;
		ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits  = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammsingle); hold off;
end

clear Active_* Option_* ax b Data* Hist_* i j k m Labels_* tick_*
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
Option_Histogramm_x_max_Value  = 75; %kW (-1 ... autoscale)
Option_Histogramm_x_min_Value  =  0; %kW
Option_Histogramm_x_step_Value =  5; %kW
Option_Histogramm_x_Label_Step =  2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = 12; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  2; % '%'
Option_Histogramm_y_Label_Step =  2; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      1; % 1 = Show subplot titles
Option_Plot_Size =   'medium'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Entwicklung der Histogramme mit anwachsender Profilzahl für Datensatz "',...
% 	Settings_Datasets{Option_Type_Load,3},'" (Summe)'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. Häufigkeit';
Labels_Title = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Histogramm_y_min_Value,Option_Histogramm_y_step_Value, Option_Histogramm_y_max_Value, Option_Histogramm_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Histogramm_x_min_Value,Option_Histogramm_x_step_Value, Option_Histogramm_x_max_Value, Option_Histogramm_x_Label_Step);
		
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
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data; Data_Input.(['Set_',num2str(k)]).(Active_Type).Data_Mean]; %#ok<AGROW>
		end
		% from W to kW
		Data = Data ./ 1000;
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			% combine the profiles
			Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})]) = ...
				[Data_Dev_Hist.(['Saved_',num2str(Active_Scenarios{j,1})]); sum(Data,2)];
			% histogramms of development of profile numbers:
			if Option_Histogramm_x_max_Value > 0
				Hist_binEdges = linspace(Option_Histogramm_x_min_Value,Option_Histogramm_x_max_Value,Option_Number_Bins+1);
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
			switch Active_Type
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammdevsummary); 
	ax = gca;
	% General:
	if Option_Show_SubTitle
		ax.Title.String = [num2str(i*Settings_Number_Profiles),' Profile'];
	end
	% X Axis
	if Option_Histogramm_x_max_Value > 0
		ax.XAxis.Limits       = [Option_Histogramm_x_min_Value, Option_Histogramm_x_max_Value];
		ax.XAxis.TickValues   = tick_x_Positions;
		ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits  = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammdevsummary); hold off;
end

clear Active_* ax b Data* Hist_* i j k Labels_* Option_* tick_*
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
Option_Histogramm_x_max_Value  = 12; %kW (-1 ... autoscale)
Option_Histogramm_x_min_Value  =  0; %kW
Option_Histogramm_x_step_Value =  1; %kW
Option_Histogramm_x_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = 20; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  5; % '%'
Option_Histogramm_y_Label_Step =  1; % Spacing between label entries
%- - - - - - - - - - - - - - - - - - 
Option_Show_SubTitle =      1; % 1 = Show subplot titles
Option_Plot_Size =   'medium'; % 'compact', 'medium', 'large'
% = = = = = = = = = = = = = = = = = 
% Labels_Title = ['Entwicklung der Histogramme mit anwachsender Profilzahl für Datensatz "',...
% 	Settings_Datasets{Option_Type_Load,3},'" (Einzelprofile)'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. Häufigkeit';
Labels_Title = []; % No title for Word output
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		[tick_y_Positions, tick_y_Labels] = get_tick(Option_Histogramm_y_min_Value,Option_Histogramm_y_step_Value, Option_Histogramm_y_max_Value, Option_Histogramm_y_Label_Step);
		[tick_x_Positions, tick_x_Labels] = get_tick(Option_Histogramm_x_min_Value,Option_Histogramm_x_step_Value, Option_Histogramm_x_max_Value, Option_Histogramm_x_Label_Step);
		
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
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data; Data_Input.(['Set_',num2str(k)]).(Active_Type).Data_Mean]; %#ok<AGROW>
		end
		% from W to kW
		Data = Data ./ 1000;
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			% combine the profiles
			Data_Singlephase = [];
			for k = 1 : size(Data, 2)/ 6
				Data_Sing = Data(:,1+(k-1)*6:6+(k-1)*6);
				Data_Singlephase = [Data_Singlephase; Data_Sing]; %#ok<AGROW>
			end
			Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})]) = ...
				[Data_Dev_Hist_Single.(['Saved_',num2str(Active_Scenarios{j,1})]); sum(Data_Singlephase,2)];
			% histogramms of development of profile numbers:
			if Option_Histogramm_x_max_Value > 0
				Hist_binEdges = linspace(Option_Histogramm_x_min_Value,Option_Histogramm_x_max_Value,Option_Number_Bins+1);
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
			switch Active_Type
				case 'Solar'
					% In case of solar, don't plot the "0" bin, becaus this
					% is almost 50% of the data (nigthtime!)
					b=bar(Hist_cj(2:end),100*Hist_nj(2:end)/sum(Hist_nj(2:end)),'hist');
				otherwise
					b=bar(Hist_cj,100*Hist_nj/sum(Hist_nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Active_Scenarios{j,3}/256);
			alpha(b,.5)
		end
		hold on;
	end
	% Format Diagrams:
	figure(fig_histogrammdevsingle); 
	ax = gca;
	% General:
	if (Option_Show_SubTitle)
		ax.Title.String = [num2str(i*Settings_Number_Profiles),' Profile'];
	end
	% X Axis
	if Option_Histogramm_x_max_Value > 0
		ax.XAxis.Limits  = [Option_Histogramm_x_min_Value, Option_Histogramm_x_max_Value];
		ax.XAxis.TickValues   = tick_x_Positions;
		ax.XAxis.TickLabels   = tick_x_Labels;
	end
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits  = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios, 'Location','southeast');
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammdevsingle); hold off;
end

clear Active_* ax b Data* Hist_* i j k Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =