import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/authentication/email_auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController noteController = TextEditingController();

  void saveNotes() async {
    String note = noteController.text.trim();
    noteController.clear();

    if (note.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notes')
            .add({'note': note, 'created_at': FieldValue.serverTimestamp()});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Note saved successfully!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a note")),
      );
    }
  }

  void logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _showEditDialog(DocumentReference noteRef, String currentNote) {
    TextEditingController editController =
    TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Note"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Update your note",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String updatedNote = editController.text.trim();
                if (updatedNote.isNotEmpty) {
                  await noteRef.update({'note': updatedNote});
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Note updated successfully!")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              logOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: const Text(
          "Welcome, all your notes will be here",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: "Anything in your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveNotes,
              child: const Text("Save Note"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('notes')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    final notes = snapshot.data!.docs;

                    if (notes.isEmpty) {
                      return const Center(child: Text("No notes yet!"));
                    }

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note =
                        notes[index].data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(note['note']),
                            subtitle: Text(
                              note['created_at'] != null
                                  ? (note['created_at'] as Timestamp)
                                  .toDate()
                                  .toString()
                                  : "No date",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(notes[index].reference,
                                        note['note']);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    notes[index].reference.delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Note deleted")),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(child: Text("Something went wrong!"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
