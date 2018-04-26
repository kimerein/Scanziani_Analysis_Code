function varargout = vStimController(varargin)
% VSTIMCONTROLLER M-file for vStimController.fig

% Created: 6/1/10 - SRO
% Modified: 7/20/10 - SRO

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @vStimController_OpeningFcn, ...
    'gui_OutputFcn',  @vStimController_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function vStimController_OpeningFcn(hObject, eventdata, handles, varargin)

% Set rig defaults
rigSpecific;
handles.USER.paramdirpath= PSC_paramdirpath;
handles.USER.logdirpath= PSC_logdirpath;
handles.USER.DAQPCIP = PSC_DAQ_PC_IP;
handles.USER.GAMMATABLE = PSC_GAMMATABLE;
handles.USER.VSTIM_RES = VSTIM_RES;

% Set flags (Temporary, incorporate into rigSpecific)
handles.flag.save = 1;
handles.flag.udp = 1;
handles.flag.parallelport = 1;

% Set display screen number and dimensions
set(handles.screenNum,'String',num2str(VSTIM_RES.screennum))

workRes.width = VSTIM_RES.width;
workRes.height = VSTIM_RES.height;
workRes.pixelSize = [];
workRes.hz = 60;
handles.workRes = workRes;
handles.params = getParams(handles);
handles.dimensions = setDimensions(handles);

% Set default GUI values
handles = computeRowCol(handles);

% Update handles structure
guidata(hObject, handles);


function varargout = vStimController_OutputFcn(hObject, eventdata, handles)


% --- Run callback function --- %

function run_Callback(hObject, eventdata, handles)

assignin('base','h',handles);

% Set up keys
KbName('UnifyKeyNames')

% Clear command line
clc

