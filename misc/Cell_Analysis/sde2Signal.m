function sde2Signal(cells)

global dataCon

fc = getData(dataCon,cells,'RevCorrStats');

areaMatrixMean = getAreaMatrixMean(fc);
standardErr = getStandardErr(fc,'standardErr');

area = reshape(areaMatrixMean,[],1);
err = reshape(standardErr,[],1);

figure
regressPlot(area,err);
xlabel('Response Magnitude');
ylabel('standard Error');