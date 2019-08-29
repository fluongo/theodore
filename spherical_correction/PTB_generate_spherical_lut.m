function scal = PTB_generate_spherical_lut(caliboutfilename, screenid, ops)
% scal = PTB_generate_spherical_lut(caliboutfilename, screenid, ops)

% How to use:
% -----------
%
% Execute the function with the following parameters:
%
% `caliboutfilename` Name of the file to which calibration results should
% be stored. If no name is provided, the file will be stored inside the
% 'GeometryCalibration' subfolder of your Psychtoolbox configuration
% directory (path is PsychToolboxConfigDir('GeometryCalibration'). The
% filename will contain the screenid of the display that was calibrated.
%
% `screenid` screen id of the target display for calibration. The parameter
% is optional, defaults to zero, and is only used to generate the default
% filename for the output file.
%
% 'ops' is the structure that contains options for the position of the
% screen
%
% This script will print out a little snippet of code that you can paste
% and include into your experiment script - That will automatically load
% the calibration result file and apply the proper undistortion operation.
%
% A quick way to test your calibration created with this script is to
% call ImageUndistortionDemo (caliboutfilename, 'checkerboard'). However,

% Setup defaults:
PsychDefaultSetup(0);

if ~exist('screenid', 'var') || isempty(screenid)
  screenid = 0;
end

scal.screenNumber = screenid;
warptype = 'CSVDisplayList'; %#ok<NASGU>
scal.useUnitDisplayCoords = 0;

[xi, yi, xS, yS] = MouseStim(10, ops);

% Build 2D source and destination matrices: rows x cols per plane,
% 2 planes for x and y components:
rows = size(xi, 1);
cols = size(xi, 2);

% Vertex coordinates of the rendered output mesh quad vertices:
scal.vcoords = zeros(rows, cols, 2);

% Corresponding texture coordinates for sourcing from user provided input
% image framebuffer:
scal.tcoords = zeros(rows, cols, 2);

% Assign from output of the Labrigger MouseStim implementation
scal.vcoords(:,:,1) = xi;
scal.vcoords(:,:,2) = yi;
scal.tcoords(:,:,1) = xS;
scal.tcoords(:,:,2) = yS;

% 'scal' contains the final results of calibration. Write it out to
% calibfile for later use by the runtime routines:

% Check if name for calibration result file is provided:
if ~exist('caliboutfilename', 'var')
  caliboutfilename = [];
end

if isempty(caliboutfilename)
  % Nope: Assign default name - Store in dedicated subfolder of users PTB
  % config dir, with a well defined name that also encodes the screenid
  % for which to calibrate:
  caliboutfilename = [ PsychtoolboxConfigDir('GeometryCalibration') 'CSVCalibdata' sprintf('_%i', screenid) '.mat'];
  fprintf('\nNo name for calibration file provided. Using default name and location...\n');
end

% Save all relevant calibration variables to file 'caliboutfilename'. This
% method should work on both, Matlab 6.x, 7.x, ... and GNU/Octave - create
% files that are readable by all runtime environments:
save(caliboutfilename, 'warptype', 'scal', '-mat', '-V6');

fprintf('Creation of Calibration file finished :-)\n\n');
fprintf('You can apply the calibration in your experiment script by replacing your \n')
fprintf('win = Screen(''OpenWindow'', ...); command by the following sequence of \n');
fprintf('commands:\n\n');
fprintf('PsychImaging(''PrepareConfiguration'');\n');
fprintf('PsychImaging(''AddTask'', ''LeftView'', ''GeometryCorrection'', ''%s'');\n', caliboutfilename);
fprintf('win = PsychImaging(''OpenWindow'', ...);\n\n');
fprintf('This would apply the calibration to the left-eye display of a stereo setup.\n');
fprintf('Additional options would be ''RightView'' for the right-eye display of a stereo setup,\n');
fprintf('or ''AllViews'' for both views of a stereo setup or the single display of a mono\n');
fprintf('setup.\n\n');
fprintf('The ''GeometryCorrection'' call has a ''debug'' flag as an additional optional parameter.\n');
fprintf('Set it to a non-zero value for diagnostic output at runtime.\n');
fprintf('E.g., PsychImaging(''AddTask'', ''LeftView'', ''GeometryCorrection'', ''%s'', 1);\n', caliboutfilename);
fprintf('would provide some debug output when actually using the calibration at runtime.\n\n\n');

% Done.
return;

end

% MouseStim is mostly a verbatim copy of the sample code on LabRigger,
% with some modifications to make it work for PTB.
function [xi, yi, xS, yS] = MouseStim(subdivide, ops)
  close all;

  % Monitor size and position variables
  w = ops.w;  % width of screen, in cm
  h = ops.h;  % height of screen, in cm
  cx = ops.cx;   % eye x location, in cm
  cy = ops.cy; % eye y location, in cm

  % Distance to bottom of screen, along the horizontal eye line
  zdistBottom = ops.zdistBottom     % in cm
  zdistTop    = ops.zdistTop;     % in cm

  % Alternatively, you can specify the angle of the screen
  %screenAngle = 72.5;   % in degrees, measured from table surface in front of screen to plane of screen
  %zdistTop = zdistBottom - (h*sin(deg2rad(90-screenAngle)));

  %pxXmax = 200; % number of pixels in an image that fills the whole screen, x
  %pxYmax = 150; % number of pixels in an image that fills the whole screen, y

  % MK: Use bigger input/output framebuffer of a 1680 x 1050 flat panel.
  % We add 1 pixel in size, so we don't get cutoff at the bottom and right
  % border if 'subdivide' is > 1.
  pxXmax = ops.pxXmax; % number of pixels in an image that fills the whole screen, x
  pxYmax = ops.pxYmax; % number of pixels in an image that fills the whole screen, y

  % Internal conversions
  top = h-cy;
  bottom = -cy;
  right = cx;
  left = cx - w;

  % Convert Cartesian to spherical coord
  % In image space, x and y are width and height of monitor and z is the
  % distance from the eye. I want Theta to correspond to azimuth and Phi to
  % correspond to elevation, but these are measured from the x-axis and x-y
  % plane, respectively. So I need to exchange the axes this way, prior to
  % converting to spherical coordinates:
  % orig (image) -> for conversion to spherical coords
  % Z -> X
  % X -> Y
  % Y -> Z

  [xi,yi] = meshgrid(1:pxXmax,1:pxYmax);

  % MK: Need to shift - 1 because OpenGL coordinates are 0-based, not 1-based
  % as Matlabs, otherwise we'd get artifacts at the top-left corner of the
  % display due to omitted data:
  xi = xi - 1;
  yi = yi - 1;

  cart_pointsX = left + (w/pxXmax).*xi;
  cart_pointsY = top - (h/pxYmax).*yi;
  cart_pointsZ = zdistTop + ((zdistBottom-zdistTop)/pxYmax).*yi;
  [sphr_pointsTh sphr_pointsPh sphr_pointsR] ...
              = cart2sph(cart_pointsZ,cart_pointsX,cart_pointsY);

  % view results
  if ops.do_plot == 1
      figure
      subplot(3,2,1)
      imagesc(cart_pointsX);
      colorbar
      title('image/cart coords, x')
      subplot(3,2,3)
      imagesc(cart_pointsY);
      colorbar
      title('image/cart coords, y')
      subplot(3,2,5)
      imagesc(cart_pointsZ);
      colorbar
      title('image/cart coords, z')

      subplot(3,2,2)
      imagesc(rad2deg(sphr_pointsTh));
      colorbar
      title('mouse/sph coords, theta')
      subplot(3,2,4)
      imagesc(rad2deg(sphr_pointsPh));
      colorbar
      title('mouse/sph coords, phi')
      subplot(3,2,6)
      imagesc(sphr_pointsR);
      colorbar
      title('mouse/sph coords, radius')
  end
  
  % Rescale the Cartesian maps into dimensions of radians
  xmaxRad = max(sphr_pointsTh(:));
  ymaxRad = max(sphr_pointsPh(:));

  fx = xmaxRad/max(cart_pointsX(:));
  fy = ymaxRad/max(cart_pointsY(:));

  % Compute matrices with sampling positions, needed for Psychtoolbox:
  xS = interp2(cart_pointsX.*fx,cart_pointsY.*fy,xi,sphr_pointsTh,sphr_pointsPh);
  yS = interp2(cart_pointsX.*fx,cart_pointsY.*fy,yi,sphr_pointsTh,sphr_pointsPh);
    
  if ops.do_plot == 1
      h = figure;
      subplot(1,2,1);
      imagesc(xS);
      colorbar
      title('Lookup position input x:')
      subplot(1,2,2);
      imagesc(yS);
      colorbar
      title('Lookup position input y:')
  end
  
  % Subsample to only use every subdivide'th sample:
  xi = xi(1:subdivide:end, 1:subdivide:end);
  yi = yi(1:subdivide:end, 1:subdivide:end);

  xS = xS(1:subdivide:end, 1:subdivide:end);
  yS = yS(1:subdivide:end, 1:subdivide:end);

  % We are done with creating output useable for Psychtoolbox.

  %% And here’s the debug code to try the distortion out in Matlab/Octave:
  if 1
    %% try a distortion

    % make source image
    checkSize = 105; % pixels per side of each check
    w = 1680; % width, in pixels
    h = 1050; % height, in pixels
    I = double(checkerboard(checkSize,round(h/checkSize/2),round(w/checkSize/2))>0.5);

    % alternate source image
    %I = zeros(150*4,200*4);
    %I(105*4:125*4,:)=0.2;
    %I(20*4:40*4,:)=0.4;

    if isequal(size(I), size(xi))
      % Test apply the distortion via interpolation and plotting in Matlab:
      ZI = interp2(cart_pointsX.*fx,cart_pointsY.*fy,I,sphr_pointsTh,sphr_pointsPh);
      h=figure;
      subplot(1,2,1);
      imshow(I);
      subplot(1,2,2);
      imshow(ZI);
    end
  end

  % Done.
end

% Inline replacement for missing rad2deg() in default Octave 3.8 installation:
function deg = rad2deg(rad)
  deg = rad * 180 / pi;
end