function handles = recolor_nview_figures(handles)

check_active_figures = setdiff(findobj('Type','figure'),handles.NVIEW_main_gui);

if ~isempty(check_active_figures)
    for i = 1 : numel(check_active_figures)
        if strcmp( getappdata(check_active_figures(i),'FigureID'),'barh')
            figure(check_active_figures(i));
            colormap(handles.System.Graphics.Colormap);
            refreshdata;
            
        elseif strcmp( getappdata(check_active_figures(i),'FigureID'),'hist')
            count = 0;
            LineStyle_Shapes{1} = ':'; LineStyle_Shapes{2} = '-'; LineStyle_Shapes{3} = '--';

            figure(check_active_figures(i));
            cp  = findobj(check_active_figures(i),'Type','patch');      
            cp = flipud(cp);
            for j = 1 : size(cp,1)/2                
                if j <= size(cp,1)/2/2
                    set(cp(j),'EdgeColor','none','FaceColor',...
                        handles.System.Graphics.Colormap(j,:),'LineWidth',1.5,'FaceAlpha',min([0.3+ j/10,0.7]));
                else
                    count = count + 1;
                    if count > 3
                        count = 1;
                    end
                    set(cp(j),'EdgeColor',handles.System.Graphics.Colormap(j,:),...
                        'FaceColor','none','LineWidth',1.5,'LineStyle',LineStyle_Shapes{count});
                end
            end
            refreshdata;
        elseif strcmp( getappdata(check_active_figures(i),'FigureID'),'line')
            cp  = findobj(check_active_figures(i),'Type','line');
            cp = flipud(cp);
            counter = 0;
            for j = 1 : numel(handles.NVIEW_Control.Simulation_Description.Variants)
                for k = 1 : 3
                    counter = counter + 1;
                    set(cp(counter),'LineStyle','-','LineWidth',10,'Color',...
                        handles.System.Graphics.Colormap(k+1,:));
                end
                for k = 1 : 3
                    counter = counter + 1;
                    set(cp(counter),'LineStyle','-','LineWidth',10,'Color',...
                        handles.System.Graphics.Colormap(end,:));
                end
                
            end
            
        end
        end
    end
end