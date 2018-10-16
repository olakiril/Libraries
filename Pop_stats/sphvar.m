function svar = sphvar(data)

% function svar = sphvar(data)
%
% calculates the spherical variance

svar = 1 - norm(mean(bsxfun(@rdivide,data,sqrt(sum(data.^2))),2)); % spherical variance
    