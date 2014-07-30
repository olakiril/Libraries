function varargout = fftPlot(trace,fps)

y = trace;
Fs = fps;                    % Sampling frequency
T = 1/Fs;                     % Sample time
L = length(y);                     % Length of signal
t = (0:L-1)*T;                % Time vector

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2);
Y = 2*abs(Y(1:NFFT/2));

if nargout >= 1
    varargout{1} = Y;
    varargout{2} = f;
else
    subplot(121)
    plot(Fs*t,y)
    title('Signal')
    xlabel('time (milliseconds)')
    % Plot single-sided amplitude spectrum.
    subplot(122)
    plot(f,Y)
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
end