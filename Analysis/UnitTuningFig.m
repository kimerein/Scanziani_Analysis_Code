function UnitTuningFig(expt,unitTag)
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
spikes.sweeps.trials = spikes.sweeps.trial;


% Extract spikes from unit specified by unitIndex
spikes = filtspikes(spikes,0,'assigns',unitInd);

% Temp -- Add hM4D field
after = 288;     % 29_M1610
after = 279;     % 
% after = 192;   % M2858
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
OnWindow = [stimulusOn (stimulusOn + 0.750)];
OffWindow = [stimulusOff (stimulusOff + 0.750)];
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
    [rAxes(i) hRaster(i)] = raster(cspikes(i));
%     if ~(i == rasterLabel)
%         RemoveAxesLabels(rAxes(i));
%     end
    
    % Color trials according to hM4D
%     hm4dTrials = cspikes(i).hm4d > 0;
%     hRaster = hRaster(hm4dTrials);
%     set(hRaster,'Color',[0 0.7 0]);           % Green
    %     set(hRaster,'Color',[1 0 1]);       % Red
    
    % Set properties
    %     axis off
    AddStimulusBar(rAxes(i),[StimWindow (max(cspikes(i).sweeps.trial)+5)]);
    title(num2str(conditions(i)));
    set(rAxes(i),'YLim',[0 (length((cspikes(i).sweeps.trial))+1)]);
end
AxesGray(rAxes);
set(rAxes,'YColor',[0.99 0.99 0.99],'XColor',[0.99 0.99 0.99]);
% set(rAxes,'Visible','off');


% --- Make PSTH --- %
pAxes = zeros(1,numPlots);
maxCounts = [];
for i = 1:numPlots
    pAxes(i) = axes('Position',[psthLeft(i) psthBottom(i) psthWidth(i) psthHeight(i)]);
    for j = 1:2
        k = [0 2];   % hM4D condition code (0 = before, 2 = after)
        k = k(j);
        if k == 0
            Trials = [1 after];
        else
            Trials = [after+96 numTrials];
        end
        tempSpikes = filtspikes(cspikes(i),0,'trials',Trials);
        if ~isempty(tempSpikes.trials)
            [pAxes(i) hPsth counts] = psth(tempSpikes,100,3);
            % Grab max bin count across all PSTHs
            maxCounts = [maxCounts counts];
            if k == 2
                set(hPsth,'Color',[0 0.7 0]);     % Green
                %             set(hPsth,'Color',[1 0 0]);     % Red
            end
        end
        tempNumTrials = sum(tempSpikes.sweeps.trial >= Trials(1) & tempSpikes.sweeps.trial <= Trials(2));
        response(j,i) = (sum(tempSpikes.spiketimes >= StimWindow(1) ...
            & tempSpikes.spiketimes <= StimWindow(2)))/StimWinSize/tempNumTrials;
    end
    if i~=7
        RemoveAxesLabels(pAxes(i));
    else
        DefaultAxes(pAxes(i));
        xlabel('seconds'); ylabel('spikes/s');
    end    
end
AxesGray(pAxes);
psthMax = max(maxCounts)+max(maxCounts)*0.05;
set(pAxes,'YLim',[0 psthMax]);
for i = 1:length(pAxes)
    AddStimulusBar(pAxes(i),[StimWindow psthMax]);
end
% Compute preferred orienation and OSI
orientations = [expt.stimulus(1).varparam.Values];
for j = 1:2
    [OSI(j) prefDir(j) DSI(j)] = OrientSelectivity(orientations,response(j,:));
end


% --- Compute number of spikes as a function of sweep --- %
numTrials = length(spikes.sweeps.trial);
spikesPerSweep = zeros(size(numTrials));
for i = 1:length(spikes.sweeps.trial)
    spikesPerSweep(i) = length(find(spikes.trials == i));
  
end

% Make axis and insert data
spikesPerSweep = smooth(spikesPerSweep,7);
hSpkAx = axes('Parent',hFig,'Position',[hSpkTimeL hSpkTimeB hSpkTimeW hSpkTimeH]);
hSpkPer = line('Parent',hSpkAx,'XData',spikes.sweeps.trial*5/60,'YData',spikesPerSweep, ...
    'Marker','none','Color',[0.2 0.2 0.2],'MarkerSize',3);
