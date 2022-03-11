clear();
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (set up of of datastorage) and the next one (Set up and
% loading of data) have to be executed before every other cell!
Saved_Data_OAT   = [];

% Paths to source files:
Path_Data_OAT = ['C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\',...
	'Results_mean\01_Merged_OAT-Data_Load_Infeed\'];
% Path_Data_OAT = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

% Add folder with help functions / needed classes to path:
scriptpath = fileparts(matlab.desktop.editor.getActiveFilename);
scriptfolderpath = fileparts(scriptpath);
addpath([scriptpath, filesep, 'Additional_Resources']);
addpath([fileparts(scriptfolderpath),filesep,'NAT_Common',filesep,'Analyzing']);
addpath([fileparts(scriptfolderpath),filesep,'NAT_Common',filesep,'Grid_Representation']);

clear script*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Additional Set Up / Configuration / Loading of OAT Data
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
	3, 'El_Mobility' , 'Elektromobilität';...
	};

Settings_Number_Profiles = 10;

% Load OAT Data
folders = dir(Path_Data_OAT);
folders = struct2cell(folders);
folders = folders(1,3:end);

sep = cell(1,numel(folders));
sep(:) = {' - '};
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
sep(:) = {'_Solar'}; % if solar pictures are also present...
folders = cellfun(@strsplit,folders,sep,'UniformOutput',false);
folders = cellfun(@(x) x{1},folders,'UniformOutput',false);
folders = unique(folders);

NVIEW_Data_Names = {'NVIEW_Results', 'NVIEW_Analysis_Selection', 'NVIEW_Control', 'NVIEW_Processed'};
disp('Loading OAT Data...');
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
%% Plot a quick summary of the input data 
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Option_Active_Scenarios = 2:2:10;   % Sommer
% Option_Active_Scenarios = [6, 8];
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
		Option_Plot_max_Value  =  20; % kW
		Option_Plot_step_Value =   5; % kW
end
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
Labels_Title = [];%['Profilsummen über Szenarien für Datensatz "',Settings_Datasets{Option_Type_Load,3},'" aus OAT'];
Labels_X_Direction = 'Datensets';
Labels_Y_Direction = 'Leistung [kW]';
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

for i_d = 1 : Saved_Data_OAT.Number_Datasets
	i_d_sorted = Saved_Data_OAT.Sorting_Idxs(i_d);
	if i_d <= 1
		Active_Scenarios = Settings_Scenario(Option_Active_Scenarios,:);
		Active_Type = Settings_Datasets{Option_Type_Load,2};
		
		fig_oat_infeedsummary = set_up_tiledlayout(Labels_Title, Labels_X_Direction, Labels_Y_Direction);
		
		% Set up the needed ticks:
		[tick_x_Positions, tick_x_Labels] = get_tick_x_profiles(Settings_Number_Profiles);
		tick_y_Positions = 0:Option_Plot_step_Value:Option_Plot_max_Value;
		tick_y_Labels    = 0:Option_Plot_step_Value:Option_Plot_max_Value;
	end
	
	figure(fig_oat_infeedsummary); nexttile;
	Labels_Scenarios = {};
	
	if strcmp(Active_Type, 'El_Mobility')
		Active_Type = 'El_mobility';
	end
	
	Data_All = Saved_Data_OAT.(['Saved_',num2str(i_d_sorted)]).NVIEW_Results.Input_Data.(Active_Type);
	% from W to kW
	Data_All = Data_All ./ 1000;
	
	for j = 1:size(Active_Scenarios,1)
		Data = Data_All(1:Settings_Number_Profiles*144,Active_Scenarios{j,1});
		if (sum(Data) > 0)
			% plot the data:
			figure(fig_oat_infeedsummary); l = plot(Data);
			set(l, 'Color', Active_Scenarios{j,3}/256);
			set(l, 'LineStyle', Active_Scenarios{j,4});
			drawnow;
			Labels_Scenarios{end+1} = Active_Scenarios{j,5}; %#ok<SAGROW>
		end
		if j <=1
			figure(fig_oat_infeedsummary); hold on;
		end
	end
	% Format Diagrams:
	figure(fig_oat_infeedsummary); 
	ax = gca;
	ax.Title.String = ['Profilsatz ',num2str(i_d)];
	% Legend
	if i_d == 1
		legend(Labels_Scenarios);
	end
	% X Axis
	ax.XAxis.Limits       = [0 144*Settings_Number_Profiles];
	ax.XAxis.TickValues   = tick_x_Positions;
	ax.XAxis.TickLabels   = tick_x_Labels;
	% Y Axis
	if Option_Plot_max_Value > 0
		ax.YAxis.Limits       = [0 Option_Plot_max_Value];
		ax.YAxis.TickValues   = tick_y_Positions;
		ax.YAxis.TickLabels   = tick_y_Labels;
	end
	set_default_plot_properties(ax);
	figure(fig_oat_infeedsummary); hold off;
end

clear Active_* ax Data* i_* j l Labels_* Option_* tick_*
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =