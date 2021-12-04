function handles = write_figure_to_excel(handles,Table_rf,file)

Excel_Column_ID = [{'A'},{'B'},{'C'},{'D'},{'E'},{'F'},{'G'},{'H'},{'I'},{'J'},{'K'},{'L'},{'M'},{'N'},{'O'},{'P'},{'R'},{'S'},{'T'},{'U'},{'V'},{'W'},{'Y'},{'Z'}];

Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);

% --------------------------------------------------------------
% Write to excel
warning('off', 'MATLAB:xlswrite:AddSheet'); % Turn off warning

% Create excel file and define sheets
xlswrite(file,Table_rf.Values,Table_rf.Description);

% Clear default sheets
hExcel = actxserver('Excel.Application');
hWorkbook = hExcel.workbooks.Open(file);
hWorksheets = hExcel.sheets;
sheetIdx = 1;
sheetIdx2 = 1;
numSheets = hWorksheets.Count;
while sheetIdx2 <= numSheets
    sheetName = hWorksheets.Item(sheetIdx).Name(1:end-1);
    if strncmp(sheetName,'Sheet',5) || strncmp(sheetName,'List',4) || strncmp(sheetName,'Tabelle',7)
        hWorksheets.Item(sheetIdx).Delete;
    else
        % Move to the next sheet
        sheetIdx = sheetIdx + 1;
    end
    sheetIdx2 = sheetIdx2 + 1; % prevent endless loop...
end

% Reformat result sheets
% Write table to excel. Find the correct sheet first, then write to it

clear sheetIdx2 numSheets
sheetIdx = [];
numSheets = hWorksheets.Count;
for i = 1 : numSheets
    sheetName = hWorksheets.Item(i).Name;    
    if strcmp(sheetName,Table_rf.Description)
        sheetIdx = i;
        break
    end
end
clear i sheetName

% -------------------------------------------------------------------
sheetName = [];
sheetName = hWorksheets.Item(sheetIdx).Name;
hWorksheet = hWorkbook.Sheets.Item(sheetIdx);
for columnIdx = 1 : size(Table_rf.Values,2)
    hWorksheet.Columns.Item(columnIdx).columnWidth = 30;
end

hWorksheet.Range(['A1:', Excel_Column_ID{size(Table_rf.Values,2)}, '1']).Interior.ColorIndex = 17;
hWorksheet.Range(['A2:', Excel_Column_ID{size(Table_rf.Values,2)}, '3']).Interior.ColorIndex = 24;
hWorksheet.Range(['A4:', Excel_Column_ID{size(Table_rf.Values,2)}, '4']).Interior.ColorIndex = 17;

% -------------------------------------------------------------------

hWorkbook.Save;
hWorkbook.Close(false);
hExcel.Quit;
delete(hExcel);

% Open the file
% winopen(file);

