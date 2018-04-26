function [mspikes expt] = make16ChSpikes(expt)

% Rig defaults
rigdef = RigDefs;

% Set parameters for layer field
layer_depth = {[0 300] [300 550] [500 800] [700 1000]};
layer_tag = [2 4 5 6];

% Make multi-dimensional spikes object
mspikes = struct;
for i = 1:length(expt.sort.trode)
    fName = [rigdef.Dir.Spikes expt.sort.trode(i).spikesfile];
    s = loadvar(fName);
    
    % Compute depth for each unit
    unit = expt.sort.trode(i).unit;
    for j = 1:length(unit)
        assign = unit(j).assign;
        tempspikes = filtspikes(s,0,'assigns',assign);
        [avgwave unit(j).maxchannel] = computeAvgWaveform(tempspikes.waveforms);
        unit(j).depth = round(getUnitDepth(expt,[expt.sort.trode(i).name '_' num2str(assign)],unit(j).maxchannel));
    end
    expt.sort.trode(i).unit = unit;
    
    % Add layer field to spikes (2,4,5,6,10(FS))
    s.depth = zeros(size(s.spiketimes));
    s.layer = zeros(size(s.spiketimes));
    
    for j = 1:length(unit)
        assign = unit(j).assign;
        label = unit(j).label;
        temp = s.assigns == assign;
        s.depth(temp) = unit(j).depth;
%         if any(strcmp(label,{'FS good unit','FS multi-unit'}))
%             s.layer(temp) = 10; %FS
%         end
    end
    
    for j = 1:length(layer_depth)
        tempdepth = layer_depth{j};
        temp = (s.depth >= tempdepth(1)) & (s.depth <= tempdepth(2)) & (s.layer ~= 10);
        s.layer(temp) = layer_tag(j);   
    end
    
    if ~isempty(mspikes)
        % Add fields to s, if not present
        mspikesFields = fieldnames(mspikes);
        for f = 1:length(mspikesFields)
            if ~isfield(s,mspikesFields{f})
                s.(mspikesFields{f}) = [];
            end
        end
        % Add fields to mspikes, if not present
           sFields = fieldnames(s);
        for f = 1:length(sFields)
            if ~isfield(mspikes,sFields{f})
                mspikes.(sFields{f}) = [];
            end
        end
    end
   
    
    mspikes(i) = s;
end

% Store sweeps for adding later
sweeps = mspikes(1).sweeps;         % All .sweeps should be the same (TO DO: Check for this)

for i = 1:length(mspikes)
    % Make site field. Each spike is assigned to the site in which the spike
    % was largest
    temp_mspikes(i) = addSpikeSite(mspikes(i),expt);
end
mspikes = temp_mspikes;

% Remove unnecessary fields
dur = mspikes(1).info.detect.dur(1);
rm = {'params','info','waveforms','sweeps','unwrapped_times','assigns','labels'};
mspikes = rmfield(mspikes,rm);

% Fuse spikes objects together
mspikes = fuseSpikes(mspikes);

% Add sweeps struct
mspikes.sweeps = sweeps;

% Add duration
mspikes.info.detect.dur = dur;

% Store file name in expt struct
expt.analysis.mua.spikesfile = [expt.name '_All_Ch_spikes'];

% Store file name in mspikes
mspikes.info.spikesfile = expt.analysis.mua.spikesfile;

% Save mspikes
fName = [rigdef.Dir.Spikes  expt.analysis.mua.spikesfile];
save(fName,'mspikes')

