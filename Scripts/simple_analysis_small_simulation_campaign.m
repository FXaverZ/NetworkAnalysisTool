%% Initial Set Up
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (set up of of datastorage) and the next one (Set up and
% loading of data) have to be executed before every other cell!

clear();
Saved_Data_OAT   = [];
Saved_Data_Input = [];

% Paths to source files:
Data_Path_LoadInfeed = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
% Data_Path_LoadInfeed = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';
Data_Path_OAT = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results_mean\01_Merged_OAT-Data\';
% Data_Path_OAT = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

% Add folder with help functions to path:
addpath([fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'Additional_Resources']);

%% Additional Set Up / Configuration / Loading of Input Data

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
Settings_Fontsize_Axes   = 8;
Settings_Fontsize_Legend = 6;

% Load data (Load Infeed Data)
folders = dir(Data_Path_LoadInfeed);
folders = struct2cell(folders);
folders = folders(1,3:end);

for i = 1: numel(folders)
	if ~isfield(Saved_Data_Input,['Saved_',num2str(i)])
		Saved_Data_Input.(['Saved_',num2str(i)]) = [];
	end
	for j = 1 : size(Settings_Scenario,1)
		if ~isfield(Saved_Data_Input.(['Saved_',num2str(i)]),['Saved_',num2str(Settings_Scenario{j,1})])
			load([Data_Path_LoadInfeed,filesep,folders{i},'\',Settings_Scenario{j,2},'.mat']);
			Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data = Load_Infeed_Data;
		end
	end
end

Saved_Data_Input.Number_Datasets = numel(folders);
clear folders i j Load_Infeed_Data

%% Plot sum over single appliance profiles over scenarios)
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = 2:2:10; % Sommer
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Plot_max_Value  = 120; % kW
Option_Plot_step_Value =  20; % kW
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
Active_Type = Settings_Datasets{Option_Type_Load,2};

fig_infeedsummary = figure; 
set_up_tiledlayout(['Profilsummen �ber Szenarien f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'],...
	'Datensets','Leistung [kW]');

% Set up the needed ticks:
[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
tick_y_Positions = 0:Option_Plot_step_Value:Option_Plot_max_Value;
tick_y_Labels    = 0:Option_Plot_step_Value:Option_Plot_max_Value;

for i = 1 : Saved_Data_Input.Number_Datasets
	figure(fig_infeedsummary); nexttile;
	Labels_Activity  = {};
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Active_Type).Data_Mean]; %#ok<AGROW>
		end
		Data = sum(Data,2);
		Data = Data ./ 1000;
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
		end
		switch Active_Type
			case 'Households'
				num_active = sum(cell2mat(Load_Infeed_Data.Set_1.Households.Number(:,2)));
				Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
			case 'Solar'
				num_active = size(Load_Infeed_Data.(['Set_',num2str(k)]).Solar_Plants.Selectable,1)-2;
				if num_active > 0
					Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
				end
			case 'El_Mobility'
				num_active = Load_Infeed_Data.(['Set_',num2str(k)]).(Active_Type).Number;
				if num_active > 0
					Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
				end
			otherwise
				num_active = 9999;
				Labels_Activity{end+1} = [num2str(num_active),' Act.']; %#ok<SAGROW>
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
	% General:
	ax.Title.String = ['Profilsatz ',num2str(i)];
	ax.FontName     = 'Palatino Linotype';
	ax.FontSize     = Settings_Fontsize_Axes;
	% Legend
	if i == 1
		legend(Labels_Scenarios);
		ax.Legend.FontSize    = Settings_Fontsize_Legend;
	elseif i == 2
		legend(Labels_Activity{:});
		ax.Legend.FontSize    = Settings_Fontsize_Legend;
	end
	% X Axis
	ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	ax.XAxis.TickValues   = tick_x_Positions;
	ax.XAxis.TickLabels   = tick_x_Labels;
	ax.XGrid              = 'on';
	% Y Axis
	if Option_Plot_max_Value > 0
		ax.YAxis.Limits  = [0 Option_Plot_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	ax.YGrid              = 'on';
	figure(fig_infeedsummary); hold off;
end

clear Active_* Option_* tick_* i j k l Labels_Activity Labels_Scenarios 
clear Load_Infeed_Data Data num_active ax 

%% Plot the single profiles for a specific scenario
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = 8; % Select only one scenario!
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Plot_max_Value  =  12; % kW
Option_Plot_step_Value =  3; % kW
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
Active_Type = Settings_Datasets{Option_Type_Load,2};

fig_infeedsingle = figure; 
set_up_tiledlayout(['Einzelprofile �ber Szenario "',Active_Scenarios{1,5},'" f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'],...
	'Datensets','Leistung [kW]');

% Set up the needed ticks:
[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
tick_y_Positions = 0:Option_Plot_step_Value:Option_Plot_max_Value;
tick_y_Labels    = 0:Option_Plot_step_Value:Option_Plot_max_Value;

for i = 1 : Saved_Data_Input.Number_Datasets
	figure(fig_infeedsingle); nexttile;
	for j = 1 : size(Active_Scenarios,1)
		Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Active_Type).Data_Mean];  %#ok<AGROW>
		end	
		% from W to kW
		Data = Data ./ 1000;
		% remove zero profiles
		Data = Data(:,sum(Data)>0);
		% add up all phase data:
		Data = Data(:,1:3:end)+Data(:,2:3:end)+Data(:,3:3:end);
		figure(fig_infeedsingle); l = plot(Data);
		drawnow;
		if j <=1
			figure(fig_infeedsingle); hold on;
			legend([num2str(size(Data,2)),' aktive Profile']);
		end
	end
	% Format Diagrams:
	figure(fig_infeedsingle); 
	ax = gca;
	% General:
	ax.Title.String = ['Profilsatz ',num2str(i)];
	ax.FontName     = 'Palatino Linotype';
	ax.FontSize     = Settings_Fontsize_Axes;
	% Legend
	ax.Legend.FontSize    = Settings_Fontsize_Legend;
	% X Axis
	ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	ax.XAxis.TickValues   = tick_x_Positions;
	ax.XAxis.TickLabels   = tick_x_Labels;
	ax.XGrid              = 'on';
	% Y Axis
	if Option_Plot_max_Value > 0
		ax.YAxis.Limits  = [0 Option_Plot_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	ax.YGrid              = 'on';
	figure(fig_infeedsingle); hold off;
end

clear Option_* i j k Data*

%% Histogramms over the profile sums over different scenarios
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Number_Bins          = 50;
Option_Histogramm_max_Value = 60; %kW
Option_Histogramm_min_Value =  0; %kW
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Histogramm_Single_max_Value = 10; %kW
Option_Histogramm_Single_min_Value = 0;  %kW
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
Active_Type = Settings_Datasets{Option_Type_Load,2};

fig_histogrammsummary = figure;
set_up_tiledlayout(['Histogramme �ber Szenarien f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'],...
	'Leistung [kW]','% rel. H�ufigkeit');

for i = 1 : Saved_Data_Input.Number_Datasets
	figure(fig_histogrammsummary); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Active_Type).Data_Mean];  %#ok<AGROW>
		end	
		% from W to kW
		Data = Data ./ 1000;
		% Sum all single appliance profiles up
		Data = sum(Data,2);
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			
			% histogramms of sum
			binEdges = linspace(Option_Histogramm_min_Value,Option_Histogramm_max_Value,Option_Number_Bins+1);
			cj = (binEdges(1:end-1)+binEdges(2:end))./2;     % center
			[~,binIdx] = histc(Data,[binEdges(1:end-1),Inf]); %#ok<HISTC> % histc
			% calculate the number of elements in bins
			nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
			figure(fig_histogrammsummary);
			switch Active_Type
				case 'Solar'
					b=bar(cj(2:end),100*nj(2:end)/sum(nj(2:end)),'hist');
				otherwise
					b=bar(cj,100*nj/sum(nj),'hist');
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
	ax.FontName     = 'Palatino Linotype';
	ax.FontSize     = Settings_Fontsize_Axes;
	% Legend
	if i == 1
		legend(Labels_Scenarios);
		ax.Legend.FontSize    = Settings_Fontsize_Legend;
	end
	figure(fig_histogrammsummary); hold off;
