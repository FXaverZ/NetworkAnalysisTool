function handles = write_to_excel(handles)

Excel_Column_ID = [...
     {'A'}, {'B'}, {'C'}, {'D'}, {'E'}, {'F'}, {'G'}, {'H'}, {'I'}, {'J'}, {'K'}, {'L'}, {'M'}, {'N'}, {'O'}, {'P'}, {'R'}, {'S'}, {'T'}, {'U'}, {'V'}, {'W'}, {'Y'}, {'Z'},...
    {'AA'},{'AB'},{'AC'},{'AD'},{'AE'},{'AF'},{'AG'},{'AH'},{'AI'},{'AJ'},{'AK'},{'AL'},{'AM'},{'AN'},{'AO'},{'AP'},{'AR'},{'AS'},{'AT'},{'AU'},{'AV'},{'AW'},{'AY'},{'AZ'},...
    {'BA'},{'BB'},{'BC'},{'BD'},{'BE'},{'BF'},{'BG'},{'BH'},{'BI'},{'BJ'},{'BK'},{'BL'},{'BM'},{'BN'},{'BO'},{'BP'},{'BR'},{'BS'},{'BT'},{'BU'},{'BV'},{'BW'},{'BY'},{'BZ'}...
%    {'A'},{'B'},{'C'},{'D'},{'E'},{'F'},{'G'},{'H'},{'I'},{'J'},{'K'},{'L'},{'M'},{'N'},{'O'},{'P'},{'R'},{'S'},{'T'},{'U'},{'V'},{'W'},{'Y'},{'Z'},...
    ];

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;
Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);
loss_an_pres = handles.NVIEW_Control.Simulation_Options.Loss_Analysis;

% --------------------------------------------------------------
% Load tables and read handles
Table_Inp = get_data_input_scenarios(d);
Table_Load = create_load_infeed_table(d,Table_Inp); 
Table_Load.Description = strrep(Table_Load.Description,'/','-');
clear Table_Inp
Table_Voltage = create_voltage_violation_table(handles,d);
Table_Current = create_current_table(handles,d);

% Changelog FZ 1.6 Start
% Check of, loss-data is avaliable:
if loss_an_pres
	Table_Losses = create_loss_table(handles,d);
end
% Changelog FZ 1.6 End

Table_Node_List = get_violated_node_list(d);
Table_Branch_List = get_violated_branch_list(d);

%----------------------------------------------------------------

% Reshape voltage violations to Excel form
Grid_List = d.Control.Simulation_Description.Variants;
Table_Voltage_Violation_All = reformat_voltage_violation_for_xls_sheet(d,Grid_List);
Table_Current_Violation_All = reformat_current_violation_for_xls_sheet(d,Grid_List);

% Changelog FZ 1.6 Start
if loss_an_pres
	Table_Electric_Losses_All = reformat_electric_losses_for_xls_sheet(d,Grid_List);
end
% Changelog FZ 1.6 End

