function Table = create_load_infeed_table(d,ext_inp)

cs = d.Control.Simulation_Options.Number_of_Scenarios;
cd = d.Control.Simulation_Options.Number_of_datasets;
ct = d.Control.Simulation_Options.Timepoints_per_dataset;
cg = d.Control.Simulation_Description.Variants;

Data_List = fields(ext_inp);

% Values ID
Table = []; 
RoundEps = 1e-2;
Table.Values = []; 
Table.RowName = [];
for H = 1 : numel(Data_List)
    Table.Values = [Table.Values;
        nan(1,cs);
        nanmax(ext_inp.(Data_List{H}).Values);
        nanmin(ext_inp.(Data_List{H}).Values);
        nanmean(ext_inp.(Data_List{H}).Values);
        nanstd(ext_inp.(Data_List{H}).Values);
        nan(1,cs);
        ];
    
    Table.RowName = [Table.RowName;
                     {upper(ext_inp.(Data_List{H}).RowName)};
                     {'Maximum values'};
                     {'Minimum values'};
                     {'Mean values'};
                     {'Standard deviation'};
                     {''};];
    
    % Define column ids
    if H == 1        
        Table.ColumnName(1,:) = [{''};ext_inp.(Data_List{H}).ColumnName];% Scenario ID
    end             
end                 
Table.Values = Table.Values - mod(Table.Values ,RoundEps);

% Convert numerical values to strings             
for rowIdx = 1 : size(Table.Values,1)
    for colIdx = 1 : size(Table.Values,2)
        if ~isnan(Table.Values(rowIdx,colIdx))
            Table.Values_Str{rowIdx,colIdx} =  num2str(Table.Values(rowIdx,colIdx),'%.2f');
        else
            Table.Values_Str{rowIdx,colIdx} = '';
        end
    end
end
Table.Values_Str = [Table.RowName, Table.Values_Str];
Table.Excel_table = Table.Values_Str; % Excel output

%Changelog 1.5 FZ Start
% convert strings containing numbers to number format (for correct
% representation in excel):
for i=1:size(Table.Excel_table,1)
	for j=2:numel(Table.Excel_table(i,:))
		num = sscanf(Table.Excel_table{i,j},'%f');
		if ~isempty(num)
			Table.Excel_table{i,j} = num;
		end
	end
end
clear i j num
%Changelog 1.5 FZ Start

% Select "identifier" and "overall" row and define html bold to the text
rowIdx_loop = [1:6:size(Table.Values_Str,1)];
   
for rowIdx = 1 : numel(rowIdx_loop)
    rowIdx = rowIdx_loop(rowIdx);
    for colIdx = 1 : size(Table.Values_Str,2)
        Table.Values_Str{rowIdx,colIdx} = ['<html><b>', Table.Values_Str{rowIdx,colIdx}, '</b></html>'];
    end
end

Table.Description =['Load/Infeed analysis_', d.Control.ID];

end
