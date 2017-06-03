function handles = grid_branches_comparison(handles,observed_dataset,display_option)

% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT

% Check d.Result for (cg) grids
list_of_grids = fields(d.Result);

% Assumption: All variants have the same number of datasets. We check how
% many datasets exist
number_of_datasets = handles.Current_Settings.Simulation.Number_Runs;


% Comparison_of_... is an array of 
% <no.of_grids x number of datasets x 4=(base limit, 1st limit, 2nd, 3rd]>
Comparison_of_Number_of_Violations = ...
    zeros(numel(list_of_grids),number_of_datasets,4);
Comparison_of_Number_of_Branches_With_Violations = ...
    zeros(numel(list_of_grids),number_of_datasets,4);
Comparison_of_Number_of_Violations_percent = ...
    zeros(numel(list_of_grids),number_of_datasets,4);
Comparison_of_Number_of_Branches_With_Violations_percent = ...
    zeros(numel(list_of_grids),number_of_datasets,4);

% -----------------------------------------------------------

% Compare the variant grids/datasets
if numel(list_of_grids) > 1 || number_of_datasets > 1
    for cg = 1 : numel(list_of_grids)
        % Set the observed grid and check all observed dataset
        grid = list_of_grids{cg};        
        % Number of violations for observed grid are written into the array

        Comparison_of_Number_of_Violations(cg,:,:) = ...
            d.Result.(grid).Branch_Violation_Summary.Number_of_Violations;
        Comparison_of_Number_of_Branches_With_Violations(cg,:,:) = ...
            d.Result.(grid).Branch_Violation_Summary.Number_of_Branches_With_Violations;

        Comparison_of_Number_of_Violations_percent(cg,:,:) = ...
            d.Result.(grid).Branch_Violation_Summary.Number_of_Violations_percent;
        Comparison_of_Number_of_Branches_With_Violations_percent(cg,:,:) = ...
            d.Result.(grid).Branch_Violation_Summary.Number_of_Branches_With_Violations_percent; 
    end % <no.of_grids x number of datasets x 4=(base limit, 1st limit, 2nd, 3rd]>
else
    disp(' ++ Only one grid/dataset analysed - can not compare branch violations ++ ');
end

% If no violations occur, return text result
if sum(Comparison_of_Number_of_Violations(:)) == 0
   disp(' No voltage violations at any grid/dataset '); 
    return;
end

% In order to display grids from top to bottom, we have to flip dimensions
% of array Comparison_of_Number_of_Violations and list_of_grids
bh.Grids = flipdim(list_of_grids,1);
bh.Datasets = 1:number_of_datasets;

bh.Number_values = ...
    flipdim(Comparison_of_Number_of_Violations,1);
bh.Nodes_values = ...
    flipdim(Comparison_of_Number_of_Branches_With_Violations,1);

bh.Number_percent = ...
    flipdim(Comparison_of_Number_of_Violations_percent,1);
bh.Nodes_percent = ...
    flipdim(Comparison_of_Number_of_Branches_With_Violations_percent,1);

% Plot the result comparisons
barh_branch_violations_grouped(bh, observed_dataset, display_option);

end % Main function

function [] = barh_branch_violations_grouped(bh, observed_dataset, display_option);
        
violations = eval(['bh.Number_', display_option]);
nodes_with = eval(['bh.Nodes_', display_option]);
grids = bh.Grids;

% If there is no additional limit, or it is never exceeded, we can 
% remove it from the graph. Therefore  there is no need for
% the additional limit value        
legend_text{1} = 'Thermal base limit';
legend_text{2} = 'First add. limit';
legend_text{3} = 'Second add. limit';
legend_text{4} = 'Third add. limit';
delete_column_ids = zeros(1,4);
for i = 2:4
    if sum(violations(:,i)==0) == size(violations,1) 
        delete_column_ids(i) = 1; 
        % delete_column_ids value 1 represents the column with a
        % non-existant limit that can be deleted        
    end
end
violations(:,:,violations==1) = []; 
nodes_with(:,:,violations==1) = []; 
legend_text(delete_column_ids==1)=[];
% Delete the additional limit columns

violations = squeeze(violations(:,observed_dataset,:));
nodes_with = squeeze(nodes_with(:,observed_dataset,:));

scz = get(0,'ScreenSize');
figure;
% Set the size of the figure - relative to screen size
set(gcf,'Position',[scz(3)*0.1 , scz(4)*0.1,scz(3)*0.5*[1,0.8]]);

ax1 = subplot(2,1,1); hold on; 
    barh(violations,'BarLayout','grouped','BarWidth',0.7);
    set(ax1,'YTick',1:1:numel(grids),...   
            'YTickLabel',grids,...
            'FontName','Times New Roman','FontSize',12);
    ylim([0.25,numel(grids)+0.75]);
    colormap summer % Change the color scheme
    % X label is too close to the left border, move it by 2,5 %
    fig_relative_position1 = get(ax1,'OuterPosition');
    fig_relative_position1([1,3]) = fig_relative_position1([1,3]) +0.025;
    set(ax1,'OuterPosition',fig_relative_position1);   
    if numel(legend_text) == 1
        % No need to display legend, only one branch limit exists
    else
        l=legend(legend_text,'Location','SouthEast');
        box(l,'off');
    end    
    if strcmp(display_option,'percent')
        xlabel('Number of branch violations in percent');
    else
        xlabel('Number of branch violations');
    end

ax2 = subplot(2,1,2); hold on; 
    barh(nodes_with,'BarLayout','grouped','BarWidth',0.7);
    set(ax2,'YTick',1:1:numel(grids),...    
            'YTickLabel',grids,...
            'FontName','Times New Roman','FontSize',12);
        % X label is too close to the left border, move it by 2,5 %
    fig_relative_position2 = get(ax2,'OuterPosition');
    fig_relative_position2([1,3]) = fig_relative_position1([1,3]);
    set(ax2,'OuterPosition',fig_relative_position2);
    
    % If nonround values are shown on xaxis, the algorithm detects it and
    % adjusts (node 1,2,3,4...) is okay, but (node 0.1, 0.3...) is not
    xtick_values = get(ax2,'XTick');
    if sum(floor(xtick_values - min(xtick_values)) == 0) > 1
        set(ax2,'XTick',min(xtick_values) : 1 : max(xtick_values));
    end
    
    ylim([0.25,numel(grids)+0.75]);
    if numel(legend_text) == 1
        % No need to display legend, only one branch limit exists
    else
        l=legend(legend_text,'Location','SouthEast');
        box(l,'off');
    end    
    if strcmp(display_option,'percent')
        xlabel('Number of branches with branch violations in percent');
    else
        xlabel('Number of branches with branch violations');
    end

end
