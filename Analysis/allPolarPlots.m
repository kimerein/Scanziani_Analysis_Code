function allfr = allPolarPlots(expt,unitTag,fileInd,b)


if nargin < 4
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
end

% Rig defaults
rigdef = RigDefs;

% Set cond struct
cond = expt.analysis.orientation.cond;

% Set time window struct
w = expt.analysis.orientation.windows;

% Temporary color
if isempty(cond.color)
    cond.color = {[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0.3 0.3 0.3]};
end

% Get tetrode number and unit index from unit tag
loc = strfind(unitTag,'_');
trodeNum = str2num(unitTag(loc-1));
unitInd = str2num(unitTag(loc+1:end));

% Get spikes from trode number and unit index
spikes = loadvar(fullfile(rigdef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));

% Extract spikes for unit and files
spikes = filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);

% Get stimulus parameters
varparam = expt.stimulus(fileInd(1)).varparam(1);
stim.type = varparam.Name;
stim.values = expt.stimulus(fileInd(1)).params.oriValues;

for i = 1:length(stim.values)
    stim.code{i} = i;
end

% --- Compute average response as a function oriention
[allfr nallfr] = computeResponseVsStimulus(spikes,stim,cond,w);


