function push_network_scenario_show_settings_Callback_Add(hObject, handles)
%PUSH_NETWORK_SCENARIO_SHOW_SETTINGS_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

mh = handles.text_message_main_handler;
buttontext = get(hObject, 'String');
mh.add_line('"',buttontext,'" pushed, printing scenario settings:');
cur_scen_set = handles.Current_Settings.Simulation.Scenarios;
mh.add_line('+-------------------+');
mh.add_line('| Scenario Settings |');
mh.add_line('+-------------------+');
mh.level_up();
for i=1:cur_scen_set.Number
	mh.add_line('-- Scenario No. ',i);
	cur_scen = cur_scen_set.(['Sc_',num2str(i)]);
	mh.level_up();
	mh.add_line('O General scenario description:');
	mh.level_up();
	mh.add_line('Filename:    ',cur_scen.Filename);	
	mh.add_line('Description: ',cur_scen.Description);
	mh.level_down();
	mh.add_line('O Time Settings:');
	mh.level_up();
	mh.add_line('Season: ',cur_scen.Time.Season);
	mh.add_line('Weekday: ',cur_scen.Time.Weekday);
	mh.level_down();
	mh.add_line('O Residential Load Settings:');
	wc = cur_scen.Households.WC_Selection;
	mh.level_up();
	idx = strcmp(handles.System.wc_households(:,2),wc);
	mh.add_line('Worst Case: ',handles.System.wc_households{idx,1});
	mh.level_down();
	mh.add_line('O E-Mobility Load Settings:');
	mh.level_up();
	if cur_scen.El_Mobility.Number > 0
		mh.add_line('E-Mobility Share: ',num2str(cur_scen.El_Mobility.Number),' %');
	else
		mh.add_line('No E-Mobility present in Scenario');
	end
	mh.level_down();
	mh.add_line('O PV-Infeed Settings:');
	mh.level_up();
	if sum(cur_scen.Solar.Number) > 0
		mh.add_line('PV-plants per Node (share in %):');
		mh.level_up();
		mh.add_line('Fix installed plants: ',num2str(cur_scen.Solar.Number(1)),' %');
		mh.add_line('Tracker plants:       ',num2str(cur_scen.Solar.Number(2)),' %');
		mh.level_down();
		mh.add_line('Mean installed power: ',...
			num2str(cur_scen.Solar.Power_sgl/1000),' kWp');
		mh.level_up();
		mh.add_line('Std. Deviation: ',...
			num2str(cur_scen.Solar.Power_sgl_dev),' %');
		mh.level_down();
		mh.add_line('Mean Orientation (0° = South, -90° = East): ',...
			num2str(cur_scen.Solar.mean_Orientation),' °');
		mh.level_up();
		mh.add_line('Std. Deviation: ',...
			num2str(cur_scen.Solar.dev_Orientation),' °');
		mh.level_down();
		mh.add_line('Mean Inclination (0° = horizontal, -90° = vertikal): ',...
			num2str(cur_scen.Solar.mean_Inclination),' °');
		mh.level_up();
		mh.add_line('Std. Deviation: ',...
			num2str(cur_scen.Solar.dev_Inclination),' °');
		mh.level_down();
		mh.add_line('Performance Ratio: ',...
			num2str(cur_scen.Solar.Performance_Ratio),' [-]');
		mh.level_up();
		mh.add_line('Std. Deviation: ',...
			num2str(cur_scen.Solar.dev_Performance_Ratio),' %');
		mh.level_down();
		mh.add_line('Efficiency: ',...
			num2str(cur_scen.Solar.Efficiency*100),' %');
		mh.level_up();
		mh.add_line('Std. Deviation: ',...
			num2str(cur_scen.Solar.dev_Efficiency),' %');
		mh.level_down();
		wc = cur_scen.Solar.WC_Selection;
		idx = strcmp(handles.System.wc_generation(:,2),wc);
		mh.add_line('Worst Case: ',handles.System.wc_generation{idx,1});
	else
		mh.add_line('No PV-Infeed present in Scenario');
	end
	mh.level_down();
	mh.level_down();
end
mh.level_down();

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
refresh_message_text_operation_finished (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

