function handles = adapt_input_data_new_timesettings(handles)
%ADAPT_INPUT_DATA_NEW_TIMESETTINGS Summary of this function goes here
%   Detailed explanation goes here

% Zugriff auf Datenobjekt:
d = handles.NAT_Data;

% load the information from the data extraction (Varialbes "Data_Extract", "System",
% "Scenario_Settings"): 
load([handles.Current_Settings.Simulation.Scenarios_Path,filesep,'Scenario_Settings.mat']);

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

fprintf('\nStart with adapting of input data...\n');
tic; %Zeitmessung start
% get the raw data and remove the old data:
Load_Infeed_Data = d.Load_Infeed_Data;

% What is the factor of the time resolutions:
t_fac = round(handles.Current_Settings.Data_Extract.Time_Resolution / Data_Extract.Time_Resolution);

% List with the available data:
to_do = {...
	'Load_Data', 'Households';...
	'Sola_Data', 'Solar';...
	'Elmo_Data', 'El_Mobility';...
	'LVGr_Data', 'LV_Grid_Input';...
	};

num_data_set = handles.Current_Settings.Data_Extract.Number_Data_Sets;

% go trough the data:
for j=1:num_data_set;
	
	fprintf(['\t\tLoadprofile No. ',num2str(j),' of ',...
		num2str(num_data_set)]);
	% clear the changed values:
	c = [];
	
	% Load the data:
	for i = 1:size(to_do,1)
		c.(to_do{i,1}) = ...
		Load_Infeed_Data.(['Set_',num2str(j)]).(to_do{i,2}).(['Data',data_typ_ex]);
		d.Load_Infeed_Data.(['Set_',num2str(j)]).(to_do{i,2}).(['Data',data_typ_ex]) = [];
		d.Load_Infeed_Data.(['Set_',num2str(j)]).(to_do{i,2}).(['Data',data_typ]) = [];
	end
	
	if Data_Extract.get_Sample_Value && Data_Extract.Time_Resolution == 1
		% remove the last value (addititional second due to simulation of synthetic
		% load profiles):
		for i = 1:size(to_do,1)
			if ~strcmp('Elmo_Data',to_do{i,1})
				c.(to_do{i,1}) = c.(to_do{i,1})(1:end-1,:);
			end
		end
	end
	
	% reshape the original data array:
	for i = 1:size(to_do,1)
		c.(to_do{i,1}) = reshape(c.(to_do{i,1}),...
			t_fac,[],size(c.(to_do{i,1}),2));
		switch data_typ
			case '_Sample'
				c.(to_do{i,1}) = squeeze(c.(to_do{i,1})(1,:,:));
			case '_Min'
				c.(to_do{i,1}) = squeeze(min(c.(to_do{i,1})));
			case '_Max'
				c.(to_do{i,1}) = squeeze(max(c.(to_do{i,1})));
			case '_Mean'
				c.(to_do{i,1}) = squeeze(mean(c.(to_do{i,1})));
			case '_05P_Quantil'
				c.(to_do{i,1}) = squeeze(quantile(c.(to_do{i,1}),0.05));
			case '_95P_Quantil'
				c.(to_do{i,1}) = squeeze(quantile(c.(to_do{i,1}),0.95));
			otherwise
				errorstring = ['Data types of the loaded data is not compatibel with',...
					' the simulation settings! Abort simulation...'];
				fprintf(['\n',errorstring,'\n']);
				errordlg(errorstring);
				return;
		end
		d.Load_Infeed_Data.(['Set_',num2str(j)]).(to_do{i,2}).(['Data',data_typ]) = c.(to_do{i,1});
	end
	t = toc;
	fprintf([' finished. Elapsed time: ',...
		sec2str(t),...
		'. Remaining time: ',...
		sec2str(t/(j/num_data_set) - t),'\n']);
end

end

