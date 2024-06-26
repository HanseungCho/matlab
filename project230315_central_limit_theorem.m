clc;
clear;
s= 10;
x0=rand(10^7,1);
for c =1:s-1
    x0=x0+rand(10^7,1);
   
end
x=x0;

x_m=mean(x);
x_std=std(x);
z=(x-x_m)/x_std;
[n,edges]=histcounts(x);
bin_widths =diff(edges);
pdf =n/(10^7)/bin_widths(1);
plot(edges(2:end),pdf)
hold on
sample=normrnd(0,1,[10^7,1]);
[n_1,edges_1]=histcounts(sample);
bin_widths_1=diff(edges_1);
pdf_1=n_1/(10^7)/0.02;
plot(edges_1(2:end),pdf_1)
hold on
x_p=bandpower(z);
sample_p=bandpower(sample);
x_p
sample_p
figure(2)
plot (xcorr(z))
hold on

