

function varargout = proj_gui(varargin)
% PROJ_GUI MATLAB code for proj_gui.fig
%      PROJ_GUI, by itself, creates a new PROJ_GUI or raises the existing
%      singleton*.
%
%      H = PROJ_GUI returns the handle to a new PROJ_GUI or the handle to
%      the existing singleton*.
%
%      PROJ_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJ_GUI.M with the given input arguments.
%
%      PROJ_GUI('Property','Value',...) creates a new PROJ_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before proj_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to proj_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help proj_gui

% Last Modified by GUIDE v2.5 21-Jul-2021 11:38:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @proj_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @proj_gui_OutputFcn, ...
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


% --- Executes just before proj_gui is made visible.
function proj_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to proj_gui (see VARARGIN)

% Choose default command line output for proj_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes proj_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = proj_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function net_input_Callback(hObject, eventdata, handles)
% hObject    handle to net_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of net_input as text
%        str2double(get(hObject,'String')) returns contents of net_input as a double
x=get(hObject,"String");
Circuit_image=0;
if x(1,1)=="c"
    
    Circuit_Image=x(1,:);
    
    x=x(2:end,:);
end

[node_voltage_arra,current_branch_arra,power_arra]=project_main(x);
set(handles.node_voltage,"String",node_voltage_arra);
set(handles.current_branch,"String",current_branch_arra);
set(handles.power_arr,"String",power_arra);

I=imread(Circuit_Image);
imshow(Circuit_Image);




% --- Executes during object creation, after setting all properties.
function net_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to net_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function node_voltage_Callback(hObject, eventdata, handles)
% hObject    handle to node_voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of node_voltage as text
%        str2double(get(hObject,'String')) returns contents of node_voltage as a double


% --- Executes during object creation, after setting all properties.
function node_voltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to node_voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function current_branch_Callback(hObject, eventdata, handles)
% hObject    handle to current_branch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_branch as text
%        str2double(get(hObject,'String')) returns contents of current_branch as a double


% --- Executes during object creation, after setting all properties.
function current_branch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_branch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function power_arr_Callback(hObject, eventdata, handles)
% hObject    handle to power_arr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of power_arr as text
%        str2double(get(hObject,'String')) returns contents of power_arr as a double


% --- Executes during object creation, after setting all properties.
function power_arr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power_arr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
