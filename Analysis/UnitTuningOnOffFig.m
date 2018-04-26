function UnitTuningOnOffFig(expt,unitTag)
%
% INPUTS
%   spikes:
%   expt:
%
% OUTPUTS
%
%   3/15/10 - SRO

% Get tetrode number and unit index from unit tag
loc = strfind(unitTag,'_');
tetNum = str2num(unitTag(loc-1));
unitInd = str2num(unitTag(loc+1:end));

% Get spikes from tetrode number and unit index
load(expt.sort.tetrode(tetNum).spikesfile)

% Extract spikes from unit specified by unitIndex
spikes = filtspikes(spikes,0,'assigns',unitInd);

% Temp -- Add hM4D field
% after = 288;     % 29_M1610
% after = 279;     % 
% after = 192;   % M2858
after = 1000;
spikes.hm4d = zeros(size(spikes.trials));
hm4dInd = spikes.trials > after;
spikes.hm4d(hm4dInd) = 2;
spikes.sweeps.hm4d(after:end) = 2;

% Get/set experiment parameters
numTrials = max(spikes.sweeps.trial);

% Get/set stimulus parameters
varparam = expt.stimulus(1).varparam.Values;       % To do: make more flexible
conditions = varparam;     
trialDuration = 3;
stimulusOn = 0.06;
stimulusDur = 2;
stimulusOff = 0.06 + stimulusDur;
StimWindow = [stimulusOn (stimulusOn+stimulusDur)];
StimWindow = [0.06 1];
OnWindow = [stimulusOn (stimulusOn + 0.750)];
OffWindow = [stimulusOff (stimulusOff + 0.750)];
OffWindow = [2.06 3];
SpontWindow = [0 (stimulusOn-0.01) (trialDuration-0.250) trialDuration];    % Temporary solution. Need to include blank stimulus to get spontaneous FR.
SpontWinSize = 0.25 + 0.1;  % Need to change
StimWinSize = diff(StimWindow);
OnWinSize = diff(OnWindow);
OffWinSize = diff(OffWindow);


% Make make spikes substruct for each condition
for i = 1:length(varparam)
    cspikes(i) = filtspikes(spikes,0,'stimcond',i);
end

% --- Set axes locations ([left bottom width height]) --- %
% Open default landscape figure
hFig = LandscapeFigSetup;
set(hFig,'Visible','off')

% Get paper size (inches)
PaperSize = get(hFig,'PaperSize');

% Set colors
green = [0 0.7 0];
red = [1 0 0];

% Set margins (normalized units)
leftMargin = 0.035;
rightMargin = 0.01;
topMargin = 0.05;
bottomMargin = 0.1;

% Set space between axes (normalized units)
xSpace = 0.03;
ySpace = 0.018;
interRowSpace = 0.02;

% Height of axes
rasterHeight = 0.17;
psthHeight = 0.1;

% Location of rasterplots (normalized units)
numRasters = length(cspikes);
rastersPerRow = ceil(numRasters/2);
rasterWidth = (1-leftMargin-rightMargin)/rastersPerRow - xSpace;
rasterWidth = repmat(rasterWidth,1,numRasters);
rasterHeight = repmat(rasterHeight,1,numRasters);
rasterLeft = zeros(size(rasterHeight));
currentLoc = leftMargin;
for i = 1:numRasters
    rasterLeft(i) = currentLoc;
    currentLoc = rasterLeft(i) + rasterWidth(i) + xSpace;
    if i == rastersPerRow
        currentLoc = leftMargin;
    end
end

rasterBottom(1:rastersPerRow) = 1 - rasterHeight(1) - topMargin;
rasterBottom(rastersPerRow+1:numRasters) = 1 - topMargin - 2*rasterHeight(1) - 2*ySpace - psthHeight;

% Location of PSTHs (normalized units)
psthWidth = rasterWidth;
psthLeft = rasterLeft;
psthBottom = rasterBottom - psthHeight - ySpace/6;
psthHeight = repmat(psthHeight,1,numRasters);

% Set the plots to display labels
rasterLabel = 7;
psthLabel = 7;

% Bottom axes parameters
axBottomHeight = (psthBottom(end) - 0.06 - 2*ySpace)/2;

