# El arquero del claro

Juego de arquería en primera persona para Windows, con veinte blancos. Los impactos te dan savia para mejorar tu arquero. El quinto árbol se parte en dos y el décimo tiene tres puntos débiles que se activan por turno. Desde el décimo, los troncos tienen corteza más oscura. Elegís una carta al romper los blancos 5, 10 y 15. La vuelta termina cuando rompés el 20. Podés cambiar entre español e inglés desde los menús.

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

**Primera vuelta.** Empezás con 24 flechas. Buscá a Pipo, el ovejero sentado a la izquierda del taller, entre el pino y el sendero. Acercate y apretá **E** para abrir el árbol de mejoras a pantalla completa. Comprá el primer nivel de daño gratis en el centro del mapa. El arco inicial pasa de 10 a 12 de daño. Cada 8 puntos de vida que le quitás al blanco ganás 1 de savia. Si un impacto le quita 12, cobrás 1 y los otros 4 puntos cuentan para la siguiente.

El taller cuesta 17 de savia. Produce 1,25 flechas por segundo y lanza tandas de tres. Seguí el vuelo y acercate al atado para recogerlo. Si el carcaj se llena, el resto queda en el suelo.

La huella te guía a Pipo hasta la primera compra o hasta los 90 segundos de juego activo. Después, al acercarte y mirarlo, sigue apareciendo la tecla de interacción. Durante los primeros diez minutos la mira también puede señalar un atado cuando te hacen falta flechas. Después, un atado que lleva al menos 90 segundos sin recoger puede recibir un aviso de ocho segundos. Las primeras cinco recogidas muestran la cantidad obtenida. Todas actualizan el carcaj y suenan a flechas acomodándose.

A la derecha del sendero está **Brizno**, el mensajero alado. Al acercarte aparece la opción de hablar. Sus relatos cambian con lo que pasa en el claro y podés seguir una charla al reabrir el juego. Para escribirle más diálogos, editá [sus charlas bilingües](assets/charlas_de_brizno.tres) en el Inspector.

El Atlas de Pipo ocupa toda la pantalla. Pasá el mouse o enfocá un nodo con el teclado para ver su ficha. Cada compra revela los vecinos y otro tramo del dibujo. Al completar todos los niveles se destaca el dibujo del arco y el carcaj. **Buena racha** cuesta 190 de savia y habilita el combo. El décimo nivel de daño cuesta 1.250 y permite soltar hasta tres flechas a la vez. Después del arco largo podés comprar **Lluvia de flechas** por 3.200 para que caigan otras tres por cada flecha que sueltes.

La **Ballesta del claro** se compra siguiendo la Rueda de savia y cuatro engranajes del taller. Con munición en su depósito dispara sola mientras buscás flechas o apuntás con el arco. En cada resumen, **Registro de la vuelta** muestra cuánto duró cada blanco y compara tus tiempos por acto y de la demo completa con tus récords locales. El tiempo se mide hasta el golpe que rompe el blanco. Empezar de nuevo conserva los récords.

En los blancos 6 a 9 y 11 a 20, acertar con el arco a la diana temporal devuelve hasta tres flechas al carcaj. La mejora **Semillas aladas** habilita tandas de tres semillas. Cada acierto deja cuatro flechas y completar la tanda duplica el premio total a 24. Los números de daño siguen el lugar del impacto al girar la cámara.

Al terminar una vuelta, el registro muestra el tiempo hasta romper el blanco 20, las compras al entrar al 10 y el daño por fuente. Al cambiar de ventana el claro sigue en marcha por defecto. Podés activar **Ajustes → Vista y lectura → Pausar al cambiar de ventana**. Durante el juego en segundo plano avanzan el taller y los dos relojes. Una pausa manual detiene la simulación y solo suma al total mientras la ventana está en primer plano.

**Probar los sonidos del arco.** En **Ajustes → Sonido**, elegí por separado la suelta de cuerda y el impacto. En un perfil nuevo se escuchan **Cuerda y fibra** y **Dardo 1 · golpe sordo**. Probá también **Dardo 3 · golpe corto**. Usá **Escuchar** para aislar cada sonido o **Ráfaga** para oír el par a alta cadencia. Las seis grabaciones de Freesound se incluyen en el ejecutable. [Grabaciones y créditos](assets/audio/freesound/CREDITOS.md)

**Guardar y continuar.** Podés guardar desde pausa. También se guardan las compras, los cambios de blanco y de fase y las recompensas. En el menú de inicio, **Continuar** recupera la partida. Si cerraste mientras elegías la recompensa, vuelven las mismas tres cartas. Si terminaste la versión de diez blancos, desde su resumen podés continuar al 11. Durante la pausa y con el juego cerrado se detienen el reloj de juego activo y el taller.

[Árbol, precios y opciones para la demo](docs/arbol-de-la-demo.md) · [Catálogo de mejoras potenciales](docs/catalogo-de-mejoras-potenciales.docx) · [Comparar 16 tipografías para el Atlas](docs/atlas-tipografias/index.html)

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

El diseño de campaña, el catálogo de mejoras y el plan de producción están enlazados desde el [PRD](docs/PRD.md). Las [próximas tareas](docs/proximas-tareas.md) incluyen las mejoras del taller y del salto, los efectos de combate y la prueba de duración.

El [flujo de integración del repositorio](AGENTS.md) se aplica a todas las contribuciones.
