/*import 'package:flutter/material.dart';

class PersonalInformationForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dateOfBirthController;
  final TextEditingController idTypeController;
  final TextEditingController idNumberController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(String) onDateOfBirthChanged;

  PersonalInformationForm({
    required this.firstNameController,
    required this.lastNameController,
    required this.dateOfBirthController,
    required this.idTypeController,
    required this.idNumberController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onDateOfBirthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: firstNameController,
          decoration: InputDecoration(labelText: 'First Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your first name';
            }
            return null;
          },
        ),
        TextFormField(
          controller: lastNameController,
          decoration: InputDecoration(labelText: 'Last Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your last name';
            }
            return null;
          },
        ),
        TextFormField(
          controller: dateOfBirthController,
          decoration: InputDecoration(labelText: 'Date of Birth (DD-MM-YYYY)'),
          onTap: () async {
            FocusScope.of(context).requestFocus(new FocusNode());

            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              String formattedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
              dateOfBirthController.text = formattedDate;
              onDateOfBirthChanged(formattedDate);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your date of birth';
            }
            return null;
          },
        ),
        TextFormField(
          controller: idTypeController,
          decoration: InputDecoration(labelText: 'ID Type'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your ID type';
            }
            return null;
          },
        ),
        TextFormField(
          controller: idNumberController,
          decoration: InputDecoration(labelText: 'ID Number'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your ID number';
            }
            return null;
          },
        ),
        TextFormField(
          controller: passwordController,
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
          controller: confirmPasswordController,
          decoration: InputDecoration(labelText: 'Confirm Password'),
          obscureText: true,
          validator: (value) {
            if (value == null || value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
 */
