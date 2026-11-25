# Árbol de mejoras de la demo

La partida recorre veinte blancos. Elegís cartas en el 5, el 10 y el 15. El resumen final aparece cuando rompés el 20. La madera se oscurece desde el blanco 10. Para la prueba privada queda por medir cuánto agrega esta segunda mitad al tiempo de compras, diálogos y combate.

## Qué podés comprar

Pipo se sienta bajo el pino a la izquierda del taller. Acercate y apretá **E**. En el centro del mapa está el daño inicial gratis y a su alrededor están velocidad, precisión, taller y reembolso. Las compras descubren los vértices vecinos y van dibujando el arco, la flecha y el carcaj. Pasá el mouse por un nodo para ver qué hace, mové la rueda para acercarte a un tramo y arrastrá el fondo para recorrerlo. Las compras previas y la savia determinan qué podés comprar en cualquier blanco de la demo.

| Mejora | Necesitás tener | Precio por nivel en savia | Qué cambia |
|---|---|---|---|
| Daño por flecha | Desde el inicio | 0, 9, 9, 14, 21, 31, 46, 69, 103, 1.250 | Cada nivel suma el 20 % del daño base del arco. El arco de rama gana 2 por nivel. En el décimo salen hasta tres flechas en abanico con el daño completo de cada una. |
| Velocidad de ataque | Daño | 14, 21, 31, 46, 68, 103, 154, 231, 346, 346 | Cada nivel suma el 12 % de la cadencia base del arco equipado. |
| Arco rápido | Velocidad | 370 | Base de 11 de daño y 2,5 disparos por segundo. Con los diez niveles iniciales de velocidad llega a 5,5. |
| Arco largo | Arco rápido y los dos nodos de Suelta ágil que le siguen en la cuerda | 16.700 | Tercer arco. Base de 22 de daño y 2 disparos por segundo. Favorece el daño por flecha y comparte el mismo carcaj. |
| Ojo de veta | Daño | 14 | Acertar al punto débil pasa de ×1,5 a ×2 de daño. |
| Chispa de copa | Ojo de veta | 18 | Cada ocho aciertos, una descarga de 20 de daño base. |
| Golpe crítico | La primera Punta reforzada después de Chispa de copa | 24 | Cada disparo tiene un 10 % de probabilidad de duplicar el daño de las flechas de esa suelta. |
| Buena racha | Ojo de veta | 190 | Desbloquea el combo y su prima de savia. Un acierto común suma 0,05 y uno preciso suma 0,5. |
| Lluvia de flechas | Arco largo | 3.200 | Cada flecha que sale del carcaj llama otras tres al mismo lugar. Funciona con cualquiera de los arcos. |
| Tiro sostenido | Buena racha | 26 | A partir de la cuarta suelta seguida, cada flecha hace un 20 % más de daño mientras mantengas el ritmo. |
| Taller de flechas | Daño | 17 | El taller de la izquierda produce 1,25 flechas por segundo y lanza atados de tres a cuatro lugares del claro. |
| Rueda de savia | Taller | 21 | El taller pasa a producir 1,5 flechas por segundo. |
| Carcaj de viaje | Taller | 7, 24 | Capacidad de 24 → 40 → 56 flechas antes de aplicar la recompensa de carcaj. |
| Recogida de hojas | Carcaj | 11 | El radio de recolección pasa de 1,5 a 2,25 metros. |
| Paso del porteador | Carcaj | 21 | Caminás un 6 % más rápido mientras llevás cuatro flechas o más. |
| Salto al atado | Recogida de hojas | 32 | Mirá hacia un atado en el suelo y saltá para llegar hasta él. Al saltar en otra dirección conservás el salto libre. |
| Recuperar savia | Daño | 6 | El clic derecho devuelve un nivel de un nodo y te reintegra lo que pagaste. |
| Una caricia | Las cuatro Puntas reforzadas de la rama de reembolso y daño 10 | 28 | Acercate a Pipo y apretá **R**. Inclina la cabeza y mueve la cola. |

### Las mejoras de los tramos y sus extremos

En los tramos intermedios, cada vértice es una compra de un nivel. Cuanto más lejos queda de la raíz por su cadena de requisitos, mayor es su precio. El tooltip muestra el costo exacto. Dos mejoras del borde del dibujo ofrecen varios niveles en el mismo nodo.

