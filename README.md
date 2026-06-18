# Riverpod Clean Architecture Monorepo

Este repositorio ejemplifica un diseño de arquitectura limpia (Clean Architecture) para micro-frontends utilizando **Dart Workspaces** y **Riverpod** para la inyección de dependencias (DI) desacoplada.

---

## Estructura del Monorepo

```directory
.
├── pubspec.yaml                 # Configuración raíz de Dart Workspaces
├── pubspec.lock                 # Lockfile unificado para todo el monorepo
├── packages/
│   └── mf_example/              # Módulo de Micro-Frontend (Independiente)
│       ├── lib/
│       │   ├── domain/
│       │   │   └── contracts/
│       │   │       ├── transfer_repository.dart  # Contrato (Clase abstracta)
│       │   │       └── fee_calculator.dart       # Contrato (Clase abstracta)
│       │   ├── config/
│       │   │   └── di/
│       │   │       └── money_transfer_contracts.dart # Providers que lanzan UnimplementedError
│       │   ├── presentation/
│       │   │   └── transfer_page.dart            # Interfaz de usuario del MF
│       │   └── mf_example.dart                   # Punto de exportación pública del MF
│       ├── test/
│       │   └── widget_test.dart                 # Tests unitarios con mocks/overrides
│       └── pubspec.yaml         # Configuración del MF (No depende de app_shell ni implementaciones concretas)
│
└── app_shell/                   # Aplicación Host / Orquestador (Shell)
    ├── lib/
    │   ├── domain/
    │   │   └── implementations/
    │   │       ├── transfer_repository_impl.dart # Implementación concreta del contrato
    │   │       └── fee_calculator_impl.dart      # Implementación concreta del contrato
    │   ├── config/
    │   │   └── di/
    │   │       ├── money_transfer_di.dart        # Configuración de overrides del módulo
    │   │       ├── auth_di.dart                  # Configuración de overrides (auth de ejemplo)
    │   │       ├── profile_di.dart               # Configuración de overrides (profile de ejemplo)
    │   │       └── app_di.dart                   # Centralizador de todos los DI del shell
    │   └── main.dart            # Entrada principal (inicializa ProviderScope con overrides)
    └── pubspec.yaml             # Configuración del Shell (Depende de mf_example)
```

---

## Configuración del Workspace

El monorepo utiliza **Dart Workspaces** (disponible a partir de Dart 3.5+). Esto permite:
1. Compartir una resolución única de dependencias en la raíz (`pubspec.lock`).
2. Vincular paquetes locales sin necesidad de configurar `dependency_overrides` repetitivos.

### Raíz (`pubspec.yaml`)
Define el espacio de trabajo apuntando a los subpaquetes miembros:
```yaml
name: _riverpod_clean_architecture
environment:
  sdk: ^3.13.0-222.0.dev
workspace:
  - app_shell
  - packages/mf_example
```

### Miembros (`app_shell/pubspec.yaml` y `packages/mf_example/pubspec.yaml`)
Cada miembro del workspace indica su pertenencia mediante:
```yaml
resolution: workspace
```

---

## ¿Cómo funciona la Inyección de Dependencias?

El objetivo principal de esta arquitectura es seguir el **Principio de Inversión de Dependencias (DIP)**. El Micro-Frontend (`mf_example`) es una biblioteca autónoma que define **qué necesita** para funcionar pero **no cómo se implementa**. El Host (`app_shell`) provee las implementaciones concretas al momento de arrancar la aplicación.

### 1. Definición de Contratos (Micro-Frontend)
En `packages/mf_example/lib/domain/contracts/` se crean interfaces puras de Dart:

```dart
abstract class TransferRepository {
  Future<void> transferMoney({
    required String fromAccount,
    required String toAccount,
    required double amount,
  });
}
```

### 2. Declaración de Providers Abstractos (Micro-Frontend)
En `packages/mf_example/lib/config/di/money_transfer_contracts.dart` se declaran los providers de Riverpod utilizando anotaciones `@riverpod`. Por defecto, estos providers lanzan un error `UnimplementedError` si algún widget intenta usarlos sin que hayan sido inyectados (sobreescritos):

```dart
@Riverpod(keepAlive: true)
TransferRepository transferRepository(Ref ref) {
  throw UnimplementedError(
    'transferRepositoryProvider must be overridden by the host app.',
  );
}
```

*Nota: Los widgets de presentación del micro-frontend consumen estos providers abstractos de forma transparente:*
```dart
final repository = ref.read(transferRepositoryProvider);
```

### 3. Implementación Concreta (Host / `app_shell`)
En `app_shell` se crean clases que heredan e implementan estos contratos, inyectando las herramientas concretas (HTTP clients, bases de datos locales, etc.):

```dart
import 'package:mf_example/mf_example.dart';

class TransferRepositoryImpl implements TransferRepository {
  final String apiService;

  TransferRepositoryImpl({required this.apiService});

  @override
  Future<void> transferMoney({ ... }) async {
    // Lógica concreta de llamada HTTP / API local
  }
}
```

### 4. Cableado / Sobreescritura (Host / `app_shell`)
En `app_shell/lib/config/di/money_transfer_di.dart`, definimos cómo se debe satisfacer el contrato asociándolo a su implementación real utilizando la API `.overrideWith` de Riverpod:

```dart
class MoneyTransferDI {
  static List<Override> get overrides => [
    transferRepositoryProvider.overrideWith(
      (ref) => TransferRepositoryImpl(
        apiService: ref.watch(transferApiServiceProvider),
      ),
    ),
  ];
}
```

Luego se centralizan todos los overrides de todos los módulos en un único listado (`app_di.dart`):

```dart
class AppDI {
  static List<Override> get overrides => [
        ...MoneyTransferDI.overrides,
        ...AuthDI.overrides,
        ...ProfileDI.overrides,
      ];
}
```

### 5. Inyección en Ejecución (`main.dart`)
Finalmente, al arrancar la aplicación en `app_shell/lib/main.dart`, se envuelve el árbol de widgets en un `ProviderScope` que recibe el listado consolidado de overrides:

```dart
void main() {
  runApp(
    ProviderScope(
      overrides: AppDI.overrides,
      child: const MainApp(),
    ),
  );
}
```

---

## Beneficios para las Pruebas Unitarias

Gracias al desacoplamiento de Riverpod, probar el micro-frontend de forma aislada es sumamente fácil. En el test widget de `packages/mf_example/test/widget_test.dart` no se requiere levantar el host ni sus servicios reales; simplemente inyectamos mocks locales al crear el entorno de pruebas:

```dart
testWidgets('Prueba de Transferencia', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transferRepositoryProvider.overrideWith((ref) => MockTransferRepository()),
        feeCalculatorProvider.overrideWith((ref) => MockFeeCalculator()),
      ],
      child: const MaterialApp(home: TransferPage()),
    ),
  );
  
  // Realizar interacción de test...
});
```
