function cluster

process = 4;

for i = 1:process
    
    !matlab.exe -nosplash -r clustering(i) &
    
end

