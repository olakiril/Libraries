function compareTunning(comp_cells,varargin)

% function compareTunning(comp_cells,varargin)
% 
% comapred the change of tuning between different conditions
% Accepts the differrent cells in rows and the same cells of different
% conditions in columns.
%
% MF 2009-12-23

params.thr = 0.05;
params.sign = 1;
params.normalize = 1;
params.name = [];
params.method = 'sem';
params.alignState = 1;

params = getParams(params,varargin);

global dataCon

% set names 
if isempty(params.name)
    for i = 1:size(comp_cells,2)
        params.name{i} = (['Condition' num2str(i)]);
    end
end

%initialize
new_tuning = zeros(size(comp_cells,1),16,size(comp_cells,2));
poti = zeros(size(comp_cells,1));
stateSeq = circshift(1:size(comp_cells,2),[0 1 - params.alignState]);

for k = 1: size(comp_cells,2)
    i = stateSeq(k);
   
    % get object data
    fc = getObjectData(comp_cells(:,i),'input','cells',params);
    tuning = getAreaMatrixMean(fc);
    poti(:,i) = getPoti(fc);
    
    for j = 1:size(tuning,1)
        
        % find prefered orientation
        if i == params.alignState
            [a b] = max(tuning(j,:));
            if j == 1
                 prefOriIndx = floor(size(tuning,2)/2);
            end
        end
        
        % align everything to the prefered orientation of the one condition
        tun_s = circshift(tuning(j,:),[0 prefOriIndx-b]);
        
        %normalize
        if params.normalize
            new_tuning(j,:,i) = (tun_s - min(tun_s)) / (max(tun_s) - min(tun_s));
            yName = ('Normalized Amplitude');
        else
            new_tuning(j,:,i) = tun_s;
            yName = ('Raw Amplitude');
        end   
    end    
end

% select significant cells only
if params.sign == 3
    tuning = new_tuning(poti(:,1)<= params.thr & poti(:,2)<= params.thr & poti(:,3)<= params.thr,:,:);  
elseif params.sign == 2
    tuning = new_tuning(poti(:,1)<= params.thr & poti(:,2)<= params.thr,:,:);  
else
    tuning = new_tuning(poti(:,params.alignState)<= params.thr,:,:);   
end
    
% find limits for axes
st_dev = std(new_tuning,0,1);
Ymax = max(max(mean(new_tuning,1) + st_dev));
Ymin = min(min(mean(new_tuning,1) - st_dev));
steps = abs((2:2:size(tuning,2)) - prefOriIndx)*360/size(tuning,2);

% plot
figure 
for i = 1:size(tuning,3)
    
    % put condition to compare in the middle
    j = fliplr(circshift(1:size(tuning,3),[0 floor(mean(1:size(tuning,3)))-1]));
 
    subplot(size(tuning,3),1,i);
        
    errorPlot(1:size(tuning,2),tuning(:,:,j(i)),'method',params.method);
    
    % set labels
    title(params.name{j(i)});
 
    set(gca,'YLim',[Ymin Ymax])
    set(gca,'XLim',[1 size(tuning,2)])

    if i == size(tuning,3);
        xlabel(gca,('Difference from the preffered Orientation'));
        set(gca,'xtick',2:2:size(tuning,2));
        set(gca,'XTickLabel',steps);
    else
        set(gca,'xtick',1);
        set(gca,'XTickLabel',[]);
    end

    if i == round(mean(1:size(tuning,3)))
        ylabel(gca,yName); 
    end
end

display (['# cells: ' num2str(size(tuning,1))]);

set(gcf,'Color',[1 1 1])


