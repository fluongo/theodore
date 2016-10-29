function varargout = theodore(varargin)
% THEODORE MATLAB code for theodore.fig
%      THEODORE, by itself, creates a new THEODORE or raises the existing
%      singleton*.
%
%      H = THEODORE returns the handle to a new THEODORE or the handle to
%      the existing singleton*.
%
%      THEODORE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THEODORE.M with the given input arguments.
%
%      THEODORE('Property','Value',...) creates a new THEODORE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before theodore_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to theodore_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help theodore

% Last Modified by GUIDE v2.5 28-Oct-2016 15:13:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @theodore_OpeningFcn, ...
                   'gui_OutputFcn',  @theodore_OutputFcn, ...
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


% --- Executes just before theodore is made visible.
function theodore_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to theodore (see VARARGIN)

% Choose default command line output for theodore
handles.output = hObject;

% Setup some value of check boxes
handles.TTLcheck = 0;
handles.Sphericalcheck = 0;
handles.photodiodecheck = 0;
handles.send2Pdatacheck = 0;

imshow(imread('theodoreLogo.jpg') , 'Parent', handles.axes2)

set(handles.figure1,'CloseRequestFcn',[]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes theodore wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = theodore_OutputFcn(hObject, eventdata, handles) 
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
[handles.fn, pathname] = uigetfile('..\\stimulus_movies\'); 
fnText_Callback(hObject, eventdata, handles)
temp = load(fullfile(pathname, handles.fn));
handles.fnPath = fullfile(pathname, handles.fn);

guidata(hObject, handles);

global moviedata
moviedata = temp.moviedata;

imshow(squeeze(moviedata(:,:,90)) , 'Parent', handles.axes1)

set(handles.loadingText, 'String', 'LOADING....'); drawnow

% Also try to manually set the Number of frames and playback speed,
% otherwise ask for user entry
nFrames = size(moviedata, 3);
set(handles.NframesText, 'String', sprintf('%d', nFrames))
global playbackHz
try
	playbackHz = temp.stimParams.framerate;
	set(handles.playbackSpeedText, 'String', sprintf('%d', playbackHz))
catch
	temp = inputdlg('Please input the playback (Hz) for this stimulus','Define playback speed')
	playbackHz = str2num(temp{1});
	set(handles.playbackSpeedText, 'String', sprintf('%d', playbackHz))
end

set(handles.DurationText, 'String', sprintf('%.3g MIN', nFrames/playbackHz/60))

set(handles.loadingText, 'String', 'LOADED')




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

handles.Sphericalcheck = get(hObject,'Value')
guidata(hObject, handles);

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

% Startup PTB and prepare the textures...
global moviedata


% Check if you are sending TTLs
if handles.TTLcheck
	s = serial('COM3');
	fopen(s);
end

% Check if you are sending 2P data
if handles.send2Pdatacheck
	sbudp = udp('131.215.25.182', 'RemotePort', 7000);
	fopen(sbudp)
end

GUIhandle = gcf;

[window, windowRect] = TheodorePTBStartup2P(2, handles.Sphericalcheck);

all_textures = PTBprepTextures(moviedata, window);

t =  Screen('Flip', window); % Get flip time
filtMode = 0; % Nearest interpolation

global playbackHz

if handles.send2Pdatacheck
	pause(3); 
	fprintf(sbudp, 'G'); 
	fprintf(sbudp, ['M', handles.fnPath]);	
	fprintf(sbudp, sprintf('Mplayback of %d hz', playbackHz))
	if handles.Sphericalcheck
		fprintf(sbudp, ['M', 'spherical correction applied to stimulus'])
	end
	pause(7);
end

% Do two cases for whether you need to send a ttl or not

if ~handles.TTLcheck
	for i = 1 :size(moviedata, 3)
		Screen('DrawTexture', window, all_textures(i), [], windowRect, [], filtMode);
		t = Screen('Flip', window, t+1/playbackHz);
		if KbCheck
			break;
		end;
	end
else
	
	for i = 1 :size(moviedata, 3)
		fprintf(s,1)
		Screen('DrawTexture', window, all_textures(i), [], windowRect, [], filtMode);
		t = Screen('Flip', window, t+1/playbackHz);
		
		if mod(i,500) == 499
			flushinput(s)
		end
		
		if KbCheck
			break;
		end;
	end
	fclose(s)
end

if handles.send2Pdatacheck
	pause(7)
	fprintf(sbudp, 'S')
	fclose(sbudp)
end

% Clear the screen/close ports
Screen('CloseAll')

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

handles.TTLcheck = get(hObject,'Value')
guidata(hObject, handles);
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


% --- Executes on button press in exitBut.
function exitBut_Callback(hObject, eventdata, handles)
% hObject    handle to exitBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close all force



function playbackSpeedText_Callback(hObject, eventdata, handles)
% hObject    handle to playbackSpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playbackSpeedText as text
%        str2double(get(hObject,'String')) returns contents of playbackSpeedText as a double


% --- Executes during object creation, after setting all properties.
function playbackSpeedText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playbackSpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check2Psend.
function check2Psend_Callback(hObject, eventdata, handles)
% hObject    handle to check2Psend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.send2Pdatacheck = get(hObject,'Value')
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of check2Psend


% --- Executes on button press in mouseChase.
function mouseChase_Callback(hObject, eventdata, handles)
% hObject    handle to mouseChase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

playbackHz = 10
[window, windowRect] = TheodorePTBStartup2P(2, handles.Sphericalcheck);
tempMovieData =  0.5*ones(9,16,4000);

all_textures = PTBprepTextures(tempMovieData, window);

% Standard window
screenNumber = 2;
color = 0.5; rect = []; pixelsize = []; numBuffers = []; stereomode = 0;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, color, rect, pixelsize, numBuffers, stereomode);
theX = round(windowRect(RectRight) / 2); theY = round(windowRect(RectBottom) / 2);


t =  Screen('Flip', window); % Get flip time
filtMode = 0; % Nearest interpolation
% Stuff for setting mouse...
SetMouse(theX,theY,screenNumber); HideCursor;

% Create a single gaussian transparency mask and store it to a texture:
texsize = 50; mask=ones(texsize, texsize) * 1;

masktex1=Screen('MakeTexture', window, mask); masktex2=Screen('MakeTexture', window, mask-1);

for i = 1 :length(all_textures)
	% On each iteration simply draw it with a gaussian mask centere on a
	% new cursor position
	
	% myrect must be redfined using the mouse position at each frame
	[mx, my, buttons]=GetMouse(screenNumber);
	
	Screen('DrawTexture', window, all_textures(i), [], windowRect, [], filtMode);
	% Code below will animate it to flashing
	if mod(i,2) == 0
		Screen('DrawTexture', window, masktex1, [], [mx-texsize my-texsize mx+texsize my+texsize]);
	else
		Screen('DrawTexture', window, masktex2, [], [mx-texsize my-texsize mx+texsize my+texsize]);
	end
	
	t = Screen('Flip', window, t+1/playbackHz);
	if KbCheck
		break;
	end;
end

% Clear the screen/close ports
Screen('CloseAll');
