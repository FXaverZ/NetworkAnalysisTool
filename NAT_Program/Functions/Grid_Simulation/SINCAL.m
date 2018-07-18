classdef SINCAL < handle
	%SINCAL    stellt Zugriff auf PSS(R)SINCAL zur Verfügung
	%
	%    Detaillierte Beschreibung fehlt!
	%
	%    Die SINCAL-Instanz wird verwendet, um alle, mit dem Zugriff auf
	%    SINCAL relevanten Variablen und Methoden zusammenzufassen.
	
	% Version:                 1.2
	% Erstellt von:            Franz Zeilinger - 30.10.2012
	% Letzte Änderung durch:   Franz Zeilinger - 04.05.2018
	
	properties
		Settings
		%        Struktur mit den aktuellen Einstellungen
		Valid_Database = false
		%        Ist eine gültige Verbindung zu einer Datenbank aktiv?
		Valid_Database_Connection = false
		%        Ist eine gültige Verbindung mit der Quell-Datenbank (z.B. Access
		%        Datenbank) des Netzmodells aktiv?
		Valid_Document = false
		%        Ist das aktuelle Netz in der SINCAL-Oberfläche aktiv?
		Tables
		%        Struktur mit den bisher ausgelesenen Tabellen
	end
	
	properties (Hidden)
		Constants
		%        Sammlung von notwendigen Konstanten
		Database
		%        aktuelle Datenbank
		new_database_path = 0
		%        Neuer Datenbankpfad wurde gesetzt.
		new_database_name = 0
		%        Neuer Datenbankname wurde gesetzt.
		SimulationSrv = [];
		%        COM-Objekt eines SINCAL-Simulationsservers (eigener Prozess)
		Simulation = [];
		%        COM-Objekt einer SINCAL-Berechnung (eigentliches Objekt, über das
		%        Lastflussrechnung gesteuert wird.
		Database_Connection = [];
		%        COM-Object to an open database connection to the source database of the
		%        SINCAL grid model.
		NetworkDataSource = [];
		%        COM-Objekt für Zugriff auf virtuelle Datenbank des aktuellen Netzes.
		Application = [];
		%        COM-Objekt für Zugriff auf SINCAL Anwendung (GUI).
		Document = [];
		%        COM-Objekt für Zugriff Dokument in SINCAL-Oberfläche.
	end
	
	methods
		
		function obj = SINCAL (varargin)
			%SINCAL    Konstruktor der SINCAL-Klasse
			%
			%    Detaillierte Beschreibung fehlt noch!
			%
			%    Weiters wird innerhalb der SINCAL-Klasse eine Sub-Struktur
			%    "Constants" erstellt, die hilfreiche Konstanten für das Arbeiten mit
			%    SINCAL enthalten. So sollen alle numerischen Parameter durch
			%    klingende Namen hier ersetzt werden und in der gemeinsamen
			%    SINCAL-Struktur zur Verfügung stehen!
			
			% Hilfreiche Konstanten:
			obj.Constants.SimulationOK      		    = 1101;    %Berechnung erfolgreich beendet.
			obj.Constants.SimulationLoadDB_Failed	    = 1502;    %Laden der Datenbank ist fehlgeschlagen!
			% Hexwerte für die einzelnen Eingabedatenarten:
			obj.Constants.Input_Mask.Loadflow        = '00000001'; %Daten für Lastfluss vorhanden
			obj.Constants.Input_Mask.Short_Circiut   = '00000002'; %Daten für Kurzschluss vorhanden
			obj.Constants.Input_Mask.Unsym_Loadflow  = '00000400'; %Unsymmetrischer Lastfluss
			obj.Constants.Input_Mask.Dynamic         = '00000200'; %Dynamik
						
			obj.Constants.Application.AutoSelResetAll  = 0;
			obj.Constants.Application.AutoSelUpdateAll = 1;
			obj.Constants.Application.AutoSelNode      = 2;
			obj.Constants.Application.AutoSelElement   = 3;
			
			obj.Constants.Application.AutoUpdateBackground = 0; %Hintergrundgrafiken aktualisieren
			obj.Constants.Application.AutoUpdateView       = 1; %Ansicht aktualisieren
			obj.Constants.Application.AutoUpdateResults    = 2; %Ergebnisse aus der Datenbank laden
			obj.Constants.Application.AutoUpdateInputData  = 3; %Eingabedaten aus der Datenbank laden
			obj.Constants.Application.AutoUpdateRedrawView = 4; %Ansichtsgrafik aktualisieren
			
			obj.Constants.Application.AutoCalcLF           = 38;%Lastfluss lt. Einstellung in den Berechnungsparametern
			
			
			% Default-Einstellungen:
			obj.Settings.Calculation_method = 'LF_USYM';
			obj.Settings.Batch_mode  = 4;
			obj.Settings.Database_typ = 'DB_EL';
			obj.Settings.Language = 'DE';
			obj.Settings.Database_Connector = 'ACCESS12'; %connection type - currently supported: 'Access','Access12','SQL','Oracle'
			obj.Settings.Database_Server_Name = [];       %name of server - not required for Access connection
			obj.Settings.Database_User_ID = [];           %user id - added to connection string if provided
			obj.Settings.Database_Password = [];          %password - added to connection string if provided
			obj.Settings.Command_Timeout = 60;            %Commandtimeout in seconds (default=60 seconds if unspecified)
			
			% Angaben des aktuelle Netzes:
			obj.Settings.Grid_name = [];
			obj.Settings.Grid_path = [];
			
			obj.update_settings(varargin{:});
		end
		
		function open_database(obj, varargin)
			%OPEN_DATABASE     erzeugt SINCAL Simulationsobjekt u. lädt die Datenbank
			%    genaue Beschreibung fehlt!
			
			% Falls bereits eine Datenbank geöffnet ist, diese zuvor schließen:
			if obj.Valid_Database
				obj.close_database;
				pause(0.05);
			end
			
			% Überprüfen, ob eine Datenbank angegeben wurde:
			if isempty(obj.Database)
				exception = MException(...
					'SINCAL:OpenDataBase:NoDatabaseSpecified',...
					['No valid Database specified! The parameters ''Grid_path'' ',...
					'and ''Grid_name'' have to be set before calling this method!']);
				throw(exception);
			end
			
			% Je nach installierter MATLAB-Version das Simulationsobjekt erzeugen:
			if strcmp(computer('arch'),'win64')
				% Erzeugen eines SINCAL-Simulationsobjektes als "out of process
				% server" (Anmerkung: Windows lässt nicht zu, dass eine 32-bit
				% Anwendung (SINCAL) innerhalb einer 64-bit-Anwendung (MATLAB) als
				% COM-Objekt aufgerufen werden kann. Daher muss ein eigener Prozess
				% gestartet wereden!
				obj.SimulationSrv = actxserver('Sincal.SimulationSrv');
				obj.Simulation = obj.SimulationSrv.GetSimulation;
			elseif strcmp(computer('arch'),'win32')
				% Auf 32-bit Systemen bzw. Installation von 32-bit MATLAB kann das
				% SINCAL-Simulationsobjekt als "in process server" erzeugt werden,
				% d.h. innerhalb des MATLAB-Prozesses (Vorteil: Nutzung des
				% gemeinsamen Arbeitsspeicherbereichs --> schnellerer
				% Datenaustausch).
				%                 obj.SimulationSrv = actxserver('Sincal.SimulationSrv');
				%                 obj.Simulation = obj.SimulationSrv.GetSimulation;
				obj.Simulation = actxserver('Sincal.Simulation');
			else
				exception = MException(...
					'SINCAL:OpenDataBase:UnsuportedOperationSystem',...
					['Not able to open a connection to SINCAL-Simulation ',...
					'because of an unsupported operating system!']);
				throw(exception);
			end
			
			% Setzen der Datenbankeinstellungen und Sprache:
			obj.Simulation.Database ([...
				'TYP=NET;MODE=JET;FILE=',obj.Database.DBfilename,';'...
				'USR=Admin;PWD=;SINFILE=',obj.Database.SINfilename,';'...
				]);
			obj.Simulation.Language(obj.Settings.Language);
			
			% Festlegen, welche Eingabeparameter vorhanden sind bzw. für die
			% Berechnung benötigt werden. Dabei erfolgt eine logische
			% ODER-Verknüpfung der Binärmuster für die einzelnen Datenarten (-->
			% siehe SINCAL-Handbuch) z.B. Lastfluss & Kurzschluss vorhanden: &h0001
			% || &h0002 = &d3
			% Hier wird mit den definierten Hex-Werten (obj.Constants.Input_Mask)
			% gearbeitet, die ODER-Verknüpfung wird dann zu einer Addition:
			switch obj.Settings.Calculation_method
				case 'LF_USYM' % Unsymmetrischer Lastfluss (MGN)
					inputstate = ...
						hex2dec(obj.Constants.Input_Mask.Loadflow) +...
						hex2dec(obj.Constants.Input_Mask.Short_Circiut) +...
						hex2dec(obj.Constants.Input_Mask.Unsym_Loadflow);
				case 'LF_RST' % unsymmetrical load-flow (RST)
					inputstate = ...
						hex2dec(obj.Constants.Input_Mask.Loadflow) +...
						hex2dec(obj.Constants.Input_Mask.Short_Circiut) +...
						hex2dec(obj.Constants.Input_Mask.Unsym_Loadflow);
				case 'LF_NR' % Lastfluss Newton-Raphson
					inputstate = ...
						hex2dec(obj.Constants.Input_Mask.Loadflow) +...
						hex2dec(obj.Constants.Input_Mask.Short_Circiut);
				case 'NETO_STAB'
					inputstate = ...
						hex2dec(obj.Constants.Input_Mask.Loadflow) +...
						hex2dec(obj.Constants.Input_Mask.Short_Circiut) +...
						hex2dec(obj.Constants.Input_Mask.Dynamic);
				otherwise
					% Fehlermeldung, da die Berechnungsmethode noch nicht verarbeiter
					% werden kann (z.B. weil die vorliegende SINCAL-Klasse dies noch
					% nicht unterstützt bzw. erst entsprechend erweitert werden muss)
					exception = MException(...
						'SINCAL:OpenDataBase:UnknownCalculationMethod',...
						['The specified calculation method ''',...
						obj.Settings.Calculation_method,...
						''' is not supported!']);
					throw(exception);
			end
			obj.Simulation.SetInputState(inputstate);
			
			% Umschalten des Batch-Modes:
			obj.Simulation.BatchMode(obj.Settings.Batch_mode);
			
			% Laden der Datenbank in Arbeitsspeicher:
			obj.Simulation.LoadDB(obj.Settings.Calculation_method);
			% Überprüfen, ob Laden erfolgreich war:
			if obj.Simulation.StatusID == obj.Constants.SimulationLoadDB_Failed
				obj.close_database; %#ok<*NASGU>
				exception = MException('SINCAL:OpenDataBase:LoadDBFailed',...
					['LoadDB failed, unable to oben SINCAL-Database!',...
					' Check settings or Licenses!']);
				throw(exception);
			end
			
			% Gültige Datenbankverbindung vorhanden!
			obj.Valid_Database = true;
			
			% Objekt für die virtuelle Datenbank auslesen (für Zugriff auf diese)
			obj.NetworkDataSource = obj.Simulation.(obj.Settings.Database_typ);
			if isempty(obj.NetworkDataSource)
				obj.close_database;
				exception = MException(...
					'SINCAL:OpenDataBase:LoadVirtualDataBaseFailed',...
					'Loading of the virtual database failed!');
				throw(exception);
			end
			% Try to get also a direct connection to the database of the grid model
			% (for direct manipulation):
			% First create the needed connection string:
			if strcmpi('ACCESS',obj.Settings.Database_Connector)
				%Connect to Access database given by input db
				cnstr='PROVIDER=Microsoft.Jet.OLEDB.4.0;';
				cnstr=[cnstr 'Data Source=' obj.Database.DBfilename ';'];
			elseif strcmpi('SQL',obj.Settings.Database_Connector)
				%Connect to SQL Database
				cnstr='Provider=SQLOLEDB;';
				cnstr=[cnstr 'Data Source=' obj.Settings.Database_Server_Name ';Initial Catalog=' db ';'];
			elseif strcmpi('ORACLE',obj.Settings.Database_Connector)
				%Connect to Oracle Database
				cnstr='Provider=OraOLEDB.Oracle;';
				cnstr=[cnstr 'Data Source=' obj.Database.DBfilename ';'];
			elseif strcmpi('ACCESS12',obj.Settings.Database_Connector)
				cnstr='PROVIDER=Microsoft.ACE.OLEDB.12.0;';
				cnstr=[cnstr 'Data Source=' obj.Database.DBfilename ';'];
			else
				warning(['Open Connection to SINCAL database: Unknown type of ',...
					'database connector was given!']);
			end
			%add uid and pwd if provided
			if ~isempty(obj.Settings.Database_User_ID)
				cnstr=[cnstr 'User Id=' obj.Settings.Database_User_ID ';'];
			end
			if ~isempty(obj.Settings.Database_Password)
				cnstr=[cnstr 'Password=' obj.Settings.Database_Password ';'];
			end
			
			try
				%create activeX control
				obj.Database_Connection = actxserver('ADODB.Connection');
				set(obj.Database_Connection,'CursorLocation',3);
				
				%Open connection
				invoke(obj.Database_Connection,'Open', cnstr);
				
				%Specify connection timeout
				set(obj.Database_Connection,'CommandTimeout',obj.Settings.Command_Timeout);
				
				obj.Valid_Database_Connection = true;
			catch e
				warning('SINCAL:ConnectionSourceDatabase:Failed',...
					['Could not connect to SINCAL source database. ',...
					'Check installed database drivers.']);
% 				warning(e.message);
				obj.Valid_Database_Connection = false;
			end
		end
		
		function update_database(obj)
			if obj.Valid_Database
				obj.close_database;
				pause(0.05);
				obj.open_database;
			end
		end
		
		function open_application_and_file(obj)
			reopen = false;
			if obj.Valid_Database
				obj.close_database;
				reopen = true;
			end
			
			obj.Application = actxserver('SIASincal.Application');
			if isempty(obj.Application)
				if reopen
					obj.open_database
				end
				exception = MException('SINCAL:OpenApplication:Failed',...
					'The opening of the SINCAL Application failed!');
				throw(exception);
			end
			% Das Netz in der SINCAL-Oberfläche öffnen:
			obj.Document = obj.Application.OpenDocument(obj.Database.SINfilename);
			if isempty(obj.Document)
				if reopen
					obj.open_database
				end
				exception = MException('SINCAL:OpenDocument:Failed',...
					'The opening of the specified SINCAL document failed!');
				throw(exception);
			end
			
			if reopen
				obj.open_database
			end
			
			obj.Valid_Document = true;
		end
		
		function close_file_in_application(obj)
			if obj.Valid_Document
				obj.Application.CloseDocument(obj.Database.SINfilename);
				obj.Document = [];
				obj.Valid_Document = false;
			end
		end
		
		function gui_select_element(obj, el_id)
			try
				if obj.Valid_Document
					obj.Document.SelectNetworkObject(...
						obj.Constants.Application.AutoSelResetAll, 0);
					obj.Document.SelectNetworkObject(...
						obj.Constants.Application.AutoSelElement, ...
						el_id);
					obj.Document.SelectNetworkObject(...
						obj.Constants.Application.AutoSelUpdateAll, 0);
				end
			catch ME
				disp('Error during calling gui_select_element');
				disp(ME.Message);
				obj.Valid_Document = 0;
			end
		end
		
		function [el_ids, el_names, el_typs] = gui_get_selected_element(obj)
			% GUI_GET_SELECTED_ELEMENT    get information about selected objects in the SINCAL GUI
			%    [EL_IDS, EL_NAMES, EL_TYPS] = SINCAL.GUI_GET_SELECTED_ELEMENT
			%    returns informations about the currently selected objects in the GUI
			%    of the SINCAL Application. For this, the Applicatio and the grid
			%    model have to be opened with aid of the MATLAB SINCAL class.
			%    Ohterwise no connection is present between the application and the
			%    invoking MATLAB function.
			%
			%    Return Values:
			%    --------------
			%    EL_IDS (numerical)
			%    Element_IDs of the selected objects. These values correspond with
			%    the IDs of the SINCAL database.
			%
			%    EL_NAMES (cell)
			%    Names of the selected objects
			%
			%    EL_TYPS (cell)
			%    Typ of the selectd objects
			
			% Created by:              Franz Zeilinger - 28.09.2016
			% Last changes by:
			
			el_ids = [];
			el_names = [];
			el_typs = [];
			
			if obj.Valid_Document
				sel = obj.Document.GetSelection();
				
				el_ids = zeros(sel.Count,1);
				for i = 1:sel.Count
					it = sel.invoke('Item',i-1);
					el_ids(i) = it.DB_ID;
				end
				if ~isempty (el_ids)
					el_names = obj.get_entry_element(el_ids,'Name');
					el_typs = obj.get_entry_element(el_ids,'Typ');
				end
			end
		end
		
		function gui_update_input_data(obj, updated_tables)
			%GUI_UPDATE_INPUT_DATA    updates SINCAL Applicaton input data from database
			%   Detailed explanation goes here
			if obj.Valid_Document
				
				for i = 1:numel(updated_tables)
					obj.Document.Reload(updated_tables{i});
				end
				obj.Document.UpdateData(...
					obj.Constants.Application.AutoUpdateInputData, ...
					obj.Constants.Application.AutoCalcLF);
			end
		end
		
		function entry = get_entry_table(obj,table_name,name_identifier,el_id,property_name)
			
			% Created by:              Franz Zeilinger - 08.11.2016
			% Last changes by:
			
			% load the table "table_name" if not allready done
			if ~isfield(obj.Tables, table_name)
				obj.table_data_load(table_name);
			end
			% where are the element IDs? (column "Element_ID")
			idx_el_id = strcmp(obj.Tables.(table_name)(1,:),name_identifier);
			if isempty(idx_el_id)
				exception = MException(...
					'SINCAL:GetEntryElement:IdentiferNotFound',...
					['The given identifier was not found in table "',table_name,'"!']);
				throw(exception);
			end
			% where is the wanted propberty? (column with the same name)
			if iscell(property_name)
				idx_prope = [];
				for i = 1:numel(property_name)
					if isempty(idx_prope)
						idx_prope = strncmpi(obj.Tables.(table_name)(1,:),property_name{i},length(property_name{i}));
					else
						idx_prope = idx_prope | strncmpi(obj.Tables.(table_name)(1,:),property_name{i},length(property_name{i}));
					end
				end
			else
				idx_prope = strncmpi(obj.Tables.(table_name)(1,:),property_name,length(property_name));
			end
			% check, if property was found. If not, return error messages:
			if sum(idx_prope) < 1
				exception = MException(...
					'SINCAL:GetEntryElement:PropertyNotFound',...
					['The given properties where not found in table "',table_name,'"!']);
				throw(exception);
			end
			% return the wanted entry or entries of the table:
			all_ids = [0;cell2mat(obj.Tables.(table_name)(2:end,idx_el_id))];
			if isempty(el_id)
				% if el_id is empty, return all entries (except first line = header!)
				idx_elemt = true(size(all_ids));
				idx_elemt(1) = false;
			else
				idx_elemt = zeros(size(all_ids));
				for i=1:numel(el_id)
					idx_elemt = idx_elemt | (all_ids == el_id(i));
				end
			end
			entry = deblank(obj.Tables.(table_name)(idx_elemt,idx_prope));
		end
		
		function entry = get_entry_element(obj,el_id,property_name)
			%GET_ENTRY_ELEMENT    get entries out of table "Element" of SINCAL model
			%    ENTRY = SINCAL.GET_ENTRY_ELEMENT(EL_ID,PROPERTY_NAME) returns
			%    depending on the inputs the corresponding elements out of the table
			%    "Element" of the SINCAL grid model.
			%
			%    Input Arguments:
			%    ----------------
			%    EL_ID (numerical)
			%    determines, from which elements the entries are needed. The value
			%    has to correspond with the database ID of SINCAL. If  EL_ID is
			%    empty, than all entries are returned.
			%
			%    PROPERTY_NAME (string or 1-dim cell-array of strings)
			%    determines, which property values should be returned
			%
			%    Return Values:
			%    --------------
			%    ENTRY (cell)
			%    [n,m] cell-array with the requested entries. n depends on the number
			%    of elements of EL_ID, m on the number of elements of PROPERTY_NAME
			
			% Created by:              Franz Zeilinger - 28.09.2016
			% Last changes by:         Franz Zeilinger - 08.11.2016
			
			entry = obj.get_entry_table('Element','Element_ID',el_id,property_name);
		end
		
		function update_settings(obj, varargin)
			%UPDATE_SETTINGS    Ergänzt Parametereinstellungen der Klasse
			%    genaue Beschreibung fehlt!
			
			% wurden noch Parameter übergeben?
			if nargin == 1
				return;
			end
			
			% Sind die Argumente Zweiergruppen --> wenn nicht --> Fehler:
			if (mod(nargin-1,2) == 0)
				% Durchlaufen aller Eingangsparameter (in 2er Schritten):
				for i = 1:2:nargin-1
					% Erster Teil: Parametername, ist dieser ein String -->
					% wenn nicht --> Fehler:
					if ischar(varargin{i})
						try
							obj.update_parameter(varargin{i}, varargin{i+1});
						catch ME
							% Falls Fehler passieren, dies melden und weiterreichen:
							exception = MException(...
								'SINCAL:UpdateSettings:Error',...
								['When processing the parameter ''',...
								varargin{i},''' a error occured!']);
							exception = addCause (ME, exception);
							throw(exception);
						end
					else
						% Fehler, weil erster Eintrag in Parameterliste kein
						% Text war:,
						exception = MException(...
							'SINCAL:UpdateSettings:WrongParameterName',...
							['Wrong inputarguments. Input looks like ',...
							'(''Parameter_Name'', Value)']);
						throw(exception);
					end
				end
			else
				% Fehler, weil Parameter nicht in Zweiergruppe übergeben wurde:
				exception = MException(...
					'SINCAL:UpdateSettings:WrongNumberArgs', ...
					['Wrong number of inputarguments. Input looks like ',...
					'(''Parameter_Name'', Value)']);
				throw(exception);
			end
			
			% Wenn neue Datenbank angegeben wurde, diesen neu setzen und ev. die neue
			% Datenbank laden:
			if obj.new_database_path || obj.new_database_name
				obj.set_database_path;
			end
			
			% Datenbank mit den neuen Einstellungen öffnen:
			obj.open_database;
		end
		
		function close_database(obj, varargin)
			%CLOSE_DATABASE    schließt offene SINCAL-COM-Objekte bzw. Applikationen
			%   Detailierte Beschreibung fehlt!
			if nargin < 2
				varargin{1} = 'not_all';
			end
			if strcmpi(varargin{1},'all')
				obj.close_file_in_application();
			end
			obj.NetworkDataSource = [];
			obj.Simulation = [];
			obj.SimulationSrv = [];
			obj.Valid_Database = false;
			obj.Tables = [];
			obj.Database_Connection = [];
			obj.Valid_Database_Connection = false;
		end
		
		function [data, names] = table_data_load (obj, tablename)
			%TABLE_DATA_LOAD    lädt Tabelle aus einer virtuellen SINCAL-Datenbank
			%    SINCAL.TABLE_DATA_LOAD (TABLENAME) lädt eine komplette Tabelle,
			%    welche durch die Tabellenbezeichnung TABLENAME angegeben wird aus
			%    der virtuellen SINCAL-Datenbank in die interne Daten-Struktur
			%    SINCAL.TABLES.
			%    TABLE ist ein Cell-Array, das in der ersten Zeile die
			%    Spaltenbezeichnung und in den darauffolgenden Zeilen die Inhalte der
			%    Tabelle wiedergibt. Diese Tabelle ist dann via
			%    SINCAL.TABLES.TABLENAME verfügbar.
			%    Auch bei allen anderen Varianten des Aufrufs dieser Methode wird die
			%    Tabelle in der internen Datenstruktur hinterlegt.
			%
			%    TABLE = SINCAL.TABLE_DATA_LOAD (TABLENAME) lädt eine komplette
			%    Tabelle TABLE und gibt diese zusätzlich zurück.
			%
			%    [DATA, NAMES] = TABLE_DATA_LOAD (SINCAL, TABLENAME) lädt die Tabelle
			%    getrennt in zwei seperaten Teilen:
			%        DATA enthält die Tabellendaten als Cell-Array.
			%        NAMES enthält die Spaltenbezeichnungen, ebenfalls als Cell-Array
			%        von Strings.
			
			% If table allready exists, remove it
			if isfield(obj.Tables,tablename)
				obj.Tables = rmfield(obj.Tables,tablename);
			end
			% Auslesen der Tabelle:
			table = obj.NetworkDataSource.GetRowObj(tablename);
			table.Open();
			% Die Namen der Tabellenbezeichnungen auslesen:
			number_names = table.Count;
			names = cell(1,number_names);
			for i = 1:number_names
				names{i} = table.get('Name',i);
			end
			% Die Daten auslesen:
			number_rows = table.CountRow;
			table.MoveFirst();
			data = cell(number_rows,number_names);
			for i = 1:number_rows
				for j = 1:number_names
					data{i,j} = table.get('Item',names{j});
				end
				table.MoveNext();
			end
			table.Close();
			if nargout < 2
				data = [names; data];
				obj.Tables.(tablename) = data;
			else
				obj.Tables.(tablename) = [names; data];
			end
		end
		
		function start_calculation(obj, varargin)
			%START_CALCULATION    initiert eine Berechnung
			%    SINCAL.START_CALCULATION startet eine Berechnung innerhalb des
			%    SINCAL.Simulation-Objekts gemäß den zuvor defnierten Einstellungen
			%    (siehe SINCAL.OPEN_DATABASE). Falls es zu Problemen bei der
			%    Berechnung kommt, erfolgt eine detailierte Ausgabe des Fehlers in
			%    der MATLAB-Konsole.
			
			%    SINCAL.START_CALCULATION( MELDUNGSMODE ) regelt, welche Meldungen im
			%    Fehlerfall ausgegeben werden.
			%        MELDUNGSMODE = 'Silent' ... Es werden keine Meldungen ausgegeben.
			
			% Starten der Lastflussrechnung:
			obj.Simulation.Start(obj.Settings.Calculation_method);
			% War Lastfluss erfolgreich?
			if obj.Simulation.StatusID ~= obj.Constants.SimulationOK
				% Im Fehlerfall, genauere Informationen zum Stand der Berechnung
				% ausgeben:
				if nargin > 1 && strcmpi(varargin{1}, 'silent')
					% no messages at all
				else
					% DEFAULT: Give all possible information!
					obj.disp_messages('all', 1);
				end
				exception = MException('SINCAL:SimulationFailed',...
					'SINCAL Calculation failded!');
				throw(exception);
			end
		end
		
		function QR = send_SQL_query(obj, sql_string)
			% [QR] = SINCAL.send_SQL_query(sql_string)
			%
			% send_SQL_query    Executes the sql statement against the connection
			% SINCAL.Database_Connection
			%
			% Inputs:
			%   sql_string,    SQL statement to be executed
			%
			% Output
			%   QR,            cell array of query results
			%
			% Notes: Convert cells to strings using char. Convert cells to numeric
			% data using cell2mat() for ints or double(cell2mat()) for floats
			%
			% This code basis on Tim Myers code (oledb*.m) and use ADO OLE DB instead
			% of OWC - Office Web Component
			%
			% Martin Furlan
			% martin.furlan@iskra-ae.com
			% January 2007
			
			%open recordset and run query
			invoke(obj.Database_Connection,'BeginTrans');
			try
				r = invoke(obj.Database_Connection,'Execute',sql_string);
				invoke(obj.Database_Connection,'CommitTrans');
				sclSuccess = 1;
			catch
				invoke(obj.Database_Connection,'RollbackTrans');
				sclSuccess = 0;
			end
			
			%retrieve data from recordset
			if sclSuccess && r.recordcount>0
				QR=invoke(r,'getrows');
				QR=QR';
			else
				QR=[];
			end
			
			if sclSuccess
				%release recordset
				invoke(r,'release');
			end
		end
		
		function success = insert_SQL_query(obj, sql_string)
			%success  = SINCAL.instert_SQL_query(sql_string)
			%
			% adodbinsert   Executes the sql statement against the connection cn
			%
			% Inputs:
			%   sql_string,    SQL statement to be executed
			%
			% Output
			%   success,       return: 1 - successful or 0 - unsuccessful
			%
			% Notes: Convert cells to strings using char. Convert cells to numeric
			% data using cell2mat() for ints or double(cell2mat()) for floats
			%
			% This code basis on Tim Myers code (oledb*.m) and use ADO OLE DB instead
			% of OWC - Office Web Component
			%
			% Martin Furlan
			% martin.furlan@iskra-ae.com
			% January 2007
			
			% Execute insert into database
			invoke(obj.Database_Connection,'BeginTrans');
			try
				invoke(obj.Database_Connection,'Execute',sql_string);
				invoke(obj.Database_Connection,'CommitTrans');
				success = 1;
			catch
				invoke(obj.Database_Connection,'RollbackTrans');
				success = 0;
			end
		end
		
	end
	
	methods (Hidden)
		
		function set_database_path (obj, varargin)
			%SET_DATABASE_PATH    aktualisiert die Datenbankangaben
			%    SINCAL.SET_DATABASE_PATH (PATH, NAME) befüllt aus den Namen NAME
			%    des zu betrachtenden Netzes sowie der Pfadangabe PATH, wo sich die
			%    Netzdaten befinden (Ort der .sin-Datei) innerhalb des SINCAL-Instanz
			%    die Sub-Struktur "Database" welche den vollständigen Pfad zur
			%    Datenbankdatei "DBfilename" und zum .sin-File "SINfilename" enthält.
			%
			%    Die Funktion überprüft dabei, ob diese Dateien vorhanden sind. Es
			%    erfolgt jedoch kein Check, ob es sich um gültie PSS(R)SINCAL Dateien
			%    handelt!
			
			if nargin == 1
				name = obj.Settings.Grid_name;
				path = obj.Settings.Grid_path;
			elseif nargin == 3
				path = varargin{1};
				name = varargin{2};
			else
				exception = MException('SINCAL:Database:WrongInputArgs',...
					'Wrong function call, check Input Arguments!');
				throw(exception);
			end
			
			% Testen, ob der angegebene Ordner vorhanden ist:
			if isdir([path,filesep,name,'_files'])
				% Aus den Angaben zur Datenbank vollständige Namen erzeugen:
				% Datenbankfile:
				obj.Database.DBfilename = [path,filesep,name,'_files\database.mdb'];
				% SINCAL-Konfigurationsfile:
				obj.Database.SINfilename = [path,filesep,name,'.sin'];
				% Checken, ob die angegegbenen Dateien existieren
				try
					t = fileattrib(obj.Database.SINfilename);
					t = fileattrib(obj.Database.DBfilename);
					% Daten in Einstellungen übernehmen:
					obj.Settings.Grid_name = name;
					obj.Settings.Grid_path = path;
					obj.new_database_path = 0;
					obj.new_database_name = 0;
				catch ME
					% Wenn nicht --> Fehlermeldung
					exception = MException('SINCAL:Database:FilesDontExist',...
						['The specified database-files do not exist!',...
						' Check Input Arguments!']);
					exception = addCause (ME, exception);
					% Daten zurücksetzen:
					obj.Database = [];
					obj.close_database;
					throw(exception)
				end
			else
				% wenn nicht --> Fehlermeldung
				exception = MException('SINCAL:Database:FilesDontExist',...
					['The specified database-folder do not exist!',...
					' Check Input Arguments!']);
				% Daten zurücksetzen:
				obj.Database = [];
				obj.close_database;
				throw(exception)
			end
		end
		
		function update_parameter(obj, parameter_name, input)
			%UPDATE_PARAMETER    Parameter überprüfen und aktualisieren
			%    SINCAL.UPDATE_PARAMETER(PARAMETER_NAME, INPUT) setzt den Wert des
			%    Parameters, der durch den Namen PARAMETER_NAME gegeben ist, auf
			%    INPUT. Dabei wird ein simpler Plausibilitätscheck durchgeführt.
			
			% Übergebene Parameter übernehmen, zuvor kontrollieren, ob diese gültig
			% sind:
			switch parameter_name
				case 'Calculation_method'
					% Muss ein String sein
					if ischar(input)
						obj.Settings.Calculation_method = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be a string!']);
						throw(exception);
					end
					obj.new_database_path = 1;
					obj.new_database_name = 1;
				case 'Batch_mode'
					% Muss eine Zahl sein
					if isnumeric (input)
						obj.Settings.Batch_mode = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				case 'Database_typ'
					% Muss ein String sein
					if ischar (input)
						obj.Settings.Database_typ = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be a string!']);
						throw(exception);
					end
				case 'Database_Connector'
					if ischar (input)
						obj.Settings.Database_Connector = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be a string!']);
						throw(exception);
					end
				case 'Grid_name'
					% Muss ein String sein
					if ischar (input)
						obj.Settings.Grid_name = input;
						obj.new_database_name = 1;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be a string!']);
						throw(exception);
					end
				case 'Grid_path'
					% Muss ein String sein
					if ischar (input)
						obj.Settings.Grid_path = input;
						obj.new_database_path = 1;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name...
							,''' has to be a string!']);
						throw(exception);
					end
				case 'Language'
					% Muss ein String sein
					if ischar (input)
						obj.Settings.Language = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name...
							,''' has to be a string!']);
						throw(exception);
					end
				case 'Database_Server_Name'
					if ischar (input)
						obj.Settings.Database_Server_Name = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name...
							,''' has to be a string!']);
						throw(exception);
					end
				case 'Settings.Database_User_ID'
					if ischar (input)
						obj.Settings.Settings.Database_User_ID = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name...
							,''' has to be a string!']);
						throw(exception);
					end
				case 'Database_Password'
					if ischar (input)
						obj.Settings.Database_Password = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name...
							,''' has to be a string!']);
						throw(exception);
					end
				case 'Command_Timeout'
					if isnumeric (input)
						obj.Settings.Command_Timeout = input;
					else
						exception = MException(...
							'SINCAL:UpdateParameter:WrongInput', ...
							['Value for ''',parameter_name,...
							''' has to be numeric!']);
						throw(exception);
					end
				otherwise
					exception = MException(...
						'SINCAL:UpdateParameter:UnknownParameter', ...
						'Parameter ''',parameter_name,''' is unknown!');
					throw(exception);
			end
		end
		
		function disp_messages(obj, mode, varargin)
			%DISP_MESSAGES    gibt die SINCAL-Statusinformationen in Konsole aus
			%    SINCAL.DISP_MESSAGES(MODE) bringt die Statusmeldungen innerhalb
			%    des SINCAL-Simulationsobjektes SIMULATION zur Anzeige in der
			%    MATLAB-Konsole. Über den String MODE wird festgelegt, welche
			%    Meldungen angezeigt werden:
			%        MODE = 'all'        Alle Meldungen werden angzeigt (Status,
			%                                Infos, Warnungen und Fehler).
			%        MODE = 'warning'    Nur Warnungen und Fehlermeldungen werden
			%                                ausgegeben.
			%        MODE = 'error'      Nur Fehlermeldungen werden ausgegeben.
			%
			%    SINCAL.DISP_MESSAGES(MODE, DETAILS) bringt zusätlich zu den Status-
			%    meldungen noch detailierte Informationen über die von der Meldung
			%    betroffenen Elemente zur Anzeige:
			%        DETAILS = true      Zusätzlich zur Meldung werde auch die
			%                                Objekt-IDs und Namen jener Elemente
			%                                ausgegeben, auf die sich die Meldung
			%                                bezieht (sofern möglich).
			%        DETAILS = false     Es werden keine detailierten Informationen
			%                                ausgegeben.
			
			% Argumentenliste überprüfen:
			if nargin < 3;
				% Normaler Modus der Stautsmeldungen:
				details = false;
			elseif nargin == 3
				details = varargin{1};
			end
			
			% Falls detailierte Infos gewünscht, zunächst die Daten der Elemente
			% einlesen:
			if details
				% Objekt für die Virtuelle Datenbank auslesen (für Zugriff auf diese)
				if isempty(obj.NetworkDataSource)
					obj.NetworkDataSource = obj.Simulation.DB_EL;
				end
				% Auslesen der Elementtabelle (um die betroffenen Elemente angeben zu
				% können):
				[data, names] = obj.table_data_load('Element');
				% Überprüfung, ob Daten für eine detailierte Anzeige vorhanden sind:
				if isempty(data)
					% Falls nicht, Detailanzeige deaktivieren:
					details = false;
				end
			end
			
			% Ein Array erstellen, das die einzelnen Moden codiert:
			switch lower(mode)
				case 'all'
					% [ status, info, warning, error]
					show_array = [1, 1, 1, 1];
				case 'warning'
					% [ status, info, warning, error]
					show_array = [0, 0, 1, 1];
				case 'error'
					% [ status, info, warning, error]
					show_array = [0, 0, 0, 1];
			end
			
			% Meldung aus SINCAL-Simulationsobjekt auslesen:
			messages = obj.Simulation.Messages;
			% Anzahl der Meldungen feststellen:
			num_mesa = messages.Count;
			% Über alle Meldunge iterieren und entsprechend den Einstellungen zur
			% Anzeige bringen:
			for i=1:num_mesa
				msg = messages.get('Item',i);
				switch msg.Type
					case 1 %Status
						if show_array(1)
							disp(['    Status: ',msg.Text]);
						end
					case 2 %Info
						if show_array(2)
							disp(['    Info: ',msg.Text]);
						end
					case 3 %Warnung
						if show_array(3)
							disp(['    Warnung: ',msg.Text]);
							num_obj=msg.CountObjectIds;
							if details
								for j=1:num_obj
									obj_ID = msg.ObjectIdAt(j);
									name = cell2mat(data(...
										cell2mat(...
										data(:,strcmp('Element_ID',names)))==obj_ID,...
										strcmp('Name',names)));
									if ~isempty(name)
										name = strtrim(name);
										disp([...
											'        Obj_ID: ',...
											num2str(msg.ObjectIdAt(j),'%04.0f'),...
											'    Name: ',name]);
									else
										disp(...
											'        unknown Obj ?!?');
									end
								end
							end
						end
					case 4 %Fehler
						if show_array(4)
							disp(['    Fehler: ',msg.Text]);
							if details
								num_obj=msg.CountObjectIds;
								for j=1:num_obj
									obj_ID = msg.ObjectIdAt(j);
									name = cell2mat(data(...
										cell2mat(data(:,...
										strcmp('Element_ID',names)))==obj_ID,...
										strcmp('Name',names)));
									if ~isempty(name)
										name = strtrim(name);
										disp([...
											'        Obj_ID: ',...
											num2str(msg.ObjectIdAt(j)),...
											'    Name: ',name]);
									else
										disp(...
											'        unknown Obj ?!?');
									end
								end
							end
						end
				end
			end
		end
		
	end
end

