# El arquero del claro

Juego de arquería en primera persona para Windows, con diez blancos y dos jefes. Los impactos te dan savia para mejorar tu arquero. El quinto blanco se parte en dos. Cuando rompés ambas mitades, elegís una recompensa y podés continuar al sexto blanco desde el resumen. El décimo tiene tres puntos débiles que se activan por turno. Podés cambiar entre español e inglés desde los menús.

## Jugar en Windows

Abrí [ElArqueroDelClaro.exe](build/windows/ElArqueroDelClaro.exe) y elegí **Entrar al claro**. El ejecutable local de 64 bits incluye el juego. También podés importar [project.godot](project.godot) en Godot 4.7.2 estándar y pulsar **F6** sobre la escena principal o **F5** desde el editor.

| Control | Acción |
|---|---|
| WASD y ratón | Caminar y mirar |
| Espacio | Dar un salto corto |
| Clic izquierdo / mantener | Soltar una flecha / repetir el disparo |
| Botón derecho mantenido | Acercar la mira |
| 1, 2 o la rueda del mouse | Cambiar entre los arcos comprados |
| Tab | Abrir o cerrar las mejoras |
| F cerca del nudo | Golpear con la rama. Con el carcaj vacío, el golpe puede desprender cuatro flechas |
| Esc | Pausar y acceder al guardado, los ajustes y la opción de empezar de nuevo |

**Primera vuelta.** Empezás con 24 flechas. Abrí el árbol con Tab, seleccioná **Daño por flecha** y elegí **Obtener gratis**. Tu arco pasa de 10 a 12 de daño base y se abren las primeras ramas. Daño y velocidad de ataque tienen diez niveles cada uno. En el segundo blanco podés construir el taller por 17 de savia. Produce 1,25 flechas por segundo y lanza tandas de tres a distintos puntos del claro. Seguí el vuelo y acercate al atado para recogerlo. Si el carcaj está lleno, el resto queda en el suelo.

En el tercer blanco podés comprar una descarga que se activa cada ocho aciertos. En el cuarto se habilita un arco que dispara más rápido y consume más flechas por segundo. Ambos requieren la primera mejora de daño.

**Guardar y continuar.** Podés guardar desde pausa. También se guardan las compras, los cambios de blanco y de fase y las recompensas. En el menú de inicio, **Continuar** recupera la partida. Si cerraste mientras elegías la recompensa, vuelven las mismas tres cartas. Si terminaste la versión anterior, en su resumen aparece **Continuar al blanco 6**. Durante la pausa y con el juego cerrado se detienen el reloj y el taller.

[Árbol, precios y opciones para la demo](docs/arbol-de-la-demo.md) · [Catálogo de mejoras potenciales](docs/catalogo-de-mejoras-potenciales.docx)

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
