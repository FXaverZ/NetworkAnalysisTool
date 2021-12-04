function [NVIEW_Results,NVPRO_Control] = limit_nat_results_as(NVIEW_Results,NVIEW_Control,NVIEW_Analysis_Selection)

% Limit the observations to selected lists in <s> and <d>!
Selected_Variants = find(NVIEW_Analysis_Selection.Variants);
Selected_Scenarios = find(NVIEW_Analysis_Selection.Scenarios);

% Get list of grid variants and select the ones from the list
SelectedVariantList = NVIEW_Control.Simulation_Description.Variants;
SelectedVariantList = SelectedVariantList(Selected_Variants);

% Timepoints
SelectedTimepoints = NVIEW_Analysis_Selection.Timepoints;

% Nodes - Branches
SelectedNodes = [];
SelectedBranches = [];
Field_List = NVIEW_Control.Simulation_Description.Variants(NVIEW_Analysis_Selection.Variants==1);
for i = 1 : size(Field_List,1)
    SelectedNodes.(Field_List{i}) = find(NVIEW_Analysis_Selection.SelectedNodes.(Field_List{i}));
    SelectedBranches.(Field_List{i}) = find(NVIEW_Analysis_Selection.SelectedBranches.(Field_List{i}));
end
clear i

% Limit scenarios to the selected list in <d>. Remove non-relevant columns in d
Data_List = fields(NVIEW_Results);

d_ = [];
for H = 1 : numel(Data_List)
    if ~isempty(find(strcmp(SelectedVariantList,Data_List{H}))) || strcmp(Data_List{H},'Input_Data')
        d_.(Data_List{H}) = NVIEW_Results.(Data_List{H});
    end
end
clear NVIEW_Results; NVIEW_Results = d_; clear d_ Data_List H

% Limit scenarios for each grid
Data_List = fields(NVIEW_Results);
for H = 1 : numel(Data_List)
    if ~strcmp(Data_List{H,1},'Input_Data')
        bus_selection = [];
        branch_selection = [];
        
        bus_selection = SelectedNodes.(Data_List{H,1});
        branch_selection = SelectedBranches.(Data_List{H,1});
        
        NVIEW_Results.(Data_List{H}).bus = NVIEW_Results.(Data_List{H}).bus(bus_selection,:);
        NVIEW_Results.(Data_List{H}).bus_name = NVIEW_Results.(Data_List{H}).bus_name(bus_selection,:);
        NVIEW_Results.(Data_List{H}).branch = NVIEW_Results.(Data_List{H}).branch(branch_selection,:);
        NVIEW_Results.(Data_List{H}).branch_name = NVIEW_Results.(Data_List{H}).branch_name(branch_selection,:);
        
        
        NVIEW_Results.(Data_List{H}).bus_voltages = NVIEW_Results.(Data_List{H}).bus_voltages(Selected_Scenarios,:,SelectedTimepoints,bus_selection,:);
        NVIEW_Results.(Data_List{H}).branch_values = NVIEW_Results.(Data_List{H}).branch_values(Selected_Scenarios,:,SelectedTimepoints,branch_selection,:);
		% CHANGELOG 1.1, FZ Start
		if isfield(NVIEW_Results.(Data_List{H}),'loss_statistics')
			NVIEW_Results.(Data_List{H}).loss_statistics = NVIEW_Results.(Data_List{H}).loss_statistics(Selected_Scenarios,:,SelectedTimepoints,branch_selection);
		else
			NVIEW_Results.(Data_List{H}).loss_statistics = [];
		end
		% CHANGELOG 1.1, FZ End
    end
end

Input_Data_Timepoints = reshape((1: size(NVIEW_Results.Input_Data.Households,1))',NVIEW_Control.Simulation_Options.Timepoints_per_dataset,[]);
Input_Data_Timepoints = Input_Data_Timepoints(NVIEW_Analysis_Selection.Timepoints,:);
Input_Data_Timepoints = Input_Data_Timepoints(:);

% Input_Data_Timepoints = [];
% for d = 1 : NVIEW_Control.Simulation_Options.Number_of_datasets
%     Input_Data_Timepoints = [Input_Data_Timepoints;
%        (NVIEW_Analysis_Selection.Timepoints +...
%         (d-1)*NVIEW_Control.Simulation_Options.Timepoints_per_dataset)];
% end


NVIEW_Results.Input_Data.Households = NVIEW_Results.Input_Data.Households(Input_Data_Timepoints,Selected_Scenarios);
NVIEW_Results.Input_Data.Solar = NVIEW_Results.Input_Data.Solar(Input_Data_Timepoints,Selected_Scenarios);
NVIEW_Results.Input_Data.El_mobility = NVIEW_Results.Input_Data.El_mobility(Input_Data_Timepoints,Selected_Scenarios);
% CHANGELOG 1.1, FZ Start
NVIEW_Results.Input_Data.LV_Grid_Input = NVIEW_Results.Input_Data.LV_Grid_Input(Input_Data_Timepoints,Selected_Scenarios);
% CHANGELOG 1.1, FZ End

NVPRO_Control = []; % Nview processed control
NVPRO_Control.Simulation_Options = NVIEW_Control.Simulation_Options;
NVPRO_Control.Simulation_Description = NVIEW_Control.Simulation_Description;


% Limit scenarios to the selected list in <s>
NVPRO_Control.Simulation_Description.Scenario = NVPRO_Control.Simulation_Description.Scenario(Selected_Scenarios,:);
NVPRO_Control.Simulation_Description.Variants = NVPRO_Control.Simulation_Description.Variants(Selected_Variants,:);
NVPRO_Control.Simulation_Options.Number_of_Scenarios = size(Selected_Scenarios,1);
NVPRO_Control.Simulation_Options.Number_of_Variants = size(Selected_Variants,1);
NVPRO_Control.Simulation_Options.Timepoints_per_dataset = numel(NVIEW_Analysis_Selection.Timepoints);