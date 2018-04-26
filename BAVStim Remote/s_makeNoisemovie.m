% script to generate noise movies
% BA
close all
clear all
maxSpatFreqRANGE = [0.001 0.02 0.04 0.08 0.12 0.2]  ;        %% spatial frequency cutoff (cpd)

for maxSpatFreq = maxSpatFreqRANGE

    displayParam.imsize = 60;                %% size in pixels
    displayParam.framerate = 75;             %% Hz
    displayParam.imageMag=10;                 %% magnification that movie will be played at % BA changed from x8 (all movies made before 080309 have 8x)
    displayParam.screenWidthPix = 600;        %% Screen width in Pixels % BA changed from 640 as above
    displayParam.screenWidthCm = 40;         %% Width in cm
    displayParam.screenDistanceCm = 25;      %% Distance in cm



duration =1  ;            %% duration in minutes
maxSpatFreq = 0.04 ;        %% spatial frequency cutoff (cpd)
maxTempFreq = 35;          %% temporal frequency cutoff
contrastSigma =0.5;         %% one-sigma value for contrast

SAVEPATH = 'E:\Documents and Settings\Bassam\My Documents\Matlab toolboxes\VStimConfig\movies\';

% filename = sprintf('movie_spf%dcpd_%dHz_%ds_fr%dHz_HIGH05LOW015.mat',maxSpatFreq*1000,maxTempFreq,round(duration*60),displayParam.framerate);
filename = sprintf('movie_spf%dcpd_%dHz_%ds_fr%dHz_SineModulation.mat',maxSpatFreq*1000,maxTempFreq,round(duration*60),displayParam.framerate);

[ moviedata RANDSTATE]=generateNoise_xyt(maxSpatFreq,maxTempFreq,contrastSigma,duration,displayParam,[SAVEPATH 'movieparams\' filename(1:end-4)]);

% stimParm
stimParam.maxSpatFreq = maxSpatFreq;
stimParam.maxTempFreq = maxTempFreq;
stimParam.contrastSigma= contrastSigma;
stimParam.duration=   duration;
stimParam.RANDSTATE = RANDSTATE;

save([SAVEPATH filename], 'moviedata','stimParam','displayParam');
end