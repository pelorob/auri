# Installare auri sull'iPad

Serve: l'iPad, il PC Windows di casa, un Apple ID (quello dell'iPad va bene), il cavo USB-C, il Wi-Fi.

## 1. Attivare la Modalità sviluppatore (una volta sola)
Impostazioni → Privacy e sicurezza → **Modalità sviluppatore** → attiva → l'iPad si riavvia → conferma "Attiva".
Se la voce non c'è ancora, compare dopo il primo tentativo di installazione con SideStore.

## 2. Installare SideStore (una volta sola, con il PC)
Segui la guida ufficiale per Windows: https://docs.sidestore.io (sezione "Installation").
La procedura cambia nel tempo: fai sempre riferimento a quella pagina.
Alla fine sull'iPad trovi l'app **SideStore**, accedi con il tuo Apple ID.

## 3. Installare auri
1. Copia `auri.ipa` sull'iPad (iCloud Drive, email a te stessa, o "Condividi" dal PC).
2. Apri **SideStore** → scheda **My Apps** → **+** → scegli `auri.ipa`.
3. Attendi la fine: auri compare nella schermata Home.

## 4. Rinnovo automatico ogni settimana
L'app va rinnovata ogni 7 giorni. Facciamolo fare all'iPad:
1. Apri **Comandi** → **Automazione** → **+** → **Ora del giorno**.
2. Ore **5:00**, **Settimanale**, **domenica**. Scegli **Esegui immediatamente** (non "Chiedi").
3. Azione: cerca **SideStore** → **Refresh All** (o "Aggiorna tutte le app").
4. Lascia l'iPad **in carica e sul Wi-Fi** il sabato notte.

## 5. Se auri non si apre
- Apri **SideStore** → **My Apps** → **Refresh All**. Fatto: i dati ci sono ancora.
- Se non si apre neanche SideStore: serve il PC, ripeti il passo 2. I dati di auri restano.

## 6. Aggiornare auri a una nuova versione
Come al passo 3, con il nuovo `auri.ipa`: i dati restano.
