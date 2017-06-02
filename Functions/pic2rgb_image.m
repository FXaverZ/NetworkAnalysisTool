function output_image = pic2rgb_image(filename, varargin)
%PIC2RGB_IMAGE    Konvertierung eines .pic-File in ein MATLAB-RGB-Array
%    OUTPUT_IMAGE = PIC2RGB_IMAGE(FILENAME) erstellt aus dem .pic-File, welches durch
%    FILENAME gegeben ist, ein Array, das einem RGB-Bild entspricht. Die Größe des
%    Bildes ist maximal 1024 x 768 Pixel, wobei das ausgebene Bild nicht verzerrt
%    wird!
%
%    OUTPUT_IMAGE = PIC2RGB_IMAGE(FILENAME, IMAGE_SIZE) erstellt ein RGB-Bild mit der
%    Größe, die durch das Array IMAGE_SIZE bestimmt wird. Dieses ist genauso
%    aufgebaut, wie der Rückgabewert der SIZE-Funktion auf ein RGB-Bild-Array: 
%        IMAGE_SIZE = [ Höhe in Pixel, Breite in Pixel, 3 (Farben)]
%    Das Bild wird genau in diese Größe eingepasst, es kann daher ev. zu einer
%    Verzerrung des Bildes kommen! 
%    Falls IMAGE_SIZE ein leeres Array ist, wird ein Bild mit maximal 1024 x 768
%    Pixel erzeugt, wobei das ausgebene Bild nicht verzerrt wird!
%
%    OUTPUT_IMAGE = PIC2RGB_IMAGE(FILENAME, IMAGE_SIZE, DISTORTION) erlaubt über den
%    Parameter DISTORTION festzulegen, wie das RGB-Bild bei der Erstellung verzerrt
%    wird:
%        DISTORTION = 'Off'    Das Bild wird nicht verzerrt. Die maximale Größe des
%                              Bildes ist durch IMAGE_SIZE gegeben, d.h. die maximale
%                              Dimension des Bildes wird in die gegebene Größe
%                              eingepasst.
%        DISTORTION = 'On'     (DEFAULT) Das Bild wird verzerrt und an die Größe
%                              gegeben durch IMAGE_SIZE angepasst.
% 
%    ACHTUNG: Diese Funktion funktioniert derzeit nur für ISO-Flächenbilder, da hier
%    nur Rhomben gezeichnet werde müssen. Andere geometrische Formen werden (noch)
%    nicht unterstützt!

% Erstellt von:            Franz Zeilinger - 04.07.2012
% Letzte Änderung durch:   Franz Zeilinger - 11.07.2012

% Inputs verarbeiten:
distortion = true;
if nargin == 1
	% Default-Bildgröße:
	image_size = [768, 1024, 3];
	distortion = false;
elseif nargin == 2
	image_size = varargin{1};
	distortion = true;
