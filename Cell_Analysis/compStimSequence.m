function compStimSequence(cells,varargin)

params.method = 'sem';
params.normalize = 1;
params.trials = 0;
params.trial = 'all';
for i = 1:size(cells,2)
    params.name{i} = (['Condition' num2str(i)]);
end

params = getParams(params,varargin);

global dataCon
figure

for j = 1:size(cells,2)
    cellIds = cells(:,j);
    data = getData(dataCon,cellIds,'ReverseCorrelation');

    conditions = length( getIndex(data(1),'conditions'));
    binArea = getIndex(data(1),'binArea');
    meanBinArea = mean(binArea(:,5:10),2);
    trials = floor(length(meanBinArea)/conditions);

    matrix = zeros(conditions,trials,length(cellIds));

    for i = 1: length(cellIds)
        binArea = getIndex(data(i),'binArea');
        meanBinArea = mean(binArea(:,5:10),2);

        % select only the valid last trials
        newArea = meanBinArea((length(meanBinArea) - trials*conditions + 1):end);
        reshapedArea = reshape(newArea',conditions,trials);

        % normalize
        if params.normalize
            matrix(:,:,i) = (reshapedArea - min(min(reshapedArea)))/(max(max(reshapedArea))-min(min(reshapedArea)));
            yName = ('Normalized Amplitude');
        else
            matrix(:,:,i)= reshapedArea;
            yName = ('Raw Amplitude');
        end

    end



    if params.trials || ~strcmp(params.trial,'all')
        if strcmp(params.trial,'all')
            subplot(size(cells,2),1,j);
            color = 0:1/conditions:1-1/conditions;
            colors = [color' color' color'];
            for i = 1:conditions
                a = reshape(matrix(i,:,:),size(matrix,2),[]);
                errorPlot(1:trials,a','method',params.method,'color',colors(i,:));
            end
            ylabel(gca,yName)
            xlabel(gca,'trial #')
            set(gca,'box','off');
        elseif strcmp(params.trial,'two')
            colors = hsv(size(cells,2));
            a(:,:) = (matrix(1,:,:) - matrix(end,:,:));
            errorPlot(1:trials,a','method',params.method,'color',colors(j,:));
            hold on
            ylabel(gca,'Amplitude difference from 1st and last condition order')
            xlabel(gca,'trial #')
            AxisPro = axis;
            Yscale = AxisPro(4)-AxisPro(3);
            text(trials-2,(AxisPro(3)+(Yscale*(12-j))/12),num2str(params.name{j}),'Color',colors(j,:));
            set(gca,'box','off');
        else
            colors = hsv(size(cells,2));
            a(:,:) = matrix(params.trial,:,:);
            errorPlot(1:trials,a','method',params.method,'color',colors(j,:));
            hold on
            ylabel(gca,yName)
            xlabel(gca,'trial #')
            AxisPro = axis;
            Yscale = AxisPro(4)-AxisPro(3);
            text(trials-2,(AxisPro(3)+(Yscale*(12-j))/12),num2str(params.name{j}),'Color',colors(j,:));
            set(gca,'box','off');
        end
    else
        colors = hsv(size(cells,2));
        sequence = reshape(mean(matrix,2),size(matrix,1),[])';
        sde = sqrt(var(sequence,1)/size(sequence,1));
        meanResponse = mean(sequence,1);
        errorbar(1:16,meanResponse,sde,'Color',colors(j,:));
        hold on
        ylabel(gca,yName)
        xlabel(gca,'Presentation order of condition')
        AxisPro = axis;
        Yscale = AxisPro(4)-AxisPro(3);
        text(conditions-2,(AxisPro(3)+(Yscale*(12-j))/12),num2str(params.name{j}),'Color',colors(j,:));
        set(gca,'box','off');
    end
end

set(gcf,'Color',[1 1 1])
