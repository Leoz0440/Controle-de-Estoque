import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  Future<void> adicionarUsuario(String nome, int idade) async {
    await FirebaseFirestore.instance.collection('users').add({
      'nome': nome,
      'idade': idade,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Usuário adicionado com sucesso!');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obterUsuarios() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }
}
