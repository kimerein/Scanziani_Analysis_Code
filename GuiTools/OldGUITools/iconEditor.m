function varargout = iconEditor(varargin)
% ICONEDITOR GUI creation example
%       ICONEDITOR is an example GUI for demonstrating how to creating
%       GUIs using nested functions. It shows how to share data between two
%       GUIs, make a GUI blocking, support custom input property/value
%       pairs with data validation, and output data to the caller. 
%
%       CDATA = ICONEDITOR(...) runs the GUI. And return the edited icon
%       data to the caller. CDATA is a three dimensional array if the Ok
%       button is pressed. Otherwise, it is empty.
%
%       ICONEDITOR('Property','Value',...) runs the GUI. This GUI
%       accepts property value pairs from the input arguments. Starting
%       from the left, property value pairs are applied to the GUI figure.
%       The following custom properties are also supported that can be used
%       to initialize this GUI. The names *are* case sensitive: 
%         'iconwidth'     desired width of the icon array
%         'iconheight'    desired height of the icon array
%         'iconfile'      source file for loading the icon for editing
%       Any unrecognized property names or invalid values are ignored.
%
%   Examples:
%
%   uicontrol('CData',iconEditor('iconwidth', 16, 'iconheight', 25));
%
%   cdata = iconEditor('iconfile', 'eraser.gif');
%   uicontrol('CData',cdata);

%   Copyright 1984-2006 The MathWorks, Inc.

% Declare non-UI data here so that they can be used in any functions in
% this GUI file. 
mInputArgs      =   varargin;   % Command line arguments when invoking the GUI
mOutputArgs     =   {};         % Variable for storing output when GUI returns
mIconCData      =   [];         % icon CData edited by this GUI of dimension
                                % [mIconHeight, mIconWidth, 3]
mIsEditingIcon  =   false;      % Flag indicating whether the current mouse 
                                % move is used for editing color or not
% Variables for supporting custom property/value pairs
mPropertyDefs   =   {...        % Custom property/value pairs of this GUI
                     'iconwidth',   @localValidateInput, 'mIconWidth';
                     'iconheight',  @localValidateInput, 'mIconHeight';
                     'iconfile',    @localValidateInput, 'mIconFile'};
mIconWidth      =   16;         % else use input property 'iconwidth'
mIconHeight     =   16;         % else use input property 'iconheight'
mIconFile       =   fullfile(matlabroot,'toolbox/matlab/icons/'); 
                                % else use input property 'iconfile'
% Shared data between iconEditor and colorPalette
mGetColorFcn    =   '';         % Function handle for getting the current 
                                % color from the embedded colorPalette 

% Create all the UI objects in this GUI here so that they can
% be used in any functions in this GUI
hMainFigure     =   figure(...
                    'Units','characters',...
                    'MenuBar','none',...
                    'Toolbar','none',...
                    'Position',[71.8 34.7 106 36.15],...
                    'WindowStyle', 'modal',...
                    'WindowButtonDownFcn', @hMainFigureWindowButtonDownFcn,...
                    'WindowButtonUpFcn', @hMainFigureWindowButtonUpFcn,...
                    'WindowButtonMotionFcn', @hMainFigureWindowButtonMotionFcn);
hIconEditPanel  =    uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Clipping','on',...
                    'Position',[1.8 4.3 68.2 27.77]);
hIconEditAxes   =   axes(...
                    'Parent',hIconEditPanel,...
                    'vis','off',...
                    'Units','characters',...
                    'Position',[2 1.15 64 24.6]);
hIconFileText   =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'HorizontalAlignment','left',...
                    'Position',[3.8 32.9 16.2 1.46],...
                    'String','Icon file: ',...
                    'Style','text');
hIconFileEdit   =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'HorizontalAlignment','left',...
                    'Position',[19.8 32.9 78.2 1.62],...
                    'String', ...
                     'Create a new icon or type in an icon image file for editing',...
                    'Enable','inactive',...
                    'Style','edit',...
                    'ButtondownFcn',@hIconFileEditButtondownFcn,...
                    'Callback',@hIconFileEditCallback);
