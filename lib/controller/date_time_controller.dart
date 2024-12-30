import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jos_ui/model/protocol/rpc.dart';
import 'package:jos_ui/service/rest_client.dart';
import 'package:jos_ui/widget/toast.dart';

class DateTimeController extends GetxController {
  final TextEditingController ntpServerEditingController = TextEditingController();
  final TextEditingController ntpIntervalEditingController = TextEditingController();
  final TextEditingController timeZoneEditingController = TextEditingController();

  var isNtpActive = false.obs;

  /* Server date & time*/
  var serverDate = ''.obs;
  var serverTime = ''.obs;
  var serverTimeZone = ''.obs;

  /* NTP sync parameters */
  var leapIndicator = ''.obs;
  var version = ''.obs;
  var mode = ''.obs;
  var stratum = ''.obs;
  var poll = ''.obs;
  var precision = ''.obs;
  var rootDelay = ''.obs;
  var rootDispersion = ''.obs;
  var referenceIdentifier = ''.obs;
  var referenceTimestamp = ''.obs;
  var originateTimestamp = ''.obs;
  var receiveTimestamp = ''.obs;
  var transmitTimestamp = ''.obs;

  void fetchNtpInfo() async {
    developer.log('Fetch NTP Information called');
    var payload = await RestClient.rpc(RPC.rpcNtpInformation);
    if (payload.isSuccess()) {
      var json = jsonDecode(payload.content!);
      bool serverNtpIsActive = json['activate'];

      ntpServerEditingController.text = json['server'];
      ntpIntervalEditingController.text = json['interval'].toString();

      if (!serverNtpIsActive) {
        fetchSystemDateTime();
      } else {
        isNtpActive.value = serverNtpIsActive;
        syncNTP();
      }
    }
  }

  void fetchSystemDateTime() async {
    developer.log('Fetch system date time called');
    var payload = await RestClient.rpc(RPC.rpcDateTimeInformation);
    if (payload.isSuccess()) {
      var json = jsonDecode(payload.content!);
      serverDate.value = json['zonedDateTime'].split(' ')[0];
      serverTime.value = json['zonedDateTime'].split(' ')[1];
      serverTimeZone.value = json['zonedDateTime'].split(' ')[2];
    }
  }

  void updateDateTime() {
    developer.log('Update date time called');
    String param = '$serverDate $serverTime';
    RestClient.rpc(RPC.rpcSystemSetDateTime, parameters: {'dateTime': param});
    displayInfo('System date & time updated');
  }

  Future<void> activateNtp() async {
    developer.log('Activate NTP called');
    await RestClient.rpc(RPC.rpcNtpActivate, parameters: {'activate': isNtpActive.value});
    String activeMessage = 'NTP client activated';
    String disabledMessage = 'NTP client disabled';
    if (isNtpActive.value) displayInfo(isNtpActive.value ? activeMessage : disabledMessage);
  }

  Future<void> setNtpConfiguration() async {
    developer.log('Set NTP configuration called');
    var params = {'server': ntpServerEditingController.text, 'interval': int.parse(ntpIntervalEditingController.text)};
    await RestClient.rpc(RPC.rpcNtpServerName, parameters: params);
    displayInfo('NTP configuration updated');
  }

  Future<void> syncNTP() async {
    developer.log('Sync NTP Called');
    var payload = await RestClient.rpc(RPC.rpcNtpSync);
    if (payload.isSuccess()) {
      var json = jsonDecode(payload.content!);
      leapIndicator.value = json['leapIndicator'].toString();
      version.value = json['version'].toString();
      mode.value = json['mode'].toString();
      stratum.value = json['stratum'].toString();
      poll.value = json['poll'].toString();
      precision.value = json['precision'].toString();
      rootDelay.value = json['rootDelay'].toString();
      rootDispersion.value = json['rootDispersion'].toString();
      referenceIdentifier.value = json['referenceIdentifier'].toString();
      referenceTimestamp.value = json['referenceTimestamp'].toString();
      originateTimestamp.value = json['originateTimestamp'].toString();
      receiveTimestamp.value = json['receiveTimestamp'].toString();
      transmitTimestamp.value = json['transmitTimestamp'].toString();
    }
  }

  Future<void> hcToSys() async {
    developer.log('Hardware clock to sys called');
    await RestClient.rpc(RPC.rpcDateTimeSyncHctosys);
  }

  Future<void> sysToHc() async {
    developer.log('System to hardware clock called');
    await RestClient.rpc(RPC.rpcDateTimeSyncSystohc);
  }

  void apply() async {
    if (isNtpActive.value) {
      activateNtp().then((value) => setNtpConfiguration()).then((value) => syncNTP());
    } else {
      activateNtp().then((value) => updateDateTime()).then((value) => fetchSystemDateTime());
    }
  }

  Future<void> updateTimezone(String zone) async {
    var reqParam = {'timezone': zone.split('\t')[0]};
    var payload = await RestClient.rpc(RPC.rpcSystemSetTimezone, parameters: reqParam);
    if (payload.isSuccess()) {
      displayInfo('Timezone successfully updated');
      if (isNtpActive.isTrue) {
        fetchNtpInfo();
      }
    }
  }
}
