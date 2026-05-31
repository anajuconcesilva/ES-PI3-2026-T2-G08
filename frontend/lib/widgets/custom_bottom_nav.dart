// CÓDIGO FEITO PELO ALUNO: DIOGO GONÇALVES TONHOSOLO
//RA: 25894007

import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final String paginaAtiva; 
  const CustomBottomNav({
    super.key,
    required this.paginaAtiva,
  });

 @override
  Widget build(BuildContext context) {
    return Container(
      // Mantemos o padding apenas no topo e na base (sem safe area manual)
      padding: const EdgeInsets.only(top: 12, bottom: 8), 
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1))
        ],
      ),

      child: SafeArea(
        top: false, //
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: "Início",
              active: paginaAtiva == 'inicio',
              onTap: () {
                if (paginaAtiva != 'inicio') Navigator.pushReplacementNamed(context, '/geral');
              },
            ),
            _NavItem(
              icon: Icons.emoji_events,
              label: "Startups",
              active: paginaAtiva == 'startups',
              onTap: () {
                if (paginaAtiva != 'startups') Navigator.pushReplacementNamed(context, '/catalogo');
              },
            ),
            _NavItem(
              icon: Icons.wallet,
              label: "Carteira",
              active: paginaAtiva == 'carteira',
              onTap: () {
                if (paginaAtiva != 'carteira') Navigator.pushReplacementNamed(context, '/carteira');
              },
            ),
            _NavItem(
              icon: Icons.show_chart,
              label: "Valorização",
              active: paginaAtiva == 'valorizacao',
              onTap: () {
                if (paginaAtiva != 'valorizacao') Navigator.pushReplacementNamed(context, '/valorizacao');
              },
            ),
            _NavItem(
              icon: Icons.store,
              label: "Negociar",
              active: paginaAtiva == 'negociar',
              onTap: () {
                if (paginaAtiva != 'negociar') Navigator.pushReplacementNamed(context, '/balcao');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF1482C7) : Colors.black,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? const Color(0xFF1482C7) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}