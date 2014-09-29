% tiff file reader
% handles scan image file which has multiple images in a file
% multiple channels are recorded, and each channel has fixed number of
% slices
% there can be multiple images per slice, but here, only 1 image per slice
% is handled
% chan 1 and chan 2 are image channels, chan 3 is an electrical channel
function [im acqproperties] = readtiff(filename, channel)

header = imfinfo(filename) ;

% setup the state variable from the ImageDescription text
evalstring = header.ImageDescription ;
evalc(evalstring) ;

% acq properties
acqproperties = state.acq ;

% number of channels recorded
numchans = acqproperties.savingChannel1 +...
                acqproperties.savingChannel2 +...
                acqproperties.savingChannel3 +...
                acqproperties.savingChannel4;
            
% number of slices per channel
nslices = acqproperties.numberOfZSlices ;

% image dimensions
height = acqproperties.linesPerFrame;
width  = acqproperties.pixelsPerLine;

% allocate memory for stack
im = zeros(height, width, nslices) ;

% read one slice at a time
for ii=1:nslices
    im(:,:,ii) = imread(filename, 'TIFF', ((ii-1)*numchans)+channel) ;
end ;