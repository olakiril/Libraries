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
params.markersize = 1;
params.names = [];
params.angle = 45;
params.sig = 1;
params.error = 'sde';
params.colors = [0.7 0.7 0.72];
params.barwidth =0.9;
params.test = 'anovan';
params.range = 0.75;
params.edgeColors = [];
params.alpha = 0.7;
params.barranges = [25 75;10 90;5 95;1 99;0 100];
params.datacolor = [0.5 0.5 0.5];
params.linecolor = [1 0 0];
params.linewidth = 2;
params.figure = [];
params.gradient = 1./[1 1.8 3.5 8 50];
params.rawback = false;

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
loc = bsxfun(@plus,repmat(linspace(1-params.range/2+ width/2,1+params.range/2- width/2,nCols),nRows,1),(1:nRows)'-1);

if isempty(params.colors)  || size(params.colors,1)<nCols
    params.colors = cbrewer('qual','Pastel1',max([nCols,3]));
end

if isempty(params.edgeColors)
    params.edgeColors = repmat('none',nCols,1);
end

% plot distribution patch
hand = [];
for k = 1:nRows
    for i = 1:nCols
        hold on
        if params.rawback
            plotrawdata;
        end
        sz = size(params.barranges,1);
        a = sort(reshape(arrayfun(@(x) prctile(data{k,i},x),params.barranges),[],1));
        idx = sort([1 repmat(2:sz*2-1,1,2) length(a)]);
        idx = [idx fliplr(idx)];
        spaces =width.*interp1([-params.gradient fliplr(params.gradient)],linspace(1,length(params.gradient)*2,sz*2))/2;
        b =[sort(repmat(2:sz,1,2),'desc') 1 1 sort(repmat(2:sz,1,2),'asce') ...
            sort(repmat(sz+1:sz*2-1,1,2),'asce') sz*2 sz*2  sort(repmat(sz+1:sz*2-1,1,2),'desc')];
        hand(i) = patch(spaces(b)+ loc(k,i),a(idx)',params.colors(i,:),'edgeColor',params.edgeColors(i,:),'facealpha',params.alpha);
        if ~params.rawback
            plotrawdata;
        end
        plot([-width width]/2+ loc(k,i),[values(k,i) values(k,i)],'color',params.colors(i,:)*0.75,'linewidth',params.linewidth)
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
        plot(min(width/2,max(-width/2,normrnd(0,0.2,length(data{k,i}),1)*width)).*offset+ loc(k,i),data{k,i},...
            '.','color',params.datacolor(i,:),'markersize',params.markersize);
        
    end

end
