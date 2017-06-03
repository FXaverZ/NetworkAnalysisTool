function handles = post_voltage_analysis(handles)
%POST_VOLTAGE_ANALYSIS - post analyzing function
%    This function postpocesses the gathered data of the
%    online_voltage_analysis after all simulations were made.

%POST_VOLTAGE_ANALYSIS    
    % O P T I O N S
    %
    %   'Summary'
    %     Simple summary option is used for a fast overview of voltage violations.
    %     The following results are given:    
    %          - Number of all voltage violations in grid 
    %          - Percentage of simulation time when voltages violated limits in grid     
    %          - Timepoints where voltage violations occured
    %
    %   'Full report'
    %      An in-depth analysis of voltage violations. The following results are given 
    %      (to be defined later)
    %          - Number of all voltage violations in grid 
    %          - Percentage of simulation time when voltages violated limits in grid     
    %          - Timepoints where voltage violations occured
    %          - Names of nodes, where voltage violations occured
    %          - Values of over- and under-voltages at voltage violation timepoints
    %          - Highest and lowest voltage in system
    %          - ...
    
  
% Getting access to the data-object
d = handles.NAT_Data;
% this object represents a connection to the stored data within the NAT

% Check d.Result.Grid for tested models - we look for (cg) d.Result.Grid.(cg)
Grids = fields(d.Result);

% ---------------------------------------------------------------------
% The following process checks all analysed grids
%
% ---------------------------------------------------------------------

