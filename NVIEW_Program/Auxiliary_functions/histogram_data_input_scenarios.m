function histogram_data_input_scenarios(handles,d,ext_inp)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

css = d.Control.Simulation_Description.Scenario(:,1);

Data_List = fields(ext_inp);
for H = 1 : numel(Data_List)
    clear  nBins binEdges aj bj cj count LineStyle_* b nj binIdx i Hist*
    
    % Create histogram
    nBins = 50; % 50 bin histogram!
    % Bin edges from 0 to max_edge
    if strcmp(Data_List{H},'Balance')
        binEdges = linspace(min(ext_inp.(Data_List{H}).Values(:)),max(ext_inp.(Data_List{H}).Values(:)),nBins+1);
    else
        binEdges = linspace(0,max(ext_inp.(Data_List{H}).Values(:)),nBins+1); 
    end
    % Lower edge
    aj = binEdges(1:end-1);
    % Higher edge
    bj = binEdges(2:end);
    % Center
    cj = (aj+bj) ./2; % center

    % Define figure with computer resolution size
    figure('name',ext_inp.(Data_List{H}).Description,'Renderer',handles.System.Graphics.Renderer); hold on; grid on; box on
    set(gcf,'Position',handles.System.Graphics.Screensize);  % Adjust figure to user screensize
    count = 0;
    LineStyle_Shapes{1} = ':'; LineStyle_Shapes{2} = '-'; LineStyle_Shapes{3} = '--';
    for i = 1 : cs
        binIdx = [];
        nj = [];
        b = [];
        [~,binIdx] = histc(ext_inp.(Data_List{H}).Values(:,i),[binEdges(1:end-1),Inf]); % histc
        % calculate the number of elements in bins
        nj = calc_bin_numbers(binIdx,nBins,binEdges);
        % Draw histogram
        b=bar(cj,100*nj/sum(nj),'style','hist');
        if i <= cs/2
            set(b,'EdgeColor','none','FaceColor',handles.System.Graphics.Colormap(i,:),'LineWidth',1.5,'FaceAlpha',min([0.2+ i/10,0.7]));
            %     set(gca,'Xtick',binEdges,'XLim',[binEdges(1) binEdges(end)]);
        else
            count = count + 1;
            if count > 3
                count = 1;
            end
            set(b,'EdgeColor',handles.System.Graphics.Colormap(i,:),'FaceColor','none','LineWidth',1.5,'LineStyle',LineStyle_Shapes{count});
        end
    end

    % Figure pre-formatting
    % Axis formatting values
    HistXLabel = ext_inp.(Data_List{H}).RowName;
    HistYLabel = 'Relative frequency in %';
    HistLegend = css;
    HistLegend = strrep(HistLegend,'_',' ');
    for i = 1 : size(HistLegend,1)
        if size(HistLegend{i,1},2) > 12
            HistLegend{i,1} = [HistLegend{i}(1:12),'...'];
        end
    end

    set(gca,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
    xlabel(HistXLabel,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
    ylabel(HistYLabel,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
    legend1 = legend(HistLegend,'Location','SouthEast');
    set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1],...
        'FontName','Times New Roman','Fontsize',handles.System.Graphics.FontSize,'box','off');
    hold off;
    % Append temporary data to gcf - append ID for colorscheme control!
    setappdata(findobj(gcf,'type','figure'),'FigureID','hist');
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