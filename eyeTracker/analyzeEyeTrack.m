function [Centroid, Area] = analyzeEyeTrack(data)
%Analyze the eye tracking data
%     Takes in amovie (h x w x T) and then asks for a crop and exports back
%     a Centroid and Area as well as an dataN script that draws on there
%     the circle fit and Area
%
%
%


rad_range = [6, 70];   % range of radii to search for

% Remove... the light spot Invert it...
%
data = max(max(max(data))) - data;
for i = 1:size(data, 3); 
    data(:,:,i) = imadjust(data(:,:,i));
end

% Get a rectangle for the subsection
goodRect = 0
while goodRect == 0
    subplot(1,2,1)
    imshow(data(:,:,1))
    rect = getrect; subplot(1,2,2); imshow(imcrop(data(:,:,1), rect))
    button = questdlg('Is this appropriate Cut?','Confirmation','Keep','Retry', 'Retry')
    switch button
        case 'Keep'
            goodRect = 1;
        case 'Retry'
            goodRect = 0;
    end
end

sz = size(imcrop(data(:,:,1), rect));
dataSub = zeros(sz(1), sz(2), size(data, 3));

for i = 1:size(data, 3)
    dataSub(:,:,i) = imcrop(data(:,:,i), rect);
end

data = dataSub;

warning off;

%Edit Patrick: changed this so that struct doesn't change size every time
%while maintaining backwards compatibility

A = cell(size(data,3),1);
B = cell(size(data,3),1);
for n = 1:size(data,3)
    A{n} = [0,0];
    B{n} = [0];
end

eye = struct('Centroid',A,'Area',B);
for(n=1:size(data,3))
    [center,radii,metric] = imfindcircles(squeeze(data(:,:,n)),rad_range, 'Sensitivity',0.9);
    if(isempty(center))
        eye(n).Centroid = [NaN NaN];    % could not find anything...
        eye(n).Area = NaN;
    else
        [~,idx] = max(metric);          % pick the circle with best scor
        eye(n).Centroid = center(idx,:);
        eye(n).Area = 4*pi*radii(idx)^2;
    end
    if mod(n,100)==0
        fprintf('Frame %d/%d\n',n,size(data,3));
    end
end

Centroid = cell2mat({eye.Centroid}');
Area = cell2mat({eye.Area}');

% Now plot on the images the radii

end

