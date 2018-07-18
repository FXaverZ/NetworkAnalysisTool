function handles = draw_violations(handles,dataset,grid_no)
% draw_violations shows a graph of:
% - voltages at nodes (it is required to save the values!), limits at nodes
%   and the conditional value if voltage limits are exceeded
% - branch values at lines and transformers (it is required to save the
%   values!), limits at branches and the conditional values if branch limits
%   are exceeded

d= handles.NAT_Data;

% List of grids
list_of_grids = fields(d.Result);
% Observed grid
cg = list_of_grids{grid_no};
% Observed dataset
observed_dataset = dataset;
% Observe values 
observed_phase = 1;

% Observed value
observed_col = 3; % Values of lines ( S (VA) )

% Draw voltage violations
draw_voltages(d,cg,observed_dataset,observed_phase);

% Draw branch violations
draw_branch_values(d,cg,observed_dataset,observed_col);
end

function d = draw_voltages(d,cg,observed_dataset,observed_phase)
    
    % Rated voltage for all nodes
    rated_voltage = vertcat(d.Grid.(cg).All_Node.Points.Rated_Voltage_phase_earth);
    % Values of voltages
    voltage_value = squeeze( d.Result.(cg).Node_Voltages(observed_dataset,...
                     :, :,observed_phase) );
    voltage_value_pu =voltage_value./ repmat(rated_voltage(:,observed_phase)',size(voltage_value,1),[]);
    % Voltage limits
    voltage_limits = vertcat(d.Grid.(cg).All_Node.Points.Voltage_Limits)/100;
        % Voltage violations
    voltage_violations = squeeze( d.Result.(cg).Voltage_Violation_Analysis(...
        observed_dataset,:,:) );
    
    % Better plot is given by scaling the values near the voltage values
    % (i.e. easy zoom)
    shown_ylimit =[min([voltage_value_pu(:);voltage_limits(:)])-0.1,...
                   max([voltage_value_pu(:);voltage_limits(:)])+0.1 ];               
    plotted_voltage_violations=voltage_violations;    
    plotted_voltage_violations(voltage_violations==0) = min(shown_ylimit);    
    plotted_voltage_violations(voltage_violations==1) = mean(shown_ylimit);
    plotted_voltage_violations(voltage_violations==2) = max(shown_ylimit);
    
    % For prettier plotting, plots with all 0s are replaced with NaN and
    % are thus not shown on graph
    plotted_voltage_violations(:,...
        sum(plotted_voltage_violations==min(shown_ylimit)) == size(plotted_voltage_violations,1)) = NaN;

    % Plot voltages for all nodes (p.u.), their limits (voltage limits) and
    % the voltage violation conditions
    
    figure; hold on; %grid on; %box on
    set(gcf,'Position',[28,278,800*[1,0.5626]]);    
    plot(voltage_value_pu,'LineStyle','-');
    
    plot(repmat((voltage_limits(:,1))',size(voltage_value,1),[]),...
        'LineStyle','-.');
    plot(repmat((voltage_limits(:,2))',size(voltage_value,1),[]),...
        'LineStyle','-.');    
    plot(repmat((voltage_limits(:,3))',size(voltage_value,1),[]),...
        'LineStyle',':');
    plot(repmat((voltage_limits(:,4))',size(voltage_value,1),[]),...
        'LineStyle',':');
    plot(plotted_voltage_violations,'LineWidth',2.5,'LineStyle',':')    
    ylim(shown_ylimit+1e-2);      
    xlabel('Iteration','FontName','Times New Roman','FontSize',13);
    ylabel('Voltage\rm (p.u.)','FontName','Times New Roman','FontSize',13)
    all_node_names = d.Result.(cg).Voltage_Violation_Summary.All_Node_Names;
    legend(all_node_names,'Location','NorthWest');

end

function d = draw_branch_values(d,cg,observed_dataset,observed_col)
    
    observed_col = 3; % Values of lines ( S (VA) )
    branch_value = squeeze( d.Result.(cg).Branch_Values(observed_dataset,...
                     :, :,observed_col) )/1e6;
    branch_limits = vertcat(d.Grid.(cg).Branches.Grouped.App_Power_Limits) / 3;    
    branch_violation = squeeze( d.Result.(cg).Branch_Violation_Analysis(observed_dataset,:,:));
    % For prettier plotting, plots with all 0s are replaced with NaN and
    % are thus not shown on graph
    branch_violation(:,sum(branch_violation==0) == size(branch_violation,1)) = NaN;
    
    figure; hold on; %grid on; %box on
    set(gcf,'Position',[28,278,800*[1,0.5626]]);
    plot(branch_value,'LineStyle','-')
    plot(repmat((branch_limits(:,1)/1e6)',max(size(branch_value)),1),...
        'LineStyle',':');    
    plot(repmat((branch_limits(:,2)/1e6)',max(size(branch_value)),1),...
        'LineStyle',':')  ;     
    plot(repmat((branch_limits(:,3)/1e6)',max(size(branch_value)),1),...
        'LineStyle',':') ;      
    plot(repmat((branch_limits(:,4)/1e6)',max(size(branch_value)),1),...
        'LineStyle',':')  ;     

    plot(branch_violation/(4/max(max(branch_value))),'LineWidth',2.5,'LineStyle',':');
    
    ylim([min(min(branch_value))-0.1, max(max(branch_value))+0.1]);
    xlabel('Iteration','FontName','Times New Roman','FontSize',13);
    ylabel('Element apparent power\rm (MVA)','FontName','Times New Roman','FontSize',13)
    
    all_branch_names = d.Result.(cg).Branch_Violation_Summary.Branch_Names;
    legend(all_branch_names,'Location','NorthWest');

end
