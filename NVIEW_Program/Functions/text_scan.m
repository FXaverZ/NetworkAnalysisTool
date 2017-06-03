%TEXT_SCAN    Auxillary function
%Reads text file

% Version:                 1.0
% Created by:              Matej Rejc - 29.01.2013
% Recently modified by:    Matej Rejc - 29.04.2013

function ftext = text_scan(filepath, filename)
% function text_scan - scans text file and defines matlab raw
% format of text file - read data file
    if iscell(filename) == 1 & numel(filename) == 1
        filename = filename{1};
    elseif iscell(filename) == 1 & numel(filename) ~= 1
        error('Error at text scan, erroneous input')
    end
    % scan text
    fid=fopen([filepath,filesep,filename]);
    i=1; v=1e+6;
    tmp=fgetl(fid);
    if ~isempty(tmp)
        ftext(i,1:length(tmp))=tmp;
    else
        i=0;
    end
    for j = 1 : v
        try
            tmp=fgetl(fid);
            if ~ischar(tmp),
                break,
            end
            ftext(i+1,1:length(tmp))=tmp;
            i=i+1;
        end
    end
    fclose(fid);
end % function text_scan