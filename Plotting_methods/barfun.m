function hout = barfun(data,varargin)

% function barfun(data,varargin)
%
% Barplots data in groups of rows with errorbars and significance test for
% all the pairs of each group
% Accepts data in:
%
% MF 2012-03

params.thr = 0.05;
params.fontsize = 12;
params.markersize = 0.5;
params.names = [];
params.angle = 45;
params.sig = 1;
params.bar = 1;
params.error = 'sde';
params.colors = [];
params.barwidth = 1;
params.test = 'anovan';
params.range = 0.5;

params = getParams(params,varargin);

% data = data';
values = cellfun(@nanmean,data);
if strcmp(params.error,'sde')
    errors = cellfun(@(x) nanstd(x)/sqrt(length(x)),data);
elseif  strcmp(params.error,'std')
    errors = cellfun(@(x) nanstd(x),data);
end

[nRows, nCols] = size(values);

if nCols == 1 || nRows ==1
    loc = 1:length(values);
else
    loc = bsxfun(@plus,repmat(linspace(1-params.range/2,1+params.range/2,nCols),nRows,1),(1:nRows)'-1);
end

%%%%%% edit for matlab 2014b
%colors = parula(nCols);
colors = cbrewer('qual','Set2',max([nCols,3]));
for i = 1:nCols
    handles.bar(i) = bar(loc(:,i),values(:,i),'barwidth',params.barwidth/nCols,...
        'faceColor',colors(i,:),'edgeColor',[1,1,1]); % standard implementation of bar fn
    hold on
end
%%%%%%

if ~isempty(params.colors)
    for i = 1:nCols
        set(handles.bar(i),'EdgeColor','none','FaceColor',params.colors(i,:));
    end
end
hold on

if nRows > 1
    %     loc = nan(nRows,nCols);
    for col = 1:nCols
        % Extract the x location data needed for the errorbar plots:
        %         loc(:,col) = mean(get(get(handles.bar(col),'children'),'xdata'),1);
        % Use the mean x values to call the standard errorbar fn; the
        % errorbars will now be centred on each bar:
        errorbar(loc(:,col),values(:,col),errors(:,col), '.','color',[0.3 0.3 0.3])
    end
else
    %     loc = mean(get(get(handles.bar,'children'),'xdata'),1);
    errorbar(loc,values,errors,'.','color',[0.3 0.3 0.3])
end

mx = max((values(:)) + errors(:));
if params.bar;mx = max([0 mx]);end
vsp = ( max(abs(values(:)) + errors(:)))*0.1;
if params.sig
    df =  mean(mean(diff(loc')));
    hsp = df*0.1;
    if nCols==1
        data = data';
        [nRows, nCols] = size(data);
    end
    for iRow = 1:nRows
        [~,seq] = sort(pdist(reshape(loc(iRow,:),[],1)));
        
        if nCols>2
            idx =squareform(1:length(seq));
            idx(logical(tril(ones(nCols),-1))) = 0;
            [xind, yind]= find(idx);
        else xind = 1;yind =2;
        end
        
        % correct error distances
        x1 = loc(xind(seq));
        x2 = loc(yind(seq));
        xd = loc(yind(seq)) - loc(xind(seq));
        uni = unique(xd);
        space = xd;
%         for i = 2:length(uni)
%             pairs = nchoosek(find(xd==uni(i)),2);
%             if size(pairs,2)>1
%                 for ipair = 1:size(pairs,1)
%                     [~,xi] = sort(x1(pairs(ipair,:)));
%                     if x1(pairs(ipair,xi(2)))<x2(pairs(ipair,xi(1))) && ...
%                             space(pairs(ipair,xi(2))) == space(pairs(ipair,xi(1)))
%                         indx = false(size(space));
%                         indx(pairs(ipair,xi(2))) = true;
%                         indx(xd>uni(i)) = true;
%                         space(indx) = space(indx)+1;
%                     end
%                 end
%             end
%         end
%         
        % plot the erros if significant
        if strcmp(params.test,'anovan')
            C = [];
            Dat = data(iRow,:);
            for idata = 1:length(Dat); C = [C;ones(length(Dat{idata}),1)*idata];end
            [~,~,stats] = anovan(cell2mat(cellfun(@(x) x(:),Dat(:),'uni',0)),C,'Display','off');
            stat = multcompare(stats,'display','off');
        end
        
        for iPair = 1:length(seq)
            if ~strcmp(params.test,'anovan')
                [sig, p] = eval([params.test '(data{iRow,xind(seq(iPair))},' ...
                    'data{iRow,yind(seq(iPair))},params.thr)']);
            else
               p = stat(stat(:,1)==xind(seq(iPair)) & stat(:,2)==yind(seq(iPair)),6);
               sig = p<params.thr;
            end
            
            if ~isnan(sig) && sig
                x1 = loc(iRow,xind(seq(iPair)));
                x2 = loc(iRow,yind(seq(iPair)));
                plot([x1+hsp x2-hsp],...
                    [mx+vsp*space(iPair) mx+vsp*space(iPair)],'k');
                text( roundall(mean([x1,x2]),0.001),...
                    double(mx+vsp*space(iPair)+vsp/2),pval(p),...
                    'FontSize',params.fontsize,'HorizontalAlignment',...
                    'center','VerticalAlignment','cap')
            end
        end
    end
    
    set(gca,'ylim',[min([0 min(values(:) - 2*errors(:))]) mx+vsp*(nCols+1)])
end

set(gca,'Box','Off');
set(gca,'FontSize',params.fontsize);
set(gca,'Xtick',1:nRows)
if ~isempty(params.names)
    set(gca,'XTickLabel',params.names)
%     if nCols==1
        ht = xticklabel_rotate([],params.angle,[]);
        set(ht,'HorizontalAlignment','right')
%     end
end

if ~params.bar
    delete(handles.bar)
    handles.bar = plot(values);
    set(gca,'xtick',1:length(values))
end
hold off

if nargout
    hout = handles.bar;
end

function ast = pval(p)
if p<0.001
    ast = '***';
elseif p<0.01
    ast = '**';
else ast = '*';
end


