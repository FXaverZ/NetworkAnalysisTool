function push_network_scenario_show_settings_Callback_Add(hObject, handles)
%PUSH_NETWORK_SCENARIO_SHOW_SETTINGS_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

cur_scen_set = handles.Current_Settings.Simulation.Scenarios;

fprintf('\n+-------------------+\n');
fprintf('| Scenario Settings |\n');
fprintf('+-------------------+\n\n');

for i=1:cur_scen_set.Number
	if i > 1
		fprintf('\n');
	end
	fprintf(['-- Scenario No. ',num2str(i),'\n']);
	cur_scen = cur_scen_set.(['Sc_',num2str(i)]);
	fprintf('\tO General scenario description:\n');
	fprintf(['\t\tFilename:    ',cur_scen.Filename,'\n']);	
	fprintf(['\t\tDescription: ',stradapt(cur_scen.Description),'\n']);
	fprintf('\tO Time Settings:\n');
	fprintf(['\t\tSeason: ',cur_scen.Time.Season,'\n']);
	fprintf(['\t\tWeekday: ',cur_scen.Time.Weekday,'\n']);
	fprintf('\tO Residential Load Settings:\n');
	wc = cur_scen.Households.WC_Selection;
	idx = strcmp(handles.System.wc_households(:,2),wc);
	fprintf(['\t\tWorst Case: ',handles.System.wc_households{idx,1},'\n']);
	fprintf('\tO E-Mobility Load Settings:\n');
	if cur_scen.El_Mobility.Number > 0
		fprintf(['\t\tE-Mobility Share: ',num2str(cur_scen.El_Mobility.Number),' %%\n']);
	else
		fprintf('\t\tNo E-Mobility present in Scenario\n');
	end
	fprintf('\tO PV-Infeed Settings:\n');
	if sum(cur_scen.Solar.Number) > 0
		fprintf('\t\tPV-plants per Node (share in %%):\n');
		fprintf(['\t\t\tFix installed plants: ',num2str(cur_scen.Solar.Number(1)),' %%\n']);
		fprintf(['\t\t\tTracker plants:       ',num2str(cur_scen.Solar.Number(2)),' %%\n']);
		fprintf(['\t\tMean installed power: ',...
			num2str(cur_scen.Solar.Power_sgl/1000),' kWp\n']);
		fprintf(['\t\t\tStd. Deviation: ',...
			num2str(cur_scen.Solar.Power_sgl_dev),' %%\n']);
		fprintf(['\t\tMean Orientation (0° = South, -90° = East): ',...
			num2str(cur_scen.Solar.mean_Orientation),' °\n']);
		fprintf(['\t\t\tStd. Deviation: ',...
			num2str(cur_scen.Solar.dev_Orientation),' °\n']);
		fprintf(['\t\tMean Inclination (0° = horizontal, -90° = vertikal): ',...
			num2str(cur_scen.Solar.mean_Inclination),' °\n']);
		fprintf(['\t\t\tStd. Deviation: ',...
			num2str(cur_scen.Solar.dev_Inclination),' °\n']);
		fprintf(['\t\tPerformance Ratio: ',...
			num2str(cur_scen.Solar.Performance_Ratio),' [-]\n']);
		fprintf(['\t\t\tStd. Deviation: ',...
			num2str(cur_scen.Solar.dev_Performance_Ratio),' %%\n']);
		fprintf(['\t\tEfficiency: ',...
			num2str(cur_scen.Solar.Efficiency*100),' %%\n']);
		fprintf(['\t\t\tStd. Deviation: ',...
			num2str(cur_scen.Solar.dev_Efficiency),' %%\n']);
		wc = cur_scen.Solar.WC_Selection;
		idx = strcmp(handles.System.wc_generation(:,2),wc);
		fprintf(['\t\tWorst Case: ',handles.System.wc_generation{idx,1},'\n']);
	else
		fprintf('\t\tNo PV-Infeed present in Scenario\n');
	end
end
fprintf('\n+-------------------+\n\n');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

function str = stradapt(str)
str = strrep(str, '%', '%%');
end

