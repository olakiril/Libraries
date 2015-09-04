function time_out = timestamp(times,type)

if nargin<2; 
    type = 'labview'; 
end

if nargin<1; 
    times = now; 
end

% labview timestamp reference, for some reason is off by 5 hours
lt = datenum(1903,12,31,19,0,0); % in miliseconds

if strcmp(type,'labview'); 
   time_out = (times - lt)*24*60*60*1000;
else
   time_out = double(times)/24/60/60/1000+lt;
end