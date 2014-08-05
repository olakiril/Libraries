% function [reject, chi2, p, dof, edges, o, e] = chi2test(d, count, alpha, ecdf)
%
% Performs the chi-square goodness-of-fit test on the data in o.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% d: a vector of observed data (the samples themselves, not a histogram)
%
% count: a vector of two integers specifying the minimum and maximum number
% of samples per bin. Default: count = [5 max(5, floor(length(d)/10))].
% In this way, about ten bins are usually used, and none of them has
% fewer than five samples.
%
% alpha: the significance level. Default: alpha = 0.05
%
% ecdf: a cell array that specifies the cumulative probability
% distribution function of the null hypothesis. The first element of the
% cell array is a function handle. Subsequent elements, if any, are
% parameters (arrays, possibly scalar or vector). If
% ecdf = {f, p1, ..., pn}
% then it must be possible to call
% f(x, {p1, ..., pn})
% where x is a vector of values.
% Default: ecdf = {@(x) (1 + erf(x/sqrt(2)))/2}
% (the cumulative distribution of a Gaussian with mean 0 and standard
% deviation 1).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
%
% reject: true if the null hypothesis is rejected; false otherwise
%
% chi2: the chi-square statitstic
%
% p: the probability of observing the given statistics or a greater value
%
% dof: the degrees of freedom
%
% edges: the bin edges actually used for the statistics
%
% o: the histogram of observed data with the given bin edges
%
% e: the estimated histogram on the same bins
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [reject, chi2, p, dof, edges, o, e] = chi2test(d, count, alpha, ecdf)
if nargin < 2 || isempty(count)
    count = [5 max(5, floor(length(d)/10))];
end
if nargin < 3 || isempty(alpha)
    alpha = 0.05;
end
if nargin < 4 || isempty(ecdf)
    ecdf = {@(x) (1 + erf(x/sqrt(2)))/2};
end
% Check that there are enough data
d = d(:)';
n = length(d);
if n < 5
    error('Need at least five data points for chi-square statistic')
end
if count(2) < count(1)
    error('Maximum number of samples per bin cannot be smaller than minimum number')
end
if n < count(2)
    count(2) = n;
end
% Determine the bin edges and bin counts by histogram equalization
d = sort(d);
j = count(2):count(2):n; % Index of highest data point in each bin
if j(end) < n % Data do not divide evenly into the bins
    if n - j(end) < count(1)
        % Not enough data in the last bin: merge it with the one before
        j(end) = n;
    else
        % Enough data to add one bin at the end
        j = [j, n];
    end
end
% Internal bin edges first
edges = (d(j(1:(end-1))) + d(j(1:(end-1)) + 1)) / 2;
% Now add an edge at the beginning and one at the end
small = mean(d(j(1:(end-1)) + 1) - d(j(1:(end-1))));
edges = [d(1) - small, edges, d(end) + small];
% Observed bin counts
o = [j(1), j(2:end) - j(1:(end-1))];
% Compute expected bin counts under the null hypothesis
if length(ecdf) == 1 % No parameters
    c = ecdf{1}(edges);
else
    c = ecdf{1}(edges, ecdf(2:end));
end
e = n * (c(2:end) - c(1:(end-1)));
% Degrees of freedom
dof = length(o) - 1; % -1 because of the constraint on the number of data points
for k = 2:length(ecdf)
    dof = dof - numel(ecdf{k});
end
chi2 = sum((o - e).^2 ./ e);
p = 1 - chi2cdf(chi2, dof);
reject = p < alpha;

end

function p = chi2cdf(x, dof)
if dof < 1 || dof ~= round(dof)
    error('Degrees of freedom must be a positive integer')
end
if any(x < 0)
    error('The chi-square distribution is only defined for nonnegative x')
end
p = gammainc(x/2, dof/2);
% Just to make sure that round-off does not put p out of range
p(p < 0) = 0;
p(p > 1) = 1;
end
