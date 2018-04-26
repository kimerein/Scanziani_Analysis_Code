function SetFileTime(File)  %#ok<INUSD>
% Set Creation, Access, or Write time of a file
% On NTFS file systems, creation, access and write time are stored for each
% file. SetFileTime can set these times for writable files.
%
% SetFileTime(FileName, TimeSpec, Time, Type)
% INPUT:
%   FileName: String, file name with or without absolute or relative path.
%             Folder names are not accepted.
%   TimeSpec: String specifying the time, which should be touched. Just the
%             first character matters.
%             'Creation': Time of creation,
%             'Access':   Time of last access,
%             'Write':    Time of last modification.
%   Time:     Current local time as [1 x 6] double vectorin DATEVEC format,
%             e.g. as replied from CLOCK. Milliseconds are considered.
%             The time is converted to UTC.
%   Type:     String, type of the conversion from local time to UTC file time.
%             Optional, default: "Local". Just the 1st character matters.
%             "Local": The file time is converted from the local time
%                      considering the daylight saving setting of the specific
%                      time.
%             "Windows": The time conversion considers the current daylight
%                      saving time as usual for Windows (e.g. the Windows
%                      Explorer). If the daylight saving changes, the file
%                      times can change also.
%             "UTC":   The input is written as UTC time without a conversion.
%
% The function stops with an error if:
%   - the file does not exist or cannot be opened in write mode,
%   - the time conversions fail,
%   - the number or type of inputs/outputs is wrong.
%
% EXAMPLE:
%   File = tempname;
%   D = dir(File)
%   SetFileTime(File, 'Write', [2009, 24, 12, 16, 32, 29]);
%   D = dir(File)
%
% NOTES:
% - The "Windows" method adjusts the times according to the currently active
%   DST. Therefore a "changed" time stamp does not necessarily mean, that the
%   file is changed, but eventuall only the daylight saving time.
%   Although this might be confusing, it is a valid method to handle the hours
%   during the DST switches consistently.
% - With the "Local" conversion, the times during the DST switches cannot be
%   converted consistently, e.g. 2009-Mar-08 02:30:00 (does not exist) and
%   2009-Nov-01 02:30:00 (exists twice). But for the half of the other 8758
%   hours of the year, "Local" is more consistent than the "Windows"
%   conversion.
% - Matlab's DIR command showed the "Windows" write time until 6.5.1 and the
%   "Local" value for higher versions.
% - This function works under WindowsXP or Windows Server 2003 and higher only,
%   because the API function TzSpecificLocalTimeToSystemTime is called.
%   The header files <windows.h> of LCC2.4 (shipped with Matlab up to 2009a and
%   higher?!) and BCC5.5 does not contain the prototype of this function. The
%   free compilers LCC 3.8 and OpenWatcom 1.8 can compile SetFileTime.
% - Unix/OSX not supported yet.
% - Run the function TestFileTime after compiling the MEX files. I recommend to
%   move TestFileTime to a folder where it does not bother.
%
% Compilation of MEX source (after "mex -setup" on demand):
%   mex -O SetFileTime.c
% Precompiled MEX files can be found at: http://www.n-simon.de/mex
%
% Tested: Matlab 6.5, 7.7, LCC3.8, OpenWatcom1.8, WinXP, [UnitTest]
% Author: Jan Simon, Heidelberg, (C) 2009 matlab.2009ATnMINUSsimonDOTde
%
% See also: DIR, CLOCK, DATEVEC, DATESTR.

% $JRev: R0e V:010 Sum:311E5620 Date:09-Jul-2009 01:37:38 $
% $File: User\JSim\Published\FileTime\SetFileTime.m $
% History:
% 010: 09-Jul-2009 00:42, TimeSpec 'Modify' -> 'Write'.

error(['*** ', mfilename, 'Cannot find MEX script!']);
