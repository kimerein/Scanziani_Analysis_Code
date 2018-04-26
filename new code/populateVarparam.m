function expt=populateVarparam(expt)

% Only use this function if varparam fields in expt.stimulus were
% not populated because you used vStimController to present stimuli!

% Assumes used vStimController to present stimuli!!!!!!!!!!!!!

for i=1:length(expt.stimulus)
    % Which stimulus parameters varied?
    if ~isfield(expt.stimulus(i).params,'contrastValues')
        % Probably used PsychStimController on these trials
        % so change nothing
        continue
    end
    if length(expt.stimulus(i).params.contrastValues)>1
        contrastUsed=1;
    else
        contrastUsed=0;
    end
    if length(expt.stimulus(i).params.oriValues)>1
        orientsUsed=1;
    else
        orientsUsed=0;
    end
    if contrastUsed==1
        expt.stimulus(i).varparam(1).Name='Contrast';
        expt.stimulus(i).varparam(1).Values=expt.stimulus(i).params.contrastValues;
        if orientsUsed==1
            expt.stimulus(i).varparam(2).Name='Orientation';
            expt.stimulus(i).varparam(2).Values=expt.stimulus(i).params.oriValues;
        end
    else
        if orientsUsed==1
            expt.stimulus(i).varparam(1).Name='Orientation';
            expt.stimulus(i).varparam(1).Values=expt.stimulus(i).params.oriValues;
        else
            expt.stimulus(i).varparam(1).Name='None';
            expt.stimulus(i).varparam(1).Values=[];
        end
    end
end
disp('You should now save this expt!');