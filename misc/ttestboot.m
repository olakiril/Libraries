function [H, alpha] = ttestboot(x1,x2,alpha,varargin)

params.nReps = 10000;  % repetition number

params = getParams(params,varargin);

if nargin<2
    x2 = 0;
end
if nargin<3
    alpha = 0.05;
end

myStatistic = @(x1,x2) median(x1)-median(x2);

sampStat = myStatistic(x1,x2);
bootstrapStat = zeros(params.nReps,1);
for i=1:params.nReps
    sampX1 = x1(ceil(rand(length(x1),1)*length(x1)));
    sampX2 = x2(ceil(rand(length(x2),1)*length(x2)));
    bootstrapStat(i) = myStatistic(sampX1,sampX2);
end

CI = prctile(bootstrapStat,[100*alpha/2,100*(1-alpha/2)]);

%Hypothesis test: Does the confidence interval cover zero?
H = CI(1)>0 | CI(2)<0;

if ~nargout
    clf
    xx = min(bootstrapStat):.01:max(bootstrapStat);
    hist(bootstrapStat,xx);
    hold on
    ylim = get(gca,'YLim');
    h1=plot(sampStat*[1,1],ylim,'y-','LineWidth',2);
    h2=plot(CI(1)*[1,1],ylim,'r-','LineWidth',2);
    plot(CI(2)*[1,1],ylim,'r-','LineWidth',2);
    h3=plot([0,0],ylim,'b-','LineWidth',2);
    xlabel('Difference between means');
    
    decision = {'Fail to reject H0','Reject H0'};
    title(decision(H+1));
    legend([h1,h2,h3],{'Sample mean',sprintf('%2.0f%% CI',100*alpha),'H0 mean'},'Location','NorthWest');
end