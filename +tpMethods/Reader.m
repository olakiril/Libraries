classdef Reader < handle
    % scanimage.Reader - ScanImage file interface
    
    properties(SetAccess = protected)
        filepaths
        info     % output of iminfo
        hdr      % header info
        nChans   % number of channels
        nSlices  % number of slices
        width    % in pixels
        height   % in pixels
        lps      % in lines/sec
        fps      % in frames/sec
    end
    
    
    methods
        function self = Reader(filepath)
            % The filepath must specify the full local path to the tiff file or
            % multiple files. Multiple files are generated using sprintf
            % numerical placeholders. For example, '/path/scan001_%03u.tif'
            % will translate into /path/scan001_001.tif,
            % /path/scan001_002.tif, etc
            
            % generate the file list
            self.filepaths = {};
            
            if exist([filepath '.tif'],'file')
                self.filepaths{1} = [filepath '.tif'];
            else
                i = 0;
                while true
                    i = i +1;
                    f = sprintf('%s_%03u.tif', filepath, i);
                    if ismember(f,self.filepaths)
                        break
                    end
                    if ~exist(f, 'file')
                        break
                    end
                    self.filepaths{end+1}=f;
                end
            end
            if isempty(self.filepaths)
                error('file %s not found', filepath)
            end
            
            disp 'reading TIFF header...'
            t = Tiff(self.filepaths{1},'r');
            evalc(t.getTag('ImageDescription'));
            self.hdr = state;
            t.close();
            
            self.nChans = self.hdr.acq.savingChannel1 +...
                self.hdr.acq.savingChannel2 +...
                self.hdr.acq.savingChannel3 +...
                self.hdr.acq.savingChannel4;
            
            self.nSlices = self.hdr.acq.numberOfZSlices;
            self.height = self.hdr.acq.linesPerFrame;
            self.width  = self.hdr.acq.pixelsPerLine;
            self.fps = self.hdr.acq.frameRate;
            self.lps =  self.height * self.fps;
        end
        
        
        function yes = hasChannel(self, iChan)
            yes = ismember(iChan, 1:4) ...
                && self.hdr.acq.(sprintf('savingChannel%u', iChan))==1;
        end
        
        
        function [img, discardedFinalLine] = read(self, iChan, frameInd, removeFlyback)
            %%%%% HERE I AM ONLY HANDLING CASES OF 1 IMAGE PER SLICE %%%%%%
            %             if self.nSlices>1
            %                 frameIdx = 1:self.nSlices;
            %             else% if nargin<3 || isempty(frameInd)
            %                 frmx = round(self.hdr.acq.numberOfFrames/self.hdr.acq.numAvgFramesSave);
            %                 frameIdx = 1:frmx;
            %             end
            %%%% 2014-09-11 self.nSlices is 1 but there are frames so I am handling
            %%%% this case and not the nSlices
            if self.nSlices>1
                frameIdx = 1:self.nSlices;
            else
                frmx = round(self.hdr.acq.numberOfFrames/self.hdr.acq.numAvgFramesSave);
                frameIdx = 1:frmx;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            removeFlyback = nargin<4 || removeFlyback;
            frameNum = (frameIdx(frameIdx)-1)*self.nChans + max(iChan);
            
            t = Tiff(self.filepaths{1},'r');
            frames = ones( t.getTag('ImageLength'), t.getTag('ImageWidth'),length(frameIdx),'uint16');
            t.close();
            
            % read all the frames
            iframe = 1;
            for ifilepath = 1:length(self.filepaths)
                t = Tiff(self.filepaths{ifilepath},'r');
                t.setDirectory(1)
                for i=1:frameNum(end)+self.nChans-iChan;
                    
                    % correct for tiffreader bug when movies are too long
                    if ~mod(i,50000)
                        t.close();
                        t = Tiff(self.filepaths{ifilepath},'r');
                        t.setDirectory(i-1)
                    end
                    
                    try
                        if i~=1; t.nextDirectory();end
                        frames(:,:,iframe) = t.read();
                        iframe = iframe+1;
                    catch
                        break
                    end
                end
                t.close();
            end
            frames(:,:,iframe:end) =[];
            
            % split channels
            img = ones(size(frames,1),size(frames,2),size(frames,3)/self.nChans,length(iChan),'uint16');
            for iCn = 1:length(iChan);
                chan = iChan(iCn);
                assert(self.hasChannel(chan), 'Channel %d was not recorded', chan)
                
                % change iChan to the channel number in the gif file.
                for i=1:chan
                    chan = chan - 1 + self.hasChannel(i);
                end
                
                frameNum = (frameIdx(frameIdx)-1)*self.nChans + chan;
                img(:,:,:,iCn) = frames(:,:,frameNum(frameNum<=size(frames,3)));
            end
            
            % determine if the last line is the flyback line and discard it if so
            discardedFinalLine = false;
            if removeFlyback && ~self.hdr.acq.slowDimDiscardFlybackLine
                if self.hdr.acq.slowDimFlybackFinalLine
                    img = img(1:end-1,:,:,:);
                    discardedFinalLine = true;
                else
                    img = img(2:end,:,:,:);
                end
            end
            
            if nargin>2 && ~isempty(frameInd)
                % get asked frames
                img = img(:,:,frameInd,:);
            end
        end
        
        
        function signal = readPhotodiode(self)
            iChan = 3;  % always assumes channel 3
            assert(self.hasChannel(iChan), ...
                'Channel 3 (photodiode) was not recorded')
            signal = self.read(iChan, [], false);
            signal = squeeze(mean(signal,2));
            signal = reshape(signal, 1, []);
        end
        
        
        function signal = readCh4(self)
            iChan = 4;
            assert(self.hasChannel(iChan), ...
                'Channel 4 was not recorded')
            signal = self.read(iChan, [], false);
            signal = squeeze(mean(signal,2));
            signal = reshape(signal, 1, []);
        end
        
        
        function times = readTimes(self,nFrames)
            if nargin<2
                nFrames = getTiffFrames(self);
            end
            times = (1:nFrames)*1000/self.fps + self.hdr.internal.triggerLabview;
        end
        
        
        function nFrames = getTiffFrames(self)
            t = Tiff(self.filepaths{1},'r');
            listing = dir(t.FileName);
            sz = listing.bytes;
            im = ones(t.getTag('ImageLength'), t.getTag('ImageWidth'),'uint16'); %#ok<NASGU>
            fsz = whos('im');
            istart =  round(max([ sz/(fsz.bytes + 10000) 1]));
            iend =  sz/(fsz.bytes);
            t.setDirectory(istart)
            go = 1;
            while go
                for i=istart:iend;
                    try
                        t.nextDirectory();
                    catch
                        go = 0;
                        break
                    end
                end
                if go
                    iend = istart;
                    istart = max([istart-2000 1]);
                    t.setDirectory(istart)
                else
                    nFrames = i;
                end
            end
            t.close();
            nFrames = nFrames/self.nChans;
        end
        
    end
    
    
    methods(Access = private)
        function [fileNum, frameNum] = getFileNum(self, frameNum)
            for i=1:length(self.filepaths)
                if frameNum <= length(self.info{i})
                    fileNum = i;
                    break
                end
                frameNum = frameNum - length(self.info{i});
            end
        end
        
    end
end