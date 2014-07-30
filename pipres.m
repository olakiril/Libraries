function r = pipres(Vm,Va,a,b)

% calculates pipette resistance in GOhms
%
% Vm : the measured voltage (V)
% Va : the applied voltage  (V)
% a  : gain
% b  : headstage gain

r = (Va*a*b*10^6)/(Vm*1000);