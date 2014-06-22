function  [oti, pdm]= opticalPropertiesONE(b)

ndx = b(3);

pdm = mod(b(2) + pi*(ndx-1),pi);

oti = (vonMises(b, pdm) - vonMises(b,pdm - pi/2)) / ...
    (vonMises(b, pdm) + vonMises(b,pdm - pi/2));



function y = vonMises(b,x)
y = b(3) * exp(b(1)*(cos(2*(x-(b(2))))-1)) + b(4)' ;
