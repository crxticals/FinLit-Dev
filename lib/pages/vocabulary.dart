import 'package:flutter/material.dart';
import 'vocab.dart';

class Vocab {
  final String word;
  final String definition;

  Vocab(this.word, this.definition);
}

class Vocabulary extends StatefulWidget {
  const Vocabulary({super.key});

  @override
  State<Vocabulary> createState() => _VocabularyState();
}

class _VocabularyState extends State<Vocabulary> {
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
      body: ExpansionTile(
        title: const Text('Unit 1: The Time Value of Money'),
        children: <Widget>[
          ExpansionTile(
            title: const Text('1.1 Introduction of the Timeline'),
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vocab.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(vocab[index].word),
                    subtitle: Text(vocab[index].definition),
                  );
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('1.2 The three rules of time travel'),
            children: <Widget>[
              const ListTile(title: Text('Item 3')),
              const ListTile(title: Text('Item 4')),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Vocabulary(),
  ));
}
