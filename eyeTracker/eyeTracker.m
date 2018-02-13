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

global basler basler_src basler_roi

% Initialize between experiments
basler_roi = [];

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

if isempty(basler_roi)
    h = warndlg('You must specify the ROI for the eye camera.....')
else
    try
        closepreview(basler)
    catch
        x=1;
    end
    
    % Open dialog to select where to save to...
    saveDir = uigetdir('F:\\francisco','Select folder in which to save eye Data....')
    
    % Configure Camera
    triggerconfig(basler, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
    basler.TriggerRepeat = inf;
    basler.FramesPerTrigger = 1;
    basler_src.TriggerMode = 'On';
    basler.ROIPosition = basler_roi;

    % Start acquisition
    start(basler)
    
    % Loaded message
    set(handles.text7, 'String', 'Waiting for stimulus trigger...')
    
    % Add in code for the encoder....
    try
        global W
        W = ChoiceWheel('COM7');
        
    catch
        disp('encoder already open...');
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
            set(handles.text7, 'String', 'Acquiring data....')
            % Counter to check if counting has stopped....
            if basler.FramesAcquired > nTot
                tSinceLast = 0 ;
                nTot = basler.FramesAcquired;
            else
                tSinceLast = tSinceLast+1;
            end

            axes(handles.axes2); imagesc(peekdata(basler, 1)); title('EYE')
            % In case of error
            try
                runData(cnt) = W.currentPosition; cnt = cnt+1;
            catch
                runData(cnt) = runData(cnt-1); cnt = cnt+1;
            end
            
            r = mod(cnt, 200);
            axes(handles.axes3); plot([runData(cnt - r + 1 : cnt-1)]);xlim([1,200]);ylim([1,1024]) ; 
            title('RUN DATA')
        end
    end

    disp('Stopped Acquiring')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Process and save the data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(handles.text7, 'String', 'Done Acquiring and Saving data...')
    
    % Stop and reset camera
    stop(basler)
    basler.TriggerRepeat = 0;
    basler_src.TriggerMode = 'Off';

    data = squeeze(getdata(basler, basler.FramesAcquired));
    % Truncate data by 4 pixels in each direction
    data = data(1:end-4, 1:end-4, :);
    
    % Maximize the range represented in uint16 
    data = single(data);
    data = data - min(data(:)); 
    data = data/max(data(:));
    data = uint16(65535*data);

    %     Remove this for the time being since it takes too long.....
    %
    %     [centroid, area, data_vid] = quickPupilMeasure(data);
    %     % Save everything
    %     eyeData.centroid = centroid;
    %     eyeData.area = area;
    %     eyeData.vid_check = data_vid;
    
    eyeData.vid_raw = data;

    % Truncate runData and compute the speed..
    runPosition = uint16(runData(1:cnt-1));
    
    x = diff(double(runPosition)); x(x>500) = 0; x(x<-500) = 0;
    runSpeed = x;
    
    figure; plot(runPosition); title('Position')
    figure; plot(runSpeed); title('Speed')

    runData = [];
    runData.position = runPosition;
    runData.T = linspace(1,size(data, 3), numel(runPosition) ); % Time in terms of frames for position
    runData.speed = runSpeed
    
    save(fullfile(saveDir, 'trialData.mat'), 'eyeData', 'saveDir', 'runData')
    
    set(handles.text7, 'String', sprintf('acquired... %d ... frames', size(data, 3) ))
end
    

    
    
% catch
%     % Graceful exit for camera....
%     disp('Some error happened...')
%     try
%         stop(basler)
%     catch
%         x=1;
%     end
%     basler.TriggerRepeat = 0;
%     basler_src.TriggerMode = 'Off';
%     
% end



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
