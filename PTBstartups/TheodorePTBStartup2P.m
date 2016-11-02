function [ window, windowRect ] = TheodorePTBStartup2P( ScreenNumber , sphericalCheck)
%[ window, windowRect ] = TheodorePTBStartup2P( ScreenNumber )
%   General Startup PTB function for the 2P stimulus computer

	close all;
	sca
	
	% Here we call some default settings for setting up Psychtoolbox
	PsychDefaultSetup(2);

	% Get the screen numbers. This gives us a number for each of the screens
	% attached to our computer.
	screens = Screen('Screens');

	% To draw we select the maximum of these numbers. So in a situation where we
	% have two screens attached to our monitor we will draw to the external
	% screen.

	screenNumber = 2 %max(screens);

	% Define black and white (white will be 1 and black 0). This is because
	% in general luminace values are defined between 0 and 1 with 255 steps in
	% between. All values in Psychtoolbox are defined between 0 and 1
	white = WhiteIndex(screenNumber);
	black = BlackIndex(screenNumber);

	% Do a simply calculation to calculate the luminance value for grey. This
	% will be half the luminace values for white
	grey = white / 2;
	
	Screen('Preference', 'VisualDebugLevel', 1);
	
	
	if sphericalCheck
		PsychImaging('PrepareConfiguration');
		PsychImaging('AddTask', 'Allviews', 'GeometryCorrection', 'C:\Users\stimcomp2\AppData\Roaming\Psychtoolbox\GeometryCalibration\CSVCalibdata_2.mat');
	end
	
	
	% Standard window
	color = 0.5; rect = []; pixelsize = []; numBuffers = []; stereomode = 0;
	[window, windowRect] = PsychImaging('OpenWindow', screenNumber, color, rect, pixelsize, numBuffers, stereomode);

end

