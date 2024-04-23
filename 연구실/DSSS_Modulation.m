clc; 
clear;
N_bit=10^2;

M=2;
bits=2*randi([0,1], N_bit,1)-1; %BPSK
Tb=1/(10^5); %bit duration
oversamplingrate=100; %1chip=100samples
fc=8*10^7; %80MHz=8*10^7Hz
PN=comm.PNSequence('Polynomial',[1 0 0 0 1 1 0 1], 'SamplesPerFrame', 100, 'InitialConditions',[0 0 0 0 0 0 1]);
pn=PN();
Processing_Gain=length(pn);
Tc=1/(Tb*Processing_Gain);%chip duration => chip rate=null-to-null bandwidth = 10^7Hz
fs=(1/Tb)*length(pn)*oversamplingrate;%sampling frequency = 10^9Hz

for k=1:length(bits)
    over_bits(length(pn)*(k-1)+1:length(pn)*k)=bits(k);
    spreaded_bits(length(pn)*(k-1)+1:length(pn)*k)=bits(k)*(2*pn-1);
end
oversampled_bits=repelem(over_bits,oversamplingrate);
oversampled_spreaded_bits=repelem(spreaded_bits,oversamplingrate);
ebn0_db=-3:10; 
esn0=zeros(1,14);
sig=zeros(1,14);
bits_for_symbol=1;
for k=1:14
    esn0_db=ebn0_db+10*log10(bits_for_symbol); 
    esn0(k)=10^(esn0_db(k)/10); 
    sig(k)=sqrt(1/(2*esn0(k)));
end
t=linspace(0,(length(bits)*Tb)-(1/fs),length(oversampled_spreaded_bits));
f=linspace(-fs/2,fs/2,length(oversampled_spreaded_bits));
mem0=oversampled_spreaded_bits.*cos(2*pi*fc*t);
Tx=[];
for p=1:length(bits)*length(pn)
    mem=mem0(oversamplingrate*(p-1)+1:oversamplingrate*p);
    E=sum(mem.^2);
    Tx=[Tx mem/sqrt(E)];
end

l=1;
noise=randn(1,length(Tx))*sig(l);
Rx=Tx+noise;
noise_FFT=abs(fftshift(fft(noise)));
FFT=abs(fftshift(fft(Tx)));
figure(1)
subplot(3,1,1)
plot(t, oversampled_bits)
title("Original signal")
xlim([0, 1/(10^5)])
subplot(3,1,2)
plot(t, oversampled_spreaded_bits)
title("Spreaded signal")
xlim([0, 1/(10^5)])
subplot(3,1,3)
plot(t, Tx)
title("Spreaded signal with modulation")
xlim([0, 1/(10^6)])

figure(2)
plot(f, FFT, 'r')
title("FFT of DSSS signal")
figure(3)
plot(f, noise_FFT, 'b')
title("FFT of Noise")
figure(4)
plot(f, FFT, 'r')
hold on
plot(f, noise_FFT, 'b')
hold off
title("FFT of DSSS signal and Noise")
%xlim([7*10^7, 9*10^7]);

figure(5)
input=Rx;
tau=-(length(input)-1):1:length(input)-1; 

p=length(input)+1;
if tau(p) > 0  %right shift
    shifted_input(tau(p)+1:length(input))=input(1:length(input)-tau(p));
    shifted_input(1:tau(p)) = 0;
elseif tau(p) < 0 %left sihft
    shifted_input(1:length(input)+tau(p))=input(-tau(p)+1:length(input));
    shifted_input(length(input)+tau(p)+1:length(input)) = 0;
else %no shift
    shifted_input(:)=input;
end

quadratic=input.*conj(shifted_input); %x(t)x*(t-tau)
caf=fftshift(fft(quadratic));
cf=linspace(-fs/2, fs/2, length(caf));
psd=abs(caf).^2;
plot(cf, psd);
xlabel('x=cylic frequency')
ylabel(sprintf('y=cyclic autocorrelation (tau = %d)', tau(p)*(1/fs)))