# El arquero del claro

Prototipo de arquería incremental en primera persona. Rompé tres nudos, gastá la savia de los impactos y construí un taller que deja haces de flechas en el claro. La partida termina en el tercer nudo y se puede repetir desde el resumen. Los menús permiten cambiar entre español e inglés.

## Jugar en Windows

Abrí [ElArqueroDelClaro.exe](build/windows/ElArqueroDelClaro.exe) y elegí **Entrar al claro**. El ejecutable local de 64 bits incluye el juego. También podés importar [project.godot](project.godot) en Godot 4.7.2 estándar y pulsar **F6** sobre la escena principal o **F5** desde el editor.

| Control | Acción |
|---|---|
| WASD y ratón | Caminar y mirar |
| Clic izquierdo / mantener | Soltar una flecha / repetir el disparo |
| Botón derecho mantenido | Acercar la mira |
| Tab | Abrir o cerrar las mejoras |
| F cerca del nudo | Golpear con la rama. Con el carcaj vacío, el golpe puede desprender cuatro flechas |
| Esc | Pausar, reanudar o reiniciar |

**Primera vuelta.** Empezás con 24 flechas. Después de seis impactos al cuerpo, abrí las mejoras y comprá **Pulso de madera** por 4 de savia. El siguiente impacto en el primer nudo hace 12 de daño. En el segundo nudo podés construir el **Taller de flechas** por 17. Mientras jugás, el taller produce 1,5 flechas por segundo. Acercate al haz frente a la bandeja, a la izquierda del punto de partida. Si el carcaj está lleno, el excedente espera en el suelo. Las mejoras y la pausa detienen el reloj.

Esta entrega sirve para probar puntería, cadencia y recogida. El desenlace muestra tus resultados. Cada nueva sesión de juego comienza en el primer nudo. El idioma se conserva entre sesiones.

## Cambiar un asset desde el editor

Abrí [la escena del pino](assets/pino.tscn), seleccioná **Pino** en el árbol de escena y usá los grupos **Silueta** y **Paleta** del Inspector. Cambiá semilla, altura, anchura o color para ver la copa actualizarse en el visor. Guardá y pulsá **F5** para ver el resultado en los cinco pinos que usan ese modelo en el claro. Para conservar otra variante por separado, usá **Guardar escena como**.

## Verificar y exportar

Con Godot 4.7.2 en el PATH, la prueba recorre la partida con entradas de teclado y ratón, compra mejoras, recoge flechas y reinicia tras el tercer nudo.

```powershell
godot --headless --path . --fixed-fps 60 --script res://tests/prototype_smoke.gd
```

Para regenerar el ejecutable, instalá las plantillas de exportación correspondientes a tu versión de Godot. El preset **Windows Desktop** empaqueta los recursos dentro del ejecutable.

```powershell
New-Item -ItemType Directory -Force build/windows
godot --headless --path . --import
godot --headless --path . --export-release "Windows Desktop" build/windows/ElArqueroDelClaro.exe
```

El diseño de campaña, el catálogo de mejoras y el plan de producción están enlazados desde el [PRD](docs/PRD.md).

El [flujo de integración del repositorio](AGENTS.md) se aplica a todas las contribuciones.
