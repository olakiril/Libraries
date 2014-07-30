%%
cd ~/stimulation/
addpath('/Volumes/lab/libraries/matlab')
run('/Volumes/lab/libraries/stimulation/setPath.m')
dat = datestr(date,'yyyy-mm-dd');
dat = '2013-10-23';
alf = dir([dat '*']);
for idir = 1:length(alf)
    display([num2str(idir) '/' num2str(length(alf))])
    name = alf(idir).name;
    movie = dir([name '/MoviesExperiment.mat']);
    if ~isempty(movie)
        files = dir([name '/*.mat']);
        if length(files)*1000 > movie.bytes/2
            load([name '/MoviesExperiment.mat'])
            stim = StimulationData(stim);
            display(['recovering ' name '...'])
            recover(stim);
            clear stim
            display('done!')
        end
    end
end