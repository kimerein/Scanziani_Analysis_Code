function varargout = PsychStimController(varargin)
% PSYCHSTIMCONTROLLER M-file for PsychStimController.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PsychStimController_OpeningFcn, ...
    'gui_OutputFcn',  @PsychStimController_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT


function PsychStimController_OpeningFcn(hObject, eventdata, handles, varargin)

% Load file with rig-specific parameters
rigSpecific; % TO DO add case where rigSpecific doesn't exist

handles.USER.moviedirpath  = PSC_moviedirpath;
handles.USER.paramdirpath= PSC_paramdirpath;
handles.USER.logdirpath= PSC_logdirpath;
handles.USER.DAQPCIP = PSC_DAQ_PC_IP;
handles.USER.GAMMATABLE = PSC_GAMMATABLE;

% Default remote control ips and ports
if exist('PSC_REMOTECONTROL_REMOTEPC_PORT','var') && exist('PSC_REMOTECONTROL_REMOTEPC_IP','var')
    handles.USER.PSC_REMOTECONTROL_REMOTEPC_PORT = PSC_REMOTECONTROL_REMOTEPC_PORT;
    handles.USER.PSC_REMOTECONTROL_REMOTEPC_IP = PSC_REMOTECONTROL_REMOTEPC_IP;
else
    error('rigSpecific file must specify both PSC_REMOTECONTROL_REMOTEPC_PORT and PSC_REMOTECONTROL_REMOTEPC_IP');
end
if exist('PSC_REMOTECONTROL_LOCALPC_PORT','var')
    handles.USER.PSC_REMOTECONTROL_LOCALPC_PORT = PSC_REMOTECONTROL_LOCALPC_PORT;
else
    handles.USER.PSC_REMOTECONTROL_LOCALPC_PORT = '3458' ;
end

% % Check that can ping ip address
% TO DO: if can't ping don't allow remote control
% if ~dosping(PSC_REMOTECONTROL_REMOTEPC_IP)
%     error(['Cannot ping REMOTE CONTROL IP: ' PSC_REMOTECONTROL_REMOTEPC_IP])
% end

% Set the screen to display stimuli
screennums = Screen('Screens'); % If there is just one monitor use that instead of th default monitor
if length(screennums) == 1; % Check if more than 1 monitor exists
    set(handles.ScreenNum,'String',num2str(screennums))
else
    set(handles.ScreenNum,'String',num2str(VSTIM_RES.screennum))
end

% Save original screen resolution before stimulus
handles.orgResolution = Screen('Resolution',str2num(get(handles.ScreenNum,'String')));

% Define screen resolution during stimulus presentation
workingRes = NearestResolution(str2num(get(handles.ScreenNum,'String')),VSTIM_RES);
set(handles.PixelsX,'String',num2str(workingRes.width));
set(handles.PixelsY,'String',num2str(workingRes.height));
set(handles.FrameHz,'String',num2str(workingRes.hz));

set(handles.chbxWeightContrast,'Enable','off')

% Update handles structure
guidata(hObject, handles);

ScreenNum_Callback(handles.ScreenNum,eventdata,handles);
StimType_Callback(handles.StimType,eventdata,handles);
Var1_Callback(handles.Var1,eventdata,handles);
Var2_Callback(handles.Var2,eventdata,handles);

end

function varargout = PsychStimController_OutputFcn(hObject, eventdata, handles)

end

function StimType_Callback(hObject, eventdata, handles)
set([handles.StimType, handles.Orient0,handles.Speed0,handles.Speed0,handles.Freq0,handles.Contrast0,handles.PositionX0,handles.PositionY0,...
    handles.Length0,handles.Duration,handles.SelectMovieName,handles.MovieName, handles.MovieMag, handles.MovieRate,handles.phasePeriod,...
    handles.stimulusGroups,handles.TempFreq0,handles.Phase0,handles.Start2,handles.Stop2,handles.nSteps2,handles.LinLog2,handles.Var2Range,handles.PreWaitInt,handles.WaitInterval,...
    handles.bkgrnd, handles.squaregratings, handles.blankstim,handles.randomize, handles.FullFlicker, handles.nReps,...
    handles.remoteUpdate, handles.LoadParams,  handles.SaveParams,  handles.RunBtn, handles.Var1,handles.Var2, handles.Start1, handles.Start2,...
    handles.Stop1, handles.Stop2, handles.nSteps1, handles.nSteps2, handles.LinLog1, handles.LinLog2, handles.Var1Range, handles.Var2Range],...
    'ForegroundColor',[0 0 0])  ;
StimType = get(hObject,'Value');
%%% disable fields that aren't appropriate to this stimulus type

if StimType == 1 || StimType == 6     %% drifting or counterphase gratings
    set(handles.Duration,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Speed0,'Enable','off');
    set(handles.TempFreq0,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Phase0,'Enable','off');
end

if StimType == 2     %% drifting bars
    ScreenSizeDegX = str2double(get(handles.SizeX,'String')) * ...
        atan(1/str2double(get(handles.ScreenDist,'String'))) * 180/pi;
    Duration = ScreenSizeDegX/str2double(get(handles.Speed0,'String'));
    set(handles.Duration,'String',num2str(Duration));
    set(handles.Duration,'Enable','off');
    set(handles.Speed0,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.TempFreq0,'Enable','off');
end

if StimType==6 %% counterphase gratings
    set(handles.Phase0,'Enable','on');
end

if StimType == 1 || StimType == 2 || StimType == 6 %% drifting bars, drifting or counterphase gratings
    set(handles.Orient0,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Freq0,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Contrast0,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.SelectMovieName,'Enable','off');
    set(handles.MovieName,'Enable','off');
    set(handles.MovieMag,'Enable','off');
    set(handles.MovieRate,'Enable','off');
    set(handles.phasePeriod,'Enable','off');
    set(handles.stimulusGroups,'Enable','off');
end

if StimType == 7 %% spot
    set(handles.PositionX0,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.PositionY0,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Duration,'Enable','on','ForegroundColor',[1 0 0]);
end

if StimType == 3 %% movie
    set(handles.Orient0,'Enable','off');
    set(handles.Speed0,'Enable','off');
    set(handles.Freq0,'Enable','off');
    set(handles.Contrast0,'Enable','off');
    set(handles.PositionX0,'Enable','on');
    set(handles.PositionY0,'Enable','off');
    set(handles.Length0,'Enable','off');
    set(handles.Duration,'Enable','on');
    set(handles.SelectMovieName,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.MovieName,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.MovieMag,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.MovieRate,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.phasePeriod,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.stimulusGroups,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.TempFreq0,'Enable','off');
    set(handles.Phase0,'Enable','off');
    % set wait interval to default 0 -- it's too easy to screw this up when
    % showing movies, causing unusual contimage phase behavior -- this is a
    % hack but I don't have better ideas MSC
    set(handles.WaitInterval,'String','0');
end

Var1_Callback(handles.Var1,eventdata,handles);
Var2_Callback(handles.Var2,eventdata,handles);

end

function RunBtn_Callback(hObject, eventdata, handles)
clc
% Setup keys and mosue
KbName('UnifyKeyNames');
handles.UCkeys = declareUCkeys();

if get(handles.chkRemote,'Value') && get(handles.toggleMaster,'Value')   % Remote MASTER
    stat = rc_udpsend(handles,'run');
    if stat
        set(handles.remotetext,'String','Remote Running','FontWeight','bold','FontSize',12, 'ForegroundColor','Red');
        %         set(handles.hPsychStimController,'KeyPressFcn',{@remoteMasterKeyHandler,handles});
    else
        set(handles.remotetext,'String','Remote Start Failed','FontWeight','bold','FontSize',10);
        %         error('Failed to Run remote PC');
    end


