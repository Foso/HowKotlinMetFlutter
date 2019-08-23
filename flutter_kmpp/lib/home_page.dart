import 'package:flutter/material.dart';
import 'package:pure_flutter/home/home_store.dart';
import 'package:pure_flutter/home/home_store_action.dart';
import 'package:pure_flutter/home/home_store_event.dart';
import 'package:pure_flutter/home/home_store_state.dart';
import 'package:pure_flutter/input_page.dart';
import 'package:pure_flutter/repo_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeStore store;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    store = HomeStore();
    store.init();
    store.event.listen((event) {
      if (event is HomeStoreEvent_FetchError) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(event.message),
        ));
      }
    });
    store.dispatch(HomeStoreAction_Fetch('kotlin', true));
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('How Kotlin Met Flutter'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(context, InputPage.route());
              if (result != null) {
                store.dispatch(HomeStoreAction_Fetch(result.username, result.isOrg));
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<HomeStoreState>(
        stream: store.state,
        builder: (context, snap) {
          final state = snap.data;
          if (state == null || state.loading || state.user == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            final user = state.user;
            final length = user.repositories.length + 1;
            return ListView.separated(
              itemCount: length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Image.network(
                          user.avatarUrl,
                          width: 80,
                          height: 80,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                user.login,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(user.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final r = user.repositories[index - 1];
                  return RepoWidget(
                    name: r.name,
                    description: r.description,
                    stars: r.stargazersCount,
                    contributors: r.contributors,
                  );
                }
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  height: 8,
                  color: Colors.grey[300],
                );
              },
            );
          }
        },
      ),
    );
  }
}
