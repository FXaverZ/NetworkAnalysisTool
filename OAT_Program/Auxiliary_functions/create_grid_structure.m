function [handles,Grid_Data] = create_grid_structure(handles,data)
% Create grid structure. Define bus/branch array
if handles.NVIEW_Control.Simulation_Options.Use_Grid_Variants == 1
    Grid_List = handles.NVIEW_Control.Simulation_Description.Variants;
else
    Grid_List = fields(data.Grid);
    if numel(Grid_List) > 1
        Grid_Result_List = fields(data.Result);
        if numel(Grid_Result_List) > 1
            error('Result file does not match selection - too many grid variants');
        else
            Grid_List = intersect(Grid_List,Grid_Result_List);
        end
    end
    handles.NVIEW_Control.Simulation_Description.Variants = Grid_List;
end

Grid_Data = [];
for i = 1 : numel(Grid_List)
    
    % clear variable@for : bus_name and set size for observed grid
    clear bus*
    bus_name = cell(numel(data.Grid.(Grid_List{i}).All_Node.Points),1);
    bus_V_pp = zeros(numel(data.Grid.(Grid_List{i}).All_Node.Points),1);
    bus_V_pe = zeros(numel(data.Grid.(Grid_List{i}).All_Node.Points),1);
    bus_Vmax = zeros(numel(data.Grid.(Grid_List{i}).All_Node.Points),1);
    bus_Vmin = zeros(numel(data.Grid.(Grid_List{i}).All_Node.Points),1);
    bus = zeros(numel(data.Grid.(Grid_List{i}).All_Node.Points),5);
    % clear variable@for: branch_name, branch_from, branch_to, define size
    clear branch*
    branch_name = cell(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_from = cell(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_to = cell(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_Vf_pe = zeros(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_Vt_pe = zeros(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_Vf_pp = zeros(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_Vt_pp = zeros(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_Ilim = zeros(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch_Slim = zeros(numel(data.Grid.(Grid_List{i}).Branches.Grouped),1);
    branch = zeros(numel(data.Grid.(Grid_List{i}).Branches.Grouped),8);
    
    % Define bus names for grid
    for j = 1 : numel(data.Grid.(Grid_List{i}).All_Node.Points)
        bus_name{j,1} = data.Grid.(Grid_List{i}).All_Node.Points(j).Node_Name;
        bus_V_pp(j,1) = data.Grid.(Grid_List{i}).All_Node.Points(j).Rated_Voltage_phase_phase;
        bus_V_pe(j,1) = data.Grid.(Grid_List{i}).All_Node.Points(j).Rated_Voltage_phase_earth(1);
        bus_Vmax(j,1) = max(data.Grid.(Grid_List{i}).All_Node.Points(j).Voltage_Limits);
        bus_Vmin(j,1) = min(data.Grid.(Grid_List{i}).All_Node.Points(j).Voltage_Limits);
    end
    
    % Define branch names and from-to bus pairs
    for j = 1 : numel(data.Grid.(Grid_List{i}).Branches.Grouped)
        branch_from{j,1} = data.Grid.(Grid_List{i}).Branches.Grouped(j).Node_1_Name;
        branch_to{j,1} = data.Grid.(Grid_List{i}).Branches.Grouped(j).Node_2_Name;
        branch_name{j,1} = data.Grid.(Grid_List{i}).Branches.Grouped(j).Branch_Name;
        
        branch_Vf_pe(j,1) = data.Grid.(Grid_List{i}).Branches.Grouped(j).Rated_Voltage1_phase_earth(1);
        branch_Vf_pp(j,1) = data.Grid.(Grid_List{i}).Branches.Grouped(j).Rated_Voltage1_phase_earth(1);
        branch_Vt_pe(j,1) = data.Grid.(Grid_List{i}).Branches.Grouped(j).Rated_Voltage1_phase_phase(1);
        branch_Vt_pp(j,1) = data.Grid.(Grid_List{i}).Branches.Grouped(j).Rated_Voltage2_phase_phase(1);
        
        branch_Ilim(j,1) = data.Grid.(Grid_List{i}).Branches.Grouped(j).Current_Limits;
        branch_Slim(j,1) = data.Grid.(Grid_List{i}).Branches.Grouped(j).App_Power_Limits;
    end
    
    % Create internal reference structure
    bus(:,1) = 1 : size(bus_name,1);
    bus(:,2) = bus_V_pp;
    bus(:,3) = bus_V_pe;
    bus(:,4) = bus_Vmax;
    bus(:,5) = bus_Vmin;
    
    % Write to main branch array
    for j = 1 : size(branch_name,1)
        branch(j,1) = find(strcmp(bus_name,branch_from{j,1}),1);
        branch(j,2) = find(strcmp(bus_name,branch_to{j,1}),1);
    end
    branch(:,3) = branch_Vf_pp;
    branch(:,4) = branch_Vt_pp;
    branch(:,5) = branch_Vf_pe;
    branch(:,6) = branch_Vt_pe;
    branch(:,7) = branch_Ilim;
    branch(:,8) = branch_Slim;
    
    % Write to structure
    Grid_Data.(Grid_List{i}).bus = bus;
    Grid_Data.(Grid_List{i}).bus_name = bus_name;
    Grid_Data.(Grid_List{i}).branch = branch;
    Grid_Data.(Grid_List{i}).branch_name = branch_name;
    % Branch data
    % 1..From bus, 2..To bus, 3..Vpp from, 4..Vpp to, 5..Vpe from,
    % 6..Vpe to, 7..Ilim (A), 8..Slim (VA)
    % Bus data
    % 1..bus no, 2..Vpp, 3..Vpe, 4..Vmax, 5..Vmin
end

end
