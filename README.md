# El arquero del claro

Juego de arquería en primera persona para Windows. El primer acto tiene cinco blancos de madera. Cada impacto te da savia para comprar mejoras y construir un taller de flechas. El quinto blanco se parte en dos a mitad de la pelea. Cuando rompés las dos mitades, elegís una mejora entre tres y ves el resultado de tu partida. Podés cambiar entre español e inglés desde los menús.

## Jugar en Windows

Abrí [ElArqueroDelClaro.exe](build/windows/ElArqueroDelClaro.exe) y elegí **Entrar al claro**. El ejecutable local de 64 bits incluye el juego. También podés importar [project.godot](project.godot) en Godot 4.7.2 estándar y pulsar **F6** sobre la escena principal o **F5** desde el editor.

| Control | Acción |
|---|---|
| WASD y ratón | Caminar y mirar |
| Clic izquierdo / mantener | Soltar una flecha / repetir el disparo |
| Botón derecho mantenido | Acercar la mira |
| 1, 2 o la rueda del mouse | Cambiar entre los arcos comprados |
| Tab | Abrir o cerrar las mejoras |
| F cerca del nudo | Golpear con la rama. Con el carcaj vacío, el golpe puede desprender cuatro flechas |
| Esc | Pausar y acceder al guardado, los ajustes y la opción de empezar de nuevo |

**Primera vuelta.** Empezás con 24 flechas. Después de seis impactos al cuerpo, abrí las mejoras y comprá **Pulso de madera** por 4 de savia. El siguiente impacto en el primer nudo hace 12 de daño. En el segundo nudo podés construir el **Taller de flechas** por 17. Mientras jugás, el taller produce 1,5 flechas por segundo. Acercate al haz frente a la bandeja, a la izquierda del punto de partida. Si el carcaj está lleno, el excedente espera en el suelo. Las mejoras y la pausa detienen el reloj.

En el tercer blanco podés comprar una descarga que se activa cada ocho aciertos. En el cuarto se habilita un arco que dispara más rápido y consume más flechas por segundo. Ambos requieren la primera mejora de daño.

**Guardar y continuar.** Podés guardar desde pausa. El juego también guarda las compras, el cambio de blanco, la división del último tronco, la caída de su primera mitad y la elección final. En el menú de inicio, **Continuar** recupera la posición y la mira. Si cerraste mientras elegías la recompensa, vuelven las mismas tres cartas. Durante la pausa y con el juego cerrado se detienen el reloj y el taller. Empezar de nuevo requiere confirmación y conserva los ajustes.

## Cambiar un asset desde el editor

Abrí [el pino](assets/pino.tscn) o [el atado de flechas](assets/haz.tscn) en Godot. Seleccioná la raíz y cambiá la silueta en el Inspector. El pino permite variar semilla, altura y ancho. El atado permite cambiar la cantidad de flechas dibujadas, el largo y la apertura. La cantidad que recoge el jugador depende de las flechas que haya en el suelo.

En [la receta de la flecha](assets/flecha.tres) podés ajustar las plumas y la punta. Para cambiar un color en varias piezas a la vez, editá [la paleta del claro](assets/paleta_claro.tres). Usá **Guardar escena como** para conservar variantes independientes. Asigná la escena nueva a uno de los espacios del [kit del claro](assets/kit_claro.tres) y pulsá **F5** para verla en la partida.

Para pedir una corrección puntual, sacá una captura desde donde lo viste al jugar. Marcá la pieza y escribí el cambio que querés, por ejemplo «acortar esta punta» o «que se distinga esta mitad del tronco».

## Verificar y exportar

Con Godot 4.7.2 en el PATH, ejecutá las pruebas en PowerShell. Usan perfiles temporales para conservar la partida personal.

```powershell
.\tests\run-tests.ps1
```

Para regenerar el ejecutable, instalá las plantillas de exportación correspondientes a tu versión de Godot. El preset **Windows Desktop** empaqueta los recursos dentro del ejecutable.

```powershell
New-Item -ItemType Directory -Force build/windows
godot --headless --path . --import
godot --headless --path . --export-release "Windows Desktop" build/windows/ElArqueroDelClaro.exe
```

El diseño de campaña, el catálogo de mejoras y el plan de producción están enlazados desde el [PRD](docs/PRD.md).

El [flujo de integración del repositorio](AGENTS.md) se aplica a todas las contribuciones.
