function hout = boxfun(data,varargin)

% function barfun(data,varargin)
%
% Barplots data in groups of rows with errorbars and significance test for
% all the pairs of each group
% Accepts data in:
%
% MF 2012-03

params.thr = 0.05;
params.fontsize = 12;
params.markersize = 10;
params.names = [];
params.angle = 45;
params.sig = 1;
params.error = 'sde';
params.colors = [0.7 0.7 0.72];
params.barwidth =0.9;
params.test = 'kruskalwallis';
params.range = 0.75;
params.edgeColors = [];
params.alpha = 0.8;
params.barranges = [25 75;10 90;5 95;1 99;0 100];
params.datacolor = [0.5 0.5 0.5];
params.linecolor = [1 0 0];
params.linewidth = 2;
params.figure = [];
params.gradient = 1./[1 1.8 3.5 8 50];
params.rawback = false;
params.type = 'stairs';
params.star = false;
params.markeralpha = 0.4;
params.isoutlier = 1;
params.rawrange = 0.6;
params.markercolor = [0.6 0.6 0.6]; 

params = getParams(params,varargin);

if isempty(params.figure)
    figure;
else
    figure(params.figure)
end

% convert data to columns
data = cellfun(@(x) x(:),data,'uni',0);
[nRows, nCols] = size(data);
if nCols == 1 || nRows ==1
    data = reshape(data,length(data),1);
end

values = cellfun(@nanmedian,data);

[nRows, nCols] = size(values);
width = params.range*params.barwidth/nCols;
if nCols>1
    xspace = linspace(1-params.range/2+ width/2,1+params.range/2- width/2, nCols);
else
    xspace = 1;
end
loc = bsxfun(@plus,repmat(xspace,nRows,1),(1:nRows)'-1);

ncolors = nCols;if nCols==1;ncolors=nRows;end
if isempty(params.colors)  || size(params.colors,1)<ncolors
    params.colors = cbrewer('qual','Pastel1',max([ncolors,3]));
end

if isempty(params.edgeColors)
    params.edgeColors = repmat('none',ncolors,1);
end

if isempty(params.datacolor)  || size(params.datacolor,1)<ncolors
    params.datacolor = repmat(params.datacolor,ncolors,1);
end

% plot distribution patch
hand = [];
for k = 1:nRows
    for i = 1:nCols
        hold on
        if nCols==1; icolor=k;else;icolor=i;end
           if params.rawback; plotrawdata; end
        switch params.type
                 
            case 'stairs'
                sz = size(params.barranges,1);
                a = sort(reshape(arrayfun(@(x) prctile(data{k,i},x),params.barranges),[],1));
                idx = sort([1 repmat(2:sz*2-1,1,2) length(a)]);
                idx = [idx fliplr(idx)];
                spaces =width.*interp1([-params.gradient fliplr(params.gradient)],linspace(1,length(params.gradient)*2,sz*2))/2;
                b =[sort(repmat(2:sz,1,2),'desc') 1 1 sort(repmat(2:sz,1,2),'asce') ...
                    sort(repmat(sz+1:sz*2-1,1,2),'asce') sz*2 sz*2  sort(repmat(sz+1:sz*2-1,1,2),'desc')];
                hand(i) = patch(spaces(b)+ loc(k,i),a(idx)',params.colors(icolor,:),'edgeColor',params.edgeColors(icolor,:),'facealpha',params.alpha);
                plot([-width width]/2+ loc(k,i),[values(k,i) values(k,i)],'color',params.colors(icolor,:)*0.75,'linewidth',params.linewidth)

            case 'violin'
                [f, u, bb]=ksdensity(data{k,i});
                f=f/max(f)*width; %normalize
                hand(i)=fill([f(:)+loc(k,i);flipud(loc(k,i)-f(:))],[u(:);flipud(u(:))],params.colors(icolor,:),'FaceAlpha',params.alpha,'EdgeColor','none');
                plot([-width width]/2+ loc(k,i),[values(k,i) values(k,i)],'color',params.colors(icolor,:)*0.75,'linewidth',params.linewidth)
            case 'box'
                qnt = quantile(data{k,i},[0.1 0.25 0.75 0.9]);
                hand(i) = patch([-width width width -width]/2 + loc(k,i),[qnt(2) qnt(2) qnt(3) qnt(3)],...
                    params.colors(icolor,:),'FaceAlpha',params.alpha,'edgecolor','none');
                plot([-width width width -width -width]/2 + loc(k,i),[qnt(2) qnt(2) qnt(3) qnt(3) qnt(2)],'color',[1 1 1]*0.8,'linewidth',0.2)
                plot([1 1]*loc(k,i),[qnt(3) qnt(4)],'--','linewidth',params.linewidth,'color',[1 1 1]*0.5)
                plot([1 1]*loc(k,i),[qnt(1) qnt(2)],'--','linewidth',params.linewidth,'color',[1 1 1]*0.5)
                plot([-width width]/4+ loc(k,i),[qnt(4) qnt(4)],'-','linewidth',params.linewidth,'color',[1 1 1]*0.5)
                plot([-width width]/4+ loc(k,i),[qnt(1) qnt(1)],'-','linewidth',params.linewidth,'color',[1 1 1]*0.5)
                plot([-width width]/2+ loc(k,i),[values(k,i) values(k,i)],'color',params.colors(icolor,:)*0.75,'linewidth',params.linewidth)

%                 
%                 b = boxplot(data{k,i},'positions', repmat(loc(k,i),length(data{k,i}),1),...
%                     'Colors',[params.colors(icolor,:)],'Widths',width,'Symbol','.','OutlierSize',0.000001,'whisker',0.7193);
% %                 set(findobj(gcf,'LineStyle','--'),'LineStyle','-')
%                 set(b(strcmp(get(b,'Tag'),'Upper Whisker')),'linewidth',1.5,'LineStyle','--')
%                 set(b(strcmp(get(b,'Tag'),'Lower Whisker')),'linewidth',1.5,'LineStyle','--')
%                 out_idx = strcmp(get(b,'Tag'),'Outliers');
%                 set(b(out_idx),'marker','o')
%                 
%                 
%                 set(b(1,1), 'YData', [qnt(3) qnt(4)])  
%                 set(b(2,1), 'YData', [ qnt(1) qnt(2)])  
% 
%                 b = b(strcmp(get(b,'Tag'),'Box'));
% 
%                 set(b,'Color','none')
%                 hand(i) = patch(get( b,'xdata'),get( b,'ydata'),params.colors(icolor,:),'FaceAlpha',params.alpha,'edgecolor','none');
%                 plot([-width width]/2+ loc(k,i),[values(k,i) values(k,i)],'color',params.colors(icolor,:)*0.75,'linewidth',params.linewidth)

        end
%         if params.rawback; plotrawdata; end
    end
end

mx = max(reshape(cellfun(@(x) prctile(x,99),data),[],1));
mn = min(reshape(cellfun(@(x) prctile(x,1),data),[],1));
vsp = [mx-mn]*0.05;

% sig spacing
if ~params.star
    sp_update = range(reshape(cellfun(@max,data),[],1))*0.01;
else
    sp_update = range(reshape(cellfun(@max,data),[],1))*0.03;
end
% sp_update =  max(abs((data(:))))*0.01;
if params.sig
    df =  mean(mean(diff(loc')));
    hsp = df*0.1;
    if nCols==1
        data = data';
        loc = loc';
        [nRows, nCols] = size(data);
    end
    
    for iRow = 1:nRows
        mx = max(reshape(cellfun(@(x) prctile(x,98),data(iRow,:)),[],1));
        
        %         [~,seq] = sort(pdist(reshape(loc(iRow,:),[],1)));
        seq = nchoosek(size(loc,2),2):-1:1;
        
        if nCols>2
            %             seq = nchoosek(nCols,2):-1:1;
            idx =squareform(1:length(seq));
            idx(logical(tril(ones(nCols),-1))) = 0;
            [xind, yind]= find(idx);
            [~,sort_idx] = sort(min([xind yind],[],2));
            xind = xind(sort_idx);
            yind = yind(sort_idx);
        else xind = 1;yind =2;
        end
       

        
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
                    'data{iRow,yind(seq(iPair))})'])
                sig = p<params.thr;
            else
                [sig, p] = eval([params.test '(data{iRow,xind(seq(iPair))},' ...
                    'data{iRow,yind(seq(iPair))},params.thr)']);
            end
            
            if iPair >1 && xind(seq(iPair))~=xind(seq(iPair-1))
                sp = sp+sp_update;
            end
            
            if ~isnan(sig) && sig
                x1 = loc(iRow,xind(seq(iPair)));
                x2 = loc(iRow,yind(seq(iPair)));
                
                sp = sp+sp_update;
                plot([x1+hsp x2-hsp],...
                    [mx+sp mx+sp],'k');
                
                if params.star
                    text(mean([x1 x2]),mx+sp,pval(p),...
                        'FontSize',params.fontsize,'HorizontalAlignment',...
                        'center','VerticalAlignment','middle')
                end 
            end
        end
        
        
        
    end
end

set(gca,'Box','Off');
set(gca,'FontSize',params.fontsize);
if nRows==1
    set(gca,'Xtick',1:nCols)
else
    set(gca,'Xtick',1:nRows)
end
if ~isempty(params.names)
    set(gca,'XTickLabel',params.names,'XTickLabelRotation',params.angle)
end

if nargout
    hout = hand;
end
hold off


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
        p = scatter(min(width*params.rawrange/2,max(-width*params.rawrange/2,...
            normrnd(0,0.2,length(data{k,i}),1)*width*params.rawrange))+ loc(k,i),data{k,i},params.markersize,...
            'MarkerFaceColor',params.markercolor,'markeredgecolor','none');
        p.MarkerFaceAlpha = params.markeralpha;
    end

end
