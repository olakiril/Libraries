function  [dti, oti, po, pdm]= opticalProperties(b)

amplitudes = [b(3) b(5)];
[maxAmp ndx] = max(amplitudes);
[minAmp ndxMin] = min(amplitudes);

pdm =mod(b(2) + pi*(ndx-1), 2*pi);

dti = (vonMises(b, pdm) - vonMises(b, pdm-pi))/(vonMises(b, pdm) + vonMises(b, pdm-pi));

oti = (vonMises(b, pdm) - mean(vonMises(b,[pdm - pi/2, pdm + pi/2]))) / ...
    (vonMises(b, pdm) + mean(vonMises(b,[pdm - pi/2, pdm + pi/2])));

po = mod(pdm, pi);





function y = vonMises(b,x)
y = b(3) * exp(b(1)*(cos((x-(b(2))))-1)) + b(4)' + b(5) * exp(b(1)*(cos((pi+x-(b(2))))-1));
