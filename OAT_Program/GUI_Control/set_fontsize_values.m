function [FontSize] = set_fontsize_values(inp)

if ischar(inp) & strcmp(inp,'default')
    FontSize = 13; % Default fontsize
elseif isnumeric(inp)
    FontSize = inp;
end

end