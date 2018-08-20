function moviedata=generateNoise_xyt(maxSpatFreq,maxTempFreq,contrastSigma,duration);
%%% generates white noise movies with limited spatial and temporal
%%% frequency, via inverse fourier transform
rand('state',sum(100*clock))
    tic
 
    %%% stimulus/display parameters
    
    imsize = 72;                %% size in pixels
    framerate = 30;             %% Hz
  
    imageMag=4;                 %% magnification that movie will be played at
    screenWidthPix = 1280        %% Screen width in Pixels
    screenWidthCm = 71;         %% Width in cm
    screenDistanceCm = 20;      %% Distance in cm
    
       %duration = .5;               %% duration in minutes  
       %maxSpatFreq = 0.12          %% spatial frequency cutoff (cpd)
    %maxTempFreq = 10;          %% temporal frequency cutoff    
    %contrastSigma =0.5;         %% one-sigma value for contrast
    
    %% derived parameters
    nframes = framerate*60*duration;
    screenWidthDeg = 2*atan(0.5*screenWidthCm/screenDistanceCm)*180/pi;
    degperpix = (screenWidthDeg/screenWidthPix)*imageMag
    
    %% frequency intervals for FFT
    nyq_pix = 0.5;
    nyq_deg=nyq_pix/degperpix;
    freqInt_deg = nyq_deg / (0.5*imsize);
    freqInt_pix = nyq_pix / (0.5*imsize);   
    nyq = framerate/2;
    tempFreq_int = nyq/(0.5*nframes)

   
    %% cutoffs in terms of frequency intervals
   
     tempCutoff = round(maxTempFreq/tempFreq_int);
     maxFreq_pix = maxSpatFreq*degperpix;   
     spatCutoff = round(maxFreq_pix / freqInt_pix);
        
        
%%% generate frequency spectrum (invFFT)
   alpha=-1;
   offset=3;
    range_mult =1;
    %for noise that extends past cutoff parameter (i.e. if cutoff = 1sigma)
    %range_mult=2;    
   spaceRange = (imsize/2 - range_mult*spatCutoff : imsize/2 + range_mult*spatCutoff)+1;
   tempRange =   (nframes /2 - range_mult*tempCutoff : nframes/2 + range_mult*tempCutoff)+1;
   [x y z] = meshgrid(-range_mult*spatCutoff:range_mult*spatCutoff,-range_mult*spatCutoff:range_mult*spatCutoff,-range_mult*tempCutoff:range_mult*tempCutoff); 
   %% can put any other function to describe frequency spectrum in here,
   %% e.g. gaussian spectrum
   % use = exp(-1*((0.5*x.^2/spatCutoff^2) + (0.5*y.^2/spatCutoff^2) + (0.5*z.^2/tempCutoff^2)));
 %  use =single(((x.^2 + y.^2)<=(spatCutoff^2))& ((z.^2)<(tempCutoff^2)) );
      use =single(((x.^2 + y.^2)<=(spatCutoff^2))& ((z.^2)<(tempCutoff^2)) ).*(sqrt(x.^2 + y.^2 +offset).^alpha);
   clear x y z;
   
   
   %%% 
   invFFT = zeros(imsize,imsize,nframes,'single');
   mu = zeros(size(spaceRange,2), size(spaceRange,2), size(tempRange,2));
   sig = ones(size(spaceRange,2), size(spaceRange,2), size(tempRange,2));   
   invFFT(spaceRange, spaceRange, tempRange) = single(use .* normrnd(mu,sig).*exp(2*pi*i*rand(size(spaceRange,2), size(spaceRange,2), size(tempRange,2))));
   clear use;
   
   %% in order to get real values for image, need to make spectrum
   %% symmetric
   fullspace = -range_mult*spatCutoff:range_mult*spatCutoff; halftemp = 1:range_mult*tempCutoff;
   halfspace = 1:range_mult*spatCutoff;
   invFFT(imsize/2 + fullspace+1, imsize/2+fullspace+1, nframes/2 + halftemp+1) = ...
            conj(invFFT(imsize/2 - fullspace+1, imsize/2-fullspace+1, nframes/2 - halftemp+1));
   invFFT(imsize/2+fullspace+1, imsize/2 + halfspace+1,nframes/2+1) = ...
            conj( invFFT(imsize/2-fullspace+1, imsize/2 - halfspace+1,nframes/2+1));
   invFFT(imsize/2+halfspace+1, imsize/2 +1,nframes/2+1) = ...
            conj( invFFT(imsize/2-halfspace+1, imsize/2+1,nframes/2+1));
  
    figure
    imagesc(abs(invFFT(:,:,nframes/2+1)));
    figure
    imagesc(angle(invFFT(:,:,nframes/2)));
   
    pack
    shiftinvFFT = ifftshift(invFFT);
    clear invFFT;
    
   %%% invert FFT and scale it to 0 -255
   
   imraw = real(ifftn(shiftinvFFT));
    clear shiftinvFFT;
    immean = mean(imraw(:))
    immax = std(imraw(:))/contrastSigma
    immin = -1*immax
    imscaled = (imraw - immin-immean) / (immax - immin);
    clear imfiltered;
    contrast_period =10;
%    contrast(1:150) = 0;
%    contrast(151:450) = 0.75;
%    contrast(451:600) = 0;
%    contrast(601:900) = .25;
%    contrast(901:1050) = 0;
%    contrast(1051:1350) = 1;
%    contrast(1351:1500) = 0;
%    contrast(1501:1800) = 0.5;
   
    for f = 1:nframes
        imscaled(:,:,f) = (imscaled(:,:,f)-.5).*(0.5-0.5*cos(2*pi*f/(contrast_period*framerate)));
        %imscaled(:,:,f) = (imscaled(:,:,f)-.5).*(contrast(mod(f-1,1800)+1));
    end
    imscaled = imscaled+0.5;
        moviedata = uint8(floor(imscaled(1:imsize,1:imsize,:)*255)+1);

%%%   to check pixel intensity distribution      (slow!)

%     pixdata = single(moviedata);
%     figure
%     hist(pixdata(:));
%     figure
% 


   %% to check that the spectrum is still correct
   clear imscaled
   c = fftn(single(moviedata)-128);
   c = fftshift(c);
   figure
   imagesc(mean(abs(c(:,:,:)),3));
   figure
    
%%% to view movie
% 
%     for f=1:1000
%    
%         imshow(moviedata(:,:,f));
%         mov(f) = getframe(gcf);
%     end 
%     toc
%     movie(mov,10,30)