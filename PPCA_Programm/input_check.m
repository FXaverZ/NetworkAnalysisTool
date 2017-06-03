function varargout = input_check(cond1, cond2,varargin)
    % input_check(Higher_number_of_inputs,Lower_number_of_inputs,inputs)
    
    % Check if condition 1 must be a higher value than condition 2
    if cond1 < cond2
        error('Error at input check inputs');
    end
    % Transform varargin to varargin from main function
    funargin = varargin{1};
    
    % cond1 matches the higher varargin input that includes xls output
    % option    
    % cond2 matches the lower varargin input that does not include xls
    % output option
    
    if numel(funargin) == cond1
        for i = 1 : cond1
            varargout{i} = funargin{i};
            if ischar(funargin{i}) && i == cond1
                if strcmp(funargin{i},'xls')
                    varargout{i}  = 1; % XLS output
                else
                    varargout{i}  = 0; % No XLS output
                end
            else
                if cond1 == cond2
                   % If no xls option is available at input, 
                   % cond1 and cond2 must be same values 
                   varargout{i} = funargin{i};
                end
            end
        end        
    elseif numel(funargin) == cond2
        for i = 1 : cond2
            varargout{i} = funargin{i};
        end
        varargout{i+1} = 0; % No XLS output
    else
        error('ErrorTests:convertTest',...
            'Error using function\nToo many/few input arguments.');
    end
    
end