function [u, l] = meanci(s,p)


p = (1-p)/2;
u = zeros(size(s,2));
l = u;
isOpen = matlabpool('size') ;
if isOpen
    R = RandStream.create('mrg32k3a','NumStreams',3,'Seed',0);
    RandStream.setGlobalStream(R)
    options = statset('UseParallel','always','Streams',{R,R,R,R});
else
    R = RandStream.create('mrg32k3a','Seed',0);
    RandStream.setGlobalStream(R)
    options = statset('Streams',R);
end
for i=1:size(s,2)
    medians = bootstrp(5000,@nanmean,s(:,i),'Options',options);
    l(i) = prctile(medians,100*p);
    u(i) = prctile(medians,100*(1-p));
end