end

clear Option_* i j k b nj cj binEdges binIdx Data Active_* ax Labels_* Load_Infeed_Data

%% Histogramms over the single profiles over different scenarios
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Option_Active_Scenarios = 2:2:10; % Sommer
Option_Active_Scenarios = [6,8];
% Option_Active_Scenarios = 1:2:10; % Winter
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Type_Load = 2; % 1 = 'Households', 2 = 'Solar', 3 = El_Mobility
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Option_Number_Bins          = 50;
Option_Histogramm_max_Value = 10; %kW
Option_Histogramm_min_Value =  0; %kW
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
Active_Type = Settings_Datasets{Option_Type_Load,2};

fig_histogrammsingle = figure;
set_up_tiledlayout(['Histogramme �ber die Einzelprofile f�r Datensatz "',Settings_Datasets{Option_Type_Load,3},'"'],...
	'Leistung [kW]','% rel. H�ufigkeit');

for i = 1 : Saved_Data_Input.Number_Datasets
	figure(fig_histogrammsingle); nexttile;
	Labels_Scenarios = {};
	for j = 1 : size(Active_Scenarios,1)
		Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Active_Scenarios{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Active_Type).Data_Mean];  %#ok<AGROW>
		end	
		% from W to kW
		Data = Data ./ 1000;
		Data_Singlephase = [];
		for m = 1 : size(Data, 2)/ 6
			data_sing = Data(:,1+(m-1)*6:6+(m-1)*6);
			Data_Singlephase = [Data_Singlephase; data_sing]; %#ok<AGROW>
		end
		Data_Singlephase = sum(Data_Singlephase,2);
		if (~isempty(Data))
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
			% histogramms of single appliances
			binEdges = linspace(Option_Histogramm_min_Value,Option_Histogramm_max_Value,Option_Number_Bins+1);
			cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
			[~,binIdx] = histc(Data_Singlephase,[binEdges(1:end-1),Inf]); %#ok<HISTC>
			% calculate the number of elements in bins
			nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
			figure(fig_histogrammsingle);
			switch Active_Type
				case 'Solar'
					b=bar(cj(2:end),100*nj(2:end)/sum(nj(2:end)),'hist');
				otherwise
					b=bar(cj,100*nj/sum(nj),'hist');
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
	ax.Title.String = ['Profilsatz ',num2str(i)];
	ax.FontName     = 'Palatino Linotype';
	ax.FontSize     = Settings_Fontsize_Axes;
	% Legend
	if i == 1
		legend(Labels_Scenarios);
		ax.Legend.FontSize    = Settings_Fontsize_Legend;
	end
	figure(fig_histogrammsingle); hold off;
