function Screensize = change_screensize(handles)
% Get screensize for monitor display

% Screen resolution
Screen_Resolution = get(0,'Screensize');

% Default value
Default_Screensize = set_graphical_values('');
% Current value
Current_Screensize = handles.System.Graphics.Screensize;

Possible_ScreensizeOptions =[ Default_Screensize(3:4);
                              0.7*(Screen_Resolution(3:4)./Default_Screensize(3:4)).*Default_Screensize(3:4);
                              0.4*(Screen_Resolution(3:4)./Default_Screensize(3:4)).*Default_Screensize(3:4);
                              [640,320];
                              [400,220];
                             ];

% Find at what possible screensize we are currently
Idx = find(Possible_ScreensizeOptions(:,1) == Current_Screensize(3)  & Possible_ScreensizeOptions(:,2) == Current_Screensize(4));

if Idx ~= size(Possible_ScreensizeOptions,1)
    Idx = Idx + 1;
    
else
    Idx = 1;
end

Screensize = [Default_Screensize(1),Default_Screensize(2),...
              Possible_ScreensizeOptions(Idx,1),Possible_ScreensizeOptions(Idx,2)];

end
