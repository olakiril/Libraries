

key.exp_date = '2011-03-03';
key.scan_idx = 13;
key.stim_idx = 1;
key.trace_opt = 6;
key.movie_type = 'natural';

% get traces and info
tracesR = fetchn(Traces(key),'trace');
tracesR = [tracesR{:}];
fps    = fetch1( Movies(key), 'fps' );

% get possitions
[cellx celly cellz] = fetchn(MaskCells(key),'img_x','img_y','img_z');

% Load times of the traces
[times stim] = fetch1(VisStims(key),'frame_timestamps','stim_file');

% equalize traces/times %%%%%% CHECK WHY
times = times(1,1:min([size(times,2) size(tracesR,1)]));
tracesR = tracesR(1:min([size(times,2) size(tracesR,1)]),:);

% stim times and types of movies shown
stimTimes = fetchn(StatsPresents(key),'movie_times');
movieTypes = fetchn(StatsPresents(key),'movie_num');
movieTypes = bsxfun(@eq,movieTypes,unique(movieTypes)');

% find trace segments for each stimulus and remove 0.5 from each
% side
traces = cell(1,length(stimTimes));
ttimes = cell(1,length(stimTimes));

for iTimes = 1:length(stimTimes)
    tindx = times > (stimTimes{iTimes}(1)) & ...
        times < (stimTimes{iTimes}(end));
    traces{iTimes} = tracesR(tindx,:);
    ttimes{iTimes} = times(tindx);
end

% remove incomplete trials
L = cell2mat(cellfun(@size,traces,'UniformOutput',0)');
indx = L(:,1) >= mean(L(:,1))*9/10;
traces = traces(indx);
ttimes = ttimes(indx);
L = L(indx);
movieTypes = movieTypes(indx,:);

% equalize
ttimes = cellfun(@(x) x(1:min(L)),ttimes,'UniformOutput',0);
traces = cellfun(@(x) x(1:min(L),:),traces,'UniformOutput',0);

% mean across same stimulus of different repetitions and collapse segments
traces = cat(3,traces{:});
ttimes = cat(3,ttimes{:});
t = cell(1,1);
tt = cell(1,1);
for iMovie = 1;%:size(movieTypes,2)
    t{iMovie} = mean(traces(:,:,movieTypes(:,iMovie)),3);
    tt{iMovie} = ttimes(:,:,1);
end
t = cell2mat(t);
tt = cell2mat(tt);
st = stimTimes{1};
s = std(t);
t(~bsxfun(@(t,s) t > 3 * s,t,s)) = 0;
%
x = 0:1:40;
y = exppdf(x,8);
y = y / y(1);


for i = 1:size(t,2)
    t(:,i) = conv(t(:,i),y,'same');
end
% normalize
t = bsxfun(@rdivide,bsxfun(@minus,t,min(t)),bsxfun(@minus,max(t),min(t)));

movie = mmreader('Z:\users\philipp\stimuli\MouseMovie\Mac\mov11_nat.mpg');

%% RF
key.masknum = 1;
key.stim_idx = 2;
key.rf_opt_num =6;
cluster =  fetch1(RFMap(key),'onpoff_rf');
[snr a] = fetch1(RFFit(key),'snr','gauss_fit');


figure
savemovie = 1;
%% plot

h = subplot(132);
mouse = importdata('Z:\users\Manolis\Graphics\mouselaser.jpg');
image(mouse)
axis(h,'image')
set(gca,'Visible','Off')

for ibin = 1:size(t,1)
    tic
    a = t(ibin,:)';
    z = [zeros(size(a,1),1)';a'; zeros(size(a,1),1)']';
    d = find(tt(ibin) < st,1,'first');
    if ~isempty(d)
        cdata = read(movie,d);
    end
    
    h = subplot(131);
    image(cdata)
    axis(h,'image')
    %     hold on
    %     gm=a(1:2); C=diag(a(3:4)); cc=a(5)*sqrt(prod(a(3:4))); C(1,2)=cc; C(2,1)=cc;
    %      g = plotGauss(gm,C,2,'pos',[size(cluster,2)+0.5,size(cluster,1)+0.5,movie.Width,movie.Height]);
    %         set(g,'Color',[1 0 0],'LineWidth',2)
    %     set(gca,'XTick',[])
    %     set(gca,'YTick',[])
    set(gca,'Visible','Off')
    
    
    subplot(133)
    scatter3(cellx,celly,cellz,300,'filled','CData',z)
    
    set(gca,'Visible','Off')
    set(gca,'CameraPositionMode','Manual');
    set(gca,'CameraPosition',[1500 -1500+4*ibin 380]);
    set(gcf,'Color',[1 1 1])
    drawnow

        set(gcf,'PaperUnits','centimeters')
        set(gcf,'PaperPosition',[1 1 200 20])
        print('-djpeg',num2str(ibin))
%         frame = importdata('movieout.jpg');
%         frames(ibin) = im2frame(frame); %#ok<SAGROW>

    
    time = toc;
    1/time
    if time < 1/fps
        pause(1/fps - time)
    end
end


% %%
% command = 'ffmpeg -i %s.avi -b 16000k -s 720x280 %s.mpg';
% movie2avi(frames,'test.avi','fps',30)
% system(sprintf(command,outfile,outfile));





