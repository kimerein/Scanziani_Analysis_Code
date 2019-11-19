function RigDef = RigDefs()
%
% OUTPUT
%   RigDef: Struct containing rig specific information 

%%% --- Enter rig specific values in right column --- %%%
% Computer IP addresses
RigDef.DAQPC_IP                            = '132.239.203.12';
RigDef.StimPC_IP                           = '128.54.15.84';
RigDef.AnalysisPC_IP                       = '132.239.203.18';
% User equipment
RigDef.equipment.amp                       = 'A-M Systems 3500';
RigDef.equipment.adaptorName               = 'nidaq';   
RigDef.equipment.board.ID                  = 'PCIe-6259';
RigDef.equipment.board.numAnalogInputCh    = 32;
RigDef.equipment.board.device              = 'Dev1';
assert(RigDef.equipment.board.numAnalogInputCh > 1, 'Error: RigDef.equipment.board.numAnalogInputCh must be > 1.');

% User ID (e.g. SRO for Shawn R. Olsen)
RigDef.User.ID                             = 'KR';
% Directories
RigDef.Dir.CodeRoot                        = 'C:\Users\Kim\Documents\GitHub\Scanziani_Analysis_Code\';
% RigDef.Dir.Icons                           = [RigDef.Dir.CodeRoot, 'GuiTools\Icons\'];

% RigDef.Dir.Data                            = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Scanziani Boston computer more recent\My Book\New RawData\'; %'F:\RawData\'; 
RigDef.Dir.Data                            = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\From new server PART 2\New Acquisition Computer 2\'; %'F:\RawData\'; 
%'C:\Users\Public\Documents\RawData\';                       
RigDef.Dir.DataFilt                        = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\Filtered\'; 
RigDef.Dir.Analyzed                        = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\Analyzed\';
RigDef.Dir.Spikes                          = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\Analyzed\SortedSpikes\';
RigDef.Dir.Stimuli                         = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\Stimuli\';    
RigDef.Dir.Expt                            = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\Experiments\';   
RigDef.Dir.FigOnline                       = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\OnlineFigures\';  
RigDef.Dir.Settings                        = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\Settings\';  
%RigDef.Dir.VStimLog                        = '\\128.54.15.84\VStim\VStimLog\';
RigDef.Dir.VStimLog                        = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\From Stim Presentation Computer\';
% RigDef.Dir.VStimLog                        = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\From new server PART 1\Visual Stim Files\';
RigDef.Dir.Fig                             = '\\research.files.med.harvard.edu\neurobio\MICROSCOPE\Kim\FF_manuscript\Sabalab computer\MATLAB Expt Data\DataFigures\';

% RigDef.Dir.Data                            = 'E:\MATLAB\Data\RawData\';                       
% RigDef.Dir.DataFilt                        = 'E:\MATLAB\Data\RawData\Filtered\'; 
% RigDef.Dir.Analyzed                        = 'E:\MATLAB\Data\Analyzed\';
% RigDef.Dir.Spikes                          = 'E:\MATLAB\Data\Analyzed\SortedSpikes\';
% RigDef.Dir.Stimuli                         = 'E:\MATLAB\Data\Stimuli\';    
% RigDef.Dir.Expt                            = 'E:\MATLAB\Data\Experiments\';   
% RigDef.Dir.FigOnline                       = 'E:\MATLAB\Data\OnlineFigures\';  
% RigDef.Dir.Settings                        = 'E:\MATLAB\Settings\';  
% %RigDef.Dir.VStimLog                        = '\\128.54.15.84\vStimData\VStimLog\';
% RigDef.Dir.VStimLog                        = 'E:\MATLAB\Data\Stimuli\';
% RigDef.Dir.Fig                             = 'E:\MATLAB\Data\DataFigures\';

% Making sure all the directories exist: (goes after all dirs)
% (N.B. network drives that are not accessible may take a very long time)
directories = fieldnames(RigDef.Dir);
missing = '';
for idx = 1:length(directories)
    fldname      = directories{idx};
    dirToCheck   = getfield(RigDef.Dir, fldname);  
    if iscell(dirToCheck)
        dirToCheck = dirToCheck{1};
    end
    if(~exist(dirToCheck, 'dir'))
        missing = [missing , sprintf('\n'), dirToCheck];
    end
end
assert(isempty(missing), sprintf('Error: Some directories defined in RigDefs.m are missing:%s\nPlease ensure RigDefs.m is up-to-date.', missing));    
% End Directories

% Prefix for daq file save names
RigDef.SaveNamePrefix                      = [RigDef.User.ID '_'];            % Can enter your own string if you want.
% Defaults for DaqController GUI
RigDef.Daq.SweepLength                     = 2;                       % in seconds
RigDef.Daq.TriggerRepeat                   = 12;
RigDef.Daq.TriggerFcn                      = '@DataViewerCallback';     % Use '@DataViewerCallback' unless you've developed your own online plotting callback
RigDef.Daq.SamplesAcquiredFcn              = '@DataViewerSamplAcqCallback'; 
RigDef.Daq.TimerFcn                        = '';
RigDef.Daq.StopFcn                         = '';
RigDef.Daq.OnlinePlotting                  = 'DataViewer';              % Flag to generate DataViewer GUI
% RigDef.Daq.SampleRate                      = 32000;
RigDef.Daq.SampleRate                      = 25000;
RigDef.Daq.Position                        = [1178 838]; %[1478 958];                % Position of DaqController (2 element vector [left bottom] in pixels)
RigDef.Daq.TriggerChannel                  = 1;
RigDef.Daq.PhotodiodeChannel               = 5;
RigDef.Daq.LEDOnThresh                     = 0.7;
RigDef.Daq.DigitalInputs                   = 8:15;
RigDef.Daq.PhysiologyChannels              = 10:25; % Matlab index rather than hardware channel
RigDef.Daq.LEDChannel                      = 4; % Matlab index rather than hardware channel
RigDef.Daq.TimeBeforeStimOnset             = 0.5; % in seconds
RigDef.Daq.StimDuration                    = 3; % in seconds
RigDef.Daq.TimeBetweenStimOffsetAndNextTrial=1; % in seconds
% Defaults values for DataViewer GUI
RigDef.DataViewer.Position                 = [244 0 928 1000];          % Position of DataViewer ([left bottom width height] in pixels)
RigDef.DataViewer.AnalysisButtons          = 1;
RigDef.DataViewer.UsePeakfinder            = 1;                         % Default setting as to whether to use Peakfinder (1) or hard threshold (0) in detecting spikes for DAQ dataviewer
RigDef.DataViewer.ShowAllYAxes             = 1;                         % Default setting for whether to show all Y axes in DAQ dataviewer
RigDef.DataViewer.MaxChannels              = 32;
RigDef.ExptDataViewer.ShowAllYAxes         = 1;                         % Default setting for whether to show all Y axes in EXPT dataviewer
RigDef.ExptDataViewer.UsePeakfinder        = 1;                         % Default setting as to whether to use Peakfinder (1) or hard threshold (0) in detecting spikes for EXPT dataviewer
RigDef.ExptDataViewer.DefaultThreshold     = -0.06;                      % Default threshold 
RigDef.ExptDataViewer.Position             = [0 0 928 1000];
% Defaults for PlotChannel GUI
RigDef.PlotChooser.LPcutoff                = 200;                          
RigDef.PlotChooser.HPcutoff                = 200;
RigDef.PlotChooser.Position                = [0 0];                % Position of PlotChooser ([left bottom] in pixels)
% Defaults for ExptTable GUI
RigDef.ExptTable.Position                  = [0 0];        % Position of ExptTable  ([left bottom] in pixels)
RigDef.ExptTable.MarkPanel                 = 1;
RigDef.ExptTable.TimeStrings               = {'Begin @','Anesthesia @','Craniotomy @','Inserted probe @','Start recording @','End @'};
% Defaults for ExptViewer GUI
RigDef.ExptViewer.Position                 = [0 0 1100 1000];                 % Position of PlotChooser ([left bottom width height] in pixels)
% Defaults for Online Analysis Figures
RigDef.OnlineFR.Position                   = [187 0 172 1000];
RigDef.OnlineLFP.Position                  = [0 0 172 1000];
RigDef.OnlinePSTH.Position                 = [15 0 172 1000];
RigDef.OnlineLFP.DefaultWindow             = [0 1.9];
% Defaults for Offline Analysis Figures
RigDef.OfflineLandscape.Position           = [792 399 1056 724];
RigDef.OfflineLandscape.PlotBursts         = 0;
% Defaults for probe
RigDef.Probe.Default                       = '32 Channel 2x16';          % Probe list in PlotChannel:  '16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1', 'Glass electrode', 'Other'
RigDef.Probe.UserProbes                    = {'16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1', 'Glass electrode','32 Channel 2x16'};
% Defaults for channel order
RigDef.ChannelOrder                        = {[1 1 1 1 1 10 14 15 1 6 8 4 13 9 11 16 0 17]+1; ... % 2x2
                                              %[2 3 7 5 12 10 14 15 1 6 8 4 13 9 11 16 0 17]+1; ... % 2x2
                                              [23 15 22 14 19 11 20 12 17 9 16 8 18 10 21 13 1 2 3 4 5 6 7]; ...
                                              %[25 17 24 16 21 13 22 14 19 11 18 10 20 12 23 15 5 3 1 6 4 2 7 8 9]... % 1x16 % BAD, Used to be: [18 10 19 11 22 14 21 13 24 16 25 17 23 15 20 12 5 3 1 6 4 2 7 8 9]... % 1x16
                                              [3 6 2 1 4 5 8 7 10 9 12 13 16 15 11 14 0 17]+1; ... % 4x1
                                              [2 1 3];... % Glass electrode
%                                               [23 15 22 14 19 11 20 12 17 9 16 8 18 10 21 13 32 7 28 26 31 24 30 3 25 29 27 1 2 4 5 6]}; % 2x16 linear probes
                                              [23 15 22 14 19 11 20 12 17 9 16 8 18 10 21 13 32 7 28 26 31 24 30 5 25 29 27 1 2 4 3 6]}; % 2x16 linear probes
                                         %[10 9 11 8 14 5 13 6 16 3 17 2 15
                                         %4 12 7 1 22 20 17 23 18 19 21 24 25 26 27] ... % 1x16
                                          %[10 9 11 8 14 5 13 6 16 3 17 2
                                          %15 4 12 7 1 22 20] ... % 1x16
                                                                         %[9 8 10 7 13 4 12 5 15 2 16
                                              %1 14 3 11 6 0 17]+1 ... % 1x16 [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6 0 17]+1 ... % 1x16                           