% Waveform axes
wvL = leftMargin;
wvB = bottomMargin/2;
wvW = rasterWidth(1)/2;
wvH = axBottomHeight*0.75 - ySpace;
% Autocorrelation axes
acL= leftMargin;
acB = bottomMargin/2 + 2*ySpace + wvH;
acW = rasterWidth(1);
acH = axBottomHeight;
% Total spikes as a function of time
hSpkTimeL = rasterLeft(1);
hSpkTimeB = bottomMargin/2 + axBottomHeight + ySpace;
hSpkTimeW = rasterWidth(2);
hSpkTimeH = axBottomHeight*0.9;
% hSpkTimeL = rasterLeft(5);
% hSpkTimeB = hSpkTimeB;
% hSpkTimeW = rasterWidth(5);
% hSpkTimeH = axBottomHeight*0.9;
% Summary of spikes changes before and after hM4D
hSpkChL = rasterLeft(2);
hSpkChB = hSpkTimeB;
hSpkChW = rasterWidth(2);
hSpkChH = axBottomHeight;
% Response vs orientation
hOriL = rasterLeft(3)-ySpace/2;
hOriB = hSpkTimeB;
hOriW = rasterWidth(3);
hOriH = axBottomHeight*0.75;
% Normalized response vs orientation
hOriNL = rasterLeft(3)-ySpace/2;
hOriNB = wvB;
hOriNW = rasterWidth(3);
hOriNH = axBottomHeight*0.75;
% Polar plot
hPolL = rasterLeft(4);
hPolB = hSpkTimeB;
hPolW = rasterWidth(4);
hPolH = axBottomHeight;
% Normalized polar plot
hPolNL = rasterLeft(4);
hPolNB = wvB;
hPolNW = rasterWidth(4);
hPolNH = axBottomHeight;
% Selectivity summary
hSelL = rasterLeft(5);
hSelB = wvB;
hSelW = rasterWidth(5);
hSelH = axBottomHeight;
% Average spontaneous activity
ax1L = rasterLeft(2);
ax1B = hSpkTimeB;
ax1W = rasterWidth(2)/3;
ax1H = axBottomHeight*0.75;
% Average over stimulus activity
ax2L = rasterLeft(2)+rasterWidth(2)-rasterWidth(2)/3;
ax2B = hSpkTimeB;
ax2W = rasterWidth(2)/3;
ax2H = axBottomHeight*0.75;
% Average on activity
ax3L = rasterLeft(2);
ax3B = wvB;
ax3W = rasterWidth(2)/3;
ax3H = axBottomHeight*0.75;
% Average off activity
ax4L = rasterLeft(2)+rasterWidth(2)-rasterWidth(2)/3;
ax4B = wvB;
ax4W = rasterWidth(2)/3;
ax4H = axBottomHeight*0.75;
% Orientation selectivity as function of time
ax5L = rasterLeft(5);
ax5B = hSpkTimeB;
ax5W = rasterWidth(5);
ax5H = axBottomHeight*0.9;
% ax5L = rasterLeft(1);
% ax5B = bottomMargin/2 + axBottomHeight + ySpace;
% ax5W = rasterWidth(2);
% ax5H = axBottomHeight*0.9;
% Orientation selectivity before and after
ax6L = rasterLeft(5);
ax6B = wvB;
ax6W = rasterWidth(2)/3;
ax6H = axBottomHeight*0.75;
% Direction selectivity before and after
ax7L = rasterLeft(5)+rasterWidth(2)-rasterWidth(2)/3;
ax7B = wvB;
ax7W = rasterWidth(2)/3;
ax7H = axBottomHeight*0.75;
% Direction selectivity as function of time
ax8L = rasterLeft(6);
ax8B = hSpkTimeB;
ax8W = rasterWidth(5);
ax8H = axBottomHeight*0.9;


% Text location
hTextL = 0;
hTextB = 0;
hTextW = 1;
hTextH = bottomMargin*0.75;


% --- Make raster plot for each stimulus condition --- %
numPlots = length(cspikes);
rAxes = zeros(1,numPlots);
for i = 1:numPlots
    rAxes(i) = axes('Position',[rasterLeft(i) rasterBottom(i) rasterWidth(i) rasterHeight(i)]);
    [rAxes(i) hRaster] = raster(cspikes(i));
    RemoveAxesLabels(rAxes(i));
    
    % Set properties
    AddStimulusBar(rAxes(i),[StimWindow (max(cspikes(i).sweeps.trial)+5)]);
    title(num2str(conditions(i)));
    set(rAxes(i),'YLim',[0 (length((cspikes(i).sweeps.trial))+1)]);
end
AxesGray(rAxes);
set(rAxes,'YColor',[0.99 0.99 0.99],'XColor',[0.99 0.99 0.99]);


% --- Make PSTH --- %
pAxes = zeros(1,numPlots);
maxCounts = [];
for i = 1:numPlots
    pAxes(i) = axes('Position',[psthLeft(i) psthBottom(i) psthWidth(i) psthHeight(i)]);
        if ~isempty(cspikes(i).trials)
            [pAxes(i) hPsth counts] = psth(cspikes(i),100,3);
            % Grab max bin count across all PSTHs
            maxCounts = [maxCounts counts];
        end
        tempNumTrials = length(cspikes(i).sweeps.trial);
        response(1,i) = (sum(cspikes(i).spiketimes >= StimWindow(1) ...
            & cspikes(i).spiketimes <= StimWindow(2)))/StimWinSize/tempNumTrials;
        response(2,i) = (sum(cspikes(i).spiketimes >= OffWindow(1) ...
            & cspikes(i).spiketimes <= OffWindow(2)))/OffWinSize/tempNumTrials;
    if i~=7
        RemoveAxesLabels(pAxes(i));
    else
        DefaultAxes(pAxes(i));
        xlabel('seconds'); ylabel('spikes/s');
    end    