% Set axes properties
AxesGray(hSpkAx);
DefaultAxes(hSpkAx);
xlabel('minutes'); ylabel('spikes/trial');
set(hSpkAx,'XLim',[0 numTrials*5/60],'YLim',[0 max(spikesPerSweep)]);
yBarPos = get(hSpkAx,'YLim');
AddStimulusBar(hSpkAx,[after*5/60 numTrials*5/60 yBarPos(2)],'CNO');


% --- Compute average spike waveform ---%

% Generate average waveform
avgWaveform = squeeze(mean(spikes.waveforms,1));
temp = [];
for i = 1:size(avgWaveform,2)
    temp = [temp; avgWaveform(:,i)];
end
avgWaveform = temp;
axwf = axes('Parent',hFig,'Position',[wvL wvB wvW wvH]);
hlwf = line('XData',1:length(avgWaveform),'YData',avgWaveform,'Color',[0.2 0.2 0.2]);
axis tight off

% --- Compute average firing rate before and after CNO ---%

% Set window sizes
SpontWinSize = 0.25 + 0.1;  % Need to change
StimWinSize = diff(StimWindow);
OnWinSize = diff(OnWindow);
OffWinSize = diff(OffWindow);

% Set before and after CNO trials
bTrials = [1 after];
aTrials = [after+96 numTrials];

% Make before and after spikes structs
bspikes = filtspikes(spikes,0,'trials',bTrials);
aspikes = filtspikes(spikes,0,'trials',aTrials);

% Spontaneous activity
bnumSpikes = (sum((bspikes.spiketimes >= SpontWindow(1) & bspikes.spiketimes <= SpontWindow(2)) ...
    | (bspikes.spiketimes >= SpontWindow(3) & bspikes.spiketimes <= SpontWindow(4))))/SpontWinSize/(diff(bTrials)+1);
anumSpikes = (sum((aspikes.spiketimes >= SpontWindow(1) & aspikes.spiketimes <= SpontWindow(2)) ...
    | (aspikes.spiketimes >= SpontWindow(3) & aspikes.spiketimes <= SpontWindow(4))))/SpontWinSize/(diff(aTrials)+1);

ax1 = axes('Parent',hFig,'Position',[ax1L ax1B ax1W ax1H]);
Default2PtAx(ax1,{'' 'CNO'},'');
b1 = line2pt(ax1,[bnumSpikes anumSpikes]);
set(ax1,'XLim',[0.5 2.5]);
AxesGray(ax1);
DefaultAxes(ax1);
title(ax1,'spontaneous','FontSize',7,'Color',[0.2 0.2 0.2])

% Over 2 sec
bnumSpikes = (sum(bspikes.spiketimes >= StimWindow(1) & bspikes.spiketimes <= StimWindow(2)))/StimWinSize/(diff(bTrials)+1);
anumSpikes = (sum(aspikes.spiketimes >= StimWindow(1) & aspikes.spiketimes <= StimWindow(2)))/StimWinSize/(diff(aTrials)+1);

ax2 = axes('Parent',hFig,'Position',[ax2L ax2B ax2W ax2H]);
Default2PtAx(ax2,{'' 'CNO'},'');
b2 = line2pt(ax2,[bnumSpikes anumSpikes]);
set(ax2,'XLim',[0.5 2.5]);
AxesGray(ax2);
DefaultAxes(ax2);
title(ax2,'stimulus','FontSize',7,'Color',[0.2 0.2 0.2])

% Early response
bnumSpikes = (sum(bspikes.spiketimes >= OnWindow(1) & bspikes.spiketimes <= OnWindow(2)))/OnWinSize/(diff(bTrials)+1);
anumSpikes = (sum(aspikes.spiketimes >= OnWindow(1) & aspikes.spiketimes <= OnWindow(2)))/OnWinSize/(diff(aTrials)+1);

