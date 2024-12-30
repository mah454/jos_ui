enum RPC {
  rpcSystemShutdown(0),
  rpcSystemReboot(1),
  rpcSystemEnvironmentList(2),
  rpcSystemEnvironmentSet(3),
  rpcSystemEnvironmentGet(4),
  rpcSystemEnvironmentUnset(5),
  rpcSystemOsType(6),
  rpcSystemTotalMemory(7),
  rpcSystemFreeMemory(8),
  rpcSystemUsedMemory(9),
  rpcSystemCpuInformation(10),
  rpcSystemCpuCoreCount(11),
  rpcSystemSetHostname(12),
  rpcSystemGetHostname(13),
  rpcSystemSetDateTime(14),
  rpcSystemSetTimezone(15),
  rpcSystemFullInformation(16),
  rpcSystemEnvironmentUpdate(17),
  rpcSystemEnvironmentBatchSet(18),
  rpcSystemKernelParameterList(19),
  rpcSystemKernelParameterSet(20),
  rpcSystemKernelParameterUnset(21),
  rpcSystemKernelParameterGet(22),
  rpcSystemKernelModuleList(23),
  rpcSystemKernelModuleLoad(24),
  rpcSystemKernelModuleUnload(25),
  rpcSystemKernelModuleInfo(26),
  rpcJvmVersion(100),
  rpcJvmVendor(101),
  rpcJvmTotalHeapSize(102),
  rpcJvmMaxHeapSize(103),
  rpcJvmUsedHeapSize(104),
  rpcJvmGc(105),
  rpcJvmRestart(106),
  rpcConfigBackupCreate(200),
  rpcConfigBackupRestore(201),
  rpcConfigBackupDelete(202),
  rpcConfigBackupList(203),
  rpcConfigPrint(204),
  rpcDateTimeInformation(300),
  rpcDateTimeSyncHctosys(301),
  rpcDateTimeSyncSystohc(302),
  rpcNtpServerName(400),
  rpcNtpSync(401),
  rpcNtpActivate(402),
  rpcNtpInformation(403),
  rpcModuleList(500),
  rpcModuleInstall(501),
  rpcModuleRemove(502),
  rpcModuleEnable(503),
  rpcModuleDisable(504),
  rpcModuleDependencies(505),
  rpcModuleStart(506),
  rpcModuleStop(507),
  rpcModuleStopAll(508),
  rpcModuleStartAll(509),
  rpcModuleInit(510),
  rpcNetworkEthernetInformation(600),
  rpcNetworkEthernetSetIp(601),
  rpcNetworkEthernetUp(602),
  rpcNetworkEthernetDown(603),
  rpcNetworkEthernetFlush(604),
  rpcNetworkRouteList(605),
  rpcNetworkRouteAdd(606),
  rpcNetworkRouteDelete(607),
  rpcNetworkRouteDefaultGateway(608),
  rpcNetworkSetDnsNameserver(609),
  rpcNetworkGetDnsNameserver(610),
  rpcNetworkHostsAdd(611),
  rpcNetworkHostsDelete(612),
  rpcNetworkHostsList(613),
  rpcNetworkNetworkAdd(614),
  rpcNetworkNetworkDelete(615),
  rpcNetworkNetworkList(616),
  rpcFilesystemList(700),
  rpcFilesystemMount(701),
  rpcFilesystemUmount(702),
  rpcFilesystemSwapOn(703),
  rpcFilesystemSwapOff(704),
  rpcFilesystemDirectoryTree(705),
  rpcFilesystemDeleteFile(706),
  rpcFilesystemMoveFile(707),
  rpcFilesystemCreateArchive(708),
  rpcFilesystemExtractArchive(709),
  rpcFilesystemCreateDirectory(710),
  rpcUserList(800),
  rpcUserAdd(801),
  rpcUserRemove(802),
  rpcUserPasswd(803),
  rpcUserLock(804),
  rpcUserUnlock(805),
  rpcUserUpdateRole(806),
  rpcUserRealmList(808),
  rpcLogAppenderList(900),
  rpcLogAppenderAdd(901),
  rpcLogAppenderRemove(902),
  rpcLogSystem(903),
  rpcLogKernel(904),
  rpcSslStatus(1000),
  rpcSslJksUpload(1001),
  rpcSslJksRemove(1002),
  rpcSslJksInfo(1003),
  rpcContainerImagePull(2000),
  rpcContainerImageRemove(2001),
  rpcContainerImageList(2002),
  rpcContainerImageSearch(2004),
  rpcContainerImagePrune(2005),
  rpcContainerImagePullCancel(2006),
  rpcContainerNetworkCreate(2007),
  rpcContainerNetworkRemove(2008),
  rpcContainerNetworkConnect(2009),
  rpcContainerNetworkDisconnect(2010),
  rpcContainerNetworkList(2011),
  rpcContainerVolumeCreate(2012),
  rpcContainerVolumeList(2013),
  rpcContainerVolumeRemove(2014),
  rpcContainerVolumePrune(2015),
  rpcContainerPodCreate(2016),
  rpcContainerPodList(2017),
  rpcContainerPodRemove(2018),
  rpcContainerPodPrune(2019),
  rpcContainerPodStats(2020),
  rpcContainerPodStop(2021),
  rpcContainerPodStart(2022),
  rpcContainerPodKill(2023),
  rpcContainerPodKubePlay(2024),
  rpcContainerPodKubeGenerate(2025),
  rpcContainerCreate(2026),
  rpcContainerRemove(2027),
  rpcContainerList(2028),
  rpcContainerStop(2029),
  rpcContainerStart(2030),
  rpcContainerKill(2031),
  rpcContainerPrune(2032),
  rpcContainerSettingRegistriesLoad(2033),
  rpcContainerSettingRegistriesSave(2034);

  final int code;
  const RPC(this.code);
}

