function varargout = akhbar(varargin)
% AKHBAR MATLAB code for akhbar.fig
%      AKHBAR, by itself, creates a new AKHBAR or raises the existing
%      singleton*.
%
%      H = AKHBAR returns the handle to a new AKHBAR or the handle to
%      the existing singleton*.
%
%      AKHBAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AKHBAR.M with the given input arguments.
%
%      AKHBAR('Property','Value',...) creates a new AKHBAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before akhbar_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to akhbar_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help akhbar

% Last Modified by GUIDE v2.5 27-Oct-2016 19:09:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @akhbar_OpeningFcn, ...
                   'gui_OutputFcn',  @akhbar_OutputFcn, ...
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


% --- Executes just before akhbar is made visible.
function akhbar_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to akhbar (see VARARGIN)

% Choose default command line output for akhbar
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes akhbar wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = akhbar_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in fileload.
function fileload_Callback(hObject, eventdata, handles)
% hObject    handle to fileload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.fn, pathname] = uigetfile('Z:\\stimulus_movies\'); 
fnText_Callback(hObject, eventdata, handles)
temp = load(fullfile(pathname, handles.fn), 'moviedata')
handles.moviedata = temp.moviedata;
imshow(squeeze(handles.moviedata(:,:,100)) , 'Parent', handles.axes1)



function fnText_Callback(hObject, eventdata, handles)
% hObject    handle to fnText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.fnText, 'String', handles.fn)

% Hints: get(hObject,'String') returns contents of fnText as text
%        str2double(get(hObject,'String')) returns contents of fnText as a double


% --- Executes during object creation, after setting all properties.
function fnText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fnText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in rigType.
function rigType_Callback(hObject, eventdata, handles)
% hObject    handle to rigType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rigType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rigType


% --- Executes during object creation, after setting all properties.
function rigType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rigType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spherical.
function spherical_Callback(hObject, eventdata, handles)
% hObject    handle to spherical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spherical


% --- Executes on button press in photodiodebox.
function photodiodebox_Callback(hObject, eventdata, handles)
% hObject    handle to photodiodebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of photodiodebox


% --- Executes on button press in goBut.
function goBut_Callback(hObject, eventdata, handles)
% hObject    handle to goBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stopBut.
function stopBut_Callback(hObject, eventdata, handles)
% hObject    handle to stopBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in sendttl.
function sendttl_Callback(hObject, eventdata, handles)
% hObject    handle to sendttl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sendttl



function NframesText_Callback(hObject, eventdata, handles)
% hObject    handle to NframesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NframesText as text
%        str2double(get(hObject,'String')) returns contents of NframesText as a double


% --- Executes during object creation, after setting all properties.
function NframesText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NframesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameRateText_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameRateText as text
%        str2double(get(hObject,'String')) returns contents of FrameRateText as a double


% --- Executes during object creation, after setting all properties.
function FrameRateText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameRateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DurationText_Callback(hObject, eventdata, handles)
% hObject    handle to DurationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DurationText as text
%        str2double(get(hObject,'String')) returns contents of DurationText as a double


% --- Executes during object creation, after setting all properties.
function DurationText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DurationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
