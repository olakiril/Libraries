%%
m = MouseBehavior;
m = m.open('COM3');
log = 1;
try
juice_dur = 5000;
for i = 1:log
    display(num2str(i))
            m.juice(juice_dur);%msec
            pause(1)
end

m.close();
catch
    m.close();
end