function histogram_voltage_violation_numbers_overall(handles,d,s)

%----------------------------------------------------------------------------
% Limit the observations to selected lists in <s> and <d>!
Selected_Variants = find(handles.NVIEW_Analysis_Selection.Variants);
Selected_Scenarios = find(handles.NVIEW_Analysis_Selection.Scenarios);

% Get list of grid variants and select the ones from the list
SelectedVariantList = s.Simulation_Description.Variants;
SelectedVariantList = SelectedVariantList(Selected_Variants);

% Limit scenarios to the selected list in <d>. Remove non-relevant columns in d
Data_List = fields(d);
d_ = [];
for H = 1 : numel(Data_List)
    if ~isempty(find(strcmp(SelectedVariantList,Data_List{H})))
        d_.(Data_List{H}) = d.(Data_List{H});
    end
end
clear d; d = d_; clear d_ Data_List H

% Limit scenarios for each grid
Data_List = fields(d);
for H = 1 : numel(Data_List)
    d.(Data_List{H}).bus_violations = d.(Data_List{H}).bus_violations(:,Selected_Scenarios);
    d.(Data_List{H}).bus_statistics = d.(Data_List{H}).bus_statistics(:,Selected_Scenarios);
    d.(Data_List{H}).bus_violated_at_datasets = d.(Data_List{H}).bus_violated_at_datasets(:,Selected_Scenarios);
%     d.(Data_List{H}).bus_deviations = d.(Data_List{H}).bus_deviations(:,Selected_Scenarios);
    d.(Data_List{H}).bus_violations_at_datasets = d.(Data_List{H}).bus_violations_at_datasets(:,Selected_Scenarios);
    d.(Data_List{H}).branch_violations = d.(Data_List{H}).branch_violations(:,Selected_Scenarios);
    d.(Data_List{H}).branch_statistics = d.(Data_List{H}).branch_statistics(:,Selected_Scenarios);
    d.(Data_List{H}).loss_statistics = d.(Data_List{H}).loss_statistics(:,Selected_Scenarios);
end


% Limit scenarios to the selected list in <s>
s.Simulation_Description.Scenario = s.Simulation_Description.Scenario(Selected_Scenarios,:);
s.Simulation_Description.Variants = s.Simulation_Description.Variants(Selected_Variants,:);
s.Simulation_Options.Number_of_Scenarios = size(Selected_Scenarios,1);
s.Simulation_Options.Number_of_Variants = size(Selected_Variants,1);

%----------------------------------------------------------------------------


cs = s.Simulation_Options.Number_of_Scenarios;
cd = s.Simulation_Options.Number_of_datasets;
cg = s.Simulation_Description.Variants;


for i = 1 : numel(cg)    
    Table.Values(:,i) = d.(cg{i}).bus_violations_at_datasets(:);
end, clear i   
Table.Description = 'Voltage violation histogram';
% Create histogram
nBins = 50; % 50 bin histogram!
% Bin edges from 0 to max_edge
binEdges = linspace(0,100,nBins+1);
% Lower edge
aj = binEdges(1:end-1);
% Higher edge
bj = binEdges(2:end);
% Center
cj = (aj+bj) ./2; % center

% Define figure with computer resolution size
figure('name',Table.Description,'Renderer',handles.System.Graphics.Renderer); hold on; grid on; box on
set(gcf,'Position',handles.System.Graphics.Screensize);  % Adjust figure to user screensize
count = 0;
LineStyle_Shapes{1} = ':'; LineStyle_Shapes{2} = '-'; LineStyle_Shapes{3} = '--';
for i = 1 : numel(cg)
    binIdx = [];
    nj = [];
    b = [];
    [~,binIdx] = histc(Table.Values(:,i),[binEdges(1:end-1),Inf]); % histc
    % calculate the number of elements in bins
    nj = calc_bin_numbers(binIdx,nBins,binEdges);
    % Draw histogram
    b=bar(cj,100*nj/sum(nj),'style','hist');
    if i <= numel(cg)/2
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
HistXLabel = 'Voltage violations in % of time';
HistYLabel = 'Relative frequency in %';
HistLegend = cg;
HistLegend = strrep(HistLegend,'_',' ');

for i = 1 : numel(HistLegend)
    if size(HistLegend{i},2) > 12
        HistLegend{i} = [HistLegend{i}(1:12),'...'];
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