% Use try/catch so crash won't leave screen hung
try
    clear mex
    InitializeMatlabOpenGL;
    
    % Get parameters
    handles.params = getParams(handles);
    
    % Save parameters
    if handles.flag.save
        parentfolder(fullfile(handles.USER.logdirpath,date),1)
        fname = fullfile(handles.USER.logdirpath,date,datestr(clock,30));
        SaveParams(handles,fname);
    end
    
    % Set up UDP for sending stimulus file name to DAQ PC
    if handles.flag.udp
        u = udpSetup(handles);
    end
    warning off MATLAB:concatenation:integerInteraction  % Comes up when generating udp packet
    
    % Setup parallel port digital out for sending coded stimulus conditions
    if handles.flag.parallelport
        [bitLine, condLine, parentuddobj] = parallelPortSetup();
        bitOn = 0;
        bitOff = 1;
    end
    
    % Setup screen
    res = handles.USER.VSTIM_RES;
    screenNum = res.screennum;
    workRes = NearestResolution(screenNum,res.width,res.height,res.hz);
    handles.workRes = workRes;
    SetResolution(screenNum,workRes);
    lcdDelay = 0.0685;   % SRO - Measured delay between flip and image on screen
    
    % Set dimensions
    handles.dimensions = setDimensions(handles);
    
    % Set number of repitions
    nReps = 1E7;
    
    % Set white, black, gray values
    white = WhiteIndex(screenNum);
    black = BlackIndex(screenNum);
    gray = round(0.5*(black+white));
    
    % Open gray screen
    HideCursor
    [w,wRect] = Screen(screenNum,'OpenWindow',gray);
    Screen('DrawText',w,sprintf('Generating stimuli'),10,30,white);
    Screen('Flip',w);
    
    % Gamma correction
    
    % --- Generate stimulus matrices and store as texture --- %
    p = handles.params;
    assignin('base','p',p)
    
    % Grating size is 1.2x width of screen so grating covers entire screen
    % when rotated
    gratingsize = handles.workRes.width*1.2;
    
    % Compute spatial frequency in terms of pixels
    d = handles.dimensions;
    sfPix = p.sf*d.degPerPix;
    pixPerCyc = 1/sfPix;
    
    assignin('base','d',d)
    
    % Get stimulus type
    ind = get(handles.stimType,'Value');
    stimType = get(handles.stimType,'String');
    stimType = stimType{ind};
    
    % Set stimulus values in stim struct
    val.contrast = p.contrastValues;
    val.orientation = p.oriValues;
    if strcmp(stimType,'Localized gratings')
        val.location = 1:(p.rows*p.columns);
    else
        val.location = NaN;
    end
    stim = makeVarParams(val);
    stim.cInd = stim.contrast;
    stim.cInd(:) = NaN;
    assignin('base','stim',stim)
    
    % Generate stimulus matrices
    for i = 1:length(p.contrastValues)
        [stimMat{i}, visSizeStim] = makeGrating(sfPix,gratingsize,p.contrastValues(i),white,black,p.square);
        % Set value for indexing texture with correct contrast
        stim.cInd(stim.contrast == p.contrastValues(i)) = i;
    end
    
    % Store 1-D single row grating in texture
    for i = 1:length(stimMat)
        stimtex(i) = Screen('MakeTexture', w, stimMat{i});
    end
    
    if strcmp(stimType,'Localized gratings')
        % Enable alpha blending
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        % Generate mask matrix
        [maskMat,maskSizePix,maskRefRect] = makeMask(p,d,visSizeStim,white,black);
        
        % Make mask texture
        masktex = Screen('MakeTexture',w,maskMat);
    end
    
    % Finished generating stimulus
    Screen('DrawText',w,sprintf('Finished stimuli'),10,30,white);
    Screen('Flip',w);
    
    
    % --- Run stimulus --- %
    
    % Set max priority level
    priorityLevel = MaxPriority(w);
    Priority(priorityLevel);
    
    % Translate speed of grating (in cycles per sec) into a shift value in
    % "pixels per frame"
    ifi = Screen('GetFlipInterval', w);
    shiftperframe = p.tf * pixPerCyc * ifi;
    
    rep = 1;
    while(rep < nReps)
        
        % Randomize stimuli
        stimInd = stim.code;
        if p.randomize
            stimInd = Shuffle(stimInd);
        end
        
        % Make N random sequences of stimuli interleaved stimuli
        if p.interleave
            tempInd = nan(1,length(stimInd)*p.numInterleave);
            for i = 1:p.numInterleave
                temp = Shuffle(stimInd);
                tempInd(i:p.numInterleave:end) = temp;
            end
            stimInd = tempInd;
        end
        
        switch stimType
            
            case 'Drifting gratings'
                for s = stimInd
                    
                    % Send stimulus file name, stimType, and stimInd via udp
                    fwrite(u,[fname '*' stimType '*' stimInd]);
                    
                    % Send stimulus code and trigger via parallel port
                    if handles.flag.parallelport
                        putvalue(parentuddobj,s,condLine);
                        putvalue(parentuddobj,[bitOn bitOff],bitLine)
                        WaitSecs(0.000001);
                        putvalue(parentuddobj,[bitOff bitOff],bitLine)
                    end
                    
                    % Delay after trigger before giving stimulus
                   WaitSecs(p.delay - lcdDelay);
                 
                    
                    % VBL-Timestamp as timing baseline for redraw loop
                    vbl = Screen('Flip',w);
                    
                    % Set duration of stimulus
                    vblEndTime = vbl + p.duration;
                    i = 0;
                    
                    while(vbl < vblEndTime)
                        xoffset = mod(i*shiftperframe,pixPerCyc);
                        i = i + 1;
                        srcRect = [xoffset 0 (xoffset + visSizeStim) visSizeStim];
                        
                        % Set destination rectangle
                        dstRect = [0 0 visSizeStim visSizeStim];
                        dstRect = CenterRect(dstRect, wRect);
                        
                        % Draw texture, rotated by angle (note: 90 deg
                        % offset, so ori = 0 is horizontal moving up
                        Screen('DrawTexture',w,stimtex(stim.cInd(s)),srcRect,dstRect,stim.orientation(s)+90);
                        
                        % Draw box in corner of screen
                        frameChangeBox(w,wRect,i)
                        
                        % Show frame
                        vbl = Screen('Flip', w, vbl + 0.2 * ifi);
                        
                        % Abort if any key is pressed (temporary)
                        if KbCheck
                            break
                        end
                        
                    end % frames
                    
                    frameChangeBox(w,wRect,i+1)
                    putvalue(parentuddobj,[bitOff bitOff],bitLine)
                    Screen('FillRect',w,gray);
                    vbl = Screen('Flip', w, vbl);
                    
                    % Inter-stimulus interval
                    WaitSecs(p.wait);
                    
                    if KbCheck
                        break
                    end
                    
                end % stimuli
                if KbCheck
                    break
                end
                
            case 'Localized gratings'
                for s = stimInd
                    
                    % Set stimulus location
                    [mi ni] = ind2sub([p.rows p.columns],stim.location(s));
                    
                    % Send stimulus file name, type, and index via udp
                    fwrite(u,[fname '*' stimType '*' stimInd]);
                    
                    % Send stimulus code and trigger via parallel port
                    if handles.flag.parallelport
                        putvalue(parentuddobj,s,condLine);
                        putvalue(parentuddobj,[bitOn bitOff],bitLine)
                    end
                    
                    % Delay after trigger before giving stimulus
                    WaitSecs(p.delay - lcdDelay);
                    
                    % VBL-Timestamp as timing baseline for redraw loop
                    vbl = Screen('Flip',w);
                    
                    % Set duration of stimulus
                    vblEndTime = vbl + p.duration;
                    i = 0;
                    
                    while(vbl < vblEndTime)
                        xoffset = mod(i*shiftperframe,pixPerCyc);
                        i = i + 1;
                        srcRect = [xoffset 0 (xoffset + visSizeStim) visSizeStim];
                        
                        % Set destination rectangle
                        dstRect = [0 0 visSizeStim visSizeStim];
                        dstRect = CenterRect(dstRect, wRect);
                        
                        % Draw stimulus texture, rotated by angle
                        Screen('DrawTexture',w,stimtex(stim.cInd(s)),srcRect,dstRect,stim.orientation(s)+90);
                        
                        % Set source rectangle for mask
                        srcRect = setSrcRect(maskRefRect,maskSizePix,mi,ni);
                        Screen('DrawTexture',w,masktex,srcRect,dstRect);
                        
                        % Draw box in corner of screen
                        frameChangeBox(w,wRect,i)
                        
                        % Show frame
                        vbl = Screen('Flip', w, vbl + 0.2 * ifi);
                        
                        % Abort if any key is pressed (temporary)
                        if KbCheck
                            break
                        end
                    end % frames
                    frameChangeBox(w,wRect,i+1)
                    putvalue(parentuddobj,[bitOff bitOff],bitLine)
                    Screen('FillRect',w,gray);
                    vbl = Screen('Flip', w, vbl);
                    
                    % Inter-stimulus interval
                    WaitSecs(p.wait);
                    
                    if KbCheck
                        break
                    end
                end % stimuli
                if KbCheck
                    break
                end
                
            case 'Reversing gratings'
                
                for s = stimInd
                    
                    % Send stimulus file name, type, and index via udp
                    fwrite(u,[fname '*' stimType '*' stimInd]);
                    
                    % Send stimulus code and trigger via parallel port
                    if handles.flag.parallelport
                        putvalue(parentuddobj,s,condLine);
                        putvalue(parentuddobj,[bitOn bitOff],bitLine)
                    end
                    
                    % Delay after trigger before giving stimulus
                    WaitSecs(p.delay - lcdDelay);
                    
                    % VBL-Timestamp as timing baseline for redraw loop
                    vbl = Screen('Flip',w);
                    
                    % Set duration of stimulus
                    vblEndTime = vbl + p.duration;
                    i = 0;
                    
                    while(vbl < vblEndTime)
                        xoffset = mod(i*shiftperframe,pixPerCyc);
                        if xoffset < (pixPerCyc/2)
                            xoffset = 0;
                        else
                            xoffset = pixPerCyc/2;
                        end
                        i = i + 1;
                        srcRect = [xoffset 0 (xoffset + visSizeStim) visSizeStim];
                        
                        % Set destination rectangle
                        dstRect = [0 0 visSizeStim visSizeStim];
                        dstRect = CenterRect(dstRect, wRect);
                        
                        % Draw texture, rotated by angle
                        Screen('DrawTexture',w,stimtex(stim.cInd(s)),srcRect,dstRect,stim.orientation(s)+90);
                        
                        % Draw box in corner of screen
                        frameChangeBox(w,wRect,i)
                        
                        vbl = Screen('Flip', w, vbl + 0.2 * ifi);
                        
                        % Abort if any key is pressed (temporary)
                        if KbCheck
                            break
                        end
                        
                    end % frames
                    if KbCheck
                        break
                    end
                    
                    frameChangeBox(w,wRect,i+1)
                    putvalue(parentuddobj,[bitOff bitOff],bitLine)
                    Screen('FillRect',w,gray);
                    vbl = Screen('Flip', w, vbl);
                    
                    % Inter-stimulus interval
                    WaitSecs(p.wait);
                    
                end % stimuli
                if KbCheck
                    break
                end
                
            case 'Gray screen'
                
                % Only 1 stimulus
                s = 1;
                
                % Send stimulus file name, stimType, and stimulus num via udp
                fwrite(u,[fname '*' stimType '*' s]);
                
                % Send stimulus code and trigger via parallel port
                if handles.flag.parallelport
                    putvalue(parentuddobj,s,condLine);
                    putvalue(parentuddobj,[bitOn bitOff],bitLine)
                end
                
                % Delay after trigger before giving stimulus
                WaitSecs(p.delay - lcdDelay);
                
                % VBL-Timestamp as timing baseline for redraw loop
                vbl = Screen('Flip',w);
                
                % Set duration of stimulus
                vblEndTime = vbl + p.duration;
                i = 0;
                
                while(vbl < vblEndTime)
                    
                    i = i + 1;
                    Screen('FillRect',w,gray);
                    
                    % Draw box in corner of screen
                    frameChangeBox(w,wRect,i)
                    
                    vbl = Screen('Flip', w, vbl + 0.2 * ifi);
                    
                    % Abort if any key is pressed (temporary)
                    if KbCheck
                        break
                    end
                    
                end % frames
                if KbCheck
                    break
                end
                
                frameChangeBox(w,wRect,i+1)
                putvalue(parentuddobj,[bitOff bitOff],bitLine)
                Screen('FillRect',w,gray);
                vbl = Screen('Flip', w, vbl);
                
                % Inter-stimulus interval
                WaitSecs(p.wait);
                
                if KbCheck
                    break
                end
                
                
            case 'Full-field'
                
                % Only 1 stimulus
                s = 1;
              
                
                % Send stimulus file name, stimType, and stimulus num via udp
                fwrite(u,[fname '*' stimType '*' s]);
                
                % Send stimulus code and trigger via parallel port
                if handles.flag.parallelport
                    putvalue(parentuddobj,s,condLine);
                    putvalue(parentuddobj,[bitOn bitOff],bitLine)
                end
               
                % Delay after trigger before giving stimulus
                WaitSecs(p.delay - lcdDelay);
                
                % VBL-Timestamp as timing baseline for redraw loop
                vbl = Screen('Flip',w);
                
                % Set duration of stimulus
                vblEndTime = vbl + p.duration;
                i = 0;
                
                while(vbl < vblEndTime)
                    
                    i = i + 1;
                    Screen('FillRect',w,black);
                    
                    % Draw box in corner of screen
                    frameChangeBox(w,wRect,i)
                    
                    vbl = Screen('Flip', w, vbl + 0.2 * ifi);
                    
                    % Abort if any key is pressed (temporary)
                    if KbCheck
                        break
                    end
                    
                end % frames
                if KbCheck
                    break
                end
                
                frameChangeBox(w,wRect,i+1)
                putvalue(parentuddobj,[bitOff bitOff],bitLine)
                Screen('FillRect',w,white);
                vbl = Screen('Flip', w, vbl);
                
                % Inter-stimulus interval
                WaitSecs(p.wait);
                
                if KbCheck
                    break
                end
                
                
                
        end % switch
        
        rep = rep + 1;

    end % repititions
    % Restore normal priority scheduling
    Priority(0);
    Screen('CloseAll');
    if exist('u','var');
        fclose(u); delete(u); clear u;
    end
    ShowCursor
    clear mex
catch
    Priority(0);
    Screen('CloseAll');
    if exist('u','var');
        fclose(u); delete(u); clear u;
    end
    ShowCursor
    psychrethrow(psychlasterror);
    clear mex
end % try

% --- Subfunctions --- %

function driftingGratings()


function localizedGratings()


function reversingGratings()


function u = udpSetup(handles)
if ~isempty(handles.USER.DAQPCIP)
    % Look for valid udp
    bnewudp = 0;
    props = {'Tag','Type'};
    vals = {'udp_conditions','udp'};
    u = instrfindall(props,vals);
    if ~isempty(u)
        if ~isvalid(u);
            delete(u);
            bnewudp = 1;
        end
    else
        bnewudp = 1;
    end
    
    % If valid upd doesn't exist create it
    if bnewudp
        u = udp(handles.USER.DAQPCIP,9093,'LocalPort',9094);
        u.Tag = 'udp_conditions'; % Tag for finding object later
    end
    
    if ~isequal(u.Status,'open');
        fopen(u);
    end
end

function SaveParams(handles,fname)
% NOTE: variable name can't be changed without affecting
% getPsychStimParameters.m
psychstimctrlparams = getParams(handles);
save(fname, 'psychstimctrlparams');

function params = getParams(handles)

% Get edit box values
h = findobj(handles.vStimController,'Style','edit');
tags = get(h,'Tag');
if ischar(tags)
    tags = {tags};
end
for i = 1:length(tags)
    temp = get(handles.(tags{i}),'String');
    if any(isletter(temp))
        params.(tags{i}) = temp;
    else
        params.(tags{i}) = str2num(temp);
    end
end

% Get popupmenu values
h = findobj(handles.vStimController,'Style','popupmenu');
tags = get(h,'Tag');
if ischar(tags)
    tags = {tags};
end
for i = 1:length(tags)
    str = get(handles.(tags{i}),'String');
    val = get(handles.(tags{i}),'Value');
    params.(tags{i}) = str{val};
end

% Get checkbox values
h = findobj(handles.vStimController,'Style','checkbox');
tags = get(h,'Tag');
if ischar(tags)
    tags = {tags};
end
for i = 1:length(tags)
    val = get(handles.(tags{i}),'Value');
    params.(tags{i}) = val;
end

% Set additional fields
if isfield(params,'gratingType')
    if ~isempty(strfind(params.gratingType,'Square'))
        params.square = 1;
    else
        params.square = 0;
    end
end

% Set controller
params.controller = 'vStimController';

function handles = setParams(handles)
p = handles.params;

fields = fieldnames(handles.params);

for i = 1:length(fields)
    switch fields{i}
        
        case {'square','controller'}
            
        case {'randomize','interleave'}
            set(handles.(fields{i}),'Value',p.(fields{i}));
            
        case {'stimType','gratingType'}
            temp = get(handles.(fields{i}),'String');
            temp = strcmp(p.(fields{i}),temp);
            val = find(temp==1);
            set(handles.(fields{i}),'Value',val)
            
        otherwise
            set(handles.(fields{i}),'String',num2str(p.(fields{i})))
    end
end

function dimensions = setDimensions(handles)

d.ScreenDistcm = handles.params.distance;
d.ScreenSizecmX = 52;          % Put in RigSpecific
d.ScreenSizecmY = 32.5;        % Put in RigSpecific
d.ScreenSizeDegX = 2*atan(d.ScreenSizecmX/2/d.ScreenDistcm)*180/pi;
d.ScreenSizeDegY = 2*atan(d.ScreenSizecmY/2/d.ScreenDistcm)*180/pi;
d.ScreenSizePixX = handles.workRes.width;
d.ScreenSizePixY = handles.workRes.height;
d.degPerPix = d.ScreenSizeDegX/d.ScreenSizePixX;

dimensions = d;

function [bitLine, condLine, parentuddobj] = parallelPortSetup()

dio = digitalio('parallel','LPT1');
hwline = addline(dio,0:1,2,'out','bitLine');    % pins 1,14
addline(dio,0:7,'out');     % pins 2-9

%%% for some reason, the slowest part of putvalue when using parallel port
%%% is this step, finding the parent uddobj.
%%% So we look this up in the beginning, and then directly call the
%%% putvalue function with uddobject, data, and line numbers.
%%% Not exactly sure why this works, but it reduces time per call
%%% from 2msec to 20usec (at least in previous versions of daqtoolbox)

parent = get(dio.bitLine, 'Parent');
parentuddobj = daqgetfield(parent{1},'uddobject');
bitLine = 1:2;
condLine = 3:10;
bitOn = 0;
bitOff = 1;
putvalue(parentuddobj,0,condLine);
putvalue(parentuddobj,[bitOff bitOff],bitLine);

function srcRect = setSrcRect(maskRefRect,maskSizePix,mi,ni)
m = maskRefRect;
msp = maskSizePix;
L = m(1) - (ni-1)*msp;
T = m(2) - (mi-1)*msp;
R = m(3) - (ni-1)*msp;
B = m(4) - (mi-1)*msp;
srcRect = [L T R B];

function handles = computeRowCol(handles)
size = str2num(get(handles.size,'String'));
d = handles.dimensions;
% Convert to pixels
size = floor(size/d.degPerPix);
rows = floor(d.ScreenSizePixY/size);
columns = floor(d.ScreenSizePixX/size);
set(handles.rows,'String',num2str(rows));
set(handles.columns,'String',num2str(columns));

function handles = computeMaskSize(handles,dimension)

d = handles.dimensions;
switch dimension
    case 'rows'
        row = str2num(get(handles.rows,'String'));
        maskSizePix = d.ScreenSizePixY/row*0.99;
    case 'columns'
        col = str2num(get(handles.columns,'String'));
        maskSizePix = d.ScreenSizePixX/col*0.99;
end
maskSizeDeg = d.degPerPix*maskSizePix;

set(handles.size,'String',num2str(maskSizeDeg,3));

function stim = makeVarParams(val)

fields = fieldnames(val);

for i = 1:length(fields)
    nCond(i) = length(val.(fields{i}));
end

cond = 0;
for c1 = 1:nCond(1)
    for c2 = 1:nCond(2)
        for c3 = 1:nCond(3)
            cond = cond + 1;
            c = [c1 c2 c3];
            for i = 1:length(fields)
                cInd = c(i);
                stim.(fields{i})(cond) = val.(fields{i})(cInd);
            end
        end
    end
end

stim.code = 1:length(stim.(fields{1}));

function handles = setOriValues(handles)
oriStart = str2num(get(handles.oriStart,'String'));
oriEnd = str2num(get(handles.oriEnd,'String'));
steps = str2num(get(handles.oriSteps,'String'));
if (oriStart == 0) && (oriEnd == 360)
    val =linspace(oriStart,oriEnd,steps+1);
    val = val(1:end-1);
else
    val = linspace(oriStart,oriEnd,steps);
end
set(handles.oriValues,'String',mat2str(val))

function handles = setContrastValues(handles)
contrastStart = str2num(get(handles.contrastStart,'String'));
contrastEnd = str2num(get(handles.contrastEnd,'String'));
steps = str2num(get(handles.contrastSteps,'String'));
val = logspace(log10(contrastStart),log10(contrastEnd),steps);
set(handles.contrastValues,'String',mat2str(val,2))

function frameChangeBox(w,wRect,i)
c = [255 0];
Screen('FillRect',w,c(mod(i,2)+1),[wRect(3)-40 wRect(4)-60 wRect(3) wRect(4)]);


% --- Callback functions --- %
function gratingType_Callback(hObject, eventdata, handles)

function sf_Callback(hObject, eventdata, handles)

function tf_Callback(hObject, eventdata, handles)

function screenNum_Callback(hObject, eventdata, handles)

function size_Callback(hObject, eventdata, handles)
handles = computeRowCol(handles);
guidata(hObject,handles)

function contrastStart_Callback(hObject, eventdata, handles)
handles = setContrastValues(handles);
guidata(hObject,handles)

function contrastEnd_Callback(hObject, eventdata, handles)
handles = setContrastValues(handles);
guidata(hObject,handles)

function contrastSteps_Callback(hObject, eventdata, handles)
handles = setContrastValues(handles);
guidata(hObject,handles)

function contrastValues_Callback(hObject, eventdata, handles)
handles = setContrastValues(handles);
guidata(hObject,handles)

function oriStart_Callback(hObject, eventdata, handles)
handles = setOriValues(handles);
guidata(hObject,handles)

function oriEnd_Callback(hObject, eventdata, handles)
handles = setOriValues(handles);
guidata(hObject,handles)

function oriSteps_Callback(hObject, eventdata, handles)
handles = setOriValues(handles);
guidata(hObject,handles)

function oriValues_Callback(hObject, eventdata, handles)
handles = setOriValues(handles);
guidata(hObject,handles)

function fullscreen_Callback(hObject, eventdata, handles)

function distance_Callback(hObject, eventdata, handles)
handles.dimensions = setDimensions(handles);
guidata(hObject,handles);

function duration_Callback(hObject, eventdata, handles)

function delay_Callback(hObject, eventdata, handles)

function load_Callback(hObject, eventdata, handles)
[fname, pname] = uigetfile('*.mat','Parameter File',handles.USER.paramdirpath);
if (fname == 0)
    return
end
load(fullfile(pname,fname));
handles.params = psychstimctrlparams;
handles = setParams(handles);
handles.dimensions = setDimensions(handles);
guidata(hObject,handles)

function save_Callback(hObject, eventdata, handles)
[fname, pname] = uiputfile('*.mat','Parameter File',handles.USER.paramdirpath);
if (fname == 0)
    return
end

fname = fullfile(pname,fname);
SaveParams(handles,fname);

handles.USER.paramdirpath = pname;
guidata(hObject,handles)

function stimType_Callback(hObject, eventdata, handles)

function randomize_Callback(hObject, eventdata, handles)

function rows_Callback(hObject, eventdata, handles)

handles = computeMaskSize(handles,'rows');
handles = computeRowCol(handles);

function columns_Callback(hObject, eventdata, handles)
handles = computeMaskSize(handles,'columns');
handles = computeRowCol(handles);

function wait_Callback(hObject, eventdata, handles)


% --- Create functions --- %
function delay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function duration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function distance_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function oriValues_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function oriSteps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function oriEnd_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function oriStart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function gratingType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function contrastValues_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function contrastSteps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function contrastEnd_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function contrastStart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function screenNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function stimType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function rows_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function columns_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function wait_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in interleave.
function interleave_Callback(hObject, eventdata, handles)
% hObject    handle to interleave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of interleave



function numInterleave_Callback(hObject, eventdata, handles)
% hObject    handle to numInterleave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numInterleave as text
%        str2double(get(hObject,'String')) returns contents of numInterleave as a double


% --- Executes during object creation, after setting all properties.
function numInterleave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numInterleave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
