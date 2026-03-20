# Destinos Turísticos App 🇳🇮

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white) 

Una aplicación móvil interactiva desarrollada en Flutter que permite visualizar, explorar y descubrir destinos turísticos de **Nicaragua**. La aplicación cuenta con capacidades generativas impulsadas por **Google Gemini AI**, almacenamiento local persistente (Offline-First) y visualización geoespacial interactiva mediante mapas de código abierto.

## 🚀 Características Principales

- **Descubrimiento Activo (IA):** Los destinos turísticos se generan y descargan dinámicamente consultando la IA de Gemini, asegurando recomendaciones únicas cada vez que no hay caché.
- **Búsqueda Dual:** Combina un filtrado de texto ultrarrápido sobre la base de datos interna local con un botón de "**Búsqueda Inteligente (IA)**" para consultar destinos completamente nuevos usando procesamiento de lenguaje natural.
- **Offline-First:** Uso intensivo de SQLite para almacenar localmente cualquier destino descubierto. La aplicación puede abrirse, navegar y leer descripciones o lugares anexos sin requerir conexión a internet.
- **Mapas Integrados:** Mapas interactivos con puntos de interés geo-localizados impulsados por `flutter_map` (OpenStreetMap).
- **Enriquecimiento de Imágenes Asíncrono:** Integra llamadas en segundo plano a la API de **Wikimedia** para compensar las limitaciones de renderizado multimedia de las IAs generativas con fotografías de calidad reales.
- **Puntos de Interés Cercanos (POIs):** En la vista de detalle, explora lugares adyacentes a un radio geográfico del destino actual.

## 🛠️ Stack Tecnológico

El proyecto está diseñado bajo los mejores estándares de Clean Architecture y la modularidad exigida a nivel empresarial.

* **Arquitectura:** Clean Architecture (Capas: `app`, `data`, `domain`, `presentation`).
* **Manejo de Estado UI:** [MobX](https://pub.dev/packages/mobx) y `mobx_codegen`.
* **Inyección de Dependencias (DI):** [GetIt](https://pub.dev/packages/get_it) para Service Location y registro de repositorios locales y remotos.
* **Networking (HTTP):** [Dio](https://pub.dev/packages/dio) conformando Datasources dedicados para APIs externas.
* **Persistencia Base de Datos:** [Sqflite](https://pub.dev/packages/sqflite) asegurando queries ricas y caché nativo.
* **Enrutamiento:** [GoRouter](https://pub.dev/packages/go_router) centralizando la navegación profunda por nombres semánticos.
* **Componentes de UI / Mapas:** `flutter_map` junto a `cached_network_image`.

## 📂 Arquitectura y Estructura del Código

El código base se organiza semánticamente evitando acoplabilidad y garantizando el flujo estricto y unidireccional de datos: `UI -> Store -> Repository (Domain/Data) -> Datasource`.

```text
lib/
├── app/                      # Infraestructura general y núcleo transversal (GoRouter, Tema visual, GetIt DI).
└── features/
    └── destinations/
        ├── data/             # Implementación. Datasources (Gemini, Local/Sqflite, Wikimedia) y Modelos/DTOs con serialización.
        ├── domain/           # Constantes e Interfaces de Repositorios Puros.
        └── presentation/     # UI organizada por páginas, stores de MobX reactivos y widgets reutilizables de feature.
```

## ⚙️ Configuración y Ejecución

Al trabajar con APIs de Gemini, el proyecto requiere claves de entorno (`.env`) no publicadas por seguridad.

### 1. Clonar y configurar las llaves
Crea un archivo llamado `.env` en la raíz del proyecto y agrega tus propias API Keys:
```env
OPENTRIPMAP_API_KEY=TuClaveDeOpenTripMapAqui
GOOGLE_GENERATIVE_AI_API_KEY=TuClaveDeGeminiAqui
```

### 2. Obtener Dependencias
```bash
flutter pub get
```

### 3. Generar Clases (MobX y JSON Serializable)
Asegurarse de reconstruir el estado observador de Mobx y cualquier DTO:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Lanzar la app
```bash
flutter run
```

## 🧪 Pruebas y Testing
El proyecto cuenta con una batería de pruebas de integración sobre los módulos cruciales técnicos:
```bash
flutter test
```
*Las pruebas engloban los repositorios, Mocking en peticiones del red (`dio`) y comportamiento de estado de `MobX`.*

---
*Desarrollado como reto técnico de resolución de problemas, Clean Architecture, gestión compleja de conectividad mixta e IA.* 🧠
