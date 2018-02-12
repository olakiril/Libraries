function h = scalebar(varargin)

params.x_length = 0;
params.y_length = 0;
params.x_pos = 0;
params.y_pos = 0;
params.x_text = '';
params.y_text = '';

params = getParams(params,varargin);

units = get(gca,'units');
set(gca,'units','normalized')
p = get(gca,'position');
xl = (get(gca,'xlim'));
yl = (get(gca,'ylim'));
lx = p(3)/diff(xl) * params.x_length;
ly = p(4)/diff(yl) * params.y_length;
px = p(3)/diff(xl) * (params.x_pos-xl(1));
py = p(4)/diff(yl) * (params.y_pos-yl(1));

if params.x_length>0
    h.xline = annotation('line', ...
    p(1) + px + [0 lx] ,...
    (p(2) + py)*[1 1]);
    h.xtext = text(params.x_pos+params.x_length/2,params.y_pos,params.x_text,...
    'horizontalalignment','center','verticalalignment','top');
end

if params.y_length>0
    h.yline = annotation('line', ...
        (p(1) + px)*[1 1] ,...
        p(2) + py + [0 ly] );
    h.ytext = text(params.x_pos,params.y_pos+params.y_length/2,params.y_text,...
    'horizontalalignment','center','verticalalignment','bottom','rotation',90);
end

set(gca,'units',units)


