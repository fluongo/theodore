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
%      applied to the GUI before theodore_OgpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to theodore_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help theodore

% Last Modified by GUIDE v2.5 09-Mar-2018 12:15:54

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

% Identify compute and if it is not the 2P computer, then open widefield
% serial


sid = get(com.sun.security.auth.module.NTSystem,'DomainSID');
if ~strcmp(sid, 'S-1-5-21-234047508-22126698-30228153')
    global sWF
    sWF = serial('COM3');
    fopen(sWF)
end
   

% Choose default command line output for theodore
handles.output = hObject;



% Setup some value of check boxes
handles.TTLcheck = 0;
handles.Sphericalcheck = 0;
handles.photodiodecheck = 0;
handles.send2Pdatacheck = 0;

imshow(imread('theodoreLogo.jpg') , 'Parent', handles.axes2)

set(handles.axes1, 'xtick', [], 'ytick', [])

set(handles.figure1,'CloseRequestFcn',[]);

% Launch the recipe GUI for 2P
recipe_2p_GUI

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
handles.fnPath = fullfile(pathname, handles.fn)

guidata(hObject, handles);

global moviedata
try
	moviedata = temp.moviedata;
catch
	moviedata = temp.stim; % Lu names it differently/....
end
imshow(squeeze(moviedata(:,:,1)) , 'Parent', handles.axes1)

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


% --- Executes on button press in spherical.
function spherical_Callback(hObject, eventdata, handles)
% hObject    handle to spherical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Sphericalcheck = get(hObject,'Value')
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of spherical



% --- Executes on button press in goBut.
function goBut_Callback(hObject, eventdata, handles)
% hObject    handle to goBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Startup PTB and prepare the textures...
global moviedata sWF


% Check if you are sending TTLs
if handles.TTLcheck
	if ~isempty(sWF)
		if strcmp(sWF.Status, 'open')
			fclose(sWF)
		end
	end
    s = serial('COM3');
    fopen(s);
end

GUIhandle = gcf;

[window, windowRect] = TheodorePTBStartup2P(2, handles.Sphericalcheck);


if isa(moviedata, 'single')
	moviedata = double(moviedata);
end
all_textures = PTBprepTextures(moviedata, window);

t =  Screen('Flip', window); % Get flip time
filtMode = 0; % Nearest interpolation

nRepeats = str2num(get(handles.editRepeats, 'String'));


global playbackHz
tic
if handles.TTLcheck
	disp('SENDING 2P DATA....')
	sbudp = udp('131.215.25.168', 'RemotePort', 7000);
	fopen(sbudp)
	pause(5); 
	fprintf(sbudp, 'G'); 
	pause(20)
	try
		fprintf(sbudp, ['M', handles.fnPath]);	
	catch
		global fnPath; fprintf(sbudp, ['M', fnPath]);	
	end
	
	fprintf(sbudp, sprintf('Mplayback of %d hz', playbackHz))
	if handles.Sphericalcheck
		fprintf(sbudp, ['M', 'spherical correction applied to stimulus'])
	end
end

% Do two cases for whether you need to send a ttl or not

if ~handles.TTLcheck
	
	for ll = 1:nRepeats
		for i = 1 :size(moviedata, 3)
			Screen('DrawTexture', window, all_textures(i), [], windowRect, [], filtMode);
			t = Screen('Flip', window, t+1/playbackHz);
			if KbCheck
				break;
			end;
		end
	end
	
else
	for ll = 1:nRepeats
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
	end
	fclose(s)
end

if handles.TTLcheck
	pause(2)
	fprintf(sbudp, 'S')
	pause(10)
	fclose(sbudp)
end

% Clear the screen/close ports
Screen('CloseAll')
playbackHz
disp(sprintf('elapsed time was %4.4f seconds and should have been %4.4f', toc, size(moviedata, 3)/playbackHz))


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

%Check if any arduinos are left open and close them
global s sWF

if isfield(sWF, 'status')
	if strcmp(sWF.Status, 'open')
		fclose(sWF)
	end
end

if isfield(s, 'status')
	if strcmp(s.Status, 'open')
		fclose(s)
	end
end

delete(instrfindall)

close all force



function playbackSpeedText_Callback(hObject, eventdata, handles)
% hObject    handle to playbackSpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global playbackHz

playbackHz = str2double(get(hObject,'String'));

disp(sprintf('Set new playback speed to %d', playbackHz))
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
texsize = 150; mask=ones(texsize, texsize) * 1;

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

set(handles.loadingText, 'String', ' ')

% Clear the screen/close ports
Screen('CloseAll');



