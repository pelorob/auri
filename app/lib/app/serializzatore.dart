/// Esegue i compiti uno alla volta, nell'ordine in cui arrivano.
/// Un compito fallito non blocca i successivi.
class Serializzatore {
  Future<void> _coda = Future.value();

  Future<void> esegui(Future<void> Function() compito) {
    final risultato = _coda.then((_) => compito());
    _coda = risultato.catchError((_) {});
    return risultato;
  }
}
