function [concatSpikes, concatNames]=concatSpikes_fromSameFiles(expt, units_names, fileInd)

% Combine spikes structs from ...
%      - same expt.
%      - same set of daq files
%      - different units, possibly recorded on different trodes
%
% expt          the expt struct specifying the experiment in which all these
%               units were recorded
% units_names   a cell array of strings specifying the trodes and assigns
%               of the selected units' spikes to concatenate
% fileInd       the daq file indices to include in concatSpikes
%               if fileInd is [], all daq files will be included

RigDef=RigDefs();

currTrode=0;
trodeInd=0;
trodeList=[];
assignsOnEachTrode={};
spikesOfEachTrode={};
for i=1:length(units_names)
    [trodeNum unitAssign]=readUnitTag(units_names{i});
    if trodeNum~=currTrode
        currTrode=trodeNum;
        trodeList=[trodeList; currTrode];
        trodeInd=trodeInd+1;
        assignsOnEachTrode{trodeInd}=[];
        assignsOnEachTrode{trodeInd}=[assignsOnEachTrode{trodeInd} unitAssign];
        spikesOfEachTrode{trodeInd}=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
    else
        assignsOnEachTrode{trodeInd}=[assignsOnEachTrode{trodeInd} unitAssign];
    end
end

allSpikes={};
for i=1:length(spikesOfEachTrode)
    if isempty(fileInd)
        allSpikes{i}=filtspikes(spikesOfEachTrode{i},0,'assigns',assignsOnEachTrode{i});
    else
        allSpikes{i}=filtspikes(spikesOfEachTrode{i},0,'assigns',assignsOnEachTrode{i},'fileInd',fileInd);
    end
end

concatNames='';
for i=1:length(trodeList)
    concatNames=strcat(concatNames,'T',num2str(trodeList(i)),'_');
    assignsList=assignsOnEachTrode{i};
    for j=1:length(assignsList)
        if j==length(assignsList) && i==length(trodeList)
            concatNames=strcat(concatNames,num2str(assignsList(j)));
        elseif j==length(assignsList)
            concatNames=strcat(concatNames,num2str(assignsList(j)),'_');
        else
            concatNames=strcat(concatNames,num2str(assignsList(j)),'&');
        end
    end
end

fields=fieldnames(allSpikes{1}); 
concatSpikes=allSpikes{1};
for i=2:length(allSpikes)
    nfields=length(fieldnames(allSpikes{2}));
    if length(fields)~=nfields % should all have the same fields
        disp('The spikes structs you are trying to concatenate should all have the same fields!');
        concatSpikes=[];
        return
    end
    for j=1:length(fields)
        if isstruct(allSpikes{i}.(fields{j}))
            insideFields=fieldnames(allSpikes{i}.(fields{j}));
            for k=1:length(insideFields)
                concatSpikes.(fields{j}).(insideFields{k})={concatSpikes.(fields{j}).(insideFields{k}) allSpikes{i}.(fields{j}).(insideFields{k})};
            end
        else
            if size(allSpikes{i}.(fields{j}),1)>1
                concatSpikes.(fields{j})=[concatSpikes.(fields{j}); allSpikes{i}.(fields{j})];
            else
                concatSpikes.(fields{j})=[concatSpikes.(fields{j}) allSpikes{i}.(fields{j})];
            end
        end
    end
end