function textNtrials_Callback(hObject, eventdata, handles)
% hObject    handle to textNtrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textNtrials as text
%        str2double(get(hObject,'String')) returns contents of textNtrials as a double


% --- Executes during object creation, after setting all properties.
function textNtrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textNtrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushRunRetin.
function pushRunRetin_Callback(hObject, eventdata, handles)
% hObject    handle to pushRunRetin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sWF
flushinput(sWF)
load('C:\Users\KOFIKO3\Desktop\New folder\retinotopicNiell.mat')
%load('C:\Users\KOFIKO3\Desktop\New folder\Retinotopy_CM_noise_10sec_NoBlank.mat')


playbackHz = 30;
nRepeats = str2num(get(handles.textNtrials, 'String')); % Number of times to repeat stimulus


sca; PsychDefaultSetup(2); Screen('Preference', 'SkipSyncTests', 0); screens = Screen('Screens');
screenNumber = 1%max(screens);

% Enter DEFCON HIGH PRIORITY and define colors
priorityLevel=MaxPriority(screenNumber); Priority(priorityLevel);
white = 255; black = 1;
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
Screen('Preference', 'SkipSyncTests', 1)
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5);

PsychImaging('PrepareConfiguration');
% configFile = 'C:\Users\KOFIKO3\AppData\Roaming\Psychtoolbox\GeometryCalibration\CSVCalibdata_1.mat'

if get(handles.screenPosition, 'Value') == 1; % Left value
    configFile = 'Z:\\_PTB_startups\\NewUndistortionWF_config_1Mon.mat'
elseif get(handles.screenPosition, 'Value') == 2; % Center value
    configFile = 'Z:\\_PTB_startups\\NewUndistortionWF_config_1Mon_Center.mat'
end

PsychImaging('AddTask', 'Allviews', 'GeometryCorrection', configFile);

% Standard window
color = 0.5; rect = []; pixelsize = []; numBuffers = []; stereomode = 0;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, color, rect, pixelsize, numBuffers, stereomode);

all_texturesH = zeros(1, size(allVertical,3)); all_texturesV = zeros(1, size(allVertical,3));

for i = 1 : size(allVertical, 3) 
    if mod(i,100) == 0
        disp(sprintf('loaded frame %d', i));
    end
    all_texturesV(i) = Screen('MakeTexture', window, double(allVertical(:,:,i)));
    all_texturesH(i) = Screen('MakeTexture', window, double(allHorizontal(:,:,i)));
end

filtMode = 0; % Nearest interpolation

nTex = length(all_texturesH); % Number of text

tic
for j = 1:nRepeats
    flushinput(sWF)
    disp(sprintf('Horizontal Run %d out of %d', j, nRepeats))
    %update to a current flip time
    t =  Screen('Flip', window); % Get flip time
    for i = 1 :nTex
        Screen('DrawTexture', window, all_texturesH(i), [], windowRect, [], filtMode);
        
        % send a ttl every 3rd frames
        if mod(i,3) == 1
            fprintf(sWF,1)
        end
        
        t = Screen('Flip', window, t + 1/playbackHz);

    end
end

% Now do elevation

for j = 1:nRepeats
    flushinput(sWF)
    %update to a current flip time
    disp(sprintf('Vertical Run %d out of %d', j, nRepeats))
    t =  Screen('Flip', window); % Get flip time
    for i = 1 :nTex
        Screen('DrawTexture', window, all_texturesV(i), [], windowRect, [], filtMode);
        
        % send a ttl every 3rd frames
        if mod(i,3) == 1
            fprintf(sWF,1)
        end
        
        t = Screen('Flip', window, t + 1/playbackHz);
    end
end
disp(sprintf('Elapsed time from all trials was .... %d and should have been %d', toc, nRepeats*10*2))
% Clear the screen/close ports
sca



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WFotherGo.
function WFotherGo_Callback(hObject, eventdata, handles)
% hObject    handle to WFotherGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Startup PTB and prepare the textures...
global moviedata sWF

flushinput(sWF)

sca; PsychDefaultSetup(2); Screen('Preference', 'SkipSyncTests', 1); screens = Screen('Screens');
Screen('Preference', 'VisualDebugLevel', 1)
screenNumber = 1 %max(screens);

