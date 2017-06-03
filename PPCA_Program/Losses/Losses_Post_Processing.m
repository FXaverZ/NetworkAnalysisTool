classdef Losses_Post_Processing
    % LOSSES_POST_PROCESSING    Voltage violation post processing  class
    % Version:                 1.0
    % Erstellt von:            Matej Rejc - 14.05.2013
    % Letzte Änderung durch:   Matej Rejc - 14.05.2013
    
    properties
        Scenarios;
        Grid_Variants;
        Datasets;
        Timepoints;
        Result_Filenames;
        Result_Filepath;
        Scenario_Filepath;
        Simulation_Options;
    end
        
    properties(GetAccess = 'private') 
        Result_Files;        
    end
    
    % Result_Post_Processing method definitions
    methods
        function obj = Losses_Post_Processing(information_file)
            % Define the information of the results for postprocessing
            inp_info = load(information_file);
            
            obj.Result_Filepath = inp_info.result_filepath;
            obj.Result_Filenames = inp_info.result_filename;
            obj.Scenario_Filepath = inp_info.scenario_filepath;
            obj.Simulation_Options = inp_info.simulation_options;
            
            obj.Scenarios = inp_info.scenarios;
            obj.Grid_Variants = inp_info.variants;
            obj.Datasets = inp_info.datasets;
            obj.Timepoints = inp_info.simulation_options.Timepoints;

        end
        % function Losses_Post_Processing: create object function
        
        function compare_losses(obj)
            % Load result file for scenario
            obj.Result_Files = Load_Result_File(obj);
            [Result, Grid, ~] = obj.Result_Files.load(1);
            
            Result.g01_Base_NS_50_Nodes.Power_Loss_Analysis(:,:,1)
            
        end
    end
end