% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Initial Set Up
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% This is a simple script for the analysis of the small simulation
% campaign. It is structured into individuall cells to be executed one by
% one.
% Only this cell (set up of of datastorage) and the next one (Set up and
% loading of data) have to be executed before every other cell!

clear();
Saved_Data_OAT   = [];

% Paths to source files:
Path_Data_OAT = 'C:\Dissertation - Daten\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Results_mean\01_Merged_OAT-Data\';
% Path_Data_OAT = 'D:\Dissertation_Neue_zus_Netzanalysen\Simple_Simulation_Campaign\Load_Infeed_Data_f_Scenarios';

% Add folder with help functions to path:
addpath([fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'Additional_Resources']);
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Additional Set Up / Configuration
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

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
%% Load OAT Data
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
folders = dir(Path_Data_OAT);
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
		load([Path_Data_OAT,...
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
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =