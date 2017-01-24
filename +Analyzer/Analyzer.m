classdef Analyzer
    
    properties
        key
        run
        reset
        oldFiles
        TrialQueue
        OldTrialQueue
        FrameQueue
        FrameIdxQueue
        usedFilesQueue
        channel
        pixels
        slice
    end
    
    methods
        
        % Fast RF analysis with random square dots
        dotMap(animal_id,session,scan_idx)
        
        % Population orientation tuning
        
        % RF maping with moving bar on intrinsic data
    end
    
    methods
        
        function obj = Analyzer(animal_id,session,scan_idx)
            obj.oldFiles = [];
            obj.key.animal_id = animal_id;
            obj.key.session = session;
            obj.key.scan_idx = scan_idx;
            obj.key.psy_id = max(fetchn(vis.Session & obj.key,'psy_id'));
            obj.key.psy_id = 678;
            obj.TrialQueue = Analyzer.Queue;
            obj.OldTrialQueue = Analyzer.Queue;
            obj.FrameQueue = Analyzer.Queue;
            obj.FrameIdxQueue = Analyzer.Queue;
            obj.usedFilesQueue = Analyzer.Queue;
            obj.run = true;
            obj.reset = false;
            obj.channel=1;
            obj.pixels=false;
            obj.slice = 1;
        end
        
        function [data, trial_key] = getTrialData(obj,start_offset,end_offset)
            
            if nargin<2; start_offset = 0; end
            if nargin<3; end_offset = false; end
            
            % get 2p file 1 at a time
            readTiff(obj);
            
            % get trial
            trial_key = getTrialKey(obj);
            
            % get start stop trial times
            [start, stop, wait] = getTimes(obj,trial_key,start_offset,end_offset);
            
            % get data
            [data, wait] = getData(obj,start,stop,wait);
            
            % if data are not there yet, put trial back into queue and wait
            if wait
                obj.TrialQueue.pushFront(trial_key.trial_idx);
                data = [];
%                 wait(1) % add small delay
            else
                obj.OldTrialQueue.push(trial_key.trial_idx);
            end
        end
        
        function [data, wait] = getData(obj,start,stop,wait)
            global Frames
            if (~isempty(start) && ~isempty(stop)) && ~wait
                times = [Frames.time];
                idx = times >= start &  times <= stop;
                if any(times>=stop) && any(idx)
                    
                    % get frame indexes
                    frame_idxs = cell2mat(obj.FrameIdxQueue.content);
                    idx = find(ismember(frame_idxs,[Frames(idx).frame]));
                    
                    % get data
                    data = obj.FrameQueue.peek(idx); % get data
                    
                    % remove unused data
                    if idx(1)~=1
                        obj.FrameQueue.pop(1:idx(1)-1);
                        obj.FrameIdxQueue.pop(1:idx(1)-1);
                    end
                    
                else % wait for more data
                    wait = true;
                    data = [];
                end
            else % wait
                data = [];
            end
        end
        
        function [start, stop, wait] = getTimes(obj,trial_key,start_offset,end_offset)
            global Trials
            if ~all([Trials.trial]>trial_key.trial_idx)
                idx = [Trials.trial]==trial_key.trial_idx;
                if any(idx)
                    
                    start = Trials(idx).time + start_offset;
                    if end_offset
                        stop =  Trials(idx).time + end_offset;
                        wait = false;
                    else
                        idx2 = [Trials.trial]==obj.TrialQueue.peek;
                        if any(idx2)
                            stop =  Trials(idx2).time;
                        else % wait for next trial to complete
                            start = []; stop = []; wait = true;
                        end
                    end
                else % wait for trial to complete
                    start = []; stop = []; wait = true;
                end
            else  % move on
                start = []; stop = []; wait = false;
            end
        end
        
        function files = getFiles(obj)
            
            % fetch pathds
            [path, filename] = fetch1((experiment.Scan & obj.key)*experiment.Session,'scan_path','filename');
            
            % list files that are not being copied
            dir1 = dir(getLocalPath(sprintf('%s*tif',fullfile(path,filename))));
%             pause(1);
          
            files = [];
            for ifile = 1:length(dir1)
                fname = fullfile(dir1(ifile).folder,dir1(ifile).name);
                dir2 = dir(fname);
                if dir1(ifile).bytes==dir2(1).bytes && ~any(strcmp(fname,obj.usedFilesQueue.content))
                    files{end+1} = fname;
                end
            end
        end
        
        function readTiff(obj)
            files = getFiles(obj);
            if ~isempty(files)
                for ifile = 1 % for now try one at each run
                    reader = ne7.scanimage.Reader5(files{ifile});
                    imdata = squeeze(reader(:,:,obj.channel,obj.slice,:));
                    fstart = reader.header.frameNumbers;
                    for iframe = 1:size(imdata,3) % put frames and frame_idx into queues
                        obj.FrameQueue.push(imdata(:,:,iframe));
                        obj.FrameIdxQueue.push(fstart+iframe-1);
                    end
                    obj.usedFilesQueue.push(files{ifile}); % update the read file list
                end
            end
        end
        
        function trial_key = getTrialKey(obj)
            
            % update trials in queue
            if obj.OldTrialQueue.isempty
                mxTrial = 0;
            else
                mxTrial = max(cell2mat(obj.OldTrialQueue.content));
            end
            trials = fetchn(vis.Trial & obj.key,'trial_idx');
            trials = sort(trials(trials>mxTrial));
            for qtrial = trials'
                obj.TrialQueue.push(qtrial);
            end
            
            % get last trial key
            trial_key = obj.key;
            trial_key.trial_idx = obj.TrialQueue.pop;
            
        end
    end
end

