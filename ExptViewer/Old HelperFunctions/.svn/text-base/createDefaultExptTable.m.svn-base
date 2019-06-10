function ExptTable = createDefaultExptTable(savefilename)
% function ExptTable = createDefaultExptTable(savefilename)
% 

ExptTable = cell(1,0);
ExptTable{1,end+1} = 'Mouse number';
ExptTable{1,end+1} = 'Penentration number';
ExptTable{1,end+1} = 'Recording depth';
ExptTable{1,end+1} = 'Experiment name';
ExptTable{1,end+1} = 'Genotype';
ExptTable{1,end+1} = 'Age';
ExptTable{1,end+1} = 'Sex';
ExptTable{1,end+1} = 'Mass';
ExptTable{1,end+1} = 'Transgene 1';
ExptTable{1,end+1} = 'Transgene 2';
ExptTable{1,end+1} = 'Transfection age';
ExptTable{1,end+1} = 'Probe type';
ExptTable{1,end+1} = 'Probe ID';
ExptTable{1,end+1} = 'Probe use number';
ExptTable{1,end+1} = 'Probe configuration';
ExptTable{1,end+1} = 'Probe angle (from perpin to pia)';
ExptTable{1,end+1} = 'Anesthesia';
ExptTable{1,end+1} = 'Anesthesia@';
ExptTable{1,end+1} = 'Brain region';
ExptTable{1,end+1} = 'Inserted probe @';
ExptTable{1,end+1} = 'Start recording @';
ExptTable{1,end+1} = 'Notes';

% make 60 rows
temp = cell(60,2);
temp(:,:) = {''};
temp(1:size(ExptTable,2),1) = ExptTable;
ExptTable = temp;


save(savefilename,'ExptTable');

