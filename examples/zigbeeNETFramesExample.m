%% ZigBee NET Frame Generation and Decoding
% This example shows how to use the Communications System Toolbox(TM) Library
% for the ZigBee(R) Protocol to generate and decode NET frames of the ZigBee
% specification [ <#8 1> ].

% Copyright 2017 The MathWorks, Inc.

%% Background
% The ZigBee standard specifies the network (NET or NWK) and application
% (APP) layers for low-rate wireless personal area networks. These NET- and
% APP-layer specifications build upon the PHY and MAC specifications of
% IEEE 802.15.4 [ <#8 2> ]. ZigBee devices find application in home
% automation and sensor networking and are highly relevant to the Internet
% of Things (IoT) trend.

%% Architecture
% A <matlab:edit('zigbee.NETFrameConfig') zigbee.NETFrameConfig>
% configuration object is used both in generating and decoding ZigBee NET
% frames. Such objects describe a NET-layer frame and specify its frame
% type and all applicable properties. The
% <matlab:edit('zigbee.NETFrameGenerator') zigbee.NETFrameGenerator>
% function accepts a zigbee.NETFrameConfig object describing the frame, and
% optionally a NET-layer payload (APP-layer frame) in bytes
% (two-characters), and outputs the NET frame in bytes. The
% <matlab:edit('zigbee.NETFrameDecoder') zigbee.NETFrameDecoder> function
% accepts a NET Protocol Data Unit (NPDU) in bytes and outputs a
% zigbee.NETFrameConfig object describing the frame and possibly a
% NET-layer frame in bytes. Clause 3.3 in [ <#8 1> ] describes the NET
% frame formats.
 

%% Decoding NET Frames of Home Automation ZigBee Radios
% This section decodes NET frames transmitted from a commercial ZigBee
% radio enabling home automation, and captured using a USRP B200-mini radio
% and the
% <matlab:web('http://www.mathworks.com/hardware-support/usrp.html')
% Communications System Toolbox Support Package for USRP(R) radio>.
%
% The <matlab:edit('zigbee.NETFrameDecoder') zigbee.NETFrameDecoder>
% function can decode NET-layer ZigBee data frames and the header of
% net-command frame types.

load zigbeeNETCaptures % netFrame

[netConfig, netPayload] = zigbee.NETFrameDecoder(netFrame);
netConfig %#ok<NOPTS>

%%
% Note that NET-layer decoding indicates that the NET-layer payload is
% encrypted (Security = true). Security can be used either in the network
% or the application layer; this frame uses network-layer security. On the
% one hand, the DataEncryption field is false in the frame and the Message
% Integrity Code (MIC) length is zero, which indicate that security level
% #0 is used and that the payload is not encryped. However, according to
% the ZigBee standard (Clause 4.4.1.2 in [ <#8 1> ]), these two fields are
% *overwritten* with values locally stored during network setup. In this
% case, this frame was secured with security level #5, which means that the
% NET-payload is encrypted and that the MIC length is 32 bits.
%
% <<zigbeeFrameFormat.png>>

%% Generating NET Frames
% The <matlab:edit('zigbee.NETFrameGenerator') zigbee.NETFrameGenerator>
% function can generate unsecure NET-layer ZigBee data frames. The
% configuration object can be further customized.

netConfig = zigbee.NETFrameConfig('SequenceNumber', 123, 'DestinationAddress', 'E568');
numOctets = 50;
payload = dec2hex(randi([0 2^8-1], numOctets, 1), 2);
netFrame = zigbee.NETFrameGenerator(netConfig, payload);

%% Further Exploration
% You can further explore the following generator and decoding functions,
% as well as the configuration object:
%
% * <matlab:edit('zigbee.NETFrameGenerator') zigbee.NETFrameGenerator>
% * <matlab:edit('zigbee.NETFrameDecoder') zigbee.NETFrameDecoder>
% * <matlab:edit('zigbee.NETFrameConfig') zigbee.NETFrameConfig>

%% Selected Bibliography
% # ZigBee Alliance, ZigBee Specification Document 053474r17, 2007
% # IEEE 802.15.4-2011 - IEEE Standard for Local and metropolitan area
% networks--Part 15.4: Low-Rate Wireless Personal Area Networks (LR-WPANs)

displayEndOfDemoMessage(mfilename)
