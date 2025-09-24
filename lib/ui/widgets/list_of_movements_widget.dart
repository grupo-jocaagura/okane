import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'movement_widget.dart';

class ListOfMovementsWidget extends StatefulWidget {
  const ListOfMovementsWidget({required this.ledgerModel, super.key});

  final LedgerModel ledgerModel;

  @override
  State<ListOfMovementsWidget> createState() => _ListOfMovementsWidgetState();
}

class _ListOfMovementsWidgetState extends State<ListOfMovementsWidget> {
  late final Future<List<_MovementEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries(widget.ledgerModel);
  }

  /// Une ingresos y egresos, y los ordena por `createdAt` (descendente).
  Future<List<_MovementEntry>> _loadEntries(LedgerModel ledger) async {
    final List<_MovementEntry> entries = <_MovementEntry>[
      ...ledger.incomeLedger.map<_MovementEntry>(
        (FinancialMovementModel m) =>
            _MovementEntry(movement: m, isIncome: true),
      ),
      ...ledger.expenseLedger.map<_MovementEntry>(
        (FinancialMovementModel m) =>
            _MovementEntry(movement: m, isIncome: false),
      ),
    ];

    entries.sort(
      (_MovementEntry a, _MovementEntry b) =>
          b.movement.createdAt.compareTo(a.movement.createdAt),
    );

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_MovementEntry>>(
      future: _entriesFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<_MovementEntry>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error al cargar movimientos: ${snapshot.error}'),
              );
            }

            final List<_MovementEntry> entries =
                snapshot.data ?? <_MovementEntry>[];

            if (entries.isEmpty) {
              return const Center(child: Text('No hay movimientos.'));
            }

            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                final _MovementEntry e = entries[index];
                return MovementWidget(
                  movement: e.movement,
                  isIncome: e.isIncome,
                );
              },
            );
          },
    );
  }
}

/// Tupla tipada para transportar movimiento + tipo (ingreso/egreso).
class _MovementEntry {
  const _MovementEntry({required this.movement, required this.isIncome});

  final FinancialMovementModel movement;
  final bool isIncome;
}
