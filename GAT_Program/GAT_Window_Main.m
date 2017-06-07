function varargout = GAT_Window_Main(varargin)
% GAT_WINDOW_MAIN MATLAB code for GAT_Window_Main.fig
%      GAT_WINDOW_MAIN, by itself, creates a new GAT_WINDOW_MAIN or raises the existing
%      singleton*.
%
%      H = GAT_WINDOW_MAIN returns the handle to a new GAT_WINDOW_MAIN or the handle to
%      the existing singleton*.
%
%      GAT_WINDOW_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAT_WINDOW_MAIN.M with the given input arguments.
%
%      GAT_WINDOW_MAIN('Property','Value',...) creates a new GAT_WINDOW_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GAT_Window_Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GAT_Window_Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GAT_Window_Main

% Last Modified by GUIDE v2.5 02-Oct-2015 10:20:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GAT_Window_Main_OpeningFcn, ...
                   'gui_OutputFcn',  @GAT_Window_Main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GAT_Window_Main is made visible.
function GAT_Window_Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GAT_Window_Main (see VARARGIN)

%------------------------------------------------------------------------------------
%---- Add program file structure to MATLAB search path ------------------------------
% Wo ist "GAT_Window_Main.m" zu finden?
[~, Source_File] = fileattrib('GAT_Window_Main.m');
% Ordner, in dem "GAT_Window_Main.m" sich befindet, enthält Programm:
if ischar(Source_File)
	fprintf([Source_File,' - Current Directory auf Datei setzen, in der sich ',...
		'''GAT_Window_Main.m'' befindet!\n']);
	% Fenster schließen:
	delete(handles.GAT_main_gui);
	return;
end
Path = fileparts(Source_File.Name);

% Subfolder in Search-Path aufnehmen (damit alle Funktionen gefunden werden
% können)
addpath(genpath(Path));
handles.Current_Settings.Files.Main_Path = Path;
%------------------------------------------------------------------------------------
%---- Set up GUI --------------------------------------------------------------------
handles.text_message_main_handler = ...
	MESSAGE_text_handler(handles.text_message_main ,...
	'OutputFile',[pwd,filesep,'Log.txt']);


%------------------------------------------------------------------------------------
% Choose default command line output for GAT_Window_Main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GAT_Window_Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GAT_Window_Main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_line_add.
function push_line_add_Callback(hObject, eventdata, handles)
% hObject    handle to push_line_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

linecount = handles.text_message_main_handler.Line_Count_Overall;
% str = ['Teststring as it is... Line No. ',num2str(linecount + 1)];

str = ['Blanks : ',num2str(linecount+1)];
if linecount+1 > numel(str)
	str2 = blanks(linecount-numel(str));
	str2 = [str2,'|'];
	str = [str, str2];
else
	str(linecount+1)='|';
end

handles.text_message_main_handler.add_line(str);


% --- Executes on button press in push_line_remove.
function push_line_remove_Callback(hObject, eventdata, handles)
% hObject    handle to push_line_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.text_message_main_handler.rem_line();


% --- Executes on button press in push_line_clear.
function push_line_clear_Callback(hObject, eventdata, handles)
% hObject    handle to push_line_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.text_message_main_handler.reset_text();


% --- Executes on button press in push_line_level_down.
function push_line_level_down_Callback(hObject, eventdata, handles)
% hObject    handle to push_line_level_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.text_message_main_handler.level_up();

% --- Executes on button press in push_line_level_up.
function push_line_level_up_Callback(hObject, eventdata, handles)
% hObject    handle to push_line_level_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.text_message_main_handler.level_down();


% --- Executes on button press in push_text_save.
function push_text_save_Callback(hObject, eventdata, handles)
% hObject    handle to push_text_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.text_message_main_handler.save_message_text();
