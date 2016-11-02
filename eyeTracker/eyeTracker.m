function varargout = eyeTracker(varargin)
% EYETRACKER MATLAB code for eyeTracker.fig
%      EYETRACKER, by itself, creates a new EYETRACKER or raises the existing
%      singleton*.
%
%      H = EYETRACKER returns the handle to a new EYETRACKER or the handle to
%      the existing singleton*.
%
%      EYETRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EYETRACKER.M with the given input arguments.
%
%      EYETRACKER('Property','Value',...) creates a new EYETRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eyeTracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eyeTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eyeTracker

% Last Modified by GUIDE v2.5 16-Feb-2017 17:29:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eyeTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @eyeTracker_OutputFcn, ...
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


% --- Executes just before eyeTracker is made visible.
function eyeTracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eyeTracker (see VARARGIN)

% Choose default command line output for eyeTracker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global basler basler_src

info = imaqhwinfo('gige');


basler = videoinput('gige', 1, 'Mono12');
basler_src = getselectedsource(basler);
basler_src.BinningHorizontal = 1;
basler_src.BinningVertical = 1;
basler_src.AcquisitionFrameRateAbs = 10;
basler_src.ExposureMode = 'Timed';
basler_src.ExposureTimeAbs = 50000;

% Note sometimes dropped packets from preview, so we will only preview the
% middle half of the screen...
sz = basler.VideoResolution;
basler.ROIPosition = [sz(1)/4 sz(2)/4 sz/2];

basler_src.TriggerMode = 'Off'

% --- Outputs from this function are returned to the command line.
function varargout = eyeTracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in preview.
function preview_Callback(hObject, eventdata, handles)
% hObject    handle to preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global basler basler_src

basler_h = preview(basler);    

% --- Executes on button press in ROIbutton.
function ROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global basler basler_roi

closepreview(basler);
basler.ROIPosition = [0 0 basler.VideoResolution];
%sz = basler.VideoResolution;
%basler.ROIPosition = [sz(1)/4 sz(2)/4 sz/2];

basler_roi = basler.ROIPosition;
start(basler);
pause(0.5);
stop(basler);
q = peekdata(basler,1);
figure('MenuBar','none','ToolBar','none','Name','Set ROI','NumberTitle','off');
imagesc(q); colormap(sqrt(gray(256))); axis off; truesize;
nPix = 192;
h = imrect(gca,[basler.VideoResolution/2-[nPix nPix]/2 nPix nPix]);

h.setFixedAspectRatioMode(true);
h.setResizable(false);
basler.ROIPosition = wait(h);
basler_roi = basler.ROIPosition;
close(gcf);
basler_h = preview(basler);
colormap(ancestor(basler_h,'axes'),sqrt(gray(256)));


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global basler

sz = basler.VideoResolution;
basler.ROIPosition = [sz(1)/4 sz(2)/4 sz/2];


% --- Executes on button press in AcquireButton.
function AcquireButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcquireButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global basler basler_src basler_roi

try
    closepreview(basler)
catch
    x=1;
end

triggerconfig(basler, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
basler.TriggerRepeat = inf;
basler.FramesPerTrigger = 1;
basler_src.TriggerMode = 'On';
basler.ROIPosition = basler_roi;

start(basler)

set(handles.text4,'Visible','Off')
set(handles.text3,'Visible','On')

% Make a preview window
hEye = figure('position', [1400,800,192,192]);axis('off')
hRun = figure('position', [200,800,400,192]);

% Add in code for the encoder....
global W
try
    W = ChoiceWheel('COM7')
catch
    disp('encoder already open...')
end

try 
    close 'Position Stream'
catch
    disp('no preview window to close..')
end

clear runData; 

global runData cnt


runData = zeros(1,500000, 'uint16'); 
cnt = 1;

% Bootleg way of figuring out time since last acquisition to determine when
% acquisition is over....
tSinceLast = 0;

while isrunning(basler) & tSinceLast < 10
    pause(0.05); % Acquire 100 run Position datapoints per second
    
    if mod(basler.FramesAcquired, 100) == 1
        disp(sprintf('Acquiring frame %d ....', basler.FramesAcquired))
    end
    if basler.FramesAcquired == 0;
        tSinceLast = 0; nTot = 0;
    else
        % Counter to check if counting has stopped....
        if basler.FramesAcquired > nTot
            tSinceLast = 0 
            nTot = basler.FramesAcquired;
        else
            tSinceLast = tSinceLast+1
        end
        
        figure(hEye); imagesc(peekdata(basler, 1));
        runData(cnt) = W.currentPosition; cnt = cnt+1;
        r = mod(cnt, 200);
        figure(hRun); plot([runData(cnt - r + 1 : cnt-1)]);xlim([1,200]);ylim([1,1024]) ; 
        title('RUN DATA')
    end
end

disp('Stopped Acquiring')
set(handles.text3, 'String', 'Done Acquiring and Waiting to Save..')



% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global basler basler_src data

set(handles.text3,'Visible','Off')

stop(basler)

basler_src.TriggerMode = 'Off';

if basler.FramesAcquired == 0
    set(handles.text4, 'String', 'No Frames Acquired....')
else
    data = squeeze(getdata(basler, basler.FramesAcquired));
    % Truncate data by 4 pixels in each direction
    data = data(1:end-4, 1:end-4, :);

    set(handles.text4, 'String', 'Analyzing and saving data.....')
    set(handles.text4,'Visible','On')

    folder_name = uigetdir('F:\\francisco','Select folder in which to save eye Data....')
    
    
%     Remove this for the time being since it takes too long.....
%
%     [centroid, area, data_vid] = quickPupilMeasure(data);
%     % Save everything
%     eyeData.centroid = centroid;
%     eyeData.area = area;
%     eyeData.vid_check = data_vid;
    
    eyeData.vid_raw = data;

    save(fullfile(folder_name, 'trialData.mat'), 'eyeData');

    set(handles.text4, 'String', 'Computing and Saving Running Data....')
    
    global runData cnt
    cnt
    runPosition = uint16(runData(1:cnt-1));
    
    
    x = diff(double(runPosition)); x(x>500) = 0; x(x<-500) = 0;
    runSpeed = x;
    size(runSpeed)
    size(runPosition)
    
    figure; plot(runPosition)
    figure; plot(runSpeed)

    
    runData = []
    runData.position = runPosition
    runData.T = linspace(1,size(data, 3), numel(runPosition) ) % Time in terms of frames for position
    runData.speed = runSpeed
    
    save(fullfile(folder_name, 'trialData.mat'), 'runData' , '-append')

    set(handles.text4, 'String', sprintf('acquired... %d ... frames', size(data, 3) ))
end

% Clean out frames


% --- Executes on button press in streamRunning.
function streamRunning_Callback(hObject, eventdata, handles)
% hObject    handle to streamRunning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global W
try
    W = ChoiceWheel('COM7')
catch
    disp('already open')
end

W.stream
