function style = getStyle(what)

% font = 'Arial Unicode MS';
font = 'Helvetica';

% Define styles here
switch what
    case 'figure',   style = {'PaperType','A4','PaperUnits','centimeters'};
    case 'subplot',  style = {'FontName',font,'FontSize',7};
    case 'xlabel',   style = {'FontName',font,'FontSize',7};
    case 'ylabel',   style = {'FontName',font,'FontSize',7};
    case 'title',    style = {'FontName',font,'FontSize',9,'FontWeight','bold'};
    case 'legend',   style = {'FontName',font,'FontSize',7};
    case 'colorbar', style = {'FontName',font,'FontSize',7};
    case 'text',     style = {'FontName',font,'FontSize',7};
    case 'polar',    style = {'FontName',font,'FontSize',7,'TTickSign','+','Border','off'};
    case 'bisector', style = {':k'};
    otherwise, error('Unknown style!')
end
