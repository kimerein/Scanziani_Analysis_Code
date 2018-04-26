function iconeditor(x,y,p)
% iconeditor  icon editor for creating and editing icons and small images.
% iconeditor create and edit icons or mouse cursors in either standard or custom sizes
% 
% usage:
% iconeditor(x,y,pixel)
%     x - horizontal size (16 as deault)
%     y - horizontal size (16 as deault)
%     pixel - size of each dot (13 as deafult)
% 
% iconeditor
%     same as iconeditor(16,16,16)
%
% iconeditor(img)
%     img - 3D-RGB image matrix
%
% iconeditor(<filename>)
%     opens the graphic file in iconeditor
%
% iconeditor(img,pixel)
%     img - RGB image matrix
%     pixel - size of each pixel (16 as deault)
%
% author:  Elmar Tarajan [MCommander@gmx.de]
% version: v1.6
% last update: 05-Mar-2010

% New in 1.6
%  - convert color image to grayscale
%  - hot keys STRG+Y and STRG+Z for undo and redo
%  - code imprvements