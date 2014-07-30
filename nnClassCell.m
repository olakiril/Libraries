function  p = nnclassCell(traces,varargin)

% function [J rJ] = nnclassCell(traces)
%
% performs a nearest neighbor classification
% traces: [cells classes trials]
%
% MF 2011-08-25

% do it
p = cell(size(traces,2),1);
parfor iClass = 1:size(traces,2)
    for iTrial = 1:length(traces{1,iClass})
        ind = true(length(traces{1,iClass}),1);
        ind(iTrial) = false;
        tr = traces;
        tr(:,iClass) = cellfun(@(x) x(ind),tr(:,iClass),'uniformoutput',0);
        r = cellfun(@mean,tr);
        dist = pdist2(r',cellfun(@(x) x(iTrial),traces(:,iClass))');
        [~,indx] = min(dist);
        p{iClass}(iTrial) = indx == iClass;
    end
end
