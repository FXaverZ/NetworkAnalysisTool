function histogram_data_input_scenarios(handles,d,ext_inp)

LineStyle_Shapes{1} = ':'; 
LineStyle_Shapes{2} = '-'; 
LineStyle_Shapes{3} = '--';

nBins = 50; % 50 bin histogram!

cs = d.Control.Simulation_Options.Number_of_Scenarios;
% cd = d.Control.Simulation_Options.Number_of_datasets;
% ct = d.Control.Simulation_Options.Timepoints_per_dataset;
% cg = d.Control.Simulation_Description.Variants;

css = d.Control.Simulation_Description.Scenario(:,1);

Table = ext_inp;
Data_List = fields(ext_inp);
Data_List = setdiff(Data_List,'ColumnName');
for H = 1 : numel(Data_List)
    clear  binEdges count nj binIdx i
    Table.(Data_List{H}).Values = zeros(nBins,cs+1);
    if H == 1 
        Table.ColumnName{1} = 'Center_Value';
        for i = 1 : numel(Table.(Data_List{H}).ColumnName)
             Table.ColumnName{end+1} = Table.(Data_List{H}).ColumnName{i};
        end
    end
    Table.(Data_List{H}) = rmfield(Table.(Data_List{H}),'ColumnName');
    
    % Create histogram
    [binEdges, cj] = get_binEdges(Data_List{H}, ext_inp.(Data_List{H}).Values(:), nBins);
    Table.(Data_List{H}).Values(:,1) = cj;
    Table.(Data_List{H}).Details = ['Bin Size: ',num2str(cj(2)-cj(1)),' kW'];
    for i = 1 : cs
        [~,binIdx] = histc(ext_inp.(Data_List{H}).Values(:,i),[binEdges(1:end-1),Inf]); % histc
        % calculate the number of elements in bins
        nj = calc_bin_numbers(binIdx,nBins,binEdges);
        Table.(Data_List{H}).Values(:,i+1) = nj;
    end
end

for H = 1 : numel(Data_List)
    clear  binEdges cj count b nj i Hist*
    
    % Draw the histograms
    [~, cj] = get_binEdges(Data_List{H}, ext_inp.(Data_List{H}).Values(:), nBins);
    % Define figure with computer resolution size
    figure('name',ext_inp.(Data_List{H}).Description,'Renderer',handles.System.Graphics.Renderer); hold on; grid on; box on
    set(gcf,'Position',handles.System.Graphics.Screensize);  % Adjust figure to user screensize
    count = 0;
    for i = 1 : cs
        nj = Table.(Data_List{H}).Values(:,i+1);
        % Draw histogram
        b=bar(cj,100*nj/sum(nj),'hist');
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
    set(legend1,'EdgeColor',[1 1 1],...
        'FontName','Times New Roman','Fontsize',handles.System.Graphics.FontSize,'box','off');
    hold off;
    
    % Append temporary data to gcf - append ID for colorscheme control!
    setappdata(findobj(gcf,'type','figure'),'FigureID','hist');
    setappdata(findobj(gcf,'type','figure'),'table',Table);
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

function [binEdges, cj] = get_binEdges(Data_list_entry,values,nBins)
% Bin edges from 0 to max_edge
if strcmp(Data_list_entry,'Balance')
    binEdges = linspace(min(values),max(values),nBins+1);
else
    binEdges = linspace(0,max(values),nBins+1);
end
% Lower edge
aj = binEdges(1:end-1);
% Higher edge
bj = binEdges(2:end);
% Center
cj = (aj+bj) ./2; % center
end
