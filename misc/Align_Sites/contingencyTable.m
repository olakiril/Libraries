function contingencyTable(comp_cells,varargin)

% function compareTunning(comp_cells,varargin)
% 
% comapred the change of tuning between different conditions
% Accepts the differrent cells in rows and the same cells of different
% conditions in columns.
%
% MF 2009-12-23

params.thr = 0.05;
params.name = [];
params.comp = 2;

params = getParams(params,varargin);

% set names 
if isempty(params.name)
    for i = 1:size(comp_cells,2)
        params.name{i} = (['Condition' num2str(i)]);
    end
end

%initialize
poti = zeros(size(comp_cells));

for i = 1: size(comp_cells,2)
   
    % get object data
    fc = getObjectData(comp_cells(:,i),'input','cells',params);
    poti(:,i) = getPoti(fc)';
    
end

combinations = nchoosek(1: 1: size(comp_cells,2),params.comp);

% output
figure;
for i = 1:size(combinations,1)
    table = zeros(2,2);
    data = poti(:,combinations(i,:));
    
    % find tuned
    data = data <= params.thr;
    
    % calculate matrix
    table(2,1) = sum(data(:,1) == 1 & data(:,2) == 1);
    table(1,1) = sum(data(:,1) == 1 & data(:,2) == 0);
    table(2,2) = sum(data(:,1) == 0 & data(:,2) == 1);
    table(1,2) = sum(data(:,1) == 0 & data(:,2) == 0);
    
    %plot
    subplot(ceil(size(combinations,1)/2),ceil(size(combinations,1)/2),i)
    plottable(table);
     title('# cells')
    
    set(gca,'XTickLabel',{'S' 'N'});
    set(gca,'YTickLabel',{'S' 'N'});
    
    xlabel(gca,([num2str(params.name{combinations(i,1)}) ' (seq. #: ' num2str(combinations(i,1)) ')']));
    ylabel(gca,([num2str(params.name{combinations(i,2)}) ' (seq. #: ' num2str(combinations(i,2)) ')']));
    
end
    
    
set(gcf,'Color',[1 1 1])
    
    