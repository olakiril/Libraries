function [hout,values,errorsL,errorsU]= barfun(data,varargin)

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
params.colors = [0.7 0.7 0.72];
params.barwidth = 0.9;
params.test = 'anovan';
params.range = 0.9;
params.average = 'nanmean';
params.alpha = 1;
params.prc = 0.9;
params.capsize = 1;
params.markersize = 2;
params.rawback = 0;
params.markeralpha = 0.4;
params.isoutlier = 1;
params.rawrange = 0.6;
params.markercolor = [0.6 0.6 0.6]; 
    
params = getParams(params,varargin);

% convert data to columns
data = cellfun(@(x) x(:),data,'uni',0);
[nRows, nCols] = size(data);
if nCols == 1 || nRows ==1
    data = reshape(data,length(data),1);
end
disp_dat = [];

% data = data';
values = eval(sprintf('cellfun(@%s,data)',params.average));
if strcmp(params.error,'sde')
    errorsU = cellfun(@(x) nanstd(x)/sqrt(length(x)),data);
    errorsL = -errorsU;
elseif  strcmp(params.error,'std')
    errorsU = cellfun(@(x) nanstd(x),data);
    errorsL = -errorsU;
elseif strcmp(params.error,'medianci')
    for x = 1:size(data,1)
        for y = 1:size(data,2)
            [errorsU(x,y), errorsL(x,y)] = medianci(data{x,y},params.prc);
            errorsL(x,y) = errorsL(x,y) - nanmedian(data{x,y});
            errorsU(x,y) = errorsU(x,y) - nanmedian(data{x,y});
        end
    end
end

