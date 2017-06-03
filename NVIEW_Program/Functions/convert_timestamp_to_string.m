function output = convert_timestamp_to_string(Filename_Format, inp_ts)

% Years
yyyy = int2str(inp_ts(1));
% Month
if inp_ts(2) < 10
    set_month = ['0',int2str(inp_ts(2))];
else
    set_month = int2str(inp_ts(2));
end
% Days
if inp_ts(3) < 10
    set_day = ['0',int2str(inp_ts(3))];
else
    set_day = int2str(inp_ts(3));
end
% Hours
if inp_ts(4) < 10
    set_hour = ['0',int2str(inp_ts(4))];
else
    set_hour = int2str(inp_ts(4));
end
% Minutes
if inp_ts(5) < 10
    set_min = ['0',int2str(inp_ts(5))];
else
    set_min = int2str(inp_ts(5));
end

% Set date in string - output creation
if strcmp(Filename_Format,'yymmdd_HHMM')
    set_year = yyyy(end-1:end);
    output = [set_year,set_month,set_day,'_',set_hour,set_min];% Date in string
elseif strcmp(Filename_Format,'yyyymmdd_HHMM')
    set_year = yyyy;
    output = [set_year,set_month,set_day,'_',set_hour,set_min];% Date in string
elseif strcmp(Filename_Format,'system time')
    set_year = yyyy;
    output = str2double([set_year,set_month,set_day,set_hour,set_min]);% Date in string
else
    error('Error at Filename_format input');
end


end



