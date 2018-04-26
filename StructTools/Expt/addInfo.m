function expt = addInfo(expt,ExptTable)
%
%
%

% Created:  7/15/10 - SRO

rigdef = RigDefs();

% Current struct version
expt.info.structversion = '2.0';

% Define some info fields
expt.info.exptfile = [expt.name '_expt'];
expt.info.table = ExptTable;

% info.mouse
expt.info.mouse.genotype = getFromExptTable(ExptTable,'Genotype');
expt.info.mouse.age = getFromExptTable(ExptTable,'Age');
expt.info.mouse.sex = getFromExptTable(ExptTable,'Sex');
expt.info.mouse.mass = getFromExptTable(ExptTable,'Mass');

% info.location
expt.info.location.region = getFromExptTable(ExptTable,'Brain region');
expt.info.location.coordinates = getFromExptTable(ExptTable,'Coordinates');
expt.info.location.bregma_lambda = getFromExptTable(ExptTable,'Bregma_lambda');

% info.transgene (seperate entry for each construct)
expt.info.transgene.typeTransfection = getFromExptTable(ExptTable,'Transfection type');
expt.info.transgene.ageTransfect = getFromExptTable(ExptTable,'Transfection age');
expt.info.transgene.construct1 = getFromExptTable(ExptTable,'Transgene 1');
expt.info.transgene.construct2 = getFromExptTable(ExptTable,'Transgene 2');

% info.anesthesia
expt.info.anesthesia = getFromExptTable(ExptTable,'Anesthesia');

% info.time
expt.info.time.begin = getFromExptTable(ExptTable,'Begin @');
expt.info.time.anesthesia = getFromExptTable(ExptTable,'Anesthesia @');
expt.info.time.craniotomy = getFromExptTable(ExptTable,'Craniotomy @');
expt.info.time.insertprobe = getFromExptTable(ExptTable,'Inserted probe @');
expt.info.time.startrecording = getFromExptTable(ExptTable,'Start recording @');
expt.info.time.end = getFromExptTable(ExptTable,'End @');
expt.info.time.duration = [];
if ~isempty(expt.info.time.begin) && ~isempty(expt.info.time.end)
    begin = expt.info.time.begin;
    endtime = expt.info.time.end;
    try % temporary - changed date format so will throw error with earlier expts
        duration = etime(datevec(endtime),datevec(begin))/3600; % In hours
        expt.info.time.duration = duration;
    end
end

% info.equipment
expt.info.equipment.amp = rigdef.equipment.amp;
expt.info.equipment.daqboard = rigdef.equipment.daqboard;


