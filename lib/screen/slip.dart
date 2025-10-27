import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:imm_hotel_app/constants/server.dart";

class Slip extends StatefulWidget {
  const Slip({super.key, required this.bookingId});
  final String bookingId;

  @override
  State<Slip> createState() => _SlipState();
}

class _SlipState extends State<Slip> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  final _fileExtensionController = TextEditingController();
  String? _fileName;
  String? _filePath;
  String? _saveAsFileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  String? _extension;
  bool _isLoading = false;
  bool _lockParentWindow = false;
  bool _userAborted = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  bool _uploadSuccess = false;

  @override
  void initState() {
    super.initState();
    _fileExtensionController
        .addListener(() => _extension = _fileExtensionController.text);
  }

  void _pickFiles() async {
    _resetState();
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        compressionQuality: 30,
        type: _pickingType,
        allowMultiple: _multiPick,
        // ignore: avoid_print
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: _lockParentWindow,
      ))
          ?.files;
       
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _fileName =
      _paths != null ? _paths!.map((e) => e.name).toString() : '...';
      _userAborted = _paths == null;
      _filePath = _paths != null ? _paths!.map((e) => e.path).toString() : '...';
      print(_fileName);
      print(_filePath);
    });
  }

  void _clearCachedFiles() async {
    _resetState();
    try {
      bool? result = await FilePicker.platform.clearTemporaryFiles();
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            (result!
                ? 'Temporary files removed with success.'
                : 'Failed to clean temporary files'),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _logException(String message) {
    if (kDebugMode) {
      print(message);
    }
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _directoryPath = null;
      _fileName = null;
      _paths = null;
      _saveAsFileName = null;
      _userAborted = false;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
  _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  _scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
    ),
  );
}

  Future<void> _uploadSlip() async {
    if (_paths == null || _paths!.isEmpty || _paths!.first.path == null) {
      _showSnackBar('กรุณาเลือกไฟล์ก่อน', isError: true);
      return;
    }
    final platformFile = _paths!.first;
    final allowedExt = ['jpg', 'jpeg', 'png', 'pdf'];
    final ext = platformFile.extension?.toLowerCase();
    if (ext == null || !allowedExt.contains(ext)) {
      _showSnackBar('ชนิดไฟล์ไม่รองรับ', isError: true);
      return;
    }
    // ขนาดสูงสุด 5 MB
    final file = File(platformFile.path!);
    final length = await file.length();
    if (length > 5 * 1024 * 1024) {
      _showSnackBar('ไฟล์ใหญ่เกินไป (สูงสุด 5MB)', isError: true);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // ดึง token จาก storage
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.server}/customer/sendslip'),
      );
      request.fields.addAll({
        'bookingId': widget.bookingId,
      });
      request.files.add(await http.MultipartFile.fromPath(
        'slip',
        _paths!.first.path!,
      ));
      request.headers.addAll({
        'Authorization': 'Bearer ${token ?? ''}',
        'Accept': 'application/json',
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _uploadSuccess = true;
        });
        _showSnackBar('อัพโหลดสลิปสำเร็จ');
        print(await response.stream.bytesToString());
        // กลับไปหน้า home หลังอัพโหลดสำเร็จ
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushNamedAndRemoveUntil(
                context,
                 '/home',
                 (route) => false,
                arguments: {'tab': 3}, // สมมติว่า tab 2 คือ booked
        );
        }
      } else {
        final respStr = await response.stream.bytesToString();
        _showSnackBar('อัพโหลดสลิปไม่สำเร็จ: $respStr', isError: true);
        print(response.reasonPhrase);
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Upload slip'),
      ),
      body: SizedBox(
        height: screenHeight,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //const Text('ขอบคุณสำหรับการจองของคุณ'),
                  //const Text('การทำธุรกรรมจะเสร็จสมบูรณ์'),
                  //const Text('เมื่อเราได้รับการชำระเงินจากคุณ'),
                  const SizedBox(height: 20),
                  // แสดงตัวอย่างสลิป (ถ้าเป็นไฟล์ภาพ)
                  if (_fileName != null &&
                      _paths != null &&
                      _paths!.isNotEmpty &&
                      _paths!.first.path != null &&
                      (_paths!.first.extension?.toLowerCase() == 'jpg' ||
                       _paths!.first.extension?.toLowerCase() == 'jpeg' ||
                       _paths!.first.extension?.toLowerCase() == 'png'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.file(
                        File(_paths!.first.path!),
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  // แสดงชื่อไฟล์ (ถ้ามี)
                  if (_fileName != null && !_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('ไฟล์ที่เลือก: $_fileName'),
                    ),
                  const SizedBox(height: 20),
                  FloatingActionButton.extended(
                    onPressed: () => _pickFiles(),
                    label: const Text('เลือกสลิป'),
                    icon: const Icon(Icons.file_download),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: (_isLoading || _paths == null || _paths!.isEmpty)
                        ? null
                        : (_uploadSuccess ? null : _uploadSlip),
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(
                      _uploadSuccess
                          ? 'อัพโหลดสำเร็จ'
                          : (_isLoading ? 'กำลังอัพโหลด...' : 'อัพโหลดสลิป')
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _uploadSuccess
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  if (_uploadSuccess)
                    const Text('อัพโหลดสำเร็จ', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
