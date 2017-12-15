%% ZigBee APP Frame Generation and Decoding for Home Automation
% This example shows how to generate and decode Application-layer frames
% for the Home Automation application profile [ <#11 1> ] of the ZigBee
% specification [ <#11 2> ] using the Communications System Toolbox(TM) 
% Library for the ZigBee(R) Protocol.

% Copyright 2017 The MathWorks, Inc.

%% Background
% The ZigBee standard [ <#11 2> ] specifies the network (NET or NWK) and
% application (APP) layers for low-rate wireless personal area networks.
% These NET- and APP-layer specifications build upon the PHY and MAC
% specifications of IEEE 802.15.4 [ <#11 3> ]. ZigBee devices find
% application in home automation and sensor networking and are highly
% relevant to the Internet of Things (IoT) trend.
%
% The application layer consists of multiple sub-layers: _(i)_ the
% Application Support Sublayer (APS), and _(ii)_ the ZigBee Cluster Library
% (ZCL). The APS sublayer follows a format that is common for all
% application profiles and ZigBee clusters (see Clause 2.2.5 in [ <#11 2>
% ]). The ZCL *header* follows a format that is common for all clusters
% (see Clause 2.4 in [ <#11 4> ]). The ZCL *payload* is used only by some
% clusters and it follows a cluster-specific format.
%
% <<zigbeeFrameFormat.png>>
%
%% Clusters and Frame Captures
% Out of all the clusters used in the Home Automation application profile,
% this example decodes and generates frames for: _(i)_ the On/Off cluster
% (used by light devices), and _(ii)_ the Intruder Alarm System (IAS) Zone
% cluster (used by motion sensors) [ <#11 4> ]. The On/Off cluster does not
% make use of a ZCL payload, but the IAS Zone cluster does.
%
% Frames of these clusters have been captured from commercial ZigBee radios
% enabling home automation, using a USRP B200-mini radio and the
% <matlab:web('http://www.mathworks.com/hardware-support/usrp.html')
% Communications System Toolbox Support Package for USRP(R) radio>. ZigBee
% can employ security either at the network or the application layer. The
% captured frames employed security at the network layer and were later on
% decrypted. This example decodes the application layer of the decrypted NET-layer payloads.

load zigbeeAPPCaptures

%% Decoding APS Frames of Home Automation ZigBee Radios
% A <matlab:edit('zigbee.APSFrameConfig') zigbee.APSFrameConfig>
% configuration object is used both in generating and decoding ZigBee APS
% frames. Such objects describe a APS-layer frame and specify its frame
% type and all applicable properties. The
% <matlab:edit('zigbee.APSFrameDecoder') zigbee.APSFrameDecoder> function
% accepts a APS Protocol Data Unit (APDU) in bytes and outputs a
% zigbee.APSFrameConfig object describing the frame and possibly a ZCL
% frame in bytes. Clause 2.2.5.1 in [ <#11 2> ] describes the APS frame
% formats.
%
% Next, the APS sublayer of a captured IAS Zone frame is decoded:

[apsConfig, apsPayload] = zigbee.APSFrameDecoder(motionDetectedFrame);
apsConfig

%% Decoding ZCL Header of Home Automation ZigBee Radios
% A <matlab:edit('zigbee.ZCLFrameConfig') zigbee.ZCLFrameConfig>
% configuration object is used both in generating and decoding ZigBee ZCL
% headers. Such objects describe a ZCL-layer frame and specify its frame
% type and all applicable properties.
% 
% The <matlab:edit('zigbee.ZCLFrameDecoder') zigbee.ZCLFrameDecoder>
% function accepts a ZCL frame in bytes and outputs a zigbee.ZCLFrameConfig
% object describing the header and possibly a ZCL payload in bytes. Clause
% 2.4.1 in [ <#11 4> ] describes the ZCL header frame formats. Note that the
% ZCL header may either specify a 'Profile-wide' or a 'Cluster-specific'
% command type. In the latter case, the zigbee.ZCLFrameDecoder also needs
% the cluster ID, which is present in the APS header, in order to decode
% the cluster-specific command ID into a command type. For example, the
% next command decodes the ZCL header of a captured IAS Zone frame.

[zclConfig, zclPayload] = zigbee.ZCLFrameDecoder(apsPayload, apsConfig.ClusterID);
zclConfig %#ok<*NOPTS>

%% Decoding ZCL Payload of IAS Zone Frame from ZigBee Radio
% In contrast to the On/Off cluster, the IAS Zone Cluster specifies a ZCL
% payload in addition to the ZCL header. A
% <matlab:edit('zigbee.IASZoneFrameConfig') zigbee.IASZoneFrameConfig>
% configuration object is used both in generating and decoding IAS Zone ZCL
% payloads. Such objects describe an IAS Zone payload and all applicable
% properties. The <matlab:edit('zigbee.IASZoneFrameDecoder')
% zigbee.IASZoneFrameDecoder> function accepts an IAS Zone payload in bytes
% and outputs a zigbee.IASZoneFrameConfig object describing the IAZ Zone
% payload.

iasZoneConfig = zigbee.IASZoneFrameDecoder(zclPayload)

%% Decoding Motion-Triggered Lighting Automation of ZigBee Radios
% A lighting automation has been established for the commercial
% home-automation ZigBee radios whose frames have been captured and
% decoded. Specifically, once a motion sensor detects motion, it sends a
% signal to the ZigBee hub, which in turn sends a signal to a light bulb so
% that it turns on. When the motion sensor detects that the motion has
% stopped (e.g., after 10 seconds without motion) it sends a signal to the
% ZigBee hub, which in turn wirelessly triggers the light bulb to turn off.
% The following video illustrates the lighting automation.

helperPlaybackVideo('LightingAutomation.mov', 2/5);

%%
% The following code decodes the actual frames transmitted between the
% ZigBee radios. These were captured with a USRP device (also shown in the video).

apsFrames = {motionDetectedFrame; turnOnFrame; motionStoppedFrame; turnOffFrame};
for idx = 1:length(apsFrames)
  % APS decoding:
  [apsConfig, apsPayload] = zigbee.APSFrameDecoder(apsFrames{idx});
  % ZCL header decoding:
  [zclConfig, zclPayload] = zigbee.ZCLFrameDecoder(apsPayload, apsConfig.ClusterID);
  zclConfig
  
  % On-off cluster (does not have ZCL payload)
  onOffClusterID = '0006';
  if isequal(apsConfig.ClusterID, onOffClusterID)
    fprintf(['Turn light bulb ' lower(zclConfig.CommandType) '.\n']);
  end
    
  % Intruder Alaram System (IAS) Zone cluster has ZCL payload:
  iasZoneClusterID = '0500';
  if ~isempty(zclPayload) && isequal(apsConfig.ClusterID, iasZoneClusterID)
    iasConfig = zigbee.IASZoneFrameDecoder(zclPayload) 
    
    if any(strcmp('Alarmed', {iasConfig.Alarm1, iasConfig.Alarm2}))
      fprintf('Motion detected.\n');
    else
      fprintf('Motion stopped.\n');
    end
  end
end

%% Generating IAS Zone ZCL Payloads
% The <matlab:edit('zigbee.IASZoneFrameGenerator')
% zigbee.IASZoneFrameGenerator> function accepts a
% zigbee.IASZoneFrameConfig object describing the IAS Zone payload and
% outputs the payload in bytes. The following code creates two ZCL payloads for
% this cluster indicating that intrusion has or has not been detected.

iasConfigIntrusion = zigbee.IASZoneFrameConfig('Alarm2', 'Alarmed');
zclPayloadIntrusion = zigbee.IASZoneFrameGenerator(iasConfigIntrusion);

iasConfigNoIntrusion = zigbee.IASZoneFrameConfig('Alarm2', 'Not alarmed');
zclPayloadNoIntrusion = zigbee.IASZoneFrameGenerator(iasConfigNoIntrusion);

%% Generating ZCL Frames
% The <matlab:edit('zigbee.ZCLFrameGenerator') zigbee.ZCLFrameGenerator>
% function accepts a zigbee.ZCLFrameConfig object describing the frame, and
% optionally a ZCL payload in bytes (two-characters), and outputs the ZCL
% frame in bytes. The following code generates ZCL frames for the On/Off
% cluster (no payload) and the IAS Zone cluster (payload needed).

% IAS Zone Cluster
zclConfigIntrusion = zigbee.ZCLFrameConfig('FrameType', 'Cluster-specific', ...
                                           'CommandType', 'Zone Status Change Notification', ...
                                           'SequenceNumber', 1, 'Direction', 'Downlink');
zclFrameIntrusion = zigbee.ZCLFrameGenerator(zclConfigIntrusion, zclPayloadIntrusion);

% On/Off Cluster
zclConfigOn = zigbee.ZCLFrameConfig('FrameType', 'Cluster-specific', ...
                                    'CommandType', 'On', ...
                                    'SequenceNumber', 2, 'Direction', 'Uplink');
zclFrameOn = zigbee.ZCLFrameGenerator(zclConfigOn);

%% Generating APS Frames
% The <matlab:edit('zigbee.APSFrameGenerator') zigbee.APSFrameGenerator>
% function accepts a zigbee.APSFrameConfig object describing the frame, and
% optionally a APS payload (ZCL-layer frame) in bytes (two-characters), and
% outputs the APS frame in bytes. The following code illustrates how to
% generate APS frames for the ZCL frames created in the previous section.

% IAS Zone Cluster
apsConfigIntrusion = zigbee.APSFrameConfig('FrameType', 'Data', ...
                                           'ClusterID', iasZoneClusterID, ...
                                           'APSCounter', 1, ...
                                           'AcknowledgementRequest', true);
apsFrameIntrusion = zigbee.APSFrameGenerator(apsConfigIntrusion, zclFrameIntrusion);

% On/Off cluster
apsConfigOn = zigbee.APSFrameConfig('FrameType', 'Data', ...
                                    'ClusterID', onOffClusterID, ...
                                    'APSCounter', 2, ...
                                    'AcknowledgementRequest', true);
apsFrameOn = zigbee.APSFrameGenerator(apsConfigOn, zclFrameOn);

%% Further Exploration
% You can further explore the following generator and decoding functions,
% as well as the configuration object:
%
% * <matlab:edit('zigbee.APSFrameConfig') zigbee.APSFrameConfig>, <matlab:edit('zigbee.APSFrameGenerator') zigbee.APSFrameGenerator>, <matlab:edit('zigbee.APSFrameDecoder') zigbee.APSFrameDecoder>
% * <matlab:edit('zigbee.ZCLFrameConfig') zigbee.ZCLFrameConfig>, <matlab:edit('zigbee.ZCLFrameGenerator') zigbee.ZCLFrameGenerator>, <matlab:edit('zigbee.ZCLFrameDecoder') zigbee.ZCLFrameDecoder>
% * <matlab:edit('zigbee.IASZoneFrameConfig') zigbee.IASZoneFrameConfig>, <matlab:edit('zigbee.IASZoneFrameGenerator') zigbee.IASZoneFrameGenerator>, <matlab:edit('zigbee.IASZoneFrameDecoder') zigbee.IASZoneFrameDecoder>

%% Selected Bibliography
% # ZigBee Alliance, ZigBee Home Automation Public Application Profile, revision 29, v. 1.2, Jun. 2013.
% # ZigBee Alliance, ZigBee Specification Document 053474r17, 2007
% # IEEE 802.15.4-2011 - IEEE Standard for Local and metropolitan area
% networks--Part 15.4: Low-Rate Wireless Personal Area Networks (LR-WPANs)
% # ZigBee Alliance, ZigBee Cluster Library Specification, Revision 6, Jan. 2016.

displayEndOfDemoMessage(mfilename)


