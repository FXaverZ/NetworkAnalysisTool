function [adapt_input_data_time, error, handles] = check_inputdata_vs_simsettings(handles)
%CHECK_INPUTDATA_VS_SIMSETTINGS Summary of this function goes here
%   Detailed explanation goes here

error = false;
adapt_input_data_time = [];

% which data typ has to be simulated?
if handles.Current_Settings.Data_Extract.get_Sample_Value
	data_typ = '_Sample';
end
if handles.Current_Settings.Data_Extract.get_Mean_Value
	data_typ = '_Mean';
end
if handles.Current_Settings.Data_Extract.get_Max_Value
	data_typ = '_Max';
end
if handles.Current_Settings.Data_Extract.get_Min_Value
	data_typ = '_Min';
end
if handles.Current_Settings.Data_Extract.get_05_Quantile_Value
	data_typ = '_05P_Quantil';
end
if handles.Current_Settings.Data_Extract.get_95_Quantile_Value
	data_typ = '_95P_Quantil';
end

% Check, if the simulation- and current available input data are compatibel, so load the
% information from the data extraction (Varialbes "Data_Extract", "System", "Scenario_Settings"):
load([handles.Current_Settings.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat']);

% Are enough data sets available?
if handles.Current_Settings.Data_Extract.Number_Data_Sets <= Data_Extract.Number_Data_Sets
	
else
	fprintf('\nNot enough data sets present! Abort simulation...\n');
	errordlg('Not enough data sets present! Abort simulation...');
	error = true;
	return;
end

% Check the time resolutions
adapt_input_data_time = false;
if handles.Current_Settings.Data_Extract.Time_Resolution > Data_Extract.Time_Resolution
	answer = questdlg({['The time resolutions of the loaded input data and the current ',...
		'simulation data is different!'];...
		'';...
		'Wich time resolution should be used?'},'Time Resolution...',...
		'Current Simulation Settings','Input Data','Input Data');
	switch answer
		case 'Input Data'
			handles.Current_Settings.Data_Extract.Time_Resolution = Data_Extract.Time_Resolution;
		case 'Current Simulation Settings'
			% Adaption of the input data is required
			adapt_input_data_time = true;
		otherwise
			error = true;
			return;
	end
elseif handles.Current_Settings.Data_Extract.Time_Resolution == Data_Extract.Time_Resolution
	% No action is needed!
else
	errorstring = 'Time resolutions of the data is not compatibel! Abort simulation...';
	fprintf(['\n',errorstring,'\n']);
	errordlg(errorstring);
	error = true;
	return;
end

% which data typ was extracted?
if Data_Extract.get_Sample_Value
	data_typ_ex = '_Sample';
end
if Data_Extract.get_Mean_Value
	data_typ_ex = '_Mean';
end
if Data_Extract.get_Max_Value
	data_typ_ex = '_Max';
end
if Data_Extract.get_Min_Value
	data_typ_ex = '_Min';
end
if Data_Extract.get_05_Quantile_Value
	data_typ_ex = '_05P_Quantil';
end
if Data_Extract.get_95_Quantile_Value
	data_typ_ex = '_95P_Quantil';
end

% check, if the data typs are compatibel:
if ~strcmp(data_typ_ex, data_typ)
	% Check, if the special case of sample-data in seconds is present:
	if ~(strcmp(data_typ_ex,'_Sample') && Data_Extract.Time_Resolution == 1)
		errorstring = ['Data types of the loaded data is not compatibel with',...
			' the simulation settings! Abort simulation...'];
		fprintf(['\n',errorstring,'\n']);
		errordlg(errorstring);
		error = true;
		return;
	end
end

end