hIconFileButton =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Callback',@hIconFileButtonCallback',...
                    'Position',[98 32.85 5.8 1.77],...
                    'String','...',...
                    'TooltipString','Import From Image File');
hPreviewPanel   =   uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Title','Preview',...
                    'Clipping','on',...
                    'Position',[71.8 23.38 32.2 8.77]);
hPreviewControl =   uicontrol(...
                    'Parent',hPreviewPanel,...
                    'Units','characters',...
                    'Enable','inactive',...
                    'Visible','off',...
                    'Position',[2 3.77 16.2 5.46],...
                    'String','');
hSectionLine    =   uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'HighlightColor',[0 0 0],...
                    'BorderType','line',...
                    'Title','',...
                    'Clipping','on',...
                    'Position',[2 3.62 102.4 0.077]);
hOKButton       =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Position',[65.8 0.62 17.8 2.38],...
                    'String','OK',...
                    'Callback',@hOKButtonCallback');
hCancelButton   =   uicontrol(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Position',[85.8 0.62 17.8 2.38],...
                    'String','Cancel',...
                    'Callback',@hCancelButtonCallback');
hPaletteContainer=  uipanel(...
                    'Parent',hMainFigure,...
                    'Units','characters',...
                    'Title','Palette',...
                    'Clipping','on',...
                    'Position',[71.8 4.46 32.2 18.23]);
% Host the ColorPalette in the PaletteContainer and keep the function
% handle for getting its selected color for editing icon
mGetColorFcn    =   colorPalette('parent', hPaletteContainer);

% Make changes needed for proper look and feel and running on different
% platforms 
prepareLayout(hMainFigure);                            

% Process the command line input arguments supplied when the GUI is
% invoked 
processUserInputs();                            

% Initialize the iconEditor using the defaults or custom data given through
% property/value pairs
localUpdateIconPlot();

% Make the GUI on screen
set(hMainFigure,'visible', 'on');
movegui(hMainFigure,'onscreen');

% Make the GUI blocking
uiwait(hMainFigure);

% Return the edited icon CData if it is requested
mOutputArgs{1} =mIconCData;
if nargout>0
    [varargout{1:nargout}] = mOutputArgs{:};
end

    %------------------------------------------------------------------
    function hMainFigureWindowButtonDownFcn(hObject, eventdata)
    % Callback called when mouse is pressed on the figure. Used to change
    % the color of the specific icon data point under the mouse to that of
    % the currently selected color of the colorPalette
        if (ancestor(gco,'axes') == hIconEditAxes)
            mIsEditingIcon = true;
        
            localEditColor();
        end
    end

    %------------------------------------------------------------------
    function hMainFigureWindowButtonUpFcn(hObject, eventdata)
    % Callback called when mouse is release to exit the icon editing mode
        mIsEditingIcon = false;
    end

    %------------------------------------------------------------------
    function hMainFigureWindowButtonMotionFcn(hObject, eventdata)
    % Callback called when mouse is moving so that icon color data can be
    % updated in the editing mode
        if (ancestor(gco,'axes') == hIconEditAxes)
            localEditColor();
        end
    end

    %------------------------------------------------------------------
    function hIconFileEditCallback(hObject, eventdata)
    % Callback called when user has changed the icon file name from which
    % the icon can be loaded
        file = get(hObject,'String');
        if exist(file, 'file') ~= 2
            errordlg(['The given icon file cannot be found ' 10, file], ...
                    'Invalid Icon File', 'modal');
            set(hObject, 'String', mIconFile);
        else
            mIconCData = [];
            localUpdateIconPlot();            
        end
    end

    %------------------------------------------------------------------
    function hIconFileEditButtondownFcn(hObject, eventdata)
    % Callback called the first time the user pressed mouse on the icon
    % file editbox 
        set(hObject,'String','');
        set(hObject,'Enable','on');
        set(hObject,'ButtonDownFcn',[]);        
        uicontrol(hObject);
    end

    %------------------------------------------------------------------
    function hOKButtonCallback(hObject, eventdata)
    % Callback called when the OK button is pressed
        uiresume;
        delete(hMainFigure);
    end

    %------------------------------------------------------------------
    function hCancelButtonCallback(hObject, eventdata)
    % Callback called when the Cancel button is pressed
        mIconCData =[];
        uiresume;
        delete(hMainFigure);
    end

    %------------------------------------------------------------------
    function hIconFileButtonCallback(hObject, eventdata)
    % Callback called when the icon file selection button is pressed
        filespec = {'*.mat', 'MATLAB MAT files (*.mat)';...
                    '*.bmp', 'BMP files (*.bmp)'; ...
                    '*.jpg', 'JPEG files (*.jpg)';...
                    '*.tif', 'TIFF files (*.tif)';
                    '*.gif', 'GIF files (*.gif)';...
                    '*.pnp', 'PNP files (*.pnp)'};
        [filename, pathname] = uigetfile(filespec, ...
            'Pick an icon image file', mIconFile);

        if ~isequal(filename,0)
            mIconFile =fullfile(pathname, filename);             
            set(hIconFileEdit, 'ButtonDownFcn',[]);            
            set(hIconFileEdit, 'Enable','on');            
            
            mIconCData = [];
            localUpdateIconPlot();            
            
        elseif isempty(mIconCData)
            set(hPreviewControl,'Visible', 'off');            
        end
    end

    %------------------------------------------------------------------
    function localEditColor
    % helper function that changes the color of an icon data point
    % to that of the currently selected color in colorPalette 
        if mIsEditingIcon
            pt = get(hIconEditAxes,'currentpoint');
            x = ceil(pt(1,1));
            y = ceil(pt(1,2));
            color = mGetColorFcn();

            % If cursor is still inside the matrix (as specified
            % by its mIconWidth and mIconHeight properties) ...
            if x > 0 && y > 0 && x < mIconWidth+1 && y < mIconHeight+1 
                % update color of the selected block 
                mIconCData(y, x,:) = color; 
                localUpdateIconPlot();
            end
        end
    end

    %------------------------------------------------------------------
    function localUpdateIconPlot   
    % helper function that updates the iconEditor when the icon data
    % changes
        %initialize icon CData if it is not initialized
        if isempty(mIconCData)
            if exist(mIconFile, 'file')==2
                try
                    mIconCData = iconRead(mIconFile);
                    set(hIconFileEdit, 'String',mIconFile);            
                catch
                    errordlg(...
                      ['Could not load icon data from given file successfully. ',...
                       'Make sure the file name is correct: ' 10, mIconFile],...
                       'Invalid Icon File', 'modal');
                    mIconCData = nan(mIconHeight, mIconWidth, 3);
                end
            else 
                mIconCData = nan(mIconHeight, mIconWidth, 3);
            end
        end
        
        % update preview control
        rows = size(mIconCData, 1);
        cols = size(mIconCData, 2);
        previewSize = getpixelposition(hPreviewPanel);
        % compensate for the title
        previewSize(4) = previewSize(4) -15;
        controlWidth = previewSize(3);
        controlHeight = previewSize(4);  
        controlMargin = 6;
        if rows+controlMargin<controlHeight
            controlHeight = rows+controlMargin;
        end
        if cols+controlMargin<controlWidth
            controlWidth = cols+controlMargin;
        end        
        setpixelposition(hPreviewControl, ...
            [(previewSize(3)-controlWidth)/2, ...
            (previewSize(4)-controlHeight)/2, ...
            controlWidth, controlHeight]); 
        set(hPreviewControl,'CData', mIconCData,'Visible','on');
        
        % update icon edit pane
        set(hIconEditPanel, 'Title', ...
            ['Icon Edit Pane (', num2str(rows),' X ', num2str(cols),')']);
        
        s = findobj(hIconEditPanel,'type','surface');        
        if isempty(s)
            gridColor = get(0, 'defaultuicontrolbackgroundcolor') - 0.2;
            gridColor(gridColor<0)=0;
            s=surface('edgecolor',gridColor,'parent',hIconEditAxes);
        end        
        %set xdata, ydata, zdata in case the rows and/or cols change
        set(s,'xdata',0:cols,'ydata',0:rows, ...
            'zdata',zeros(rows+1,cols+1), ...
            'cdata',localGetIconCDataWithNaNs());

        set(hIconEditAxes,'drawmode','fast','xlim', ...
            [-.5 cols+.5],'ylim',[-.5 rows+.5]);
        axis(hIconEditAxes, 'ij', 'off');        
    end

    %------------------------------------------------------------------
	function cdwithnan = localGetIconCDataWithNaNs()
		% Add NaN to edge of mIconCData so the entire icon renders in the
		% drawing pane.  This is necessary because of surface behavior.
		cdwithnan = mIconCData;
		cdwithnan(:,end+1,:) = NaN;
		cdwithnan(end+1,:,:) = NaN;
		
	end

    %------------------------------------------------------------------
    function processUserInputs
    % helper function that processes the input property/value pairs 
    % Apply possible figure and recognizable custom property/value pairs
        for index=1:2:length(mInputArgs)
            if length(mInputArgs) < index+1
                break;
            end
            match = find(ismember({mPropertyDefs{:,1}},mInputArgs{index}));
            if ~isempty(match)  
               % Validate input and assign it to a variable if given
               if ~isempty(mPropertyDefs{match,3}) && ...
                       mPropertyDefs{match,2}(mPropertyDefs{match,1}, ...
                       mInputArgs{index+1})
                   assignin('caller', mPropertyDefs{match,3}, ...
                       mInputArgs{index+1}) 
               end
            else
                try 
                    set(topContainer, ...
                        mInputArgs{index}, mInputArgs{index+1});
                catch
                    % If this is not a valid figure property value pair,
                    % keep the pair and go to the next pair
                    continue;
                end
            end
        end        
    end

    %------------------------------------------------------------------
    function isValid = localValidateInput(property, value)
    % helper function that validates the user provided input property/value
    % pairs. You can choose to show warnings or errors here.
        isValid = false;
        switch lower(property)
            case {'iconwidth', 'iconheight'}
                if isnumeric(value) && value >0
                    isValid = true;
                end
            case 'iconfile'
                if exist(value,'file')==2
                    isValid = true;                    
                end
        end
    end
end % end of iconEditor

%------------------------------------------------------------------
function prepareLayout(topContainer)
% This is a utility function that takes care of issues related to
% look&feel and running across multiple platforms. You can reuse
% this function in other GUIs or modify it to fit your needs.
    allObjects = findall(topContainer);
    warning off  %Temporary presentation fix
    try
        titles=get(allObjects(isprop(allObjects,'TitleHandle')), ...
            'TitleHandle');
        allObjects(ismember(allObjects,[titles{:}])) = [];
    catch
    end
    warning on

    % Use the name of this GUI file as the title of the figure
    defaultColor = get(0, 'defaultuicontrolbackgroundcolor');
    if isa(handle(topContainer),'figure')
        set(topContainer,'Name', mfilename, 'NumberTitle','off');
        % Make figure color matches that of GUI objects
        set(topContainer, 'Color',defaultColor);
    end

    % Make GUI objects available to callbacks so that they cannot
    % be changes accidentally by other MATLAB commands
    set(allObjects(isprop(allObjects,'HandleVisibility')), ...
                                     'HandleVisibility', 'Callback');

    % Make the GUI run properly across multiple platforms by using
    % the proper units
    if strcmpi(get(topContainer, 'Resize'),'on')
        set(allObjects(isprop(allObjects,'Units')),'Units','Normalized');
    else
        set(allObjects(isprop(allObjects,'Units')),'Units','Characters');
    end

    % You may want to change the default color of editbox,
    % popupmenu, and listbox to white on Windows 
    if ispc
        candidates = [findobj(allObjects, 'Style','Popupmenu'),...
                           findobj(allObjects, 'Style','Edit'),...
                           findobj(allObjects, 'Style','Listbox')];
        set(findobj(candidates,'BackgroundColor', defaultColor), ...
                               'BackgroundColor','white');
    end
end
