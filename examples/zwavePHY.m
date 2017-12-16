%Simulation of Z-wave Physical Layer
%Looking at BER and Energy Consumption?


EcNo = -25:2.5:25;                % Ec/No range of BER curves
spc = 4;                            % samples per chip
msgLen = 8*120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message
M = 32;        % Modulation order
k = log2(M);
freqsep = 16;  % Frequency separation (Hz)
nsamp = 16;    % Number of samples per symbol
Fs = 1024;      % Sample rate (Hz)

berZwave = zeros(1, length(EcNo));

for idx = 1:length(EcNo) % loop over the EcNo range
  % O-QPSK PHY, 2450 MHz  
  zwaveform = fskmod(message, M,freqsep,nsamp,Fs);
  K = 2;      % information bits per symbol
  received = awgn(zwaveform, EcNo(idx)+10*log10(k)-10*log10(nsamp), 'measured',[],'dB');
  bits     = fskdemod(received, M, freqsep, nsamp, Fs);
  [~, berZwave(idx)] = biterr(message, bits);
        
end



% plot BER curve
figure
semilogy(EcNo, berZwave, '-o')
legend('FSK', '2.4GHz')
title('IEEE 802.15.4 PHY BER Curves')
xlabel('Chip Energy to Noise Spectral Density, Ec/No (dB)')
ylabel('BER')
axis([min(EcNo) max(EcNo) 10^-2 1])
grid on
