function handles = draw_power_losses(handles,dataset, grid_no)

% draw_power_losses shows a graph of:
% - active power losses at various voltage levels and for total network
% throughout iterations for one dataset

d= handles.NAT_Data;
list_of_grids = fields(d.Result);
cg = list_of_grids{grid_no};
observed_dataset = dataset;

draw_power_losses_voltage_level(d,cg,observed_dataset);

end

function d = draw_power_losses_voltage_level(d,cg,observed_dataset)
    
    % Observe only specific voltage levels
    active_power_losses_at_voltage_level = ...
        squeeze(d.Result.(cg).Power_Loss_Analysis(observed_dataset,:,:)); 
    voltage_level_id = d.Grid.(cg).Branches.grouped_voltage_level_id;
    voltage_level_kv = d.Grid.(cg).Branches.grouped_voltage_level_val / 1e3;
    
    % automatic text formation (prefix for ylabel and legend)
    % The prefix of the power losses - kW or MW
    if size(int2str(round(max(active_power_losses_at_voltage_level(:)))),2) > 6
        % If the number is larger than 0.1e6
        prefix = 1e6; ylabel_prefix = 'M';
    else
        % The number is in the 1e3 range
        prefix = 1e3; ylabel_prefix = 'k';
    end
    legend_text=cell(1,numel(voltage_level_id)+1);
    for i = 1:numel(voltage_level_id)
        legend_text{i} = ['Voltage level ', int2str(voltage_level_kv(i)), ...    
            ' kV (ID ' int2str(voltage_level_id(i)) ') '];
    end
    legend_text{end} = 'Total network losses';
    
    % Plot figure
    figure; hold on; %grid on; %box on
    set(gcf,'Position',[28,278,800*[1,0.5626]]);    
    plot(active_power_losses_at_voltage_level/prefix,...
    'LineWidth',1.5,'LineStyle','-');    
    xlabel('Iteration','FontName','Times New Roman','FontSize',13);
    ylabel(['Active power losses \rm (' ylabel_prefix 'W)'],'FontName','Times New Roman','FontSize',13)
    legend(legend_text,'Location','NorthWest');

end
