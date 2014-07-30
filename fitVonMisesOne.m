function b = fitVonMisesOne(y,x)

% get max. amplitude
[maxAmp,ind] = max(y);

% fit von Mises function
x0 = [0.5 x(ind(1)) maxAmp 0];
options = optimset('MaxFunEvals', 10^25,'Display','off'); % number of iterations
b = lsqcurvefit(@vonMises, x0, x, y, [0 -pi 0 0], [],options);

function y = vonMises(b,x)
    y = b(3) * exp(b(1)*(cos(2*(x-(b(2))))-1)) + b(4)';
