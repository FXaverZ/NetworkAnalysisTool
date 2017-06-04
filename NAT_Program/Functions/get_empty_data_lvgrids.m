function get_empty_data_lvgrids(handles, varargin)
%GET_DATA_LVGRIDS Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
	% als Zweites Argument wurde ein aktueller Index übergeben für eine
	% Generierung von mehreren Datensätzen...
	idx_act = varargin{1};
else
	idx_act = [];
end

LV_Grid_Input.Data_Sample = [];
LV_Grid_Input.Data_Mean = [];
LV_Grid_Input.Data_Min = [];
LV_Grid_Input.Data_Max = [];
LV_Grid_Input.Data_05P_Quantil = [];
LV_Grid_Input.Data_95P_Quantil = [];
LV_Grid_Input.Content = {};

% Zugriff auf das Datenobjekt:
d = handles.NAT_Data;

% Ergebnis zurückschreiben:
if isempty(idx_act)
	% Es wird nur ein Datensatz generiert:
	d.Load_Infeed_Data.Set_1.LV_Grid_Input = LV_Grid_Input;
	if ~isfield(d.Load_Infeed_Data.Set_1, 'Table_Network')
		d.Load_Infeed_Data.Set_1.Table_Network = handles.Current_Settings.Table_Network;
	end
else
	d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).LV_Grid_Input = LV_Grid_Input;
	if ~isfield(d.Load_Infeed_Data.(['Set_',num2str(idx_act)]), 'Table_Network')
		d.Load_Infeed_Data.(['Set_',num2str(idx_act)]).Table_Network = handles.Current_Settings.Table_Network;
	end
end

end

