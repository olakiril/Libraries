function plotScan(fn,raw)

if nargin < 2, raw = false; end

[path fn ext] = fileparts(fn);
fn = fullfile(path,[fn '.mat']);
data = load(fn);

disp(sprintf('Fs=%0.1f',1/mean(diff(data.time))))

[c p] = princomp(data.traces);
a = var(p);
p = resample(p(:,1),length(data.mot_t),length(data.time));
disp(sprintf('Energy in first two PC: %0.2f%%',100*sum(a(1:2)) / sum(a)))
disp(sprintf('Skew corrected %0.3f.  Skew raw %0.3f',median(skewness(data.cleanTraces)), median(skewness(data.traces))));

figure(1)
clf
ds = 1;
if ds == 1
    traces = data.cleanTraces;
else
    for i = 1:size(data.cleanTraces,2)
        traces(:,i) = decimate(data.cleanTraces(:,i),ds);
    end
end
plot(data.time(1:ds:end),bsxfun(@plus,traces * 4, 1:size(traces,2)));

figure(4)
clf
ds = 1;
if ds == 1
    traces = data.traces;
else
    for i = 1:size(data.cleanTraces,2)
        traces(:,i) = decimate(data.cleanTraces(:,i),ds);
    end
end
plot(data.time(1:ds:end),bsxfun(@plus,traces * 4, 1:size(traces,2)));

figure(2)

h(1) = subplot(3,1,1);
plot(data.time,bsxfun(@plus,data.traces * 4, 1:size(data.traces,2)));

h(2) = subplot(3,1,2);
plot(data.time,bsxfun(@plus,data.cleanTraces * 4, 1:size(data.cleanTraces,2)));

h(3) = subplot(3,1,3);
plot(data.mot_t,data.xpos,data.mot_t,data.ypos+4,data.mot_t,data.zpos+8,data.mot_t,p-4)


figure(3)
subplot(411)
plot(data.xpos,p,'.')
subplot(412)
plot(data.ypos,p,'.')
subplot(413)
plot(data.zpos,p,'.')

[xCoh f] = mscohere(p,data.xpos,200,[],[],1/mean(diff(data.mot_t)));
[yCoh f] = mscohere(p,data.ypos,200,[],[],1/mean(diff(data.mot_t)));
[zCoh f] = mscohere(p,data.zpos,200,[],[],1/mean(diff(data.mot_t)));

[r foo foo foo stats1] = regress(p,[ones(length(p),1) data.xpos data.ypos]);% data.zpos]);
[r foo foo foo stats2] = regress(p,[ones(length(p),1) data.xpos data.ypos data.zpos]);

subplot(414)
plot(f,xCoh,f,yCoh,f,zCoh)

disp(sprintf('R2 for motion regression (no Z) on PC: %0.4f, p=%0.4f',stats1(1),stats1(3)))
disp(sprintf('R2 for motion regression (with Z) on PC: %0.4f, p=%0.4f',stats2(1),stats2(3)))
%skewness(p(:,1))]

linkaxes(h(1:2));

figure(5);
[path fn ext] = fileparts(fn);
fn = fullfile(path,[fn '.h5']);
mot = loadMotion(fn);
mot = mean(mot,4);
mot = permute(mot,[3 2 1]);
mot(:,:,1) = mot(:,:,1) / max(reshape(mot(:,:,1),1,[]));
mot(:,:,2) = mot(:,:,2) / max(reshape(mot(:,:,1),1,[]));
imagesc(mot);
%linkaxes(h,'x');

%xlim([0 100])
%ylim([0 30])