| Mejora | Dónde aparece | Precio en savia | Qué cambia |
|---|---|---|---|
| Punta reforzada | 31 vértices | 21–1.071 por vértice | Suma 1 al daño de la flecha antes de aplicar los multiplicadores. |
| Suelta ágil | 36 vértices | 45–933 por vértice | Suma un 2 % de la cadencia base del arco. |
| Engranaje del taller | 24 vértices | 45–686 por vértice | El taller produce 0,025 flechas más por segundo. |
| Semillas aladas | Primer engranaje de la rama que baja de la Rueda de savia hacia el fondo del carcaj | 45 | Habilita tandas de tres semillas con caídas de 8, 9 y 10 segundos. Cada acierto deja cuatro flechas para recoger. Si acertás las tres, la última deja 16, lo que lleva la cosecha total a 24. El taller mantiene los 0,025 flechas/s de este engranaje. |
| Ballesta del claro | Después de los cuatro engranajes que bajan desde la Rueda hacia el extremo derecho de la flecha | 235 | Instala una ballesta a la derecha del sendero y suma otras 0,025 flechas/s al taller. |
| Potencia multiplicada | Extremo de la rama que pasa por Golpe crítico | 390, 820, 1.460 | Cada nivel multiplica el daño que ya tiene la flecha por 1,2. Los tres juntos aplican ×1,728. |
| Disparo adicional | Después del arco largo | 260, 320, 420, 550, 720, 930, 1.210, 1.560 | Suma un disparo por segundo por nivel, para cualquiera de los tres arcos. |

Al devolver un nivel conservás las otras compras. Para comprar otro nivel vuelven a contar los requisitos que tengas en ese momento. Los arcos comparten munición. Devolver capacidad con el carcaj lleno te deja gastar las flechas que ya cargaste. Los atados en el aire y en el suelo se conservan si devolvés el taller.

**Cargar la ballesta.** Acercate al depósito y apretá **E**. Cada toque pasa hasta ocho flechas, deja cuatro en el carcaj y respeta las doce plazas del depósito. La banderita baja indica que está vacío. La ballesta dispara una flecha cada dos segundos y hace ocho de daño base, multiplicados por la potencia del blanco. Sus tiros pagan savia por el daño efectivo. En el quinto blanco apunta a una mitad viva y en el décimo espera cuando hace falta acertar a la cavidad encendida. Si devolvés la mejora, recuperás las flechas que entran en el carcaj y el resto queda al pie del tronco.

## Ritmo y prueba de juego

Cada **8 puntos de vida que pierde un blanco** entran **1 de savia**. Importa cuánto daño recibió realmente. Si a una mitad le quedan 3 de vida y le pegás por 50, esos 3 puntos se acumulan para el próximo cobro. El sobrante pasa al siguiente blanco y se guarda al salir. Con Buena racha, los impactos manuales ganan además una prima que llega hasta un 50 % de su ingreso base cuando el combo alcanza ×6.

Hay **113 nodos, 141 niveles y 61.800 de savia** en compras. Sin primas, al entrar al décimo blanco habrás ganado **38.612 de savia**, el **62,5 %** del costo total. El ingreso base alcanza para comprar todo al quitarle aproximadamente el 52 % de la vida al jefe. El saldo visible depende de cuánto hayas gastado. Respecto de la versión 0.10, los blancos 11–19 tienen cien veces la vida y el 20 tiene mil veces la vida. El vigésimo empieza con 83.825.374.000 puntos. Al continuar una partida previa se conserva la fracción de vida que le quedaba al tronco.

En los blancos 6 a 9 y 11 a 20, acertar con el arco a la diana que aparece por unos segundos devuelve hasta **tres flechas** directamente al carcaj. La primera aparece al entrar al sexto blanco y dura siete segundos. Cada diana paga una vez, incluso con el disparo triple. Si quedan dos lugares, recuperás dos.

El combo aparece junto a la vida del blanco e indica cuándo empieza a bajar. Junto al carcaj podés ver cuántas flechas soltó el disparo triple y cuándo cae la lluvia. Con las dos mejoras y tres flechas en el carcaj, una suelta produce tres flechas en abanico y nueve adicionales desde arriba. Los huecos del jefe se abren con un acierto directo o un golpe de rama en la raíz correspondiente.

Al romper el blanco 15, elegís entre **Ojo de búho** (+0,5 al multiplicador del punto débil), **Paso ligero** (+15 % de velocidad al caminar) y **Cosecha doble** (16 flechas al pie de cada árbol roto).

Para la prueba privada, observá el primer cambio de táctica después de la carta del quinto blanco y qué hace el jugador cuando se queda sin flechas. En el registro de una partida nueva podés cotejar la duración de la vuelta con el tiempo activo, los niveles comprados y el saldo al entrar al décimo, y el daño efectivo de arco y ballesta.

## Qué queda para después

El [catálogo editable](catalogo-de-mejoras-potenciales.docx) conserva las 65 fichas de ideas y el orden de trabajo propuesto para las nuevas familias. Quedan para diseñar la frecuencia de blancos opcionales, los ecos de disparos, la quemadura con sus tres especializaciones, los tiros en el aire y los giros de 360°, las mejoras de la ballesta y el arco láser de fin de juego.

En el quinto blanco se mantienen las cartas de daño, cadencia y capacidad. La astilla adicional al apuntar, las ráfagas y la recarga de emergencia quedan como ideas para una progresión posterior, posiblemente ligada al prestigio. La actividad al costado del claro sigue abierta. Brizno es opcional. Sus nuevos diálogos y su posible vínculo con el prestigio quedan para después del MVP.
