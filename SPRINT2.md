# Sprint 2 — Plano de Implementação

## Context

Sprint 1 entregou: 3 telas (Home, Map, Dialog), GPS funcional, 5 locais hardcoded em `lib/data/locations.dart`, e o Firebase já configurado (google-services.json / GoogleService-Info.plist presentes) mas **sem nenhum pacote Firebase no pubspec.yaml e sem firebase_options.dart**.

Sprint 2 objetivos:
- Integração com banco de dados (Firestore via Firebase Functions)
- Sistema de desbloqueio progressivo de ambientes
- Persistência de progresso do jogador

---

## O que o usuário precisa executar (comandos)

> Estes são os passos manuais que só o usuário pode fazer. O restante é código.

### 1. Instalar Firebase CLI (se não tiver)
```bash
npm install -g firebase-tools
firebase login
```

### 2. Instalar FlutterFire CLI (se não tiver)
```bash
dart pub global activate flutterfire_cli
```

### 3. Gerar firebase_options.dart
```bash
flutterfire configure
```
Selecione o projeto `teste-pedro-16cfe`. Isso cria `lib/firebase_options.dart`.

### 4. Inicializar Firebase Functions
```bash
firebase init functions
```
Quando perguntado: selecione **TypeScript**, ESLint: **sim**, instalar dependências agora: **sim**.
Isso cria o diretório `functions/` na raiz do projeto.

### 5. No console do Firebase (https://console.firebase.google.com → projeto teste-pedro-16cfe)
- **Firestore Database** → Criar banco (modo teste por enquanto)

### 6. Após o código estar pronto — seed, deploy e rodar o app
```bash
flutter pub get
dart run scripts/seed_firestore.dart   # popula os locais no Firestore
firebase deploy --only functions       # faz deploy das Functions
flutter run
```

### 7. Git (quando aprovar o resultado)
```bash
git add .
git commit -m "Sprint 2: Firebase Functions, desbloqueio progressivo e persistência"
```

---

## Arquitetura Sprint 2

### Estrutura Firestore
```
locations/{locationId}     - dados dos 5 ambientes (populado pelo seed)
players/{uid}/progress     - progresso do jogador (visitados + desbloqueados)
```

### Firebase Functions (backend)
O app Flutter **não acessa o Firestore diretamente**. Toda leitura e escrita passa pelas Functions:

| Function | Tipo | Descrição |
|---|---|---|
| `getLocations` | HTTPS Callable | Lê `/locations`, retorna lista de locais |
| `getOrCreatePlayer` | HTTPS Callable | Cria ou lê `/players/{uid}/progress` |
| `saveProgress` | HTTPS Callable | Persiste visitados e desbloqueados |
| `loadProgress` | HTTPS Callable | Retorna progresso do jogador |

### Fluxo de desbloqueio
- Ao iniciar o jogo: apenas o local de `sequence: 1` está desbloqueado
- Ao completar um local (DialogScreen → "Continuar"): chama `saveProgress` que marca como visitado e desbloqueia o próximo (`sequence + 1`)
- MapScreen sempre mostra o primeiro local desbloqueado e não visitado

---

## Arquivos a criar

| Arquivo | Descrição |
|---|---|
| `lib/firebase_options.dart` | Gerado pelo `flutterfire configure` (você executa) |
| `lib/models/player_model.dart` | Modelo de progresso do jogador |
| `lib/services/functions_service.dart` | Chama as Firebase Functions via `cloud_functions` |
| `lib/services/uid_service.dart` | Gera e persiste UUID local via `shared_preferences` |
| `functions/src/index.ts` | Implementação das 4 Firebase Functions |
| `scripts/seed_firestore.dart` | Script único para popular a coleção `/locations` |

## Arquivos a modificar

| Arquivo | O que muda |
|---|---|
| `pubspec.yaml` | Adiciona `firebase_core`, `cloud_functions`, `uuid`, `shared_preferences` |
| `lib/main.dart` | Inicializa Firebase antes de rodar o app |
| `lib/screens/map_screen.dart` | Chama `getLocations` e `loadProgress` via FunctionsService |
| `lib/screens/dialog_screen.dart` | Ao concluir local: chama `saveProgress` via FunctionsService |
| `lib/screens/home_screen.dart` | Botão "Continuar" se já houver progresso salvo |

`lib/data/locations.dart` → mantido como fallback local (dados hardcoded)

---

## Detalhes de implementação

### PlayerModel
```dart
class PlayerModel {
  final String uid;
  final Set<String> visitedLocationIds;   // IDs já visitados
  final Set<String> unlockedLocationIds;  // IDs desbloqueados
}
```

### FunctionsService (métodos principais)
```dart
// Usa FirebaseFunctions.instance.httpsCallable('nomeDaFunction')
- getLocations()              → chama function `getLocations`, retorna List<LocationModel>
- getOrCreatePlayer(uid)      → chama function `getOrCreatePlayer`
- saveProgress(uid, visited, unlocked) → chama function `saveProgress`
- loadProgress(uid)           → chama function `loadProgress`, retorna PlayerModel
```

### UidService
- `getOrCreateUid()` → lê UUID do `shared_preferences`; se não existir, gera com o pacote `uuid` e persiste — retorna string estável por dispositivo

### Firebase Functions — index.ts (estrutura)
```typescript
// functions/src/index.ts
export const getLocations = onCall(async () => { /* lê /locations */ });
export const getOrCreatePlayer = onCall(async ({ data }) => { /* cria/lê /players/{uid}/progress */ });
export const saveProgress = onCall(async ({ data }) => { /* escreve progresso */ });
export const loadProgress = onCall(async ({ data }) => { /* lê progresso */ });
```

---

## ⚠️ Atenção antes do seed

As coordenadas GPS em `lib/data/locations.dart` são **placeholder** (`-23.50XX, -46.60XX`).
**Corrija as coordenadas reais da PUC antes de rodar o seed**, senão o jogo não vai funcionar no campus.

---

## Verificação / Testes

1. Primeiro acesso: só o Estacionamento aparece como destino
2. Chegar no local (ou simular no emulador) → entrar no Dialog
3. Completar Dialog → Biblioteca desbloqueia, progresso salvo via Function
4. Fechar e reabrir o app → progresso restaurado, Biblioteca continua desbloqueada
5. Console Firebase → Firestore → `/players/{uid}/progress` mostrando os IDs visitados
6. Console Firebase → Functions → logs das chamadas confirmando execução
