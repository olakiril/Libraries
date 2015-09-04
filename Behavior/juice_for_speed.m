function log = juice_for_speed(target_speed, speed_range, juice_frequency)

rate_lag = 20;
steps_per_revolution = (360/10) * 4;
mm_per_revolution = 2*pi*70;
position_scale = mm_per_revolution / steps_per_revolution;    % convert the units from board to mm / s
juice_dur =35;

DT = 0.05;
TIME = 600;
STEPS = round(TIME / DT); % how many 50 ms times samples

if nargin < 1
    target_speed = 10; % mm / s
end

if nargin < 2
    speed_range = 2;   % mm / s - how close to stick to target speed
end

if nargin < 3
    juice_frequency = 0.5; % juice / s when correct
end

t1 = now;

history_t = zeros(rate_lag, 1); % time history
history_p = zeros(rate_lag, 1); % position history

m = MouseBehavior;
% m = m.open('/dev/cu.usbmodem201321');
m = m.open('COM3');
log = nan(STEPS,4);

% set all history to initial position so rate starts
% at 0
[dist, ~] = m.query();
history_p(:) = dist;

time_hit_speed = nan;
time_last_juice = nan;

for i = 1:size(log,1)
    
    [dist, touch] = m.query();
    
    history_t(1:end-1) = history_t(2:end);
    history_t(end) = (now() - t1) * 24 * 60 * 60;
    
    history_p(1:end-1) = history_p(2:end);
    history_p(end) = dist;
    
    dt_s = (history_t(end) - history_t(1));
    rate = (history_p(end) - history_p(1)) / (dt_s * length(history_t)) * position_scale;
    
    log(i,1) = history_t(end);
    log(i,2) = rate;
    log(i,3) = dist;
    log(i,4) = touch;

    if abs(rate - target_speed) < speed_range
        if isnan(time_hit_speed)
            time_hit_speed = history_t(end);
            time_last_juice = history_t(end);
        end
        
        if (history_t(end) - time_last_juice) > (1 / juice_frequency)
            disp('juice')
            time_last_juice = history_t(end);
            m.juice(juice_dur);
        end
    else
        time_hit_speed = nan;
        time_last_juice = nan;
    end

    if mod(i,10) == 0
        subplot(311);
        plot(log(:,1), log(:,2));
        xlabel('Time (s)');
        ylabel('Rate (mm/s)');
        ylim([-10,20]);
        
        subplot(312);
        juice = bitand(uint32(log(:,4)),16) / 16;
        plot(log(:,1), juice);
        xlabel('Time (s)');
        ylabel('Juice')
        
        subplot(313);
        lick = bitand(uint32(log(:,4)),3);
        plot(log(:,1), lick);
        xlabel('Time (s)');
        ylabel('Lick');

        drawnow
    end
end

m.close();


    