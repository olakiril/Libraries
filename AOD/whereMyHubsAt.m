function whereMyHubsAt(data)

[c p] = corrcoef(data);
p(c < 0) = 1;
c(c < 0) = 0;

% rescale in two dimensons
y = mdscale(abs(c),2);

perms = nchoosek(1:size(y,1),2);
ind = sub2ind(size(c),perms(:,1),perms(:,2));
[foo order] = sort(c(ind));

ind = ind(order);
perms = perms(order,:);

start = find(p(ind) < 0.000001,1)

% plot the network nodes and significant connection
clf

hold on
for k = start:size(perms,1)
    i = perms(k,1);
    j = perms(k,2);
    if(size(y,2) == 2)
        plot([y(i,1) y(j,1)],[y(i,2) y(j,2)],'color',1-[1 1 1]*abs(c(i,j)))
    else
        plot3([y(i,1) y(j,1)],[y(i,2) y(j,2)],[y(i,3) y(j,3)],'color',[1 1 1]*abs(p(i,j)),'LineWidth',0.5)        
    end
end

if(size(y,2) == 2)
    plot(y(:,1),y(:,2),'.');
else
    plot3(y(:,1),y(:,2),y(:,3),'.');
end
