function moviePlot(trace,fps)
frameSize = 500;
for iFrame = 1:length(trace)- frameSize;
    
    plot(trace(iFrame:iFrame+frameSize))
    drawnow
    pause(1/fps)
end