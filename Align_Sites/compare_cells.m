function comp_cells = compare_cells(sites,varargin)

% function comp_cells = compare_cells(sites)
% 
% comp_cells finds same cells across different sites with different
% conditions.
% Output: 2d array with same cells on different sites in columns
%
% MF 2009-12-22

params.condition = 'anesthesia';
params.cond_num = 3;

params = getParams(params,varargin);

global dataCon
sessMan = getContext(dataCon,'Session');

% filter by condition
condition = findMetaDataVec(sessMan,sites,params.condition);

% split the sites
aw_sites = sites(condition == 0);
an_sites = sites(condition == 1);

% get coordinates 
aw_x = findMetaDataVec(sessMan,aw_sites,'x');
aw_y = findMetaDataVec(sessMan,aw_sites,'y');
aw_z = findMetaDataVec(sessMan,aw_sites,'z');

an_x = findMetaDataVec(sessMan,an_sites,'x');
an_y = findMetaDataVec(sessMan,an_sites,'y');
an_z = findMetaDataVec(sessMan,an_sites,'z');

% initialize
site_ids = zeros(length(aw_sites),params.cond_num);
site_ids(:,1) = sites(condition == 0);

% find site Ids and arange per condition in column and different site in
% row
for i = 1:length(aw_sites)
     site_ids(i,2:params.cond_num) = an_sites(aw_x(i)== an_x & aw_y(i)== an_y & aw_z(i)== an_z);
end

% get rid sites that don't have the proper ammount of conditions
site_ids(logical(mean(a==0,2)),:) = [];

% initialize more
masks = cell(1,size(site_ids,2));
cells = cell(1,size(site_ids,2));
maskNum = cell(1,size(site_ids,2));
comp_cells = zeros(length(getCells(sites)),size(site_ids,2));

% loop through different sites
for i = 1:length(aw_sites)
    %loop through different conditions
    for j = 1:size(site_ids,2)
        mask = getData(dataCon,site_ids(i,j),'Image','type','mask');
        masks{j} =  getImage(mask);
        cells{j} = filterElementByType(sessMan,'Cell',site_ids(i,j));
        maskNum{j} = findMetaDataVec(sessMan,cells{j},'maskNum');
    end
    
    % get alignment possitions of cells for different sites
    aligned_cells = align_cells(masks);
    aligned_ids = zeros(size(aligned_cells));
    
    % loop through different conditions
    for j = 1:size(site_ids,2)
        % loop through different cells in the same condition same site
        for k = 1:size(aligned_cells,1)
            cell_mat = cells{j};
            % replace mask Id with CellId
            cell_m = cell_mat(maskNum{j}== aligned_cells(k,j));
            if isempty(cell_m)
                continue
            end
            aligned_ids(k,j) = cell_m;
        end
    end
    
    % get rid of non existing cells
    aligned_ids(logical(mean(aligned_ids==0,2)),:) = [];
    
    % put into a larger list
    ind = find(comp_cells==0,1,'first');
    comp_cells(ind:ind+size(aligned_ids,1)-1,:) = aligned_ids;
end

% crop the empty spots on the list
ind = find(comp_cells==0,1,'first');
comp_cells = comp_cells(1:ind-1,:);
