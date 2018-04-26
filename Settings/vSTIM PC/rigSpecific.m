

PSC_moviedirpath = 'C:\SRO DATA\vStim Data\Movies\';
PSC_paramdirpath = 'C:\SRO DATA\vStim Data\vStimConfig\vStimController\';
PSC_logdirpath = 'C:\SRO DATA\vStim Data\vStimLog\';
PSC_DAQ_PC_IP = '132.239.203.99'; %SRO

PSC_REMOTECONTROL_REMOTEPC_IP = '132.239.203.99'; %SRO
PSC_REMOTECONTROL_REMOTEPC_PORT = '3458'; %BA
PSC_REMOTECONTROL_LOCALPC_PORT = '3458'; %BA

% Default screen setup (must specify all 3 fields if VSTIM_RES is defined)
VSTIM_RES.screennum = 2;
VSTIM_RES.width = 1920;
VSTIM_RES.height = 1200;
VSTIM_RES.hz = 60;

% Gamma calibration
% if none set to empty. this will use flat look-up table
PSC_GAMMATABLE = '';

parentfolder(PSC_moviedirpath,1);
parentfolder(PSC_paramdirpath,1);
parentfolder(PSC_logdirpath,1);

% defaults
if ~exist('VSTIM_RES','var'); VSTIM_RES.width = 800; VSTIM_RES.height = 600;  VSTIM_RES.hz = 60; end
