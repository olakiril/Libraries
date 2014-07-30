function [imageStack stat] = buildPhaseScrambledImageStack(origImageMatrix,cohValArray,nFrames,varargin)
% function [imageStack stat] = buildPhaseScrambledImageStack(origImageMatrix,cohValArray,nFrames,param1,paramVal1,param2,paramVal2,...)
%-----------------------------------------------------------------------------------------
% BUILDPHASESCRAMBLEDIMAGESTACK - builds an image stack where the phase coherence
% increases from 0 in the first frame to 1 in the last frame.
%
% This function is called by:
% This function calls:
% MAT-files required:
%
% See also:

% Author: Mani Subramaniyan
% Date created: 2009-11-29
% Last revision: 2009-11-29
% Created in Matlab version: 7.5.0.342 (R2007b)
%-----------------------------------------------------------------------------------------

params.cohFunction = 'linear';
params.rootCohFcnOrder = 2;
params.powerCohFcnExponent = 2;
params.randSeedVal = [];
params.randGenerator = 'state';
params.imagePartnerMatrix = [];
params.commonAmpSpec = [];
params.getStat = false;
params.adjustDc = true;
params.dcVal = 127;
params.normalizeSpatialFreq = false;
params.plot = true;

params = parseVarArgs(params,varargin{:});

if nargin<2
    cohValArray = 0;
    nFrames = 1;
end

if ~isempty(params.randSeedVal)
    randn(params.randGenerator,params.randSeedVal);
    rand(params.randGenerator,params.randSeedVal);
end

origImageMatrix = double(origImageMatrix);
fTransf = fftn(origImageMatrix);

origPhaseSpec = angle(fTransf);

if params.normalizeSpatialFreq
    if ~isempty(params.commonAmpSpec)
        ampSpec = params.commonAmpSpec;
    elseif ~isempty(params.imagePartnerMatrix)
        ampSpec = getAvgAmpSpec(origImageMatrix,params.imagePartnerMatrix);
    else
        ampSpec = abs(fTransf);
    end
else
    ampSpec = abs(fTransf);
end


if params.adjustDc
    ampSpec = adjustDcValue(ampSpec,params);
end
% Get the part of the phase spectrum that has phase information to create the entire phase
% spectrum. We choose the left half of the phase spectrum to work on, since the right half can be
% created from the left half.

leftHalfOrig = getLeftHalfSpec(origPhaseSpec);
leftHalfTarget  =  getLeftHalfSpec(angle(fftn(randn(size(origImageMatrix)))));

[nRows nCols] = size(origImageMatrix);
leftHalfTarget = adjustTarget(leftHalfOrig,leftHalfTarget);
params.maxDistToGo = leftHalfTarget - leftHalfOrig;

imageStack = uint8(zeros(nRows,nCols,nFrames));

for iFrame = 1:nFrames
    % Interpolate the phase spectrum
    params.cohVal = cohValArray(iFrame);
    leftHalfNew = interpolatePhaseSpec(leftHalfOrig,params);

    % Create the right half of the phase spectrum to get the full phase spectrum
    fullPhaseSpecNew = getFullPhaseSpec(leftHalfNew,leftHalfOrig,origPhaseSpec);

    % Recreate the image from the modified phase spectrum. We add the param 'symmetric'
    % in ifft because we ensured symmetry in the phase spectum. This gives output that is
    % strictly real.
    imageStack(:,:,iFrame) = ifftn(ampSpec.*exp(1i*fullPhaseSpecNew),'symmetric');  
    
    displayProgress(iFrame,nFrames);
end


if params.getStat
    stat = getStatistics(imageStack,origImageMatrix);
else
    stat = [];
end


function leftHalf = getLeftHalfSpec(origSpec)

% Note that the first row and the first column of the fft output correspond to the
% frequencies along the cardinal axis. In each of horizontal and vertical direction, if
% the number of elements in odd, then, the positive and negative frequencies are equally
% represented (because, after reserving the first component for the cardinal direction,
% you have an even number of elements are remaining and you can use half for positive and
% half for negative frequencies); if even, after reserving the first element for cardinal
% axis, you have an odd number of elements remaining and 1+((N-1)/2) elements are used for
% the positive frequencies(upto fnyq) and the remaining (N-1)/2 elements are used for
% negative frequencies.

[~, nCols] = size(origSpec);
endInd = floor(nCols/2) + 1;
leftHalf = origSpec(:,1:endInd);


function leftHalfNew = interpolatePhaseSpec(leftHalfOrig,params)

currDistToGo = params.maxDistToGo*(1-params.cohVal);
% Now go towards target(completely random spectrum) by 'currDistToGo'
leftHalfNew = leftHalfOrig + currDistToGo;
leftHalfNew = mod(leftHalfNew + pi,2*pi) - pi;

function fullPhaseSpecNew = getFullPhaseSpec(leftHalfNew,leftHalfOrig,origPhaseSpec)

