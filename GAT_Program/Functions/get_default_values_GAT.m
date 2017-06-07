function handles = get_default_values_GAT(handles)
%GET_DEFAULT_VALUES_GAT   loads the defaults of all settings in the GAT
%   HANDLES = GET_DEFAULT_VALUES_NAT7(HANDLES) adds to the HANDLES
%   Structure the default settings for the program behavior in form of the
%   substructure 'Current_Settings'. This function has to be called right
%   after creating the main NAT7-GUI and before other settings are loaded
%
%   See also GUIDATA.

% Version:                 1.0
% Created by:              Franz Zeilinger - 29.09.2015
% Last change by:          Franz Zeilinger - 30.09.2015

%------------------------------------------------------------------------------------
% System-Values - are not to be altered during runtime!
%------------------------------------------------------------------------------------

% Standardbezeichnungen:
System.seasons =   {... % Typen der Jahreszeiten
	'Summer', 'Summer';... 
	'Transi', 'Transition';...
	'Winter', 'Winter';...
	}; 
System.weekdays =  {... % Typen der Wochentage
	'Workda', 'Workday';...
	'Saturd', 'Saturday';...
	'Sunday', 'Sunday';...
	}; 
end

