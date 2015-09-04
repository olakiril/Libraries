function logOUT = juice_for_speed_staircase(varargin)

% function log = juice_for_speed_staircase(varargin)
% 
% Default Parameters:
% params.target_speed = 30;     % mm / s
% params.speed_range = 30;      % mm / s - how close to stick to target speed
% params.juice_frequency = 1;   % juice / s when correct
% params.speed_update_step = 1; % update the speed range in mm/s
% params.path = 'F:\Behavior\'; % saving path
% params.time = 600;            % Experiment run time
% params.juice_dur = 35;        % juice pulse duration (msec)
% 
% Output:
% log.time
% log.speed
% log.dist
% log.touch
% log.speed_range 
% log.params

% set the parameters
params.target_speed = 30;     % mm / s
params.speed_range = 30;      % mm / s - how close to stick to target speed
params.juice_frequency = 1;   % juice / s when correct
params.speed_update_step = 1; % update the speed range in mm/s
params.path = 'F:\Behavior\'; % saving path
params.time = 600;            % Experiment run time
params.juice_dur = 50;        % juice pulse duration (msec)

% update the parameters
for i = 1:2:length(varargin); params.(varargin{i}) = varargin{i+1}; end

% set constant params
speed_range = params.speed_range;
DT = 0.05;
rate_lag = 20;
steps_per_revolution = (360/10) * 4;
mm_per_revolution = 2*pi*70;
position_scale = mm_per_revolution / steps_per_revolution;    % convert the units from board to mm / s
STEPS = round(params.time / DT); % how many 50 ms times samples

% open port
m = MouseBehavior;
m = m.open('COM3');

% initialize
t1 = now;
history_t = zeros(rate_lag, 1); % time history
history_p = zeros(rate_lag, 1); % position history
log.time = nan(STEPS,1);
log.speed = nan(STEPS,1);
log.dist = nan(STEPS,1);
log.touch = nan(STEPS,1);
log.speed_range = nan(STEPS,1);
time_hit_speed = nan;
time_last_juice = nan;

% set all history to initial position so rate starts at 0
[dist, ~] = m.query();
history_p(:) = dist;

% initialize figure
clf;shg;
stop = false;

for i = 1:STEPS
    
    % get the date from the board
    [dist, touch] = m.query();
    
    % update time history
    history_t(1:end-1) = history_t(2:end);
    history_t(end) = (now() - t1) * 24 * 60 * 60;
    
    % update position history
    history_p(1:end-1) = history_p(2:end);
    history_p(end) = dist;
    
    % compute dt
    dt_s = (history_t(end) - history_t(1));
    
    % compute speed
    speed = (history_p(end) - history_p(1)) / (dt_s * length(history_t)) * position_scale;
    
    % update log file
    log.time(i) = history_t(end);
    log.speed(i) = speed;
    log.dist(i) = dist;
    log.touch(i) = touch;
    log.speed_range(i) = speed_range;
    
    % check state
    if abs(speed - params.target_speed) < speed_range
        if isnan(time_hit_speed)
            time_hit_speed = history_t(end);
            time_last_juice = history_t(end);
        end
        
        if (history_t(end) - time_last_juice) > (1 / params.juice_frequency)
            % juice it!
            disp('juice')
            time_last_juice = history_t(end);
            m.juice(params.juice_dur);
            
            % update speed range
            speed_range = speed_range+params.speed_update_step;
        end
    else
        time_hit_speed = nan;
        time_last_juice = nan;
    end
    
    % plot
    if mod(i,10) == 0
        subplot(311);
        plot(log.time(:), log.speed(:));
        xlabel('Time (s)');
        ylabel('Rate (mm/s)');
        ylim([-10,20]);
        
        subplot(312);
        juice = bitand(uint32(log.touch(:)),16) / 16;
        plot(log.time(:), juice);
        xlabel('Time (s)');
        ylabel('Juice')
        
        subplot(313);
        lick = bitand(uint32(log.touch(:)),3);
        plot(log.time(:), lick);
        xlabel('Time (s)');
        ylabel('Lick');
        
        drawnow
    end
    
    % check for keys
    k=get(gcf,'CurrentCharacter');
    if k~='@' % has it changed from the dummy character?
    set(gcf,'CurrentCharacter','@'); % reset the character
    % now process the key as required
    if k=='q', stop=true; end
    end
    
    % stop if commanded
    if stop; disp('Quiting...'); break; end
end

% close connection
m.close();

% save
display('Saving...')
log.params = params;
save([params.path datestr(now,'yy-mm-dd_HH-MM-SS')],'log')

% output
if nargout
    logOUT = log;
end

