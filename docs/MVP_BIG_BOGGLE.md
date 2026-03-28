# MVP — Big Boggle móvil

## 1) Definición del MVP
El MVP debe permitir una ronda completa de juego para un solo jugador.

### Alcance incluido
- Tablero 5x5 generado con **25 dados predefinidos** (no alfabeto uniforme).
- Aleatoriedad por ronda: permutar ubicación de los 25 dados y luego elegir una cara aleatoria de cada dado (6 opciones).
- Rotación visual aleatoria por celda: 0°, 90°, 180° o 270°.
- Selección de letras adyacentes (8 direcciones posibles).
- Restricción: no repetir celda en la misma palabra.
- Botón para enviar palabra.
- Validación:
  - longitud mínima (>= 3 o 4; configurable),
  - existe en diccionario,
  - no repetida en la ronda.
- Puntaje por longitud.
- Timer de ronda (ej. 180s).
- Pantalla final con:
  - puntaje total,
  - lista de palabras válidas encontradas.

### Fuera de alcance inicial
- Multiplayer online.
- Rankings cloud.
- Matchmaking.
- Login social.
- Múltiples idiomas de diccionario en runtime.

## 2) Reglas base recomendadas
- El set de letras visible debe provenir de los dados oficiales definidos para el juego (25 dados x 6 caras, sin repetición de letras dentro de un mismo dado).
- La rotación de una letra cambia su orientación visual, no su valor para formar palabras.
- Adyacencia horizontal/vertical/diagonal.
- Una celda solo puede usarse una vez por palabra.
- Palabra mínima: 3 o 4 letras (definir antes de implementar).
- Scoring sugerido:
  - 3-4 letras: 1 punto
  - 5 letras: 2 puntos
  - 6 letras: 3 puntos
  - 7 letras: 5 puntos
  - 8+ letras: 11 puntos

## 3) Diseño técnico (agnóstico de engine)

## Módulos
1. `DiceSet`
   - define los 25 dados y sus 6 caras por dado (6 letras únicas por dado).
2. `BoardGenerator`
   - permuta los 25 dados entre las 25 posiciones,
   - toma una cara aleatoria por dado para la letra visible,
   - asigna una rotación visual aleatoria por celda (0/90/180/270).
3. `PathValidator`
   - comprueba que la secuencia de celdas es adyacente y no repetida.
4. `WordValidator`
   - normaliza palabra,
   - consulta diccionario,
   - evita duplicados.
5. `ScoringService`
   - calcula puntos por longitud.
6. `RoundController`
   - controla inicio/fin de ronda y timer.
7. `GameState`
   - snapshot del estado para UI y guardado,
   - incluye `die_id`, `face_letter` y `rotation_degrees` por celda.

## Datos
- `dice_set_big_boggle.json` (25 dados x 6 letras por dado).
- `dictionary_es.txt` (una palabra por línea).
- `game_config.json` (duración, tamaño tablero, largo mínimo).

## 4) Plan de implementación por fases

### Fase A — Núcleo sin UI
- [ ] Implementar `DiceSet` (25 dados x 6 caras, sin repetición de letras dentro de un mismo dado).
- [ ] Implementar modelo de tablero y coordenadas con metadatos de `die_id` y rotación.
- [ ] Implementar adyacencia y validación de ruta.
- [ ] Implementar scoring.
- [ ] Pruebas unitarias de reglas.

### Fase B — UI jugable mínima
- [ ] Dibujar tablero 5x5.
- [ ] Permitir arrastre/tap para construir palabra.
- [ ] Mostrar palabra en curso y feedback de error.
- [ ] Botón "Enviar" y lista de palabras aceptadas.

### Fase C — Ronda completa
- [ ] Timer visible.
- [ ] Fin automático al terminar tiempo.
- [ ] Pantalla de resultados.
- [ ] Botón "Jugar de nuevo".

### Fase D — Pulido inicial
- [ ] Mejoras visuales y animaciones simples.
- [ ] Sonido básico (aceptada/rechazada/fin).
- [ ] Persistencia de mejor puntaje local.

## 5) Checklist de aprendizaje (Codex + desarrollo)
- [ ] Separar reglas puras de UI.
- [ ] Escribir al menos 1 test por regla principal.
- [ ] Hacer commits pequeños por feature.
- [ ] Ejecutar pruebas antes de cada commit.
- [ ] Documentar decisiones de diseño.

## 6) Siguiente entrega sugerida
Crear la estructura del proyecto en el motor elegido e implementar **solo Fase A** con tests verdes.


## 7) Estado de implementación actual
Base de Fase A creada en Godot 4 con scripts de núcleo y test runner en `godot/tests/run_tests.gd`.

Próximo paso recomendado: integrar estos módulos en una escena jugable mínima (Fase B).
