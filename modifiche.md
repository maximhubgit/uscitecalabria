# Pianificazione Modifiche Cassa1

## Obiettivi
1. Login: un solo tasto con accesso anonimo, icona isola
2. Home: card saldo generale continuativo (verde/rosso), togliere confronti periodi
3. Rimuovere totale gestione registrazione vocale

## Sequenza Passaggi

### Passo 1: Rimuovere voci e modificare login
- [ ] Modificare `lib/ui/screens/auth/login_screen.dart`
  - Togliere i due tasti "Maxim" e "Francy"
  - Aggiungere un unico tasto con icona isola (Icons.landscape o Icons.terrain)
  - Mantenere accesso anonimo semplice

### Passo 2: Semplificare card saldo nella home
- [ ] Modificare `lib/ui/screens/home/home_screen.dart`
  - Semplificare `_buildTotalBalanceCard` per mostrare solo saldo generale
  - Colore verde se saldo >= 0, rosso se saldo < 0
  - Rimuovere confronti anno/mese/24m
  - Togliere il picker mese/anno (il saldo è continuativo)

### Passo 3: Rimuovere funzionalità vocale - Widget
- [ ] Rimuovere `lib/ui/widgets/voice_transaction_dialog.dart`

### Passo 4: Rimuovere funzionalità vocale - Service
- [ ] Rimuovere `lib/data/services/voice_transaction_service.dart`

### Passo 5: Rimuovere funzionalità vocale - AppDrawer
- [ ] Modificare `lib/ui/widgets/app_drawer.dart`
  - Rimuovere voce "Nuova transazione vocale"
  - Rimuovere import voice_transaction_dialog e voice_transaction_service

### Passo 6: Rimuovere funzionalità vocale - HomeScreen
- [ ] Modificare `lib/ui/screens/home/home_screen.dart`
  - Rimuovere quick action "Voce"
  - Rimuovere imports voice_transaction_dialog e voice_transaction_service

### Passo 7: Verifica e pulizia
- [ ] Eseguire `flutter analyze` per verificare problemi
- [ ] Testare l'app `flutter run -d edge`

## Note
- Il saldo diventa continuativo (tutte le transazioni, non più solo mensili)
- Il filtro del mese corrente deve essere rimosso
- Il calcolo del saldo nelle varie schermate deve considerare tutte le transazioni