function [frm]= generateGratings_blit(orient,freq,TempFreq,phase0,contrast,duration, degPerPix,sizeX,sizeY, frameRate, black, white)

% BA
SAVEPATH = 'E:\Documents and Settings\Bassam\My Documents\Matlab toolboxes\VStimConfig\movies\autosaved\';

savefilename = sprintf('%sGratingO%df%dtf%dph%dc%dd%ddpp%dx%dy%dfr%dbk%dwh%d',SAVEPATH,orient,round(freq*1000),round(TempFreq*1000),phase0,round(contrast*1000),round(duration*1000), round(degPerPix*1000),sizeX,sizeY, round(frameRate*100), black, white);

bcalculate = 1;

bsave = 1;
tic
if ~isempty(dir([savefilename '.mat'])) % read from file disk if already exists
    load(savefilename);
    temp = sprintf('Loading previously generated file: %s',savefilename);
    display(temp);
    temp = sprintf('Checking parameters');
    display(temp);

    paramIN.orient = orient;
    paramIN.freq = freq;
    paramIN.TempFreq = TempFreq;
    paramIN.phase0 = phase0;
    paramIN.contrast = contrast;
    paramIN.duration = duration;
    paramIN.degPerPix = degPerPix;
    paramIN.sizeX = sizeX;
    paramIN.sizeY = sizeY;
    paramIN.frameRate = frameRate;
    paramIN.black = black;
    paramIN.white = white;
    
    if ~isempty(comp_struct(paramIN,param)) % check if all the param values are correct in file
        bcalculate = 1;
        Warning('Loaded file params do NOT match params the way savefilename is named should be changed fix this');
    end
    bcalculate = 0;
end
toc
if bcalculate % calculate grating
    % window
        temp = sprintf('Calculating grating');
    display(temp);

    gray = 0.5*(white+black);
    if contrast>1
        contrast=1;
    end
    inc=(white-gray)*contrast;

    %%% calculate stimulus parameters
    frames = duration*frameRate;  % temporal period, in frames, of the drifting grating

    %%%framesPerPeriod = frameRate / (TempFreq); use inverse of this to avoid
    %%%dividing by zero when tempfreq=0

    phase0 = phase0*pi/180;
    FrameFreq = TempFreq/frameRate;   %%%grating frequency, in frames;

    wavelength = 1/freq;
    pixPerDeg = 1/degPerPix;

    %%% calculate image, a ramp from 0 to 2pi aligned with grating
    [x,y]=meshgrid(1:sizeX,1:sizeY);
    angle=orient*pi/180;
    angle = pi-angle;  %%% to follow polar coordinate convention


    f= 2*pi/(pixPerDeg*wavelength); % cycles/pixel
    a=cos(angle)*f;
    b=sin(angle)*f;

    frm = zeros(frames, size(x,1),size(x,2),'uint8');
    for i=1:frames
        phase=(i*FrameFreq)*2*pi + phase0; % this should make number of cycles per sec the same no mater aht the spatial frquency
        % grating
        frm(i,:,:)=uint8(gray +inc*sin(a*x+b*y+phase));
    end

    if bsave
        param.orient = orient;
        param.freq = freq;
        param.TempFreq = TempFreq;
        param.phase0 = phase0;
        param.contrast = contrast;
        param.duration = duration;
        param.degPerPix = degPerPix;
        param.sizeX = sizeX;
        param.sizeY = sizeY;
        param.frameRate = frameRate;
        param.black = black;
        param.white = white;
        save(savefilename,'frm','param'); % temp BA
    end
end