end

%%
for i = 1: numel(folders)
	figure(fig_infeedsummary); nexttile;
	figure(histogrammsummary); nexttile;
	figure(histogrammSingle); nexttile;
	if ~isfield(Saved_Data_Input,['Saved_',num2str(i)])
		Saved_Data_Input.(['Saved_',num2str(i)]) = [];
	end
	Labels_Activity = {};
	for j = 1 : size(Settings_Scenario,1)
		if ~isfield(Saved_Data_Input.(['Saved_',num2str(i)]),['Saved_',num2str(Settings_Scenario{j,1})])
			load([Data_Path_LoadInfeed,filesep,folders{i},'\',Settings_Scenario{j,2},'.mat']);
			Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data = Load_Infeed_Data;
		else
			Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data;
		end
		
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Option_Type_Load).Data_Mean]; %#ok<AGROW>
			
		end
		
		if Option_Show_Power_Sum
			Data_Singlephase = [];
			for m = 1 : size(Data, 2)/ 6
				data_sing = Data(:,1+(m-1)*6:6+(m-1)*6);
				Data_Singlephase = [Data_Singlephase; data_sing]; %#ok<AGROW>
			end
			Data_Singlephase = sum(Data_Singlephase,2);
			Data = sum(Data,2);
			num_active = 9999;
			switch Option_Type_Load
				case 'Households'
					num_active = sum(cell2mat(Load_Infeed_Data.Set_1.Households.Number(:,2)));
					Labels_Activity{end+1} = [num2str(num_active),' Act.'];
				case 'Solar'
					num_active = size(Load_Infeed_Data.(['Set_',num2str(k)]).Solar_Plants.Selectable,1)-2;
					if num_active > 0
						Labels_Activity{end+1} = [num2str(num_active),' Act.'];
					end
				case 'El_Mobility'
					num_active = Load_Infeed_Data.(['Set_',num2str(k)]).(Option_Type_Load).Number;
					if num_active > 0
						Labels_Activity{end+1} = [num2str(num_active),' Act.'];
					end
				otherwise
					num_active = 0;
			end
			% histogramms of sum
			binEdges = linspace(min_hist_value,Option_Histogramm_max_Value,Settings_Number_Bins+1);
			cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
			[~,binIdx] = histc(Data,[binEdges(1:end-1),Inf]); % histc
			% calculate the number of elements in bins
			nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
			figure(histogrammsummary); 
			switch Option_Type_Load
				case 'Solar'
					b=bar(cj(2:end),100*nj(2:end)/sum(nj(2:end)),'hist');
				otherwise
					b=bar(cj,100*nj/sum(nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
			alpha(b,.5)
			hold on;
			
			% histogramms of single appliances
			binEdges = linspace(Option_Histogramm_Single_min_Value,Option_Histogramm_Single_max_Value,Settings_Number_Bins+1);
			cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
			[~,binIdx] = histc(Data_Singlephase,[binEdges(1:end-1),Inf]); % histc
			% calculate the number of elements in bins
			nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
			figure(histogrammSingle); 
			switch Option_Type_Load
				case 'Solar'
					b=bar(cj(2:end),100*nj(2:end)/sum(nj(2:end)),'hist');
				otherwise
					b=bar(cj,100*nj/sum(nj),'hist');
			end
			set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
			alpha(b,.5)
			hold on;
			
		end
		figure(fig_infeedsummary); l = plot(Data);
		set(l, 'Color', Settings_Scenario{j,3});
		drawnow;
		if j <=1
			figure(fig_infeedsummary); hold on;
			if Option_Plot_max_Value > 0 
				ylim([0 Option_Plot_max_Value]);
			end
			figure(fig_infeedsummary); title(['Dataset ',num2str(i),' - Source - "',Option_Type_Load,'"']);
			figure(histogrammsummary); title(['Histogramm ',num2str(i),' - Source - "',Option_Type_Load,'"']);
			figure(histogrammSingle); title(['Histogramm Einzel',num2str(i),' - Source - "',Option_Type_Load,'"']);
		end
	end
	if Option_Show_Power_Sum && i <= 1
		figure(fig_infeedsummary); legend(Labels_Activity{:})
		figure(histogrammsummary); legend(Settings_Scenario{:,4});
		figure(histogrammSingle); legend(Settings_Scenario{:,4});
	end
	if Option_Show_Power_Sum && i == 2
		figure(fig_infeedsummary); hold on;
		figure(fig_infeedsummary); legend(Settings_Scenario{:,4});
	end
	figure(fig_infeedsummary); hold off;
	figure(histogrammsummary); hold off;
end
%% Histogramm aufbauend
histogrammdevelopment = figure; tiledlayout(5,3);
histogrammdevelopmentSingle = figure; tiledlayout(5,3);
histData = [];
histDataSingle = [];
for i = 1: numel(folders)
	figure(histogrammdevelopment); nexttile;
	figure(histogrammdevelopmentSingle); nexttile;
	for j = 1 : size(Settings_Scenario,1)
		if (~isfield(histData, ['Saved_',num2str(Settings_Scenario{j,1})]))
			histData.(['Saved_',num2str(Settings_Scenario{j,1})]) = [];
		end
		if (~isfield(histDataSingle, ['Saved_',num2str(Settings_Scenario{j,1})]))
			histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]) = [];
		end
		Load_Infeed_Data = Saved_Data_Input.(['Saved_',num2str(i)]).(['Saved_',num2str(Settings_Scenario{j,1})]).Load_Infeed_Data;
		Data = [];
		for k = 1 : Settings_Number_Profiles
			Data = [Data;...
				Load_Infeed_Data.(['Set_',num2str(k)]).(Option_Type_Load).Data_Mean]; %#ok<AGROW>
		end
		histData.(['Saved_',num2str(Settings_Scenario{j,1})]) = [histData.(['Saved_',num2str(Settings_Scenario{j,1})]); sum(Data,2)];
		
		binEdges = linspace(min_hist_value,Option_Histogramm_max_Value,Settings_Number_Bins+1);
		cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
		[~,binIdx] = histc(histData.(['Saved_',num2str(Settings_Scenario{j,1})]),[binEdges(1:end-1),Inf]); % histc
		% calculate the number of elements in bins
		nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
		figure(histogrammdevelopment);
		switch Option_Type_Load
			case 'Solar'
				b=bar(cj(2:end),100*nj(2:end)/sum(nj),'hist');
			otherwise
				b=bar(cj,100*nj/sum(nj),'hist');
		end
		set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
		alpha(b,.5)
		hold on;
		
		figure(histogrammdevelopmentSingle);
		Data_Singlephase = [];
		for k = 1 : size(Data, 2)/ 6
			data_sing = Data(:,1+(k-1)*6:6+(k-1)*6);
			Data_Singlephase = [Data_Singlephase; data_sing]; %#ok<AGROW>
		end
		histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]) = [histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]); sum(Data_Singlephase,2)];
		
		binEdges = linspace(Option_Histogramm_Single_min_Value,Option_Histogramm_Single_max_Value,Settings_Number_Bins+1);
		cj = (binEdges(1:end-1)+binEdges(2:end))./2; % center
		[~,binIdx] = histc(histDataSingle.(['Saved_',num2str(Settings_Scenario{j,1})]),[binEdges(1:end-1),Inf]); % histc
		% calculate the number of elements in bins
		nj = accumarray(binIdx,1,[Settings_Number_Bins,1], @sum);
		figure(histogrammdevelopmentSingle);
		switch Option_Type_Load
			case 'Solar'
				b=bar(cj(2:end),100*nj(2:end)/sum(nj),'hist');
			otherwise
				b=bar(cj,100*nj/sum(nj),'hist');
		end
		set(b,'EdgeColor','none','FaceColor',Settings_Scenario{j,3});
		alpha(b,.5)
		hold on;
		
		if j <=1
			figure(histogrammdevelopment); title([num2str(i*10),' Datasets ',' - Source - "',Option_Type_Load,'"']);
		end
	end
	figure(histogrammdevelopment); hold off;
	figure(histogrammdevelopmentSingle); hold off;
