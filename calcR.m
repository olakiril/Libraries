function calcR(oscV,ampV,a,b)
% function calcR(oscV,ampV,a,b)
%
% Calculates the resistance of the pipette
%
% oscV: osciloscope voltage (volts)
% ampV: Step voltage (volts)
% a: alpha gain
% b: beta gain

cur = ampV*a*b*10^9/oscV*10^-6;
display([num2str(cur,3) ' Mohms'])