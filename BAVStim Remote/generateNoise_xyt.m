function [moviedata RANDSTATE] = generateNoise_xyt(maxSpatFreq,maxTempFreq,contrastSigma,duration,displayParam,filename)
%%% generates white noise movies with limited spatial and temporal
%%% frequency, via inverse fourier transform
RANDSTATE = sum(100*clock);
rand('state',RANDSTATE)
    tic
    
    %%% stimulus/display parameters
% 
%     displayParam.imsize = 60;                %% size in pixels
%     displayParam.framerate = 60;             %% Hz
%     displayParam.imageMag=10;                 %% magnification that movie will be played at % BA changed from x8 (all movies made before 080309 have 8x)
%     displayParam.screenWidthPix = 600;        %% Screen width in Pixels % BA changed from 640 as above
%     displayParam.screenWidthCm = 40;         %% Width in cm
%     displayParam.screenDistanceCm = 25;      %% Distance in cm
% 
    %        duration = 5               %% duration in minutes
    %        maxSpatFreq = 0.08         %% spatial frequency cutoff (cpd)
    %     maxTempFreq = 4;          %% temporal frequency cutoff
    %     contrastSigma =0.5;         %% one-sigma value for contrast
    % %
    %% derived parameters
    nframes = displayParam.framerate*60*duration;
    screenWidthDeg = 2*atan(0.5*displayParam.screenWidthCm/displayParam.screenDistanceCm)*180/pi;
    degperpix = (screenWidthDeg/displayParam.screenWidthPix)*displayParam.imageMag;
    
    %% frequency intervals for FFT
    nyq_pix = 0.5;
    nyq_deg=nyq_pix/degperpix;
    freqInt_deg = nyq_deg / (0.5*displayParam.imsize); % BA lowest spac frequency in deg ( as below there is a factor of 0.5 that I don't understand)
    freqInt_pix = nyq_pix / (0.5*displayParam.imsize);   
    nyq = displayParam.framerate/2;
    tempFreq_int = nyq/(0.5*nframes) ;% BA is this the lowest frequency in one movie? if so shouldn't it be framerate/(0.5*nframes) ?

   
    %% cutoffs in terms of frequency intervals
   
     tempCutoff = round(maxTempFreq/tempFreq_int); % BA cutoff frequency in terms of the temporal resolution available given the framerate?
     maxFreq_pix = maxSpatFreq*degperpix;   % BA (cyc per pix)
     spatCutoff = round(maxFreq_pix / freqInt_pix); % BA as above but for space given pixels 
        
        
%%% generate frequency spectrum (invFFT)
   alpha=-1;
   offset=3;
    range_mult =1;
    %for noise that extends past cutoff parameter (i.e. if cutoff = 1sigma)
    %range_mult=2;    
   spaceRange = (displayParam.imsize/2 - range_mult*spatCutoff : displayParam.imsize/2 + range_mult*spatCutoff)+1; % BA something to do with range in pixesl around a pixel that is effected by a contrast at that pixel??
   tempRange =   (nframes /2 - range_mult*tempCutoff : nframes/2 + range_mult*tempCutoff)+1;
   [x y z] = meshgrid(-range_mult*spatCutoff:range_mult*spatCutoff,-range_mult*spatCutoff:range_mult*spatCutoff,-range_mult*tempCutoff:range_mult*tempCutoff); 
   %% can put any other function to describe frequency spectrum in here,
   %% e.g. gaussian spectrum
   % use = exp(-1*((0.5*x.^2/spatCutoff^2) + (0.5*y.^2/spatCutoff^2) + (0.5*z.^2/tempCutoff^2)));
 %  use =single(((x.^2 + y.^2)<=(spatCutoff^2))& ((z.^2)<(tempCutoff^2)) );
      use =single(((x.^2 + y.^2)<=(spatCutoff^2))& ((z.^2)<(tempCutoff^2)) ).*(sqrt(x.^2 + y.^2 +offset).^alpha); % BA peak at 0 and fall off as 1/sqrt(x + offset) all pages are the same except first and last are 0s
   clear x y z;
   
   
   %%% 
   invFFT = zeros(displayParam.imsize,displayParam.imsize,nframes,'single');
   mu = zeros(size(spaceRange,2), size(spaceRange,2), size(tempRange,2));
   sig = ones(size(spaceRange,2), size(spaceRange,2), size(tempRange,2));
   % BA use scales gaussian times random phase
   invFFT(spaceRange, spaceRange, tempRange) = single(use .* normrnd(mu,sig).*exp(2*pi*i*rand(size(spaceRange,2), size(spaceRange,2), size(tempRange,2))));
       save([filename '_generateNoise_freqSpectrum.mat'],'use','spaceRange','tempRange','spatCutoff','tempCutoff');
   clear use;
   
   %% in order to get real values for image, need to make spectrum
   %% symmetric
   fullspace = -range_mult*spatCutoff:range_mult*spatCutoff; halftemp = 1:range_mult*tempCutoff;
   halfspace = 1:range_mult*spatCutoff;
   invFFT(displayParam.imsize/2 + fullspace+1, displayParam.imsize/2+fullspace+1, nframes/2 + halftemp+1) = ...
            conj(invFFT(displayParam.imsize/2 - fullspace+1, displayParam.imsize/2-fullspace+1, nframes/2 - halftemp+1));
   invFFT(displayParam.imsize/2+fullspace+1, displayParam.imsize/2 + halfspace+1,nframes/2+1) = ...
            conj( invFFT(displayParam.imsize/2-fullspace+1, displayParam.imsize/2 - halfspace+1,nframes/2+1));
   invFFT(displayParam.imsize/2+halfspace+1, displayParam.imsize/2 +1,nframes/2+1) = ...
            conj( invFFT(displayParam.imsize/2-halfspace+1, displayParam.imsize/2+1,nframes/2+1));
  
%     figure
%     imagesc(abs(invFFT(:,:,nframes/2+1)));
%     figure
%     imagesc(angle(invFFT(:,:,nframes/2)));
%    
    shiftinvFFT = ifftshift(invFFT); % BA don't get it
    save([filename '_generateNoise_invFFT.mat'],'invFFT');
    clear invFFT mu sigma
 
    

   %%% invert FFT and scale it to 0 -255
   
   imraw = real(ifftn(shiftinvFFT));
    clear shiftinvFFT;
    immean = mean(imraw(:));
    immax = std(imraw(:))/contrastSigma;
    immin = -1*immax;
    imscaled = (imraw - immin-immean) / (immax - immin);
    clear imfiltered;
    contrast_period =10;
    
    %** BA
%     A = [0.75 .25 1 0.5];
%     dur = 150; % duration in frames of each contrast
%     contrast = zeros(1,size(imraw,3));
%     j=1;
%     for k = 2:2:size(imraw,3)/dur
%        contrast(1+(k-1)*dur:k*dur) = 0 ;
% %        contrast(1+(i)*dur:(k+1)*dur) = A(round(rand(1)*length(A)+.5)) ; %
% %        random
%        contrast(1+(i)*dur:(k+1)*dur) = A(rem(j,length(A))+1) ;
%        j = j+1;
%     end
    %** BA for HIGHLOW e.g.HIGH05 LOW015
    contrastHIGH = 0.5
    contrastLOW = 0.15
    contrast = ones(1,size(imscaled,3)).*contrastHIGH;
    temp = sin(2*pi*[1:nframes]/(2*contrast_period*displayParam.framerate))>0;
    contrast(temp)=contrastLOW;
    for f = 1:nframes
        imscaled(:,:,f) = (imscaled(:,:,f)-.5).*(0.5-0.5*cos(2*pi*f/(contrast_period*displayParam.framerate))); % sine modulation
%         imscaled(:,:,f) = (imscaled(:,:,f)-.5).*(0.5); % no modulation
%         imscaled(:,:,f) = (imscaled(:,:,f)-.5).*(contrast(mod(f-1,1800)+1)); % step      modulation
%         imscaled(:,:,f) = (imscaled(:,:,f)-.5).*contrast(f); % HIGH LOW step      modulation
    end
    imscaled = imscaled+0.5;
        moviedata = uint8(floor(imscaled(1:displayParam.imsize,1:displayParam.imsize,:)*255)+1);

%         temp = imscaled(:,:,4250);
% figure;  hist(temp(:),100)

figure;
plot(squeeze(mean(mean(imscaled,1),2)),'g');hold on
plot(squeeze(std(std(imscaled,1,1),1,2)))
title('mean (green) and std');
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
%    figure
    
%% to view movie
% 
%     for f=1:1000
%    
%         imshow(moviedata(:,:,f));
%         mov(f) = getframe(gcf);
%     end 
%     toc
%     movie(mov,10,30)