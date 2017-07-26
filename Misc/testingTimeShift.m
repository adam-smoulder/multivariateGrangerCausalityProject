timelength = 5;
fs = 100;
x = 0:1/fs:timelength-0.001;
e1 = wgn(1,length(x),10*log10(0.6)); %noise
e2 = wgn(1,length(x),10*log10(0.5)); 
e3 = wgn(1,length(x),10*log10(0.3)); 
e4 = wgn(1,length(x),10*log10(0.3)); 
e5 = wgn(1,length(x),10*log10(0.6)); 

%y1 = sin(pi*x)+e1;
%y2 = sin(pi*x-0.1);

y1 = e1;
for i = (2+1):1:length(y1)
    y1(i) = y1(i) + 0.95*sqrt(2)*y1(i-1) - 0.9025*y1(i-2);
end

y2 = e2;
for i = (2+1):1:length(y2)
    y2(i) = y2(i) + 0.5*y1(i-2);
end

y3 = e3;
for i = (3+1):1:length(y3)
    y3(i) = y3(i) - 0.4*y1(i-3);
end

y4 = e4;
y5 = e5;
for i = (1+1):1:length(y4)
    if i~=2 
        y4(i) = y4(i) + 0.25*sqrt(2)*y4(i-1) - 0.5*y1(i-2) + 0.25*sqrt(2)*y5(i-1);
        y5(i) = y5(i) - 0.25*sqrt(2)*y4(i-1) + 0.25*sqrt(2)*y5(i-1);
    else
        y5(i) = y5(i) - 0.25*sqrt(2)*y4(i-1) + 0.25*sqrt(2)*y5(i-1);
    end
end

Y1 = fft(y1);
midpoint = length(Y1)/2+1;
Y1 = Y1(1, 1:midpoint-1);
Y2 = fft(y2);
Y2 = Y2(1, 1:midpoint-1);
Y3 = fft(y3);
Y3 = Y3(1, 1:midpoint-1);
Y4 = fft(y4);
Y4 = Y4(1,1:midpoint-1);
Y5 = fft(y5);
Y5 = Y5(1,(1:midpoint-1));

w = fs/2*1/(length(x)/2)*(0:1:length(x)/2-1);

figure(1);
subplot(1,2,1);
plot(w, (abs(Y1)),'LineWidth', 4);
hold on
plot(w, (abs(Y2)),'LineWidth',2);
plot(w, (abs(Y3)), 'LineWidth',1);
plot(w, (abs(Y4)), 'LineWidth',1);
plot(w, (abs(Y5)), 'LineWidth',1);

ylabel('Magnitude');
xlabel('Frequency');
%axis([-4,4,-50,50]);
hold off

subplot(1,2,2);
plot(w, phase(Y1), 'LineWidth', 4);
hold on
plot(w, phase(Y2), 'LineWidth', 2);
plot(w, phase(Y3), 'LineWidth', 1);
plot(w, phase(Y4), 'LineWidth', 1);
plot(w, phase(Y5), 'LineWidth', 1);
xlabel('Frequency');
ylabel('Phase');
legend('Y1','Y2','Y3', 'Y4','Y5');
hold off
