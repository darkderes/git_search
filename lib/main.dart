import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(ProfileSearchApp());

class ProfileSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileSearchScreen(),
    );
  }
}

class Profile {
  final String login;
  final String avatarUrl;
  final int repositoryCount;

  Profile(this.login, this.avatarUrl, this.repositoryCount);
}

class ProfileSearchScreen extends StatefulWidget {
  @override
  _ProfileSearchScreenState createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Profile> _profiles = [];

  void _searchProfiles(String query) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/search/users?q=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      _profiles = items.map((item) {
        final login = item['login'];
        final avatarUrl = item['avatar_url'];
        final repositoryCount =
            item['public_repos']; // Obtén el conteo de repositorios
        return Profile(login, avatarUrl, repositoryCount ?? 0);
      }).toList();
    } else {
      _profiles.clear();
    }

    setState(() {});
  }

void _countRepos(String query) async {
  final response = await http.get(
    Uri.parse('https://api.github.com/users/darkderes/repos'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> repos = json.decode(response.body);
    List<int> ids = [];
    
    for (var repo in repos) {
      if (repo.containsKey("id")) {
        ids.add(repo["id"]);
      }
    }
    
    print('IDs de repositorios: $ids');
  } else {
    print('No se pudieron obtener los repositorios.');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Profile Search'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              onChanged: (query) {
                _searchProfiles(query);
                _countRepos(query);
              },
              decoration: InputDecoration(labelText: 'Search GitHub Profiles'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(_profiles[index].avatarUrl),
                  title: Text(_profiles[index].login),
                  subtitle:
                      Text('Repositorios: ${_profiles[index].repositoryCount}'),
                  onTap: () {
                    // Implementa la acción al seleccionar un perfil de GitHub
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
