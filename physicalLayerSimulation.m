%Simulation of Z-wave Physical Layer
%Looking at BER and Energy Consumption?


EcNo = -25:2.5:25;                % Ec/No range of BER curves
spc = 4;                            % samples per chip
msgLen = 8*120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message
M = 16;        % Modulation order
k = log2(M);
freqsep = 16;  % Frequency separation (Hz)
nsamp = 25;    % Number of samples per symbol
Fs = 1024;      % Sample rate (Hz)

berOQPSK2450 = zeros(1, length(EcNo));
berZwave = zeros(1, length(EcNo));

for idx = 1:length(EcNo) % loop over the EcNo range
  % O-QPSK PHY, 2450 MHz  (for zigbee)
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '2450 MHz');
  K = 2;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '2450 MHz');
  [~, berOQPSK2450(idx)] = biterr(message, bits);
  
  % FSK (for Z-Wave)
  zwaveform = fskmod(message, M,freqsep,nsamp,Fs);
  received = awgn(zwaveform, EcNo(idx)+10*log10(k)-10*log10(nsamp), 'measured',[],'dB');
  %SNR = EcNo(idx) - 10*log10(nsamp) + 10*log10(k);
  %received = awgn(zwaveform, SNR);
  bits     = fskdemod(received, M, freqsep, nsamp, Fs);
  [~, berZwave(idx)] = biterr(message, bits);
        
end

disp(berZwave)

% plot BER curve
figure
semilogy(EcNo, berZwave, '-o', EcNo, berOQPSK2450, '-+')
legend('FSK', 'OQPSK')
title('Z-Wave(FSK) and Zigbee(OQPSK) BER Comparison')
xlabel('Chip Energy to Noise Spectral Density, Ec/No (dB)')
ylabel('BER')
axis([min(EcNo) max(EcNo) 10^-2 1])
grid on
