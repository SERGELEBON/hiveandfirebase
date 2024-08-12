
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import '../models/hive_models/user.dart';

class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isAccepted = false;
  bool _isMinor = false;

  File? _profileImage;
  File? _idFront;
  File? _idBack;
  File? _minorDocument;
  File? _birthCertificate;
  File? _identityDocument;

  final ImagePicker _picker = ImagePicker();

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = DateTime.now().year;
  String _selectedIdType = 'CNI'; // Type de pièce par défaut

  void _calculateAge() {
    final birthDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    setState(() {
      _isMinor = age < 18;
    });
  }

  Widget _buildUploadButton(String text, Function(File) onFilePicked, {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: disabled
            ? null
            : () async {
          final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            onFilePicked(File(pickedFile.path));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey : Color(0xFF1A1F31),
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

  // Méthode pour récupérer et afficher les utilisateurs enregistrés

    Future<List<User>> _getUsers() async {
      final userBox = await Hive.openBox<User>('userBox');
      return userBox.values.toList();
    }

    Widget _buildUserList() {
      return FutureBuilder<List<User>>(
        future: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur lors du chargement des utilisateurs'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun utilisateur enregistré.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Text('Date de naissance: ${user.dateOfBirth}\nType de pièce: ${user.idType}\nNuméro de pièce: ${user.idNumber}, ${user.password}'),
                );
              },
            );
          }
        },
      );
    }



  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _isAccepted) {
      if (_profileImage == null || _idFront == null || _idBack == null ||
          (_isMinor && (_minorDocument == null || _birthCertificate == null || _identityDocument == null))) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All files must be uploaded')));
        return;
      }

      final userBox = Hive.box<User>('userBox');
      final user = User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: '${_selectedDay.toString().padLeft(2, '0')}-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedYear}',
        idType: _selectedIdType,
        idNumber: _idNumberController.text,
        password: _passwordController.text,
      );
      userBox.add(user);
      print("$_profileImage, $_idFront, $_idBack, $_minorDocument, $_identityDocument, $_birthCertificate ");

      Navigator.pushNamed(context, '/welcome');
      // Réinitialisation des champs de fichiers après soumission

     setState(() {

        _profileImage = null;
        _idFront = null;
        _idBack = null;
        _minorDocument = null;
        _birthCertificate = null;
        _identityDocument = null;
        print("$_profileImage, $_idFront, $_idBack, $_minorDocument, $_identityDocument, $_birthCertificate ");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire Multi-Étapes'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text("Retour"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stepper(
              currentStep: _currentStep,
              onStepContinue: _currentStep < 1 ? () => setState(() => _currentStep += 1) : _submitForm,
              onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep -= 1) : null,
              steps: [
                Step(
                  title: Text('Informations Personnelles'),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(labelText: 'Prénom'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre prénom';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(labelText: 'Nom'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedDay,
                                items: List.generate(31, (index) => index + 1).map((day) {
                                  return DropdownMenuItem<int>(
                                    value: day,
                                    child: Text(day.toString().padLeft(2, '0')),
                                  );
                                }).toList(),
                                decoration: InputDecoration(labelText: 'Jour'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDay = value ?? _selectedDay;
                                    _calculateAge();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedMonth,
                                items: List.generate(12, (index) => index + 1).map((month) {
                                  return DropdownMenuItem<int>(
                                    value: month,
                                    child: Text(month.toString().padLeft(2, '0')),
                                  );
                                }).toList(),
                                decoration: InputDecoration(labelText: 'Mois'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonth = value ?? _selectedMonth;
                                    _calculateAge();
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedYear,
                                items: List.generate(100, (index) => DateTime.now().year - index).map((year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                                decoration: InputDecoration(labelText: 'Année'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value ?? _selectedYear;
                                    _calculateAge();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedIdType,
                          items: [
                            DropdownMenuItem(value: 'CNI', child: Text('CNI')),
                            DropdownMenuItem(value: 'PERMIS', child: Text('PERMIS')),
                            DropdownMenuItem(value: 'PASSEPORT', child: Text('PASSEPORT')),
                            DropdownMenuItem(value: 'AUTRE PIECE', child: Text('AUTRE PIECE')),
                          ],
                          decoration: InputDecoration(labelText: 'Type de Pièce'),
                          onChanged: (value) {
                            setState(() {
                              _selectedIdType = value ?? _selectedIdType;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un type de pièce';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _idNumberController,
                          decoration: InputDecoration(labelText: 'Numéro de Pièce'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre numéro de pièce';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Mot de Passe'),
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 4) {
                              return 'Le mot de passe doit contenir au moins 4 chiffres';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(labelText: 'Confirmer le Mot de Passe'),
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: Text('Téléchargement de fichiers'),
                  content: Column(
                    children: [
                      _buildUploadButton('Télécharger la photo de profil', (file) => setState(() => _profileImage = file)),
                      _buildUploadButton('Télécharger le recto de la pièce', (file) => setState(() => _idFront = file)),
                      _buildUploadButton('Télécharger le verso de la pièce', (file) => setState(() => _idBack = file)),
                      if (_isMinor) ...[
                        _buildUploadButton('Télécharger l\'autorisation parentale', (file) => setState(() => _minorDocument = file)),
                        _buildUploadButton('Télécharger l\'acte de naissance', (file) => setState(() => _birthCertificate = file)),
                        _buildUploadButton('Télécharger la carte d\'identité du mineur', (file) => setState(() => _identityDocument = file)),
                      ],
                      Row(
                        children: [
                          Checkbox(
                            value: _isAccepted,
                            onChanged: (value) {
                              setState(() {
                                _isAccepted = value ?? false;
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isAccepted = !_isAccepted;
                              });
                            },
                            child: Text("J'accepte les termes et conditions"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),
              ],
            ),
            Divider(),
           /* Text(
              'Liste des utilisateurs enregistrés :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._buildUserList(), */ // Affiche la liste des utilisateurs
          ],
        ),
      ),
    );
  }
}
























/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import '../login/login_page.dart';
import '../models/user.dart';

class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idTypeController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isAccepted = false;
  bool _isMinor = false;

  File? _profileImage;
  File? _idFront;
  File? _idBack;
  File? _minorDocument;
  File? _birthCertificate;
  File? _identityDocument;

  final ImagePicker _picker = ImagePicker();

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = DateTime.now().year;

  void _calculateAge() {
    final birthDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final today = DateTime.now();
    var age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    setState(() {
      _isMinor = age < 18;
    });
  }

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

  Future<void> _submitForm() async {
    print ( _selectedDay);
    print(_selectedMonth);
    print(_selectedYear);

    if (_formKey.currentState!.validate() && _isAccepted) {
      if (_profileImage == null || _idFront == null || _idBack == null ||
          (_isMinor && (_minorDocument == null || _birthCertificate == null || _identityDocument == null))) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All files must be uploaded')));
        return;
      }

      final userBox = Hive.box<User>('userBox');
      final user = User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: '${_selectedDay.toString().padLeft(2, '0')}-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedYear}',
        idType: _idTypeController.text,
        idNumber: _idNumberController.text,
        password: _passwordController.text,
      );
      userBox.put('user', user);

      // Reset file fields after submission
      setState(() {
        _profileImage = null;
        _idFront = null;
        _idBack = null;
        _minorDocument = null;
        _birthCertificate = null;
        _identityDocument = null;
      });

      Navigator.pushNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Step Form'),
        actions: [
          ElevatedButton(onPressed: ()=>{
          Navigator.pushNamed(context, '/login')
          }, child: Text("Retour"))
        ],

      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep < 1 ? () => setState(() => _currentStep += 1) : _submitForm,
        onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep -= 1) : null,
        steps: [

          Step(
            title: Text('Personal Information'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedDay,
                          items: List.generate(31, (index) => index + 1).map((day) {
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text(day.toString().padLeft(2, '0')),
                            );
                          }).toList(),
                          decoration: InputDecoration(labelText: 'Day'),
                          onChanged: (value) {
                            setState(() {
                              _selectedDay = value ?? _selectedDay;
                              _calculateAge();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedMonth,
                          items: List.generate(12, (index) => index + 1).map((month) {
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text(month.toString().padLeft(2, '0')),
                            );
                          }).toList(),
                          decoration: InputDecoration(labelText: 'Month'),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth = value ?? _selectedMonth;
                              _calculateAge();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedYear,
                          items: List.generate(100, (index) => DateTime.now().year - index).map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          decoration: InputDecoration(labelText: 'Year'),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value ?? _selectedYear;
                              _calculateAge();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _idTypeController,
                    decoration: InputDecoration(labelText: 'ID Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ID type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _idNumberController,
                    decoration: InputDecoration(labelText: 'ID Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ID number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text('Upload Files'),
            content: Column(
              children: [
                _buildUploadButton('Upload Profile Image', (file) => _profileImage = file),
                _buildUploadButton('Upload ID Front', (file) => _idFront = file),
                _buildUploadButton('Upload ID Back', (file) => _idBack = file),
                _buildUploadButton('Upload Minor Document', (file) => _minorDocument = file, disabled: !_isMinor),
                _buildUploadButton('Upload Birth Certificate', (file) => _birthCertificate = file, disabled: !_isMinor),
                _buildUploadButton('Upload Identity Document', (file) => _identityDocument = file, disabled: !_isMinor),
                CheckboxListTile(
                  title: GestureDetector(
                    onTap: () {
                      // Code pour afficher les conditions d'utilisation
                    },
                    child: Text(
                      'I accept the terms and conditions',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  value: _isAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAccepted = value ?? false;
                    });
                  },
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 */ //Marc first







/*import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'personal_information_form.dart';
import 'upload_files_form.dart';
import 'package:hive/hive.dart';

class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _idTypeController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isAccepted = false;
  bool _isMinor = false;

  File? _profileImage;
  File? _idFront;
  File? _idBack;
  File? _minorDocument;
  File? _birthCertificate;
  File? _identityDocument;

  void _calculateAge(String date) {
    if (date.isEmpty) return;

    final birthDate = DateTime.parse(date);
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    setState(() {
      _isMinor = age < 18;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _isAccepted) {
      if (_profileImage == null || _idFront == null || _idBack == null ||
          (_isMinor && (_minorDocument == null || _birthCertificate == null || _identityDocument == null))) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All files must be uploaded')));
        return;
      }

      final userBox = Hive.box<User>('userBox');
      final user = User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _dateOfBirthController.text,
        idType: _idTypeController.text,
        idNumber: _idNumberController.text,
        password: _passwordController.text,
      );
      userBox.put('user', user);

      // Reset file fields after submission
      setState(() {
        _profileImage = null;
        _idFront = null;
        _idBack = null;
        _minorDocument = null;
        _birthCertificate = null;
        _identityDocument = null;
      });

      Navigator.pushNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Step Form'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep < 1 ? () => setState(() => _currentStep += 1) : _submitForm,
        onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep -= 1) : null,
        steps: [
          Step(
            title: Text('Personal Information'),
            content: PersonalInformationForm(
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              dateOfBirthController: _dateOfBirthController,
              idTypeController: _idTypeController,
              idNumberController: _idNumberController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              onDateOfBirthChanged: _calculateAge,
            ),
          ),
          Step(
            title: Text('Upload Files'),
            content: UploadFilesForm(
              isMinor: _isMinor,
              profileImage: _profileImage,
              idFront: _idFront,
              idBack: _idBack,
              minorDocument: _minorDocument,
              birthCertificate: _birthCertificate,
              identityDocument: _identityDocument,
              onProfileImagePicked: (file) => setState(() => _profileImage = file),
              onIdFrontPicked: (file) => setState(() => _idFront = file),
              onIdBackPicked: (file) => setState(() => _idBack = file),
              onMinorDocumentPicked: (file) => setState(() => _minorDocument = file),
              onBirthCertificatePicked: (file) => setState(() => _birthCertificate = file),
              onIdentityDocumentPicked: (file) => setState(() => _identityDocument = file),
            ),
          ),
        ],
      ),
    );
  }
}
 */ //Second
