classdef SINCAL < handle
	%SINCAL    stellt Zugriff auf PSS(R)SINCAL zur Verf�gung
	%
	%    Detaillierte Beschreibung fehlt!
	%
	%    Die SINCAL-Instanz wird verwendet, um alle, mit dem Zugriff auf
	%    SINCAL relevanten Variablen und Methoden zusammenzufassen.
	
	% Version:                 1.1
	% Erstellt von:            Franz Zeilinger - 30.10.2012
	% Letzte �nderung durch:   Franz Zeilinger - 29.01.2013
	
	properties
		Settings                
	%        Struktur mit den aktuellen Einstellungen
		Valid_Database = false  
	%        Ist eine g�ltige Verbindung zu einer Datenbank aktiv?
		Valid_Document = false  
	%        Ist das aktuelle Netz in der SINCAL-Oberfl�che aktiv?	
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
	%        COM-Objekt einer SINCAL-Berechnung (eigentliches Objekt, �ber das
	%        Lastflussrechnung gesteuert wird.
		NetworkDataSource = []; 
	%        COM-Objekt f�r Zugriff auf virtuelle Datenbank des aktuellen Netzes.
		Application = []; 
	%        COM-Objekt f�r Zugriff auf SINCAL Anwendung (GUI).	
		Document = []; 
	%        COM-Objekt f�r Zugriff Dokument in SINCAL-Oberfl�che.		
	end
	
	methods
		
		function obj = SINCAL (varargin)
			%SINCAL    Konstruktor der SINCAL-Klasse
			%    
			%    Detaillierte Beschreibung fehlt noch!
			%
			%    Weiters wird innerhalb der SINCAL-Klasse eine Sub-Struktur
			%    "Constants" erstellt, die hilfreiche Konstanten f�r das Arbeiten mit
			%    SINCAL enthalten. So sollen alle numerischen Parameter durch
			%    klingende Namen hier ersetzt werden und in der gemeinsamen
			%    SINCAL-Struktur zur Verf�gung stehen!
			
			% Hilfreiche Konstanten:
			obj.Constants.SimulationOK      		    = 1101;    %Berechnung erfolgreich beendet.
			obj.Constants.SimulationLoadDB_Failed	    = 1502;    %Laden der Datenbank ist fehlgeschlagen!
			% Hexwerte f�r die einzelnen Eingabedatenarten:
			obj.Constants.Input_Mask.Loadflow        = '00000001'; %Daten f�r Lastfluss vorhanden
			obj.Constants.Input_Mask.Short_Circiut   = '00000002'; %Daten f�r Kurzschluss vorhanden
			obj.Constants.Input_Mask.Unsym_Loadflow  = '00000400'; %Unsymmetrischer Lastfluss
			
			obj.Constants.Application.AutoSelResetAll  = 0;
			obj.Constants.Application.AutoSelUpdateAll = 1;
			obj.Constants.Application.AutoSelNode      = 2;
			obj.Constants.Application.AutoSelElement   = 3;
			
			obj.Constants.Application.AutoUpdateResults    = 2;
			obj.Constants.Application.AutoUpdateRedrawView = 4;
			obj.Constants.Application.AutoCalcLF           = 38;
			
			% Default-Einstellungen:
			obj.Settings.Calculation_method = 'LF_USYM';
			obj.Settings.Batch_mode  = 4;
			obj.Settings.Database_typ = 'DB_EL';
			obj.Settings.Language = 'DE';
			% Angaben des aktuelle Netzes:
			obj.Settings.Grid_name = [];
			obj.Settings.Grid_path = [];
			
			obj.update_settings(varargin{:});
		end
		
		function open_database(obj, varargin)
			%OPEN_DATABASE     erzeugt SINCAL Simulationsobjekt u. l�dt die Datenbank
			%    genaue Beschreibung fehlt!
			
			% Falls bereits eine Datenbank ge�ffnet ist, diese zuvor schlie�en:
			if obj.Valid_Database
				obj.close_database;
			end
			
			% �berpr�fen, ob eine Datenbank angegeben wurde:
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
				% server" (Anmerkung: Windows l�sst nicht zu, dass eine 32-bit
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
			
			% Festlegen, welche Eingabeparameter vorhanden sind bzw. f�r die
			% Berechnung ben�tigt werden. Dabei erfolgt eine logische
			% ODER-Verkn�pfung der Bin�rmuster f�r die einzelnen Datenarten (-->
			% siehe SINCAL-Handbuch) z.B. Lastfluss & Kurzschluss vorhanden: &h0001
			% || &h0002 = &d3
			% Hier wird mit den definierten Hex-Werten (obj.Constants.Input_Mask)
			% gearbeitet, die ODER-Verkn�pfung wird dann zu einer Addition:
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
				otherwise
					% Fehlermeldung, da die Berechnungsmethode noch nicht verarbeiter
					% werden kann (z.B. weil die vorliegende SINCAL-Klasse dies noch
					% nicht unterst�tzt bzw. erst entsprechend erweitert werden muss)
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
			% �berpr�fen, ob Laden erfolgreich war:
			if obj.Simulation.StatusID == obj.Constants.SimulationLoadDB_Failed
				obj.close_database; %#ok<*NASGU>
				exception = MException('SINCAL:OpenDataBase:LoadDBFailed',...
					['LoadDB failed, unable to oben SINCAL-Database!',...
					' Check settings or Licenses!']);
				throw(exception);
			end
			
			% G�ltige Datenbankverbindung vorhanden!
			obj.Valid_Database = true;
			
			% Objekt f�r die virtuelle Datenbank auslesen (f�r Zugriff auf diese)
			obj.NetworkDataSource = obj.Simulation.(obj.Settings.Database_typ);
			if isempty(obj.NetworkDataSource)
				obj.close_database;
				exception = MException(...
					'SINCAL:OpenDataBase:LoadVirtualDataBaseFailed',...
					'Loading of the virtual database failed!');
				throw(exception);
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
				exception = MException('SINCAL:OpenApplication:Failed',...
					'The opening of the SINCAL Application failed!');
				throw(exception);
			end
			% Das Netz in der SINCAL-Oberfl�che �ffnen:
			obj.Document = obj.Application.OpenDocument(obj.Database.SINfilename);
			if isempty(obj.Document)
				exception = MException('SINCAL:OpenDocument:Failed',...
					'The opening of the specified SINCAL document failed!');
				throw(exception);
			end
			
			if reopen
				obj.open_database
			end
			
			obj.Valid_Document = true;
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
		
		function close_file(obj)
			try
				if obj.Valid_Document
					obj.Document = [];
					obj.Application.CloseDocument(obj.Database.SINfilename);
					obj.Valid_Document = false;
				end
			catch ME
				obj.Valid_Document = false;
				obj.Document = [];
			end
		end
		
		function update_settings(obj, varargin)
			%UPDATE_SETTINGS    Erg�nzt Parametereinstellungen der Klasse
			%    genaue Beschreibung fehlt!
			
			% wurden noch Parameter �bergeben?
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
				% Fehler, weil Parameter nicht in Dreiergruppe �bergeben wurde:
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
		end
		
		function close_database(obj)
			%CLOSE_DATABASE    schlie�t offene SINCAL-COM-Objekte bzw. Applikationen
			%   Detailierte Beschreibung fehlt!
			
			obj.NetworkDataSource = [];
			obj.Simulation = [];
			obj.SimulationSrv = [];
			obj.Valid_Database = false;
		end
		
		function [data, names] = table_data_load (obj, tablename)
			%TABLE_DATA_LOAD    l�dt Tabelle aus einer virtuellen SINCAL-Datenbank
			%    SINCAL.TABLE_DATA_LOAD (TABLENAME) l�dt eine komplette Tabelle,
			%    welche durch die Tabellenbezeichnung TABLENAME angegeben wird aus
			%    der virtuellen SINCAL-Datenbank in die interne Daten-Struktur
			%    SINCAL.TABLES. 
			%    TABLE ist ein Cell-Array, das in der ersten Zeile die
			%    Spaltenbezeichnung und in den darauffolgenden Zeilen die Inhalte der 
			%    Tabelle wiedergibt. Diese Tabelle ist dann via
			%    SINCAL.TABLES.TABLENAME verf�gbar. 
			%    Auch bei allen anderen Varianten des Aufrufs dieser Methode wird die
			%    Tabelle in der internen Datenstruktur hinterlegt.
			%    
			%    TABLE = SINCAL.TABLE_DATA_LOAD (TABLENAME) l�dt eine komplette
			%    Tabelle TABLE und gibt diese zus�tzlich zur�ck.
			%
			%    [DATA, NAMES] = TABLE_DATA_LOAD (SINCAL, TABLENAME) l�dt die Tabelle
			%    getrennt in zwei seperaten Teilen:
			%        DATA enth�lt die Tabellendaten als Cell-Array.
			%        NAMES enth�lt die Spaltenbezeichnungen, ebenfalls als Cell-Array
			%        von Strings.
			
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
		
		function start_calculation(obj)
			%START_CALCULATION    initiert eine Berechnung
			%    SINCAL.START_CALCULATION startet eine Berechnung innerhalb des
			%    SINCAL.Simulation-Objekts gem�� den zuvor defnierten Einstellungen
			%    (siehe SINCAL.OPEN_DATABASE). Falls es zu Problemen bei der
			%    Berechnung kommt, erfolgt eine detailierte Ausgabe des Fehlers in
			%    der MATLAB-Konsole.
			
			% Starten der Lastflussrechnung:
			obj.Simulation.Start(obj.Settings.Calculation_method);
			% War Lastfluss erfolgreich?
			if obj.Simulation.StatusID ~= obj.Constants.SimulationOK
				% Im Fehlerfall, genauere Informationen zum Stand der Berechnung
				% ausgeben:
				obj.disp_messages('all', 1);
				exception = MException('SINCAL:SimulationFailed',...
					'SINCAL Calculation failded!');
				throw(exception);
			end
		end
		
	end
	
	methods (Hidden)
		
		function set_database_path (obj, varargin)
			%SET_DATABASE_PATH    aktualisiert die Datenbankangaben
			%    SINCAL.SET_DATABASE_PATH (PATH, NAME) bef�llt aus den Namen NAME
			%    des zu betrachtenden Netzes sowie der Pfadangabe PATH, wo sich die
			%    Netzdaten befinden (Ort der .sin-Datei) innerhalb des SINCAL-Instanz
			%    die Sub-Struktur "Database" welche den vollst�ndigen Pfad zur
			%    Datenbankdatei "DBfilename" und zum .sin-File "SINfilename" enth�lt.
			%
			%    Die Funktion �berpr�ft dabei, ob diese Dateien vorhanden sind. Es
			%    erfolgt jedoch kein Check, ob es sich um g�ltie PSS(R)SINCAL Dateien
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
				% Aus den Angaben zur Datenbank vollst�ndige Namen erzeugen:
				% Datenbankfile:
				obj.Database.DBfilename = [path,filesep,name,'_files\database.mdb'];
				% SINCAL-Konfigurationsfile:
				obj.Database.SINfilename = [path,filesep,name,'.sin'];
				% Checken, ob die angegegbenen Dateien existieren
				try
					fileattrib(obj.Database.SINfilename);
					fileattrib(obj.Database.DBfilename);
					% Daten in Einstellungen �bernehmen:
					obj.Settings.Grid_name = name;
					obj.Settings.Grid_path = path;
					obj.new_database_path = 0;
					obj.new_database_name = 0;
					
					% die neue Datenbank �ffnen:
					obj.open_database;

				catch ME
					% Wenn nicht --> Fehlermeldung
					exception = MException('SINCAL:Database:FilesDontExist',...
						['The specified database-files do not exist!',...
						' Check Input Arguments!']);
					exception = addCause (ME, exception);
					% Daten zur�cksetzen:
					obj.Database = [];
					obj.close_database;
					throw(exception)
				end
			else
				% wenn nicht --> Fehlermeldung
				exception = MException('SINCAL:Database:FilesDontExist',...
					['The specified database-folder do not exist!',...
					' Check Input Arguments!']);
				% Daten zur�cksetzen:
				obj.Database = [];
				obj.close_database;
				throw(exception)
			end
		end
		
		function update_parameter(obj, parameter_name, input)
			%UPDATE_PARAMETER    Parameter �berpr�fen und aktualisieren
			%    SINCAL.UPDATE_PARAMETER(PARAMETER_NAME, INPUT) setzt den Wert des
			%    Parameters, der durch den Namen PARAMETER_NAME gegeben ist, auf
			%    INPUT. Dabei wird ein simpler Plausibilit�tscheck durchgef�hrt.
			
			% �bergebene Parameter �bernehmen, zuvor kontrollieren, ob diese g�ltig
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
			%    MATLAB-Konsole. �ber den String MODE wird festgelegt, welche
			%    Meldungen angezeigt werden: 
			%        MODE = 'all'        Alle Meldungen werden angzeigt (Status,
			%                                Infos, Warnungen und Fehler).
			%        MODE = 'warning'    Nur Warnungen und Fehlermeldungen werden
			%                                ausgegeben. 
			%        MODE = 'error'      Nur Fehlermeldungen werden ausgegeben.
			%
			%    SINCAL.DISP_MESSAGES(MODE, DETAILS) bringt zus�tlich zu den Status-
			%    meldungen noch detailierte Informationen �ber die von der Meldung
			%    betroffenen Elemente zur Anzeige:
			%        DETAILS = true      Zus�tzlich zur Meldung werde auch die
			%                                Objekt-IDs und Namen jener Elemente
			%                                ausgegeben, auf die sich die Meldung
			%                                bezieht (sofern m�glich).
			%        DETAILS = false     Es werden keine detailierten Informationen
			%                                ausgegeben. 
			
			% Argumentenliste �berpr�fen:
			if nargin < 3;
				% Normaler Modus der Stautsmeldungen:
				details = false;
			elseif nargin == 3
				details = varargin{1};
			end
			
			% Falls detailierte Infos gew�nscht, zun�chst die Daten der Elemente
			% einlesen: 
			if details
				% Objekt f�r die Virtuelle Datenbank auslesen (f�r Zugriff auf diese)
				if isempty(obj.NetworkDataSource)
					obj.NetworkDataSource = obj.Simulation.DB_EL;
				end
				% Auslesen der Elementtabelle (um die betroffenen Elemente angeben zu
				% k�nnen): 
				[data, names] = obj.table_data_load('Element');
				% �berpr�fung, ob Daten f�r eine detailierte Anzeige vorhanden sind:
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
			% �ber alle Meldunge iterieren und entsprechend den Einstellungen zur
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
									name = strtrim(name);
									disp([...
										'        Obj_ID: ',...
										num2str(msg.ObjectIdAt(j),'%04.0f'),...
										'    Name: ',name]);
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
									name = strtrim(name);
									disp([...
										'        Obj_ID: ',...
										num2str(msg.ObjectIdAt(j)),...
										'    Name: ',name]);
								end
							end
						end
				end
			end
		end
		
	end
end

