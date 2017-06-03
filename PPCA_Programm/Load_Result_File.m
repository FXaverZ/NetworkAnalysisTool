classdef Load_Result_File < handle
    % LOAD_RESULT_FILE    Voltage violation post processing  class
    % Version:                 1.0
    % Erstellt von:            Matej Rejc - 14.05.2013
    % Letzte Änderung durch:   Matej Rejc - 14.05.2013
    
    properties
        Result_Filenames = [];
        Result_Filepath = [];
        Simulation_Options = [];
    end
    
    methods
        
        function obj = Load_Result_File(ext_obj)              
            obj.Result_Filenames = ext_obj.Result_Filenames;
            obj.Result_Filepath = ext_obj.Result_Filepath;
            obj.Simulation_Options = ext_obj.Simulation_Options;
        end
        
        
        function [Result,Grid,Load_Infeed_Data] = load(obj,scenario)
            % Load relevent data from mat file
            Result = []; Grid = []; Load_Infeed_Data = [];
            load([obj.Result_Filepath,filesep,obj.Result_Filenames{scenario}],...
                'Result','Grid','Load_Infeed_Data');
        end
        
    end
end