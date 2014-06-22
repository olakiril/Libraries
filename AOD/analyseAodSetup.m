%% Process XY scanning on the scan AODs
dat = dlmread('HP_Sweep.csv');

pan = dat(:,7);
tilt = dat(:,8);

xhp = dat(:,1);
xlp = dat(:,2);
yhp = dat(:,3);
ylp = dat(:,4);

plot(xhp(:),pan(:),'.')
plot(yhp(:),pan(:),'.')

command = [xhp yhp];
command = [xlp ylp];
command = [ylp yhp];
command = [xlp xhp];

% select the points with enough power for a good
% fit
idx = dat(:,end) > .1;

b_tilt = robustfit(command(idx,:),tilt(idx,:));
b_pan = robustfit(command(idx,:),pan(idx,:));

%plot([0 b_tilt(2)],[0 b_tilt(3)],[0 b_pan(2)],[0 b_pan(3)])
plot([0 b_tilt(2)],[0 b_pan(2)],[0 b_tilt(3)],[0 b_pan(3)])
atan(b_pan(2)/b_tilt(2))/pi*180
atan(b_pan(3)/b_tilt(3))/pi*180

%% Check alignment between chirp and scanning AODs
datX = dlmread('X_Sweep.csv');
datY = dlmread('Y_Sweep.csv');

%% Check data with all captured
dat = dlmread('All_Sweep_AfterAdjust.csv');
pan = dat(:,7);
tilt = dat(:,8);
b_pan = robustfit(dat(:,1:4),pan);
b_tilt = robustfit(dat(:,1:4),tilt);

%% Map power
dat = dlmread('LP_PowerSweep.csv');
imagesc(xhp(1:20:end)/2^32*400,yhp(1:20)/2^32*400,reshape(dat(:,end),20,20)'/2);
xlabel('X freq (MHz)'); 
ylabel('Y freq (MHz)');
