function [stack x y z] = loadAODStack(fn)
% Loads an AOD stack file
% [stack x y z] = loadAODStack(fn)
%
% JC 2010-04-09

dat = loadAODFile(fn);

[foo idx] = sort(cellfun(@length,dat));
dat = dat(idx);

assert(dat{1}(1)==1,'Not a stack file');

settings = double(dat{2});

dx = floor((settings(2)-settings(1))/settings(3));
x = (settings(1):dx:settings(2)-dx)/1460000;

dy = floor((settings(5)-settings(4))/settings(6));
y = (settings(4):dx:settings(5)-dy)/1460000;

dz = floor((settings(8)-settings(7))/settings(9));
z = (settings(7):dz:settings(8)-dz)/700;

if length(dat{1}) >= 2 % more recent format
    numchans = dat{1}(2);
    if numchans == 1
        stack = dat{3};
    else
        stack = [dat{3}'; dat{4}'];
    end
    stack = reshape(stack,[numchans length(x) length(y) length(z) settings(end)]);
else
    if numel(dat{3}) == 2 * prod([length(x) length(y) length(z) settings(end)])
        numchans = 2;
    elseif numel(dat{3}) == prod([length(x) length(y) length(z) settings(end)])
        numchans = 1;
    else
        keyboard
        numchans = 2;
        settings(end) = floor(numel(dat{3}) / prod([numchans length(x) length(y) length(z)]));
        dat{3} = dat{3}(1:prod([numchans length(x) length(y) length(z) settings(end)]));
    end
    stack = reshape(dat{3},[numchans length(x) length(y) length(z) settings(end)]);    
end
    

