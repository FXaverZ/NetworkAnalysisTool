function [Screensize,Colormap] = set_graphical_values(inp)
% Get screensize for monitor display
scr = get(0,'Screensize');
Screensize = [0.1*[scr(3),scr(4)],0.5*[scr(3),scr(4)]];

switch inp
    case 'color10'
        % Colorbrewer scheme (diverging), RGB, 10 color scheme!
        Colormap = [103,0,31; 178,24,43; 214,96,77; 244,165,130; 253,219,199; 209,229,240; 146,197,222; 67,147,195; 33,102,172; 5,48,97]/256;
    case 'color12'
        % Colorobrewer scheme (quantative),RGB, 12 color sceheme!
        Colormap = [141,211,199;255,255,179;190,186,218;251,128,114;128,177,211;153,180,98;179,222,105;252,205,229;217,217,217;188,128,189;204,235,197;255,237,111]/256;
    case 'gray'
        Colormap = [37,37,37; 82,82,82;115,115,115;141,141,141;160,160,160;189,189,189;217,217,217]/256;
        %cmp=colormap(gray(128));        
        %Colormap = cmp(1:10:size(cmp,1),:)*256;       
    case ''
        % Do nothing
end

end

