
% Monitor size and position variables
ops.w = 48;  % width of screen, in cm
ops.h = 27;  % height of screen, in cm
ops.cx = 27;   % eye x location, in cm (from bottom-right)
ops.cy = 13; % eye y location, in cm (from bottom-right)

% Distance to bottom of screen, along the horizontal eye line
ops.zdistBottom = 13;     % in cm
ops.zdistTop    = 12;     % in cm

% Pixels to fill whole screen
ops.pxXmax = 900; % number of pixels in an image that fills the whole screen, x
ops.pxYmax = 400;

% Whether or not to plot
ops.do_plot = 1;

caliboutfilename = 'test.mat';
screenid = 0;
scal = PTB_generate_spherical_lut(caliboutfilename, screenid, ops)
