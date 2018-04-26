function fileIndex = GetFileInd(fileName)

startInd = strfind(fileName,'_');
startInd = startInd(end)+1;
endInd = strfind(fileName,'.daq')-1;
fileIndex = str2num(fileName(startInd:endInd));