function output_image = get_iso_image(SincalDoc, calc_method, mode_image_ouput, ...
	varargin)
%GET_ISO_IMAGE    erstellt in der SINCAL-Oberfläche ein ISO-Bild und liest dieses ein
%    Genaue Beschreibung fehlt!

% Erstellt von:            Franz Zeilinger - 11.07.2012
% Letzte Änderung durch:   Franz Zeilinger - 11.07.2012

% Default-Werte:
Parameters = {...
	'Points','Page';...
	'SubDivisions',200;...
	'Gradient',false;...
	'NodeContour',true;...
	'ElementContour',true;...
	'Gravity',5;...
	'VisibleCenter',false;...
	'VisibleCenterSize',50;...
	'MinValue',0;...
	'BaseValue',50;...
	'MaxValue',100;...
	};
image_grid = [];
im_size = [];

% Eingangsvariablen behandlen:
if nargin < 3
	exception = MException('InputParameter:NumberArguments',...
		['Wrong number of inputarguments. ',...
		'Input looks at least like (SincalDoc, calc_method, mode_image_ouput)']);
	throw(exception);
elseif nargin > 3 && mod(numel(varargin),2) == 0
	% Für zukünftige Erweiterungen: User kann über Parameter-Name-Wert-Paare die
	% Einstellungen der Anzeige beliebig ändern...
	for i=1:2:numel(varargin)
		% Parametername auslesen:
		parameter = varargin{i};
		% Die Parameter entsprechend zuweisen:
		switch parameter
			case 'Grid Image'
				image_grid = varargin{i+1};
			case 'ISO-Imagesize'
				im_size = varargin{i+1};
			otherwise
				exception = MException('InputParameter:ParameterUnknown',...
					['The spezified parameter ', parameter, 'can not be ',...
					'processed']);
				throw(exception);
		end
	end	
elseif nargin > 3
	exception = MException('InputParameter:NumberArguments',...
		['Wrong number of inputarguments. ',...
		'Input looks like (SincalDoc, calc_method, mode_image_ouput, ',...
		'''Parameter_Name'', Parameter_Value)']);
	throw(exception);
end

% Nachbearbeiten der Eingaben:
if ~isempty(image_grid)
	% Ermitteln der Größe des übergebenen Netzbildes, damit das ISO-Flächenbild in 
	% der gleichen Größe erzeugt wird:
	im_size = size(image_grid);
end

% Applikationsobjekte laden, um Zugriff auf ISO-Flächenerzeugung zu bekommen:
NetTools = SincalDoc.GetNetTools();
ISOArea = NetTools.GetISO();

% In der SINCAL-Oberfläche die Daten aus der Datenbank erneut
% laden ("Refresh") damit die aktuellen Ergebnisse vorliegen:
switch calc_method
	case 'LF_USYM'
		SincalDoc.Reload('ULFNodeResult');   % Knotenergebnisse
		SincalDoc.Reload('ULFBranchResult'); % Zweigelementergebnisse
	otherwise
		exception = MException('CalulationMethod:NotKnownMethod', ...
			'The specified calculation method can not be processed!');
		throw(exception);
end
SincalDoc.UpdateData(2, 4);
SincalDoc.UpdateData(1, 4);          % Anzeige aktualisieren

% Einstellungen für die Visulisisierung:
switch mode_image_ouput
	case 'ULFResults'
		% 20 = Unsymmetrischer Lastfluss S
		%  1 = "Area Weight" = Flächengewicht
		ISOArea.SetVisualizationType(20, 1, true);
		% Zugehörige Parameter:
		ISOArea.set('Parameter','Points','Page');
		ISOArea.set('Parameter','SubDivisions',200);
		ISOArea.set('Parameter','Gradient',false);
		ISOArea.set('Parameter','NodeContour',true);
		ISOArea.set('Parameter','ElementContour',true);
		ISOArea.set('Parameter','Gravity',5);
		ISOArea.set('Parameter','VisibleCenter',false);
		ISOArea.set('Parameter','VisibleCenterSize',50);
		ISOArea.set('Parameter','MinValue',0);
		ISOArea.set('Parameter','BaseValue',50);
		ISOArea.set('Parameter','MaxValue',100);
		% Farbeinstellungen:
		ISOArea.ResetColors;
		%   0% des Wertebereichs -> Blau
		ISOArea.SetColor (  0,   0,   0, 255);
		%  50% des Wertebereichs -> Grün
		ISOArea.SetColor ( 50,   0, 255,   0);
		% 100% des Wertebereichs -> Rot
		ISOArea.SetColor (100, 255,   0,   0);
		% Dateiname festlegen:
	case 'ULFUUn'
		% 18 = Unsymmetrischer Lastfluss U/Un
		%  2 = "Shepard"
		ISOArea.SetVisualizationType(18, 'Shepard', true);
		% Zugehörige Parameter:
		ISOArea.set('Parameter','Points','Page');
		ISOArea.set('Parameter','SubDivisions',200);
		ISOArea.set('Parameter','Gradient',false);
		ISOArea.set('Parameter','NodeContour',true);
		ISOArea.set('Parameter','ElementContour',true);
		ISOArea.set('Parameter','MinValue' , 98);
		ISOArea.set('Parameter','BaseValue',100);
		ISOArea.set('Parameter','MaxValue' ,102);
		% Farbeinstellungen:
		ISOArea.ResetColors;
		%   0% des Wertebereichs -> Blau
		ISOArea.SetColor (  0,   0,   0, 255);
		%  50% des Wertebereichs -> Grün
		ISOArea.SetColor ( 50,   0, 255,   0);
		% 100% des Wertebereichs -> Rot
		ISOArea.SetColor (100, 255,   0,   0);
		% Dateiname festlegen:
end
% ISO-Fläche Zeichnen:
bOK = ISOArea.Create('ISO1');
if ~bOK
% 	disp('Darstellung nicht möglich');
% 	SincalDoc = [];
% 	SincalApp.CloseDocument(DataBase.Sinfilen);
% 	clear all;
% 	return;
end

% Pfadeinstellungen für speichern des temporären Bildes ermitteln:
path = pwd;
filename = [path,'Temp','.pic'];

% ISO-Flächenbild speichern:
NetTools.Save('ISO1',filename);

% ISO-Fläche in ein MATLAB-Image-Array umrechnen:
output_image = pic2rgb_image(filename,im_size);
% die .pic-Datei wieder löschen:
delete(filename);

% Falls Bild vorhanden, das Netz in die ISO-Fläche einzeichnen:
if ~isempty(image_grid)
	output_image(image_grid<=3) = image_grid(image_grid<=3);
end

% Die Randpixel wegschneiden:
output_image = output_image(2:end-1,2:end-1,:);

end