for i = 1 : numel(Grids)  % Number of topologies, i.e. models analysed

    for cd = 1 : size(d.Result.(Grids{i}).Voltage_Violation,1)
        % Iterate through all datasets cd = size(results,1)
        
        % Access the d.Result.Grid.(cg).Voltage_Violation(cd,all_timepoints,all_nodes)
        % The squeezed values for dataset cd and topology (cg) are saved in
        % voltage_violation_results
        voltage_violation_results =...
            squeeze( d.Result.(Grids{i}).Voltage_Violation(cd,:,:) );
        
        
        if sum(voltage_violation_results(:)) == 0
           % If no voltage violations occur 
           fprintf('-----------------------------------------------------------------------------\n');
           fprintf('Summary of voltage violation analysis                     \n');
           fprintf('-----------------------------------------------------------------------------\n');
           fprintf('No voltage violations!\n');
           fprintf('-----------------------------------------------------------------------------\n');

        else
            % If voltage violations occur, a in-depth statistical analysis
            % is performed
            
            %-------------------------------------------------------------------
            % Summary of entire grid: 
            %
            %   - grid_experienced_voltage_violations
            %       Number of times the grid experienced voltage violations. 
            %       Array: [all violations, violation of limit 1, violation of limit 2]
            %
            %   - grid_experienced_voltage_violations_proc
            %       Voltage violations in grid in procent.
            %       Array: [all violations, violation of limit 1, violation of limit 2]
            %
            %   - timepoints
            %       Number of time points of the simulations
            %
            %   - voltage_violations_all_at_timepoints
            %       At what time points was there a voltage violation in
            %       grid. The array is a true/false array, where true is
            %       the time point when one or more voltage violations
            %       occured.
            %   - voltage_violations1_at_timepoints
            %       At what time points was there a voltage violation of
            %       >>limit 1<< in the grid. The array is a true/false array, 
            %       where true is the time point when one or more voltage violations
            %       occured.
            %
            %   - voltage_violations2_at_timepoints
            %       At what time points was there a voltage violation of
            %       >>limit 2<< in the grid. The array is a true/false array, 
            %       where true is the time point when one or more voltage violations
            %       occured.           
                
                
              voltage_violations_all_at_timepoints = sum(voltage_violation_results ~= 0,2) > 0;              
              voltage_violations1_at_timepoints    = sum(voltage_violation_results == 1,2) > 0;
              voltage_violations2_at_timepoints    = sum(voltage_violation_results == 2,2) > 0;    
              
              % Number of times the grid experienced voltage violations
              grid_experienced_voltage_violations(1) = sum(voltage_violations1_at_timepoints);
              grid_experienced_voltage_violations(2) = sum(voltage_violations2_at_timepoints);
              grid_experienced_voltage_violations(3) = sum(voltage_violations_all_at_timepoints);
              
              % Number of timepoints analysed
              timepoints = size(d.Result.Grid.(Grids{i}).Voltage_Violation,2);
              
              % Proc. value of experienced voltage violations during the
              % simulation procedure
              grid_experienced_voltage_violations_proc = 100*grid_experienced_voltage_violations/timepoints;
            
              
              % Define the names of nodes with voltage limit violations
              % First define the ids (true/false) of nodes where voltages
              % are violated
              voltage_violations_all_at_nodes_ids = sum(voltage_violation_results ~= 0,1) > 0;
              voltage_violations1_at_nodes_ids = sum(voltage_violation_results == 1,1) > 0;
              voltage_violations2_at_nodes_ids = sum(voltage_violation_results == 2,1) > 0;
              
              number_of_nodes_with_voltage_violations(1) = sum(voltage_violations1_at_nodes_ids);
              number_of_nodes_with_voltage_violations(2) = sum(voltage_violations2_at_nodes_ids);
              number_of_nodes_with_voltage_violations(3) = sum(voltage_violations_all_at_nodes_ids);

              % Define the names of nodes in the grid ************ TO BE
              % CHANGED to point to the correct GRID ! Currently only the
              % active grid is saved
              node_name = cell(numel(d.Grid.All_Node.Points),1);
              for k = 1 : numel(d.Grid.All_Node.Points)
                 node_name{k} = d.Grid.All_Node.Points(k).Node_Name ;
              end
              
              % Names of nodes where voltage violations occur!
              voltage_violations_all_at_nodes_names = node_name(voltage_violations_all_at_nodes,1);
              voltage_violations1_at_nodes_names = node_name(voltage_violations1_at_nodes,1);
              voltage_violations2_at_nodes_names = node_name(voltage_violations2_at_nodes,1);

              
              if grid_experienced_voltage_violations(1) == grid_experienced_voltage_violations(3) &...
                      grid_experienced_voltage_violations(2) == 0 
                  % If second limit is not defined!
                  fprintf('-----------------------------------------------------------------------------\n');
                  fprintf('Summary of voltage violation analysis                     \n');
                  fprintf('-----------------------------------------------------------------------------\n');
                  fprintf(['Number of voltage violations : '...
                      int2str(grid_experienced_voltage_violations(3)),...
                      ' / '  int2str(timepoints) ' (' ...
                      num2str(round(100*grid_experienced_voltage_violations_proc(3))/100)  ' %%)\n']);
   
                  fprintf(['Number of nodes where voltage violations occur : ' int2str(number_of_nodes_with_voltage_violations(3)) '\n']);
                  fprintf('---------------\n');
                  fprintf(['Nodes where voltage violations occur : \n']);
                  for k = 1 : numel(voltage_violations_all_at_nodes_names)
                      fprintf(['   - Node ' voltage_violations_all_at_nodes_names{k} '\n']);
                  end      
                  fprintf('-----------------------------------------------------------------------------\n');
                  
                  
              else % If two voltage limits are present
                  fprintf('-----------------------------------------------------------------------------\n');
                  fprintf('Summary of voltage violation analysis                     \n');
                  fprintf('-----------------------------------------------------------------------------\n');
                  fprintf(['Number of all voltage violations (limit 1 and 2) : '...
                      int2str(grid_experienced_voltage_violations(3)),...
                      ' / '  int2str(timepoints) ' (' ...
                      num2str(round(100*grid_experienced_voltage_violations_proc(3))/100)  ' %%)\n']);
                  
                  fprintf(['Number of voltage violations at limit 1          : '...
                      int2str(grid_experienced_voltage_violations(1)),...
                      ' / '  int2str(timepoints) ' (' ...
                      num2str(round(100*grid_experienced_voltage_violations_proc(1))/100)  ' %%)\n']);
                  fprintf(['Number of voltage violations at limit 2          : '...
                      int2str(grid_experienced_voltage_violations(2)),...
                      ' / '  int2str(timepoints) ' (' ...
                      num2str(round(100*grid_experienced_voltage_violations_proc(2))/100)  ' %%)\n']);
                  fprintf(['Number of nodes where voltage violations (limit 1 and 2) occur : ' int2str(number_of_nodes_with_voltage_violations(3)) '\n']);
                  fprintf(['Number of nodes where voltage violations (limit 1) occur       : ' int2str(number_of_nodes_with_voltage_violations(1)) '\n']);
                  fprintf(['Number of nodes where voltage violations (limit 2) occur       : ' int2str(number_of_nodes_with_voltage_violations(2)) '\n']);

                  fprintf('---------------\n');
                  fprintf(['Nodes where voltage violations (limit 1) occur : \n']);
                  for k = 1 : numel(voltage_violations1_at_nodes_names)
                      fprintf(['   - Node ' voltage_violations1_at_nodes_names{k} '\n']);
                  end
                  fprintf('---------------\n');
                  fprintf(['Nodes where voltage violations (limit 2) occur : \n']);
                  for k = 1 : numel(voltage_violations2_at_nodes_names)
                      fprintf(['   - Node ' voltage_violations2_at_nodes_names{k} '\n']);
                  end                  
                  fprintf('---------------\n');
                  fprintf(['Nodes where voltage violations (limit 1 and 2) occur : \n']);
                  for k = 1 : numel(voltage_violations_all_at_nodes_names)
                      fprintf(['   - Node ' voltage_violations_all_at_nodes_names{k} '\n']);
                  end                  
                  
                  fprintf('-----------------------------------------------------------------------------\n');

              end % Is there one or two voltage limits?
        end % Voltage violation check - seperate no voltage violations and voltage violation if sentence
        
        %%!! PRIKAZATI SE DATASET, TOPOLOGIJO, KAKO DRUGO INFO!
        
    end % Dataset active!
    
end % Observed model - .(cg).

