function r = runPopulationAnalysis(S)


%% schneidman-style analysis
N = size(S,2);
pt = binHist(S);  % compute histogram with bayesian smooting

m = binMeanFromHist(pt);   % compute mean from histogram

% inpedendent model
p1 = binHistIndep(m);

% second order model
[theta, p2] = fitIsing(pt',2);
p2 = p2';

% compute entropies
h = binEntropyBias(S);
h1 = binEntropy(p1);
h2 = binEntropy(p2);

% compute strength of higher order correlations
in = h1 - h;    % multi-information
i2 = h1 - h2;   
f = i2/in;

% kullback-leibler divergences

for i=1:10
  S1 = binSamplesFromHist(p1,N);
  S2 = binSamplesFromHist(p2,N);

  kl1(i) = binKLbias(S,S1);
  kl2(i) = binKLbias(S,S2);

  js1(i) = binJSbias(S,S1);
  js2(i) = binJSbias(S,S2);
end
kl1 = mean(kl1);  js1 = mean(js1);
kl2 = mean(kl2);  js2 = mean(js2);


% return
r.kl1 = kl1;       r.kl2 = kl2;
r.js1 = js1;       r.js2 = js2;
r.h = h;          r.h1 = h1;        r.h2 = h2;
r.in = in;        r.i2 = i2;        r.f = f;
r.p = pt;         r.p1 = p1;        r.p2 = p2;
r.theta = theta;




