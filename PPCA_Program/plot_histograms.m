classdef plot_histograms
    
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
        scenario;
        % Scenario
        grid;
        % Grid
        yunit;
    end
    
    methods
        function obj = plot_histograms(number_of_subplots,grids,scenarios)
            obj.screensize = get(0,'ScreenSize');
            obj.gc_size = [obj.screensize(3)*0.1 , obj.screensize(4)*0.1,obj.screensize(3)*0.5*[1,0.8]];
            obj.gc_handles = figure;
            set(obj.gc_handles,'Position',obj.gc_size);
            
            obj.gc_subplots = number_of_subplots;
            % Reset information
            obj.scenario = scenarios;
            obj.grid = grids;
            
            % Colormap - user defined
            obj.cmap = [079,129,189;192,080,077;155,187,089;128,100,162;247,150,070;
                000,000,000;075,172,198;031,073,125;000,176,080;127,127,127]/256;
            
            obj.yunit = 1; % Relative frequency  %%EDIT VALUE HERE TO SEE FREQ/REL FREQ GRAPHS          
            % obj.yunit = 0; % Frequency
        end
        
        function obj = plot_histogram_grids_at_scenario(obj,varargin)
            input = varargin{1};
            axc = varargin{2};
            nBins = varargin{3};
            max_edge = varargin{4};
            xlabel_txt = varargin{5};
            title_txt = varargin{6};
            
            if numel(varargin) == 7
               losses_true = 1; % Temporary fix to be able to draw losses. 
               % Next version should implement a logical comparison of what you are plotting 
            else
                losses_true = 0;
            end
            
            if losses_true == 0
                max_edge = 10*round(max_edge/10)+10;
                if max_edge > 100
                    max_edge = 100;
                end
                
            end
            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            hold on
            
            for G = 1 : numel(obj.grid)
                bindEdges = []; aj = []; bj = []; cj = [];
                binIdx = []; nj = []; b = [];
                
                % Bin edges from 0 to max_edge %
                binEdges = linspace(0,max_edge,nBins+1);
                aj = binEdges(1:end-1); % lower edge
                bj = binEdges(2:end); % higher edge
                cj = (aj+bj) ./2; % center                
                [~,binIdx] = histc(input(:,G),[binEdges(1:end-1),Inf]); % histc
                % calculate the number of elements in bins
                nj = calc_bin_numbers(binIdx,nBins,binEdges);
                % Draw bars
                b=fun_hist_draw(cj,nj,obj.yunit);
                set(b,'EdgeColor',obj.cmap(G,:),'FaceColor','none','LineWidth',1.5,'FaceAlpha',0.7);
                set(ax_handles{axc},'XLim',[binEdges(1) binEdges(end)]);
            end
            % Labels
            insert_ylabel(obj.yunit);
            xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
            
            for G = 1 : numel(obj.grid)
               obj.grid{G}(obj.grid{G} =='_')=' ';                
            end
            title_txt(title_txt=='_')=' ';            
            l=legend(obj.grid,'Location','NorthEast',...
                'FontName','Times New Roman','FontSize',12);
            box(l,'off')
            title(title_txt,'FontName','Times New Roman','FontSize',12);
            
        end % function histogram_grids_at_scenario
        
        function obj = plot_histogram_scenarios_at_grid(obj,varargin)
            input = varargin{1};
            axc = varargin{2};
            nBins = varargin{3};
            max_edge = varargin{4};
            xlabel_txt = varargin{5};
            title_txt = varargin{6};
            
            if numel(varargin) == 7
                losses_true = 1; % Temporary fix to be able to draw losses.
                % Next version should implement a logical comparison of what you are plotting
            else
                losses_true = 0;
            end
            
            if losses_true == 0
                max_edge = 10*round(max_edge/10)+10;
                if max_edge > 100
                    max_edge = 100;
                end
                
            end
            
            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            hold on
            
            for S = 1 : numel(obj.scenario)
                bindEdges = []; aj = []; bj = []; cj = [];
                binIdx = []; nj = []; b = [];                
                % Bin edges from 0 to max_edge %
                binEdges = linspace(0,max_edge,nBins+1);
                aj = binEdges(1:end-1); % lower edge
                bj = binEdges(2:end); % higher edge
                cj = (aj+bj) ./2; % center                
                [~,binIdx] = histc(input(:,S),[binEdges(1:end-1),Inf]); % histc
                % calculate the number of elements in bins
                nj = calc_bin_numbers(binIdx,nBins,binEdges);
                % Draw bars
                b=fun_hist_draw(cj,nj,obj.yunit);
                set(b,'EdgeColor',obj.cmap(S,:),'FaceColor','none','LineWidth',1.5,'FaceAlpha',0.7);
                set(ax_handles{axc},'XLim',[binEdges(1) binEdges(end)]);
            end
            % Labels
            insert_ylabel(obj.yunit);
            xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
                                    
            for S = 1 : numel(obj.scenario)
               obj.scenario{S}(obj.scenario{S} =='_')=' ';                
            end
            title_txt(title_txt=='_')=' ';
            
            l=legend(obj.scenario,'Location','NorthEast',...
                'FontName','Times New Roman','FontSize',12);
            box(l,'off')
            title(title_txt,'FontName','Times New Roman','FontSize',12);
            
        end % function plot_histogram_scenarios_at_grid
    
        function obj = plot_histogram_inputs_at_scenarios(obj,varargin)
            input = varargin{1};
            axc = varargin{2};
            nBins = varargin{3};
            max_edge = varargin{4};
            xlabel_txt = varargin{5};
            title_txt = varargin{6};
            
            % Scientific notation exponent
            max_edge = round(max_edge/10^floor(log10(max_edge))) * 10^floor(log10(max_edge));
            min_edge = 0;
            min_input = min(input(:));
            if min_input < 0 
                min_input = abs(min_input);
                min_edge = - round(min_input/10^floor(log10(min_input))) * 10^floor(log10(min_input));
            end
            
            ax_handles{axc} = subplot(obj.gc_subplots,1,axc); 
            hold on
            
            for S = 1 : numel(obj.scenario)
                binEdges = []; aj = []; bj = []; cj = [];
                binIdx = []; nj = []; b = [];
                
                % Bin edges from 0 to max_edge %
                binEdges = linspace(min_edge,max_edge,nBins+1);
                aj = binEdges(1:end-1); % lower edge
                bj = binEdges(2:end); % higher edge
                cj = (aj+bj) ./2; % center                
                [~,binIdx] = histc(input(:,S),[binEdges(1:end-1),Inf]); % histc
                % calculate the number of elements in bins
                nj = calc_bin_numbers(binIdx,nBins,binEdges);
                % Draw bars
                b=fun_hist_draw(cj,nj,obj.yunit);
                set(b,'EdgeColor',obj.cmap(S,:),'FaceColor','none','LineWidth',1.5,'FaceAlpha',0.7);
                set(ax_handles{axc},'Xtick',binEdges,'XLim',[binEdges(1) binEdges(end)]);
            end
            
            % Labels
            insert_ylabel(obj.yunit);
            xlabel(xlabel_txt,'FontName','Times New Roman','FontSize',12);
            
            for S = 1 : numel(obj.scenario)
               obj.scenario{S}(obj.scenario{S} =='_')=' ';                
            end
            title_txt(title_txt=='_')=' ';
            
            l=legend(obj.scenario,'Location','NorthEast',...
                'FontName','Times New Roman','FontSize',12);
            box(l,'off')
            title(title_txt,'FontName','Times New Roman','FontSize',12);
            
            
            
        end % function plot_histogram_inputs_at_scenarios
        
    end % Methods
end % Classdef

function b = fun_hist_draw(cj,nj,yunit)
    if yunit == 1
        b=bar(cj,nj/sum(nj),'style','hist');
    else
        b=bar(cj,nj,'style','hist');
    end    
end

function nj = calc_bin_numbers(binIdx,nBins,binEdges)
    % calculate the number of elements in bins
    try
        nj = accumarray(binIdx,1,[nBins,1], @sum);
    catch
        nj = zeros(numel(binEdges)-1,1);
        for i = 1 : numel(binEdges)-1
            nj(i,1) = sum(binIdx==i);
        end
    end
end

function insert_ylabel(yunit)
    if yunit == 1
        ylabel('Relative frequency','FontName','Times New Roman','FontSize',12);
    else
        ylabel('Frequency','FontName','Times New Roman','FontSize',12);
    end
end