function [ output_args ] = theodore_BO_FG_generate(params)
% Function for generatign a theodore compatible Figure Ground and Border
% ownership stimuli, trying to make this as multipurpose as possible.

% parameters

frame_rate = params.framerate;
stim_duration = params.stim_duration;
blank_duration = params.blank_duration;
resx = 160; 
resy = 90;
size_x = 30; % If you want to do multiple sizes just make this nx1
size_y = 30; % If you want to do multiple sizes just make this nx1
orientation = 0;  
x = params.PosX; % Offset from center
y = params.PosY; % Offset from center
repeat = params.Nrepeats % Number of times to repeat
contrast = 0.8;
 

% load texture
imtx = imread('texture2_low1.tif');
imtx=single(imtx);
imtx=imtx(:,:,1);
imtx=imtx/max(imtx(:))*contrast;
imtx_bg = imresize(imtx, [resy, resx]);
imtx_fg= flip(imtx_bg,1);


%parameter for movement
mov_range = round(resx * 0.01); % How far figure will move
frames = stim_duration*framerate; %Number of frames for movement
mov_bg = imresize(imtx, [resy, resx + mov_range*2]) ;
mov_fg = flip(mov_bg,1);

n_obj_size = length(size_x); % Number of object sizes

n_stim = (2 + 2)*3*n_obj_size+4 + 4 + 2 + 2; % (2txt, 2lum)*3n_pos*n_size + 2 txt blank+ 2 blank


template = cell(n_stim,1);
k = 0;
for i = 1:n_obj_size % different size

    object_size_x = size_x(i);
    object_size_y = size_y(i);
    posx = [x, x - object_size_x/2,  x + object_size_x/2];
    blank = zeros(resy, resx, blank_duration*frame_rate)+0.5;
    2
    for j = 1:length(posx) % position
        
        xc = posx(j);
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

        % lum2
        k=k+1;
        template{k} = zeros(resy,resx,'single');
        template{k}(:) = contrast;
        template{k}(y_obj, x_obj)  = 1-contrast;

        % txt1 % Texture square on BG
        k=k+1;
        template{k} = zeros(resy,resx,'single');
        template{k} = imtx_bg;
        template{k}(y_obj, x_obj)  = imtx_fg(y_obj, x_obj);

        % txt2 % Texture square on BG
        k=k+1;
        template{k} = zeros(resy,resx,'single');
        template{k} = imtx_fg;
        template{k}(y_obj, x_obj)  = imtx_bg(y_obj, x_obj);
        
        % moving txt1
        k=k+1;

        for m = 1:frames
            bg_m(:,:,m) = imtx_bg;
        end

        obj_m = bg_m;
        d_x = round(sin( ((1:frames)-1)*(pi/2) ) * mov_range);
        for m = 1:frames
            x_obj_m = valid_matrix_index(x_obj - d_x(m), resx); % move
            obj_m(y_obj, x_obj_m, m) = imtx_fg(y_obj, x_obj);
        end
        template{k} = cat(3,obj_m,blank);
        
        % moving txt2
        k=k+1;

        for m = 1:frames
            bg_m(:,:,m) = imtx_fg;
        end

        obj_m = bg_m;
        d_x = round(sin( ((1:frames)-1)*(pi/2) ) * mov_range);
        for m = 1:frames
            x_obj_m = valid_matrix_index(x_obj - d_x(m), resx); % move
            obj_m(y_obj, x_obj_m, m) = imtx_bg(y_obj, x_obj);
        end
        template{k} = cat(3,obj_m,blank);
        
    end
    
end

%background moving controls

bg_m = zeros(resy, resx, frames, 'single'); % background move
d_x = round(sin( ((1:frames)-1)*(pi/2) ) * mov_range);
x_bg_m =  mov_range+1 : resx + mov_range; % x of center frame
for m = 1:frames
    bg_m(:,:,m) = mov_bg(:, x_bg_m - d_x(m));
end
template{n_stim-5} = cat(3,bg_m,blank);
    
bg_m = zeros(resy, resx, frames, 'single'); % background move
d_x = round(sin( ((1:frames)-1)*(pi/2) ) * mov_range);
x_bg_m =  mov_range+1 : resx + mov_range; % x of center frame
for m = 1:frames
    bg_m(:,:,m) = mov_fg(:, x_bg_m - d_x(m));
end
template{n_stim-4} = cat(3,bg_m,blank);

template{n_stim-3}(1:resy,1:resx) = single(1-contrast);
template{n_stim-2}(1:resy,1:resx) = single(contrast);
template{n_stim-1} = imtx_fg; 
template{n_stim} = imtx_bg;

% movie data
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
            moviedata = cat(3, moviedata, show_time);
        else
            show_time=repmat( template_rand{j}, [1 1 frame_rate*stim_duration]);
            moviedata = cat(3, moviedata, show_time,  blank );
        end
    end
end

clearvars -except moviedata template seq

% Make a template figure for each one

for i = 1:24
    if size(template{i}, 3) == 20
        templateD{i} = template{i}(:,:,1);
        templateD{i}(end-30:end, end-30:end) = 1;
    else
        templateD{i} = template{i};
    end
end

% Return moviedata, stimParams, templateD
stimParams.framerate = framerate;
stimParams.Nframes = size(moviedata, 3);
stimParams.RFmap = 0; stimParams.trialBased = 1;
stimParams.trialInfo = {}
stimParams.trialInfo.StimName = sprintf('ECRF modulation, %d Repeats, %d conditions, Lum/Tex/TexMot', params.Nrepeats, length(templateD));
stimParams.trialInfo.Ntrials = length(seq);
stimParams.trialInfo.Nrepeats = params.Nrepeats
stimParams.trialInfo.NtrialTypes = length(templateD)
stimParams.trialInfo.durationStim = params.duration_stim
stimParams.trialInfo.durationTrial = params.stim_duration + params.blank_duration
stimParams.trialInfo.trialOnsetFrames = [1:stimParams.durationTrial*framerate:stimParams.Nframes]
stimParams.trialInfo.stimOnsetFrames = stimParams.trialOnsetFrames
stimParams.trialInfo.stimOffsetFrames = stimParams.stimOnsetFrames + stimParams.duration_stim*framerate -1;
stimParams.trialInfo.trialType = seq; % 1-24 of the trial types
stimParams.trialInfo.trialTemplate = templateD; % templates


% 
% trialTypeCategory: {1x240 cell}
%         trialTypeMotion: [1x240 double]
%      trialTypeFullField: [1x240 double]
%     trialFigurePosition: {1x240 cell}


% 
% % Add outlines
% [Gmag1,Gdir] = imgradient(template{1});
% for i = 3:6
%     templateD{i} = templateD{i} +Gmag1; 
% end
% [Gmag7,Gdir] = imgradient(template{7});
% for i = 9:12
%     templateD{i} = templateD{i} + Gmag7; 
% end
% 
% [Gmag13,Gdir] = imgradient(template{13});
% for i = 15:18
%     templateD{i} = templateD{i} +Gmag13; 
% end

% Plot results
for i = 1:24
    subplot(7,7,i)
    imshow(templateD{i}); title(num2str(i))
end

end

