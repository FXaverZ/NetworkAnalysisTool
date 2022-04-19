function push_network_load_random_allocation_Callback_Add (hObject, handles)
% hObject    Link zur Grafik push_network_load_random_allocation (siehe GCBO)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)


handles = load_random_allocation(handles);

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

