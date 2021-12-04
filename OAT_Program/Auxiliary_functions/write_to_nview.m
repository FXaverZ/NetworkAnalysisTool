function handles = write_to_nview(handles)

% Transfer handles substructures to internal structures
d = handles.NVIEW_Processed;
Analysis_Selection_Id = define_analysis_selection_id(handles.NVIEW_Analysis_Selection);


% ----------------------------------------------------------------------------------------------------------------------------------------------
% Store information
% ----------------------------------------------------------------------------------------------------------------------------------------------
info =...
['>> bus                                                                                                                                  ';
'columns... 1 bus no, 2 Upp (kV), 3 Upe (kV), 4 Umax (%), 5 Umin (%)                                                                     ';
'rows... nodes                                                                                                                           ';
'                                                                                                                                        ';
'>> branch                                                                                                                               ';
'columns... 1 from bus, 2 to bus, 3 Upe,from (kV), 4 Upp,from (kV), 5 Upe,to (kV), 6 Upp,to (kV), 7 Sr (MVA), 8 Ir (A)                   ';
'rows... branch                                                                                                                          ';
'                                                                                                                                        ';
'>> voltage_violations                                                                                                                   ';
'dimension 1...scenario                                                                                                                  ';
'dimension 2...dataset                                                                                                                   ';
'dimension 3...timepoint                                                                                                                 ';
'dimension 4...node                                                                                                                      ';
'                                                                                                                                        ';
'>> bus_violations                                                                                                                       ';
'columns... scenarios                                                                                                                    ';
'rows... voltage violations at node                                                                                                      ';
'                                                                                                                                        ';
'>> bus_statistics                                                                                                                       ';
'columns... scenarios                                                                                                                    ';
'rows... 1 number of voltage violations, 2 number of voltage violations in %, 3 number of nodes violated, 4 number of nodes violated in %';
'                                                                                                                                        ';
'>> bus_violations_at_datasets                                                                                                           ';
'columns... scenarios                                                                                                                    ';
'rows... number of voltage violations per dataset                                                                                        ';
'                                                                                                                                        ';
'>> bus_violated_at_datasets                                                                                                             ';
'columns... scenarios                                                                                                                    ';
'rows...number of nodes violated per dataset                                                                                             ';
'                                                                                                                                        ';
'>> bus deviations                                                                                                                       ';
'dimension 1... scenarios                                                                                                                ';
'dimension 2... 1 Umax (pu), 2 Umean (pu), 3 Umin (pu)                                                                                   ';
'dimension 3... 1 L1, 2 L2, 3 L3                                                                                                         '];

d.Information = info;
d.Analysis_Selection_Id = Analysis_Selection_Id;
% ----------------------------------------------------------------------------------------------------------------------------------------------
% Store information
% ----------------------------------------------------------------------------------------------------------------------------------------------


% Store to MAT file
path = handles.System.Export_Path;
file = [strrep(handles.NVIEW_Control.Result_Information_File.Name,' - Settings',' - '),['NVIEW']];
file = [path,filesep,file,'.mat'];

save(file,'d')