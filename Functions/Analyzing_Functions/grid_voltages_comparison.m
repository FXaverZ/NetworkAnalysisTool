function handles = grid_voltages_comparison(handles)

    

% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT

% Check d.Result for (cg) grids
list_of_grids = fields(d.Result);

% Comparison_of_... is an array of 
% <no.of_grids x 3=(1st limit, 2nd limit, 1st+2nd]>

Comparison_of_Number_of_Violations = zeros(numel(list_of_grids),3); 
Comparison_of_Number_of_Nodes_With_Violations =  zeros(numel(list_of_grids),3);
Comparison_of_Number_of_Violations_percent =  zeros(numel(list_of_grids),3);
Comparison_of_Number_of_Nodes_With_Violations_percent = zeros(numel(list_of_grids),3);

if numel(list_of_grids) > 1
    
    for cg = 1 : numel(list_of_grids)
        grid = list_of_grids{cg};
        % Number of violations for observed grid are written into the array
        Comparison_of_Number_of_Violations(cg,:) = ...
            d.Result.(grid).Voltage_Violation_Summary.Number_of_Violations;
        Comparison_of_Number_of_Nodes_With_Violations(cg,:) = ...
            d.Result.(grid).Voltage_Violation_Summary.Number_of_Nodes_With_Violations;
        Comparison_of_Number_of_Violations_percent(cg,:) = ...
            d.Result.(grid).Voltage_Violation_Summary.Number_of_Violations_percent;
        Comparison_of_Number_of_Nodes_With_Violations_percent(cg,:) = ...
            d.Result.(grid).Voltage_Violation_Summary.Number_of_Nodes_With_Violations_percent;
    end
    
    
    % In order to display grids from top to bottom, we have to flip dimensions
    % of array Comparison_of_Number_of_Violations and list_of_grids
    barh_values.Comparison_of_Number_of_Violations = ...
        flipdim(Comparison_of_Number_of_Violations,1);
    barh_values.Comparison_of_Number_of_Nodes_With_Violations = ...
        flipdim(Comparison_of_Number_of_Nodes_With_Violations,1);
    
    barh_values.Comparison_of_Number_of_Violations_percent = ...
        flipdim(Comparison_of_Number_of_Violations_percent,1);
    barh_values.Comparison_of_Number_of_Nodes_With_Violations_percent = ...
        flipdim(Comparison_of_Number_of_Nodes_With_Violations_percent,1);
    barh_values.Grids = flipdim(list_of_grids,1);
    
    % Plot the result comparisons
    barh_node_violations_grouped(barh_values.Comparison_of_Number_of_Violations,...
        barh_values.Comparison_of_Number_of_Nodes_With_Violations, ...
        barh_values.Grids, 'values');
    
    barh_node_violations_grouped(barh_values.Comparison_of_Number_of_Violations_percent,...
        barh_values.Comparison_of_Number_of_Nodes_With_Violations_percent, ...
        barh_values.Grids, 'percent');
    
else
    disp('Only one grid analysed - can not compare voltage violations');
end

end

function [] = barh_node_violations_grouped(numb_of_violations, numb_of_viol_nodes, grids, display_option)
% input variables
    % numb_of_violations - number of node violations in numbers or in percent
    % numb_of_viol_nodes - number of nodes violated in numbers or in percent
    % grids - list of grids
    % display_option - either in numbers 'values' or in percent 'percent'

legend_text{1} = 'Voltage limit';
legend_text{2} = 'Add. voltage limit';
legend_text{3} = 'Any voltage limit';
% If there is no additional limit, or it is never exceeded, we can 
% remove it from the graph. Therefore  there is no need for
% the additional limit and the "any limit" value
    
if sum(numb_of_violations(:,2)==0) == size(numb_of_violations,1) 
    numb_of_violations(:,2:end) = []; 
    numb_of_viol_nodes(:,2:end) = []; 
    legend_text(2:end)=[];
    % Delete the additional and "any" limit column
end
    
figure;  set(gcf,'Position',[28,278,800*[1,0.85]]); % Set the size of the figure

ax1 = subplot(2,1,1); hold on; 
    barh(numb_of_violations,'BarLayout','grouped','BarWidth',0.7);
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
        % No need to display legend, only one voltage limit exists
    else
        l=legend(legend_text,'Location','SouthEast');
        box(l,'off'); 
    end
    if strcmp(display_option,'percent')
        xlabel('Number of voltage violations in percent');
    else
        xlabel('Number of voltage violations');
    end

ax2 = subplot(2,1,2); hold on; 
    barh(numb_of_viol_nodes,'BarLayout','grouped','BarWidth',0.7);
    set(ax2,'YTick',1:1:numel(grids),...    
            'YTickLabel',grids,...
            'FontName','Times New Roman','FontSize',12);
        % X label is too close to the left border, move it by 2,5 %
    fig_relative_position2 = get(ax2,'OuterPosition');
    fig_relative_position2([1,3]) = fig_relative_position1([1,3]);
    set(ax2,'OuterPosition',fig_relative_position2);
    ylim([0.25,numel(grids)+0.75]);
    if numel(legend_text) == 1
        % No need to display legend, only one voltage limit exists
    else
        l=legend(legend_text,'Location','SouthEast');
        box(l,'off')
    end
    
    if strcmp(display_option,'percent')
        xlabel('Number of nodes with voltage violations in percent');
    else
        xlabel('Number of nodes with voltage violations');
    end

end