% Enter DEFCON HIGH PRIORITY and define colors
priorityLevel=MaxPriority(screenNumber); Priority(priorityLevel);
white = 255; black = 1;
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5);
if handles.Sphericalcheck == 1
    PsychImaging('PrepareConfiguration');
    % configFile = 'C:\Users\KOFIKO3\AppData\Roaming\Psychtoolbox\GeometryCalibration\CSVCalibdata_1.mat'
    if get(handles.screenPosition, 'Value') == 1; % Left value
        configFile = 'Z:\\_PTB_startups\\NewUndistortionWF_config_1Mon.mat'
    elseif get(handles.screenPosition, 'Value') == 2; % Center value
        configFile = 'Z:\\_PTB_startups\\NewUndistortionWF_config_1Mon_Center.mat'
    else
        return
    end
    PsychImaging('AddTask', 'Allviews', 'GeometryCorrection', configFile);
else
    disp('no spherical correction')
end
% Standard window
color = 0.5; rect = []; pixelsize = []; numBuffers = []; stereomode = 0;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, color, rect, pixelsize, numBuffers, stereomode);

all_textures = zeros(1, size(moviedata,3)); 

for i = 1 : size(moviedata, 3) 
    if mod(i,100) == 0
        disp(sprintf('loaded frame %d', i));
    end
    all_textures(i) = Screen('MakeTexture', window, moviedata(:,:,i));
end

filtMode = 0; % Nearest interpolation
TTLeveryN = str2num(get(handles.edit16, 'String'))
playbackHz = str2num(get(handles.playbackSpeedText, 'String'))
nRepeats = str2num(get(handles.widefieldRepeats, 'String'))

t =  Screen('Flip', window); % Get flip time
for kk = 1:nRepeats
    flushinput(sWF)
    for i = 1 :length(all_textures)
        if mod(i,400) == 1
            disp(sprintf('Displaying frame %d out of %d', (kk-1)*size(moviedata, 3)+i, size(moviedata, 3)*nRepeats));
            flushinput(sWF)
        end
        Screen('DrawTexture', window, all_textures(i), [], windowRect, [], filtMode);

        % send a ttl every 3rd frames
        if TTLeveryN == 1
           fprintf(sWF,1)
        else
            if mod(i,TTLeveryN) == 1
                fprintf(sWF,1)
            end
        end
        
        if KbCheck
			break;
		end;
        
        t = Screen('Flip', window, t + 1/playbackHz);

    end
end

% Clear the screen/close ports
sca



function widefieldRepeats_Callback(hObject, eventdata, handles)
% hObject    handle to widefieldRepeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widefieldRepeats as text
%        str2double(get(hObject,'String')) returns contents of widefieldRepeats as a double


% --- Executes during object creation, after setting all properties.
function widefieldRepeats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widefieldRepeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunRetinotopy_2P.
function RunRetinotopy_2P_Callback(hObject, eventdata, handles)
% hObject    handle to RunRetinotopy_2P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nRepeats = str2num(get(handles.RetinotopyNrepeats2P, 'String'));

% Check if you are sending TTLs
if handles.TTLcheck
    s = serial('COM3');
    fopen(s);
end

GUIhandle = gcf;

% Load in the data for retinotopy
%load('X:\stimulus_movies\widefield\retinotopicNiell.mat')
load('X:\stimulus_movies\widefield\retinotopicNiell_10sec_NoBlank.mat')

spherical = 1; % Always make spherical
[window, windowRect] = TheodorePTBStartup2P(2, spherical);

all_texturesH = PTBprepTextures(allHorizontal, window);
all_texturesV = PTBprepTextures(allVertical, window);

t =  Screen('Flip', window); % Get flip time
filtMode = 0; % Nearest interpolation

playbackHz = 30;

if handles.TTLcheck
	disp('SENDING 2P DATA....')
	sbudp = udp('131.215.25.182', 'RemotePort', 7000);
	fopen(sbudp)
	pause(5); 
	fprintf(sbudp, 'G'); 
	pause(20)	
	fprintf(sbudp, sprintf('MRetinotopy at %d Hz', playbackHz))
	fprintf(sbudp, sprintf('MRepeats %d', nRepeats))

	if handles.Sphericalcheck
		fprintf(sbudp, ['M', 'spherical correction applied to stimulus'])
	end
end


tic

% Do two cases for whether you need to send a ttl or not
for nn = 1:nRepeats % Horizontal
	if handles.TTLcheck
		flushinput(s)
	end
	disp(sprintf('Running horizontal trial %d out of %d', nn, nRepeats))
	for i = 1 : length(all_texturesH)
		if handles.TTLcheck
			fprintf(s,1)
		end
		Screen('DrawTexture', window, all_texturesH(i), [], windowRect, [], filtMode);
		t = Screen('Flip', window, t+1/playbackHz);
	end
end

