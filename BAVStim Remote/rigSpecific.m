

PSC_moviedirpath = 'C:\CODE Visual Stimulation\Movies\';
PSC_paramdirpath = 'C:\CODE Visual Stimulation\VStimConfig\';
PSC_logdirpath = 'C:\CODE Visual Stimulation\VStimLog\';
PSC_DAQ_PC_IP = '132.239.203.99'; %SRO

PSC_REMOTECONTROL_REMOTEPC_IP = '132.239.203.99'; %SRO
PSC_REMOTECONTROL_REMOTEPC_PORT = '3458'; %BA
PSC_REMOTECONTROL_LOCALPC_PORT = '3458'; %BA

% Default screen setup (must specify all 3 fields if VSTIM_RES is defined)
VSTIM_RES.screennum = 2;
VSTIM_RES.width = 800;
VSTIM_RES.height = 600;
VSTIM_RES.hz = 60;

% Gamma calibration
% if none set to empty. this will use flat look-up table
PSC_GAMMATABLE = '';

parentfolder(PSC_moviedirpath,1);
parentfolder(PSC_paramdirpath,1);
parentfolder(PSC_logdirpath,1);

% defaults
if ~exist('VSTIM_RES','var'); VSTIM_RES.width = 800; VSTIM_RES.height = 600;  VSTIM_RES.hz = 60; end
