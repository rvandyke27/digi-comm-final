function [  ] = physicalLayerSimulation( input_args )
%physicalLayerSimulation runs simulation of physical layer protocols
%   description of input parameters

EcNo = -25:2.5:17.5;                % Ec/No range of BER curves
spc = 4;                            % samples per chip
msgLen = 8*120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message

berOQPSK2450 = zeros(len(EcNo));


for idx = 1:length(EcNo) % loop over the EcNo range
  
  % O-QPSK PHY, 2450 MHz  
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '2450 MHz');
  K = 2;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '2450 MHz');
  [~, berOQPSK2450(idx)] = biterr(message, bits);

end

end

