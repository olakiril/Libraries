function [xs, ys] = marginalSwap(x, y)
% Swap marginals (averages and conditional)
%   x and y are matrices, where each row contains one response trace, i.e.
%   if there are 10s with 500ms bins and 10 repetitions, x and y should be
%   10 x 20.
%
% AE 2013-06-04

[trials, bins] = size(x);

% get the ordering of the means for swapping the marginal firing rate
% distributions
[~, ox] = sort(mean(x, 1));
[~, oy] = sort(mean(y, 1));

xs = zeros(trials, bins);
ys = zeros(trials, bins);

for i = 1 : bins
    % get the ordering of the conditional distributions
    xi = x(:, ox(i));
    yi = y(:, oy(i));
    [~, oxi] = sort(xi);
    [~, oyi] = sort(yi);
    
    % swap both firing rate and conditional distributions while keeping the
    % dependency structure
    xs(oxi, ox(i)) = yi(oyi);
    ys(oyi, oy(i)) = xi(oxi);
end

