function plotStimulus(stim)

startT = nan(length(stim.params.trials),1);
endT = nan(length(stim.params.trials),1);
start= nan(length(stim.params.trials),1);

    startIndx = find(strcmp(vertcat(stim.eventTypes),'showStimulus'));
    endIndx = find(strcmp(vertcat(stim.eventTypes),'endStimulus'));
     sIndx = find(strcmp(vertcat(stim.eventTypes),'startTrial'));
  
        
for itrial = 1:length(stim.params.trials)

    startT(itrial) = stim.events(itrial).syncedTimes(stim.events(itrial).types == startIndx);
    endT(itrial) = stim.events(itrial).syncedTimes(stim.events(itrial).types == endIndx);
    start(itrial) = stim.events(itrial).syncedTimes(stim.events(itrial).types == sIndx);
end
% convert to seconds
startT = startT/1000 ;
endT = endT/1000 ;
start = start/1000 ;

stimulus = reshape([ones(1,length(stim.params.trials) - 1); ones(1,length(stim.params.trials)- 1)...
    ;zeros(1,length(stim.params.trials)- 1); zeros(1,length(stim.params.trials)- 1)],[],1);

R = reshape([startT(1:end-1)';endT(1:end-1)';endT(1:end-1)' ; startT(2:end)'],[],1);
plot(R,stimulus)
hold on
plot(start,zeros(size(start)),'.r')
set(gcf,'color',[1 1 1])
set(gca,'box','off','Ylim',[-2 4],'YTick',[0 1],'YTickLabel',{'off','on'})
xlabel('seconds')
ylabel('stimulus')
