function str = rnfield(str,old,new)
f = fieldnames(str);
v = struct2cell(str);
f{strmatch(old,f,'exact')} = new;
str = cell2struct(v,f);
