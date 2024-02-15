import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:html';
import 'dart:typed_data';

import 'package:fetch_client/fetch_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jos_ui/controller/jvm_controller.dart';
import 'package:jos_ui/controller/log_controller.dart';
import 'package:jos_ui/dialog/toast.dart';
import 'package:jos_ui/model/RpcResponse.dart';
import 'package:jos_ui/model/log_level.dart';
import 'package:jos_ui/model/rpc.dart';
import 'package:jos_ui/service/storage_service.dart';

enum UploadType {
  module,
  config;
}

class RestClient {
  static final JvmController jvmController = getx.Get.put(JvmController());
  static final _http = http.Client();
  static final LogController _sseController = Get.put(LogController());

  static String _baseLoginUrl() => "${StorageService.getItem('base_address') ?? 'http://127.0.0.1:7080'}/api/login";

  static String _baseRpcUrl() => "${StorageService.getItem('base_address') ?? 'http://127.0.0.1:7080'}/api/rpc";

  static String _baseUploadUrl() => "${StorageService.getItem('base_address') ?? 'http://127.0.0.1:7080'}/api/upload";

  static String _baseSseUrl() => "${StorageService.getItem('base_address') ?? 'http://127.0.0.1:7080'}/api/sse";

  static String _baseDownloadUrl() => "${StorageService.getItem('base_address') ?? 'http://127.0.0.1:7080'}/api/download";

  static Future<bool> login(String username, String password) async {
    developer.log('Login request [$username] [$password] [${_baseLoginUrl()}]');
    String authB64 = base64Encode(utf8.encode('$username:$password'));
    var headers = {'authorization': 'Basic $authB64'};
    developer.log('Credential send: [$headers]');

    try {
      var response = await _http.get(Uri.parse(_baseLoginUrl()), headers: headers);
      var statusCode = response.statusCode;
      storeJvmNeedRestart(response.headers);
      if (statusCode == 204) {
        storeToken(response.headers);
        developer.log('Login success');
        return true;
      }
      developer.log('Login Failed');
    } catch (e) {
      developer.log('[Http Error] $rpc ${e.toString()}');
    }
    return false;
  }

  static Future<bool> checkLogin() async {
    developer.log('Check login [${_baseLoginUrl()}]');
    var token = StorageService.getItem('token');
    if (token == null) return false;
    var headers = {'authorization': 'Bearer $token'};
    developer.log('Credential send: [$headers]');

    try {
      var response = await _http.get(Uri.parse(_baseLoginUrl()), headers: headers);
      var statusCode = response.statusCode;
      storeJvmNeedRestart(response.headers);
      if (statusCode == 204) {
        developer.log('Token is valid');
        storeToken(response.headers);
        return true;
      }
      developer.log('Invalid token');
    } catch (e) {
      developer.log('[Http Error] $rpc ${e.toString()}');
    }
    return false;
  }

  static Future<RpcResponse> rpc(RPC rpc, {Map<String, dynamic>? parameters}) async {
    developer.log('Request call rpc: [$rpc] [$parameters] [${_baseLoginUrl()}]');
    var token = StorageService.getItem('token');
    if (token == null) getx.Get.toNamed('/');
    var headers = {
      'Authorization': 'Bearer $token',
      'x-rpc-code': '${rpc.value}',
    };
    developer.log('Credential send: [$headers]');

    try {
      var response = await _http.post(Uri.parse(_baseRpcUrl()), headers: headers, body: jsonEncode(parameters));
      var statusCode = response.statusCode;
      developer.log('Response received with http code: $statusCode');
      storeJvmNeedRestart(response.headers);
      storeToken(response.headers);
      if (statusCode == 200) {
        var utf8Body = utf8.decode(response.bodyBytes);
        return RpcResponse.toObject(utf8Body);
      } else if (statusCode == 204) {
        return RpcResponse(true, null, null, null);
      } else if (statusCode == 401) {
        getx.Get.offAllNamed('/');
      } else {
        String msg = jsonDecode(response.body)['message'];
        displayWarning(msg, timeout: 5);
      }
    } catch (e) {
      if (rpc == RPC.systemReboot || rpc == RPC.jvmRestart || rpc == RPC.systemShutdown) {
        developer.log('Normal error by http , The jvm going to shutdown before sending response');
      } else {
        developer.log('[Http Error] $rpc ${e.toString()}');
      }
    }
    return RpcResponse(false, null, null, null);
  }

  static void storeToken(Map<String, String> headers) {
    var authHeader = headers['authorization'];
    if (authHeader != null) {
      var token = authHeader.split(' ')[1];
      StorageService.addItem('token', token);
    }
  }

  static void storeJvmNeedRestart(Map<String, String> headers) {
    var jvmNeedRestart = headers['x-jvm-restart'];
    if (jvmNeedRestart != null) {
      developer.log('Receive header X-Jvm-Restart with value: [$jvmNeedRestart]');
      jvmNeedRestart == 'true' ? jvmController.enableRestartJvm() : jvmController.disableRestartJvm();
    }
  }

  static Future<bool> upload(Uint8List bytes, String fileName, UploadType type) async {
    developer.log('selected file: $fileName');

    var token = StorageService.getItem('token');
    var headers = {
      'authorization': 'Bearer $token',
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse('${_baseUploadUrl()}/${type.name}'));
      request.headers.addAll(headers);
      var fileOrder = http.MultipartFile.fromBytes('file', bytes, filename: fileName);
      request.files.add(fileOrder);
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
        displayError('Invalid ${type.name} file');
        return false;
    }
  }

  static Future<FetchResponse> sse(String packageName, LogLevel logLevel) async {
    developer.log('Start SSE Client [$packageName] [${logLevel.name}]');
    var token = StorageService.getItem('token');
    var header = {'authorization': 'Bearer $token', 'Connection': 'keep-alive', 'Content-type': 'text/event-stream', 'x-log-package': packageName, 'x-log-level': logLevel.name.toUpperCase()};

    var request = http.Request('GET', Uri.parse(_baseSseUrl()));
    request.headers.addAll(header);

    final FetchClient fetchClient = FetchClient(mode: RequestMode.cors);
    return fetchClient.send(request);
  }

  static Future<void> download(Map<String, String> parameters) async {
    developer.log('Download file: ');
    var token = StorageService.getItem('token');
    if (token == null) getx.Get.toNamed('/');
    var headers = {
      'Authorization': 'Bearer $token',
    };
    developer.log('Credential send: [$headers]');

    try {
      var uri = Uri.parse(_baseDownloadUrl()).replace(queryParameters: parameters);

      final anchor = AnchorElement(href: '#')
        ..setAttribute('download', '')
        ..style.display = 'none';
      document.body!.append(anchor);

      // final request = await http.head(uri, headers: headers);
      final request = http.Request('GET', uri);
      request.headers.addAll(headers);
      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final blob = Blob([response.bodyBytes]);
      final urlObject = Url.createObjectUrlFromBlob(blob);

      final contentDisposition = response.headers['content-disposition'];
      final filename = contentDisposition?.split('filename=')[1].replaceAll('"', '');

      anchor.href = urlObject;
      anchor.download = filename;
      anchor.click();
      anchor.remove();
      Url.revokeObjectUrl(urlObject);

      client.close();
    } catch (e) {
      developer.log('[Http Error] $rpc ${e.toString()}');
    }
  }
}
