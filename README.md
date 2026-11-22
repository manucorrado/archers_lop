# El arquero del claro

Juego de arquería en primera persona para Windows, con diez blancos y dos jefes. Los impactos te dan savia para mejorar tu arquero. El quinto blanco se parte en dos. Cuando rompés ambas mitades, elegís una recompensa y podés continuar al sexto blanco desde el resumen. El décimo tiene tres puntos débiles que se activan por turno. Podés cambiar entre español e inglés desde los menús.

## Jugar en Windows

Abrí [ElArqueroDelClaro.exe](build/windows/ElArqueroDelClaro.exe) y elegí **Entrar al claro**. El ejecutable local de 64 bits incluye el juego. También podés importar [project.godot](project.godot) en Godot 4.7.2 estándar y pulsar **F6** sobre la escena principal o **F5** desde el editor.

| Control | Acción |
|---|---|
| WASD y ratón | Caminar y mirar |
| Espacio | Saltar. Con la mejora de salto, mirar hacia un atado cercano al saltar te lleva hasta él |
| Clic izquierdo / mantener | Soltar una flecha / repetir el disparo |
| Botón derecho mantenido | Acercar la mira |
| 1, 2, 3 o la rueda del mouse | Equipar el arco de rama, el rápido o el largo, entre los comprados |
| E cerca de Pipo | Abrir las mejoras. E o Esc para volver al claro |
| E cerca de Brizno | Hablar con el mensajero o pasar de página. Esc cierra la charla |
| E junto a la ballesta | Pasar hasta ocho flechas del carcaj al depósito. Siempre te quedan al menos cuatro para el arco |
| Clic izquierdo / derecho en un nodo | Comprar un nivel / devolver un nivel después de desbloquear los reembolsos |
| Rueda sobre el árbol / arrastrar el fondo | Acercar o alejar el dibujo / recorrerlo. Inicio recupera la vista completa |
| R cerca de Pipo | Acariciarlo después de desbloquear la mejora |
| F cerca del nudo | Golpear con la rama. Con el carcaj vacío, el golpe puede desprender cuatro flechas |
| Esc | Pausar y acceder al guardado, los ajustes y la opción de empezar de nuevo |

**Primera vuelta.** Empezás con 24 flechas. Buscá a Pipo, el ovejero sentado bajo el pino a la izquierda del taller, y apretá **E**. Pasá el mouse por el centro del árbol y comprá el primer nivel de daño gratis. El arco inicial pasa de 10 a 12 de daño. Cada 8 puntos de vida que le quitás al blanco ganás 1 de savia. Si un impacto le quita 12, cobrás 1 y los otros 4 puntos cuentan para la siguiente.

El taller cuesta 17 de savia. Produce 1,25 flechas por segundo y lanza tandas de tres. Seguí el vuelo y acercate al atado para recogerlo. Si el carcaj se llena, el resto queda en el suelo.

La guía de primeros pasos te indica cuándo disparar y te ayuda a encontrar a Pipo y las flechas del taller. Se retira cuando volvés a disparar tras recoger un atado. Podés desactivarla en Ajustes. A la derecha del sendero está **Brizno**, el mensajero alado. Al acercarte aparece la opción de hablar. Sus relatos cambian con lo que pasa en el claro y podés seguir una charla al reabrir el juego. Para escribirle más diálogos, editá [sus charlas bilingües](assets/charlas_de_brizno.tres) en el Inspector.

Cada compra revela los nodos vecinos y otro tramo del dibujo. Las mejoras iniciales suman daño o cadencia según la base del arco. En daño 10 salen hasta tres flechas por disparo. Más afuera aparecen los multiplicadores de daño y los disparos adicionales por segundo. La compra **Buena racha** activa el combo y su prima de savia.

La **Ballesta del claro** se compra siguiendo la Rueda de savia y cuatro engranajes del taller. Con munición en su depósito dispara sola mientras buscás flechas o apuntás con el arco. En cada resumen, **Registro de la vuelta** muestra cuánto duró cada blanco y compara tus tiempos por acto y de la demo completa con tus récords locales. El tiempo se mide hasta el golpe que rompe el blanco. Empezar de nuevo conserva los récords.

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
