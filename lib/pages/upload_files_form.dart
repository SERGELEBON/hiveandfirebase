/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadFilesForm extends StatefulWidget {
  final bool isMinor;
  final File? profileImage;
  final File? idFront;
  final File? idBack;
  final File? minorDocument;
  final File? birthCertificate;
  final File? identityDocument;
  final Function(File) onProfileImagePicked;
  final Function(File) onIdFrontPicked;
  final Function(File) onIdBackPicked;
  final Function(File) onMinorDocumentPicked;
  final Function(File) onBirthCertificatePicked;
  final Function(File) onIdentityDocumentPicked;

  UploadFilesForm({
    required this.isMinor,
    this.profileImage,
    this.idFront,
    this.idBack,
    this.minorDocument,
    this.birthCertificate,
    this.identityDocument,
    required this.onProfileImagePicked,
    required this.onIdFrontPicked,
    required this.onIdBackPicked,
    required this.onMinorDocumentPicked,
    required this.onBirthCertificatePicked,
    required this.onIdentityDocumentPicked,
  });

  @override
  _UploadFilesFormState createState() => _UploadFilesFormState();
}

class _UploadFilesFormState extends State<UploadFilesForm> {
  final ImagePicker _picker = ImagePicker();

  Widget _buildUploadButton(String text, Function(File) onFilePicked, {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: disabled ? null : () async {
          final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            onFilePicked(File(pickedFile.path));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1A1F31),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_upload, color: Colors.white),
            SizedBox(width: 10),
            Text(text, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildUploadButton('Upload Profile Image', widget.onProfileImagePicked),
        _buildUploadButton('Upload ID Front', widget.onIdFrontPicked),
        _buildUploadButton('Upload ID Back', widget.onIdBackPicked),
        _buildUploadButton('Upload Minor Document', widget.onMinorDocumentPicked, disabled: !widget.isMinor),
        _buildUploadButton('Upload Birth Certificate', widget.onBirthCertificatePicked, disabled: !widget.isMinor),
        _buildUploadButton('Upload Identity Document', widget.onIdentityDocumentPicked, disabled: !widget.isMinor),
      ],
    );
  }
}
 */