% Deal with phases of the cardinal axis freq and other angle freq separately: the first row of the
% fftn output has the freq components with the horizontal(0deg) orientation and the first
% column contains freq components with vertical(90deg) orientation with the dc component
% as the first element in either case.


% When we do flipud and fliplr operations, if there are odd number of rows or columns, the
% middle elements stay where they are and if there are even number of rows or columns, the
% elements symmetrically get flipped. So no special care is needed for this part.

leftNonCardSpec = leftHalfNew(2:end,2:end);
rightNonCardSpec = rot90(-leftNonCardSpec,2);

[nRows nCols] = size(origPhaseSpec);
if  isOdd(nCols) % if original image has odd number of columns
    fullNonCardSpec = [leftNonCardSpec rightNonCardSpec];
else
    fullNonCardSpec = [leftNonCardSpec rightNonCardSpec(:,2:end)];
end

% Get the phases corresponding to pure horizontal and vertical dir freq components
horiFreq = leftHalfNew(1,2:end);
origVecFullLength = nCols;
horiFreq = createSymmetricVec(horiFreq,origVecFullLength);
    
nReqElem = floor(nRows/2) + 1;
vertFreq = leftHalfNew(2:nReqElem,1);
origVecFullLength = nRows;

% The output of 'createSymmetricVec' is always a row vector.
vertFreq = reshape(createSymmetricVec(vertFreq,origVecFullLength),[],1);

% Keep the dc component unchanged and rebuild the full phase spectrum
dcPhase = leftHalfOrig(1,1);
vertFreq = [dcPhase; vertFreq];

fullPhaseSpecNew = [vertFreq [horiFreq;fullNonCardSpec]];


function symRowVec = createSymmetricVec(nonSymVec,origVecFullLength)
% Takes the first half of the phase vector and creates phase values that would correspond
% to the corresponding negative frequencies.

% We do not know apriori whether the input vector would be a row or column vector. So we
% cast them into a row vector and the calling function will cast it back to its own
% required dimension.
nonSymVec = reshape(nonSymVec,1,[]);

if isOdd(origVecFullLength)
    symRowVec = [nonSymVec fliplr(-nonSymVec)];
else   
    symPart = nonSymVec(1:end-1);
    symRowVec = [symPart nonSymVec(end) fliplr(-symPart)];
end


function x = isOdd(n)
%function x = iOodd(n)
%tells you if a given value is odd or not
x = logical(mod(n,2));


function stat = getStatistics(imageStack,origImageMatrix)

disp('Computing various statistical measures of image frames')
nFrames = size(imageStack,3);
for iFrame = 1:nFrames
    currFrame = double(imageStack(:,:,iFrame));
    pixDist = origImageMatrix - currFrame;
    d = pixDist.^2;
    d = sum(d(:))/numel(origImageMatrix);
    stat.L1(iFrame) = std(currFrame(:));
    stat.L2(iFrame) = d;
    stat.kurtDiff(iFrame) = getKurtosisDiff(currFrame,origImageMatrix);
    stat.kurtosis(iFrame) = kurtosis(currFrame(:));
    xx = abs(pixDist)./origImageMatrix;
    stat.perBidMod(iFrame) = 100*mean(xx(:));
    displayProgress(iFrame,nFrames);
end


function meanAmpSpec = getAvgAmpSpec(origImageMatrix,imagePartnerMatrix)

amp1 = abs(fftn(double(origImageMatrix)));
amp2 = abs(fftn(double(imagePartnerMatrix)));
meanAmpSpec = (amp1 + amp2)/2;


function dk = getKurtosisDiff(currFrame,origImageMatrix)

nTotElem = numel(origImageMatrix);

cf4 = currFrame.^4;
cf4sum = sum(cf4(:));
om4 = origImageMatrix.^4;
om4sum = sum(om4(:));
om2 = origImageMatrix.^2;
om2sum = sum(om2(:));
numerator = abs(cf4sum - om4sum)/nTotElem;
denominator = (om2sum/nTotElem)^2;

dk = numerator/denominator;


function leftHalfTarget = adjustTarget(leftHalfOrig,leftHalfTarget)

% Adjust the target
k = 2*pi;
d = abs(leftHalfTarget-leftHalfOrig);

phaseValCond1 = leftHalfTarget + k;
cond1 = abs(phaseValCond1 - leftHalfOrig) < d;
phaseValCond2 = leftHalfTarget - k;
cond2 = abs(phaseValCond2 - leftHalfOrig) < d;
cond3 = (~cond1 & ~cond2);
leftHalfTarget = cond1.* phaseValCond1 + cond2.*phaseValCond2 + cond3.*leftHalfTarget;


function ampSpec = adjustDcValue(ampSpec,params)

dcVal = abs(ampSpec(1,1))/numel(ampSpec);
scaleFac = params.dcVal/dcVal;
ampSpec = ampSpec * scaleFac;