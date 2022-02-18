function popup_time_resolution_Callback_Add (hObject, handles)
%POPUP_TIME_RESOLUTION_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

% get the Duration of the simulation stepsize in seconds:
secs = handles.System.time_resolutions{get(hObject,'Value'),2};
handles.Current_Settings.Data_Extract.Time_Resolution = secs;

% adjust the Timpoints_per_dataset:
if ~handles.Current_Settings.Data_Extract.get_Time_Series
	% if no time series: sim-duration is one day
	handles.Current_Settings.Data_Extract.Timepoints_per_dataset = round(24*60*60/secs);
else
	% if time series, use the number of days of the timeseries:
	handles.Current_Settings.Data_Extract.Timepoints_per_dataset = ...
		round(handles.Current_Settings.Data_Extract.Time_Series.Duration*24*60*60/secs);
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Structure aktualisieren:
guidata(hObject, handles);
end

