function str = sec2str(t)
%SEC2STR    ermittelt Zeitstring aus Zeitspanne
%    STR = SEC2STR(T) ermittelt aus einer Zeitspanne T in Sekunden einen String der
%    Form 'mm months dd days HHh MMmin SS.SSSs' und gibt diesen zurück. Je
%    nach Lände der Zeitspanne werden keine Angaben zu HH und MM gemacht
%    bzw. die Genauigkeit der Zahlendarstellung angepasst.

% Erstellt von:            Franz Zeilinger - 11.08.2010
% Letzte Änderung durch:   Franz Zeilinger - 22.11.2021

sec_lin = datenum('1900-01-01 00:00:01')-datenum('1900-01-01 00:00:00');
date = datenum('1900-01-01 00:00:00')+t*sec_lin;
[~,m,d,h,min,sec] = datevec(date);
m = m-1;
d = d-1;
if (m > 1)
    str = [num2str(m),' months ',num2str(d),' days ',num2str(h),'h ',...
		num2str(min),'min ',num2str(floor(sec)),'s'];
elseif (m <= 1) && (m > 0)
    str = [num2str(m),' month ',num2str(d),' day ',num2str(h),'h ',...
		num2str(min),'min ',num2str(floor(sec)),'s'];
elseif (d > 1)
    str = [num2str(d),' days ',num2str(h),'h ',...
		num2str(min),'min ',num2str(floor(sec)),'s'];
elseif (d <= 1) && (d > 0)
    str = [num2str(d),' day ',num2str(h),'h ',...
		num2str(min),'min ',num2str(floor(sec)),'s'];
elseif (d <= 0) && (h > 0)
	str = [num2str(h),'h ',...
		num2str(min),'min ',num2str(floor(sec)),'s'];
elseif (h <= 0) && (min > 0)
	str = [num2str(min),'min ',num2str(floor(sec)),'s'];
else
	str = [num2str(sec,'%3.1f'),'s'];
end
		