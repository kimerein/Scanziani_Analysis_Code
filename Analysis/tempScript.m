function tempScript(expt,mSpikes,twindow)



chOrder = expt.info.probe.channelorder;

tic
% Make spikes substruct for each channel
parfor i = 1:length(chOrder)
    chSpikes(i) = filtspikes(mSpikes,0,'site',chOrder(i));
    chSpikes(i).info.trodesite = chOrder(i);
end
toc

tic
% Compute firing rate in window for every trial
parfor i = 1:length(chSpikes)
    frPerTrial(:,i) = computeSpikesPerTrial(chSpikes(i),twindow);
end
disp('fr loop')
toc

% Correlation coefficients
figure
R = corrcoef(frPerTrial);
imagesc(R,[0 1]);

% PSTHs
figure
numCh = length(chSpikes);
for i = 1:length(chSpikes)
    
    axs(i) = axes;
    h(i) = psth(chSpikes(i),25,axs(i));
end

assignin('base','axs',axs);
removeAxesLabels(axs);
params.cellmargin = [0 0 0.005 0.005];
setaxesOnaxesmatrix(axs,numCh,1,1:numCh,params);


% Plot spikes per trial on one site vs all others
hf = figure('Position',[243          53        1494        1056],'Visible','off');
numChSpikes = length(chSpikes);
for m = 3:13
    for n = 3:13
        i = sub2ind([11 11],m-2,n-2);
        hrax(i) = axes;
        l(i) = line(frPerTrial(:,m),frPerTrial(:,n),'Marker','.','LineStyle','none');
    end
end

assignin('base','hrax',hrax);
removeAxesLabels(hrax);
params.cellmargin = [0 0 0.005 0.005];
setaxesOnaxesmatrix(hrax,11,11,1:121,params);

% % defaultAxes(h);
% axis(h,'tight');

set(hf,'Visible','on')

% Plot contrast-response functions
figure(11)
for i = 1:3
    contrastCode(:,i) = i:3:36;
end

fileInd = 8:18;
contrastVal = expt.stimulus(10).varparam(2).Values;
twindow = [0.3 1.6];
for i = 1:length(chSpikes)
    
    for k = 1:size(contrastCode,2)
        tempspikes = filtspikes(chSpikes(i),0,'fileInd',fileInd,'stimcond',contrastCode(:,k));
        cResponse(i,k) = computeFR(tempspikes,twindow);
        spont(i,k) = computeFR(tempspikes,[0 0.25]);
    end
    
    
    
end

cResponse = cResponse - spont;
temp = max(cResponse'); temp = temp';
temp = repmat(temp,1,3);
cResponse = cResponse./temp;

for i = 1:length(chSpikes)
    crax(i) = axes('XScale','log','XTick',contrastVal,'XLim',[0.15 1.1],'YLim',[0 1]);
    crl(i) = line('XData',contrastVal,'YData',cResponse(i,:),'Marker','o');
end

assignin('base','crax',crax);
removeAxesLabels(crax);
params.cellmargin = [0 0 0.01 0.01];
params.matmargin = [0.2 0.2 0.02 0.02];
setaxesOnaxesmatrix(crax,numCh,1,1:numCh,params);






% --- Subfunctions --- %

function frPerTrial = computeSpikesPerTrial(spikes,twindow)

% Compute window size (sec)
winsize = diff(twindow);

parfor i = 1:length(spikes.sweeps.trials)
    tempSpikes = filtspikes(spikes,0,'trials',i);
    frPerTrial(i) = sum(tempSpikes.spiketimes >= twindow(1) & ...
        tempSpikes.spiketimes <= twindow(2))/winsize;
end










