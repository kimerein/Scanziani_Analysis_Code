function Time = GetFileTime(FileName, Type)  %#ok<STOUT,INUSD>
% Get Creation, Access, and Write time of a file
% Time = GetFileTime(FileName, Type)
% INPUT:
%   FileName: String, file or folder name with or without absolute or relative
%             path.
%   Type:     String, type of the conversion from UTC file time to local time.
%             Optional, default: "Local". Just the 1st character matters.
%             "Local": The file times are converted from the local time
%                      considering the daylight saving setting of the specific
%                      times.
%             "Windows": The time conversions consider the current daylight
%                      saving time as usual for Windows (e.g. the Windows
%                      Explorer). If the daylight saving changes, the file
%                      times can change also.
%             "UTC":   The UTC times are replied without a conversion.
%
% OUTPUT:
%   Time:     Struct with fields: "Creation", "Access", "Write".
%             Each field contains the corresponding time as [1 x 6] double
%             vector (see DATEVEC):
%             [year, month, day, hour, minute, second.millisecond]
%
% The function stops with an error if:
%   - the file/folder does not exist,
%   - the time conversion fails,
%   - the number or type of inputs/outputs is wrong.
%
% EXAMPLES:
%   File = which('GetFileTime.m');
%   GetFileTime(File)
%   GetFileTime(File, 'UTC')
%   GetFileTime(File, 'Windows')
%
% NOTES:
% - The function is tested for NTFS drives only. It seems that it could work on
%   FAT file systems also.
% - The "Windows" method replies different times according to the currently
%   active DST. Therefore a "changed" time stamp does not necessarily mean,
%   that the file is changed, but eventuall only the daylight saving time.
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
%   mex -O GetFileTime.c
% Precompiled MEX files can be found at: http://www.n-simon.de/mex
%
% Tested: Matlab 6.5, 7.7, LCC3.8, OpenWatcom1.8, WinXP, [UnitTest]
% Author: Jan Simon, Heidelberg, (C) 2009 matlab.2009ATnMINUSsimonDOTde
%
% See also: DIR, CLOCK, DATEVEC, DATESTR.

% $JRev: R0m V:004 Sum:88784805 Date:20-Nov-2009 10:30:06 $
% $File: User\JSim\Published\FileTime\GetFileTime.m $
% History:
% 001: 09-Jul-2009 00:12, Initial version.
% 002: 11-Nov-2009 12:11, 2nd input for time conversion.

error(['*** ', mfilename, 'Cannot find MEX script!']);
