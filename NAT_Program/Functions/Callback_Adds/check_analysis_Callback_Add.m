function check_analysis_Callback_Add (hObject, handles, task)
%CHECK_ANALYSIS_BRANCH_DATA_SAVE_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here
switch task
	case 'branch_data_save'
		handles.Current_Settings.Simulation.Save_Branch_Results = get(hObject,'Value');
	case 'branch_violation'
		handles.Current_Settings.Simulation.Branch_Violation_Analysis = get(hObject,'Value');
	case 'power_loss'
		handles.Current_Settings.Simulation.Power_Loss_Analysis = get(hObject,'Value');
	case 'power_loss_data_save'
		handles.Current_Settings.Simulation.Save_Power_Loss_Results = get(hObject,'Value');
	case 'voltage_data_save'
		handles.Current_Settings.Simulation.Save_Voltage_Results = get(hObject,'Value');
	case 'voltage_violation'
		handles.Current_Settings.Simulation.Voltage_Violation_Analysis = get(hObject,'Value');
end	

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% Update handles structure
guidata(hObject, handles);
end

