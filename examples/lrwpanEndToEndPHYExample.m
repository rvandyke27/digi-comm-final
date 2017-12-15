%% End-to-End IEEE 802.15.4 PHY Simulation
% This example shows how to: _(i)_ generate waveforms, _(ii)_ decode
% waveforms and _(iii)_ compute BER curves for different PHY specifications
% from the IEEE 802.15.4 standard [ <#5 1>], using the Communications System 
% Toolbox(TM) Library for the ZigBee(R) Protocol.

% Copyright 2017 The MathWorks, Inc.

%% Background
% The *IEEE 802.15.4* standard specifies the *PHY* and *MAC* layers of Low-Rate
% Wireless Personal Area Networks (*LR-WPANs*) [ <#5 1> ]. The IEEE 802.15.4
% PHY and MAC layers provide the basis of other higher-layer standards,
% such as *ZigBee*, WirelessHart, 6LoWPAN and MiWi. Such standards find
% application in home automation and sensor networking and are highly
% relevant to the Internet of Things (IoT) trend.

%% Physical Layer Implementations of IEEE 802.15.4
% The original IEEE 802.15.4 standard and its amendments specify multiple
% PHY layers, which use different modulation schemes and support different
% data rates. These physical layers were devised for specific frequency
% bands and, to a certain extent, for specific countries. This example
% provides functions that generate and decode waveforms for the physical
% layers proposed in the original IEEE 802.15.4 specification (OQPSK in 2.4
% GHz, BPSK in 868/915 MHz), IEEE 802.15.4b (OQPSK and ASK in 868/915 MHz),
% IEEE 802.15.4c (OQPSK in 780 MHz) and IEEE 802.15.4d (GFSK and BPSK in
% 950 MHz).
%
% These physical layers specify a format for the PHY protocol data unit
% (PPDU) that includes a preamble, a start-of-frame delimiter (SFD), and
% the length and contents of the MAC protocol data unit (MPDU). The
% preamble and SFD are used for frame-level synchronization.
%
% * *OQPSK PHY*: All OQPSK PHYs map every 4 PPDU bits to one symbol. The
% 2.4 GHz OQPSK PHY spreads each symbol to a 32-chip sequence, while the
% other OQPSK PHYs spread it to a 16-chip sequence. Then, the chip
% sequences are OQPSK modulated and passed to a half-sine pulse shaping
% filter (or a normal raised cosine filter, in the 780 MHz band). For a
% detailed description, see Clause 10 in [ <#5 1> ].
%
% * *BPSK PHY*: The BPSK PHY differentially encodes the PPDU bits. Each
% resulting bit is spread to a 15-chip sequence. Then, the chip sequences
% are BPSK modulated and passed to a normal raised cosine filter. For a
% detailed description, see Clause 11 in [ <#5 1> ].
%
% * *ASK PHY*: The ASK PHY uses BPSK modulation for the preamble and the
% SFD only. The remaining PPDU bits are first mapped to 20-bit symbols in
% the 868 MHz band and to 5-bit symbols in the 915 MHz band. Each symbol is
% spread to a 32-chip sequence using a technique known as Parallel Sequence
% Spread Spectrum (PSSS) or Orthogonal Code Division Multiplexing (OCDM).
% The chip sequence is then ASK modulated and passed to a root raised
% cosine filter. For a detailed description, see Clause 12 in [ <#5 1> ].
%
% * *GFSK PHY*: The GFSK PHY first whitens the PPDU bits using modulo-2
% addition with a PN9 sequence. The whitened bits are then GFSK modulated.
% For a detailed description, see Clause 15 in [ <#5 1> ].

%% Waveform Generation, Decoding and BER Curve Calculation
% This code illustrates how to use the waveform generation and
% decoding functions for different frequency bands and compares the
% corresponding BER curves.

EcNo = -25:2.5:17.5;                % Ec/No range of BER curves
spc = 4;                            % samples per chip
msgLen = 8*120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message

% Preallocate vectors to store BER results:
[berOQPSK2450, berOQPSKrest, berBPSK, berASK915, ...
 berASK868, berGFSK] = deal(zeros(1, length(EcNo)));

for idx = 1:length(EcNo) % loop over the EcNo range
  
  % O-QPSK PHY, 2450 MHz  
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '2450 MHz');
  K = 2;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '2450 MHz');
  [~, berOQPSK2450(idx)] = biterr(message, bits);

  % O-QPSK PHY, 780MHz / 868MHz / 915MHz
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '780 MHz'); % or '868 MHz'/'915 MHz'
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '780 MHz'); % or '868 MHz'/'915 MHz'
  [~, berOQPSKrest(idx)] = biterr(message, bits);

  % BPSK PHY, 868/915/950 MHz
  waveform = lrwpan.PHYGeneratorBPSK(message, spc);
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderBPSK(received, spc);
  [~, berBPSK(idx)] = biterr(message, bits);

  % ASK PHY, 915 MHz
  waveform = lrwpan.PHYGeneratorASK(message, spc, '915 MHz');
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderASK(received,  spc, '915 MHz');
  [~, berASK915(idx)] = biterr(message, bits(1:msgLen));

  % ASK PHY, 868 MHz
  waveform = lrwpan.PHYGeneratorASK(message, spc, '868 MHz');
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderASK(received,  spc, '868 MHz');
  [~, berASK868(idx)] = biterr(message, bits(1:msgLen));
 
  % GFSK PHY, 950 MHz
  waveform = lrwpan.PHYGeneratorGFSK(message, spc);
  K = 1;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderGFSK(received, spc);
  [~, berGFSK(idx)] = biterr(message, bits);
end

% plot BER curve
semilogy(EcNo, berOQPSK2450, '-o', EcNo, berOQPSKrest, '-*', EcNo, berBPSK, '-+', ...
         EcNo, berASK915,    '-x', EcNo, berASK868,    '-s', EcNo, berGFSK, '-v')
legend('OQPSK, 2450 MHz', 'OQPSK, 780/868/950 MHz', 'BPSK, 868/915/950 MHz', 'ASK, 915 MHz', ...
       'ASK, 868 MHz', 'GFSK, 950 MHz', 'Location', 'southwest')
title('IEEE 802.15.4 PHY BER Curves')
xlabel('Chip Energy to Noise Spectral Density, Ec/No (dB)')
ylabel('BER')
axis([min(EcNo) max(EcNo) 10^-2 1])
grid on

%% Further Exploration
% You can further explore the following generator and decoding functions:
%
% * <matlab:edit('lrwpan.PHYGeneratorOQPSK') lrwpan.PHYGeneratorOQPSK>,
% <matlab:edit('lrwpan.PHYDecoderOQPSKNoSync') lrwpan.PHYDecoderOQPSKNoSync>
% and <matlab:edit('lrwpan.PHYDecoderOQPSK') lrwpan.PHYDecoderOQPSK>
% * <matlab:edit('lrwpan.PHYGeneratorBPSK') lrwpan.PHYGeneratorBPSK>
% and <matlab:edit('lrwpan.PHYDecoderBPSK') lrwpan.PHYDecoderBPSK>
% * <matlab:edit('lrwpan.PHYGeneratorASK') lrwpan.PHYGeneratorASK>
% and <matlab:edit('lrwpan.PHYDecoderASK') lrwpan.PHYDecoderASK>
% * <matlab:edit('lrwpan.PHYGeneratorGFSK') lrwpan.PHYGeneratorGFSK>
% and <matlab:edit('lrwpan.PHYDecoderGFSK') lrwpan.PHYDecoderGFSK>

%% Selected Bibliography
% # IEEE 802.15.4-2011 - IEEE Standard for Local and metropolitan area
% networks--Part 15.4: Low-Rate Wireless Personal Area Networks (LR-WPANs)


displayEndOfDemoMessage(mfilename)
