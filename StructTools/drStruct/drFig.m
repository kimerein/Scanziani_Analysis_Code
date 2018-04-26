function drFig(dr,sdir,bSave)
%
%
%
%
%

% Created: SRO - 6/10/11

if nargin < 1 || isempty(dr)
    try
        dr = evalin('base','dr');
    catch
        error('Need to supply "dr" data struct')
    end
end

if nargin < 2 || isempty(sdir)
    sdir = 'S:\SRO DATA\Figures\DataFigures\Temp\';
end

if nargin < 3 || isempty(bSave)
    bSave = 0;
end

% Setup figure
[tmp expt_name] = fileparts(dr.fname);
hfig = landscapeFigSetup;
setappdata(hfig,'sdir',sdir);
setappdata(hfig,'figText',[expt_name '_Fig']);
hSaveFigTool = addSaveFigTool(gcf);
addText(hfig,expt_name);

% Plot mua contrast-response functions
ua = dr.ua;
for u = 1:length(ua)
    hcrf(u) = axes('Parent',hfig);
    c = ua(u).stim.values';
%     r = ua(u).fr.ledon(:,1);
%     rErr = ua(u).sem.ledon(:,1);
     r = ua(u).fr.norm(:,1);
    rErr = ua(u).sem.norm(:,1);
    hl = plotCrf(c,r,ua(u).crf.cfun{1},rErr,hcrf(u));
end

title(hcrf(1),'LGN'); title(hcrf(2),'V1');

% Plot PSTHs
clrs = {[0.1 0.1 0.1], [0.6 0.6 0.6], [0 0 1], [1 0 0], [1 0 1], [0 1 0]}; 
for u = 1:length(ua)
    hpsthC(u) = axes('Parent',hfig);
    psth = ua(u).psth;
    centers = psth.centers;
    d = psth.data;
    sem = psth.sem; 
    for n = 1:size(d,2)
        plotPsth2sem(d(:,n,1),sem(:,n,1),centers,hpsthC(u),grays(n));
    end
    ymax = setSameYmax(hpsthC(u),15);
    addStimulusBar(hpsthC(u),[ua(u).analysis.other.windows.stim ymax*0.97],'',[0 0 0],1.5);
    
    hpsthLed(u) = axes('Parent',hfig);
    for n = 1:size(d,3)
        plotPsth2sem(d(:,6,n),sem(:,6,n),centers,hpsthLed(u),clrs{n});
    end
    ymax = setSameYmax(hpsthLed(u),15);
    addStimulusBar(hpsthLed(u),[ua(u).analysis.other.windows.stim ymax*0.97],'',[0 0 0],1.5);
    addStimulusBar(hpsthLed(u),[ua(u).analysis.other.windows.ledon ymax*0.99],'',[0 0 1],1.5);
end

% Plot transfer function
htfcn = axes('Parent',hfig);
x = dr.lgn_m(:,1);
y = dr.v1_m(:,1);
% xErr = dr.ua(1).sem.ledon(:,1);
% yErr = dr.ua(2).sem.ledon(:,1);
xErr = dr.ua(1).sem.norm(:,1);
yErr = dr.ua(2).sem.norm(:,1);
plotCrf(x,y,dr.tfcn.cfun{1},yErr,htfcn);
addErrBar(x,y,xErr,'x',htfcn);
xlabel('LGN (spikes/s)'); ylabel('V1 (spikes/s)');
xlim([min(x)*0.9 max(x)*1.1])

x = dr.lgn_m(end,2:end);
y = dr.v1_m(end,2:end);
% xErr = dr.ua(1).sem.ledon(end,2:end);
% yErr = dr.ua(2).sem.ledon(end,2:end);
xErr = dr.ua(1).sem.norm(end,2:end);
yErr = dr.ua(2).sem.norm(end,2:end);

htmp = line('Parent',htfcn,'XData',x,'YData',y,'Color',[1 0.5 0],...
    'Marker','o','MarkerFaceColor',[1 0.5 0],'LineStyle','none');
addErrBar(x,y,xErr,'x',htfcn,htmp);
addErrBar(x,y,yErr,'y',htfcn,htmp);
title('Highest contrast + LED','Color',[1 0.5 0])
setSameYmax(htfcn,5);


