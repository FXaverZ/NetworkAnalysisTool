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
            
            invalid_cp = [];
            for j = 1 : size(cp,1)
               if isempty(get(cp(j),'DisplayName'))
                   invalid_cp = [invalid_cp;j];
               end
            end
            cp(invalid_cp) = [];
            
            if numel(cp) == 1
                set(cp(1),'EdgeColor','none','FaceColor',...
                            handles.System.Graphics.Colormap(j,:),'LineWidth',1.5,'FaceAlpha',min([0.2+ j/10,0.7]));
            else                
                for j = 1 : size(cp,1)
                    if j <= size(cp,1)/2
                        set(cp(j),'EdgeColor','none','FaceColor',...
                            handles.System.Graphics.Colormap(j,:),'LineWidth',1.5,'FaceAlpha',min([0.2+ j/10,0.7]));
                    else
                        count = count + 1;
                        if count > 3
                            count = 1;
                        end
                        set(cp(j),'EdgeColor',handles.System.Graphics.Colormap(j,:), 'FaceColor','none','LineWidth',1.5,'LineStyle',LineStyle_Shapes{count});
                    end
                end
            end
            refreshdata;
            
        elseif strcmp( getappdata(check_active_figures(i),'FigureID'),'line_voltage_deviations')
            figure(check_active_figures(i));
            cp  = findobj(check_active_figures(i),'Type','line');
            cp = flipud(cp);
            counter = 0;
            for j = 1 : numel(handles.NVIEW_Processed.Control.Simulation_Description.Variants)
                for k = 1 : 3
                    counter = counter + 1;
                    set(cp(counter),'LineStyle','-','LineWidth',10,'Color',handles.System.Graphics.Colormap(k+1,:));
                end
                for k = 1 : 3
                    counter = counter + 1;
                    set(cp(counter),'LineStyle','-','LineWidth',10,'Color',handles.System.Graphics.Colormap(end,:));
                end
            end
            refreshdata;
            
        elseif strcmp( getappdata(check_active_figures(i),'FigureID'),'timeline')
            figure(check_active_figures(i));
            cp  = findobj(check_active_figures(i),'Type','line');
            cp = flipud(cp);
            count = 0;
            for j = 1 : size(cp,1)
                
                if ~strcmp(get(cp(j),'DisplayName'),'')
                    count = count + 1 ;
                    if mod(j,2) ~= 0
                        set(cp(j),'LineStyle',get(cp(j),'LineStyle'),'LineWidth',get(cp(j),'LineWidth'),'Color',handles.System.Graphics.Colormap(count,:));
                    else
                         count = count + 1;
                        set(cp(j),'LineStyle',get(cp(j),'LineStyle'),'LineWidth',get(cp(j),'LineWidth'),'Color',handles.System.Graphics.Colormap(count,:));
                    end
                end
            end
            refreshdata;

        end
    end
end