[nRows, nCols] = size(values);
width = params.barwidth/nCols;
loc = bsxfun(@plus,repmat(linspace(1-params.range/2 + width/2,1+params.range/2 -width/2,nCols),nRows,1),(1:nRows)'-1);

ncolors = nCols;if nCols==1;ncolors=nRows;end
if iscell(params.colors)
    assert(all(size(params.colors),size(values)))
elseif isempty(params.colors) || size(params.colors,1)<ncolors
    params.colors = cbrewer('qual','Pastel1',max([ncolors,3]));
end

        hold on
for i = 1:nCols
    for k = 1:nRows
           if params.rawback; plotrawdata; end
        if nCols==1; icolor=k;else;icolor=i;end
        color = params.colors(icolor,:);
        if  size(params.colors,1)>ncolors
          color = hsv2rgb(rgb2hsv(color).*[1 i/nCols 1]);
        end
    
        handles.bar(i,k) = bar(loc(k,i),values(k,i),'barwidth',width,...
            'faceColor',color,'edgeColor','none',...
            'LineStyle','none','FaceAlpha',params.alpha); % standard implementation of bar fn

        handles.bar(i,k).BaseLine.LineStyle = 'none';
%         if params.rawback; plotrawdata; end

    end
end

if nRows > 1
    %     loc = nan(nRows,nCols);
    for col = 1:nCols
        % Extract the x location data needed for the errorbar plots:
        %         loc(:,col) = mean(get(get(handles.bar(col),'children'),'xdata'),1);
        % Use the mean x values to call the standard errorbar fn; the
        % errorbars will now be centred on each bar:
        errorbar(loc(:,col),values(:,col),errorsL(:,col),errorsU(:,col),'linestyle','none','color',[0.3 0.3 0.3],'CapSize',params.capsize)
    end
else
    %     loc = mean(get(get(handles.bar,'children'),'xdata'),1);
    errorbar(loc,values,errorsL,errorsU,'linestyle','none','color',[0.3 0.3 0.3],'CapSize',2)
end

mx = max((values(:)) + errorsU(:));
mn = 0;
sp_update =  max(abs((values(:)) + errorsU(:)))*0.01;
if params.bar;mx = max([0 mx]);end
vsp = ( max(abs(values(:)) + errorsU(:)))*0.1;
if params.sig
    df =  mean(mean(diff(loc')));
    hsp = df*0.1;
    if nCols==1
        data = data';
        loc = loc';
        [nRows, nCols] = size(data);
    end
    for iRow = 1:nRows
        %         [~,seq] = sort(pdist(reshape(loc(iRow,:),[],1)));
        %
        seq = nchoosek(size(loc,2),2):-1:1;
        if nCols>2
            idx =squareform(1:length(seq));
            idx(logical(tril(ones(nCols),-1))) = 0;
            [xind, yind]= find(idx);
            [xind,x_sort] = sort(xind);
            yind = yind(x_sort);
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
        if any(strcmp(params.test,{'anovan','kruskalwallis'}))
            C = [];
            Dat = data(iRow,:);
            for idata = 1:length(Dat); C = [C;ones(length(Dat{idata}),1)*idata];end
            if strcmp(params.test,'anovan')
                [~,~,stats] = anovan(cell2mat(cellfun(@(x) x(:),Dat(:),'uni',0)),C,'Display','off');
            elseif strcmp(params.test,'kruskalwallis')
                [~,~,stats] = kruskalwallis(cell2mat(cellfun(@(x) x(:),Dat(:),'uni',0)),C,'off');
            end
            stat = multcompare(stats,'display','off');
        end
        
        sp = sp_update;
        for iPair = 1:length(seq)
            if any(strcmp(params.test,{'anovan','kruskalwallis'}))
                p = stat(stat(:,1)==xind(seq(iPair)) & stat(:,2)==yind(seq(iPair)),6);
                sig = p<params.thr;
            elseif any(strcmp(params.test,{'ranksum','signrank'}))
                p = eval([params.test '(data{iRow,xind(seq(iPair))},' ...
                    'data{iRow,yind(seq(iPair))})']);
                sig = p<params.thr;
            else
                [sig, p] = eval([params.test '(data{iRow,xind(seq(iPair))},' ...
                    'data{iRow,yind(seq(iPair))},params.thr)']);
            end
            
            if ~isnan(sig) && sig
                x1 = loc(iRow,xind(seq(iPair)));
                x2 = loc(iRow,yind(seq(iPair)));
%                                 plot([x1+hsp x2-hsp],...
%                                     [mx+vsp*space(iPair) mx+vsp*space(iPair)],'k');
                                text( roundall(mean([x1,x2]),0.001),...
                                    double(mx+vsp*space(iPair)+vsp/2),pval(p),...
                                    'FontSize',params.fontsize,'HorizontalAlignment',...
                                    'center','VerticalAlignment','cap')
                sp = sp+sp_update;
                plot([x1+hsp x2-hsp],...
                    [mx+sp mx+sp],'k');
%                                 text( roundall(mean([x1,x2]),0.001),...
%                                     double(mx+vsp*space(iPair)+vsp/2),pval(p),...
%                                     'FontSize',params.fontsize,'HorizontalAlignment',...
%                                     'center','VerticalAlignment','cap')
            end
        end
    end
    
%     set(gca,'ylim',[min([0 min(values(:) - 2*errorsU(:))]) mx+vsp*(nCols+1)])
%     set(gca,'ylim',[min([0 min(values(:) - 2*errorsU(:))]) mx+2*sp])

end

if params.rawback
        set(gca,'ylim',[min([0 min(min(cellfun(@(x) nanmin(x(:)),disp_dat)))]) max(max(cellfun(@(x) nanmax(x(:)),disp_dat)))])
end

set(gca,'Box','Off');
set(gca,'FontSize',params.fontsize);
if nRows==1
    set(gca,'Xtick',1:nCols)
else
    set(gca,'Xtick',1:nRows)
end

if ~params.bar
    delete(handles.bar)
    handles.bar = plot(values);
    set(gca,'xtick',1:length(values))
end
hold off

if ~isempty(params.names)
    set(gca,'XTickLabel',params.names,'XTickLabelRotation',params.angle)
end

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
end

function plotrawdata
    offset = invprctile(data{k,i},data{k,i})/100;
    offset = 1 - abs(offset - 0.5)/0.5;
    disp_dat{k,i}  = data{k,i};
    if params.isoutlier
        disp_dat{k,i} = disp_dat{k,i}(~isoutlier(disp_dat{k,i}));
    end
    p = scatter(min(width*params.rawrange/2,max(-width*params.rawrange/2,...
        normrnd(0,0.2,length(disp_dat{k,i}),1)*width*params.rawrange))+ loc(k,i),disp_dat{k,i},params.markersize,...
        'MarkerFaceColor',params.markercolor,'markeredgecolor','none');
    p.MarkerFaceAlpha = params.markeralpha;

end

end