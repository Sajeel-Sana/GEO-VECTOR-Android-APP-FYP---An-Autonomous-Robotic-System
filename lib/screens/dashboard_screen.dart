import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>> missions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    final ref = FirebaseDatabase.instance.ref("missions/${user.uid}");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      final temp = <Map<String, dynamic>>[];

      data.forEach((key, value) {
        temp.add({
          "id": key,
          "data": value,
        });
      });

      setState(() {
        missions = temp;
        loading = false;
      });
    } else {
      setState(() {
        missions = [];
        loading = false;
      });
    }
  }

  Future<void> downloadMission(Map<String, dynamic> mission) async {
    // Permission
    await Permission.storage.request();

    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final fileName = "mission_${mission['id']}.json";
    final file = File("${directory.path}/$fileName");

    final jsonData = jsonEncode(mission['data']);
    await file.writeAsString(jsonData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Downloaded $fileName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Missions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : missions.isEmpty
          ? const Center(child: Text("No missions found"))
          : ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text("Mission ${index + 1}"),
              subtitle: Text(
                "Waypoints: ${(mission['data']['paths'][0]['waypoints'] as List).length}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => downloadMission(mission),
              ),
            ),
          );
        },
      ),
    );
  }
}
