function handles = plot_timeline_graph(handles,Table,Data_List)
% if numel(Table.ColumnName) == 1
%     return;
% end

% Plot grapghs
for i = 1 : numel(Data_List)    
    PlotInput = Table.(Data_List{i}).Values;
    % Axis formatting values
    PlotXtick = 1 : Table.(Data_List{i}).XTick: Table.(Data_List{i}).XLim;
    PlotXLabel =  Table.(Data_List{i}).XLabel;
    PlotYLabel = Table.(Data_List{i}).RowName;
    PlotFigureName = Table.(Data_List{i}).Description;
    PlotLegend = Table.ColumnName;
    
    % Define figure with computer resolution size
    figure('name',PlotFigureName,'Renderer',handles.System.Graphics.Renderer); hold on; grid on; box on
    set(gcf,'Position',handles.System.Graphics.Screensize);  % Adjust figure to user screensize
    count = 0;
    for j = 1 : numel(PlotLegend)
        count = count + 1;
        if mod(j,2) ~= 0
            plot(PlotInput(:,j),'LineStyle','-','LineWidth',1.0,'Color',handles.System.Graphics.Colormap(count,:));
        else
            count = count + 1;
            plot(PlotInput(:,j),'LineStyle',':','LineWidth',2,'Color',handles.System.Graphics.Colormap(count,:));
        end
    end
    
    % Set axis formatting
    set(gca,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize,'XTick',PlotXtick);
    ylabel(PlotYLabel,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
    xlabel(PlotXLabel,'FontName','Times New Roman','FontSize',handles.System.Graphics.FontSize);
    xlim([0,Table.(Data_List{i}).XLim]);
    legend1=legend(PlotLegend,'Location','SouthEast');
    set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1],...
        'FontName','Times New Roman','Fontsize',handles.System.Graphics.FontSize,'box','off');
    hold off;
    % Append temporary data to gcf - append ID for colorscheme control!
    setappdata(findobj(gcf,'type','figure'),'FigureID','timeline');
        
    % Append table data to gcf - values
    setappdata(findobj(gcf,'type','figure'),'table',Table);
      
   

    
end