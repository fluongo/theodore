% Make a 30 second contrast modulated noise movie
clear all
duration = 1; % Minutes
tempFreq = 3;
spatialFreq = 0.3;
moviedata=generateNoise_xyt_noContrastMod(spatialFreq,tempFreq,0.5,duration);
%close all
new = moviedata;
new(find(moviedata<=128)) = 255;
new(find(moviedata>128)) = 1;

npix = 1800;

new_scaled = zeros(npix, npix, size(new, 3), 'uint8');
for i = 1:size(new,3);
    new_scaled(:,:,i) = imresize(new(:,:,i), [npix, npix]);
end

% The scale used previously is 300 pixels for every 1280 pixels
% So max that needs to be used is 1200 x 300
% Needs to be isomatric for speeds to be hte same
%%

stim_duration = 50;
grey_duration = 10;
framerate = 30;
slice = 30; % Size in pixels of the slice to send accross
nFrames = (stim_duration + grey_duration) * framerate;

%implay(new_scaled)

%% HORIZONTAL

nScreens = 3;
nframes_travel_x = nScreens*300;
nframes_travel_y = 300;
% Horizontal frames
framesH = 128*ones(nframes_travel_y, nframes_travel_x, stim_duration*framerate);
nframes_stim = stim_duration*framerate;
for i = 1:nframes_stim
    % Compute where the slice will end...
    d = ceil(nframes_travel_x*i/nframes_stim);
    if d<= slice % Condition for the start
        framesH(1:nframes_travel_y, 1:d, i) = new_scaled(1:nframes_travel_y,175:175+d-1, 200+i);
    elseif d >= nframes_travel_x; % End condition
        extra = d - nframes_travel_x;
        dX = slice-extra;
        framesH(1:nframes_travel_y, end + extra :end, i) = new_scaled(1:nframes_travel_y,175:175 + abs(extra), 200+i);
    else
        framesH(1:300, d-slice+1 : d, i) = new_scaled(1:nframes_travel_y, 176 : 175 + slice, i);
    end
end
framesH = uint8(framesH);

% Now add gray periods...
full_horizontal  = 128*ones(size(framesH, 1), size(framesH, 2), nFrames, 'uint8');
grey_frames = round(grey_duration/2*framerate); % Number of frames in gray
full_horizontal(:,:,grey_frames + 1:end-grey_frames ) = framesH;
implay(full_horizontal,30)

%% VERTICAL

% Horizontal frames
framesV = 128*ones(nframes_travel_y, nframes_travel_x, stim_duration*framerate);
nframes_stim = stim_duration*framerate;
for i = 1:nframes_stim
    
    % Compute where the slice will end...
    d = ceil(nframes_travel_y*i/nframes_stim);
    if d<= slice % Condition for the start
        
        framesV(1:d,1:nframes_travel_x, i) = new_scaled(1:1+d-1, 1:nframes_travel_x, 200+i);
    elseif d >= nframes_travel_y; % End condition
        %         d
        %         extra = d - (nframes_travel_y-slice)
         dX = abs(d - nframes_travel_y)
         framesV(d - (slice-extra) + 1: end , 1:nframes_travel_x,  i) = new_scaled(1: slice-dX, 1:nframes_travel_x,200+i);
    else
        framesV(d-slice+1 : d, 1:nframes_travel_x, i) = new_scaled(1 : slice, 1:nframes_travel_x, i);
    end
end

framesV = uint8(framesV);

implay(framesV)
%%
% Now add gray periods...
full_vertical  = 128*ones(size(framesH, 1), size(framesH, 2), nFrames, 'uint8');
grey_frames = round(grey_duration/2*framerate); % Number of frames in gray
full_vertical(:,:,grey_frames + 1:end-grey_frames ) = framesV;
implay(full_vertical,30)

allVertical = full_vertical;
allHorizontal = full_horizontal;


