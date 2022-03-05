clear();
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (set up of of datastorage) and the next one (Set up and
% loading of data) have to be executed before every other cell!
Saved_Data_Input = [];

% Paths to source files:
Path_Data_LoadInfeed = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
% Path_Data_LoadInfeed = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios_30erSets';
% Path_Data_LoadInfeed = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

% Add folder with help functions to path:
addpath([fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'Additional_Resources']);
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Additional Set Up / Configuration / Loading of Input Data
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Settings_Scenario = {
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

Settings_Datasets = {
	1, 'Households'  , 'Haushaltslast'   ;...
	2, 'Solar'       , 'PV Einspeisung'  ;...
	3, 'El_Mobility' , 'Elektromobilit�t';...
	};

Settings_Number_Profiles = 10;

% Load data (Load Infeed Data)
folders = dir(Path_Data_LoadInfeed);
folders = struct2cell(folders);
folders = folders(1,3:end);

for i = 1: numel(folders)
	if ~isfield(Saved_Data_Input,['Saved_',num2str(i)])
		Saved_Data_Input.(['Saved_',num2str(i)]) = [];
	end
	for j = 1 : size(Settings_Scenario,1)
		if ~isfield(Saved_Data_Input.(['Saved_',num2str(i)]),['Saved_',num2str(Settings_Scenario{j,1})])
			Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]) = ...
				load([Path_Data_LoadInfeed,filesep,folders{i},'\',Settings_Scenario{j,2},'.mat'],'Load_Infeed_Data');
		end
	end
end

Saved_Data_Input.Number_Datasets = numel(folders);
clear folders i j Load_Infeed_Data

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Plot sum over single appliance profiles over scenarios
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10;   % Sommer
Option_Active_Scenarios = [6, 8];
% Option_Active_Scenarios = 1:2:10; % Winter
% Option_Active_Scenarios = 1:10;   % All scenarios (not recomended!)
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = 'El_Mobility'
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% y-axis Settings (Option_Plot_max_Value = -1 ... autoscale)
switch Option_Type_Load
	case 1 % 'Households'
		Option_Plot_max_Value  =  40; % kW
		Option_Plot_step_Value =  10; % kW
	case 2 % 'Solar'
		Option_Plot_max_Value  = 120; % kW
		Option_Plot_step_Value =  20; % kW
	case 3 % 'El_Mobility'
		Option_Plot_max_Value  =  30; % kW
		Option_Plot_step_Value =   5; % kW
end
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Labels_Title = [];%['Profilsummen �ber Szenarien f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Datensets';
Labels_Y_Direction = 'Leistung [kW]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		fig_infeedsummary = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
		
		% Set up the needed ticks:
		[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
		tick_y_Positions = 0:Option_Plot_step_Value:Option_Plot_max_Value;
		tick_y_Labels    = 0:Option_Plot_step_Value:Option_Plot_max_Value;
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
		end
		switch Active_Type
			case 'Households'
				Data_num_active = sum(cell2mat(Data_Input.Set_1.Households.Number(:,2)));
				Labels_Activity{end+1} = [num2str(Data_num_active),' Act.']; %#ok<SAGROW>
			case 'Solar'
				Data_num_active = size(Data_Input.(['Set_',num2str(k)]).Solar_Plants.Selectable,1)-2;
				if Data_num_active > 0
					Labels_Activity{end+1} = [num2str(Data_num_active),' Act.']; %#ok<SAGROW>
				end
			case 'El_Mobility'
				Data_num_active = Data_Input.(['Set_',num2str(k)]).(Active_Type).Number;
				if Data_num_active > 0
					Labels_Activity{end+1} = [num2str(Data_num_active),' Act.']; %#ok<SAGROW>
				end
			otherwise
				Data_num_active = 9999;
				Labels_Activity{end+1} = [num2str(Data_num_active),' Act.']; %#ok<SAGROW>
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
	ax.Title.String = ['Profilsatz ',num2str(i)];
	% Legend
	if i == 1
		legend(Labels_Scenarios);
	elseif i == 2
		legend(Labels_Activity{:});
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
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = 8; % Select only one scenario!
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% y-axis Settings for each sceanrio and load type
switch Option_Type_Load
	case 1 % 'Households'
		Option_Plot = {...
			% 1,  2,  3,  4,  5,  6,  7,  8,  9, 10; % Scenario (Option_Active_Scenarios)
			 -1, -1, -1, -1, -1, -1, -1, -1, -1, -1; % Option_Plot_max_Value ( -1 ... autoscale)
			 [], [], [], [], [], [], [], -1, [], []; % Option_Plot_step_Value
			};
	case 2 % 'Solar'
		Option_Plot = {...
			% 1,  2,  3,  4,  5,  6,  7,  8,  9, 10; % Scenario (Option_Active_Scenarios)
			 -1, -1, -1, -1, -1, 12, -1, 12, -1, -1; % Option_Plot_max_Value ( -1 ... autoscale)
			 [], [], [], [], [],  4, [],  4, [], []; % Option_Plot_step_Value
			};
	case 3 % 'El_Mobility'
		Option_Plot = {...
			% 1,  2,  3,  4,  5,  6,  7,  8,  9, 10; % Scenario (Option_Active_Scenarios)
			 -1, -1, -1, -1, -1, -1, -1, -1, -1, -1; % Option_Plot_max_Value ( -1 ... autoscale)
			 [], [], [], [], [], [], [], -1, [], []; % Option_Plot_step_Value
			};
end
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Labels_Title = ['Einzelprofile �ber Szenario "',Settings_Scenario{Option_Active_Scenarios,5},...
	'" f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Datensets';
Labels_Y_Direction = 'Leistung [kW]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Option_Plot_max_Value  =  Option_Plot{1,Option_Active_Scenarios};
		Option_Plot_step_Value =  Option_Plot{2,Option_Active_Scenarios};
		
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		fig_infeedsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
		
		% Set up the needed ticks:
		[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
		tick_y_Positions = 0:Option_Plot_step_Value:Option_Plot_max_Value;
		tick_y_Labels    = 0:Option_Plot_step_Value:Option_Plot_max_Value;
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
	ax.Title.String = ['Profilsatz ',num2str(i)];
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
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Number_Bins             = 70;
Option_Histogramm_x_max_Value  = 70; %kW
Option_Histogramm_x_min_Value  =  0; %kW
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = 12; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  4; % '%'
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Labels_Title = ['Histogramme �ber Szenarien f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		% Prepare everything:
		tick_y_Positions = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		tick_y_Labels    = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		fig_histogrammsummary = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
		
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
	ax.Title.String = ['Profilsatz ',num2str(i)];
	% X Axis
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits       = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios);
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammsummary); hold off;
end

clear Option_* Active_* Data* Labels_* Hist_* i j k b ax
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms over the single profiles over different scenarios
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Number_Bins            = 50;
Option_Histogramm_x_max_Value = 10; %kW
Option_Histogramm_x_min_Value =  0; %kW
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = 20; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  5; % '%'
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Labels_Title = ['Histogramme �ber die Einzelprofile f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
Labels_Subplot_Title_Startstr = 'Profilsatz'; % e.g. final format: "Profilsatz 3"
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		tick_y_Positions = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		tick_y_Labels    = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		
		fig_histogrammsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
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
	ax.Title.String = [Labels_Subplot_Title_Startstr,' ',num2str(i)];
	% X Axis
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits  = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios);
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammsingle); hold off;
end

clear Active_* Option_* ax b Data* Hist_* i j k m Labels_* tick_*

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms with adding up profile number (sum over appliance profiles)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Number_Bins            = 70;
Option_Histogramm_x_max_Value = -1; %kW (-1 ... autoscale)
Option_Histogramm_x_min_Value =  0; %kW
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  =  6; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  2; % '%'
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Labels_Title = ['Entwicklung der Histogramme mit anwachsender Profilzahl f�r Datensatz "',...
	Settings_Datasets{Option_Type_Load,3},'" (Summe)'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		tick_y_Positions = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		tick_y_Labels    = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		
		fig_histogrammdevsummary = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
		
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
	ax.Title.String = [num2str(i*Settings_Number_Profiles),' Profile'];
	% X Axis
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits  = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios);
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammdevsummary); hold off;
end

clear Active_* ax b Data* Hist_* i j k Labels_* Option_* tick_*

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Histogramms with adding up profile number (single appliance profiles)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Number_Bins            = 70;
Option_Histogramm_x_max_Value = -1; %kW (-1 ... autoscale)
Option_Histogramm_x_min_Value =  0; %kW
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Histogramm_y_max_Value  = 10; % '%' (-1 ... autoscale)
Option_Histogramm_y_min_Value  =  0; % '%'
Option_Histogramm_y_step_Value =  2; % '%'
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Labels_Title = ['Entwicklung der Histogramme mit anwachsender Profilzahl f�r Datensatz "',...
	Settings_Datasets{Option_Type_Load,3},'" (Einzelprofile)'];
Labels_X_Direction = 'Leistung [kW]';
Labels_Y_Direction = '% rel. H�ufigkeit';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Plot the figure:
for i = 1 : Saved_Data_Input.Number_Datasets
	if i <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		tick_y_Positions = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		tick_y_Labels    = Option_Histogramm_y_min_Value : Option_Histogramm_y_step_Value : Option_Histogramm_y_max_Value;
		
		fig_histogrammdevsingle = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
		
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
	ax.Title.String = [num2str(i*Settings_Number_Profiles),' Profile'];
	% X Axis
	% Y Axis
	if Option_Histogramm_y_max_Value > 0
		ax.YAxis.Limits  = [Option_Histogramm_y_min_Value, Option_Histogramm_y_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	% Legend
	if i == 1
		legend(Labels_Scenarios);
	end
	set_default_plot_properties(ax);
	figure(fig_histogrammdevsingle); hold off;
end

clear Active_* ax b Data* Hist_* i j k Labels_* Option_* tick_*

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =