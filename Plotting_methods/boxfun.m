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
params.markersize = 0.5;
params.names = [];
params.angle = 45;
params.sig = 1;
params.error = 'sde';
params.colors = [];
params.barwidth = 0.5;
params.test = 'anovan';
params.barrange = 0.5;
params.edgeColors = [];
params.alpha = 0.7;
params.range = [25 75;10 90;5 95;1 99;0 100];
params.datacolor = [1 1 1]*0.8;
params.linecolor = [1 0 0];
params.linewidth = 2;
params.figure = [];
params.gradient = exp([1 1.5 2 3 5])/2;
params.rawback = false;

params = getParams(params,varargin);

if isempty(params.figure)
    figure;
else
    figure(params.figure)
end

% data = data';
values = cellfun(@nanmedian,data);

[nRows, nCols] = size(values);

if nCols == 1 || nRows ==1
    loc = 1:length(values);
else
    loc = bsxfun(@plus,repmat(linspace(1-params.barrange/2,1+params.barrange/2,nCols),nRows,1),(1:nRows)'-1);
end

if isempty(params.colors)
    params.colors = cbrewer('qual','Pastel1',max([nCols,3]));
end

if isempty(params.edgeColors)
    params.edgeColors = repmat('none',nCols,1);
end

% plot distribution patch
for k = 1:nRows
    for i = 1:nCols
        
        hold on
        try
        if params.rawback
            offset = invprctile(data{k,i},data{k,i})/100;
            offset = 1 - abs(offset - 0.5)/0.5;
            plot(normrnd(0,0.1,length(data{k,i}),1)*params.barwidth*1.5.*offset+ loc(k,i),data{k,i},'.','color',params.datacolor);
        end
        sz = size(params.range,1);
        a = sort(reshape(arrayfun(@(x) prctile(data{k,i},x),params.range),[],1));
        idx = sort([1 repmat(2:sz*2-1,1,2) length(a)]);
        idx = [idx fliplr(idx)];
        spaces = params.barwidth/2./interp1([-params.gradient fliplr(params.gradient)],linspace(1,length(params.gradient)*2,sz*2));
        b =[sort(repmat(2:sz,1,2),'desc') 1 1 sort(repmat(2:sz,1,2),'asce') ...
            sort(repmat(sz+1:sz*2-1,1,2),'asce') sz*2 sz*2  sort(repmat(sz+1:sz*2-1,1,2),'desc')];
        patch(spaces(b)+ loc(k,i),a(idx)',params.colors(i,:),'edgeColor',params.edgeColors(i,:),'facealpha',params.alpha);
        end
    end
end

% plot raw data and median valus
for i = 1:nCols
    for k = 1:nRows
        hold on
        try
        if ~params.rawback
            offset = invprctile(data{k,i},data{k,i})/100;
            offset = 1 - abs(offset - 0.5)/0.5;
            plot(normrnd(0,0.1,length(data{k,i}),1)*params.barwidth*1.5.*offset+ loc(k,i),data{k,i},'.','color',params.datacolor);
        end
        plot([-params.barwidth/4 params.barwidth/4] + loc(k,i),[values(k,i) values(k,i)],'color',params.colors(i,:)*0.75,'linewidth',params.linewidth)
        end
    end
end

mx = max(reshape(cellfun(@(x) prctile(x,99),data),[],1));
mn = min(reshape(cellfun(@(x) prctile(x,1),data),[],1));
vsp = [mx-mn]*0.05;

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
end

set(gca,'Box','Off');
set(gca,'FontSize',params.fontsize);
if nRows==1
    set(gca,'Xtick',1:nCols)
else
    set(gca,'Xtick',1:nRows)
end
if ~isempty(params.names)
    set(gca,'XTickLabel',params.names)
    ht = xticklabel_rotate([],params.angle,[]);
    set(ht,'HorizontalAlignment','right')
end

hold off

function ast = pval(p)
if p<0.001
    ast = '***';
elseif p<0.01
    ast = '**';
else ast = '*';
end


