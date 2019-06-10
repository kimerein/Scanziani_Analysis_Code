function Parameters = createDefaultDaqParameters(savefilename)
% function Parameters = createDefaultDaqParameters(savefilename)


Parameters = cell(32,8);
Parameters(:,1) = cellfun(@num2str, mat2cell([1:size(Parameters,1)]',ones(size(Parameters,1),1)),'UniformOutput',0);
Parameters(:,2) = {'no'};
Parameters(:,3) = {''};
Parameters(:,4) = cellfun(@num2str, mat2cell([1:size(Parameters,1)]',ones(size(Parameters,1),1)),'UniformOutput',0);
Parameters(:,5) = {'[-5 5]'};
Parameters(:,6) = {'[-5 5]'};
Parameters(:,7) = {'[-10 10]'};
Parameters(:,8) = {'Volts'};

Parameters(1:3,2) = {'yes'};

Parameters(1,3) = {'Trigger'};
Parameters(2,3) = {'Ch1'};
Parameters(3,3) = {'Photodiode'};

Parameters(1,4) = {'31'};
Parameters(1,4) = {'17'};
Parameters(1,4) = {'16'};

save(savefilename,'Parameters');


