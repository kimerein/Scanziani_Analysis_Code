function TestFileTime(doSpeed)
% Automatic test: Set/GetFileTime
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% TestFileTime(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed tested are defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%
% Tested: Matlab 6.5, 7.7
% Author: Jan Simon, Heidelberg, (C) 2009 matlab.2009ATnMINUSsimonDOTde

% $JRev: R0g V:001 Sum:3B3E30A6 Date:10-Nov-2009 16:34:29 $
% $File: User\JSim\Published\FileTime\TestFileTime.m $
% History:
% 001: 10-Nov-2009 13:18, Need a test for new features.

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
ErrID = 'JSim:TestFileTime:';

% Initial values: --------------------------------------------------------------
% Program Interface: -----------------------------------------------------------
if nargin == 0
   doSpeed = true;  %#ok<NASGU>
end

% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
disp(['===  Test SetFileTime / GetFileTime  ', datestr(now, 0)]);

% Create a test file:
disp('Create test file:');
File = fullfile(tempdir, 'test_FileTime.txt');
if exist(File, 'file')
   delete(File);
end
FID = fopen(File, 'wb');
if FID < 0
   error([ErrID, 'NoTestFile'], 'Cannot create test file?!');
end
fclose(FID);

% Get WRITE time with Matlab's DIR:
FileDir = dir(File);
disp(FileDir);

% Get file times:
disp('GetFileTime:');
Reply = GetFileTime(File);
disp(Reply);

% DIR does apply FLOOR to the seconds:
fprintf('\n');
if isequal(FileDir.date, datestr(floor(Reply.Write), 0))
   disp('  ok: DIR and GetFileTime reply the same WRITE time');
else
   error([ErrID, 'DIRneGetFileTime'], ...
      'DIR and GetFileTime reply different WRITE time');
end

% Set the file times and compare them after Get: -------------------------------
TypeList = {'', 'Windows', 'Local', 'UTC'};
SpecList = {'Write', 'Creation', 'Access'};
DateList = {[2009 6 1 14 15 16], [2009 12 1 14 15 16]};  % Summer and winter
DSTList  = {'Summer time', 'Winter time'};
for iDate = 1:length(DateList)
   aDate = DateList{iDate};
   fprintf('\n- %s: [%d %d %d %d %d %d]\n', DSTList{iDate}, aDate);
   
   for iSpec = 1:length(SpecList)
      aSpec = SpecList{iSpec};
      for iType = 1:length(TypeList)
         % Call SetFileTime:
         aTimeType = TypeList{iType};
         try
            if isempty(aTimeType)  % Default:
               SetFileTime(File, aSpec, aDate);
            else
               SetFileTime(File, aSpec, aDate, aTimeType);
            end
         catch  % TRY-CATCH compatible with Matlab 6.5:
            error([ErrID, 'CrashedSet'], ...
               ['Crash in SetFileTime (', aSpec, ', ', aTimeType ')', ...
                  char(10), lasterr]);
         end
         
         % Call GetfileTime:
         try
            if isempty(aTimeType)  % Default:
               Reply = GetFileTime(File);
            else
               Reply = GetFileTime(File, aTimeType);
            end
         catch
            error([ErrID, 'CrashedGet'], ...
               ['Crash in GetFileTime (', aTimeType ')', ...
                  char(10), lasterr]);
         end
         
         % Compare the results:
         if isequal(Reply.(aSpec), aDate)
            if isempty(aTimeType)
               fprintf('  ok: Get(Set(%s, date)\n', aSpec);
            else
               fprintf('  ok: Get(Set(%s, date, %s)\n', aSpec, aTimeType);
            end
         else
            error([ErrID, 'GetSetDiffers'], ...
               ['GetFileTime(SetFileTime(', aSpec, ', ', ...
                  sprintf('[%d %d %d %d %d %d]', aDate), aTimeType, ') = ', ...
                  sprintf('[%d %d %d %d %d %d]', Reply.(aSpec))]);
         end
         
         % Compare with DIR:
         if strcmp(aSpec, 'Write')
            if (sscanf(version, '%d') >= 7 && strcmp(aTimeType, 'Local')) || ...
                  (sscanf(version, '%d') < 7 && strcmp(aTimeType, 'Windows'))
               FileDir = dir(File);
               if isequal(FileDir.date, datestr(floor(Reply.Write), 0))
                  disp('  ok: Reply equals DIR');
               else
                  error([ErrID, 'DiffersFromDIR'], ...
                     'Get(Set()) differs from DIR');
               end
            end
         end
      end
   end
end

% Check bad inputs/outputs: ----------------------------------------------------
fprintf('\nTest bad inputs and outputs:\n');
tooLazy  = false;
testDate = clock;
head     = blanks(6);
try
   SetFileTime([], 'Write', testDate);
   tooLazy = true;
catch
   disp(['  ok: Bad file refused:', char(10), head, lasterr]);
end
if tooLazy
   error([ErrID, 'BadFileAccepted'], 'Bad file accepted.');
end

try
   SetFileTime(tempdir, 'Write', testDate);
   tooLazy = true;
catch
   disp(['  ok: Folder refused: ', char(10), head, lasterr]);
end
if tooLazy
   error([ErrID, 'FolderAccepted'], 'Folder accepted.');
end

try
   SetFileTime('this_is_a_not_existing_file%&%$', 'Write', testDate);
   tooLazy = true;
catch
   disp(['  ok: Missing file refused: ', char(10), head, lasterr]);
end
if tooLazy
   error([ErrID, 'MissFileAccepted'], 'Missing file accepted.');
end

try
   SetFileTime(File, '_No_valid_spec', testDate);
   tooLazy = true;
catch
   disp(['  ok: Invalid time specifier refused: ', char(10), head, lasterr]);
end
if tooLazy
   error([ErrID, 'BadSpecAccepted'], 'Bad time specifier accepted.');
end

try
   SetFileTime(File, 'Access', 'badate');  % String, but 6 chars
   tooLazy = true;
catch
   disp(['  ok: Date as string refused: ', char(10), head, lasterr]);
end
if tooLazy
   error([ErrID, 'BadDateStrAccepted'], 'Date as string accepted.');
end

try
   SetFileTime(File, 'Access', 1:7);  % date with 7 elements
   tooLazy = true;
catch
   disp(['  ok: Date with 7 numbers refused: ', char(10), head, lasterr]);
end
if tooLazy
   error([ErrID, 'BadDateNumAccepted'], 'Date with 7 numbers accepted.');
end

try
   SetFileTime(File, 'Access', zeros(1, 6));
   tooLazy = true;
catch
   disp(['  ok: date ZEROS(1, 6) refused: ', char(10), head, lasterr]);
end
if tooLazy
   error([ErrID, 'ZeroDateNumAccepted'], 'Date ZEROS(1, 6) accepted.');
end

% Success! Goodbye: ------------------------------------------------------------
delete(File);
fprintf('\n');
disp('SetFileTime / GetFileTime seem to work fine.');

return;
