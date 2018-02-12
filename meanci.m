function [u, l] = meanci(s,p,singlethread)

if nargin<3
    singlethread = false;
end

p = (1-p)/2;
u = zeros(size(s,2),1);
l = u;
cp = gcp('nocreate');
if ~isempty(cp) && ~singlethread
    R = RandStream.create('mrg32k3a','NumStreams',cp.NumWorkers,'Seed',0);
    RandStream.setGlobalStream(R)
    options = eval(['statset(''UseParallel'',''always'',''Streams'',{R ' repmat(',R',1,cp.NumWorkers-1) '})']);
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





