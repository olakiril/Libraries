function histdiff(A,B,varargin)

% function histdiff(A,B,varargin)
%
% This function creates a histogram of the differences between A and B.
% It also provides a bar plot with the mean values of A & B
%
% MF 2011-08-23

params.fontsize = 13;
params.bin = 20;
params.title = '';
params.names = [{'A'},{'B'}];
params.thr = 0.001;
params.constrict = [99.99 99.99; 1 1];
params.figure = [];
params = getParams(params,varargin);


% remove outliers
if params.constrict
    i = A<prctile(A,params.constrict(1,2)) & A>prctile(A,params.constrict(2,2))...
        & B<prctile(B,params.constrict(1,1)) & B>prctile(B,params.constrict(2,1));
    A = A(i);
    B = B(i);
end

params.markersize = params.fontsize - 3;

if isempty(params.figure)
    f = figure;
    set(f,'Name',params.title)
else
    f = figure(params.figure);
    set(f,'Name',params.title)
end

hist(A - B,params.bin)
g = hist(A - B,params.bin);

[s p] = ttest(A - B);

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.3 0.3 0.3])

hold on

plot([mean(A - B) mean(A - B)],[0 max(g)*1.2],'--r','LineWidth',2)
plot([0 0],[0 max(g)*1.2],'k','LineWidth',1)

ylabel('Count','FontSize',params.fontsize,'Interpreter','none')
xlabel([params.names{1} ' - ' params.names{2}],'FontSize',params.fontsize,'Interpreter','none');
set(gcf,'Color',[1 1 1]);
set(gca,'Box','Off')
set(gca,'FontSize',params.fontsize)
A = double(A);
B = double(B);
if s == 1
    text(max(A-B)*0.8,max(g)/3,['mean: ' num2str(roundall(mean(A - B)))],'FontSize',params.fontsize);
    text(max(A-B)*0.8,max(g)/4,['p < ' num2str(params.thr)],'FontSize',params.fontsize)
end
title(params.title,'Interpreter','none')
barInsert(A,B,params);

