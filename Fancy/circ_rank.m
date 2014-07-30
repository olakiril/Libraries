function varargout = circ_rank(varargin)

% function ranked_angles = circ_rank(angles)
%
% gives the circular rank of a population of angles
% input: angles in pi dimention
%
% MF 2009-08-14

% make sure input was not cell from before
if iscell(varargin{1})
    varargin = varargin{1};
end

% get the index of different populations
population_index = cell(1,length(varargin));
for i = 1:length(varargin)
    if i > 1
    indxSize = max(population_index{i - 1});
    else
        indxSize = 0;
    end
    population_index{i} = indxSize + 1 : indxSize + length(varargin{i});
end

% put the angels into one matrix
angles = cell2mat(varargin);

% circular correction
angles(angles>(pi/2)) = pi - angles(angles>(pi/2));

% find the ranks
ranked_angles = tiedrank(angles);
circular_rank = 2*pi*ranked_angles/length(ranked_angles);

% split the data into different populations
varargout = cell(1,length(varargin));
for i = 1:length(varargin)
    varargout{i} = circular_rank(population_index{i});
end






