import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List articles = [];
  bool loading = true;
  bool updating = false;
  Timer? timer;
  String lastUpdated = "";

  @override
  void initState() {
    super.initState();
    getData();

    // auto refresh every 3 seconds
    timer = Timer.periodic(Duration(seconds: 3), (t) {
      getData();
    });
  }

  Future<void> getData() async {
    if (updating) return;

    setState(() {
      updating = true;
    });

    try {
      var res = await http.get(
        Uri.parse('https://api.spaceflightnewsapi.net/v4/articles/'),
      );

      var data = jsonDecode(res.body);

      List list = data['results'];

      list.shuffle(); // just to show visible change

      setState(() {
        articles = list.take(10).toList();
        loading = false;
        lastUpdated = DateTime.now().toLocal().toString();
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      updating = false;
    });
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget card(item) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              item['summary'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live News Feed"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              showMsg("Refreshing...");
              await getData();
              showMsg("Updated");
            },
          )
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          showMsg("Refreshing...");
          await getData();
          showMsg("Updated");
        },
        child: Column(
          children: [
            if (updating)
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  "Updating...",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "Last updated: $lastUpdated",
                style: TextStyle(fontSize: 12),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: articles.length,
                itemBuilder: (c, i) => card(articles[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}