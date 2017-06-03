function varargout = input_check_plot(ext_obj, cond1, cond2, varargin)
    % input_check(object, number_of_inputs, inputs)
    if cond2 > cond1
        error('Error using input check plot function')
    end
    % Transform varargin to varargin from main function
    funargin = varargin{1};
    
    % cond1 matches the higher varargin input that includes xls output
    % option    
    % cond2 matches the lower varargin input that does not include xls
    % output option
    
    if numel(funargin) == cond2
        for i = 1 : cond2
            varargout{i} = funargin{i};
            if ischar(funargin{i})         
                if strcmp(funargin{i},'all')
                    varargout{i} = 1 : ext_obj.Datasets;
                end
            else
                varargout{i} = funargin{i};
            end
        end
        varargout{cond1+1} = 0; % plot function is turned off
    elseif numel(funargin) == cond1
        for i = 1 : cond1
            varargout{i} = funargin{i};
            if ischar(funargin{i}) 
                if strcmp(funargin{i},'all')
                    varargout{i} = 1 : ext_obj.Datasets;
                end
                
                if strcmp(funargin{i},'plot') && i == cond1 
                    varargout{i} = 1;
                end
                
            else
                varargout{i} = funargin{i};
            end
        end        
    
    else
        error('ErrorTests:convertTest',...
            'Error using function\nToo many/few input arguments.');
    end
    
    if isempty(funargin) 
        varargout{1}=0;
    end
end