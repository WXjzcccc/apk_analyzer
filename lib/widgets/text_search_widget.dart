import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

class TextSearchDelegate extends SearchDelegate {
  final String text;

  TextSearchDelegate(this.text);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    List<String> matches = [];
    for(String line in text.split('\n')) {
      if (line.toLowerCase().contains(query.toLowerCase())) {
        matches.add(line);
      }
    }
    String resultText = matches.isNotEmpty ? matches.join('\n') : '';
    return ListView(
      children: [
        ListTile(
          title: Text(matches.isNotEmpty ? "<$query> 搜索结果" : '未搜索到'),
        ),
        if (matches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextHighlight(
              text: resultText, 
              words: {
                query: HighlightedWord(
                  textStyle: TextStyle(
                    backgroundColor: Colors.yellow,
                    color: Colors.black,
                  ),
                ),
              },
            ),
          ),
      ],
    );
  }
}