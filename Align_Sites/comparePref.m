function comparePref(comp_cells,varargin)

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
prOri = zeros(size(comp_cells));

for i = 1: size(comp_cells,2)
   
    % get object data
    fc = getObjectData(comp_cells(:,i),'input','cells',params);
    poti(:,i) = getPoti(fc)';
    prOri(:,i) = getVonMises(fc,3)';
    
end

combinations = nchoosek(1: 1: size(comp_cells,2),params.comp);

% output
figure;

for i = 1:size(combinations,1)

    potiNew = poti(:,combinations(i,:));
    oriNew = prOri(:,combinations(i,:));

    % find tuned
    dataTun = potiNew <= params.thr;

    % calculate matrix
    ori = oriNew (dataTun(:,1) == 1 & dataTun(:,2) == 1,:);

    for j = 1:size(ori,1)
        ori(j,2) = abs(circ_dist2(ori(j,2)*2,circ_dist2(ori(j,1)*2))/2);
    end

    %plot
    subplot(ceil(size(combinations,1)/2),ceil(size(combinations,1)/2),i)

    [x b] = sort(ori(:,1));
    y = ori(:,2);
    y = y(b);
    p = polyfit(x,y,3);
    f = polyval(p,x);
    plot(x,y,'.',x,f,'-')

    xlabel(gca,num2str(params.name{combinations(i,1)}));
    ylabel(gca,num2str(params.name{combinations(i,2)}));

end

    
set(gcf,'Color',[1 1 1])
    
    