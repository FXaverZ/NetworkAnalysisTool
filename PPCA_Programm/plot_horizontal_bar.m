classdef plot_horizontal_bar
    
    properties
        gc_size;
        % User's screensize
        gc_subplots;
        % Number of subplots
        
        ax_position;
        % Axis relative position
        gc_handles; 
        % My plot figure handle        
        ax_handles;
        % Axis ids - cells
    end
    
    properties(GetAccess = 'private')
        screensize;        
        % Monitor resolution
        dataset;
        % Dataset information
        scenario;
        % Scenario
        grid;
        % Grid
        cmap;
    end
    
    methods
        function obj = plot_horizontal_bar(number_of_subplots)
            obj.screensize = get(0,'ScreenSize');
            obj.gc_size = [obj.screensize(3)*0.1 , obj.screensize(4)*0.1,obj.screensize(3)*0.5*[1,0.8]];
            obj.gc_handles = figure;
            set(obj.gc_handles,'Position',obj.gc_size);
            
            obj.gc_subplots = number_of_subplots;
            % Reset information
            obj.dataset=[];
            obj.scenario=[];
            obj.grid=[];
            
            % Colormap - user defined
            obj.cmap = [079,129,189;192,080,077;155,187,089;128,100,162;247,150,070;
                        000,000,000;075,172,198;031,073,125;000,176,080;127,127,127]/256;
        end
        
        function obj = datasets(obj,varargin)
            %function [] = datasets(input_values,axis,xlabel,ytick_numerical,ytick_text,scen,grid)
            if numel(varargin) == 7
                input = varargin{1};
                axc = varargin{2};   
                xlabel_txt = varargin{3};
                ytick = varargin{4};
                ytick_label  = varargin{5};  
                scenario = varargin{6};
                grid = varargin{7};
            elseif numel(varargin) == 5 && varargin{2} ~= 1
                input = varargin{1};
                axc = varargin{2};   
                xlabel_txt = varargin{3};
                ytick = varargin{4};
                ytick_label  = varargin{5}; 
                scenario = [];
                grid = [];
            else
                error('ErrorTests:convertTest',...
                'Error using plot_horizontal_bar\nToo many/few input arguments.');
            end
            
            if ~isempty(scenario) && ~isempty(grid) & isempty(obj.dataset)
                obj.dataset=[scenario,grid];
            end
            
            title(['Dataset comparison for scenario ' int2str(obj.dataset(1)) ' and grid ' int2str(obj.dataset(2)), ''],...
                'FontName','Times New Roman','FontSize',12)
            for l = 1 : numel(ytick_label)
               if size(ytick_label{l},2) > 24
                   ytick_label{l} = [ytick_label{l}(1:21),'...'];
               end
            end
            % Subplot graphics
            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            hold on;
            
            % input ... input value
            % ytick ... numerical y tick values [1,5,10,15,...]
            % ytick_label ... y tick values in txt format [a1, a5, a10,
            % a15,...]
            
            barh(input,'BarLayout','grouped','BarWidth',0.7);
            set(ax_handles{axc},'FontName','Times New Roman','FontSize',12,...
                'YTick',ytick,...
                'YTickLabel',ytick_label);
            % Limit the y axis to fit figure
            ylim([0.25,size(input,1)+0.75]);
            
            colormap(obj.cmap); % Change the color scheme
            % If axis must be moved (long y label names)
            % ax_position{axc} = get(ax_handles{axc},'OuterPosition');
            % ax_position{axc}([1,3]) = ax_position{axc}([1,3]) +0.025;
            % set(ax_handles{axc},'OuterPosition',ax_position{axc});
            
            % X label
            xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
        end % display : datasets 
        
        function obj = grids(obj,varargin)
        %function [] = datasets(input_values,axis,xlabel,ytick_numerical,ytick_text,scen,grid)
            if numel(varargin) >= 6
                input = varargin{1};
                axc = varargin{2};   
                xlabel_txt = varargin{3};
                ytick = varargin{4};
                ytick_label  = varargin{5};  
                scenario = varargin{6};
                legend_txt = varargin{7};
            elseif numel(varargin) == 5 && varargin{2} ~= 1
                input = varargin{1};
                axc = varargin{2};   
                xlabel_txt = varargin{3};
                ytick = varargin{4};
                ytick_label  = varargin{5}; 
                scenario = [];
                legend_txt = [];
            else
                error('ErrorTests:convertTest',...
                'Error using plot_horizontal_bar\nToo many/few input arguments.');
            end
            
            if ~isempty(scenario) & isempty(obj.scenario)
                obj.scenario=scenario;
            end  
            
            for l = 1 : numel(ytick_label)
                if size(ytick_label{l},2) > 24
                    ytick_label{l} = [ytick_label{l}(1:21),'...'];
                end
            end
                    
            % Subplot graphics
            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            hold on;    
            
            title(['Grid comparisons for scenario ' int2str(obj.scenario), ''],...
                'FontName','Times New Roman','FontSize',12);
            
            barh(input,'BarLayout','grouped','BarWidth',0.7);
            set(ax_handles{axc},'FontName','Times New Roman','FontSize',12,...
                'YTick',ytick,...
                'YTickLabel',ytick_label);
            % Limit the y axis to fit figure
            ylim([0.25,size(input,1)+0.75]);
            
            colormap(obj.cmap); % Change the color scheme
            % If axis must be moved (long y label names)
            % ax_position{axc} = get(ax_handles{axc},'OuterPosition');
            % ax_position{axc}([1,3]) = ax_position{axc}([1,3]) +0.025;
            % set(ax_handles{axc},'OuterPosition',ax_position{axc});
            
            % X label
            xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
            if ~isempty(legend_txt)
                for l = 1 : numel(legend_txt)
                    if size(legend_txt{l},2) > 24
                        legend_txt{l} = [legend_txt{l}(1:21),'...'];
                    end
                end
                l=legend(legend_txt,'Location','SouthEast');
                box(l,'off')
            end
            if max(input(:)) > 1e3 % If input are the losses
                % no need to limit xaxis
            else
                if max(input(:)) == 100
                    upper_lim = 100;
                else
                    upper_lim = ceil(1.25*max(input(:))/10)*10;
                    if upper_lim >= 100
                        upper_lim = 100;
                    end
                end            
                xlim([0,upper_lim]);            
            end
        end % display : grids
        
        function obj = grids_and_scenarios(obj,varargin)
        %function [] = datasets(input_values,axis,xlabel,ytick_numerical,ytick_text,legend_text,title_text)
            if numel(varargin) == 7
                if isempty(varargin{3}) == 0
                    input = varargin{1};
                    axc = varargin{2};
                    xlabel_txt = varargin{3};
                    ytick = varargin{4};
                    ytick_label  = varargin{5};
                    title_txt = varargin{6};
                    legend_txt = varargin{7};
                else
                    input = varargin{1};
                    axc = varargin{2};
                    xlabel_txt = [];
                    ytick = varargin{4};
                    ytick_label  = varargin{5};
                    title_txt = varargin{6};
                    legend_txt = varargin{7};                    
                end
                
            elseif numel(varargin) == 6 && varargin{2} ~= 1
                if isempty(varargin{3}) == 0
                    input = varargin{1};
                    axc = varargin{2};
                    xlabel_txt = varargin{3};
                    ytick = varargin{4};
                    ytick_label  = varargin{5};
                    title_txt = varargin{6};
                    legend_txt = [];
                else
                    input = varargin{1};
                    axc = varargin{2};
                    xlabel_txt = [];
                    ytick = varargin{4};
                    ytick_label  = varargin{5};
                    title_txt = varargin{6};
                    legend_txt = [];                    
                end
            elseif numel(varargin) == 5 && varargin{2} ~= 1
                if isempty(varargin{3}) == 0
                    input = varargin{1};
                    axc = varargin{2};
                    xlabel_txt = varargin{3};
                    ytick = varargin{4};
                    ytick_label  = varargin{5};
                    title_txt = [];
                    legend_txt = [];
                else
                    input = varargin{1};
                    axc = varargin{2};
                    xlabel_txt = [];
                    ytick = varargin{4};
                    ytick_label  = varargin{5};
                    title_txt = [];
                    legend_txt = [];                    
                end                
                
            else
                error('ErrorTests:convertTest',...
                'Error using plot_horizontal_bar\nToo many/few input arguments.');
            end
            % Remove underlines - the plotting function turns the "_" into
            % subscripts
            for i = 1 : numel(legend_txt)
               legend_txt{i}(legend_txt{i} =='_') = ' ';
            end
            for l = 1 : numel(legend_txt)
                if size(legend_txt{l},2) > 24
                    legend_txt{l} = [legend_txt{l}(1:21),'...'];
                end
            end
            for l = 1 : numel(ytick_label)
                if size(ytick_label{l},2) > 24
                    ytick_label{l} = [ytick_label{l}(1:21),'...'];
                end
            end
            
            % Subplot graphics
            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            hold on;    
            
            title(title_txt,...
                'FontName','Times New Roman','FontSize',12);
            
            barh(input,'BarLayout','grouped','BarWidth',0.7);
            set(ax_handles{axc},'FontName','Times New Roman','FontSize',12,...
                'YTick',ytick,...
                'YTickLabel',ytick_label);
            % Limit the y axis to fit figure
            ylim([0.25,size(input,1)+0.75]);
            
            colormap(obj.cmap); % Change the color scheme
            % If axis must be moved (long y label names)
            % ax_position{axc} = get(ax_handles{axc},'OuterPosition');
            % ax_position{axc}([1,3]) = ax_position{axc}([1,3]) +0.025;
            % set(ax_handles{axc},'OuterPosition',ax_position{axc});
            
            % X label
            if ~isempty(xlabel_txt)
                xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
            end
            if ~isempty(legend_txt)
                for l = 1 : numel(legend_txt)
                    if size(legend_txt{l},2) > 24
                        legend_txt{l} = [legend_txt{l}(1:21),'...'];
                    end
                end
                l=legend(legend_txt,'Location','SouthEast','FontName','Times New Roman','FontSize',12);
                box(l,'off')
            end
            
            if max(input(:)) > 1e3
                % If losses are plotted, no need to limit axis
            else
                if max(input(:)) == 100
                    upper_lim = 100;
                elseif max(input(:)) > 40
                    upper_lim = ceil(1.8*max(input(:))/10)*10;
                    if upper_lim >= 100
                        upper_lim = 100;
                    end
                    
                elseif max(input(:)) > 30 && max(input(:)) <= 40
                    upper_lim = ceil(1.55*max(input(:))/10)*10;
                    if upper_lim >= 100
                        upper_lim = 100;
                    end
                else
                    upper_lim = ceil(1.05*max(input(:))/10)*10;
                    if upper_lim >= 100
                        upper_lim = 100;
                    end
                    
                end
                if ~isempty(legend_txt)
                    xlim([0,upper_lim]);
                end
            end
        end % display : grids and scenarios
        
        
    end % Methods
end % Classdef

