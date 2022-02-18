function handles = grid_power_loss_comparison(handles,observed_dataset)

    

% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT
cd = observed_dataset;

% Check d.Result for (cg) grids
list_of_grids = fields(d.Result);

% If voltage levels will change with variations, the unique_voltage_levels
% array will include ALL possible voltage levels. With this we can create a
% universal comparison array.

all_voltage_level_vals=cell(1,numel(list_of_grids));
all_voltage_levels_ids=cell(1,numel(list_of_grids));

for cg = 1 : numel(list_of_grids)
    grid = list_of_grids{cg};    
    all_voltage_level_vals{cg} = d.Grid.(grid).Branches.grouped_voltage_level_val;
    all_voltage_level_ids{cg} = d.Grid.(grid).Branches.grouped_voltage_level_id;
end

[unique_voltage_level_vals,idx] = unique(cell2mat(all_voltage_level_vals(:)));
unique_voltage_level_ids = cell2mat(all_voltage_level_ids(:));
unique_voltage_level_ids = unique_voltage_level_ids(idx);

% Universal comparison arrays. Rows are grids, columns are voltage levels.
% The last column is the sum of all voltage levels
Comparison_of_Max_Power_Losses = ...
    zeros(numel(list_of_grids),numel(unique_voltage_level_vals)+1); 
Comparison_of_Min_Power_Losses = ...
    zeros(numel(list_of_grids),numel(unique_voltage_level_vals)+1);
Comparison_of_Std_Power_Losses = ...
    zeros(numel(list_of_grids),numel(unique_voltage_level_vals)+1); 

for cg = 1 : numel(list_of_grids)
    grid = list_of_grids{cg};        
    % if voltage levels change throughout the variations, the algorithm
    % compares all possible voltage levels with the specific voltage level
    % of the observed variant and pairs it with the correct column. If a
    % voltage level in a specific variant doesnt exist, a zero will be
    % there
    observed_voltage_level_ids = d.Grid.(grid).Branches.grouped_voltage_level_id;    
    for i = 1 : numel(observed_voltage_level_ids)        
        Comparison_of_Max_Power_Losses(cg,...
            unique_voltage_level_ids == observed_voltage_level_ids) = ...
            d.Result.(grid).Power_Loss_Summary.Max_Power_Loss_Values(cd,i);
        
        Comparison_of_Min_Power_Losses(cg,...
            unique_voltage_level_ids == observed_voltage_level_ids) = ...
            d.Result.(grid).Power_Loss_Summary.Min_Power_Loss_Values(cd,i);     
        
        Comparison_of_Std_Power_Losses(cg,...
            unique_voltage_level_ids == observed_voltage_level_ids) = ...
            d.Result.(grid).Power_Loss_Summary.Std_Power_Loss_Values(cd,i);         
    end
    Comparison_of_Max_Power_Losses(cg,end) = d.Result.(grid).Power_Loss_Summary.Max_Power_Loss_Values(cd,end);
    Comparison_of_Min_Power_Losses(cg,end) = d.Result.(grid).Power_Loss_Summary.Min_Power_Loss_Values(cd,end);
    Comparison_of_Std_Power_Losses(cg,end) = d.Result.(grid).Power_Loss_Summary.Std_Power_Loss_Values(cd,end);

end

    
    % In order to display grids from top to bottom, we have to flip dimensions
    % of array Comparison_of_Number_of_Violations and list_of_grids
    barh_values.Comparison_of_Max_Power_Losses = ...
        flipdim(Comparison_of_Max_Power_Losses,1);
    barh_values.Comparison_of_Min_Power_Losses = ...
        flipdim(Comparison_of_Min_Power_Losses,1);    
    barh_values.Comparison_of_Std_Power_Losses = ...
        flipdim(Comparison_of_Std_Power_Losses,1);

    barh_values.Grids = flipdim(list_of_grids,1);
    
    % Plot the result comparisons
    comparison = barh_values.Comparison_of_Max_Power_Losses;
    grids = barh_values.Grids ;
  
    
figure;  set(gcf,'Position',[28,278,800*[1,0.85]]); % Set the size of the figure

ax1 = subplot(2,1,1); hold on; 
    barh(comparison,'BarLayout','grouped','BarWidth',0.7);    
    set(ax1,'YTick',1:1:numel(grids),...   
            'YTickLabel',grids,...
            'FontName','Times New Roman','FontSize',12);
    ylim([0.25,numel(grids)+0.75]);
    colormap summer % Change the color scheme
    % X label is too close to the left border, move it by 2,5 %
    fig_relative_position1 = get(ax1,'OuterPosition');
    fig_relative_position1([1,3]) = fig_relative_position1([1,3]) +0.025;
    set(ax1,'OuterPosition',fig_relative_position1);    
    
    l=legend(legend_text,'Location','SouthEast');
    box(l,'off');
    xlabel('Number of voltage violations');

    
end