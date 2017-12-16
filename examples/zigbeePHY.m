%Simulation of Zigbee Physical Layer
%Looking at BER and Energy Consumption?


EcNo = -25:2.5:25;                % Ec/No range of BER curves
spc = 4;                            % samples per chip
msgLen = 8*120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message

berOQPSK2450 = zeros(1, length(EcNo));
berzwave = zeros(1, length(EcNo));

for idx = 1:length(EcNo) % loop over the EcNo range
  % O-QPSK PHY, 2450 MHz  
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '2450 MHz');
  K = 2;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '2450 MHz');
  [~, berOQPSK2450(idx)] = biterr(message, bits);
        
end


% plot BER curve
figure
semilogy(EcNo, berOQPSK2450, '-o')
legend('OQPSK', '2.4GHz')
title('IEEE 802.15.4 PHY BER Curves')
xlabel('Chip Energy to Noise Spectral Density, Ec/No (dB)')
ylabel('BER')
axis([min(EcNo) max(EcNo) 10^-2 1])
grid on
