function sem = mediansem(s)

sem = [];
for i=1:size(s,2)
  for j=1:size(s,3)
    sem(i,j) = nanstd(bootstrp(1000,@nanmedian,s(:,i,j)));
  end
end





