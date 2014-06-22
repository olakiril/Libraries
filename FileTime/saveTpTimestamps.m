function saveTpTimestamps(directory) 

files = dir([directory '/*p0.h5']);

for i = 1:length(files)
    timestamp = GetFileTime([directory '/' files(i).name]); %#ok<NASGU>
    save([directory '/' files(i).name(1:10)  '_ts'],'timestamp');
end;