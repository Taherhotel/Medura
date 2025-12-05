import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({super.key, required this.currentData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _caretakerNameController;
  late TextEditingController _caretakerRelationController;
  late TextEditingController _allergiesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentData['name']);
    _ageController = TextEditingController(text: widget.currentData['age']);
    _weightController = TextEditingController(text: widget.currentData['weight']);
    _heightController = TextEditingController(text: widget.currentData['height']);
    _bloodTypeController =
        TextEditingController(text: widget.currentData['bloodType']);
    _caretakerNameController =
        TextEditingController(text: widget.currentData['caretakerName']);
    _caretakerRelationController =
        TextEditingController(text: widget.currentData['caretakerRelation']);
    _allergiesController =
        TextEditingController(text: widget.currentData['allergies']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bloodTypeController.dispose();
    _caretakerNameController.dispose();
    _caretakerRelationController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'age': _ageController.text,
                  'weight': _weightController.text,
                  'height': _heightController.text,
                  'bloodType': _bloodTypeController.text,
                  'caretakerName': _caretakerNameController.text,
                  'caretakerRelation': _caretakerRelationController.text,
                  'allergies': _allergiesController.text,
                });
              }
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Personal Details'),
            _buildTextField('Name', _nameController),
            Row(
              children: [
                Expanded(child: _buildTextField('Age', _ageController, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Blood Type', _bloodTypeController)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField('Weight (kg)', _weightController, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Height (cm)', _heightController, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Caretaker Info'),
            _buildTextField('Caretaker Name', _caretakerNameController),
            _buildTextField('Relation', _caretakerRelationController),
            const SizedBox(height: 24),
            _buildSectionHeader('Medical Notes'),
            _buildTextField('Allergies', _allergiesController, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
