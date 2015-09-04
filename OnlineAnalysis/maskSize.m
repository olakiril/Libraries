function m = maskSize(mask,n)

close all
m = mask;
m(m~=1) = 2;
for i = 1:n*2
    m = m';
    d = diff(m);
    d(find(d==1)+1) = -1;
    d((d==1)) = 0;
    d(size(m,1),:) = 0;
    m(d~=0) = 1;
    
end

m = m - 1;
m = mask.*m;
m(m==0) = 1;

% if nargout<2
%     subplot(311)
%     imagesc(mask)
%     subplot(312)
%     imagesc(m)
%     subplot(313)
%     imagesc(m+mask)
% end