function plotLaserReport(value,varargin)

params.laser = '2P1';
params.valName = value;

params = getParams(params,varargin);

if params.laser == '2P1'
    directory = 'Y:/2PLaserBackup/at-photon1.neusc.bcm.tmc.edu/';
else
    directory = 'Y:/2PLaserBackup/at-s5no1.neusc.bcm.tmc.edu/';
end

files = dir([directory '*.csv']);
rh = nan(length(files),1);
date = cell(length(files),1);
for ifile = 1:length(files);

    fid = fopen([directory files(ifile).name]);
    dat = [];
    for i = 1:500
        val = textscan(fid,['?' value ',%f\n']);
        if(isempty(val{1}))
            fgetl(fid);
        else
            dat = val{1};
        end
    end
    fclose(fid);

    if isempty(dat)
        dat = nan;
    end
    rh(ifile) = dat;
    date{ifile} = files(ifile).name(1:10);
end

figure
plot(rh);
ylabel(params.valName)
xticklabel_rotate(1:size(date),90,date);
set(gca,'Box','Off')
set(gcf,'Color',[1 1 1])
title(params.laser);