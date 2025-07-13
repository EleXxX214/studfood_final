import 'package:flutter/material.dart';
import 'package:studfood/components/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestPage extends StatefulWidget {
  const SuggestPage({super.key});

  @override
  State<SuggestPage> createState() => _SuggestPageState();
}

class _SuggestPageState extends State<SuggestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('suggests').add({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
      });
      setState(() => _isSubmitting = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Dziękujemy!'),
            content: const Text('Twoja sugestia została wysłana.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _descController.clear();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Błąd'),
            content: Text('Wystąpił problem podczas wysyłania zgłoszenia:\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Zgłoś restaurację"),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Zgłoś restaurację, która mogłaby oferować zniżki!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa restauracji *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Podaj nazwę restauracji';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Opis zniżek(opcjonalnie)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Wyślij zgłoszenie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
