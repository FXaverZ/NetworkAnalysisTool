function handles = write_to_excel(handles)

Excel_Column_ID = [{'A'},{'B'},{'C'},{'D'},{'E'},{'F'},{'G'},{'H'},{'I'},{'J'},{'K'},{'L'},{'M'},{'N'},{'O'},{'P'},{'R'},{'S'},{'T'},{'U'},{'V'},{'W'},{'Y'},{'Z'}];

% Transfer handles substructures to internal structures
d = handles.NVIEW_Results;
s = handles.NVIEW_Control;
% --------------------------------------------------------------
% Load tables and read handles
Table_Inp = get_data_input_scenarios(handles);
Table_Load = create_load_infeed_table(handles,Table_Inp); 
Table_Load.Description = strrep(Table_Load.Description,'/','-');
clear Table_Inp
Table_Voltage = create_voltage_violation_table(handles,d,s);

Table_Simulation.Excel_table = ...
    [{'SIMULATION DESCRIPTION AND PARAMETERS USED'};
    {''};
    {['''', handles.NVIEW_Control.Result_Information_File.Name ,'''',' Result information file read']};
    {''};
    {[int2str(size(handles.NVIEW_Control.Simulation_Description.Variants,1)), ' Grid variants compared']};
    {[int2str(size(handles.NVIEW_Control.Simulation_Description.Scenario,1)), ' Scenarios analysed']};
    {[int2str(handles.NVIEW_Control.Simulation_Options.Number_of_datasets), ' Datasets per Scenario used']};
    {[int2str(handles.NVIEW_Control.Simulation_Options.Timepoints_per_dataset), ' Timepoints per Dataset used']};
    {['''', handles.NVIEW_Control.Simulation_Options.Input_values_used,'''', ' Values used for simulation']};];
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

% --------------------------------------------------------------
% Write to excel
warning('off', 'MATLAB:xlswrite:AddSheet'); % Turn off warning

path = handles.System.Export_Path;
file = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - Settings',' - '),'Summary'];
file = [path,filesep,file,'.xls'];

if exist(file,'file') == 2
    % If file exists, open the file?
    % winopen(file);
    delete(file); % Remove the file?
end

% Create excel file and define sheets
Sheet_Descr_Load = Table_Load.Description(1:find(Table_Load.Description=='_')-1);
Sheet_Descr_Volt = Table_Voltage.Description(1:find(Table_Voltage.Description=='_')-1);
xlswrite(file,Table_Simulation.Excel_table,Table_Simulation.Description);
xlswrite(file,Table_Load.Excel_table,Sheet_Descr_Load);
xlswrite(file,Table_Voltage.Excel_table,Sheet_Descr_Volt);


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
            [0,1,2].* (2+size(handles.NVIEW_Control.Simulation_Description.Scenario,1));
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
    elseif strcmp(sheetName,Table_Simulation.Description)
        hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
        hWorksheet.Columns.Item(1).columnWidth = 70; %first column
        
        hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
        hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '4']).Interior.ColorIndex = 47;
        
        hWorksheet.Range(['A6:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '6']).Interior.ColorIndex = 24;
        hWorksheet.Range(['A7:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '7']).Interior.ColorIndex = 47;
        
    end
end

hWorkbook.Save;
hWorkbook.Close(false);
hExcel.Quit;
delete(hExcel);

% Open the file
winopen(file);

