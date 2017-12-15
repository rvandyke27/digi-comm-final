%% IEEE 802.15.4 - MAC Frame Generation and Decoding
% This example shows how to generate and decode MAC frames of the IEEE
% 802.15.4 standard [ <#8 1> ] using the Communications System Toolbox(TM) 
% Library for the ZigBee(R) Protocol.

% Copyright 2017 The MathWorks, Inc.

%% Background
% The *IEEE 802.15.4* standard specifies the *MAC* and *PHY* layers of
% Low-Rate Wireless Personal Area Networks (*LR-WPANs*) [ <#8 1> ]. The
% IEEE 802.15.4 MAC and PHY layers provide the basis of other higher-layer
% standards, such as *ZigBee*, WirelessHart, 6LoWPAN and MiWi. Such
% standards find application in home automation and sensor networking and
% are highly relevant to the Internet of Things (IoT) trend.

%% Architecture
% The IEEE 802.15.4 MAC layer inserts a MAC header and a MAC footer before
% and after a network-layer frame, respectively. The MAC footer contains a
% CRC check.
%
% <<zigbeeFrameFormat.png>>
%
% A <matlab:edit('lrwpan.MACFrameConfig') lrwpan.MACFrameConfig>
% configuration object is used both in generating and decoding IEEE
% 802.15.4 MAC frames. Such objects describe a MAC frame and specify its
% frame type and all applicable properties. The
% <matlab:edit('lrwpan.MACFrameGenerator') lrwpan.MACFrameGenerator>
% function accepts a lrwpan.MACFrameConfig object describing the frame, and
% optionally a MAC-layer payload (NET-layer frame) in bytes
% (two-characters), and outputs the MAC frame in bits. The
% <matlab:edit('lrwpan.MACFrameDecoder') lrwpan.MACFrameDecoder> function
% accepts a MAC Protocol Data Unit (MPDU) in bits and outputs a
% lrwpan.MACFrameConfig object describing the frame and possibly a
% NET-layer frame in bytes. Clause 5 in [ <#8 1> ] describes the MAC frame
% formats.

%% Decoding MAC Frames of Home Automation ZigBee Radios
% This section decodes MAC frames transmitted from commercial ZigBee
% radios enabling home automation, and captured using a USRP B200-mini radio
% and the
% <matlab:web('http://www.mathworks.com/hardware-support/usrp.html')
% Communications System Toolbox Support Package for USRP(R) radio>.

load lrwpanMACCaptures

%% 
% First, a data frame is decoded:
[dataFrameMACConfig, netFrame] = lrwpan.MACFrameDecoder(MPDU_data);
if ~isempty(dataFrameMACConfig)
  fprintf('CRC check passed for the MAC frame.\n');
  dataFrameMACConfig %#ok<NOPTS>
end

%% 
% Next, an acknowledgement frame is decoded:
ackFrameMACConfig = lrwpan.MACFrameDecoder(MPDU_ack) %#ok<NOPTS>


%% Generating MAC Frames
% The <matlab:edit('lrwpan.MACFrameGenerator') lrwpan.MACFrameGenerator>
% function can generate all MAC frame types from the IEEE 802.15.4 standard
% [ <#8 1> ], i.e., 'Beacon', 'Data', 'Acknowledgement', and 'MAC Command'
% frame types. The MAC Command frame types can be further specified as:
% 'Association request', 'Association response', 'Disassociation
% notification', 'Data request', 'PAN ID conflict notification', 'Orphan
% notification', 'Beacon request', and 'GTS request'.
%
% This code illustrates how to generate frames for all frame types:

% Beacon
beaconConfig = lrwpan.MACFrameConfig('FrameType', 'Beacon');
beaconMACFrame = lrwpan.MACFrameGenerator(beaconConfig);

% Data
dataConfig = lrwpan.MACFrameConfig('FrameType', 'Data');
numOctets = 50;
payload = dec2hex(randi([0 2^8-1], numOctets, 1), 2);
dataMACFrame = lrwpan.MACFrameGenerator(dataConfig, payload);

% Acknowledgment
ackConfig = lrwpan.MACFrameConfig('FrameType', 'Acknowledgment');
ackFrame = lrwpan.MACFrameGenerator(ackConfig);

% MAC Command
commandConfig = lrwpan.MACFrameConfig('FrameType', 'MAC Command');
commandConfig.MACCommand = 'Association request';
% Valid settings for MACCommand also include: 'Association response',
% 'Disassociation notification', 'Data request', 'PAN ID conflict
% notification', 'Orphan notification', 'Beacon request', and 'GTS request'.
commandFrame = lrwpan.MACFrameGenerator(commandConfig);

%% Further Exploration
% You can further explore the following generator and decoding functions,
% as well as the configuration object:
%
% * <matlab:edit('lrwpan.MACFrameGenerator') lrwpan.MACFrameGenerator>
% * <matlab:edit('lrwpan.MACFrameDecoder') lrwpan.MACFrameDecoder>
% * <matlab:edit('lrwpan.MACFrameConfig') lrwpan.MACFrameConfig>

%% Selected Bibliography
% # IEEE 802.15.4-2011 - IEEE Standard for Local and metropolitan area
% networks--Part 15.4: Low-Rate Wireless Personal Area Networks (LR-WPANs)

displayEndOfDemoMessage(mfilename)