end

%% OAT Data
folders = dir(Data_Path_OAT);
folders = struct2cell(folders);
folders = folders(1,3:end);

if strcmp(Option_Type_Load, 'El_Mobility')
	Option_Type_Load = 'El_mobility';
end

sep = cell(1,numel(folders));
sep(:) = {' - '};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
sep(:) = {'_Solar'};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
folders = unique(folders);

oatsummary = figure; tiledlayout(5,3);
for i = 1: numel(folders)
	if ~isfield(Saved_Data_OAT,['Saved_',num2str(i)])
		load([Data_Path_OAT,...
			folders{i},' - 000 - OAT-Data.mat']);
		Saved_Data_OAT.(['Saved_',num2str(i)]).NVIEW_Results = NVIEW_Results;
	else
		NVIEW_Results = Saved_Data_OAT.(['Saved_',num2str(i)]).NVIEW_Results;
	end
	
	figure(oatsummary); nexttile;
	for j = 1:size(Settings_Scenario,1)
		figure(oatsummary); plot(NVIEW_Results.Input_Data.(Option_Type_Load)(1:Settings_Number_Profiles*144,Settings_Scenario{j,1}));
		drawnow;
		if j <=1
			figure(oatsummary); hold on;
			title(['Datenset ',num2str(i),' - OAT - "',Option_Type_Load,'"']);
		end
	end
	figure(oatsummary); hold off;
end

%% Close all figures
close(fig_infeedsummary);
close(histogrammsummary);
close(oatsummary);