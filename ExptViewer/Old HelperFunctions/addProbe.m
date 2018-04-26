function expt = addProbe(expt,ExptTable)
% function expt = addProbe(expt,ExptTable)
%
%
%
%

% Created: 7/15/10 - SRO (pulled out of makeExptSRO)


expt.probe.type = getFromExptTable(ExptTable,'Probe type');                        % 16 Channel, Glass, etc.
expt.probe.ID = getFromExptTable(ExptTable,'Probe ID');
expt.probe.usenum = str2num(getFromExptTable(ExptTable,'Probe use number'));
expt.probe.configuration = getFromExptTable(ExptTable,'Probe configuration');      % 1x16, 2x2, 4x1, 1x1 (glass,tungsten)
expt.probe.sitearea = getFromExptTable(ExptTable,'Electrode area');
expt.probe.xdistance = str2num(getFromExptTable(ExptTable,'Probe xdistance'));     % Read off of LN keypad
expt.probe.angle = str2num(getFromExptTable(ExptTable,'Probe angle'));             % Measured
expt.probe.tipdepth = [];              % Derived
expt.probe.sitedepth = [];             % Derived

% Compatibility with older ExptTable
if isempty(expt.probe.xdistance)
    expt.probe.xdistance = str2num(getFromExptTable(ExptTable,'Recording depth'));  
end

% Temporary for old files
if isnan(expt.probe.type)
    probeList = {'2x2','1x16','4x1'};
    [selection ok] = listdlg('ListString',probeList,'PromptString',...
        'Which probe was used?','ListSize',[160 160]);
    expt.probe.type = '16 Channel';
    expt.probe.configuration = probeList{selection};
end

if strcmp(expt.probe.type,'16 Channel')
    expt.probe.trode.names = {'T1','T2','T3','T4'};   % Name is user-defined
    expt.probe.numchannels = 16;
    expt.probe.numtrodes = 4;
    expt.probe.sitesPerTrode = 4;
elseif strcmp(expt.probe.type,'Glass electrode')
    expt.probe.trode.names = {'E1'};                  % Name is user-defined
    expt.probe.numchannels = 1;
    expt.probe.numtrodes = 1;
    expt.probe.sitesPerTrode = 1;
end

switch expt.probe.configuration
    case {'2x2','2 x 2'}
        if ~isTDTexpt(expt)
            expt.probe.channelorder = [2 3 7 5 12 10 14 15 1 6 8 4 13 9 11 16];
        else         % for TDT same but they are flipped in order already so
            expt.probe.channelorder = [1:16];
        end
    case {'1x16','1 x 16'}
        expt.probe.channelorder = [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];
    case {'4x1','4 x 1'}
        expt.probe.channelorder = [3 6 2 1 4 5 8 7 10 9 12 13 16 15 11 14];
    case {'1x1','1 x 1'} % Glass electrode
        expt.probe.channelorder = 1;
end

% Adds .tipdepth and .sitedepth
expt = computeSiteDepth(expt);              

% Define sites on each trode using channelorder.
sitesPerTrode = expt.probe.sitesPerTrode;
for i = 1:expt.probe.numtrodes
    channelorder = expt.probe.channelorder;
    channelInd = 1 + (i-1)*4;
    expt.probe.trode.sites{i} = channelorder(channelInd:channelInd+(sitesPerTrode-1));          
end


