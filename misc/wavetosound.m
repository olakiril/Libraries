%%
Fs = 2000;      % Samples per second
toneFreq = 1000;  % Tone frequency, in Hertz
nSeconds = 2;   % Duration of the sound
y = sin(linspace(0,nSeconds*toneFreq*2*pi,round(nSeconds*Fs)));

sound(y,Fs);  % Play sound at sampling rate Fs

%%
Fs = 2000;
toneFreq = 1000;  % Tone frequency, in Hertz
nSeconds = 3; 
y = sin(linspace(0,nSeconds*toneFreq*2*pi,round(nSeconds*Fs)));
r = sin(1:2:20);
amp = [rand(200,1);r'];
amp = interp1(amp,size(amp,1)/size(y,2):size(amp,1)/size(y,2):size(amp,1));
 
signal = y.*amp;



% Fs = 2000;
% toneFreq = 2000;  % Tone frequency, in Hertz
% nSeconds = 2; 
% y = sin(linspace(0,nSeconds*toneFreq*2*pi,round(nSeconds*Fs)));
% 
% amp = [rand(10,1);r'];
% amp = interp1(amp,size(amp,1)/size(y,2):size(amp,1)/size(y,2):size(amp,1));
%  
% signal(2,:) = y.*amp;

clf
subplot(211)
plot(signal(1,:));
subplot(212)
plot(signal(2,:),'r');
%%
sound(signal,Fs); 
