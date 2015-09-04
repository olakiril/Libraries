
%% find beh files

file = '15-04-03_12-13-31';
pathStart = 'G:/';

dirCam = dir([pathStart 'Camera']);
dirCam = dirCam([dirCam.isdir]);
dirCam = dirCam(3:end);
timCam = nan(length(dirCam),1);
for i = 1:length(dirCam)
    timCam(i) = datenum(dirCam(i).name,'yy-mm-dd_HH-MM-SS');
end
indCam = find((timCam - datenum(file,'yy-mm-dd_HH-MM-SS'))<0.5 & (timCam - datenum(file,'yy-mm-dd_HH-MM-SS'))>0,1,'first');

dirBeh = dir([pathStart 'Behavior\*.mat']);
timBeh = nan(length(dirBeh),1);
for i = 1:length(dirBeh)
    timBeh(i) = datenum(dirBeh(i).name(1:end-4),'yy-mm-dd_HH-MM-SS');
end
try idx = (timBeh - timCam(indCam)) < 0;catch; idx = true;end
indBeh = (timBeh - datenum(file,'yy-mm-dd_HH-MM-SS'))<0.5 & (timBeh - datenum(file,'yy-mm-dd_HH-MM-SS'))>0 & idx;
dirBeh = dirBeh(indBeh);

display(['Found: ' num2str(length(dirBeh)) ' behavioral mat files'])
% read data

op_d = loadHWS([pathStart 'Camera/' file '/cameradata.h5'],'lick','optical_detection');
el_d = loadHWS([pathStart 'Camera/' file '/cameradata.h5'],'lick','electrical_detection');
times = loadHWS([pathStart 'Camera/' file '/cameradata.h5'],'frametimes','frametimes');
juice = loadHWS([pathStart 'Camera/' file '/cameradata.h5'],'juice','juice');
ctimes = times(logical(juice));
beh_times = [];
beh_speed = [];
beh_touch = [];
dx = 0;
for i = 1:length(dirBeh)
    
    load([pathStart 'Behavior/' dirBeh(i).name])
    if size(log,2)==4
        log2.time = log(:,1);
        log2.speed =log(:,2);
        log2.dist =  log(:,3);
        log2.touch =  log(:,4);
        log = log2; 
    end
    dirCam = dir([pathStart 'Camera/' file '/' dirBeh(i).name '_timeCorrector.mat']);
    if isempty(dirCam)
        btimes = log.time(log.touch>18)*1000;
        if isempty(btimes); display('No juice delivered!');continue; end
        [delay, gain] = alignVectors([ctimes ones(length(ctimes),1)],btimes + (ctimes(1) -btimes(1)),'marker','.','dx',dx);
        gainfix = @(x,gn)  (x-x(1))*(1 + gn/100) + x(1);
        timeCorrector = @(x) gainfix(x*1000 + delay,gain) + (ctimes(1) -btimes(1));
        save([pathStart 'Camera/' file '/' dirBeh(i).name '_timeCorrector.mat'],'timeCorrector')
    else
        load([pathStart 'Camera/' file '/' dirBeh(i).name '_timeCorrector.mat'])
    end
    beh_times = [beh_times;timeCorrector(log.time)];
    beh_speed = [beh_speed;log.speed];
    beh_touch = [beh_touch;log.touch];
    ltim = log.time(~isnan(log.time));
    dx = ltim(end)*1000;
end

%%
fg = figure;
subplot(211)
plot((times-times(1))/1000,normalize(juice),'.','markerSize',10)
hold on
plot((beh_times-times(1))/1000,normalize(beh_touch>18)-0.025,'.k','markerSize',10)
plot((times-times(1))/1000,normalize(op_d)-0.1,'.r','markerSize',10)
plot((times-times(1))/1000,normalize(el_d)-0.05,'.g','markerSize',10)
plot((beh_times-times(1))/1000,normalize(beh_speed),'k')
ylim([0 1])
l = legend({'Juice Cam','Juice Beh','Lick opt','Lick ele','Speed'});
% av = VideoReader([pathStart 'Camera/' file '/eyemovie.avi']);
% im = read(av,1);

subplot(212)

viewBehavior(av,fg,(times-times(1))/1000)



