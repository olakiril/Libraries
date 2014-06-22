function idx = findGrids(coordinates)

d = sqrt(sum(diff(coordinates).^2,2));
idx = {};
for i = 1:length(d)
    j = find(abs(d(i) - d) < 1e-3);
    gap = find(diff(j) >= 4);
    if ~isempty(gap)
        j(gap(1)+1:end) = [];
    end
    if length(j) >= 25 & ~ismember(i,cat(2,idx{:}))
        idx{end+1} = i:j(end)+1;
    end
end


