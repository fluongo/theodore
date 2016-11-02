% border_ownership_stimulus
% By lu 2016.4.14
% adding the stim_info to each stimulus type  2016.4.20
% modified 4.12 add moving texture background

function stim_example = border_ownership5_FL( params )
% Version of Lu's stimulus generation software that will also output a
% stimulus structure that has all of the useful information in stimParams,
% for use with the Alvin, stimulus generation GUI

% NOTE: There was a bug in the previous version, whereby two things were
% not happening.... 
% 1. the background figure was not moving with the
% 2. the background was not moving on these conditions

% parameters
frame_rate = params.framerate;
stim_duration = params.ontime;
blank_duration = params.offtime;
resx = params.resx;
resy = params.resy;
size_x = params.sizex;
size_y = params.sizey;
orientation = params.ori;  
x = params.posx;
y = params.posy;
repeat = params.repeat;
contrast = params.contrast;
stimtype = params.stimtype;

% load texture
imtx = imread('texture2_low2.tif');
imtx=single(imtx);
imtx=imtx(:,:,1);
imtx=imtx/max(imtx(:))*contrast;

mov_range = round(resx * 0.01);
mov_bg = imresize(imtx, [resy, resx + mov_range*2]) ;
mov_fg = flip(mov_bg,1); 

imtx_bg = mov_bg(:,mov_range+1:end-mov_range);
imtx_fg= flip(imtx_bg,1); 



% imtx_fg = imresize(imtx_fg, [resy, resx]);

%

stim_info = struct('stim_type',[], 'background',[], 'is_background_moving',[], ...
    'object',[], 'object_size',[],  'object_position',[], 'is_object_moving',[] );



n_obj_size = length(size_x);

n_stim = (2 + 2 + 2)*3*n_obj_size+6; % (2txt, 2moving txt, 2lum)*3n_pos*n_size + 2 txt blank+ 2 blank


template = cell(n_stim,1);
k = 0;
for i = 1:n_obj_size % different size

object_size_x = size_x(i);
object_size_y = size_y(i);
posx = [x, x - object_size_x/2,  x + object_size_x/2];

