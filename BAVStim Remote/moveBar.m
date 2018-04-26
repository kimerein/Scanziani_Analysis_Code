function [coord]= moveBar
% BA
% based on SpriteDemo and kbDemo
% move bar around with mouse
% up and down to lengthen and shorten bar
% left and right to rotate
% c to switch bar from black to white
% click mouse to exit
%
% return x y coordinates of location when mouse is clicked
try
    %%
    % BA from SpriteDemo.

    % Hide the mouse cursor.
    HideCursor;

    screenNumber = 1;

    %define keys
    KbName('UnifyKeyNames');
    rightKey = KbName('RightArrow');
    leftKey = KbName('LeftArrow');
    upKey = KbName('UpArrow');
    downKey = KbName('DownArrow');
    cKey = KbName('c');


    % Get colors
    %** ADD set foreground andback
    black = BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber);
    backgroundColors = [white black];

    buttons = 0; % When the user clicks the mouse, 'buttons' becomes nonzero.
    mX = 0; % The x-coordinate of the mouse cursor
    mY = 0; % The y-coordinate of the mouse cursor

    condition = 2; % set default condition (black bar on white background) 2 = white bar on black background
    % declare window

    [window windowRect] = Screen('OpenWindow', 0, backgroundColors(condition));

    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

    MAXBARLENGTH = windowRect(3)/2 ;
    barLength = MAXBARLENGTH;

    % defaults
    barWidth = 50; % * convert degrees % The height of horizontal bar
    barLengthStep = 20; % step size to lengthen/shorten bar by
    barRotation = 0 ;

    % two different conditions for black and white bars
    spriteFrame(1) = Screen('MakeTexture', window, black);
    spriteFrame(2) = Screen('MakeTexture', window, white);

    %     spriteRect = [0 0 barLength barWidth]; % The bounding box for our animated sprite
    lastsecs = [];
    while ~any(buttons)
        % We need to redraw the text or else it will disappear after a
        % subsequent call to Screen('Flip').
        Screen('DrawText', window, 'Move the mouse.  Click to exit', 0, 0, backgroundColors(mod(condition,2)+1));

        % Get the location and click state of the mouse.
         [mX, mY, buttons] = GetMouse;
        spriteRect = [0 0 barLength barWidth]; % The bounding box for our  sprite

        % Draw the sprite at the new location.
        Screen('DrawTexture', window, spriteFrame(condition), spriteRect, CenterRectOnPoint(spriteRect, mX, mY),barRotation);
        % Call Screen('Flip') to update the screen.  Note that calling
        % 'Flip' after we have both erased and redrawn the sprite prevents
        % the sprite from flickering.
        Screen('Flip', window);


        [keyIsDown, secs, keyCode] = KbCheck;
        if isempty(lastsecs)|( secs -lastsecs) >= 1/10; % set a maximum rate at which a key can be pressed otherwise holding button makes bar spin to fast
            if keyIsDown %%% charavail would be much better, but doesn't seem to work
                lastsecs = secs;
                if keyCode(rightKey) % rotate bar
                    barRotation = mod(barRotation + 45,360);
                elseif keyCode(leftKey) % rotate bar
                    barRotation = mod(barRotation - 45,360);
                elseif keyCode (upKey) % lengthen bar
                    barLength = min(MAXBARLENGTH,barLength+barLengthStep);
                elseif keyCode (downKey) % shorten bar
                    barLength = max(0,barLength-barLengthStep);
                elseif keyCode (cKey) % switch from white on black to black on white
                    if condition==1
                        condition=2;
                    else
                        condition = 1;
                    end
                    
                    Screen('FillRect',window, backgroundColors(condition));
                    Screen('DrawText', window, 'Move the mouse.  Click to exit', 0, 0, backgroundColors(condition));
                end
            end
        end
    end

    % Revive the mouse cursor.
    ShowCursor;

    % Close screen
    Screen('CloseAll');

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

catch

    % If there is an error in our try block, let's
    % return the user to the familiar MATLAB prompt.
    ShowCursor;
    Screen('CloseAll');
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    psychrethrow(psychlasterror);

end

coord = [mX mY];