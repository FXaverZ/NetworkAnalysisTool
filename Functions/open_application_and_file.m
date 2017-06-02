function SINCAL = open_application_and_file (SINCAL)
%OPEN_APPLICATION_AND_FILE startet SINCAL-Benutzeroberfläche öffnet Dokument

% Erstellt von:            Franz Zeilinger - 11.07.2012
% Letzte Änderung durch:   Franz Zeilinger - 16.10.2012

SINCAL.Application = actxserver('SIASincal.Application');
if isempty(SINCAL.Application)
	exception = MException('SINCAL:OpenApplication:Failed',...
		'The opening of the SINCAL Application failed!');
	throw(exception);
end
% Das Netz in der SINCAL-Oberfläche öffnen:
SINCAL.Document = SINCAL.Application.OpenDocument(SINCAL.Database.SINfilename);
if isempty(SINCAL.Document)
	exception = MException('SINCAL:OpenDocument:Failed',...
		'The opening of the specified SINCAL document failed!');
	throw(exception);
end
end