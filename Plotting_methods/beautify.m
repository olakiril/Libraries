function beautify(fig, varargin)

params.x_pos = .1;
params.y_pos = .1;
params.tlength = .008;
params.color = [.1,.1,.1];
params.x_rotation = 45;
params.y_rotation = 45;
params.txt_offset = .02;
params.xaxis = 1;

params = getParams(params, varargin);

set(0, 'CurrentFigure', fig)
ch = get(fig,'Children');

for ax = ch(:)'
    axes(ax)
    xticks = get(ax,'xtick');
    xticklabels = get(ax,'XTickLabel');
    xl = ax.XLim;
    
    yticks = get(ax,'ytick');
    yticklabels = get(ax,'YTickLabel');
    yl = ax.YLim;
    
    xlb = ax.XLabel;
    ylb = ax.YLabel;
    
    x_vis = ax.XAxis.Visible;
    y_vis = ax.YAxis.Visible;
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    
    xp = yticks(1) - diff(yl)*params.x_pos;
    if (xticks(1) - diff(xl)*params.y_pos) > xl(1)
        yp = xl(1);
    else
        yp = xticks(1) - diff(xl)*params.y_pos;
    end
    
    
    hold on
    
    % plot X axis stuff
    xlim([yp, xl(2)]); ylim([xp, yl(2)])
    if params.xaxis && x_vis
        plot([xticks(1), xticks(end)],[1,1]*xp,'color',params.color)
        for xt = 1:length(xticks)
            plot([1,1]*xticks(xt),[xp,xp+diff(yl)*params.tlength],'color',params.color);
        end
    end
    if x_vis
        for xt = 1:length(xticklabels)
            text( xticks(xt),xp - diff(yl)*params.txt_offset,xticklabels{xt},...
                'HorizontalAlignment','right',...
                'VerticalAlignment','middle','Rotation',params.x_rotation)
        end
    end
    
    % plot Y axis stuff
    if y_vis
        plot([1,1]*yp,[yticks(1), yticks(end)],'color',params.color)
        for yt = 1:length(yticks)
            plot([yp,yp+diff(xl)*params.tlength],[1,1]*yticks(yt),'color',params.color);
            text(yp - diff(xl)*params.txt_offset, yticks(yt),yticklabels{yt},...
                'HorizontalAlignment','right','Rotation',params.y_rotation)
        end
    end

    text(xlb.Position(1),xlb.Position(2)+(yl(1) - xp),xlb.String,'HorizontalAlignment','center',...
        'VerticalAlignment','top','fontsize',xlb.FontSize)
    text(ylb.Position(1)+(xl(1) - yp),ylb.Position(2),ylb.String,'rotation',90,...
        'HorizontalAlignment','center','VerticalAlignment','bottom',...
        'fontsize',xlb.FontSize)
end

% set figure color
set(fig,'color',[1,1,1])