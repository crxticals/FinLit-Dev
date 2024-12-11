import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Vocabulary extends StatefulWidget {
  const Vocabulary({super.key});

  @override
  State<Vocabulary> createState() => _VocabularyState();
}

class _VocabularyState extends State<Vocabulary> {
  Map<String, dynamic>? vocabulary;

  Future<void> loadJsonAsset() async {
    final String jsonString = await rootBundle.loadString('vocab.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);
    setState(() {
      vocabulary = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D3F6B),
        title: const Text(
          'Vocabulary',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: vocabulary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vocabulary!.keys.length,
              itemBuilder: (BuildContext context, int unitIndex) {
                String unitKey = vocabulary!.keys.elementAt(unitIndex);
                Map<String, dynamic> unitData = vocabulary![unitKey];

                return ExpansionTile(
                  title: Text(unitKey),
                  children: unitData.keys.map((subUnitKey) {
                    List<dynamic> subUnitData = unitData[subUnitKey];

                    return ExpansionTile(
                      title: Text(subUnitKey),
                      children: subUnitData.map((vocabItem) {
                        return ListTile(
                          title: Text(vocabItem['term']),
                          subtitle: Text(vocabItem['definition']),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Vocabulary(),
  ));
}
