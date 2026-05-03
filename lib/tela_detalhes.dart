import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Quando a tela anterior estiver pronta, adicionar: final String startupId e adicionar no construtor: required this.startupId
class TelaDetalhesInformaEs extends StatefulWidget {
  const TelaDetalhesInformaEs({super.key});

  @override
  State<TelaDetalhesInformaEs> createState() => _TelaDetalhesInformaEsState();
}

class _TelaDetalhesInformaEsState extends State<TelaDetalhesInformaEs> {
  int _indiceMenu = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceMenu,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1482C7),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) => setState(() => _indiceMenu = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.rocket_launch), label: "Startups"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Carteira"),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Valorização"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Negociar"),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('startups')
        // quando tela anterior estiver pronta trocar 'biochip-campus' por widget.startupId
            .doc('biochip-campus')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Erro ao carregar os dados."));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1482C7)));
          }

          var dados = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          // --- CAMPOS PUXADOS DO BANCO ---
          String nomeStartup = "BioChip Campus";
          String descricaoStartup = dados['description'] ?? 'Sem descrição';
          String urlLogo = dados['coverImageUrl'] ?? '';
          String sumarioExecutivo = dados['executiveSummary'] ?? 'Sem sumário disponível.';
          String estagio = dados['stage'] ?? 'Em Operação'; //

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _construirCabecalho(),
                  const SizedBox(height: 20),

                  // Passamos o texto do estágio que veio do banco
                  _construirBotaoEstagio(estagio),

                  const SizedBox(height: 20),
                  _construirImagemDestaque(urlLogo),
                  const SizedBox(height: 20),
                  Text(
                    nomeStartup,
                    style: const TextStyle(color: Color(0xFF373737), fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    descricaoStartup,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  const SizedBox(height: 25),
                  _construirCardTokens(),
                  const SizedBox(height: 25),
                  _construirCardInformacoes(sumarioExecutivo),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ATUALIZADOS ---

  Widget _construirBotaoEstagio(String textoEstagio) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFDBD9D9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1482C7), width: 1),
        boxShadow: const [BoxShadow(color: Color(0xFFC1C1C1), blurRadius: 4, offset: Offset(0, 4))],
      ),
      // Agora exibe "Estágio: " + o valor que está no Firebase
      child: Text(
        "Estágio: $textoEstagio",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // (Os outros métodos _construirCabecalho, _construirImagemDestaque, etc., permanecem iguais aos anteriores)

  Widget _construirCabecalho() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () {}),
        const Text("Detalhes da Startup", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const CircleAvatar(backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png")),
      ],
    );
  }

  Widget _construirImagemDestaque(String url) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1482C7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: url.isNotEmpty ? Image.network(url, fit: BoxFit.cover) : const Icon(Icons.image),
      ),
    );
  }

  Widget _construirCardTokens() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1482C7)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total de Tokens:", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1482C7)),
                child: const Text("Comprar Tokens", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("0,00", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC71414)),
                child: const Text("Vender Tokens", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirCardInformacoes(String sumario) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1482C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Informações", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text("Sumário Executivo:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(sumario, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}