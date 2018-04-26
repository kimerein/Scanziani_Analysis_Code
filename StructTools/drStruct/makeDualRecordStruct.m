function dr = makeDualRecordStruct(expt_names,unit_tags,depth_range)
% function makeDualRecordStruct(expt_names,unit_tags)
%
% INPUT
%   expt_names: Cell array of expt pairs (one LGN, one V1)
%   unit_tags: Unit tag for mua
%   depth_range 
%

% Created: SRO 6/9/11

if nargin < 3 || isempty(depth_range)
    depth_range = {[-inf inf],[-inf inf]};
end

rdef = RigDefs;

drDir = 'C:\Users\shawn\Documents\MATLAB\L6 Final Analysis\Dual LGN V1 recording\Dual recording structs\';

dr.expt_names = expt_names;
dr.unit_tags = unit_tags;
dr.fname = make_fname(expt_names,drDir);
dr.tfcn = [];

% Make "unit array" for
for i = 1:length(expt_names)
    expt_last_fname = [rdef.Dir.Expt expt_names{i} '_expt'];
    expt = loadvar(expt_last_fname);
    
    ua(i).expt_last_fname = expt_last_fname;
    ua(i).unit_tag = unit_tags{i}{1};
    ua(i).depth_range = depth_range{i};
    
    if strfind(expt.name,'LGN')
        ua(i).rec_loc = 'LGN';
    elseif strfind(expt.name,'V1')
        ua(i).rec_loc = 'V1';
    end
    
end

% Verify LGN data comes first in ua
if strcmp(ua(1).rec_loc,'V1');
    tmp(1) = ua(2);
    tmp(2) = ua(1);
    ua = tmp;
end

ua = addAnalysisToUa(ua,{'other'});
ua = addResponseMatToUa(ua,'other');


% Comute normalized response
for u = 1:length(ua)
    tmp = ua(u).fr.ledon;
    tmp = tmp - min(tmp(:,1));
    tmp = tmp./max(tmp(6,1));
    ua(u).fr.norm = tmp;
    
    tmp = ua(u).fr.ledon;
    tmp = tmp - min(tmp(:,1));
    ua(u).sem.norm = ua(u).sem.ledon/max(tmp(6,1));
end

dr.ua = ua;

% Save struct
sv(dr);


function fname = make_fname(expt_names,drDir)

for i = 1:length(expt_names)
    tmp = expt_names{i};
    k = strfind(tmp,'LGN_');
    if k
        tmp(k:k+3) = '';
        fname = tmp;
    end
end

fname = [drDir fname '_dr'];



