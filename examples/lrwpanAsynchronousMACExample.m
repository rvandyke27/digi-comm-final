%% IEEE 802.15.4 - Asynchronous CSMA MAC
% This example shows how to simulate the IEEE 802.15.4 asynchronous CSMA
% MAC [ <#8 1> ] using the Communications System Toolbox(TM) for the 
% ZigBee(R) Protocol.

% Copyright 2017 The MathWorks, Inc.

%% Background
% The *IEEE 802.15.4* standard specifies the *MAC* and *PHY* layers of
% Low-Rate Wireless Personal Area Networks (*LR-WPANs*) [ <#8 1> ]. The
% IEEE 802.15.4 MAC and PHY layers provide the basis of other higher-layer
% standards, such as *ZigBee*, WirelessHart, 6LoWPAN and MiWi. Such
% standards find application in home automation and sensor networking and
% are highly relevant to the Internet of Things (IoT) trend.
%
% The IEEE 802.15.4 MAC [ <#8 1> ] specifies two-basic MAC modes: _(i)_
% non-beacon-enabled, and _(ii)_ beacon-enabled MAC. The non-beacon enabled
% MAC is an asynchronous CSMA (Carrier-sense Multiple Access) MAC, which is
% very similar to the IEEE 802.11 MAC. The beacon-enabled MAC allows two
% different MAC periods: _(i)_ a synchronized-CSMA MAC period, and _(ii)_ a
% time-slotted, contention-free MAC period. This example provides an
% extensive simulation of the non-beacon-enabled, asynchronous, CSMA-based
% IEEE 802.15.4 MAC.

%% Network Setup
% An IEEE 802.15.4 PAN (personal area network) is set up by a standard
% process between end devices and PAN coordinators. First, devices that
% would like to join a network perform either active or passive *scanning*.
% Active scanning means that a device first transmits a *Beacon Request* and
% later on it performs passive scanning. Passive scanning means that the
% device sniffs to collect *beacon frames* from PAN coordinators (who may have
% received their Beacon Request in the case of active scanning). Upon the
% collection of beacons during passive scanning, the end device chooses the
% PAN with which it would like to associate. Then it transmits an
% *Association Request* to the coordinator of this PAN and the coordinator
% acknowledges it.
%
% <<networkSetup.png>>
%
% In contrast to IEEE 802.11, the coordinator does not follow the
% *acknowledgement* of an Association Request with an immediate transmission
% of an *Association Response*. Instead, the IEEE 802.15.4 coordinator first
% stores the Association Response locally; it is only transmitted when the
% end device sends a *Data Request* and the coordinator acknowledges it. The
% IEEE 802.15.4 standard uses the term *indirect transmission* to refer to
% this mechanism for transmitting frames. In general, this mechanism is
% very useful for battery-powered devices of low-traffic networks (e.g.,
% sensor networks). Such devices may periodically activate their radios to
% check whether any frames are pending for them, instead of continuously
% using their radios to receive a frame immediately.
%
% Once the Association response is received and acknowledged, the end
% device is associated with the PAN. At that time, *data frames* can be
% exchanged between the coordinator and the end device in any direction.
% The data frames may be acknowledged, depending on their 'Acknowledgement
% Request' indication.

%% Asyncrhonous Medium-Access Control (MAC)
% The asynchronous CSMA IEEE 802.15.4 MAC is similar to the generic CSMA
% operation and the IEEE 802.11 MAC. In this MAC scheme, acknowledgement
% frames are transmitted immediately, without using the CSMA method. All
% other frames are transmitted using CSMA.
%
% Specifically, once a device has a frame to transmit, it randomly chooses
% a *backoff* delay (number of backoff periods) from the range [0 2^BE-1],
% whrere BE is the backoff exponent. The duration of each backoff period is
% 20 symbols. For the OQPSK PHY in 2.4 GHz, this duration corresponds to
% 128 chips and 0.32 ms. Once the device has waited for the chosen number
% of backoff periods, it performs *carrier sensing*. If the medium is idle,
% the device begins transmission of its frame, until it is entirely
% transmitted.
%
% <<asynchronousCSMA.png>>
%
% If the medium is busy during carrier sense, then the backoff exponent
% increments by 1 and a new number of backoff periods is selected from the
% new [0 2^BE-1] range. When the backoff counter expires again, carrier
% sensing is performed. If the maximum number of backoff countdowns is
% reached without the medium being idle during any carrier sensing
% instance, then the device terminates its attempts to transmit the frame.

%% Network Simulation Capabilities
% This example offers an implementation for the described network setup
% process and the CSMA method via the
% <matlab:edit('lrwpan.MACFullFunctionDevice')
% lrwpan.MACFullFunctionDevice> and the
% <matlab:edit('lrwpan.MACReducedFunctionDevice')
% lrwpan.MACReducedFunctionDevice> classes. Specifically, the following
% capabilities are enabled:
%
% * Active and passive scanning
% * Association Request and Association Response exchange
% * Indirect transmissions using Data Requests
% * Frame acknowledgements and frame retransmissions if acknowledgements
% are not timely received
% * Short and long interframe spacing (SIFS and LIFS) 
% 
% * Binary exponential backoff
% * Carrier sensing


%% Network Simulation
% In this section, we create an IEEE 802.15.4 network of 3 nodes: one PAN
% coordinator and two end devices. The network simulator is configured to
% process all devices at increments of a single backoff duration (20
% symbols, 0.32 ms).
%
% First, the following code illustrates the association of the first device
% with the network.

symbolsPerStep = 20;
chipsPerSymbol = 32;
samplesPerChip = 4;
symbolRate = 65.5e3; % symbols/sec
time = 0;
stopTime = 5; % sec

% Create PAN Coordinator
panCoordinator = lrwpan.MACFullFunctionDevice('PANCoordinator', true, 'SamplesPerChip', 4, ....
  'PANIdentifier', '7777', 'ExtendedAddress', [repmat('0', 1, 8) repmat('7', 1, 8)], ...
  'ShortAddress', '1234');

% Create first end-device:
endDevice1 = lrwpan.MACReducedFunctionDevice('SamplesPerChip', 4, ...
  'ShortAddress', '0001', 'ExtendedAddress', [repmat('0', 1, 8) repmat('3', 1, 8)]);

% Initialize device inputs
received1 = zeros(samplesPerChip * chipsPerSymbol * symbolsPerStep/2, 1);
received2 = zeros(samplesPerChip * chipsPerSymbol * symbolsPerStep/2, 1);

while time < stopTime
  % Pass the received signals to the nodes for processing. Also, fetch what
  % they have to transmit:
  transmitted1 = panCoordinator(received1);
  transmitted2 = endDevice1(received2);
  
  % Ideal wireless channel, where both nodes are within range:
  received1 = transmitted2; % half-duplex radios, none receiving while transmitting
  received2 = transmitted1;

  time = time + symbolsPerStep/symbolRate; % update clock
end

%% 
% Once the 1st end device has been associated, data frames are randomly
% injected into the link between the end device and the PAN Coordinator.

%%
% Next, a third device joins the PAN and data frames are subsequently
% exchanged between the coordinator and both end devices, in a star
% topology fashion (end devices must only transmit frames to coordinators).
% In this case, the output is supressed.

% Create second end-device:
endDevice2 = lrwpan.MACReducedFunctionDevice('SamplesPerChip', 4, ...
  'ShortAddress', '0002', 'ExtendedAddress', [repmat('0', 1, 8) repmat('4', 1, 8)], 'Verbosity', false);
% Supress detailed output:
endDevice1.Verbosity = false;
panCoordinator.Verbosity = false;

% Initialize input
received3 = zeros(samplesPerChip * chipsPerSymbol * symbolsPerStep/2, 1);

stopTime = 10; % sec
while time < stopTime
  % Pass the received signals to the nodes for processing. Also, fetch what
  % they have to transmit:
  transmitted1 = panCoordinator(received1);
  transmitted2 = endDevice1(received2);
  transmitted3 = endDevice2(received3);
  
  % Ideal wireless channel, where all nodes are within range:
  received1 = transmitted2 + transmitted3; % half-duplex radios, none receiving while transmitting
  received2 = transmitted1 + transmitted3;
  received3 = transmitted1 + transmitted2;

  time = time + symbolsPerStep/symbolRate; % update clock
end

%%
% More nodes can be added to the network, as long as the channel
% relationship is established accordingly (i.e., the received signals as a
% function of the transmitted signals).

%% Further Exploration
% You can further explore the following generator and decoding functions,
% as well as the configuration object:
%
% * <matlab:edit('lrwpan.MACFullFunctionDevice') lrwpan.MACFullFunctionDevice>
% * <matlab:edit('lrwpan.MACReducedFunctionDevice') lrwpan.MACReducedFunctionDevice>
% * <matlab:edit('lrwpan.MACDevice') lrwpan.MACDevice>

%% Selected Bibliography
% # IEEE 802.15.4-2011 - IEEE Standard for Local and metropolitan area
% networks--Part 15.4: Low-Rate Wireless Personal Area Networks (LR-WPANs)
