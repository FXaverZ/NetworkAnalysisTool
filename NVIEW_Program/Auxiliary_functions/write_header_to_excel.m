function file = write_header_to_excel(handles,ident)

path = []; file = [];
% Excel file info
path = handles.System.Export_Path;
file = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - Settings','_'), ident];
file = [path,filesep,file,'.xls'];

warning('off', 'MATLAB:xlswrite:AddSheet'); % Turn off warning


Excel_Column_ID = [{'A'},{'B'},{'C'},{'D'},{'E'},{'F'},{'G'},{'H'},{'I'},{'J'},{'K'},{'L'},{'M'},{'N'},{'O'},{'P'},{'R'},{'S'},{'T'},{'U'},{'V'},{'W'},{'Y'},{'Z'}];

if exist(file,'file') == 2
    % If file exists, open the file?
    % winopen(file);
    delete(file); % Remove the file?
end

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
xlswrite(file,Table_Simulation.Excel_table,Table_Simulation.Description);

hExcel = actxserver('Excel.Application');
hWorkbook = hExcel.workbooks.Open(file);
hWorksheets = hExcel.sheets;

sheetIdx = [];
numSheets = hWorksheets.Count;
for i = 1 : numSheets
    sheetName = hWorksheets.Item(i).Name;
    if strcmp(sheetName,Table_Simulation.Description)
        sheetIdx = i;
        break
    end
end
clear i sheetName numSheets

hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
hWorksheet.Columns.Item(1).columnWidth = 70; %first column

hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '1']).Interior.ColorIndex = 17;
hWorksheet.Range(['A3:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '3']).Interior.ColorIndex = 24;
hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '4']).Interior.ColorIndex = 47;

hWorksheet.Range(['A6:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '6']).Interior.ColorIndex = 24;
hWorksheet.Range(['A7:', Excel_Column_ID{size(Table_Simulation.Excel_table,2)}, '7']).Interior.ColorIndex = 47;

hWorkbook.Save;
hWorkbook.Close(false);
hExcel.Quit;
delete(hExcel);
% ------------------------------------------------