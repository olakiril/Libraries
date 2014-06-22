function  progressBar(istep,steps)

% function  progressBar(istep,steps)
%
% Displays a progress bar in a for loop. 
% Updates are split into 100 steps to minimize delay.
%
% istep: current step 
% steps: all the steps of the loop 
%
% MF 2012-03

global pBarH

if  istep == steps(1)
    pBarH = waitbar(0,'Please wait...'); 
    tic
end
lstep = length(steps);
steps = steps([1:round(lstep/100):round(lstep-lstep/100) lstep]);
if sum(istep == steps)
    t = toc;
    rawtime = (1/(istep/steps(end)) - 1)*t;
    timeleft = round(rawtime);
    timelength = 'seconds';
    if length(num2str(timeleft))>2 && length(num2str(timeleft))<5
        timeleft = roundall(timeleft/60,0.1);
        timelength = 'minutes';
    elseif length(num2str(timeleft))== 5
        timeleft = roundall(timeleft/3600,0.1);
        timelength = 'hours';
    elseif length(num2str(timeleft))>5
        timeleft = roundall(timeleft/(3600*24),0.1);
        timelength = 'days';
    end
    waitbar(istep / steps(end),pBarH,['Please wait... ' num2str(timeleft) ...
        ' ' timelength ' (' num2str(istep) '/' num2str(steps(end)) ')'])
end

if istep == steps(end)
    close(pBarH)
    clear pBarH
end