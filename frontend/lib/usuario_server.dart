import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usuario_model.dart';

class UsuarioService {
  static Future<Usuario?> fetchUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print("UID DO USUÁRIO: $uid"); // ← agora depois do uid
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    print("DOCUMENTO EXISTE? ${doc.exists}");
    print("DADOS: ${doc.data()}");

    if (!doc.exists) return null;

    return Usuario.fromMap(doc.data()!);
  }
}