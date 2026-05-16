// CÓDIGO FEITO PELA ALUNO: DIOGO GONÇALVES TONHOSOLO
//RA: 25894007

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_balcao_detalhes.dart';

class TelaBalcaoLista extends StatefulWidget {
  const TelaBalcaoLista({super.key});

  @override
  State<TelaBalcaoLista> createState() => _TelaBalcaoListaState();
}

class _TelaBalcaoListaState extends State<TelaBalcaoLista> {
  @override
  Widget build(BuildContext context) {
    const azulPrincipal = Color(0xFF1482C7);
    const fundoCard = Color(0xFFF0F6FA);
    const bordaCard = Color(0xFF90C2E7);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Balcão de negociação",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Subtítulo centralizado corretamente
            Center(
              child: Text(
                "Negocie tokens de startups com\noutros investidores da plataforma.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.3),
              ),
            ),
            const SizedBox(height: 20),

            // Barra de Busca
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar startups",
                hintStyle: TextStyle(color: Colors.grey[400]),
                suffixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: azulPrincipal, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Startups disponíveis para negociação:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ─── LISTA INTEGRADA COM O FIREBASE ───
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('startups').snapshots(),
                builder: (context, snapshot) {
                  // Mostra loading enquanto carrega
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Se der erro ou não tiver dados
                  if (snapshot.hasError) {
                    return const Center(child: Text("Erro ao carregar os dados."));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Nenhuma startup disponível no momento."));
                  }

                  final startupsDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: startupsDocs.length,
                    itemBuilder: (context, index) {
                      final doc = startupsDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final startupId = doc.id;

                      // 1. Pega o Nome (Se não tiver campo 'name', usa o ID do documento)
                      final nome = data['name'] ?? startupId;

                      // 2. Pega a Imagem da Capa
                      final coverImageUrl = data['coverImageUrl'] ?? '';

                      // 3. Pega o preço em centavos e converte para Reais
                      final precoCents = data['currentTokenPriceCents'] ?? 0;
                      final precoReais = precoCents / 100;
                      final precoFormatado = precoReais.toStringAsFixed(2).replaceAll('.', ',');

                      // Mockados temporariamente (você pode substituir quando tiver no banco)
                      final volumeMock = '30.550,00';
                      final negociacoesMock = '157';
                      final tokensMock = '1.250';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: fundoCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: bordaCard, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo da Startup
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      // Usando a foto do Firebase
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade300,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: coverImageUrl.isNotEmpty
                                            ? Image.network(
                                          coverImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.business, size: 20, color: azulPrincipal),
                                        )
                                            : const Icon(Icons.business, size: 20, color: azulPrincipal),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          nome.toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Preço Médio (Vindo do Firebase)
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Preço médio',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                      const SizedBox(height: 2),
                                      Text('R\$ $precoFormatado',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                ),
                                // Volume e Negociações
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Volume 24h',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                      const SizedBox(height: 2),
                                      Text('R\$ $volumeMock',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Text('$negociacoesMock negociações',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Rodapé do Card
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$tokensMock tokens em\ncirculação',
                                  style: const TextStyle(
                                      color: azulPrincipal, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TelaBalcaoDetalhes(
                                          startupId: startupId,
                                          nome: nome.toString(),
                                          preco: precoFormatado,
                                          imageUrl: coverImageUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: azulPrincipal,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    elevation: 0,
                                  ),
                                  child: const Text('Ver balcão',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const _BottomNav(),
          ],
        ),
      ),


    );
  }
}
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // Removi o BorderRadius e a cor cinza escura para ficar limpo
      decoration: BoxDecoration(
        color: Colors.white, // Deixa branco para fundir com a tela
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5), // Apenas uma linha fina
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Nav(
            icon: Icons.home,
            label: "Início",
            onTap: () => Navigator.pushNamed(context, '/geral'),
          ),
          _Nav(
            icon: Icons.emoji_events,
            label: "Startups",
            onTap: () => Navigator.pushNamed(context, '/catalogo'),
          ),
          const _Nav(icon: Icons.attach_money, label: "Carteira"),
          const _Nav(icon: Icons.show_chart, label: "Valorização"),
          const _Nav(
            icon: Icons.store,
            label: "Negociar",
            active: true,
          ),
        ],
      ),
    );
  }
}
class _Nav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _Nav({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF1482C7) : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? const Color(0xFF1482C7) : Colors.black,
            ),
          )
        ],
      ),
    );
  }
}