for j = 1:3 % position

    xc = posx(j);
    yc=y;
    xl = valid_matrix_index(resx/2 + xc - object_size_x/2, resx);
    xr = valid_matrix_index(resx/2 + xc + object_size_x/2, resx);
    x_obj =  xl : xr;
    yl = valid_matrix_index(resy/2 + y - object_size_y/2, resy);
    yr = valid_matrix_index(resy/2 + y + object_size_y/2, resy);
    y_obj = yl:yr;

    % lum1
    k=k+1;
    template{k} = zeros(resy,resx,'single');
    template{k}(:) = 1-contrast;
    template{k}(y_obj, x_obj)  = contrast;

    stim_info(k).stim_type = 'luminance object';
    stim_info(k).background = 1-contrast;
    stim_info(k).is_background_moving = false;
    stim_info(k).object = contrast;
    stim_info(k).object_size = [object_size_x object_size_y];
    stim_info(k).object_position = [xc yc];
    stim_info(k).is_object_moving = false;

    % lum2
    k=k+1;
    template{k} = zeros(resy,resx,'single');
    template{k}(:) = contrast;
    template{k}(y_obj, x_obj)  = 1-contrast;

    stim_info(k).stim_type = 'luminance object inverted';
    stim_info(k).background = contrast;
    stim_info(k).is_background_moving = false;
    stim_info(k).object = 1-contrast;
    stim_info(k).object_size = [object_size_x object_size_y];
    stim_info(k).object_position = [xc yc];
    stim_info(k).is_object_moving = false;

    % txt1
    k=k+1;
    template{k} = zeros(resy,resx,'single');
    template{k} = imtx_bg;
    template{k}(y_obj, x_obj)  = imtx_fg(y_obj, x_obj);

    stim_info(k).stim_type = 'texture object 1';
    stim_info(k).background = 'texture tilt left';
    stim_info(k).is_background_moving = false;
    stim_info(k).object = 'texture tilt right';
    stim_info(k).object_size = [object_size_x object_size_y];
    stim_info(k).object_position = [xc yc];
    stim_info(k).is_object_moving = false;

    % txt2
    k=k+1;
    template{k} = zeros(resy,resx,'single');
    template{k} = imtx_fg;
    template{k}(y_obj, x_obj)  = imtx_bg(y_obj, x_obj);

    stim_info(k).stim_type = 'texture object 2';
    stim_info(k).background = 'texture tilt right';
    stim_info(k).is_background_moving = false;
    stim_info(k).object = 'texture tilt left';
    stim_info(k).object_size = [object_size_x object_size_y];
    stim_info(k).object_position = [xc yc];
    stim_info(k).is_object_moving = false;

    % moving txt1
    k=k+1;
    frames = round(frame_rate*stim_duration);
    d_x = sin( ((1:frames)-1)*(pi/2) ) * mov_range;
    template{k} = zeros(resy,resx, frames,'single');
    
    for m = 1:frames
        x_obj_m = valid_matrix_index(x_obj - d_x(m), resx); % move
        template{k}(:,:,m) = imtx_bg; % Background
        template{k}(y_obj, x_obj_m, m) = mov_fg(y_obj, x_obj_m + d_x(m)); % Foreground
    end

    stim_info(k).stim_type = 'moving texture object 1';
    stim_info(k).background = 'texture tilt left';
    stim_info(k).is_background_moving = false;
    stim_info(k).object = 'texture tilt right';
    stim_info(k).object_size = [object_size_x object_size_y];
    stim_info(k).object_position = [xc yc];
    stim_info(k).is_object_moving = true;


    % moving txt2
    k=k+1;
    template{k} = zeros(resy, resx, frames,'single');

    for m = 1:frames
        x_obj_m = valid_matrix_index(x_obj - d_x(m), resx); % move
        template{k}(:,:,m) = imtx_fg;
        template{k}(y_obj, x_obj_m, m) = mov_bg(y_obj, x_obj_m + d_x(m));
    end

    stim_info(k).stim_type = 'moving texture object 1';
    stim_info(k).background = 'texture tilt left';
    stim_info(k).is_background_moving = false;
    stim_info(k).object = 'texture tilt right';
    stim_info(k).object_size = [object_size_x object_size_y];
    stim_info(k).object_position = [xc yc];
    stim_info(k).is_object_moving = true;

end

end


% moving texture background 1
k=k+1;
mov_frames = round(frame_rate*stim_duration);
d_x = round(sin( ((1:mov_frames)-1)*(pi/2) ) * mov_range);
template{k} = zeros(resy, resx, mov_frames,'single');
x_bg_m =  mov_range+1 : resx + mov_range; 

for m = 1:mov_frames
template{k}(:,:,m) = mov_fg(:, x_bg_m + d_x(m));         
end 

stim_info(k).stim_type = 'moving texture background 1';
stim_info(k).background = 'texture tilt right';
stim_info(k).is_background_moving = true;
stim_info(k).object = 'no object';
stim_info(k).object_size = [];
stim_info(k).object_position = [];
stim_info(k).is_object_moving = false;



% moving texture background 2
k=k+1;
mov_frames = round(frame_rate*stim_duration);
d_x = round(sin( ((1:mov_frames)-1)*(pi/2) ) * mov_range);
template{k} = zeros(resy, resx, mov_frames,'single');
x_bg_m =  mov_range+1 : resx + mov_range; 

for m = 1:mov_frames
template{k}(:,:,m) = mov_bg(:, x_bg_m - d_x(m));         
end 

stim_info(k).stim_type = 'moving texture background 2';
stim_info(k).background = 'texture tilt left';
stim_info(k).is_background_moving = true;
stim_info(k).object = 'no object';
stim_info(k).object_size = [];
stim_info(k).object_position = [];
stim_info(k).is_object_moving = false;

