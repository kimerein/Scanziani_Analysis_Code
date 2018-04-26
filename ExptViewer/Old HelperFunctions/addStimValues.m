function expt = addStimValues(expt)
% function expt = addStimValues(expt)
%
% Adds explicit representation of stimulus values for orientation and
% contrast to the sweeps struct.
%

% Created: 7/19/10 - SRO

% Add new fields to .sweeps struct
expt.sweeps.ori = [];
expt.sweeps.contrast = [];
expt.sweeps.location = [];
expt.sweeps.stimType = {};

sweepInd = 0;

% Loop through files
for fileInd = 1:length(expt.stimulus)
    
    % Get stimulus struct for particular file
    s = expt.stimulus(fileInd);
    
    % Determine which controller is used
    if isfield(s.params,'StimulusName')
        ctlrType = 'PsychStimController';
    elseif isfield(s.params,'stimType')
        ctlrType = 'vStimController';
    end
    
    switch ctlrType
        case 'PsychStimController'
           
            
        case 'vStimController'
            
            stimType = s.params.stimType;
            oriValues = s.params.oriValues;
            nOri = length(oriValues);
            cValues = s.params.contrastValues;
            nContrast = length(cValues);
            switch stimType
                case 'Localized gratings'
                    nLoc = s.params.columns * s.params.rows;
                    locValues = 1:(s.params.columns*s.params.rows);
                    
                case {'Drifting gratings','Reversing gratings'}
                    nLoc = 1;
                    locValues = NaN;
            end
            
            for i = 1:expt.files.triggers(fileInd)
                
                sweepInd = sweepInd + 1;
                tempcode = expt.sweeps.stimcond(sweepInd);
                
                if ~isnan(tempcode)
                    locInd = mod(tempcode-1,nLoc)+1;
                    oriInd = mod(ceil(tempcode/nLoc)-1,nOri)+1;
                    cInd = mod(ceil(tempcode/nLoc/nOri)-1,nContrast)+1;
                    % Set values
                    expt.sweeps.ori(sweepInd) = oriValues(oriInd);
                    expt.sweeps.contrast(sweepInd) = cValues(cInd);
                    expt.sweeps.location(sweepInd) = locValues(locInd);
                    expt.sweeps.stimType{sweepInd} = stimType;
                else
                    expt.sweeps.ori(sweepInd) = NaN;
                    expt.sweeps.contrast(sweepInd) = NaN;
                    expt.sweeps.location(sweepInd) = NaN;
                    expt.sweeps.stimType{sweepInd} = NaN;
                end
            end
            
    end
end