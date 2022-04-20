function longname = pvplant2str(handles,pvplant)
%PVPLANT2STR Summary of this function goes here
%   Detailed explanation goes here
typ = handles.System.sola.Typs{pvplant.Typ,1};
longname = [typ(1:4),' - ',...
    num2str(pvplant.Power_Installed'/1000,'%.2f'),' kWp - ',...
    num2str(pvplant.Orientation,'%.1f'),'° - ',...
    num2str(pvplant.Inclination,'%.1f'),'°'];
end