else % Only run if in Local mode or Remote SLAVE mode
    try  % Use try/catch so crash won't leave screen hung
        clear mex
        % Setup screen
        workRes = NearestResolution(str2num(get(handles.ScreenNum,'String')),str2num(get(handles.PixelsX,'String')),str2num(get(handles.PixelsY,'String')),str2num(get(handles.FrameHz,'String')));
        set(handles.PixelsX,'String',num2str(workRes.width)); set(handles.PixelsY,'String',num2str(workRes.height)); set(handles.FrameHz,'String',num2str(workRes.hz));
        SetResolution(str2num(get(handles.ScreenNum,'String')),workRes);

        % Save parameters automatically
        parentfolder(fullfile(handles.USER.logdirpath,date),1)
        fname = fullfile(handles.USER.logdirpath,date,datestr(clock,30));
        SaveParams(handles,fname);

        % UDP for sending stimulus file to daq PC
        if ~isempty(handles.USER.DAQPCIP)
            bnewudp = 0;
            props = {'Tag','Type'};
            vals = {'udp_conditions','udp'};
            u = instrfindall(props,vals);
            if ~isempty(u)
                if ~isvalid(u);
                    delete(u);bnewudp = 1;
                end
            else            bnewudp = 1;
            end

            if bnewudp % If valid upd doesn't already exist create it
                u = udp(handles.USER.DAQPCIP,9093,'LocalPort',9094);
                u.OutputBufferSize = 2^12; % for some reason these must be set after udp is created otherwise fields are ignored and defaults are used
                u.InputBufferSize = 2^12;
                u.Timeout = 5e-1; %

                u.Tag = 'udp_conditions'; % for finding this later
            end

            if ~isequal(u.Status,'open'); fopen(u); end

        end

        InitializeMatlabOpenGL;
        % Display description
        Duration = str2double(get(handles.Duration,'String'));
        FrameHz = round(str2double(get(handles.FrameHz,'String')));
        whichScreen = str2double(get(handles.ScreenNum,'String'));
        [window,windowRect]=Screen(whichScreen,'OpenWindow',0);   %%% open grey window
        Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % BA needed for masking (could find another way )

        white = WhiteIndex(window);
        black = BlackIndex(window);
        grey = round(0.5*(black+white));
        % clear mex
        imageRect = windowRect;
        ScreenSizeDegX = str2double(get(handles.SizeX,'String'))*atan(1/str2double(get(handles.ScreenDist,'String')))*180/pi;
        degPerPix = ScreenSizeDegX/windowRect(3);
        handles.degPerPix = degPerPix;
        params.nCond = size(handles.orient,2);
        stim = get(handles.StimType,'Value');

        % nReps is the number of repetitions of the entire stimulus sequence
        % fractional values of nReps are useful to truncate movies
        nReps = str2double(get(handles.nReps,'String'));
        if nReps <= 0 %% loop almost-infinitely
            nReps = 10000000;
        end

        nStimulusRepetitions = 1; % defaults to 1 for non-movie stimuli

        % For clut animation
        if stim == 1 || stim == 2 || stim == 4 || stim == 5 || stim == 6 || stim == 7
            clut = 1;
            sizeLut = 256;
            offclut = zeros(sizeLut,3);
            offclut(:,:) = grey;   %default
        else %% stim == 3
            clut = 0; % movie
        end
        Screen('DrawText',window,sprintf('Generating stimuli'),10,30,white);

        Screen('Flip',window);

        switchStimHelper();

        binterleavedCompatible = get(handles.chbxbinterleave,'Value');
        bweightContrast = get(handles.chbxWeightContrast,'Value');

        % BA mask parameters TO DO ADD to GUI
        % mask radii
        % ADD to gui , and saved and reloaded
        handles.UCparams.rx = str2num(get(handles.maskradiusx,'String')) ;% in pixels %% add change to degrs
        handles.UCparams.ry = str2num(get(handles.maskradiusy,'String'));

        params.rStep = 5; % inc and descrement step mask radius, pixels
        params.RMAX = max(imageRect); % max radius of mask
        handles.UCparams.lockMask = 1; % toggles mouse movement of mask

        %BA initial mask coordinates (later is mouse cursor coordinates)
        % ADD to gui and save and reloaded
        handles.UCparams.mX =  str2num(get(handles.maskcenterx,'String')); % The x-coordinate of the mouse cursor
        handles.UCparams.mY = str2num(get(handles.maskcentery,'String')); % The y-coordinate of the mouse cursor
        handles.UCparams.rotation = 0;

        params.nMasks = 4; % number of cases in helperMakeMask
        handles.UCparams.masktype = get(handles.popmenuMask,'Value')-1;
        handles.UCparams.masktex =  helperMakeMask(handles.UCparams.rx,handles.UCparams.ry,window,handles.UCparams.masktype);

        % ADD to GUI control of this
        handles.UCparams.bautoChangeContrast = 1;

        params.window = window; % for passing into keycontrol function

        %%%% clear screen
        Screen('FillRect',window,128);
        Screen('DrawText',window,sprintf('Finished stimuli'),10,40);
        Screen('Flip',window);

        %%%% gamma correction
        flat_clut = [(0:1/255:1)' (0:1/255:1)' (0:1/255:1)'];
        if ~isempty (handles.USER.GAMMATABLE); load(handles.USER.GAMMATABLE )
            screen('LoadNormalizedGammaTable',window,inv_gamma_clut);
            clear spyderCaldata;
        else % correct with out calibration
            screen_gamma=2; % commented by BA on 062208 (although this calibration is
            % % pretty` close to right(within a few percent)
            gamma_clut = flat_clut.^(1/screen_gamma);
            %         screen('LoadNormalizedGammaTable',window,gamma_clut);
            screen('LoadNormalizedGammaTable',window,flat_clut);
        end
        %%% get number of frames
        if clut
            nFrames = size(cluts,3);
        else
            nFrames = size(textures,2);
        end

        %% setup synchronization
        statusfile = fopen('statusfile.txt','w');
        startTime = GetSecs();

        % Setup parallel port digital out. Used for sending stimulus
        % conditions to DAQ PC.
        dio = digitalio('parallel','LPT1');
        hwline = addline(dio,0:1,2,'out','bitLine');    %% pins 1,14
        addline(dio,0:7,'out'); %% pins 2-9

        %%% for some reason, the slowest part of putvalue when using parallel port
        %%% is this step, finding the parent uddobj.
        %%% So we look this up in the beginning, and then directly call the
        %%% putvalue function with uddobject, data, and line numbers.
        %%% Not exactly sure why this works, but it reduces time per call
        %%% from 2msec to 20usec (at least in previous versions of daqtoolbox
        parent = get(dio.bitLine, 'Parent');
        parentuddobj = daqgetfield(parent{1},'uddobject');
        % stimLine = 1;
        % frameLine = 2;
        bitLine=1:2;
        condNum=3:10;
        bitOn=0;
        bitOff=1;
        putvalue(parentuddobj,0,condNum);
        putvalue(parentuddobj,[bitOff bitOff],bitLine);

        %% set background clut
        if clut
            moglClutBlit(window,textures(1),offclut);
            % currentclut=offclut;
        end

        clearBkgrnd = get(handles.bkgrnd,'Value');

        %% add blank stimulus as extra condition
        nNoneBlankStim = params.nCond;
        bUsingBlank = 0;

        if get(handles.blankstim,'Value')
            if clut
                bUsingBlank = 1;
                params.nCond = params.nCond + 1;
                cluts(:,:,:,params.nCond) = offclut(1,1);
                textures(params.nCond) = textures(params.nCond-1);
            else  %%% no need for blank in movies (at least for now)
                sprintf('no blank available for movies')
            end
        end

        %% add full field flicker as extra condition, for drifiting gratings
        if get(handles.FullFlicker,'Value') && (get(handles.StimType,'Value')==1)
            params.nCond = params.nCond + 1;
            if clut
                cluts(:,:,:,params.nCond)=cluts(:,:,:,1);
                textures(params.nCond)=Screen('MakeTexture',window,ones(size(img)));
            end
        end

        %% set up run variables
        FrameInt = 1/FrameHz;
        WaitInt = str2double(get(handles.WaitInterval,'String'));
        WaitInt = str2double(get(handles.WaitInterval,'String'));
        PreWaitInt = str2double(get(handles.PreWaitInt,'String'));
        
        s1 = zeros(nFrames,1);
        ds = zeros(nFrames-1,1);

        vblstore = nan(1,min(nFrames*params.nCond*500,1000000)); % BA predefine space for saving vbl time (this is a backup in case
        vbli = 1;
        ndropframes = 0;

        % BA for saving condList
        MAXSHUFFLES = 1000; %number of times that condList will be reshuffled, after which the first shuffle will be used again
        condListStore = zeros(1,params.nCond*MAXSHUFFLES,'int16');
        % texturec = 1;

        %% finally, run stimulus!!
        warning off MATLAB:concatenation:integerInteraction  %%%% this error comes up in generating udp packet
        %     ListenChar(2); % BA removed this cause it is annoying

        % Make sure all Rushed variables and functions are in memory
        % before raising priority
        handles.UCparams.doneStim = 0;
        handles.UCparams.break = 0;
        iter = 0;
        numiters = nReps * params.nCond * nStimulusRepetitions;
        % stimulusrep applies when there are multiple stimuli for a particular
        % condition, e.g. different noise patterns.
        stimulusrep = 1;

        GetSecs;
        Screen('Screens');
        %     HideCursor; %BA

        lastsecs = [];
        bgotRemoteData = 0;
        vbllast = 0;
        Ncond= params.nCond;
        Ncond_pertrial = Ncond; % weighting and interleaving will change the number of conditios pertrial
        condList = [1:Ncond];
        
        %%% loop on conditions
        while ~handles.UCparams.doneStim
%             iter
%             Ncond_pertrial
%             condList
            
            frameChangeBox(window,windowRect,255); % make sure frame box always ends a stimuls low adds box to corner of screen and switch box from gray to white everytime function is called
            vbl = Screen('Flip',window);

            %%% randomize conditions
            if get(handles.randomize,'Value');
                if mod(iter,Ncond_pertrial)==0   %%% shuffle condition list each repeat

                    display('** HERE **')
                    if iter>0 && iter>Ncond_pertrial*MAXSHUFFLES %number of times that condList has been reshuffled exceeds MAXSHUFFLES resuse previous REShuffles in order
                        temp =  mod(iter,Ncond_pertrial*MAXSHUFFLES);
                        temp = temp + ~temp; % make start from 1
                        condList = condListStore(temp:temp+tempNcond+1); %
                        display('Reusing stored conditions')

                    else

                        if bweightContrast
                            % find which Variable is contrast
                            allcond = 1:params.nCond;
                            if bUsingBlank, allcond_withoutBLANK =  1:(params.nCond-1); else allcond_withoutBLANK = allcond; end
                            nVarCont = length(handles.contrast);
                            if get(handles.Var1,'Value')==5
                                if get(handles.Var2,'Value')~=1
                                    contrastCond = (floor((allcond_withoutBLANK-1)/nVarCont)+1) ;
                                else contrastCond = allcond; end
                            else               contrastCond= rem(allcond_withoutBLANK -1,nVarCont)+1;   end

                            if bUsingBlank, contrastCond = [contrastCond 0]; end % add an empty entry for the BLANK condition

                            nOccurances = ones(1,length(allcond));
                            nOccurances(contrastCond==(nVarCont-1)) = 2;
                            nOccurances(contrastCond==(nVarCont)) = 3;

                            condList = [];
                            for i = allcond
                                % number of times to include this stimulus depend on its contrast
                                % it is assumed that the high contrast are
                                % the highest Var values
                                condList = [condList i*ones(1,nOccurances(i))];
                            end
                            Ncond_pertrial = length(condList);
                            condList=     Shuffle(condList);

                        else
                            condList = Shuffle([1:Ncond]); % must use Ncond here (Ncond_pertrial change after interleaveCompatible
                            display('here2')
                        end
                        
                        interleavedCompatible
                        condListStore(max(iter,1):max(iter,1)+Ncond_pertrial-1) = condList; % save so that is saved to disk
                    end
                end

            else
                condList = [1:Ncond];
                interleavedCompatible
                condListStore(1:Ncond_pertrial) = condList;
            end


            %%% choose condition for  this iteration and send it out
            if handles.UCparams.bautoChangeContrast % BA allows manual control of condition
                handles.UCparams.c = condList(mod(iter,Ncond_pertrial)+1);
            end
% handles.UCparams.c
            putvalue(parentuddobj, handles.UCparams.c,condNum);

            %%% raise the priority
            priorityLevel = MaxPriority(window);

            Priority(priorityLevel);
            %             Priority(0);
            %%% loop for blit anim              ation
            if ~clut
                if stim==3 % BA not sure what this is for don't like it for my gratings but leaving it for moviedata
                    vbl = Screen('Flip',window);  %%% initial flip, to sync with vertical blank
                end
                %% set which frames to show
                if (stim == 3 && stimgroups > 1)
                    % if multiple condition movie, randomly choose a condition
                    offset = ( handles.UCparams.c-1)*nStimulusRepetitions*phasePeriodFrames + ...
                        (stimulusrep-1)*phasePeriodFrames;
                    minframe = offset + 1;
                    maxframe = offset + phasePeriodFrames;
                else
                    % show movie all the way through regardless of randomization
                    minframe = 1;
                    maxframe = nFrames;
                end


                if exist('u','var');
                    if isequal(u.status,'open')
                        fwrite(u,[fname '*' condNAME]);
                        sendParams_udp(u,handles);
                    end
                else
                    display(' ******* WARNING Stim conditions are not being transmitted to DAQ PC ******* ');
                end

                WaitSecs(WAITTIME);% BA (delay so that next trigger is caught by DAQ) kluggy, WAITTIME>0 only for reverse correlation

                % Loop through frames
                for f = minframe:maxframe
                    if handles.UCparams.break
                        break;
                    end
                    s1(f) = GetSecs;
                    Screen('DrawTexture',window, textures(handles.UCparams.c,f),[],destRect,handles.UCparams.rotation);
                    Screen('DrawTexture', window, handles.UCparams.masktex, [],CenterRectOnPoint(windowRect*2, handles.UCparams.mX, handles.UCparams.mY));                         % draw mask
                    %% BA CHECK may be drawing mask outside of window
                    Screen('DrawText',window,sprintf('%d %d C%d %d %d',ndropframes,vbli,params.nCond,iter,stimulusrep),10,2,black);

                    everyframeHelper();
                end

                % Done with stimulus
                if clearBkgrnd
                    Screen('FillRect',window,grey);

                    frameChangeBox(window,windowRect); % adds box to corner of screen and switch box from gray to white everytime function is called
                    putvalue(parentuddobj,[bitOn bitOn],bitLine);
                    vbl = Screen('Flip',window, vbl+ (FrameWait - 0.5) * FrameInt);
                    putvalue(parentuddobj,[bitOff bitOff],bitLine);

                    vbli = vbli+1;
                    if bsavefliptimes
                        vblstore(vbli)= vbl;
                    end
                end

                putvalue(parentuddobj,[bitOff bitOff],bitLine);

                % If clut (stimulus = ... )
            elseif clut
                clutcond = (squeeze(cluts(:,:,:, handles.UCparams.c)));
                %%% first clut loaded is slow, so must load something
                %%% (at least in old version)
                %             moglClutBlit(window,textures( handles.UCparams.c,1),currentclut);
                %             vbl= Screen('Flip',window);
                if exist('u','var');
                    if isequal(u.status,'open')
                        fwrite(u,[fname '*' condNAME]);
                        sendParams_udp(u,handles);
                    end
                else
                    display(' ********** WARNING Stim conditions are not being transmitted to DAQ PC******');
                end% BA output stimulus data to DAQ PC

                   % Done with stimulus
                   if clearBkgrnd & PreWaitInt>0
                       moglClutBlit(window,textures( handles.UCparams.c),offclut);
                       frameChangeBox(window,windowRect); % Add box to corner of screen that changes on flip

                       putvalue(parentuddobj,[bitOn bitOn],bitLine);
                       vbl = Screen('Flip',window, vbl + (FrameWait - 0.5) * FrameInt);
                       putvalue(parentuddobj,[bitOn bitOff],bitLine);
                       vbli = vbli+1;
                       if bsavefliptimes
                           vblstore(vbli)= vbl;
                       end
                       WaitSecs(PreWaitInt);

                   end
                
                %%%% loop through frames
                for f = 1:nFrames
                    if handles.UCparams.break
                        break;
                    end
                    s1(f) = GetSecs;
                    %                moglClutBlitBA(window,textures( handles.UCparams.c),clutcond(:,:,f),handles.UCparams.rotation);
                    moglClutBlit(window,textures( handles.UCparams.c),clutcond(:,:,f),handles.UCparams.rotation);
                    %                moglClutBlit(window,textures(handles.UCparams.c),clutcond(:,:,f));

                    % Draw mask
                    Screen('DrawTexture', window, handles.UCparams.masktex, [],CenterRectOnPoint(windowRect*2, handles.UCparams.mX, handles.UCparams.mY));
                    if handles.UCparams.c<= nNoneBlankStim
                        Screen('DrawText',window,sprintf('D:%d %d %dd %1.2fcpd %1.1fhz %1.2f #%d C%d %d %d',ndropframes, vbli, mod(handles.orient(handles.UCparams.c)+(360-handles.UCparams.rotation),360),handles.freq(handles.UCparams.c),handles.TempFreq(handles.UCparams.c),handles.contrast(handles.UCparams.c),handles.UCparams.c, params.nCond,iter,stimulusrep),10,2,black);
                    else  % for blank stimuluts
                        Screen('DrawText',window,sprintf('D:%d %d BLANK C%d %d %d',ndropframes, vbli,...
                            params.nCond,iter,stimulusrep),10,2,black);
                    end
                    everyframeHelper();

                end

                % Done with stimulus
                if clearBkgrnd & WaitInt>0 % only flip to gray for non zero postwait
                    moglClutBlit(window,textures( handles.UCparams.c),offclut);
                    frameChangeBox(window,windowRect); % Add box to corner of screen that changes on flip

                    putvalue(parentuddobj,[bitOn bitOn],bitLine);
                    vbl = Screen('Flip',window, vbl + (FrameWait - 0.5) * FrameInt);
                    putvalue(parentuddobj,[bitOff bitOff],bitLine);
                    vbli = vbli+1;
                    if bsavefliptimes
                        vblstore(vbli)= vbl;
                    end
                end

                putvalue(parentuddobj,[bitOff bitOff],bitLine);

            end    % clut

            Priority(0);
            WaitSecs(WaitInt);

            if nFrames > 1
                ds = max(ds,diff(s1));
            end

            iter = iter + 1;
            stimulusrep = floor(iter/params.nCond);
            elapsedTime = GetSecs - startTime;
            fprintf(statusfile,'%d %d %0.2f \r\n',iter,int16(numiters),elapsedTime);

            if mod(iter,params.nCond) == 0 %% done all conditions, move on to next stimulus
                stimulusrep = stimulusrep + 1;
                % if new Rep of entire movie, start new stimulusrep
                stimulusrep = mod(stimulusrep-1,nStimulusRepetitions)+1;
            end

            % test for all stimuli complete
            if (iter >= numiters)
                handles.UCparams.doneStim = 1;
                disp('Exit on completion');
            end
        end %while ~doneStim

        f = figure(1);
        set(f,'Position',[1 35 1024 130])
        plot(ds);
        title('Dropped frames');
        cleanupHelper();

        % If there's an error, clean up and rethrow the error
    catch ME
        getReport(ME)
        cleanupHelper();
        psychrethrow(psychlasterror);
    end
end

    function interleavedCompatible
        Ncond_pertrial = length(condList);
        if binterleavedCompatible % to insure that interleaved stimuli get each stimulus condition

            if ~mod(Ncond_pertrial,2) % is even
                tempcondList = circshift(condList',Ncond_pertrial/2+1)'; % shift by an odd number, half the length of trial taken to avoid giving the same stimuli close to gether
                %                 tempcondList
            else % if odd just repeat same condition order
                tempcondList = condList; %
            end
            condList = [condList tempcondList];
            Ncond_pertrial = length(condList); % should be 2 times Ncond_pertrial
        end
    end

    function cleanupHelper()

        Priority(0);

        %%% Save conditions and condition order to disk
        condListStore = condListStore((condListStore>0));
        vblstore = vblstore(~isnan(vblstore));
        save([fname '_Condvblstore'],'condListStore','iter','vblstore'); % this is a back up (each condition should be transmitted to DAQ PC each iteration)

        %%% UPDATE GUI values BA%%%%%%%%%%
        set(handles.popmenuMask,'Value',handles.UCparams.masktype+1);
        set(handles.maskradiusx,'String',num2str(handles.UCparams.rx)); % in pixels
        set(handles.maskradiusy,'String',num2str(handles.UCparams.ry));
        set(handles.maskcenterx,'String',num2str(handles.UCparams.mX)); % The x-coordinate of the mouse cursor
        set(handles.maskcentery,'String',num2str(handles.UCparams.mY)); % The y-coordinate of the mouse cursor

        %%%% cleanup   %%%%
        if exist('u','var');
            fclose(u); delete(u); clear u;
        end
        moglClutBlit;
        ListenChar(1);
        pnet('closeall')
        fclose(statusfile);clear statusfile;
        Screen('LoadNormalizedGammaTable',window,flat_clut);
        screen('CloseAll');

        SetResolution(str2num(get(handles.ScreenNum,'String')),handles.orgResolution);

        %BA save frames timing
        ShowCursor;

        if ~get(handles.toggleMaster,'Value')
            udpcommhelper(handles.uR,'stimend');
        end
    end

    function everyframeHelper()
        frameChangeBox(window,windowRect); % adds box to corner of screen and switch box from gray to white everytime function is called

        putvalue(parentuddobj,[bitOn bitOn],bitLine);
        if f > 1
            vbl = Screen('Flip',window, vbl + (FrameWait - 0.5) * FrameInt);
        else
            vbl = Screen('Flip',window);
        end
        putvalue(parentuddobj,[bitOn bitOff],bitLine);
        vbli = vbli+1;
        if bsavefliptimes
            vblstore(vbli)= vbl;
        end
        if f > 1 % don't check for dropped fram on first frame, because there may be a period of blankBackground before
            if (vbl-vbllast) > FrameInt*1.5;
                ndropframes = ndropframes + 1 ;
            end % define dropped frame
        end
        vbllast = vbl;

        % BA USer Control stimulus and mask with keyboard and mouse
        if ~handles.UCparams.lockMask
            [handles.UCparams.mX, handles.UCparams.mY, handles.UCparams.buttons] = GetMouse;
        end

        [keyIsDown, secs, keyCode] = KbCheck;
        % REMOVED BECAUSE is too slow (sometimes fscanf takes 15 ms (though
        % mostly 5ms), maybe pnet is better, or figure out how to make call
        % back work by setting Priority lower?
        %         if  && ~ mod(f,10)
        %
        %             tic
        %             s = fscanf(handles.uR);
        %             toc
        %             bgotRemoteData = 0;
        %             if ~isempty(s); % if got remote input put in keyCode formation if a number  otherwise ignore
        %                 if ~isempty(regexp(s, '\d'));
        %                     temp = str2num(s);
        %                     if temp<=size(keyCode,2)
        %                         keyCode(:) = 0; keyCode(temp) = 1; % remote input overrides local key press
        %                         bgotRemoteData = 1;
        %                         fwrite(handles.uR,'ok'); %
        %                     else
        %                         fwrite(handles.uR,'-1'); %
        %                     end
        %                 end
        %             end
        %         end

        if isempty(lastsecs)|( secs -lastsecs) >= 1/10; % set a maximum rate at which a key can be pressed otherwise holding button makes bar spin to fast
            if keyIsDown  %%% charavail would be much better, but doesn't seem to work
                lastsecs= secs;
                handles.UCparams = helperUserControl(keyCode,handles.UCkeys,handles.UCparams,params);
            end
        end
    end

    function switchStimHelper()
        bsavefliptimes = 0; % set to 1 to store flip times
        % currently only 1 for movies
        switch stim
            %% TO DO BA added box in corner of screen that flips from gray to white
            %% whenever fram changes
            %%%%%%  drifting and counterphase gratings %%%%%
            case {1,6}
                % screen_gamma=2;
                textures = zeros(params.nCond,1);
                for c = 1:params.nCond
                    if get(handles.StimType,'Value')==1   %%% drift vs counterphase
                        condNAME = 'Drifting Gratings';% BA

                        %% NOTE %%% THIS clut METHOD introduces weird artifacts on the
                        %% screen,(should remove it from other stimuli too)
                        % originally removed by because rotation wasn't working now kinda works with rotation, but sometimes doesn't
                        %% dosen't seem to create cl right?? get phase but no
                        %% sinusiod
                        imgSz = [imageRect(3)*2,imageRect(4)*2];
                        % Change clut for square gratings
                        if (get(handles.squaregratings,'Value')) % BA DOESTN WORK
                            [img cl] = generateSqGratings_lut(handles.orient(c),handles.freq(c),handles.TempFreq(c),handles.phase(c),handles.contrast(c),Duration, degPerPix,imgSz(1),imgSz(2),FrameHz,black,white,sizeLut);
                        else

                            [img cl] = generateGratings_lut(handles.orient(c),handles.freq(c),handles.TempFreq(c),handles.phase(c),handles.contrast(c),Duration, degPerPix,imgSz(1),imgSz(2),FrameHz,black,white,sizeLut);
                        end
                        destRect = windowRect;
                    else
                        [img cl] = generateCPGratings_lut(handles.orient(c),handles.freq(c),handles.TempFreq(c),handles.phase(c),handles.contrast(c),Duration, degPerPix,imageRect(3),imageRect(4),FrameHz,black,white,sizeLut);
                        condNAME = 'Counterphase Gratings';% BA

                    end
                    if exist('cl','var')
                        if c==1
                            cluts = zeros(256,3,size(cl,3),params.nCond);
                        end
                        cluts(:,:,:,c)=floor(cl);
                        textures(c,1)=Screen('MakeTexture',window,img);
                    end
                end %cond
                fprintf('done generating')
                WAITTIME = 0; %BA
                FrameWait=1;


                %%%%% checkerboard  %%%%%%%%%%
            case 5
                condNAME = 'checkerboard';% BA

                params.nCond = size(handles.freq,2);
                textures = zeros(params.nCond,1);
                for c = 1:params.nCond
                    [x y]= meshgrid(1:imageRect(3), 1:imageRect(4));
                    contrast = handles.contrast(c);
                    f= 2*pi*handles.freq(c)* degPerPix;
                    img = 1+sign(sin(f*x).*sin(f*y));
                    if contrast>1
                        contrast=1;
                    end

                    inc=(white-grey)*contrast;

                    cl = offclut;
                    cl(1,:) = grey-inc;
                    cl(2,:) = grey+inc;
                    cl(3,:) = grey+inc;

                    fprintf('done generating')
                    if c==1
                        cluts = zeros(256,3,size(cl,3),params.nCond);
                    end
                    cluts(:,:,:,c)=floor(cl);
                    textures(c,1)=Screen('MakeTexture',window,img);
                end
                FrameWait = ceil(Duration*FrameHz);

                %%%%%%%  fullfield flash %%%%%%%%
            case 4 %
                condNAME = 'fullfield flash';% BA

                offclut(:,:)=black;
                textures = zeros(params.nCond,1);
                for c = 1:params.nCond
                    img = ones(imageRect(4), imageRect(3));
                    cl  = offclut;
                    cl(:,:) = floor(white*handles.contrast(c));
                    fprintf('done generating')
                    if c==1
                        cluts = zeros(256,3,size(cl,3),params.nCond);
                    end
                    cluts(:,:,:,c)=floor(cl);
                    textures(c,1)=Screen('MakeTexture',window,img);
                end % cond
                FrameWait = ceil(Duration*FrameHz);

                %%%%% drifting bars  %%%%%
            case 2
                condNAME = 'drifting bars';% BA

                textures = zeros(params.nCond,1);
                for c = 1:params.nCond

                    % uncommented bva   040208
                    frm = generateBars_blit(handles.orient(c),handles.freq(c),handles.speed(c),handles.contrast(c),handles.length(c), handles.positionX(c),Duration, degPerPix,imageRect(3),imageRect(4),FrameHz,black,white,2048);
                    nFrames = size(frm,1);
                    for f = 1:nFrames
                        textures(c,f)=Screen('MakeTexture',window,squeeze(frm(f,:,:)));
                    end
                    MovieRate = FrameHz;
                    destRect = windowRect;
                    clut=0;
                    if c==1
                        save frames frm
                    end
                    %                                 end of uncomment bva 040208

                    %******* commented bva 040208
                    %                     [img cl] = generateBars_lut(handles.orient(c),handles.freq(c),handles.speed(c),handles.contrast(c),handles.length(c), handles.positionX(c),Duration, degPerPix,imageRect(3),imageRect(4),FrameHz,black,white,sizeLut);
                    %                     fprintf('done generating')
                    %                     if c==1
                    %                         cluts = zeros(256,3,size(cl,3),params.nCond);
                    %                     end
                    %                     cluts(:,:,:,c)=floor(cl);
                    %                     textures(c,1)=Screen('MakeTexture',window,img);
                    %                     % %******* end of bva comment 040208

                    % black background
                    %offclut(:) = grey - (white-grey)*handles.contrast(c);
                end % cond
                FrameWait = 1;

                %%% flashing spots  %%%%%%%
            case 7
                condNAME = 'flashing spots';% BA

                params.nCond = size(handles.freq,2);
                textures = zeros(params.nCond,1);
                for c = 1:params.nCond
                    [x y]= meshgrid(1:imageRect(3), 1:imageRect(4));
                    contrast = handles.contrast(c);
                    widthPix = handles.length(c)/degPerPix;
                    posXpix = imageRect(3)/2 + handles.positionX(c)/degPerPix;
                    posYpix = imageRect(4)/2 + handles.positionY(c)/degPerPix;

                    img = double((x>(posXpix-widthPix/2)) & (x<(posXpix+widthPix/2)) & (y>(posYpix-widthPix/2)) & (y<(posYpix+widthPix/2)));
                    if contrast>1
                        contrast=1;
                    end
                    inc = (white-grey)*contrast;
                    cl = offclut;
                    cl(2,:) = grey+inc;

                    %%% non-grey background
                    cl(1,:) = grey-0.75*inc;
                    offclut(:) = grey - 0.75*inc;
                    fprintf('done generating')

                    if c==1
                        cluts = zeros(256,3,size(cl,3),params.nCond);
                    end
                    cluts(:,:,:,c)=floor(cl);
                    textures(c,1)=Screen('MakeTexture',window,img);
                end % cond
                FrameWait = ceil(Duration*FrameHz);

                %%%%% movie %%%%%
            case 3
                bsavefliptimes = 1;
                load(get(handles.MovieName,'String'),'moviedata');
                condNAME = 'movie';% BA

                MovieMag = str2double(get(handles.MovieMag,'String'));
                MovieRate = str2double(get(handles.MovieRate,'String'));
                phasePeriod = str2double(get(handles.phasePeriod,'String'));

                % done loading movie

                length = str2double(get(handles.Length0,'String'));
                if length > 0
                    length = length/MovieMag;
                    length = length/degPerPix;
                    moviedata = moviedata(1:round(length),:,:); %#ok
                end


                %         moviedata = moviedata(:,:,1:298); % BA just take a subset of the movie (%each part is 300 frames long)
                nFrames = size(moviedata,3);

                % fractional nReps truncates movie
                if (nReps < 1)
                    nFrames = min(nFrames,floor(nFrames*nReps));
                    nReps = 100000000;  %%%%% fix this
                end

                %% if multiple stimulus groups specified, break up movies into different stimulus conditions
                % period of the stimulus (i.e. one phase cycle)
                phasePeriodFrames = MovieRate * phasePeriod;
                if phasePeriodFrames == 0
                    phasePeriodFrames = nFrames;
                end
                % stimulus groups CURRENTLY NOT SUPPORTED BA
                %                 % number of different stimulus groups contained in movie, default 1
                %                 % this does not constrain the number of repetitions in a group, which
                %                 % is set by Duration and phasePeriodFrames
                stimgroups =str2double(get(handles.stimulusGroups,'String'));
                params.nCond = stimgroups;
                %                 if params.nCond > 1
                %                     % number of repetitions of each stimulus in one group
                %                     nStimulusRepetitions = (nFrames/phasePeriodFrames) / params.nCond;
                %                     disp(sprintf('%.1f conditions, %.1f stimuli per condition',params.nCond,nStimulusRepetitions));
                %                     if (nStimulusRepetitions ~= floor(nStimulusRepetitions)) % must be integer
                %                         error('Movie not evenly divisible; is number of stimulus groups wrong?');
                %                     end
                %                 else
                %                     params.nCond = size(handles.freq,2);   %%% if only one stimulus group, then use variables to set params.nCond
                %                 end

                imageRect = SetRect(0,0,size(moviedata,1),size(moviedata,2));
                destRect = CenterRect(MovieMag*imageRect,windowRect);
                x0 = str2double(get(handles.PositionX0,'String'));
                if x0 ~= 0
                    dx = x0/degPerPix;
                    destRect = offsetrect(destRect,dx,0);
                end

                textures = zeros(1,nFrames);
                for f=1:nFrames
                    textures(1,f)=Screen('MakeTexture',window,squeeze(moviedata(:,:,f))');
                end
                clear moviedata

                FrameWait = FrameHz/MovieRate;
                WAITTIME = 4; % BA this is a clug only relavent when clut=0 to make sure that DAQ side caputures the begining of the next stimulus presentation.
                %         % DAQ can miss trigger sometimes when acquiring very long, large
                %         files there is some time for saving etc.
        end
    end
end

% function remoteMasterKeyHandler(src,evnt,handles)
% %keyPressFcn automatically takes in two inputs
% %src is the object that was active when the keypress occurred
% %evnt stores the data for the key pressed
%
% %brings in the handles structure in to the function
% handles = guidata(src);
%
% k = evnt.Key; %k is the key that is pressed
% keyCode = KbName(evnt.Key); % convert to right name for Psychtoolbox
% S = fscanf(handles.uR); % get an okay if was recieved
% if isequal(S,'ok');
%     %     error('ERROR: No response from communicating with slave')
%     stat = 0;
% else
%     display('COMM ERROR: No response from communicating  slave')
% end
%
% end
function frameChangeBox(window,imageRect,setc)
% function to add box to corner of screen. box switches everytime fucntion
% is called. use to monitor frame changes. ie. call just before each flip, thus provides an location where a photodiode can monitor the
% frame changes (EF's idea)
persistent c;

if nargin>2, c=setc;
else
    if isempty(c)||c~=128;
        c = 128;
    else
        c = 255;
    end
end
Screen('FillRect',window,c,[imageRect(3)-50 imageRect(4)-50 imageRect(3) imageRect(4)]);

end

function SaveParams_Callback(hObject, eventdata, handles) %#ok

[fname, pname] = uiputfile('*.mat','Parameter File',handles.USER.paramdirpath);
if (fname == 0), return; end % canceled

fname = fullfile(pname,fname);
SaveParams(handles,fname);

handles.USER.paramdirpath = pname;
end

%--- function to save parameters, called by SaveParams, or on Run_Btn
function SaveParams(handles,fname)
psychstimctrlparams = getParams(handles); % NOTE: the name of this variable can't be changed without effecting getPsychStimParameters.m
save(fname, 'psychstimctrlparams');
end

function LoadParams_Callback(hObject, eventdata, handles) %#ok

[fname, pname] = uigetfile('*.mat','Parameter File',handles.USER.paramdirpath);
if (fname == 0)
    return;
end % canceled

lstvar = whos; lstvar = {lstvar.name};% list of variable before loaded (for creating struct below)
load(fullfile(pname,fname));

if ~exist('psychstimctrlparams','var'); % new format is struct (create struct for backwards compatiblity)
    lstvar2 = whos; lstvar2 = {lstvar2.name};% find list off all variables including loaded
    lstvar(end+1) = {'psychstimctrlparams'}; % exclude this variable too
    ind = find(~ismember(lstvar2,lstvar));
    for i =1:size(ind,2);
        s = sprintf('psychstimctrlparams.%s = %s;', lstvar2{ind(i)},lstvar2{ind(i)});
        eval(s);
    end
end
setParams(handles,eventdata,psychstimctrlparams);
handles.USER.paramdirpath = pname;
end

function params = getParams(handles)
% get all values and put into struct
% make sure fieldname is same as name in struct
params.Orient0 = str2double(get(handles.Orient0,'String')); %#ok
params.Freq0 = str2double(get(handles.Freq0,'String')); %#ok
params.Speed0 = str2double(get(handles.Speed0,'String')); %#ok
params.Contrast0 = str2double(get(handles.Contrast0,'String')); %#ok
params.TempFreq0 = str2double(get(handles.TempFreq0,'String')); %#ok
params.Duration= str2double(get(handles.Duration,'String')); %#ok
params.Phase0 = str2double(get(handles.Phase0,'String')); %#ok
params.Length0 = str2double(get(handles.Length0,'String')); %#ok
params.PositionX0 = str2double(get(handles.PositionX0,'String')); %#ok
params.PositionY0 = str2double(get(handles.PositionY0,'String')); %#ok
params.WaitInterval = str2double(get(handles.WaitInterval,'String')); %#ok
params.PreWaitInt = str2double(get(handles.PreWaitInt,'String')); %#ok
if isfield(handles,'eyeCond0')
    params.eyeCond0 = str2double(get(handles.eyeCond0,'String'));
else
    params.eyeCond0 = 0;
end; % removed eye (left this for backward compatibility)

params.StimulusStr = get(handles.StimType,'String'); %#ok
params.StimulusNum = get(handles.StimType,'Value'); %#ok

params.PixelsX = str2double(get(handles.PixelsX,'String')); %#ok
params.PixelsY = str2double(get(handles.PixelsY,'String')); %#ok
params.SizeX = str2double(get(handles.SizeX,'String')); %#ok
params.SizeY = str2double(get(handles.SizeY,'String')); %#ok
params.ScreenDist = str2double(get(handles.ScreenDist,'String')); %#ok

params.Var1Str = get(handles.Var1,'String'); %#ok
params.Var1Val = get(handles.Var1,'Value'); %#ok

params.Start1 = str2double(get(handles.Start1,'String')); %#ok
params.Stop1 = str2double(get(handles.Stop1,'String')); %#ok
params.nSteps1 = str2double(get(handles.nSteps1,'String')); %#ok
params.LinLog1 = get(handles.LinLog1,'Value'); %#ok

params.Var2Str = get(handles.Var2,'String'); %#ok
params.Var2Val = get(handles.Var2,'Value'); %#ok

params.Start2 = str2double(get(handles.Start2,'String')); %#ok
params.Stop2 = str2double(get(handles.Stop2,'String')); %#ok
params.nSteps2 = str2double(get(handles.nSteps2,'String')); %#ok
params.LinLog2 = get(handles.LinLog2,'Value'); %#ok

params.MovieName = get(handles.MovieName,'String'); %#ok
params.MovieMag = str2double(get(handles.MovieMag,'String')); %#ok
params.MovieRate = str2double(get(handles.MovieRate,'String')); %#ok
params.phasePeriod = str2double(get(handles.phasePeriod,'String')); %#ok
params.stimulusGroups = str2double(get(handles.stimulusGroups,'String')); %#ok

params.blankbkgrnd = get(handles.bkgrnd,'Value'); %#ok
params.randomize = get(handles.randomize,'Value'); %#ok
params.blankstim = get(handles.blankstim,'Value'); %#ok
params.FullFlicker = get(handles.FullFlicker,'Value'); %#ok
params.nReps = get(handles.nReps,'String'); %#ok

params.orient = handles.orient; %#ok
params.spfreq = handles.freq; %#ok
params.speed = handles.speed; %#ok
params.contrast = handles.contrast; %#ok
params.phase = handles.phase; %#ok
params.TempFreq = handles.TempFreq; %#ok
params.positionX = handles.positionX; %#ok
params.positionY = handles.positionY; %#ok
params.length = handles.length; %#ok
params.squaregratings = get(handles.squaregratings,'Value'); %#ok

% mask BA
params.maskstr = get(handles.popmenuMask,'String'); %#ok
params.popmenuMask = get(handles.popmenuMask,'Value');
params.maskcenterx =  get(handles.maskcenterx,'String');
params.maskcentery = get(handles.maskcentery,'String');
params.maskcenterdeg = get(handles.maskcenterdeg,'String');
params.maskradiusx = get(handles.maskradiusx,'String');
params.maskradiusy =get(handles.maskradiusy,'String');
params.maskmeanradiusdeg = get(handles.maskmeanradiusdeg,'String');
end

function setParams(handles,eventdata,params)

set(handles.StimType,'Value',params.StimulusNum);
set(handles.Orient0,'String',num2str(params.Orient0));
set(handles.Freq0,'String',num2str(params.Freq0));
set(handles.Speed0,'String',num2str(params.Speed0));
set(handles.Contrast0,'String',num2str(params.Contrast0));
set(handles.Duration,'String',num2str(params.Duration));

set(handles.PixelsX,'String',num2str(params.PixelsX));
set(handles.PixelsY,'String',num2str(params.PixelsY));
set(handles.SizeX,'String',num2str(params.SizeX));
set(handles.SizeY,'String',num2str(params.SizeY));
set(handles.ScreenDist,'String',num2str(params.ScreenDist));

set(handles.Var1,'Value',params.Var1Val);
set(handles.Start1,'String',num2str(params.Start1));
set(handles.Stop1,'String',num2str(params.Stop1));
set(handles.nSteps1,'String',num2str(params.nSteps1));
set(handles.LinLog1,'Value',params.LinLog1);

set(handles.Var2,'Value',params.Var2Val);
set(handles.Start2,'String',num2str(params.Start2));
set(handles.Stop2,'String',num2str(params.Stop2));
set(handles.nSteps2,'String',num2str(params.nSteps2));
set(handles.LinLog2,'Value',params.LinLog2);

set(handles.MovieName,'String',params.MovieName);
set(handles.MovieMag,'String',num2str(params.MovieMag));
set(handles.MovieRate,'String',num2str(params.MovieRate));

set(handles.TempFreq0,'String',num2str(params.TempFreq0));
set(handles.Phase0,'String',num2str(params.Phase0));

set(handles.randomize,'Value',params.randomize);
set(handles.blankstim,'Value',params.blankstim);
set(handles.bkgrnd,'Value',params.blankbkgrnd);
set(handles.Length0,'String',num2str(params.Length0));
set(handles.WaitInterval,'String',num2str(params.WaitInterval));

if isfield(params,'PreWaitInt') % %BA 062310
    set(handles.PreWaitInt,'String',num2str(params.PreWaitInt));
end

set(handles.PositionX0,'String',num2str(params.PositionX0));
set(handles.PositionY0,'String',num2str(params.PositionY0));
set(handles.FullFlicker,'Value',params.FullFlicker);
set(handles.nReps,'String',num2str(params.nReps));
set(handles.phasePeriod,'String',num2str(params.phasePeriod));
set(handles.stimulusGroups,'String',num2str(params.stimulusGroups));
set(handles.squaregratings,'Value',params.squaregratings);

if isfield(params,'popmenuMask') % %BA 081909
    set(handles.popmenuMask,'Value',params.popmenuMask);
    set(handles.maskcenterx,'String',params.maskcenterx);
    set(handles.maskcentery,'String',params.maskcentery);
    set(handles.maskcenterdeg,'String',params.maskcenterdeg);
    set(handles.maskradiusx,'String',params.maskradiusx);
    set(handles.maskradiusy,'String',params.maskradiusy);
    set(handles.maskmeanradiusdeg,'String',params.maskmeanradiusdeg);
end

handles =  guidata(handles.hPsychStimController);
StimType_Callback(handles.StimType,eventdata,handles);
end

function TempFreq0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function Phase0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function Orient0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function Freq0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function Speed0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function Contrast0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function Var1_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1 %none
    set(handles.Start1,'Enable','off');
    set(handles.Stop1,'Enable','off');
    set(handles.nSteps1,'Enable','off');
    set(handles.LinLog1,'Enable','off');
    set(handles.Var1Range,'Enable','off');
else

    set(handles.Start1,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Stop1,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.nSteps1,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.LinLog1,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Var1Range,'Enable','on','ForegroundColor',[1 0 0]);
end

% WeightContrast only makes sense for Contrast
if get(handles.Var2,'Value')==5 || get(handles.Var1,'Value')==5%contrast
    if get(handles.randomize,'Value')
        set(handles.chbxWeightContrast,'Enable','on','ForegroundColor',[1 0 0]);
    else
        set(handles.chbxWeightContrast,'Enable','off');
    end
end

Var1Range_Callback(handles.Var1Range,eventdata,handles);

end

function Var2_Callback(hObject, eventdata, handles)

if get(hObject,'Value')==1 %none
    set(handles.Start2,'Enable','off');
    set(handles.Stop2,'Enable','off');
    set(handles.nSteps2,'Enable','off');
    set(handles.LinLog2,'Enable','off');
    set(handles.Var2Range,'Enable','off');

else
    set(handles.Start2,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Stop2,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.nSteps2,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.LinLog2,'Enable','on','ForegroundColor',[1 0 0]);
    set(handles.Var2Range,'Enable','on','ForegroundColor',[1 0 0]);
end

% WeightContrast only makes sense for Contrast
if get(handles.Var2,'Value')==5 || get(handles.Var1,'Value')==5 %contrast
    set(handles.chbxWeightContrast,'Enable','on','ForegroundColor',[1 0 0]);
else
    set(handles.chbxWeightContrast,'Enable','off');
end

Var2Range_Callback(handles.Var2Range,eventdata,handles);
end

function LinLog1_Callback(hObject, eventdata, handles) %#ok
Var1_Callback(handles.Var1, eventdata, handles);
end

function Start1_Callback(hObject, eventdata, handles) %#ok

Var1_Callback(handles.Var1, eventdata, handles);
end

function Stop1_Callback(hObject, eventdata, handles) %#ok
Var1_Callback(handles.Var1, eventdata, handles);
end

function nSteps1_Callback(hObject, eventdata, handles) %#ok
Var1_Callback(handles.Var1, eventdata, handles);
end

function Start2_Callback(hObject, eventdata, handles) %#ok
Var2_Callback(handles.Var2, eventdata, handles);
end

function Stop2_Callback(hObject, eventdata, handles) %#ok
Var2_Callback(handles.Var2, eventdata, handles);

end

function nSteps2_Callback(hObject, eventdata, handles) %#ok
Var2_Callback(handles.Var2, eventdata, handles);
end

function LinLog2_Callback(hObject, eventdata, handles) %#ok
Var2_Callback(handles.Var2, eventdata, handles);
end

function Var1Range_Callback(hObject, eventdata, handles) %#ok

nSteps1 = str2double(get(handles.nSteps1,'String'));
Start1 = str2double(get(handles.Start1,'String'));
Stop1 = str2double(get(handles.Stop1,'String'));

variscircular = 0;
if (get(handles.Var1,'Value')) == 2 && (Start1 == 0) && (Stop1 == 360)
    variscircular = 1; % orientation
end

if get(handles.LinLog1,'Value')==1
    if variscircular
        Var1Range = linspace(Start1, Stop1, nSteps1+1);
        Var1Range = Var1Range(1:end-1);
    else
        Var1Range = linspace(Start1, Stop1, nSteps1);
    end
else
    Var1Range = logspace(log10(Start1), log10(Stop1), nSteps1);
end
set(hObject,'String',mat2str(Var1Range,3));

[handles.orient handles.freq handles.speed handles.contrast handles.phase ...
    handles.TempFreq handles.var1value handles.var2value handles.positionX handles.positionY handles.length handles.eye] = generateVarParams(handles);

codes = [0 4 23 10 13 24 18 7 8 22];
handles.var1code = codes(get(handles.Var1,'Value'));
handles.var2code = codes(get(handles.Var2,'Value'));

guidata(handles.hPsychStimController,handles);
end

function Var2Range_Callback(hObject, eventdata, handles) %#ok
nSteps2 = str2double(get(handles.nSteps2,'String'));
Start2 = str2double(get(handles.Start2,'String'));
Stop2 = str2double(get(handles.Stop2,'String'));

variscircular = 0;
if (get(handles.Var2,'Value')) == 2 && (Start2 == 0) && (Stop2 == 360)
    variscircular = 1; % orientation
end

if get(handles.LinLog2,'Value')==1
    if variscircular
        Var2Range = linspace(Start2, Stop2, nSteps2+1);
        Var2Range = Var2Range(1:end-1);
    else
        Var2Range = linspace(Start2, Stop2, nSteps2);
    end
else
    Var2Range = logspace(log10(Start2), log10(Stop2), nSteps2);
end
set(hObject,'String',mat2str(Var2Range,3));

[handles.orient handles.freq handles.speed handles.contrast handles.phase ...
    handles.TempFreq handles.var1value handles.var2value handles.positionX handles.positionY handles.length handles.eye] = generateVarParams(handles);

codes = [0 4 23 10 13 24 18 7 8  22];
handles.var1code =codes(get(handles.Var1,'Value'));
handles.var2code =codes(get(handles.Var2,'Value'));

guidata(handles.hPsychStimController,handles);
end

function MovieName_Callback(hObject, eventdata, handles) %#ok
updateparamsfrommovie(get(hObject,'String'),handles);
end

function SelectMovieName_Callback(hObject, eventdata, handles) %#ok

[fname pname] = uigetfile('.mat','Movie Name',handles.USER.moviedirpath);
if (fname == 0)
    return;
end

fullmoviename = fullfile(pname,fname);
handles.USER.moviedirpath = pname;

set(handles.MovieName,'String',fullmoviename);

updateparamsfrommovie(fullmoviename,handles);
end

function ScreenNum_Callback(hObject, eventdata, handles) %#ok

FrameHz_Callback(handles.FrameHz,eventdata,handles);
PixelsX_Callback(handles.PixelsX,eventdata,handles);
PixelsY_Callback(handles.PixelsY,eventdata,handles);

end

function PixelsX_Callback(hObject, eventdata, handles) %#ok

end

function PixelsY_Callback(hObject, eventdata, handles) %#ok

% screennums = Screen('Screens'); % if there is just one monitor use that unstaed of th default monitor
% if length(screennums)==1; % checkk if more than 1 monitor exists
%     set(handles.ScreenNum,'String',num2str(screennums))
% end
end

function rc_slaveudpcallback(obj,eventdata,handles) % HOW TO GET handles into call back
% remote control works in 2 modes
% master and slave. in  both modes commands are sent as datagrams (each fwrite command is 1
% datagram)and a callbackfunction is activated on the slave side when the master
% sends a datagram.
% the first line of a datagram contains the command to be executed.
% The next lines contains data transmitted (if data transmission is required by command).
% e.g. UPDATEDATA or RUN

handles =  guidata(handles.hPsychStimController); % must update old version of handles may be pasted in
S = fscanf(obj);
[splits, splits, splits, splits, splits, splits, splits]  = regexp(S,'\n'); %delimiter
fwrite(obj,'ok')

%parse to get COMMAND
cmd= splits{1,1}; % first line contains command

switch cmd
    case 'UPDATEDATA'
        params = rc_udprecieveParams(splits(2:end));
        setParams(handles,eventdata,params);
    case 'RUN'
        RunBtn_Callback(handles.RunBtn, eventdata, handles)
    case 'STOP'
        %         TODO
        % handles.UCparams.Stim~
        % handles.UCparams.break
        %  UPDATE handles
        % M
end

end

function chkRemote_Callback(hObject, eventdata, handles)
rchelper(hObject,eventdata,handles)
end

function rchelper(obj,eventdata,handles)
if get(handles.chkRemote,'Value') % remote control ond
    set([handles.text23,handles.ScreenNum, handles.PixelsX, handles.PixelsY, handles.text16, handles.text17,  handles.SizeY, handles.SizeX, handles.text17, handles.ScreenDist, handles.text15, handles.FrameHz, handles.text24]...
        ,'Enable','off');

    % setup defaults for Remote control IP and ports
    if isempty(get(handles.remoteIP,'String'))
        set(handles.remoteIP,'String',[handles.USER.PSC_REMOTECONTROL_REMOTEPC_IP ':' handles.USER.PSC_REMOTECONTROL_REMOTEPC_PORT]);
    end
    if isempty(get(handles.LocalIP,'String'))
        set(handles.LocalIP,'String',['localhost:' handles.USER.PSC_REMOTECONTROL_LOCALPC_PORT]);
    end

    handles = initRemoteControludp();

    set(handles.toggleMaster,'Enable','on');
    set(handles.LocalIP,'Enable','on');
    set(handles.remoteIP,'Enable','on');
    set(handles.remoteUpdate,'Enable','on');

    if ~get(handles.toggleMaster,'Value') % SLAVE mode
        toggleenable('off')
        set(handles.remotetext,'String','SLAVE','ForegroundColor','Blue','FontSize',14,'FontWeight','normal');

        % TODO disable the rest
    else % MASTER MODE
        toggleenable('on')
        set(handles.remotetext,'String','MASTER','ForegroundColor','Green','FontSize',14,'FontWeight','normal');

    end
else  % LOCAL
    set([handles.text23,handles.ScreenNum, handles.PixelsX, handles.PixelsY, handles.text16, handles.text17,  handles.SizeY, handles.SizeX, handles.text17, handles.ScreenDist , handles.text15, handles.FrameHz, handles.text24]...
        ,'Enable','on');
    set([handles.LocalIP, handles.remoteIP, handles.remoteUpdate,handles.toggleMaster],'Enable','off');
    toggleenable('on')
    set(handles.remotetext,'String','Local','ForegroundColor','Black','FontSize',14,'FontWeight','normal');

end
end

function toggleenable(state)
set([handles.StimType, handles.Orient0,handles.Speed0,handles.Speed0,handles.Freq0,handles.Contrast0,handles.PositionX0,handles.PositionY0,...
    handles.Length0,handles.Duration,handles.SelectMovieName,handles.MovieName, handles.MovieMag, handles.MovieRate,handles.phasePeriod,...
    handles.stimulusGroups,handles.TempFreq0,handles.Phase0,handles.Start2,handles.Stop2,handles.nSteps2,handles.LinLog2,handles.Var2Range,handles.WaitInterval,...
    handles.bkgrnd, handles.squaregratings, handles.blankstim,handles.randomize, handles.FullFlicker, handles.nReps,...
    handles.remoteUpdate, handles.LoadParams,  handles.SaveParams,  handles.RunBtn, handles.Var1,handles.Var2, handles.Start1, handles.Start2,...
    handles.Stop1, handles.Stop2, handles.nSteps1, handles.nSteps2, handles.LinLog1, handles.LinLog2, handles.Var1Range, handles.Var2Range],...
    'Enable',state, 'ForegroundColor',[0 0 0])   ;
if isequal(state,'on')
    StimType_Callback(handles.StimType,eventdata,handles);
end
end

% SEND updated GUI info to remote PC
function remoteUpdate_Callback(hObject, eventdata, handles)
rc_udpsend(handles,'update');
end

function toggleMaster_Callback(hObject, eventdata, handles)
rchelper(hObject,eventdata,handles);
end

function LocalIP_Callback(hObject, eventdata, handles)
end

function rc_masterudpcallback(obj,eventdata,handles)
% TO DO ADD printing of command window text from SLAVE

s = fscanf(handles.uR);
if ~isempty(strfind(s,'stimend'))
    set(handles.remotetext,'String','MASTER: Remote slave quit','ForegroundColor','Green','FontSize',10,'FontWeight','normal');
    fwrite(handles.uR,'ok')
end
% disp('in master remote callback')
end

function bkgrnd_Callback(hObject, eventdata, handles)
end

function squaregratings_Callback(hObject, eventdata, handles)
end

function WaitInterval_Callback(hObject, eventdata, handles)
end

function Duration_Callback(hObject, eventdata, handles)
end

function popmenuMask_Callback(hObject, eventdata, handles)
end

function maskcenterx_Callback(hObject, eventdata, handles)
end

function maskcentery_Callback(hObject, eventdata, handles)
end

function SizeX_Callback(hObject, eventdata, handles)
end

function SizeY_Callback(hObject, eventdata, handles)
end

function FullFlicker_Callback(hObject, eventdata, handles)
end

function blankstim_Callback(hObject, eventdata, handles)
end

function randomize_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    if get(handles.Var2,'Value')==5 || get(handles.Var1,'Value')==5%contrast
        set(handles.chbxWeightContrast,'Enable','on')
    end
else
    set(handles.chbxWeightContrast,'Enable','off')
end
end

function nReps_Callback(hObject, eventdata, handles)
end

function chbxbinterleave_Callback(hObject, eventdata, handles)
end

function chbxWeightContrast_Callback(hObject, eventdata, handles)
end

function Length0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function PositionX0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function FrameHz_Callback(hObject, eventdata, handles) %#ok

end

function PositionY0_Callback(hObject, eventdata, handles) %#ok
StimType_Callback(handles.StimType,eventdata,handles);
end

function updateparamsfrommovie(fullmoviename,handles)

% update variables after select
load(fullmoviename,'MovieMag','MovieRate','period_sec');

if exist('MovieMag','var')
    % movie meta-data variables saved:
    %  'duration_sec','period_sec','MovieMag','MovieRate','screenDistanceCm'

    set(handles.MovieMag,'String',num2str(MovieMag)); %#ok
    set(handles.MovieRate,'String',num2str(MovieRate)); %#ok
    set(handles.phasePeriod,'String',num2str(period_sec)); %#ok

    % other variables that could be saved:
    % duration_sec (default is to play whole movie)
    % screenDistanceCm (irrelevant for movies)
    % xsize (no ysize)
end
end

% --- Remote control functions --- %

function stat = rc_udpsend(handles,scommand)
% send GUI values to remote Slave
% values are sent from a struct (struct array is not supported) in the form of a string.
% where each field of the struct is a row in the string. where the field
% name and value are seperated by a space.
% e.g. params.freq0 = 1;
%      params.Var1 = [1:5];
%  would be sent as:
%        freq0 1
%        Var1 1 2 3 4 5
%
% an response of "ok" is expected back from the slave after it recieves the string
handles.uR.DatagramReceivedFcn =''; % temporarily disable callback
stat = 0;
switch (scommand)
    case 'run'
        updatehelper
        stat = udpcommhelper(handles.uR,sout);
        if stat
            sout = sprintf('RUN');
            stat =  udpcommhelper(handles.uR,sout);
        else disp('ERROR: communicating with remote PC cannot run'); end
    case 'update'
        updatehelper
        stat = udpcommhelper(handles.uR,sout);
end


% TO DO (currently this function does nothing)
handles.uR.DatagramReceivedFcn ={@rc_masterudpcallback,handles}; % reenable callback
    function updatehelper
        params = getParams(handles);
        fldn = fieldnames(params);
        sout = sprintf('UPDATEDATA\n');
        for i = 1:length(fldn)
            temp = params.(fldn{i});
            if ~iscell(temp)   % NOTE, right now can't send matrixes, or anything (e.g. substructs, cells) that is not a string
                % or a vector
                sout = sprintf('%s%s %s\n',sout,fldn{i},num2str(temp));
            end
        end
    end
end

function stat = udpcommhelper(uR,sout)
fwrite(uR,sout);
S = fscanf(uR); % get an okay if was recieved
if ~isequal(S,'ok');
    disp(['ERROR: No response from communicating with slave' sout(1:min(end,10))])
    stat = 0;
else
    stat = 1;
end
end

function masktex =  helperMakeMask(rx,ry,window,masktype)
% BA
tic
[width, height]=Screen('WindowSize', window);

width = width*2.1;% height a width multipled by 2.1 to make mask can be moved anywhere in the
height = height*2.1;
% screen and still mask
white = WhiteIndex(window);
black = BlackIndex(window);
grey = round(0.5*(black+white));

% We create a Luminance+Alpha matrix for use as transparency mask:
[x,y]=meshgrid([1:width]-width/2,[1:height]-height/2);
% Layer 1 (Luminance) is filled with luminance value 'gray' of the
% background.
maskimg=ones(height,width,2) * grey;
% Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
% mask.

switch masktype % note param.nMask should equal to the number of cases
    case 0 % gaussianm
        maskimg(:,:,2)=255 - exp(-((x/rx).^2)-((y/ry).^2))*255;
    case 1 % eliptical aperature
        maskimg(:,:,2) = 255;
        maskimg((height/2-rx):(height/2+rx-1),(width/2-ry):(width/2+ry-1),2)= (~makeElipse(rx,ry))*255;
    case 2 % inverted eliptical aperature
        maskimg(:,:,2) = 0;
        maskimg((height/2-rx):(height/2+rx-1),(width/2-ry):(width/2+ry-1),2)= (makeElipse(rx,ry))*255;
    case 3 % no mask
        maskimg(:,:,2) = 0;
        %     case 4 % Working on cross grating
        %         Duration = str2double(get(handles.Duration,'String'));
        %         FrameHz = round(str2double(get(handles.FrameHz,'String')));
        %
        %         cnow = UCparams.c;
        %
        %         [frm]= generateGratings_blit(handles.orient(cnow),handles.freq(cnow),handles.TempFreq(cnow),handles.phase(cnow),handles.contrast(cnow),1/FrameHz,  handles.degPerPix,width,height,FrameHz,black,white);
        %         maskimg(:,:,2) = frm;
        %         maskimg((height/2-rx):(height/2+rx-1),(width/2-ry):(width/2+ry-1),2)= (~makeElipse(rx,ry))*255;
        %
end
% Build a single transparency mask texture:
masktex=Screen('MakeTexture', window, maskimg);
% masktex=Screen('MakeTexture', window, squeeze(frm));

% Screen('DrawTexture', window,masktex)
% Screen('Flip',window);
toc
end

function UCkeys = declareUCkeys()
% Set keys.
% UCkeys.rightKey = KbName('RightArrow');
% UCkeys.leftKey = KbName('LeftArrow');
UCkeys.commaKey = KbName('.>');
UCkeys.periodKey = KbName(',');
UCkeys.upKey = KbName('UpArrow');
UCkeys.downKey = KbName('DownArrow');
UCkeys.mKey = KbName('m');
UCkeys.spaceKey = KbName('space');
UCkeys.aKey = KbName('a');  % auto bautoChangeContrast
UCkeys.lKey = KbName('l');
UCkeys.escKey = KbName('ESCAPE');
UCkeys.buttons = 0; % When the user clicks the mouse, 'buttons' becomes nonzero.
UCkeys.strikeKey = KbName('`');
end

% TODO REMOVE UCParams.. (it is not in handles)
function UCparams = helperUserControl(keyCode,UCkeys,UCparams,params)
% function that handles key strokes during stimulus presentation
% UCkeys - user controlled keys
% UCparams - user controlled params (may be changed in this funciton)
% params - should not be changed in this function
%
% BA

% ADD rotation of texture

if keyCode(UCkeys.spaceKey) % next condition
    UCparams.c = UCparams.c+1;
    if UCparams.c > params.nCond
        UCparams.c = 1;
    end
elseif keyCode(UCkeys.commaKey) % rotate bar
    UCparams.rotation = mod(UCparams.rotation + 15,360);
elseif keyCode(UCkeys.periodKey) % rotate bar
    UCparams.rotation = mod(UCparams.rotation - 15,360);
elseif keyCode(UCkeys.upKey)
    UCparams.rx = min(UCparams.rx+params.rStep,params.RMAX);
    UCparams.ry = UCparams.rx; % ADD so that it doesn't have to creat new mask
    UCparams.masktex =  helperMakeMask(UCparams.rx,UCparams.ry,params.window,UCparams.masktype);
elseif keyCode(UCkeys.downKey)
    UCparams.rx = max(UCparams.rx-params.rStep,0);
    UCparams.ry = UCparams.rx;
    UCparams.masktex =  helperMakeMask(UCparams.rx,UCparams.ry,params.window,UCparams.masktype);
elseif keyCode(UCkeys.mKey)
    UCparams.masktype = UCparams.masktype+1;
    UCparams.masktype = mod(UCparams.masktype,params.nMasks);
    % to DO replace so that mask doesn't have to be
    % recalcualted
    UCparams.masktex =  helperMakeMask(UCparams.rx,UCparams.ry,params.window,UCparams.masktype);
elseif  keyCode(UCkeys.lKey) % toggle lock mask location
    UCparams.lockMask = ~UCparams.lockMask;
    if UCparams.lockMask
        showCursor;
    else
        hideCursor;
    end
elseif  keyCode(UCkeys.aKey) % toggle lock mask location
    UCparams.bautoChangeContrast = ~UCparams.bautoChangeContrast;
elseif  keyCode(UCkeys.escKey) % end after this condition es
    UCparams.doneStim = 1;
    keyspressed = KbName(find(keyCode));
    disp(sprintf('Exit on %s key pressed',keyspressed));
elseif  keyCode(UCkeys.strikeKey) % end immediately
    UCparams.break= 1;
    UCparams.doneStim = 1;
    keyspressed = KbName(find(keyCode));
    disp(sprintf('Exit on %s key pressed',keyspressed));
end

% NOTE do not do guidata update, so UCparams changes are not made a
% permenent in guihandles. if they were this probably wouls cary from run
% to run i.e. rotation in 1 run would carry over to the next not sure I
% want this
end

function params = rc_udprecieveParams(splits)
% recieves data from rc_udpsendParams in the form of a string and converts
% it back into a struct
try
    for i = 1:size(splits,2)-1
        % NOTE, right now can't send matrixes, or anything (e.g. substructs, cells) that is not a string
        % or a vector

        stemp= splits{1,i};
        ind = regexp(stemp,'\s'); ind = ind(1);
        params.(stemp(1:ind-1)) = stemp(ind+1:end);

        if ~any(isletter(params.(stemp(1:ind-1)))) % if not a string convert to vector
            params.(stemp(1:ind-1)) = str2num(params.(stemp(1:ind-1)));
        end
    end

catch
    i
end
end

function setupRemoteControl(hObject,handles)
% slave mode
if  ~(get(handles.toggleMaster,'Value'))
else

end
end

function handles = initRemoteControludp
handles =  guidata(gcbo);
s = get(handles.LocalIP,'String'); ind = regexp(s,':');
localport = str2num(s(ind+1:end));


s = get(handles.remoteIP,'String');
%     get IP and port
ind = regexp(s,':');

remotehost = s(1:ind-1); % Normally an IP Address
remoteport = str2num(s(ind+1:end));

budpexists = 1;
handles.uR = instrfind('Tag','RemoteControl_udp');
if isempty(handles.uR);    budpexists = 0;
elseif  ~isvalid(handles.uR)
    delete(handles.uR);
    budpexists = 0;
elseif isequal(handles.uR.Status,'open');               fclose(handles.uR); end

if ~budpexists % if not the same as current one create udp
    handles.uR = udp(remotehost,remoteport,'LocalPort',localport);
end
handles.uR.RemotePort = remoteport;
handles.uR.RemoteHost =remotehost;
handles.uR.Tag = 'RemoteControl_udp';
handles.uR.OutputBufferSize = 2^12; % for some reason these must be set after udp is created otherwise fields are ignored and defaults are used
handles.uR.InputBufferSize = 2^12;
handles.uR.Timeout = 5e-1; %

fopen(handles.uR);
%%set callback appropriate to master/slave
if ~get(handles.toggleMaster,'Value') % slave mode
    handles.uR.DatagramReceivedFcn =  {@rc_slaveudpcallback,handles};
    warning('off','instrument:fscanf:unsuccessfulRead') % turn off because is called constanly in main loop

else % master mode
    handles.uR.DatagramReceivedFcn ={@rc_masterudpcallback,handles};
    warning('on','instrument:fscanf:unsuccessfulRead')
end
guidata(handles.hPsychStimController,handles); % update handles

end
function sendParams_udp(u,handles)
% this function is overlapse woth rc_udpsend, but doesn't expect the
% closed-loop okays

% there are some problems wit this for some reason
% maskstr and blankbackground aren't being sent?
params = getParams(handles);
fldn = fieldnames(params);
sout = sprintf('UPDATEDATA\n');
for i = 1:length(fldn)
    %     fldn{i}
    temp = params.(fldn{i});
    if ~iscell(temp)   % NOTE, right now can't send matrixes, or anything (e.g. substructs, cells) that is not a string
        % or a vector
        sout = sprintf('%s%s %s\n',sout,fldn{i},num2str(temp));
    elseif isequal(fldn{i},'StimulusStr')
        sout = sprintf('%s%s %s\n',sout,'CurrentStimulusStr',temp{params.(fldn{i+1})});
    elseif isequal(fldn{i},'Var1Str')
        sout = sprintf('%s%s %s\n',sout,'CurrentVar1Str',temp{params.(fldn{i+1})});
    elseif isequal(fldn{i},'Var2Str')
        sout = sprintf('%s%s %s\n',sout,'CurrentVar2Str',temp{params.(fldn{i+1})});
    elseif isequal(fldn{i},'maskstr')
        sout = sprintf('%s%s %s\n',sout,'CurrentMaskStr',temp{find(params.(fldn{i+1}))});
    else % don't send
        %         temp
    end
end
% sout
fwrite(u,sout);

end

% --- Create functions --- %

function remoteIP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function StimType_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function TempFreq0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function LocalIP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function WaitInterval_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function PixelsX_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end
function ScreenNum_CreateFcn(hObject, eventdata, handles) %#ok

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

end
function MovieMag_CreateFcn(hObject, eventdata, handles) %#ok

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function MovieName_CreateFcn(hObject, eventdata, handles) %#ok

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Phase0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function Orient0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Freq0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Contrast0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Speed0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Var2Range_CreateFcn(hObject, eventdata, handles) %#ok

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function nSteps1_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Var1_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Var2_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function LinLog1_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Stop2_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function PixelsY_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function SizeX_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function SizeY_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function ScreenDist_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function FrameHz_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function MovieRate_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Length0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function PositionX0_CreateFcn(hObject, eventdata, handles) %#ok

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function PositionY0_CreateFcn(hObject, eventdata, handles) %#ok
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
function phasePeriod_CreateFcn(hObject, eventdata, handles) %#ok
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function nReps_CreateFcn(hObject, eventdata, handles) %#ok
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function stimulusGroups_CreateFcn(hObject, eventdata, handles) %#ok
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function maskcenterx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function maskcentery_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
function maskradiusx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function maskradiusy_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function maskcenterdeg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function maskmeanradiusdeg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function Var1Range_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Duration_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function nSteps2_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function LinLog2_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Start1_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Start2_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function Stop1_CreateFcn(hObject, eventdata, handles) %#ok
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
end
function popmenuMask_CreateFcn(hObject, eventdata,handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function PreWaitInt_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function PreWaitInt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
