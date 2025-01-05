import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vocab.dart';

class Vocabulary extends StatefulWidget {
  const Vocabulary({super.key});

  @override
  State<Vocabulary> createState() => _VocabularyState();
}

class _VocabularyState extends State<Vocabulary> {

    final _containerHeight = 700.0;
    final ScrollController _scrollController = ScrollController();
    int _currentScrollIndex = 0;
  
  @override
  void initState(){
    super.initState();

    _scrollController.addListener(_updateScrollIndicator);
  }

  void _updateScrollIndicator(){
    setState(() {
      _currentScrollIndex = _scrollController.offset ~/ _containerHeight;
    });
  }

  void _onNumberTap(int index){
    _scrollController.animateTo(index * _containerHeight, 
    duration: const Duration(seconds: 1), curve: Curves.easeIn);

    setState(() {
      _currentScrollIndex = index;
    });
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
        )
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ExpansionTile(
            title: Text('Unit 1: The Time Value of Money'),
            children: <Widget>[
              ExpansionTile(
                title: Text('1.1 Introduction of the Timeline '),
                children: <Widget>[
                  for (var item in vocab) 
                    ExpansionTile(
                      title: Text(item.word),
                      children: <Widget>[
                        ListTile(title: Text(item.definition)),
                      ],
                    ),
                ],
              ),
              ExpansionTile(
                title: Text('1.2 The three rules of time travel'),
                children: <Widget>[
                  ListTile(title: Text('Item 3')),
                  ListTile(title: Text('Item 4')),
                ],
              ),
            ],
          );
        },
        itemCount: 1,
      ),
    );
  }
}