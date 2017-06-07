function [season, weekd, parafilemname] = day2sim_parameter(Model, act_day)
%DAY2SIM_PARAMETER   calculates out of a daynumber the corresponding simulation parameters 
%   [SEASON, WEEKD, PARAFILEMNAME] = DAY2SIM_PARAMETER(MODEL, ACT_DAY) gets out of
%   the actual daynumber ACT_DAY in form of a serial date number e.g. created by the
%   DATNUM function, the corresponding simulation parametes:
%		* Shortname of the current season SEASON
%		* Shortname of the current day WEEKD
%		* full filname to the parameterfilename for the load simulation PARAFILEMNAME
%
%	The MODEL structure is a description of the corresponding load simulation model,
%	this sturcture contains at least 
%		* two {3,1} Cell-Arrays with the used short names of the seasons and daytyps 
%			MODEL.Seasons		
%				1st row: shortname for summer season
%				2nd row: shortname for the transition time
%				3rd row: shortname for winter season
%			MODEL.Weekdays
%				1st row: shortname for working day typs (Monday till Friday)
%				2nd row: shortname for saturday
%				3rd row: shortname for sunday
%		* one string entry, which indikates the seperation marker of filenameparts
%		  for the used paramterfiles:
%		MODEL.Seperator
%
%   The days are asigned to the seasson according to VDEW standard load profiles
%   Summer: 15.5. - 14.9.   --> 123 days
%   Winter: 1.11. - 20.3.   --> 140 days
%   Transi: remaining days  --> 102 days
%
%	The shortnames SEASON and WEEKD can be mapped over HANDLES.SYSTEM.seasons and
%	HANDLES.SYSTEM.weekdays to userfriendlier long names.
%
%   See also datenum, get_default_values_GAT

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 02.02.2015
% Letzte Änderung durch:   Franz Zeilinger - 30.09.2015

% das aktuelle Jahr ermitteln:
Current_Year = str2double(datestr(act_day,'yyyy'));

% assign the day to the corresbonding season:
sum_start = datenum(['15.05.',num2str(Current_Year)],'dd.mm.yyyy'); % Sommer-Beginn
sum_end = datenum(['14.09.',num2str(Current_Year)],'dd.mm.yyyy');   % Sommer-Ende
win_start = datenum(['01.11.',num2str(Current_Year)],'dd.mm.yyyy'); % Winter-Beginn
win_end = datenum(['20.03.',num2str(Current_Year)],'dd.mm.yyyy');   % Winter-Ende

% Die umliegenden Jahre ermitteln:
Next_Year = datenum(num2str(Current_Year+1),'yyyy');
Current_Year = datenum(num2str(Current_Year),'yyyy');

% Jahreszeit ermitteln:
if act_day >= sum_start && act_day < sum_end + 1
	season = Model.Seasons{1};
elseif (act_day >= Current_Year && act_day < win_end + 1) || ...
		(act_day >= win_start && act_day < Next_Year)
	season = Model.Seasons{2};
else
	season = Model.Seasons{3};
end

% Wochentag ermitteln:
day_type = weekday(act_day);
if day_type > 1 && day_type < 7
	weekd = Model.Weekdays{1};
elseif day_type == 7
	weekd = Model.Weekdays{2};
else
	weekd = Model.Weekdays{3};
end
sep = Model.Seperator;
parafilemname = ['Param',sep,season,sep,weekd];
end