ax3 = axes('Parent',hFig,'Position',[ax3L ax3B ax3W ax3H]);
Default2PtAx(ax3,{'' 'CNO'},'');
b3 = line2pt(ax3,[bnumSpikes anumSpikes]);
set(ax3,'XLim',[0.5 2.5]);
ylabel('spikes/s');
AxesGray(ax3);
DefaultAxes(ax3);
set(get(ax3,'YLabel'),'Units','normalized','Position',[-0.4 0.5 1]);
title(ax3,'early','FontSize',7,'Color',[0.2 0.2 0.2])

% Off response
bnumSpikes = (sum(bspikes.spiketimes >= OffWindow(1) & bspikes.spiketimes <= OffWindow(2)))/OffWinSize/(diff(bTrials)+1);
anumSpikes = (sum(aspikes.spiketimes >= OffWindow(1) & aspikes.spiketimes <= OffWindow(2)))/OffWinSize/(diff(aTrials)+1);

ax4 = axes('Parent',hFig,'Position',[ax4L ax4B ax4W ax4H]);
Default2PtAx(ax4,{'' 'CNO'},'');
b4 = line2pt(ax4,[bnumSpikes anumSpikes]);
set(ax4,'XLim',[0.5 2.5]);
AxesGray(ax4);
DefaultAxes(ax4);
title(ax4,'off','FontSize',7,'Color',[0.2 0.2 0.2])

