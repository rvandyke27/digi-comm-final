% 1. create n bit (or byte?) message (bit stream) could be actual packet or
% random
msgLen = 120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message
M = 2;        % Modulation order
k = log2(M);
freqsep = 40000;  % Frequency separation (Hz)
nsamp = 2000;    % Number of samples per symbol
Fs = 80000;      % Sample rate (Hz)
zwaveform = fskmod(message, M,freqsep,nsamp,Fs);

% 2. create modulated signal based on nrz coding 
 %print out chunk of frequency modulated message (waveform)
 
% 3. add preamble, SOF, EOF
 
% 4. sent at high frequency (according to MAC protocol)
%   indicate if there is a collision/succesful transmission of each
%   node/print other steps of MAC protocol process?

% 5. take first received signal
% display chunk of waveform
% 6. demodulate 
% show demodulated chunk?
  
  %find average snr for error free transmission?
  received = awgn(zwaveform, 0);
  bits     = fskdemod(received, M, freqsep, nsamp, Fs);
  
  if(message == bits)
     disp("no errors"); 
 
  
  else
    disp("an error");
    
  end
  
% 7. full show receieved frame