function  varargout = colorPalette(varargin)
% COLORPALETTE GUI creation example
%       COLORPALETTE is an example GUI for demonstrating how to creating
%       GUIs using nested functions. It shows how to share data between two
%       GUIs, support custom input property/value pairs with data
%       validation, and output data to the caller. COLORPALETTE populate a
%       color palette into a given figure or panel provided as an input
%       parameter through custom property 'parent'. If user does not
%       provide parent, GCF will be used.
%
%       GETCOLORFCN = COLORPALETTE(...) runs the GUI. And return a function
%       handle for getting the currently selected color in the color
%       palette. The returned function handle can be used at any time
%       before the color palette is destroyed.
%
%       COLORPALETTE('Property','Value',...) runs the GUI. This GUI
%       accepts property value pairs from the input arguments. Only the
%       following custom properties are supported that can be used to
%       initialize this GUI. The names are not case sensitive:  
%         'parent'  the parent figure or panel that holds the color palette
%       Other unrecognized property name or invalid value is ignored.
%
%   Examples:
%
%   fhandle = colorPalette;
%   color = fhandle();
%
%   panel = uipanel('title', 'Palette');    
%   fhandle = colorPalette('parent', panel);
%   color = fhandle();

%   Copyright 1984-2006 The MathWorks, Inc.

% Declare non-UI data so that they can be used in any functions in this GUI
% file, including functions triggered by creating the GUI layout below
mInputArgs      = varargin; % Command line arguments when invoking the GUI
mOutputArgs     = {};       % Variable for storing output when GUI returns
mSelectedColor  = [0,0,0];  % Currently selected color in the palette
% Variables for supporting custom property/value pairs
mPropertyDefs   = {...      % The supported custom property/value pairs of this GUI
                   'parent',   @localValidateInput, 'mPaletteParent'};
mPaletteParent  = [];       % Use input property 'parent' to initialize

% Process the command line input arguments supplied when the GUI is
% invoked
processUserInputs();                            

% Declare and create all the UI objects in this GUI here so that they can
% be used in any functions
hPalettePanel       =   uibuttongroup('Parent',mPaletteParent, ...
                            'Units', 'normalized',...
                            'Position',[0 0 1 1],...
                            'Title',{''},...
                            'BorderType', 'none',...
                            'SelectionChangeFcn', @hPalettePanelSelectionChanged);
hSelectedColorText  =   uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'Style', 'text'); 
hBlueValueText      =   uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'Style', 'text',...
                            'HorizontalAlignment', 'left'); 
hGreenValueText     =   uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'Style', 'text',...
                            'HorizontalAlignment', 'left'); 
hRedValueText       =   uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'Style', 'text',...
                            'HorizontalAlignment', 'left'); 
hMoreColorButton    =   uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'String', 'More Colors ...',...
                            'Callback',@hMoreColorButtonCallback); 

% Dynamically create the color cells and palette tools and layout component
layoutComponent();

% initalized the displayed color information
localUpdateColor();

% Return user defined output if it is requested
mOutputArgs{1} =@getSelectedColor;
if nargout>0
    [varargout{1:nargout}] = mOutputArgs{:};