end
AxesGray(pAxes);
psthMax = max(maxCounts)+max(maxCounts)*0.2;
set(pAxes,'YLim',[0 psthMax]);
for i = 1:length(pAxes)
    AddStimulusBar(pAxes(i),[0.05 2.05 psthMax*0.95]);
    AddStimulusBar(pAxes(i),[StimWindow 0.9*psthMax],'',green);
    AddStimulusBar(pAxes(i),[OffWindow 0.9*psthMax],'',red);
end

% Compute preferred orienation and OSI
orientations = [expt.stimulus(1).varparam.Values];
for j = 1:2
    [OSIon(j) prefDir(j) DSI(j)] = OrientSelectivity(orientations,response(j,:));
end


% --- Response as a function of orientation --- %
orientations = [expt.stimulus(1).varparam.Values 360];
response(1,13) = response(1,1);
response(2,13) = response(2,1);
axOri = axes('Parent',hFig','Position',[hOriL hOriB hOriW hOriH]);
lOri(1) = line('Parent',axOri,'XData',orientations,'YData',response(1,:), ...
    'Color',green,'LineWidth',1.5);
lOri(2) = line('Parent',axOri,'XData',orientations,'YData',response(2,:), ...
    'Color',red,'LineWidth',1.5);
set(axOri,'XLim',[0 360],'YLim',[0 max(max(response))],'XTick',[0 180 360],'XTickLabel',{'0';'180';'360'});
AxesGray(axOri);
DefaultAxes(axOri);
ylabel('spikes/s');

% Normalized response as a function of orientation
axOriN = axes('Parent',hFig','Position',[hOriNL hOriNB hOriNW hOriNH]);
responseN(1,:) = response(1,:)/max(response(1,:));
responseN(2,:) = response(2,:)/max(response(2,:));
lOri(1) = line('Parent',axOriN,'XData',orientations,'YData',responseN(1,:), ...
    'Color',green,'LineWidth',1.5);
lOri(2) = line('Parent',axOriN,'XData',orientations,'YData',responseN(2,:), ...
    'Color',red,'LineWidth',1.5);
set(axOriN,'XLim',[0 360],'YLim',[0 max(max(responseN))],'XTick',[0 180 360],'XTickLabel',{'0';'180';'360'});
AxesGray(axOriN);
DefaultAxes(axOriN);
title(axOriN,'normalized','FontSize',7,'Color',[0.2 0.2 0.2])

% Polar plot
orientations(2,:) = orientations(1,:);
axPol = axes('Parent',hFig','Position',[hPolL hPolB hPolW hPolH]);
hpol = polar(axPol,(orientations*pi/180)',(0.97*response/max(max(response)))');
set(hpol(1),'Color',green);
set(hpol(2),'Color',red);
PolarDefault(axPol);
set(hpol,'LineWidth',1.5)

out1 = (orientations*pi/180)';
out2 = (0.97*response/max(max(response)))';

% Normalized polar plot
axPol = axes('Parent',hFig','Position',[hPolNL hPolNB hPolNW hPolNH]);
hpol = polar(axPol,(orientations*pi/180)',(0.97*responseN)');
set(hpol(1),'Color',green);
set(hpol(2),'Color',red);
PolarDefault(axPol);
set(hpol,'LineWidth',1.5)




% --- Text annotation --- %
ind = findstr(expt.name,'_');
ann = [expt.name((max(ind)+1):end) ' ' unitTag];
hText = annotation('textbox',[hTextL hTextB hTextW hTextH],'String',...
    ann,'EdgeColor','none','HorizontalAlignment','right','Interpreter','none', ...
    'Color',[0.2 0.2 0.2]);

% --- Finish --- %

% Make figure visible
set(hFig,'Visible','on')
SaveName = ['C:\SRO DATA\Data\Experiments\Images\' expt.name((max(ind)+1):end) unitTag 'OnOff']
saveas(hFig,SaveName,'pdf')
pause(1)
print(hFig)
pause(1)
close(hFig)

% %  Print figure
% if 1
%     print(hFig)
%     pause(1)
%     SaveName = ['C:\SRO DATA\Data\Experiments\Images\' expt.name((max(ind)+1):end) unitTag]
%     saveas(hFig,SaveName,'pdf')
%     close(hFig)
% end