% Plot measured vs predicted
v1_m = dr.v1_m(4:6,2:end);
v1_p = dr.v1_p(4:6,2:end);
hMvsP(1) = axes;
defaultAxes(gca)
grys = {[0.7 0.7 0.7],[0.4 0.4 0.4],[0 0 0]};
for i = 1:size(v1_m,1)  % Contrast
    line('Parent',hMvsP(1),'XData',v1_p(i,:),'YData',v1_m(i,:),...
        'Color',grys{i},'LineStyle','none','Marker','o','LineWidth',1.5 ...
        ); % 'MarkerFaceColor',colors(i)
end
setXYsameLimit(hMvsP(1));
addUnityLine(hMvsP(1));
title('color by contrast')
xlabel('V1 predicted (spikes/s)'); ylabel('V1 measured (spikes/s)');

hMvsP(2) = axes;
defaultAxes(gca)
clrs = {[0 0 1], [1 0 0], [1 0 1], [0 1 0]}; 
clrs = {[0.6 0.6 0.6], [0 0 1], [1 0 0], [1 0 1], [0 1 0]}; 
for i = 1:size(v1_m,2) % LED level
    line('Parent',hMvsP(2),'XData',v1_p(:,i),'YData',v1_m(:,i),...
        'Color',clrs{i},'LineStyle','none','Marker','o','LineWidth',1.5 ...
        );
end
setXYsameLimit(hMvsP(2));
addUnityLine(hMvsP(2));
title('color by LED')
xlabel('V1 predicted (spikes/s)'); ylabel('V1 measured (spikes/s)');

% Plot L6 efficacy of suppression on V1 vs LGN
hL6efficacy = axes;
defaultAxes(gca);
v1_range = ua(2).fr.ledon(end,1) - ua(2).fr.spont(end,1);
lgn_range = ua(1).fr.ledon(end,1) - ua(1).fr.spont(end,1);
v1_eff = dr.v1_comp_s(end,2:end)./v1_range;
tmp = -1*(ua(1).fr.ledon(end,2:end) - ua(1).fr.ledon(end,1));
lgn_eff = tmp./lgn_range;

line('Parent',hL6efficacy,'XData',lgn_eff,'YData',v1_eff,'Marker','o');
setXYsameLimit(hL6efficacy);
addUnityLine(hL6efficacy);
title('Highest contrast + LED');
xlabel('L6 suppression of LGN'); ylabel('L6 suppression of V1');


% Plot V1 component vs LED level
hV1Led = axes;
defaultAxes(gca)
v1_c = dr.v1_comp_f;
tmp = v1_c(4:end,2:end);
tmp(tmp > 1) = 1;
v1_c = mean(tmp,1);  % Use 3 highest contrasts and 4 highest LED
ledVal = cell2mat(ua(1).analysis.other.cond.values(2:end));
line('Parent',hV1Led,'XData',ledVal,'YData',v1_c,'Marker','o');
xlabel('LED (V)'); ylabel ('V1 component');
ylim([0 1]);
xlim([min(ledVal)*0.9 max(ledVal)*1.1])
title('Avg over top 3 contrasts')

% Plot V1 component vs contrast
hV1C = axes;
defaultAxes(gca)
v1_c = dr.v1_comp_f;
tmp = v1_c(4:end,2:end);
tmp(tmp > 1) = 1;
v1_c = mean(tmp,2);  % Use 3 highest contrasts and 4 highest LED
c = ua(1).stim.values(4:end)';
line('Parent',hV1C,'XData',c,'YData',v1_c,'Marker','o');
xlabel('contrast'); ylabel ('V1 component');
ylim([0 1]);
xlim([min(c)*0.9 max(c)*1.1])
title('Avg over top 4 LED levels')

% Format and arrange axes
hax = [hcrf htfcn hL6efficacy hpsthC hMvsP(1) hV1Led hpsthLed hMvsP(2) hV1C];
params.cellmargin = [0.045 0.045  0.075  0.075];
setaxesOnaxesmatrix(hax,3,4,1:length(hax),params);


% Save figure
if bSave
    pushSaveFigButton(hSaveFigTool);
end

set(hfig,'Visible','on')