% --- Response as a function of orientation --- %
orientations = [expt.stimulus(1).varparam.Values 360];
response(1,13) = response(1,1);
response(2,13) = response(2,1);
axOri = axes('Parent',hFig','Position',[hOriL hOriB hOriW hOriH]);
lOri(1) = line('Parent',axOri,'XData',orientations,'YData',response(1,:), ...
    'Color',[0 0 1],'LineWidth',1.5);
lOri(2) = line('Parent',axOri,'XData',orientations,'YData',response(2,:), ...
    'Color',[0 0.7 0],'LineWidth',1.5);
set(axOri,'XLim',[0 360],'YLim',[0 max(max(response))],'XTick',[0 180 360],'XTickLabel',{'0';'180';'360'});
AxesGray(axOri);
DefaultAxes(axOri);

% Normalized response as a function of orientation
axOriN = axes('Parent',hFig','Position',[hOriNL hOriNB hOriNW hOriNH]);
responseN(1,:) = response(1,:)/max(response(1,:));
responseN(2,:) = response(2,:)/max(response(2,:));
lOri(1) = line('Parent',axOriN,'XData',orientations,'YData',responseN(1,:), ...
    'Color',[0 0 1],'LineWidth',1.5);
lOri(2) = line('Parent',axOriN,'XData',orientations,'YData',responseN(2,:), ...
    'Color',[0 0.7 0],'LineWidth',1.5);
set(axOriN,'XLim',[0 360],'YLim',[0 max(max(responseN))],'XTick',[0 180 360],'XTickLabel',{'0';'180';'360'});
AxesGray(axOriN);
DefaultAxes(axOriN);
title(axOriN,'normalized','FontSize',7,'Color',[0.2 0.2 0.2])

% Polar plot
orientations(2,:) = orientations(1,:);
axPol = axes('Parent',hFig','Position',[hPolL hPolB hPolW hPolH]);
hpol = polar(axPol,(orientations*pi/180)',(0.97*response/max(max(response)))');
PolarDefault(axPol);
set(hpol,'LineWidth',1.5)

out1 = (orientations*pi/180)';
out2 = (0.97*response/max(max(response)))';

% Normalized polar plot
axPol = axes('Parent',hFig','Position',[hPolNL hPolNB hPolNW hPolNH]);
hpol = polar(axPol,(orientations*pi/180)',(0.97*responseN)');
PolarDefault(axPol);
set(hpol,'LineWidth',1.5)


% Orientation selectivity as a function of time
orientations = orientations(1,1:12);
avgWindow = 60;
lastTrigger = max(spikes.sweeps.trial);
% Loop on different stimulus conditions
for i = 1:length(cspikes)
    % Loop on different trigger windows
    allWindows = floor(linspace(1,lastTrigger-avgWindow,30));
    for j = 1:length(allWindows)
        Trials = [allWindows(j) (allWindows(j)+avgWindow-1)];
        tempSpikes = filtspikes(cspikes(i),0,'trials',Trials);
        tempNumTrials = sum(tempSpikes.sweeps.trial >= Trials(1) & tempSpikes.sweeps.trial <= Trials(2));
        respFtime(j,i) = (sum(tempSpikes.spiketimes >= StimWindow(1) ...
            & tempSpikes.spiketimes <= StimWindow(2)))/StimWinSize/tempNumTrials;
    end
end

for i = 1:size(respFtime,1)
    [OriSelect(i) temp DirSelect(i)] = OrientSelectivity(orientations,respFtime(i,:),prefDir(2));
end

% Make axis and insert data
xData = (allWindows + avgWindow/2)*5/60;            % 
ax5 = axes('Parent',hFig,'Position',[ax5L ax5B ax5W ax5H]);
hOriTime = line('Parent',ax5,'XData',xData,'YData',OriSelect, ...
    'Marker','none','Color',[0.3 0.3 0.3],'MarkerSize',3);
% Set axes properties
AxesGray(ax5);
DefaultAxes(ax5);
xlabel('minutes'); ylabel('OSI');
set(ax5,'XLim',[0 numTrials*5/60],'YLim',[0 1]);
yBarPos = get(ax5,'YLim');
AddStimulusBar(ax5,[after*5/60 numTrials*5/60 yBarPos(2)],'CNO');

% % Direction selectivity as a function of time
% % Make axis and insert data
% xData = (allWindows + avgWindow/2)*5/60;            % 
% ax8 = axes('Parent',hFig,'Position',[ax8L ax8B ax8W ax8H]);
% hDirTime = line('Parent',ax8,'XData',xData,'YData',DirSelect, ...
%     'Marker','none','Color',[0.3 0.3 0.3],'MarkerSize',3);
% % Set axes properties
% AxesGray(ax8);
% DefaultAxes(ax8);
% xlabel('minutes'); ylabel('DSI');
% set(ax8,'XLim',[0 numTrials*5/60],'YLim',[0 1]);
% yBarPos = get(ax8,'YLim');
% AddStimulusBar(ax8,[after*5/60 numTrials*5/60 yBarPos(2)],'CNO');

% Average OSI before and after
ax6 = axes('Parent',hFig,'Position',[ax6L ax6B ax6W ax6H]);
Default2PtAx(ax6,{'' 'CNO'},'');
b6 = line2pt(ax6,OSI);
set(ax6,'XLim',[0.5 2.5],'YLim',[0 1]);
AxesGray(ax6);
DefaultAxes(ax6);
title(ax6,'OSI','FontSize',7,'Color',[0.2 0.2 0.2])

% % Average DSI before and after
% ax7 = axes('Parent',hFig,'Position',[ax7L ax7B ax7W ax7H]);
% Default2PtAx(ax7,{'' 'CNO'},'');
% b7 = line2pt(ax7,DSI);
% set(ax7,'XLim',[0.5 2.5],'YLim',[0 1]);
% AxesGray(ax7);
% DefaultAxes(ax7);
% % title(ax7,'DSI','FontSize',7,'Color',[0.2 0.2 0.2])




% --- Text annotation --- %
ind = findstr(expt.name,'_');
ann = [expt.name((max(ind)+1):end) ' ' unitTag];
hText = annotation('textbox',[hTextL hTextB hTextW hTextH],'String',...
    ann,'EdgeColor','none','HorizontalAlignment','right','Interpreter','none', ...
    'Color',[0.2 0.2 0.2]);

% --- Finish --- %

% Make figure visible
set(hFig,'Visible','on')
pause
close(hFig)
% SaveName = ['C:\SRO DATA\Data\Experiments\Images\' expt.name((max(ind)+1):end) unitTag]
% saveas(hFig,SaveName,'pdf')

% %  Print figure
% if 1
%     print(hFig)
%     pause(1)
%     SaveName = ['C:\SRO DATA\Data\Experiments\Images\' expt.name((max(ind)+1):end) unitTag]
%     saveas(hFig,SaveName,'pdf')
%     close(hFig)
% end


