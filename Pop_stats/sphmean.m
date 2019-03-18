function smean = sphmean(data)

% function smean = sphmean(data)
%
% data: [cells bins]
%
% calculates the spherical mean

V = sum(bsxfun(@rdivide,data,sqrt(sum(data.^2))),2);

smean = V/norm(V);
    