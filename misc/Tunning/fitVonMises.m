function b = fitVonMises(y,x)



% compute prefered orientations
% x = orientations / 180*pi;

% get max. amplitude
[maxAmp,ind] = max(y);
% minAmp = min(y);
    
% fit von Mises function
% x0 = [0.5 x(ind(1)) maxAmp-minAmp minAmp maxAmp-minAmp];
x0 = [0.5 x(ind(1)) maxAmp 0 maxAmp];
options = optimset('MaxFunEvals', 10^25,'Display','off'); % number of iterations
b = lsqcurvefit(@vonMises, x0, x, y, [0 -pi 0 0 0], [],options);



function y = vonMises(b,x)
    y = b(3) * exp(b(1)*(cos((x-(b(2))))-1)) + b(4)' + b(5) * exp(b(1)*(cos((pi+x-(b(2))))-1));
