import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaBalcaoDetalhes extends StatefulWidget {
  final String startupId;
  final String nome;
  final String preco;
  final String imageUrl;

  const TelaBalcaoDetalhes({
    super.key,
    required this.startupId,
    required this.nome,
    required this.preco,
    required this.imageUrl,
  });

  @override
  State<TelaBalcaoDetalhes> createState() => _TelaBalcaoDetalhesState();
}

class _TelaBalcaoDetalhesState extends State<TelaBalcaoDetalhes> {
  final Color azulPrincipal = const Color(0xFF1482C7);
  final Color vermelhoOferta = const Color(0xFFC80101);
  final Color verdeOferta = const Color(0xFF237E04);
  final fundoCard = Color(0xFFF0F6FA);

  bool _mostrandoCompra = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Balcão de negociação", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ─── CABEÇALHO DA STARTUP ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: fundoCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: azulPrincipal),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text("Ver detalhes", style: TextStyle(color: azulPrincipal, decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Preço médio", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("R\$ ${widget.preco}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text("+ 2,35% hoje", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //  comprar e vender
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mostrandoCompra = true; // Muda para a aba de compra
                      });
                    },
                    child: _buildTab("Comprar", _mostrandoCompra, verdeOferta),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mostrandoCompra = false;
                      });
                    },
                    child: _buildTab("Vender",!_mostrandoCompra, vermelhoOferta),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_mostrandoCompra)
              _buildOfertasSection("Ofertas de compra", verdeOferta, true)
            else
              _buildOfertasSection("Ofertas de venda", vermelhoOferta, false),


            const SizedBox(height: 20),

            // ─── MINHAS OFERTAS ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(15),
                border:Border.all(color: azulPrincipal),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Minhas ofertas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton(onPressed: () {}, child: const Text("Ver todas", style: TextStyle(color: Colors.blue))),
                    ],
                  ),
                  const Text("Você não possui nenhuma oferta para este ativo.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ─── BOTÕES DE AÇÃO ───
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("+ Nova oferta de compra", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("+ Nova oferta de venda", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  Widget _buildTab(String label, bool active, Color corAtiva) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? corAtiva.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? corAtiva : Colors.transparent, width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? corAtiva : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildOfertasSection(String titulo, Color cor, bool isCompra) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: azulPrincipal),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // header da Tabela
              Container(
                decoration: BoxDecoration(
                color: fundoCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10))
                ),
                padding: const EdgeInsets.all(10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("Usuário", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Quantidade", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Preço(R\$)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Total(R\$)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Linhas da Tabela
    if (isCompra) ...[
      _buildTableRow("Investidor 1", "5000000000", "10,05", "5.005,00", cor),
      _buildTableRow("Investidor 2", "300000000", "10,25", "3.075,00", cor),
      _buildTableRow("Investidor 3", "2000", "11,50", "2.300,00", cor),
      _buildTableRow("Investidor 4", "509", "10,05", "5.005,00", cor),
      _buildTableRow("Investidor 5", "310", "10,25", "3.075,00", cor),
      _buildTableRow("Investidor 6", "200", "11,50", "2.300,00", cor),
    ] else ...[
    _buildTableRow("Investidor 7", "7000000", "13,10", "6.550,00", cor),
    _buildTableRow("Investidor 8", "150000000", "12,70", "1.905,00", cor),
    _buildTableRow("Investidor 9", "100", "13,10", "1.310,00", cor),
    ]
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(String user, String qtd, String preco, String total, Color cor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(user, style: TextStyle(color: cor, fontSize: 11))),
          Expanded(child: Text(qtd, style: TextStyle(color: cor, fontSize: 11))),
          Expanded(child: Text(preco, style: TextStyle(color:cor, fontSize: 11))),
          Expanded(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(total, style: TextStyle(color: cor, fontSize: 11)),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          )),
        ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _IconNav(icon: Icons.home, label: "Início"),
          _IconNav(icon: Icons.business, label: "Startups"),
          _IconNav(icon: Icons.account_balance_wallet, label: "Carteira"),
          _IconNav(icon: Icons.show_chart, label: "Valorização"),
          _IconNav(icon: Icons.store, label: "Negociar", active: true),
        ],
      ),
    );
  }
}

class _IconNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _IconNav({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFF1482C7) : Colors.black),
        Text(label, style: TextStyle(fontSize: 11, color: active ? const Color(0xFF1482C7) : Colors.black)),
      ],
    );
  }
}