for nn = 1:nRepeats % Vertical
	if handles.TTLcheck
		flushinput(s)
	end
	disp(sprintf('Running vertical trial %d out of %d', nn, nRepeats))
	for i = 1 : length(all_texturesH)
		if handles.TTLcheck
			fprintf(s,1)
		end
		Screen('DrawTexture', window, all_texturesV(i), [], windowRect, [], filtMode);
		t = Screen('Flip', window, t+1/playbackHz);
	end
end
disp(sprintf('Elapsed time %d and should have been %d', toc, nRepeats*2*10))

% Clsoe arduino...
if handles.TTLcheck
	fclose(s)
end

if handles.TTLcheck
	pause(5)
	fprintf(sbudp, 'S')
	pause(10)
	fclose(sbudp)
end

% Clear the screen/close ports
Screen('CloseAll')



function RetinotopyNrepeats2P_Callback(hObject, eventdata, handles)
% hObject    handle to RetinotopyNrepeats2P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of RetinotopyNrepeats2P as text
%        str2double(get(hObject,'String')) returns contents of RetinotopyNrepeats2P as a double


% --- Executes during object creation, after setting all properties.
function RetinotopyNrepeats2P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RetinotopyNrepeats2P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in screenPosition.
function screenPosition_Callback(hObject, eventdata, handles)
% hObject    handle to screenPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Hints: contents = cellstr(get(hObject,'String')) returns screenPosition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from screenPosition


% --- Executes during object creation, after setting all properties.
function screenPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screenPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in but_runrecipe.
function but_runrecipe_Callback(hObject, eventdata, handles)
% hObject    handle to but_runrecipe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global recipe_data

nExperiment = size(recipe_data, 1);


i = 1;
while i <= nExperiment
    fn = recipe_data{i,1};
    fr_rate = recipe_data{i,2};
    loadOutside(fn, fr_rate, hObject, eventdata, handles)
    goBut_Callback(hObject, eventdata, handles)

    tic
    fprintf('!!!!!! PRESS ANY KEY TO PAUSE EXPERIMENT ... !!!!!!!!')
    ct = 0;
    while toc<10 % seconds
        if floor(toc)~=ct % This make a counter...
            ct = floor(toc); fprintf(num2str(10-floor(toc)))
        end
        if KbCheck
            quest = 'Experiment is currently paused, would you like to rerun, contiue, or exit?';
            title = 'Theodore Paused'; defbtn = 'continue';
            answer = questdlg(quest,title,'rerun','continue','exit',defbtn);
            switch answer
                case 'rerun'
                    continue;
                case 'continue'
                    i = i+1; continue;
                case 'exit'
                    i = nExperiment+10; continue;%Exit condition
            end
        
        end
    end
    
    1 = i+1; % iterate counter
end

disp('DONE with all stimuli....')





function loadOutside(fn, framerate, hObject, eventdata, handles)
% Used for quickly loading in files same as the load button but as a
% function

[pathname,name,ext] = fileparts(fn) 
handles.fn = [name, ext]
handles.fnPath = fullfile(pathname, handles.fn)
global fnPath
fnPath = handles.fnPath
guidata(hObject, handles);


fnText_Callback(hObject, eventdata, handles)
temp = load(fullfile(pathname, handles.fn));



global moviedata
try
	moviedata = temp.moviedata;
catch
	moviedata = temp.stim; % Lu names it differently/....
end
imshow(squeeze(moviedata(:,:,1)) , 'Parent', handles.axes1)

set(handles.loadingText, 'String', 'LOADING....'); drawnow

% Also try to manually set the Number of frames and playback speed,
% otherwise ask for user entry
nFrames = size(moviedata, 3);
set(handles.NframesText, 'String', sprintf('%d', nFrames))
global playbackHz

playbackHz = framerate;
set(handles.playbackSpeedText, 'String', sprintf('%d', playbackHz))

set(handles.DurationText, 'String', sprintf('%.3g MIN', nFrames/playbackHz/60))

set(handles.loadingText, 'String', 'LOADED')



function editRepeats_Callback(hObject, eventdata, handles)
% hObject    handle to editRepeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRepeats as text
%        str2double(get(hObject,'String')) returns contents of editRepeats as a double


% --- Executes during object creation, after setting all properties.
function editRepeats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRepeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox6.
function listbox6_Callback(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox6


% --- Executes during object creation, after setting all properties.
function listbox6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addstimrecipe_button.
function addstimrecipe_button_Callback(hObject, eventdata, handles)
% hObject    handle to addstimrecipe_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in resetrecipe_button.
function resetrecipe_button_Callback(hObject, eventdata, handles)
% hObject    handle to resetrecipe_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in playrecipe_button.
function playrecipe_button_Callback(hObject, eventdata, handles)
% hObject    handle to playrecipe_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
