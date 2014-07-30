function clustering(i)

process = 4;
conect;
day = '090723_001';
fun = @(e) strcmp(getMetaData(e,'mouseId'),day);
mouseId = filterElementByFun(sessMan,'Subject',fun);
cells = filterElementByType(sessMan,'Cell',mouseId);

celnum = length(cells);
celclust = round(celnum/process);
start = 1 + ((1:process)-1)*celclust;
finish = [celclust*(1:process-1) celnum];

getData(dataCon,cells(start(i):finish(i)),'ReverseCorrelation')
getData(dataCon,cells(start(i):finish(i)),'RevCorrStats')

quit
