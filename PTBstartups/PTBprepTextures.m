function [ all_textures ] = PTBprepTextures( moviedata, window )
%UNTITLED3 Summary of this function goes here
%   Takes in moviedata, and then returns the texture handles

all_textures = zeros(1, size(moviedata,3));

for i = 1 : size(moviedata, 3) 
	%all_textures(i) = Screen('MakeTexture', window, double(moviedata(:,:,i)));
	all_textures(i) = Screen('MakeTexture', window, moviedata(:,:,i));
end

end

