# GibGobble

Proyecto inicial para construir una versión móvil inspirada en **Big Boggle** (word puzzle) y aprender desarrollo de juegos paso a paso con Codex.

## Objetivo
Construir un MVP jugable en móvil con:
- tablero 5x5 basado en 25 dados predefinidos (estilo Big Boggle),
- selección de letras adyacentes por gesto,
- validación de palabras contra diccionario,
- sistema de puntuación,
- ronda cronometrada y pantalla de resultados.

## Regla clave del tablero (realista)
La generación del tablero **no** debe tomar letras del alfabeto completo de forma uniforme.

Debe replicar la lógica de dados físicos:
- existen 25 dados, cada uno con 6 caras/letras predefinidas,
- cada dado debe tener exactamente 6 caras y sin letras repetidas dentro del mismo dado,
- en cada ronda se mezclan los 25 dados y se asignan aleatoriamente a las 25 posiciones,
- luego, para cada dado, se elige al azar una de sus 6 caras visibles,
- además cada celda aplica rotación visual aleatoria de `0°`, `90°`, `180°` o `270°`.

> La rotación afecta la presentación visual (dificultad de lectura), no la validez lingüística de la letra.

## Stack recomendado para empezar
Para priorizar aprendizaje y velocidad de prototipo:
- **Godot 4** (2D, export móvil, iteración rápida),
- lógica de reglas desacoplada de UI,
- diccionario local en archivo de texto.

> Nota: si prefieres Unity o Flutter, se puede migrar el plan manteniendo las mismas capas de arquitectura.

## Arquitectura base (conceptual)
1. **Core del juego**
   - reglas de adyacencia,
   - validación de rutas,
   - scoring,
   - control de tiempo.
2. **Estado de partida**
   - tablero actual,
   - palabra en construcción,
   - palabras encontradas,
   - puntaje y tiempo restante.
3. **UI móvil**
   - grilla 5x5,
   - feedback visual del trazo,
   - HUD (tiempo/puntaje),
   - pantalla de resumen.
4. **Datos**
   - diccionario,
   - configuración de ronda,
   - definición de dados (25 x 6 caras),
   - persistencia básica de récord.

## Roadmap corto
Revisa el detalle en [`docs/MVP_BIG_BOGGLE.md`](docs/MVP_BIG_BOGGLE.md).

## Cómo usar este repositorio ahora
1. Leer el documento de MVP y checklist.
2. Elegir motor final (Godot/Unity/Flutter).
3. Crear el primer esqueleto del proyecto con escenas/pantallas.
4. Implementar primero reglas puras y tests, luego UI.


## Estado actual (Godot 4)
Se creó una base inicial del proyecto en `godot/` enfocada en Fase A:
- `scripts/core/dice_set.gd`
- `scripts/core/board_generator.gd`
- `scripts/core/path_validator.gd`
- `scripts/core/word_validator.gd`
- `scripts/core/scoring_service.gd`
- `tests/run_tests.gd`
- `data/dice_set_big_boggle.json`

## Ejecutar tests de núcleo
Desde la carpeta `godot/`:

```bash
godot4 --headless --path . --script res://tests/run_tests.gd
```

Si tu sistema usa `godot` en lugar de `godot4`, reemplaza el comando.
