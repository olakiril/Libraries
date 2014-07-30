function class = classfinder(data,thr)

% function class = classfinder(data,varargin)
%
% Classifies points into groups with a given threshold
% 
% Data have the cases to classify in rows and the different measuments in columns
%
% MF 2011-10-06

if nargin<2
    thr = 100;
end

class = ones(size(data,1),1);
mdist = data(1,:);
for icase = 2:1:size(data,1)
   dist = pdist2(data(icase,:),mdist);
   [mindist minind] = min(dist);
    if mindist < thr
        mdist(minind,:) = mean([mdist(minind,:);data(icase,:)]);
        class(icase) = minind;
    else
        class(icase) = size(mdist,1)+1;
        mdist(end+1,:) = data(icase,:); %#ok<AGROW>
        
    end
end