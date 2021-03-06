function [Data Fs pdData pdFs] = getOpticalData(fn,photodiode)

% function [Data Fs pdData pdFs] = getOpticalData(fn)
%
% Gets the data from the Intrinsic Imager program.
% fn   : filename
% Data : camera data in: [time x y]
% Fs   : Sampling rate
% pdData : photodiode data
% pdFs   : photodiode Sampling rate
%
% If photodiode is true
% Data : photodiode data
% Fs   : photodiode Sampling rate
%
% MF 2012-06
if nargin<2
    photodiode = false;
end

if ~photodiode
    data = single(loadHWS(fn,'imaging','movie')); % get the imaging data
    try
        imsizeX = loadHWS(fn,'imaging','x');
        imsizeY = loadHWS(fn,'imaging','y');
    catch  %#ok<CTCH>
        display('Could not find image size, selecting 512')
        imsizeX = 512;
        imsizeY = 512;
    end
    
    Data = permute(reshape(data,imsizeX,[],imsizeY),[2 3 1]); % reshape into [time x y]
    
    if nargout>1
        Fs = loadHWS(fn,'imaging','hz'); % get framerate
    end
    
    if nargout>2
      pdData = loadHWS(fn,'ephys','photodiode'); % get photodiode data
    end
    
    if nargout>3
      pdFs = loadHWS(fn,'ephys','hz'); % get framerate
    end
    
else
    Data = loadHWS(fn,'ephys','photodiode'); % get photodiode data
    
    if nargout>1
        Fs = loadHWS(fn,'ephys','hz'); % get framerate
    end
end