end
    
    %----------------------------------------------------------------------
    function color = getSelectedColor
    % function returns the currently selected color in this colorPlatte
        color = mSelectedColor;
    end

    %----------------------------------------------------------------------
    function hPalettePanelSelectionChanged(hObject, eventdata)
    % Callback called when the selected color is changed in the colorPlatte
        selected = get(hPalettePanel,'SelectedObject');
        def = get(selected, 'UserData');
        if ~isempty(def) && isfield(def,'Callback')
            def.Callback(selected, eventdata);
        end
    end

    %----------------------------------------------------------------------
    function hMoreColorButtonCallback(hObject, eventdata)
    % Callback called when the more color button is pressed. 
        color = mSelectedColor;
        if isnan(color)
            color =[0 0 0];
        end
        color = uisetcolor(color);
        if ~isequal(color, mSelectedColor)
            mSelectedColor =color;
            localUpdateColor();
        end
    end

    %----------------------------------------------------------------------
    function eraserToolCallback(hObject, eventdata)
    % Callback called when the eraser palette tool button is pressed
        mSelectedColor = NaN;
    end

    %----------------------------------------------------------------------
    function colorCellCallback(hObject, eventdata)
    % Callback called when any color cell button is pressed
        mSelectedColor = get(hObject, 'BackgroundColor');
        localUpdateColor();
    end

    %----------------------------------------------------------------------
    function localUpdateColor
    % helper function that updates the preview of the selected color
        set(hSelectedColorText, 'BackgroundColor', mSelectedColor);
        set(hRedValueText, 'String',['R: ' num2str(mSelectedColor(1))]);
        set(hGreenValueText,'String',['G: ' num2str(mSelectedColor(2))]);
        set(hBlueValueText,'String',['B: ' num2str(mSelectedColor(3))]);
    end

    %----------------------------------------------------------------------
    function layoutComponent
    % helper function that dynamically creats all the tools and color cells
    % in the palette. It also positions all other UI objects properly. 
        % get the definision of the layout
        [mLayout, mColorEntries, mToolEntries] = localDefineLayout();
        
        % change the size of the color palette to the desired size, place
        % the components, and then change size back.
        setpixelposition(hPalettePanel, [0, 0, mLayout.preferredWidth, mLayout.preferredHeight]);
        
        % create tools
        startY = mLayout.preferredHeight;
        for i=1:mLayout.toolRowNumber
            for j=1:mLayout.toolPerRow
                if ((i-1)*mLayout.toolPerRow + j)>length(mToolEntries)
                    break;
                end
                tool = mToolEntries{(i-1)*mLayout.toolPerRow + j};
                control = uicontrol('Style','ToggleButton',...
                            'Parent',hPalettePanel, ...
                            'TooltipString', tool.Name,...
                            'UserData', tool,...
                            'Units','pixels',...
                            'Position',[mLayout.hgap+(j-1)*(mLayout.toolSize+mLayout.hgap),...
                                        startY- i*(mLayout.toolSize+mLayout.hgap),...
                                        mLayout.toolSize, mLayout.toolSize]);            
                if isfield(tool,'Icon')
                    set(control,'CData',iconRead(tool.Icon));
                end
                if isfield(tool,'Visible')
                    set(control,'Visible',tool.Visible);
                end
                set(control,'units','normalized');
            end
        end

        % create color cells
        startY = startY - mLayout.toolRowNumber*(mLayout.toolSize+mLayout.vgap);
        for i=1:mLayout.cellRowNumber
            for j=1:mLayout.cellPerRow
                if ((i-1)*mLayout.cellPerRow + j)>length(mColorEntries)
                    break;
                end
                color = mColorEntries{(i-1)*mLayout.cellPerRow + j};
                tooltip = mat2str(color.Color);
                if isfield(color,'Name')
                    tooltip = color.Name;
                end
                control = uicontrol('Style','ToggleButton',...
                            'TooltipString', tooltip,...
                            'BackgroundColor',color.Color,... 
                            'Parent',hPalettePanel, ...
                            'Units','pixels',...
                            'UserData',color,... 
                            'Position',[mLayout.hgap+(j-1)*(mLayout.cellSize+mLayout.hgap),...
                                    startY- i*(mLayout.cellSize+mLayout.hgap),...
                                    mLayout.cellSize, mLayout.cellSize]);            
                if isequal(mSelectedColor,get(control,'BackgroundColor'))
                    set(control, 'value',1);
                end
                set(control,'units','normalized');
            end
        end
        
        % place color sample
        startY = startY - mLayout.cellRowNumber*(mLayout.cellSize+mLayout.vgap);
        startX = 2*mLayout.hgap+mLayout.colorSampleSize;
        setpixelposition(hSelectedColorText, [mLayout.hgap, (startY-mLayout.colorSampleSize), ...
                                              mLayout.colorSampleSize,mLayout.colorSampleSize]); 
        rgbHeight = floor(mLayout.colorSampleSize/3);
        rgbWidth = mLayout.preferredWidth - mLayout.colorSampleSize - 3*mLayout.hgap;
        setpixelposition(hRedValueText,   [startX, (startY-rgbHeight), rgbWidth, rgbHeight]); 
        setpixelposition(hGreenValueText, [startX, (startY-2*rgbHeight),rgbWidth, rgbHeight]); 
        setpixelposition(hBlueValueText,  [startX, (startY-3*rgbHeight),rgbWidth, rgbHeight]); 
                                          
        % place more color button
        startY = startY - mLayout.colorSampleSize - mLayout.vgap;
        setpixelposition(hMoreColorButton,[mLayout.hgap, (startY-mLayout.moreColorButtonHeight), ...
                                           mLayout.preferredWidth - 2*mLayout.hgap,mLayout.moreColorButtonHeight]); 

        % restore palette to the full size                               
        set(hPalettePanel, 'units', 'normalized', 'Position', [0 0 1 1]);

        %----------------------------------------------------------------------
        function [layout, colors, tools]=localDefineLayout
        % helper functions that provides the data defining the color palette    
            colors = localDefineColors();
            tools = localDefineTools();
            
            layout.hgap = 3;
            layout.vgap = 5;
            layout.cellSize = 16;
            layout.cellPerRow = 8;
            layout.toolSize = 25;
            layout.colorSampleSize = 60;
            layout.moreColorButtonHeight = 25;
            
            % calculate the preferred width and height
            width  =  max([2*layout.colorSampleSize,(layout.cellSize+layout.hgap)*layout.cellPerRow]);
            layout.cellRowNumber =  ceil(length(colors)/ceil(width/(layout.cellSize+layout.vgap)));
            layout.toolPerRow =  ceil(width/(layout.toolSize+layout.vgap));
            layout.toolRowNumber =  ceil(length(tools)/ceil(width/(layout.toolSize+layout.vgap)));
            height =  layout.cellRowNumber*(layout.cellSize+layout.vgap) ...
                    + layout.toolRowNumber*(layout.toolSize+layout.vgap) ...
                    + layout.colorSampleSize + layout.moreColorButtonHeight;
            layout.preferredWidth = layout.hgap+width;
            layout.preferredHeight = 2*layout.vgap+height;
        end

        %--------------------------------------------------------------------------
        function tools = localDefineTools
        % helper function that defines the tools shown in this color
        % palette. The 'name' is used to show a tooltip of the tool. The
        % 'callback' is used to provide the function called when the
        % corresponding tool is selected. You can change the tools in the
        % palette by adding/removing entries.
        tools = {struct('Name','Eraser', ...
                        'Icon', 'eraser.gif',...
                        'Callback', @eraserToolCallback)};
        end

        %--------------------------------------------------------------------------
        function colors = localDefineColors
        % helper function that defines the colors shown in this color
        % palette. The 'name' is used to show a tooltip of the color. If it
        % is not provided, the color value is used as the tooltip. The
        % 'callback' is used to provide the function called when the
        % corresponding color is selected. You can change the color values
        % or the number of colors. The palette will adapt to the changes 
        callback =@colorCellCallback; 
        colors= {struct('Color','black',...
                        'Callback',callback),...
                 struct('Color','white',...
                        'Callback',callback),...        
                 struct('Color',[0.94,0.94,0.94],...
                        'Callback',callback),...
                 struct('Color',get(0,'defaultuicontrolbackgroundcolor'), ...
                        'Name', 'Default uicontrol color',...
                        'Callback',callback),...        
                 struct('Color',get(0,'defaultfigurecolor'),...
                        'Name', 'Default figure color',...
                        'Callback',callback),...        
                 struct('Color',[0.5,0.5,0.5],...
                        'Callback',callback),...        
                 struct('Color',[0.31,0.31,0.31],...
                        'Callback',callback),...        
                 struct('Color',[0.04,0.14,0.42],...
                        'Callback',callback),...        
                 struct('Color','red',...
                        'Callback',callback),...        
                 struct('Color',[0.75,0,0.75],...
                        'Callback',callback),...        
                 struct('Color','blue',...
                        'Callback',callback),...        
                 struct('Color',[0,0.5,0],...
                        'Callback',callback),...        
                 struct('Color',[0,0.75,0.75],...
                        'Callback',callback),...
                 struct('Color',[0.75,0.75, 0],...
                        'Callback',callback),...
                 struct('Color',[0.6,0.2,0],...
                        'Callback',callback),...
                 struct('Color',[0.25,0.25,0.25],...
                        'Callback',callback),...
                 struct('Color',[0.85,0.16,0],...
                        'Callback',callback),...
                 struct('Color','magenta',...
                        'Callback',callback),...
                 struct('Color',[0.48, 0.06, 0.89],...
                        'Callback',callback),...
                 struct('Color',[0.08, 0.16, 0.55],...
                        'Callback',callback),...
                 struct('Color',[0.04, 0.52, 0.78],...
                        'Callback',callback),...
                 struct('Color',[0.17, 0.51, 0.34],...
                        'Callback',callback),...
                 struct('Color',[0.68, 0.47, 0],...
                        'Callback',callback),...                
                 struct('Color',[0.87, 0.49, 0],...
                        'Callback',callback),...                
                 struct('Color',[1, 0.6, 0.78],...
                        'Callback',callback),...                
                 struct('Color',[0.85, 0.7 ,1],...
                        'Callback',callback),...                
                 struct('Color',[0.7, 0.78, 1],...
                        'Callback',callback),...                
                 struct('Color',[0.68, 0.92, 1],...
                        'Callback',callback),...                
                 struct('Color','cyan',...
                        'Callback',callback),...                
                 struct('Color','green',...
                        'Callback',callback),...                
                 struct('Color','yellow',...
                        'Callback',callback),...                
                 struct('Color',[1,0.69,0.39],...
                        'Callback',callback)};
        end
    end


    %----------------------------------------------------------------------
    function processUserInputs
    % helper function that processes the input property/value pairs 
        % Apply recognizable custom parameter/value pairs
        for index=1:2:length(mInputArgs)
            if length(mInputArgs) < index+1
                break;
            end
            match = find(ismember({mPropertyDefs{:,1}},mInputArgs{index}));
            if ~isempty(match)  
               % Validate input and assign it to a variable if given
               if ~isempty(mPropertyDefs{match,3}) && mPropertyDefs{match,2}(mPropertyDefs{match,1}, mInputArgs{index+1})
                   assignin('caller', mPropertyDefs{match,3}, mInputArgs{index+1}) 
               end
            end
        end        

        if isempty(mPaletteParent)
            mPaletteParent =gcf;
        end
    end

    %----------------------------------------------------------------------
    function isValid = localValidateInput(property, value)
    % helper function that validates the user provided input property/value
    % pairs. You can choose to show warnings or errors here.
        isValid = false;
        switch lower(property)
            case 'parent'
                if ishandle(value) 
                    mPaletteParent = true;
                    isValid =true;
                end
        end
    end
end % end of iconPalette

