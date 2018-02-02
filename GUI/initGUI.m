function varargout = initGUI(varargin)
% INITGUI MATLAB code for initGUI.fig
%      INITGUI, by itself, creates a new INITGUI or raises the existing
%      singleton*.
%
%      H = INITGUI returns the handle to a new INITGUI or the handle to
%      the existing singleton*.
%
%      INITGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INITGUI.M with the given input arguments.
%
%      INITGUI('Property','Value',...) creates a new INITGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before initGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to initGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help initGUI

% Last Modified by GUIDE v2.5 01-Feb-2018 15:38:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @initGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @initGUI_OutputFcn, ...
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


% --- Executes just before initGUI is made visible.
function initGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to initGUI (see VARARGIN)
global dataType Quit
dataType = {'', '', ''};
Quit = 0;

% Choose default command line output for initGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes initGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = initGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global preProcess train track type Quit
varargout{1} = preProcess;
varargout{2} = train;
varargout{3} = track;
varargout{4} = type;
varargout{5} = Quit;
close


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global preProcess
preProcess = get(hObject,'Value');


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
global train
train = get(hObject,'Value');


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global track
track = get(hObject,'Value');


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
global dataType
if get(hObject,'Value') == 1
    dataType{1,1} = 'Amplitude';
else
    dataType{1,1} = '';
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
global dataType
if get(hObject,'Value') == 1
    dataType{1,2} = 'Phase';
else
    dataType{1,2} = '';
end


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
global dataType
if get(hObject,'Value') == 1
    dataType{1,3} = 'ampXphase';
else
    dataType{1,3} = '';
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global type dataType
ii = 1;
for i = 1 :length(dataType)
    if ~isempty(dataType{1,i})
        type{1,ii} = dataType{1,i};
        ii = ii+1;
    end
end

initGUI_OutputFcn(hObject, eventdata, handles);
close


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the current position of the GUI from the handles structure
% to pass to the modal dialog.
% Call modaldlg with the argument 'Position'.
global Quit
user_response = questdlg('Are you sure you want to cancel?', ...
	'Quit MLOT', ...
	'Yes','No', 'No');
switch user_response
case {'No'}
    % take no action
    Quit = 0;
case 'Yes'
    % Prepare to close GUI application window
    Quit = 1;
    close
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
