Param(
[int]$engineCount,
[string]$outputIp
)

$modelXml = 
@"
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<AirEngineConfig Version="3">
	<General InstanceName="" EmbedInstanceName="1" VideoBadFileName="" AudioBadFileName="" ExternalCommandsServer="" IdleColor="#0000FF" MinimumItemLen="500" MarkNewItemStart="0" ProcessCC="1" ProcessTeletext="1" HTTPOnLocalhostOnly="0" VideoAccelerator="Direct3D11/0" QueueSize="10" FeedbackCodec="4294901760" ProcessingMode="0" OutBlocks="3" FeedbackAudioCodec="4"/>
	<StartInLive Enabled="0" LiveTargetAspect="0" AudioMatrixFileName="" AudioMatrixName=""/>
	<SCTE35Generator SplicePrerollMs="4000" Scte104Line="11" AutoReturnMode="0"/>
	<Licensing BasicProduction="0" BasicAutomaton="0" AdvancedProduction="1" AdvancedAutomaton="1"/>
	<Channels MaxFormat="720x576i_25 4:3" DropFrame="0">
		<Channel0 Format="720x576i_25 16:9" ColorInfo="17">
			<Output0 Clsid="{BDDDCDE6-D5C6-4833-B4C4-39DAA9B014A7}" Url="srt://34.254.239.223:6000" MulticastSourceIP="0.0.0.0" MulticastSourceIP2="0.0.0.0" MulticastTTL="1" TSPacketsInRTP="7" RegistrationServer="" OutputID="" ServiceID="1" TransportID="0" PMT_PID="256" PCR_PID="0" SCTE35_PID="0" VideoType="131073" VideoBitrate="3000000" GOPSize="30" GOPPDist="1" ClosedGOP="1" ChromaFormat="0" FrameCodingType="1" VideoPID="4096" AudioStreams="1" AudioStreamInput_0="0" AudioStreamPID_0="4097" AudioStreamType_0="0" AudioStreamBitrate_0="128000" AudioStreamLanguage_0="" H264EntropyCoding="0" AdaptiveGOP="0" TransportRate="0" OP4247_PID="0" CodingWindow="4294967295" RateMode="0" BitDepth="8" ErrorCorrection="0" SrtPassphrase="" OP4247_Descriptor="eng:2:801" OP4247_Bitrate="400000">
				<Prescale Enabled="0" Pixels="720" Lines="576" HiFps="0" Progressive="0"/>
			</Output0>
		</Channel0>
	</Channels>
	<RtpInput Clsid="{F071F479-67B8-4E8D-BE8B-42CD7550D37D}" Url="" IPListenOn="0.0.0.0"/>
	<SCTE35Listener Enabled="0" Url="device://0" OutOffset="0" InOffset="0"/>
	<GFX Mode="0" UseTypeInSeq="1" TypeRootFolder="" NoCGVideo="0"/>
	<AudioInput>
		<S0 Flags="65536" Channels="0;1" Meta="-1" DRC="1"/>
		<S1 Flags="65536" Channels="2;3" Meta="-1" DRC="1"/>
		<S2 Flags="65536" Channels="4;5" Meta="-1" DRC="1"/>
		<S3 Flags="65536" Channels="6;7" Meta="-1" DRC="1"/>
		<S4 Flags="0" Channels="" Meta="-1" DRC="1"/>
		<S5 Flags="0" Channels="" Meta="-1" DRC="1"/>
		<S6 Flags="0" Channels="" Meta="-1" DRC="1"/>
		<S7 Flags="0" Channels="" Meta="-1" DRC="1"/>
	</AudioInput>
	<AudioOutput>
		<S0 Flags="65536" Channels="0;1" Meta="-1"/>
		<S1 Flags="65536" Channels="2;3" Meta="-1"/>
		<S2 Flags="65536" Channels="4;5" Meta="-1"/>
		<S3 Flags="65536" Channels="6;7" Meta="-1"/>
		<S4 Flags="0" Channels="" Meta="-1"/>
		<S5 Flags="0" Channels="" Meta="-1"/>
		<S6 Flags="0" Channels="" Meta="-1"/>
		<S7 Flags="0" Channels="" Meta="-1"/>
	</AudioOutput>
	<Proxy Enabled="0" Folder="C:\CinegyAirProxy" MaximumGb="100" RefreshTime="15000" Compression="4" RenderThreadCount="1" RenderBuffers="8" RenderSpeedLimit="250" IsSpeedLimit="0" IgnoreEOF="0" EnableQualityDegradation="0" MpegFormat="2" UseGPU="0" StampProxyFrames="0" ExtendedLog="0" ForceMPEG2="0" ProxyThreadPriority="Lowest"/>
	<Logging LogFolder="C:\Logs" TraceLevel="1" ErrorLevel="1" RotateFrequency="24" DayStartAt="6" AsRunLogFolder=""/>
	<Events>
		<TitleList Enabled="0" Device="SUBTITLE" Command="LOAD" Op1="" Frequency="5000" Items="3"/>
		<TitleTC Enabled="0" Device="SUBTITLE" Command="TC" Op1="" Frequency="5000" Delay="0"/>
		<EPGList Enabled="0" Device="EPG" Command="LOAD" Op1="" Frequency="5000" Items="3"/>
		<EPGTC Enabled="0" Device="EPG" Command="TC" Op1="" Frequency="5000" Delay="0"/>
		<LiveEnter Enabled="0" Device="" Command="" Op1="" Op2="" Op3=""/>
		<LiveLeave Enabled="0" Device="" Command="" Op1="" Op2="" Op3=""/>
	</Events>
	<GPI Enabled="0" CommercialBitNo="7" CommercialPrerollMs="2000" LiveEnabled="0" LiveBitNo="0" LivePrerollMs="2000"/>
	<DTMFGen NetworkOut="" NetworkIn="" Preroll="3000" Level="-20" ToneDuration="50" SilenceDuration="50"/>
	<DTMF Enabled="0" Device="0" AudioChannel="0" NetworkOut="" NetworkIn="" Preroll="3000"/>
</AirEngineConfig>
"@

New-Item -ItemType Directory -Force -Path C:\ProgramData\Cinegy\CinegyAir\Config\
	
[xml]$profileXml = $modelXml

for($i =0 ; $i -lt $engineCount; $i++ ){
    $profileXml.AirEngineConfig.General.InstanceName = "Air$($i+1)"
    $profileXml.AirEngineConfig.General.IdleColor = "#{0:X6}" -f (10 * $i)
    $profileXml.AirEngineConfig.Channels.Channel0.Output0.Url = "srt://" + $outputIp + ":" + (6000 + $i)
    $profileXml.AirEngineConfig.Logging.LogFolder = "C:\Data\Logs\Air$i"
    New-Item -ItemType Directory -Force -Path $profileXml.AirEngineConfig.Logging.LogFolder
    $profileXml.Save("C:\ProgramData\Cinegy\CinegyAir\Config\Instance-$i.Config.xml")
}
