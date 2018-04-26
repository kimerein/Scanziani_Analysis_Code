function showClusterTuning(bChooseFile,bLed)
if ~exist('bChooseFile','var')||isempty(bChooseFile), bChooseFile = 0; end
RigDefs;
bMergeTool = 0;

% find handle of Split Tool
set(0,'Showhiddenhandles','on')

hSMT = findobj('-regexp','Name','Split Tool');
if isempty(hSMT) % look for Merge Tool
    hSMT = findobj('-regexp','Name','Merge Tool');
    bMergeTool = 1;
end
   
figdata = get(hSMT,'UserData');
if ~ bMergeTool% if Split Tool then  using the tempassigns from splittool
    figdata.spikes.assigns = figdata.tempassigns;
end

spikes = figdata.spikes;
selected_assigns = figdata.selected;
if isempty(selected_assigns), selected_assigns =  unique(spikes.assigns); selected_assigns  = selected_assigns(selected_assigns>0); end

      % find files with orientation varying
% assume the expt struc in the workspace is the one we are working on 
expt = evalin('base', 'expt'); 
% set(0,'Showhiddenhandles','on')
% hEV = findobj('-regexp','Name','ExptViewer');
set(0,'Showhiddenhandles','off')

% need to add ablity to change the file used for tuning
if ~isfield(expt.sort.defaults,'plotTuning_fileInd') || bChooseFile
    fileInd = expt.sort.trode(spikes.info.trodeInd).fileInds;
    selectedfileInd = GUI_listFilesVisualParams('exptStruct',expt,'fileInd',fileInd);
    expt.sort.defaults.plotTuning_fileInd = selectedfileInd;
    save( fullfile(RigDefaults.DirExpt,getFilename(expt.info.exptfile)),'expt'); % BA this seems like it should be changed to save at rig specific location
    evalin('base', sprintf('expt.sort.defaults.plotTuning_fileInd = [ %s ];',num2str(selectedfileInd))); 

else
    selectedfileInd = expt.sort.defaults.plotTuning_fileInd;
end
% save as defaults


% Update the fields added to spikes struct (outliers may have removed
% spikes) 
if ~isequal(size(spikes.assigns),size(spikes.stimcond))
spikes = spikesAddSweeps(spikes,expt,spikes.info.trodeInd);
spikes = spikesAddConds(spikes);  
end

tempspikes = filtspikes(spikes,0,'assigns',selected_assigns,'fileInd',selectedfileInd);

% plotSortTuning(expt,tempspikes,selectedfileInd);

if exist('bLed','var')
plotclusterTuning(expt,tempspikes,selectedfileInd,bLed);
else
plotclusterTuning(expt,tempspikes,selectedfileInd);
end
