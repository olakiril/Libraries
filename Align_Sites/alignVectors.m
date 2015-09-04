function [outdx, outgain] = alignVectors(X,Y,varargin)

global data1
global data2
global dx
global step
global xstep
global go
global yl
global dy
global gain
global params

params.testingmode = [];
params.xstep = 2000;
params.step = 5;
params.ylim = [0 3];
params.marker = '-';
params.dx = X(1)-Y(1);
params.gain = 0;
params = getParams(params,varargin);


% set initial parameters
step = params.step;
xstep = params.xstep;
yl = params.ylim;
data1 = X;
data2 = Y;
dx = params.dx;
dy = 0;
go = false;
gain = params.gain;

% plot the data
% gain function
gainfix = @(x,gn)  (x-x(1))*(1 + gn/100) + x(1);


h = figure('NumberTitle','off',...
    'Name','align Images',...
    'KeyPressFcn',@dispkeyevent);
p = get(h,'position');
set(h,'position',[p(1)-p(3)/2,p(2),p(3)*2,p(4)])
hold on;
plot(data1(:,1),data1(:,2),params.marker);
plot(gainfix(data2+dx,gain),0.95*ones(length(data2),1)+dy,'.','Color',[1 0 0])
ylim([0 3])
xl = get(gca,'xlim');
xl = [data2(1)+dx-diff(xl) data2(1)+dx+diff(xl)];
xlim(xl)
display('Align the data')

% wait until the alignment is done
while ~go && ishandle(h)
    figure(h)
    pause(0.2)
end

outdx = dx;
outgain = gain;

function dispkeyevent(~, event)

global data1
global data2
global dx
global go
global step
global xstep
global yl
global dy
global params
global gain

% gain function
gainfix = @(x,gn)  (x-x(1))*(1 + gn/100) + x(1);

xl = get(gca,'xlim');
if strcmp(event.Key,'downarrow')
    xl = [mean(xl)-diff(xl)*2/2 mean(xl)+diff(xl)*2/2];
elseif strcmp(event.Key,'uparrow')
    xl = [mean(xl)-diff(xl)*0.5/2 mean(xl)+diff(xl)*0.5/2];
elseif strcmp(event.Key,'leftarrow')
    xl = xl-xstep;
elseif strcmp(event.Key,'rightarrow')
    xl = xl+xstep;
elseif strcmp(event.Key,'equal') || strcmp(event.Key,'equal')
    dx = dx+step;
elseif strcmp(event.Key,'hyphen') || strcmp(event.Key,'hyphen')
    dx = dx-step;
elseif strcmp(event.Key,'rightbracket')
    dx = dx+step*500;
    xl = xl+step*500;
elseif strcmp(event.Key,'leftbracket')
    dx = dx-step*500;
      xl = xl-step*500;
elseif strcmp(event.Key,'slash')
    dx = dx+step*2500;
    xl = xl+step*2500;
elseif strcmp(event.Key,'period')
    dx = dx-step*2500;
      xl = xl-step*2500;
elseif strcmp(event.Key,'0') 
    gain = gain+0.0005;
elseif strcmp(event.Key,'9') 
    gain = gain-0.0005;
elseif strcmp(event.Key,'o') 
    gain = gain-0.0001;
elseif strcmp(event.Key,'p') 
    gain = gain+0.0001;
elseif strcmp(event.Key,'quote')
    dx = dx+step*.2;
elseif strcmp(event.Key,'semicolon')
    dx = dx-step*.2;
elseif strcmp(event.Key,'return')
    go = true;
elseif strcmp(event.Key,'pageup') || strcmp(event.Key,'rightbracket')
    dy = dy+0.02;
elseif strcmp(event.Key,'pagedown') || strcmp(event.Key,'leftbracket')
    dy = dy-0.02;
elseif strcmp(event.Key,'home')
    xl = [data1(1)-diff(xl)/2 data1(1)+diff(xl)/2];
elseif strcmp(event.Key,'end')
    xl = [data2(end)+dx-(diff(xl)/2) data2(end)+dx+(diff(xl)/2)];
end

if go
    close(gcf)
else
    clf
    hold on;
    plot(data1(:,1),data1(:,2),params.marker);
    plot(gainfix(data2+dx,gain),0.95*ones(length(data2),1)+dy,'.','Color',[1 0 0])
    ylim(yl)
    xlim(xl)
end