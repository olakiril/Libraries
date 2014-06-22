function S = isingFeature(n,order)

% S = isingFeature(n,order)
%   Computes feature matrix for an Ising Model of order two or three in n 
%   dimensions. The first n rows are the 'mean features' x_i, the next 'n
%   choose 2' rows are the 'second moment features' x_i x_j and the last 'n
%   choose 3' rows are the 'third moment features' x_i x_j x_k, where
%   applicable. Implementation uses logical arrays to save memory and
%   avoids extensive looping for the first order features. 
%
%   Input:
%       n       dimension
%       order   order of the model (valid: [2]/3)
%
%   Output:
%       S       feature matrix (# features x 2^n)
%
% PHB 2008-08-01


X = 0:2^n-1;

% order determines the order of the model
% default: second order, maximum: third order
if nargin < 2
    order = 2;
end


% compute first order features
cc = zeros(size(X));
S = false(n,size(X,2));
for i=n:-1:1
    idx = X>=2^(i-1);
    S(n-i+1,idx)=true;
    cc(idx) = cc(idx)+1;
    X(idx) = X(idx) - 2^(i-1);    
end


% compute second order features
if order>1
    SS = false(nchoosek(n,2),size(S,2));
    c = 1;
    for i=1:n
        for j=i+1:n
            SS(c,:) = S(j,:).*S(i,:);
            c = c+1;
        end    
    end
    S = [S;SS];
end

% compute third order features
if order>2
    SS = false(nchoosek(n,3),size(S,2));
    c = 1;
    for i=1:n
        for j=i+1:n
            for k=j+1:n
                SS(c,:) = S(j,:).*S(i,:).*S(k,:);
                c = c+1;
            end
        end    
    end
    S = [S;SS];
end