elseif nargin == 3
	image_size = varargin{1};
	switch lower(varargin{2})
		case 'off'
			distortion = false;
		case 'on'
			distortion = true;
		otherwise
			exception = MException('InputParameter:ParameterValueUnknown',...
				['The spezified parameter for DISTORTION ''', varargin{2}, ...
				''' can not be processed']);
			throw(exception);
	end
end

% Die Bildgrößenangabe anpassen (Übergabeformat ist jenes, dass die SIZE-Funktion für
% ein Bild ausgibt, diese muss angepasst und reduziert werden):
if ~isempty(image_size);
	image_size_pixel(1) = image_size(2);
	image_size_pixel(2) = image_size(1);
else
	image_size_pixel = [1024, 768];
end

% Den Text des .pic-Files einlesen:
try
	text = fileread(filename);
	% Den Text zeilenweise aufspalten:
	text = regexp(text, '\n', 'split');
catch ME
	exception = MException('ReadInFile:ErrorReadingFile', ...
		'The specified file could not be read!');
	exception = addCause(exception, ME);
	throw(exception);
end
% Nun liegt ein cell-Array im gleichen Format wie das .pic-Textfile vor!

% Überprüfung, ob ein gültiges File eingelesen wurde (anhand der ersten Zeile):
if ~strncmp(text(1),'CADBOX V_2',10);
	exception = MException('VerifyInput:InvalidFile', ...
		'The selected file has not the correct format!');
	throw(exception);
end

% Nun die Farbskalen einlesen, dazu nach dem Ort dieser Suchen:
idx_st = find(strncmp(text,'COLOR.',length('COLOR.')))+1;
if isempty(idx_st)
	exception = MException('ReadInValues:NoColorTable', ...
		'The selected file has no color table!');
	throw(exception);
end
try 
	% Das Ende der Farbskala ermitteln und die einzelnen Farbwerte einlesen:
	idx_en = find(strncmp(text(idx_st:end),'......',length('......'))...
		,1,'first')+idx_st-2;
	colors = text(idx_st:idx_en);
	data = cellfun(@get_color_from_str, colors, 'UniformOutput', false);
	data = cell2mat(data);
	colors = zeros(round(size(data,2)/3),3);
	colors(:,1)=data(1:3:end);
	colors(:,2)=data(2:3:end);
	colors(:,3)=data(3:3:end);
catch ME
	exception = MException('ReadInValues:CorruptedColorTable', ...
		'The selected file has a corrupted color table!');
	exception = addCause(exception, ME);
	throw(exception);
end
% Die Farben in das richtige Zahlenformat konvertieren:
colors = uint8(colors);

% Die Bildinformationen einlesen (derzeit nur Rechtecke = 'RHOMB.'). Dazu zuerst
% feststellen, wo überall als Einleitung 'RHOMB.' steht, die darunterliegenden Zeilen
% enthalten die Informationen über das Viereck:
idx_st = find(strncmp(text,'RHOMB.',length('RHOMB.')));
idx_en = find(strncmp(text(idx_st(end):end),'......',length('......'))...
	,1,'first')+idx_st(end);

% Die Ausdehnung der Rechtecke ermitteln und mit den Farbindex in ein [n,5]-Array
% ablegen in der Form: 
%    [x_min, y_min, x_max, y_max, color_idx]
output_image_raw=zeros(length(idx_st),5);
% Farbe der Füllung der Rechtecke ermitteln:
data = cellfun(@get_rhombus_color, text(idx_st+2:9:idx_en), 'UniformOutput', false);
output_image_raw(:,5)=cell2mat(data)+1;
% Koordinaten der Rechtecke ermitteln:
coordinates = zeros(4,2,length(idx_st));
for i = 1:4
	data = cellfun(@get_rhombus_coordinates, text(idx_st+3+i:9:idx_en),...
		'UniformOutput', false);
	data = cell2mat(data);
	coordinates(i,1,:)=data(1:2:end);
	coordinates(i,2,:)=data(2:2:end);
end
% Da es sich nur um Rechtecke handelt, werden die Koordinaten auf die Ausdehnung des
% Rechteckes umgerechnet und in das Ergebnisarray geschrieben:
output_image_raw(:,1) = squeeze(min(coordinates(:,1,:)));
output_image_raw(:,2) = squeeze(min(coordinates(:,2,:)));
output_image_raw(:,3) = squeeze(max(coordinates(:,1,:)));
output_image_raw(:,4) = squeeze(max(coordinates(:,2,:)));

% Nun liegen die Koordinaten aller Rechtecke in Metern vor. Diese müssen nun in ein
% Pixelbild umgewandelt werden, in der Größe, die durch IMAGE_SIZE gegeben ist, also
% zunächst die Größe des Bildes in Meter ermitteln: 
min_m = min(output_image_raw(:,1:4));
max_m = max(output_image_raw(:,1:4));
size_m(1,:) = min_m(1:2);
size_m(2,:) = max_m(3:4);

% Ausdehnung des Bildes in Meter ermitteln: 
size_image = [size_m(2,1)-size_m(1,1),size_m(2,2)-size_m(1,2)];
% Mit der Größe in Meter und der gewünschten Pixelgröße werde die Umrechnungsfaktoren
% sowie die Offsets für die einzelnen Achsen ermittelt:
if distortion
	% Das Bild darf beliebig verzerrt werden:
	u = (image_size_pixel-1)./size_image;
else
	% Das Bild in die maximale Größe einpassen, dazu erst die größte Dimension
	% finden: 
	if size_image(1) == size_image(2);
		% Falls die Bildseiten exakt gleich groß sind, Orientierung an der
		% gewünschten Ausgabegröße:
		if image_size_pixel(1) == image_size_pixel(1);
			% Falls auch hier beide Seiten gleich groß sind, einfach die erste Seite
			% auswählen:
			idx = [1 0];
		else
			% Größte Seite der gewünschten Ausgabegröße nehmen:
			idx = (image_size_pixel==max(image_size_pixel));
		end
	else
		% Größte Seite des Bildes nehmen:
		idx = (size_image==max(size_image));
	end
	% Über die größte Seite den Umrechnungsfaktor bestimmen:
	u = (image_size_pixel(idx)-1)/size_image(idx);
	u(2) = u;
	% Neue Pixelgröße ermitteln:
	image_size_pixel(~idx) = ceil(size_image(~idx)*u(~idx))+1;
end
offset = round([-size_m(1,1),-size_m(1,2)].*u);

% leeres Ausgabe-Bild erzeugen:
output_image = zeros(image_size_pixel(2),image_size_pixel(1),3);
% in richtiges Format konvertieren:
output_image = uint8(output_image);

% Die Koordinaten in Pixelwerte umrechnen:
output_image_raw(:,[1,3]) = round(output_image_raw(:,[1,3])*u(1));
output_image_raw(:,[2,4]) = round(output_image_raw(:,[2,4])*u(2));
% Offset entfernen:
output_image_raw(:,[1,3])=output_image_raw(:,[1,3])+offset(1)+1;
output_image_raw(:,[2,4])=output_image_raw(:,[2,4])+offset(2)+1;
% nun die eingelesenen Daten durchgehen, und das Bild erstellen:
for i=1:size(output_image_raw,1)
	data = output_image_raw(i,:);
	color = colors(data(5),:);
	output_image(1+image_size_pixel(2)-(data(2):data(4)),data(1):data(3),1)=color(1);
	output_image(1+image_size_pixel(2)-(data(2):data(4)),data(1):data(3),2)=color(2);
	output_image(1+image_size_pixel(2)-(data(2):data(4)),data(1):data(3),3)=color(3);
end

% Das Bild wird an die die aufrufende Funktion übergeben und kann z.B. mit IMWRITE
% als Datei abgespeichert werden...
end

% ---
% Hilfsfunktionen:
% ---
function color = get_color_from_str(tline)
% ermittelt aus einer Text-Zeile der Farbtabelle TLINE die Werte für das
% Farbtabellen-Array:
tline = strtrim(tline(1:end-1));
color = str2num(tline);  %#ok<ST2NM>
color= color(2:end);
end

function color_idx = get_rhombus_color(filled_line)
% ermittelt aus einer Zeile mit den Farbinformationen FILLED_LINE die Füllfarbe eines
% Viereckes:
filled_line = strtrim(filled_line);
color_idx=str2double(filled_line(find(filled_line==' ',1,'last')+1:end));
end

function coordinate = get_rhombus_coordinates(row)
% ermittel aus einer Text-Zeile der Viereckeigenschaften die beiden Koordinaten einer
% Ecke eines Vierecks:
row = strtrim(row);
coordinate = str2num(row); %#ok<ST2NM>
coordinate = coordinate(1:2);
end