% LED defaults
RigDef.led.Enable                          = 1;  % Enable (1), disable (0) Analog/LED GUI button
RigDef.led.ID                              = {'592 nm - 7317', '590 nm - XXXX', '440 nm - XXXX'};
RigDef.led.Offset                          = {0,0,0};
RigDef.led.HwChannel                       = {2,3,1};
RigDef.led.DCOffset                        = 0;
%RigDef.led.DetectLED                       = 1; % If equals 1, rather than trusting LEDCond.mat file for analysis, detect LED based on change in LED input channel

% Defaults SpikeSorting
RigDef.SS.label_categories = {'in process', 'good unit', 'unit missing spikes','FS good unit', 'dirty unit', 'multi-unit', 'FS multi-unit', 'axon', 'axon multi-unit', 'garbage'};
RigDef.SS.label_colors = [ .7 .7 .7; .3 .8 .3; .1 .1 .1; .3 .3 .8; .7 .5 .5; .6 .8 .6; .6 .6 .8; .4 .1 .1; .5 .2 .9; .5 .5 .5];
% (TO DO NEED TO CONVERT FROM normalized to pixels, not sure how to do this
% with 2 screensRigDef.SS.default_figure_size = [.05 .1 .9 .8]; 
                                          
% --- End of user-defined rig specific paramters --- %

% Get nidaq board name
if strcmp(RigDef.equipment.adaptorName,'nidaq') && strcmp(computer,'PCWIN32')
    temp = daqhwinfo('nidaq');
    RigDef.equipment.daqboard = temp.BoardNames{1};  % Assume you only have board installed
else
    RigDef.equipment.daqboard = 'PCIe-6259';
end

% Set DaqSetup parameters
fName = fullfile([RigDef.Dir.Settings 'DaqSetup\'],'DefaultDaqParameters.mat');
if isempty(dir(fName)) % make directory
    [junk pathname] = getFilename(fName);
    parentfolder(pathname,1);
    RigDef.Daq.Parameters = createDefaultDaqParameters(fName);   
else
    load(fName);
    RigDef.Daq.Parameters = Parameters;
end

% Set ExptTable parameters
fName = fullfile([RigDef.Dir.Settings 'ExptTable\'],'DefaultExptTable.mat');
if isempty(dir(fName)) % make directory
    [junk pathname] = getFilename(fName);
    parentfolder(pathname,1);
    RigDef.ExptTable.Parameters  = createDefaultExptTable(fName);    
else
    load(fName);
    RigDef.ExptTable.Parameters = ExptTable;
end


