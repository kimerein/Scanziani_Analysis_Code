// GetFileTime.c
// Get Creation, Access, and Write time of a file
// Time = GetFileTime(FileName, Type)
// INPUT:
//   FileName: String, file or folder name with or without absolute or relative
//             path.
//   Type:     String, type of the conversion from UTC file time to local time.
//             Optional, default: "Local". Just the 1st character matters.
//             "Local": The file times are converted from the local time
//                      considering the daylight saving setting of the specific
//                      times.
//             "Windows": The time conversions consider the current daylight
//                      saving time as usual for Windows (e.g. the Windows
//                      Explorer). If the daylight saving changes, the file
//                      times can change also.
//             "UTC":   The UTC times are replied without a conversion.
//
// OUTPUT:
//   Time:     Struct with fields: "Creation", "Access", "Write".
//             Each field contains the corresponding time as [1 x 6] double
//             vector (see DATEVEC):
//               [year, month, day, hour, minute, second.millisecond]
//
// The function stops with an error if:
//   - the file does not exist,
//   - the time conversion fails,
//   - the number or type of inputs/outputs is wrong.
//
// EXAMPLES:
//   File = which('GetFileTime.m');
//   GetFileTime(File)
//   GetFileTime(File, 'UTC')
//   GetFileTime(File, 'Windows')
//
// NOTES:
// - The function is tested for NTFS drives only. It seems that it could work
//   on FAT file systems also.
// - The "Windows" method replies different times according to the currently
//   active DST. Therefore a "changed" time stamp does not necessarily mean,
//   that the file is changed, but eventuall only the daylight saving time.
//   Although this might be confusing, it is a valid method to handle the hours
//   during the DST switches consistently.
// - With the "Local" conversion, the times during the DST switches cannot be
//   converted consistently, e.g. 2009-Mar-08 02:30:00 (does not exist) and
//   2009-Nov-01 02:30:00 (exists twice). But for the half of the other 8758
//   hours of the year, "Local" is more consistent than the "Windows"
//   conversion.
// - Matlab's DIR command showed the "Windows" write time until 6.5.1 and the
//   "Local" value for higher versions.
// - This function works under WindowsXP or Windows Server 2003 and higher only,
//   because the API function TzSpecificLocalTimeToSystemTime is called.
//   The header files <windows.h> of LCC2.4 (shipped with Matlab up to 2009a and
//   higher?!) and BCC5.5 does not contain the prototype of this function. The
//   free compilers LCC 3.8 and OpenWatcom 1.8 can compile SetFileTime.
// - Unix/OSX not supported yet.
// - Run the function TestFileTime after compiling the MEX files. I recommend to
//   move TestFileTime to a folder where it does not bother.
//
// Compilation of MEX source (after "mex -setup" on demand):
//   mex -O GetFileTime.c
// Precompiled MEX files can be found at: http://www.n-simon.de/mex
//
// Tested: Matlab 6.5, 7.7, LCC3.8, OpenWatcom1.8, WinXP, [UnitTest]
// Author: Jan Simon, Heidelberg, (C) 2009 matlab.2009ATnMINUSsimonDOTde
//
// See also: DIR, CLOCK, DATEVEC, DATESTR.

/*
% $JRev: R0r V:008 Sum:B4B6CC49 Date:20-Nov-2009 10:29:54 $
% $File: User\JSim\Published\FileTime\GetFileTime.c $
% History:
% 001: 09-Jul-2009 00:12, Initial version.
% 005: 08-Nov-2009 13:43, Reply UTC file time as: Windows, Local, UTC.
%      No support of LCC 2.4 (shipped with Matlab) and BCC5.5.
% 006: 15-Nov-2009 00:37, Works with directories also.
*/

#if defined(WIN32) || defined(_WIN32)
#include <windows.h>
#else
#error Implemented for Windows only now!
#endif

#include "mex.h"
#include <math.h>

// Enumerator for types of time conversion:
static enum ConversionType {WIN_TIME, LOCAL_TIME, UTC_TIME};

// Prototypes:
void FileTimeToDateVec_Win(const FILETIME *UTC, double *DateVec,
                           enum ConversionType Type);

// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char       *FileName, TypeIn;
  const char *ReplyFields[3] = {"Creation", "Access", "Write"};
  mxArray    *Reply, *Field;
  HANDLE     *H;
  FILETIME   CreationUTC, AccessUTC, WriteUTC;
  BOOL       Success;
  
  // Default conversion: Adjust to local with daylight saving setting of the
  // specific time:
  enum ConversionType Type = LOCAL_TIME;
  
  // 2nd input is the [Type] of the output as string:
  if (nrhs == 2) {
    // Check type of input:
    if (!mxIsChar(prhs[1]) || mxGetNumberOfElements(prhs[1]) == 0) {
      mexErrMsgIdAndTxt("JSim:GetFileTime:BadType",
                        "2nd input [Type] must be a string.");
    }
    
    // "W" for "Windows", "U" for "UTC", "L" for real local time (default):
    TypeIn = (char) tolower(*(char *)mxGetData(prhs[1]));
    if (TypeIn == 'w') {         // As Windows: Adjust to current DST
      Type = WIN_TIME;
    } else if (TypeIn == 'u') {  // UTC time: Not affected by DST
      Type = UTC_TIME;
    }
  } else if (nrhs != 1) {
    mexErrMsgIdAndTxt("JSim:GetFileTime:BadNArgin", "1 input required.");
  }
  
  // For nlhs == 0, the reply is store in [ans]:
  if (nlhs > 1) {
    mexErrMsgIdAndTxt("JSim:GetFileTime:BadNArgout", "1 output allowed.");
  }
  
  // Get file name:
  if (!mxIsChar(prhs[0])) {
    mexErrMsgIdAndTxt("JSim:GetFileTime:BadFileName",
                      "1st input must be the file name.");
  }
  if ((FileName = mxArrayToString(prhs[0])) == NULL) {
    mexErrMsgIdAndTxt("JSim:GetFileTime:NoMemory",
                      "FileName to C-string failed.");
  }
  
  // Get a file or directory handle:
  H = CreateFile(
        (LPCTSTR)FileName,          // Pointer to file name
        NULL,                       // Access mode (GENERIC_READ)
        FILE_SHARE_READ, NULL,      // Share mode and security
        OPEN_EXISTING,              // How to create
        FILE_FLAG_BACKUP_SEMANTICS, // Attributes, accept directory
        NULL);                      // Attribute template handle
  
  mxFree(FileName);                 // Release memory as soon as possible
  
  if (H == INVALID_HANDLE_VALUE) {
    mexErrMsgIdAndTxt("JSim:GetFileTime:MissFile",
                      "File or folder is not existing!");
  }
  
  // Obtain the file times:
  Success = GetFileTime(H,
    &CreationUTC,   // Creation time as UTC
    &AccessUTC,     // Last access time as UTC
    &WriteUTC);     // Last write time as UTC
  
  // Close the file before checking success:
  CloseHandle(H);
  
  if (Success == 0) {
    mexErrMsgIdAndTxt("JSim:GetFileTime:CreateFileFailed",
                      "GetFileTime[win] failed!");
  }
  
  // Create output:
  plhs[0] = mxCreateStructMatrix(1, 1, 3, ReplyFields);
  Reply   = plhs[0];
  
  // Creation time:
  Field = mxCreateDoubleMatrix(1, 6, mxREAL);
  FileTimeToDateVec_Win(&CreationUTC, mxGetPr(Field), Type);
  mxSetFieldByNumber(Reply, 0, 0, Field);
  
  // Last access time:
  Field = mxCreateDoubleMatrix(1, 6, mxREAL);
  FileTimeToDateVec_Win(&AccessUTC, mxGetPr(Field), Type);
  mxSetFieldByNumber(Reply, 0, 1, Field);

  // Last write time:
  Field = mxCreateDoubleMatrix(1, 6, mxREAL);
  FileTimeToDateVec_Win(&WriteUTC, mxGetPr(Field), Type);
  mxSetFieldByNumber(Reply, 0, 2, Field);
  
  return;
}

// *****************************************************************************
void FileTimeToDateVec_Win(const FILETIME *UTC, double *DateVec,
                           enum ConversionType Type)
{
  // The input UTC file time is converted to the local time according with
  // different methods. The result is converted to a Matlab date vector.
  SYSTEMTIME ST, ST2;
  FILETIME   Local;
  
  switch (Type) {
    case LOCAL_TIME:
      // Convert UTC FILETIME to system time:
      if (FileTimeToSystemTime(UTC, &ST2) == 0) {
        mexErrMsgIdAndTxt("JSim:GetFileTime:BadToSystemTimeLOCAL",
                          "FILETIME to SYTEMTIME failed!");
      }
  
      // Convert UTC system time to local system time considering daylight
      // saving time at the specified time:
      if (SystemTimeToTzSpecificLocalTime(NULL, &ST2, &ST) == 0) {
        mexErrMsgIdAndTxt("JSim:GetFileTime:BadToTzSystemTime",
                          "FILETIME to specific SYTEMTIME failed!");
      }
      break;

    case WIN_TIME:
      // Convert UTC file time to local file time:
      if (FileTimeToLocalFileTime(UTC, &Local) == 0) {
        mexErrMsgIdAndTxt("JSim:GetFileTime:BadUTC2Local",
                          "UTC to local FILETIME failed!");
      }
  
      // Convert local file time to system time:
      if (FileTimeToSystemTime(&Local, &ST) == 0) {
        mexErrMsgIdAndTxt("JSim:GetFileTime:BadToSystemTimeWIN",
                          "FILETIME to SYTEMTIME failed!");
      }
      
      break;
            
    case UTC_TIME:
      // Convert local file time to system time:
      if (FileTimeToSystemTime(UTC, &ST) == 0) {
        mexErrMsgIdAndTxt("JSim:GetFileTime:BadToSystemTimeUTC",
                          "FILETIME to SYTEMTIME failed!");
      }
      
      break;
      
    default:  // Actually impossible if "enum ConversionType" is well defined:
      mexErrMsgIdAndTxt("JSim:GetFileTime:BadTypeSwitch", "Programming error!");
  }
  
  // Create a Matlab date vector (see DATEVEC):
  *DateVec++ = (double) ST.wYear;
  *DateVec++ = (double) ST.wMonth;
  *DateVec++ = (double) ST.wDay;
  *DateVec++ = (double) ST.wHour;
  *DateVec++ = (double) ST.wMinute;
  *DateVec   = (double) ST.wSecond + ((double) ST.wMilliseconds) / 1000;

  return;
}
