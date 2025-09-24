import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Mapper infra: construye LedgerModel desde cualquier Map (dinámico),
/// normalizando claves y listas para evitar listas vacías por tipos.
class LedgerModelMapper {
  /// Construye un LedgerModel desde un Map potencialmente dinámico.
  static LedgerModel fromAnyMap(Map<dynamic, dynamic> any) {
    // 1) Normaliza clave->String
    final Map<String, dynamic> j = any.map(
      (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
    );

    // 2) Normaliza listas de movimientos
    List<FinancialMovementModel> parseMovList(dynamic v) {
      final List<dynamic> raw = (v is List) ? v : const <dynamic>[];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> e) => Map<String, dynamic>.from(e))
          .map(FinancialMovementModel.fromJson)
          .toList();
    }

    // 3) Extrae campos (sin depender de Utils para listas)
    final String name = (j[LedgerEnum.nameOfLedger.name] ?? '').toString();

    final List<FinancialMovementModel> income = parseMovList(
      j[LedgerEnum.incomeLedger.name],
    );

    final List<FinancialMovementModel> expense = parseMovList(
      j[LedgerEnum.expenseLedger.name],
    );

    return LedgerModel(
      nameOfLedger: name,
      incomeLedger: income,
      expenseLedger: expense,
    );
  }

  /// (opcional) ida -> json (puedes seguir usando m.toJson() si prefieres)
  static Map<String, dynamic> toMap(LedgerModel m) => m.toJson();
}
