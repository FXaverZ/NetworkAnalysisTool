classdef plot_line_graphs
    
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
        cmap;
        % Colormap
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
        node;
        % Node
        
    end
    
    methods
        function obj = plot_line_graphs(number_of_subplots)
            obj.screensize = get(0,'ScreenSize');
            obj.gc_size = [obj.screensize(3)*0.1 , obj.screensize(4)*0.1,obj.screensize(3)*0.5*[1,0.8]];
            obj.gc_handles = figure;
            set(obj.gc_handles,'Position',obj.gc_size);
            
            obj.gc_subplots = number_of_subplots;
            % Reset information
            obj.dataset=[];
            obj.scenario=[];
            obj.grid=[];
            obj.node=[];
            
            % Colormap - user defined
            obj.cmap = [079,129,189;192,080,077;155,187,089;128,100,162;247,150,070;
                        000,000,000;075,172,198;031,073,125;000,176,080;127,127,127]/256;
        end
        
        function obj = timeplot_for_node(obj,varargin)
            if numel(varargin) == 6
                input = varargin{1};
                if size(input,2) ~=6
                    error('ErrorTests:convertTest',...
                    'Error using timeplot_for_node\nInput values are not properly sized.');
                end                
                axc = varargin{2};                   
                xlabel_txt = varargin{3};
                ylabel_txt = varargin{4};
                title_txt = varargin{5};
                legend_txt = varargin{6};
            else
                error('ErrorTests:convertTest',...
                'Error using timeplot_for_node\nToo many/few input arguments.');
            end

            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            
            hold on;
            % Input
            %   1-3 columns : L1, L2, L3 Upe 
            %   4 column: uul
            %   5 column: ull
            %   6 column: Voltage violation condition
            
            for i = 1 : 3
                plot(input(:,i),'LineStyle','-','LineWidth',1.5,...
                    'Color',obj.cmap(i,:),'Marker','none');
            end
            plot(input(:,i+1),'LineStyle','--','LineWidth',1.5,...
                    'Color',obj.cmap(end,:),'Marker','none');
            plot(input(:,i+3),'LineStyle','-','LineWidth',1.75,...
                    'Color',obj.cmap(i+3,:),'Marker','none');               
            plot(input(:,i+2),'LineStyle','--','LineWidth',1.5,...
                'Color',obj.cmap(end,:),'Marker','none');
            % Set limits
            ylimits = [-0.05 + round(10*min(min(input(:,1:3))))/10,...
                       0.05 + round(10*max(max(input(:,1:3))))/10];
            if min(ylimits) > 0.9
                ylimits(1) = 0.9-0.05;
            end
            if max(ylimits) < 1.1
                ylimits(2) = 1.1+0.05;
            end              
            ylim(ylimits);            
            xlim([1,size(input,1)]);
            
            % Set x axis ticks
            if  size(input,1) <= 10
                xtick = 1;
            elseif size(input,1) >10 & size(input,1) <= 20
                xtick = 2;
            elseif size(input,1) > 20 & size(input,1) <= 50
                xtick = 5;
            elseif size(input,1) > 50 & size(input,1) <= 100                
                xtick = 10;
            elseif size(input,1) > 100 & size(input,1) < 150
                xtick = 10;
            elseif size(input,1) >= 150 & size(input,1) < 200
                xtick = 20;
            else
                xtick = 50;
            end            
            set(ax_handles{axc},'FontName','Times New Roman','FontSize',12,...
                'XTick',1:xtick:size(input,1));
            
            xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
            ylabel(ylabel_txt,'FontName','Times New Roman','FontSize',12);
            l=legend(legend_txt,'Location','NorthEast',...
                'FontName','Times New Roman','FontSize',12);
            box(l,'off')            
        end % function timeplot_for_node
        
        function obj = voltageplot_for_nodes(obj,varargin)
            if numel(varargin) == 6
                input = varargin{1};
                axc = varargin{2};                   
                xlabel_txt = varargin{3};
                ylabel_txt = varargin{4};
                title_txt = varargin{5};
                if ~isempty(varargin{6})
                    legend_txt = varargin{6};
                else
                    legend_txt = [];
                end
            else
                error('ErrorTests:convertTest',...
                'Error using timeplot_for_node\nToo many/few input arguments.');
            end

            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            hold on;

            % NaN plotting to set legends properly
            plot(NaN,'LineWidth',4,'Color',obj.cmap(1,:))
            plot(NaN,'LineWidth',4,'Color',obj.cmap(2,:))
            plot(NaN,'LineWidth',4,'Color',obj.cmap(3,:))
            plot(NaN,'LineWidth',4,'Color',obj.cmap(4,:))
            plot(NaN,'LineWidth',4,'Color',obj.cmap(5,:))
            plot(NaN,'LineWidth',4,'Color',obj.cmap(6,:))
            
            % For all phases (i) and all nodes (n), we plot the
            % variations of voltages at nodes
            for n = 1 : size(input{1},1)
                i = 1; % Phase L1
                line([n,n],[input{i}(n,1),input{i}(n,2)],...
                    'LineWidth',4,'Color',obj.cmap(1,:));
                i = 2; % Phase L2
                line([n,n],[input{i}(n,1),input{i}(n,2)],...
                    'LineWidth',4,'Color',obj.cmap(2,:));
                i = 3; % Phase L3
                line([n,n],[input{i}(n,1),input{i}(n,2)],...
                    'LineWidth',4,'Color',obj.cmap(3,:));
            end
            for n = 1 : size(input{1},1)
                i = 1; % Phase L1
                line([n,n],[input{i}(n,3)+1e-3,input{i}(n,3)-1e-3],...
                    'LineWidth',4,'Color',obj.cmap(4,:));
                i = 2; % Phase L2
                line([n,n],[input{i}(n,3)+1e-3,input{i}(n,3)-1e-3],...
                    'LineWidth',4,'Color',obj.cmap(5,:));
                i = 3; % Phase L3
                line([n,n],[input{i}(n,3)+1e-3,input{i}(n,3)-1e-3],...
                    'LineWidth',4,'Color',obj.cmap(6,:));
            end
            
            
            xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
            ylabel(ylabel_txt,'FontName','Times New Roman','FontSize',12);
            % Remove underlines, which cause subscrpts in labels
            title_txt(title_txt == '_') = ' ';            
            title(title_txt,'FontName','Times New Roman','FontSize',12);
            if ~isempty(legend_txt)
                l=legend(legend_txt,'Location','NorthEast',...
                    'FontName','Times New Roman','FontSize',12);
                box(l,'off')
            end
            
        end % function voltageplot_for_nodes
        
        
    end % Methods
end % Classdef

