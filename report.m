function report(txt)

global old_txt

if nargin<1
    old_txt = '';
    fprintf('\n')
    return
end

fprintf(repmat('\b',1,length(old_txt)));
fprintf('%s',txt);
old_txt = txt;