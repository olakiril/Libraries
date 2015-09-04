function viewBehavior(VR,fig,avTimes)

global mx
global loc
global av
global line
global times
global play
global htimer

play = false;
mx = av.Duration*av.Framerate;
loc = 1;
av = VR;
times = avTimes;

% plot the data
set(fig,'WindowScrollWheelFcn',@doScroll,'KeyPressFcn',@dispkeyevent);
slider = uicontrol('Parent',fig,'Style','slider','Position',[81,14,819,23],...
    'value',loc, 'min',1, 'max',mx);
set(slider,'Callback',@moveslider)
s = subplot(211);

htimer = timer(...
    'ExecutionMode', 'fixedRate', ...   % Run timer repeatedly
    'Period',0.2, ...                % Initial period is 1 sec.
    'TimerFcn', @update_display); % Specify callback

xloc = times(round(loc));
line = plot([xloc xloc],[0 1],'-.k');

sc = get(s,'children');
set(sc,'buttondownfcn',@timeInput)

updatePlot

end

function moveslider(~,e)

global loc

loc = e.Source.Value;
updatePlot

end

function doScroll(~,e)

global loc
global mx

if  loc<mx && e.VerticalScrollCount>0
    loc = loc + 1;
elseif loc>1 &&  e.VerticalScrollCount<0
    loc = loc - 1;
end

updatePlot

end

function updatePlot

global av
global loc
global line
global slider
global times

set(slider,'value',loc)

xloc = times(round(loc));
subplot(211)
delete(line)
line = plot([xloc xloc],[0 1],'-.r');
title(loc)

subplot(212)
imshow(read(av,loc))

end

function timeInput (~,e)
global loc
global times
coordinates = get (gca, 'CurrentPoint');
xloc = coordinates(1,1);
[~,loc] = min(abs(times-xloc));

updatePlot
end

function dispkeyevent(~, event)

global play
global htimer

if strcmp(event.Key,'space')
    play = ~play;
    if play
        start(htimer)
    else
        stop(htimer)
    end
    
else
    display(['key: "' event.Key '" not assigned!'])
end

end

function update_display(~,e)
% global htimer
global loc
% stop(htimer)
loc = loc+4;
updatePlot
% start(htimer)
end