%   four backgrounds
k=k+1;
template{k}(1:resy,1:resx) = 1-contrast;
template{k}=single(template{k});

stim_info(k).stim_type = 'luminance background';
stim_info(k).background = 1-contrast;
stim_info(k).is_background_moving = false;
stim_info(k).object = 'no object';
stim_info(k).object_size = [];
stim_info(k).object_position = [];
stim_info(k).is_object_moving = false;

k=k+1;
template{k}(1:resy,1:resx) = contrast;
template{k}=single(template{k});

stim_info(k).stim_type = 'luminance background inverted';
stim_info(k).background = contrast;
stim_info(k).is_background_moving = false;
stim_info(k).object = 'no object';
stim_info(k).object_size = [];
stim_info(k).object_position = [];
stim_info(k).is_object_moving = false;


k=k+1;
template{k} = imtx_fg;

stim_info(k).stim_type = 'texture background 1';
stim_info(k).background = 'texture tilt right';
stim_info(k).is_background_moving = false;
stim_info(k).object = 'no object';
stim_info(k).object_size = [];
stim_info(k).object_position = [];
stim_info(k).is_object_moving = false;


k=k+1;
template{k} = imtx_bg;

stim_info(k).stim_type = 'texture background 2';
stim_info(k).background = 'texture tilt left';
stim_info(k).is_background_moving = false;
stim_info(k).object = 'no object';
stim_info(k).object_size = [];
stim_info(k).object_position = [];
stim_info(k).is_object_moving = false;
          


% implay(template)

stim_example = template{3};

if nargout == 1
    return;
end

 
%% movie data

moviedata = [];
blank = zeros(resy, resx, blank_duration*frame_rate)+0.5;

seq=[];

for i=1:repeat 
    ind=randperm(length(template));
    template_rand=template(ind); 
    seq=[seq ind];
    for j=1:length(template)
        if size(template_rand{j},3)>1
            show_time= template_rand{j};
        else
            show_time=repmat( template_rand{j}, [1 1 frame_rate*stim_duration]);
        end
        moviedata = cat(3, moviedata, show_time,  blank );
    end
end

% Conver to Uint8 for space
moviedata = uint8(255*moviedata);

stimParams = params.stimParams;

stimParams.Nframes = size(moviedata, 3);
stimParams.LuParams = params;
stimParams.LuStimInfo = stim_info;
stimParams.trialInfo.Ntrials = params.repeat * length(template);
stimParams.trialInfo.Nrepeats = params.repeat;
stimParams.trialInfo.NtrialTypes = length(template);
stimParams.trialInfo.durationStim = params.ontime;
stimParams.trialInfo.durationTrial = params.ontime+params.offtime;
stimParams.trialInfo.trialOnsetFrames =  [ 1 : (stimParams.trialInfo.durationTrial*frame_rate) : size(moviedata, 3)];
stimParams.trialInfo.stimOnsetFrames = stimParams.trialInfo.trialOnsetFrames;
stimParams.trialInfo.stimOffsetFrames = stimParams.trialInfo.stimOnsetFrames + frame_rate*params.ontime-1;
stimParams.trialInfo.trialType = seq; % What trial Type it was on each trial
stimParams.trialInfo.trialTypeDescriptors = stim_info; % What kind of trial that was...
stimParams.trialInfo.trialTemplate = template; % The template of that specific trial...

% implay(moviedata)
%datetime_str=datestr(now,'yyyy.mm.dd-HH.MM.SS');
%filename = ['border_ownership_mixed_' datetime_str '.mat'];

filename = sprintf('New_FG_BO_%dHz_%dconditions_%dReps_%dposition_%4.1fs_trials_%4.1fmsStim.mat', ...
    frame_rate, length(template), repeat, length(posx), stimParams.trialInfo.durationTrial, ...
    stimParams.trialInfo.durationStim)

save(fullfile(fileparts(which('alvin')), filename),'moviedata', 'stimParams', '-v7.3');


function x = valid_matrix_index(x, res)
x = round(x);
x(x<1) = 1;
x(x>res) = res;


