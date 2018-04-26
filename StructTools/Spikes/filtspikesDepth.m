function spikes = filtspikesDepth(spikes,depth)
% function spikes = filtspikesDepth(spikes,depth)
%
% INPUT
%   spikes
%   depth: Either a 2-element [edge1 edge2] or 1-element [center] vector
%
% OUTPUT
%   spikes:

%


if length(depth) == 1
    depth = [depth-1 depth+1];
end

% Greater than depth(1)
spikes = makeTempField(spikes,'depth',depth(1),'greater');
spikes = filtspikes(spikes,0,'temp',1);
% Less than depth(2)
spikes = makeTempField(spikes,'depth',depth(2),'less');
spikes = filtspikes(spikes,0,'temp',1);