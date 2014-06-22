function uniKeyNum = key2num(key)

% function num = key2num(key)
%
% really bad way of converting a key to a unique number
%
% MF 2010-11-12

% perform some sort of sorting - although this won't guarranty the same
% results...
[sor ind] = sort(fieldnames(key));

% get the data
dat = struct2cell(key);
dat = dat(ind);

% run the loop to detect each subkey
numstr = [];
for ifields = 1:length(fields(key))
    for indx = 1:length(dat{ifields})
        % convert all to strings and put the in one sequence
        if ischar(dat{ifields}(indx))
            numstr = [numstr num2str(str2num(dat{ifields}(indx)))]; %#ok<AGROW,ST2NM>
        else
            numstr = [numstr num2str(dat{ifields}(indx))]; %#ok<AGROW>
        end
    end
end

% convert the big string into a unique number
uniKeyNum = eval(numstr); 