Table_Simulation.Excel_table = ...
    [{'SIMULATION DESCRIPTION AND PARAMETERS USED'};
    {''};
    {['''', handles.NVIEW_Control.Result_Information_File.Name ,'''',' Result information file read']};
    {''};
    {[int2str(size(handles.NVIEW_Processed.Control.Simulation_Description.Variants,1)), ' Grid variants compared']};
    {[int2str(size(handles.NVIEW_Processed.Control.Simulation_Description.Scenario,1)), ' Scenarios analysed']};
    {[int2str(handles.NVIEW_Processed.Control.Simulation_Options.Number_of_datasets), ' Datasets per Scenario used']};
    {[int2str(handles.NVIEW_Processed.Control.Simulation_Options.Timepoints_per_dataset), ' Timepoints per Dataset used']};
    {['''', handles.NVIEW_Processed.Control.Simulation_Options.Input_values_used,'''', ' Values used for simulation']};];
Table_Simulation.Description = 'Simulation parameters';

% --------------------------------------------------------------
% Add Excel headers
Table_Load.Excel_Header = cell(3,size(Table_Load.Excel_table,2));
Table_Load.Excel_Header{1,1} = 'LOAD/INFEED SUMMARY REPORT';
Table_Load.Excel_table = [Table_Load.Excel_Header;Table_Load.Excel_table];
Table_Load.Excel_table(3,:) = Table_Load.ColumnName; % Add ID header

Table_Voltage.Excel_Header = cell(3,size(Table_Voltage.Excel_table,2));
Table_Voltage.Excel_Header{1,1} = 'VOLTAGE VIOLATION SUMMARY REPORT';
Table_Voltage.Excel_table = [Table_Voltage.Excel_Header;Table_Voltage.Excel_table];
Table_Voltage.Excel_table(3,:) = Table_Voltage.ColumnName; % Add ID header

Table_Current.Excel_Header = cell(3,size(Table_Current.Excel_table,2));
Table_Current.Excel_Header{1,1} = 'CURRENT VIOLATION SUMMARY REPORT';
Table_Current.Excel_table = [Table_Current.Excel_Header;Table_Current.Excel_table];
Table_Current.Excel_table(3,:) = Table_Current.ColumnName; % Add ID header

% Changelog FZ 1.6 Start
if loss_an_pres
	Table_Losses.Excel_Header = cell(3,size(Table_Losses.Excel_table,2));
	Table_Losses.Excel_Header{1,1} = 'ELECTRIC LOSSES SUMMARY REPORT';
	Table_Losses.Excel_table = [Table_Losses.Excel_Header;Table_Losses.Excel_table];
	Table_Losses.Excel_table(3,:) = Table_Losses.ColumnName; % Add ID header
end
% Changelog FZ 1.6 End

Table_Node_List.Excel_Header = cell(2,size(Table_Node_List.Values_Excel,2)); 
Table_Node_List.Excel_Header{1,1} = 'NODES AFFECTED BY VOLTAGE VIOLATIONS';
Table_Node_List.Excel_table = [Table_Node_List.Excel_Header;Table_Node_List.Values_Excel];

Table_Branch_List.Excel_Header = cell(2,size(Table_Branch_List.Values_Excel,2)); 
Table_Branch_List.Excel_Header{1,1} = 'BRANCHES AFFECTED BY OVERCURRENTS';
Table_Branch_List.Excel_table = [Table_Branch_List.Excel_Header;Table_Branch_List.Values_Excel];

Table_Voltage_Violation_All.Excel_table = [Table_Voltage_Violation_All.Excel_Header; Table_Voltage_Violation_All.Values_Cell];
Table_Voltage_Violation_All.Excel_table{1,1} = Table_Voltage_Violation_All.Main_Header;

Table_Current_Violation_All.Excel_table = [Table_Current_Violation_All.Excel_Header; Table_Current_Violation_All.Values_Cell];
Table_Current_Violation_All.Excel_table{1,1} = Table_Current_Violation_All.Main_Header;

% Changelog FZ 1.6 Start
if loss_an_pres
	Table_Electric_Losses_All.Excel_table = [Table_Electric_Losses_All.Excel_Header; Table_Electric_Losses_All.Values_Cell];
	Table_Electric_Losses_All.Excel_table{1,1} = Table_Electric_Losses_All.Main_Header;
end
% Changelog FZ 1.6 End

% --------------------------------------------------------------
% Write to excel
warning('off', 'MATLAB:xlswrite:AddSheet'); % Turn off warning

path = handles.System.Export_Path;
file = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - Settings',' - '),['NVIEW']];
file = [path,filesep,file,'.xls'];

if exist(file,'file') == 2
    % If file exists, open the file?
    % winopen(file);
    delete(file); % Remove the file?
end

% Create excel file and define sheets
Sheet_Descr_Load = Table_Load.Description(1:find(Table_Load.Description=='_')-1);
Sheet_Descr_Volt = Table_Voltage.Description(1:find(Table_Voltage.Description=='_')-1);
Sheet_Descr_Curr = Table_Current.Description(1:find(Table_Current.Description=='_')-1);

% Changelog FZ 1.6 Start
if loss_an_pres
	Sheet_Descr_Loss = Table_Losses.Description(1:find(Table_Losses.Description=='_')-1);
end
% Changelog FZ 1.6 End

Sheet_Descr_Nodes = 'Nodes aff. by volt. viol.'; 
Sheet_Descr_Branches = 'Branches aff. by overcurr.'; 

Sheet_Descr_Volt_Viol_All = Table_Voltage_Violation_All.Description;
Sheet_Descr_Curr_Viol_All = Table_Current_Violation_All.Description;

% Changelog FZ 1.6 Start
if loss_an_pres
	Sheet_Descr_Elec_Loss_All = Table_Electric_Losses_All.Description;
end
% Changelog FZ 1.6 End

xlswrite(file,Table_Simulation.Excel_table,Table_Simulation.Description);
xlswrite(file,Table_Load.Excel_table,Sheet_Descr_Load);
xlswrite(file,Table_Voltage.Excel_table,Sheet_Descr_Volt);
xlswrite(file,Table_Current.Excel_table,Sheet_Descr_Curr);

% Changelog FZ 1.6 Start
if loss_an_pres
	xlswrite(file,Table_Losses.Excel_table,Sheet_Descr_Loss);
end
% Changelog FZ 1.6 End

xlswrite(file,Table_Node_List.Excel_table,Sheet_Descr_Nodes);
xlswrite(file,Table_Branch_List.Excel_table,Sheet_Descr_Branches);

xlswrite(file,Table_Voltage_Violation_All.Excel_table,Sheet_Descr_Volt_Viol_All);
xlswrite(file,Table_Current_Violation_All.Excel_table,Sheet_Descr_Curr_Viol_All);

% Changelog FZ 1.6 Start
if loss_an_pres
	xlswrite(file,Table_Electric_Losses_All.Excel_table,Sheet_Descr_Elec_Loss_All);
end
% Changelog FZ 1.6 End

% Clear default sheets
hExcel = actxserver('Excel.Application');
hWorkbook = hExcel.workbooks.Open(file);
hWorksheets = hExcel.sheets;
sheetIdx = 1;
sheetIdx2 = 1;
numSheets = hWorksheets.Count;
while sheetIdx2 <= numSheets
    sheetName = hWorksheets.Item(sheetIdx).Name(1:end-1);
    if ~isempty(strncmp(sheetName,'Sheet',5)) || ~isempty(strncmp(sheetName,'List',4)) || ~isempty(strncmp(sheetName,'Tabelle',7))
        hWorksheets.Item(sheetIdx).Delete;
    else
        % Move to the next sheet
        sheetIdx = sheetIdx + 1;
    end
    sheetIdx2 = sheetIdx2 + 1; % prevent endless loop...
end

% Reformat result sheets
% Write table to excel. Find the correct sheet first, then write to it

numSheets = hWorksheets.Count;
for sheetIdx = 1 : numSheets
    sheetName = [];
    sheetName = hWorksheets.Item(sheetIdx).Name;
    if strcmp(sheetName,Sheet_Descr_Load)
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        hWorksheet.Columns.Item(1).columnWidth = 55; %first column
        for columnIdx = 2 : size(Table_Load.Excel_table,2)
            hWorksheet.Columns.Item(columnIdx).columnWidth = 30; %first column
        end
        hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Load.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Load.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_Load.Excel_table,2)}, '4']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A10:', Excel_Column_ID{size(Table_Load.Excel_table,2)}, '10']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A16:', Excel_Column_ID{size(Table_Load.Excel_table,2)}, '16']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A22:', Excel_Column_ID{size(Table_Load.Excel_table,2)}, '22']).Interior.ColorIndex = 17;
        
    elseif strcmp(sheetName,Sheet_Descr_Volt)
        % What rows must be highlighted (2x scenario+overall tables and 3x
        % L1, L2, L3 phase tables
        Highlight_Table_Voltage_Rows = 3 + [1, 2, 3] + ...
            [0,1,2].* (2+size(handles.NVIEW_Processed.Control.Simulation_Description.Scenario,1));
        Highlight_Table_Voltage_Rows = [Highlight_Table_Voltage_Rows,...
            max(Highlight_Table_Voltage_Rows) :5:size(Table_Voltage.Excel_table,1)-1];
        
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        hWorksheet.Columns.Item(1).columnWidth = 55; %first column
        for columnIdx = 2 : size(Table_Voltage.Excel_table,2)
            hWorksheet.Columns.Item(columnIdx).columnWidth = 30; %first column
        end
        
        for i = 1 : numel(Highlight_Table_Voltage_Rows)
            hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Voltage.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
            hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Voltage.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
            hWorksheet.Range(['A', int2str(Highlight_Table_Voltage_Rows(i)) ,...
                ':', Excel_Column_ID{size(Table_Voltage.Excel_table,2)},...
                int2str(Highlight_Table_Voltage_Rows(i))]).Interior.ColorIndex = 17;
        end

    elseif strcmp(sheetName,Sheet_Descr_Curr)
        % What rows must be highlighted (2x scenario+overall tables and 3x
        % L1, L2, L3 phase tables
        Highlight_Table_Voltage_Rows = 3 + [1, 2, 3] + ...
            [0,1,2].* (2+size(handles.NVIEW_Processed.Control.Simulation_Description.Scenario,1));
        
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        hWorksheet.Columns.Item(1).columnWidth = 55; %first column
        for columnIdx = 2 : size(Table_Voltage.Excel_table,2)
            hWorksheet.Columns.Item(columnIdx).columnWidth = 30; %first column
        end
        
        for i = 1 : numel(Highlight_Table_Voltage_Rows)
            hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Voltage.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
            hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Voltage.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
            hWorksheet.Range(['A', int2str(Highlight_Table_Voltage_Rows(i)) ,...
                ':', Excel_Column_ID{size(Table_Voltage.Excel_table,2)},...
                int2str(Highlight_Table_Voltage_Rows(i))]).Interior.ColorIndex = 17;
        end
    
    elseif loss_an_pres && strcmp(sheetName,Sheet_Descr_Loss)
        % What rows must be highlighted (2x scenario+overall tables and 3x
        % L1, L2, L3 phase tables
        Highlight_Table_Voltage_Rows = 3 + 1  ;
        
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        hWorksheet.Columns.Item(1).columnWidth = 55; %first column
        for columnIdx = 2 : size(Table_Voltage.Excel_table,2)
            hWorksheet.Columns.Item(columnIdx).columnWidth = 30; %first column
        end
        
        for i = 1 : numel(Highlight_Table_Voltage_Rows)
            hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Voltage.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
            hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Voltage.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
            hWorksheet.Range(['A', int2str(Highlight_Table_Voltage_Rows(i)) ,...
                ':', Excel_Column_ID{size(Table_Voltage.Excel_table,2)},...
                int2str(Highlight_Table_Voltage_Rows(i))]).Interior.ColorIndex = 17;
        end
        
    elseif strcmp(sheetName,Sheet_Descr_Nodes)
        
        Highlight_Table_Nodes_Rows = [1,3,4]  ;        
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        for columnIdx = 1 : size(Table_Node_List.Excel_table,2)
            hWorksheet.Columns.Item(columnIdx).columnWidth = 30; %first column
        end
        
        for i = 1 : numel(Highlight_Table_Nodes_Rows)
            hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Node_List.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
            hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Node_List.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
            hWorksheet.Range(['A', int2str(Highlight_Table_Nodes_Rows(i)) ,...
                ':', Excel_Column_ID{size(Table_Node_List.Excel_table,2)},...
                int2str(Highlight_Table_Nodes_Rows(i))]).Interior.ColorIndex = 17;
        end
        
    elseif strcmp(sheetName,Sheet_Descr_Branches)
        
        Highlight_Table_Branches_Rows = [1,3,4]  ;        
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        for columnIdx = 1 : size(Table_Branch_List.Excel_table,2)
            hWorksheet.Columns.Item(columnIdx).columnWidth = 30; %first column
        end
        
        for i = 1 : numel(Highlight_Table_Branches_Rows)
            hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Branch_List.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
            hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Branch_List.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
            hWorksheet.Range(['A', int2str(Highlight_Table_Branches_Rows(i)) ,...
                ':', Excel_Column_ID{size(Table_Branch_List.Excel_table,2)},...
                int2str(Highlight_Table_Branches_Rows(i))]).Interior.ColorIndex = 17;
        end
                
    elseif strcmp(sheetName,Table_Simulation.Description)
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        hWorksheet.Columns.Item(1).columnWidth = 70; %first column
        
        hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '4']).Interior.ColorIndex = 47;
        
        hWorksheet.Range(['A6:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '6']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A7:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '7']).Interior.ColorIndex = 47;
        
    elseif strcmp(sheetName,Table_Voltage_Violation_All.Description)
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        for nc = 1 : size(Table_Voltage_Violation_All.Values,2)
            hWorksheet.Columns.Item(nc).columnWidth = 20; %first column
        end
        
        hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Voltage_Violation_All.Values,2)}, '1']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Voltage_Violation_All.Values,2)}, '3']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_Voltage_Violation_All.Values,2)}, '4']).Interior.ColorIndex = 47;
        
    elseif strcmp(sheetName,Table_Current_Violation_All.Description)
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        for nc = 1 : size(Table_Current_Violation_All.Values,2)
            hWorksheet.Columns.Item(nc).columnWidth = 20; %first column
        end
        
        hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Current_Violation_All.Values,2)}, '1']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Current_Violation_All.Values,2)}, '3']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_Current_Violation_All.Values,2)}, '4']).Interior.ColorIndex = 47;
       
    elseif loss_an_pres && strcmp(sheetName,Table_Electric_Losses_All.Description)  
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        for nc = 1 : size(Table_Electric_Losses_All.Values,2)
            hWorksheet.Columns.Item(nc).columnWidth = 20; %first column
        end
        
        hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Current_Violation_All.Values,2)}, '1']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Current_Violation_All.Values,2)}, '3']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_Current_Violation_All.Values,2)}, '4']).Interior.ColorIndex = 47;
        
    end
end

hWorkbook.Save;
hWorkbook.Close(false);
hExcel.Quit;
delete(hExcel);

% Open the file
winopen(file);

