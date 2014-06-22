function [stack x y z stackRed] = loadAODStack(fn)
% [stack x y z stackRed] = loadStack(fn)
%
% JC 2010-07-08

mode = loadHWS(fn,'config','mode');
assert(~isempty(mode), 'Cannot find mode information, invalid AOD scan file');
assert(mode(1) == 1, 'Not a volume scan');

settings = double(loadHWS(fn,'config','volume_settings'));

dx = floor(range(settings(1:2))/settings(3));
dy = floor(range(settings(4:5))/settings(6));
dz = floor(range(settings(7:8))/settings(9));
x = (settings(1) + (1:settings(3))*dx) / 1460000;
y = (settings(4) + (1:settings(6))*dy) / 1460000;
z = (settings(7) + (0:settings(9)-1)*dz) / 600;
rep = settings(10);

dat = loadHWS(fn,'ImData','ImCh1');
stack = reshape(double(dat),[settings(3:3:9)' rep]);
%stack = mean(stack,4);

if nargout>4
    try
        dat = loadHWS(fn,'ImData','ImCh2');
        stackRed = reshape(double(dat),[settings(3:3:9)' rep]);
        %stackRed = mean(stackRed,4);
        
    catch
        stackRed = zeros(size(stack));
    end
end