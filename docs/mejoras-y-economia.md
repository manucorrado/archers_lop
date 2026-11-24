# Mejoras y economía del arquero

**Decisión de diseño.** Una flecha sirve para disparar, para representar abundancia en el suelo y para alimentar un centinela. La savia paga las mejoras. El jugador decide entre seguir apuntando a una veta, desviarse para recoger un haz de flechas o cargar un puesto que seguirá haciendo daño mientras él se mueve.

## Qué se traduce del análisis

La referencia es el HTML aportado, *AMMO DUMP — In-Depth Game Analysis*, del 17 de noviembre de 2026. Los apartados *Mechanics*, *Upgrades*, *Pacing* y *Known unknowns* distinguen observaciones de reconstrucciones. Los nombres españoles, precios, ventanas, fórmulas y valores que siguen pertenecen al diseño del arquero.

| Evidencia en el HTML | Equivalencia jugable |
| --- | --- |
| Cuatro armas en secuencia y un cuchillo independiente. | Cuatro arcos que se conservan y se pueden alternar. El golpe de rama ocupa una acción propia y permite terminar cualquier nudo con el carcaj vacío. |
| El árbol se anuncia con 77 mejoras. Los contadores por nodo y el logro de comprar todos sus niveles sustentan la interpretación de 77 rangos. El informe desconoce el inventario exacto de nodos. | 22 nodos propios con 77 compras. Daño por disparo pasa a daño por flecha, cadencia a frecuencia de suelta y capacidad a tamaño de carcaj. El orden de compra cambia el recorrido. Todos los rangos son compatibles. |
| Proyectiles recogibles, seis máquinas de munición, doce torretas abastecibles y un logro por acumular munición en el suelo. | Haces de flechas con cantidad real, seis talleres de flechas y doce centinelas de arco. Una pila grande equivale a varios lotes recogibles. |
| Tres cartas entre 24 cada cinco cubos. Adrenaline acelera las armas un 50 %. El análisis infiere las familias de Motherlode y Gusher a partir de las imágenes. | Pulso de liebre reproduce el efecto de Adrenaline. Veta madre aumenta el ingreso y Manantial acelera los talleres por decisión de diseño. Los otros 21 dones se detallan más abajo. |
| Multiplicador con logro en ×6, dianas, cubos dorados y suministros. Su fórmula y las probabilidades están sin documentar. | Combo de atención, Diana de veta, Nudo áureo y Alijo del guardabosque. La puntería y la logística compiten por segundos. El combo añade savia al ingreso manual. |
| Efectos de rayo, tormenta, meteoros, ola de cuchillas, agujero negro y sol. El informe distingue seis tipos de evento, de los que cita lluvia de cubos y tormentas. | Seis fenómenos comprables. Los seis sucesos temporales del claro tienen otro calendario. Así se puede reconocer qué efecto compró el jugador y qué apareció durante la partida. |
| Blanco creciente, seis actos, jefe cada cinco, partida finita y desafío de menos de 90 minutos. | Treinta nudos. Los costes se anclan al hito de disponibilidad. El tiempo final y las rutas de compra incentivan volver a jugar. El análisis deja abiertos los umbrales precisos y la posibilidad de reembolso. |
| El HTML destaca el movimiento para recoger, abastecer y atender oportunidades. | El radio de recogida y la movilidad con flechas implementan esa necesidad. Son incorporaciones de esta adaptación. |

| Equipo de AmmoDump | Equipo del arquero | Efecto de AmmoDump | Fenómeno del claro |
| --- | --- | --- | --- |
| Pistola | Arco de rama | Rayo | Chispa de copa |
| MAC-10 | Arco recurvo | Tormenta | Tormenta de copas |
| Escopeta | Arco de abanico | Meteoros | Lluvia de bellotas |
| Arma alimentada por cinta | Arco de tejo repetidor | Ola de cuchillas | Hojas en hoz |
| Cuchillo | Golpe de rama | Agujero negro | Remolino de raíces |
| | | Sol | Sol del claro |

## Qué hace cada arco

El botón de tiro suelta una flecha al pulsar. Mantenerlo permite repetir a la cadencia del arco. En ajustes se puede alternar la repetición con una pulsación. El modelo confirma el tiro con un pulso de la cuerda y una estela breve. Cada impacto se resuelve sobre el primer blanco válido del recorrido. El golpe de rama funciona a corta distancia, una vez por segundo. Las cifras de la tabla se expresan antes del factor de potencia del nudo y de los bonos.

| Equipo | Disponible desde | Daño unitario | Sueltas/s | Flechas por suelta | Cuándo elegirlo |
| --- | --- | ---: | ---: | ---: | --- |
| Arco de rama | N1, equipado | 10 | 1 | 1 | Una suelta reconocible por pulsación. Permite aprender a apuntar y ahorrar flechas. |
| Arco recurvo | N4, compra | 11 | 2,5 | 1 | Mantiene el combo disparando seguido. Su consumo vuelve visible la utilidad del primer taller. |
| Arco de abanico | N12, compra | 15 | 1,1 | Hasta 3 | Una suelta cubre centro y flancos. Con dos flechas quedan centro y una lateral, con una queda el tiro central. Las tres pueden acertar al mismo nudo grande. |
| Arco de tejo repetidor | N22, compra | 18 | 4 | 1 | Mantiene un chorro de impactos concentrados. El abanico conserva su ventaja contra grupos laterales. |
| Golpe de rama | N1, acción independiente | 4 | 1 | 0 | Arranca cuatro flechas físicas al golpear un nudo con el carcaj vacío. Este desprendimiento tiene 4 s de espera, compartidos entre todos los blancos. |

Empezar con 24 flechas en un carcaj de 24. Cada rotura deja un haz de ocho junto al nudo. El taller entrega su producción en su propio zócalo. El jugador recoge por proximidad hasta completar el carcaj. El sobrante conserva su posición y cantidad. Una interacción frente a un centinela rellena su tolva dejando cuatro flechas de reserva personal. El puesto indica vacío, disponible o activo. La interfaz anticipa cuántas unidades va a transferir. Frente a un puesto lleno o sin excedente, el jugador conserva su carga. Un intento de disparo en vacío solo da la señal de falta de flechas.

## El árbol de 77 rangos

N es el número del nudo actual. Cada número en **N de cada rango** abre un rango, en el orden indicado. Comprar siempre exige el rango anterior del mismo nodo y los prerrequisitos de la tabla. Un prerrequisito sin número significa rango 1. La columna **%** determina el precio del rango a partir del presupuesto de su nudo de apertura. El precio queda fijo aunque se compre mucho después. La ficha permite comparar el valor actual y el próximo, el coste y la savia que quedará al confirmar. Cada compra es definitiva durante esa vuelta. El árbol se consulta y se compra con la simulación en pausa.

| ID | Nodo | N de cada rango | Prerrequisito | % | Beneficio por rango |
| --- | --- | --- | --- | ---: | --- |
| A1 | Pulso de madera | 1, 3, 6, 9, 12, 15, 18, 21, 24, 29 | Inicial | 20 | +20 % del daño base por flecha manual. Diez rangos dan ×3 al daño base. |
| A2 | Ritmo de suelta | 2, 6, 11, 17, 23 | A1 | 45 | +12 % de la cadencia base de todos los arcos. |
| A3 | Ojo de veta | 2, 9, 18 | A1 | 45 | El multiplicador de impacto manual en punto débil sube de ×1,5 en pasos de 0,25 hasta ×2,25. |
| A4 | Flecha de eco | 7, 13, 22 | A3 | 55 | Un impacto manual en punto débil alcanza un segundo blanco lateral válido en 8 m. Inflige 20/40/60 % del daño original. Un eco máximo por suelta. |
| A5 | Arco recurvo | 4 | A1 | 55 | Desbloquea el segundo arco y permite probarlo en el claro inmediatamente. |
| A6 | Arco de abanico | 12 | A5 | 75 | Desbloquea la suelta de hasta tres flechas. |
| A7 | Arco de tejo repetidor | 22 | A6 | 75 | Desbloquea el cuarto arco y su repetición concentrada. |
| L1 | Taller de flechas | 2, 6, 9, 13, 18, 23 | Inicial | 55 | Construye un taller en el siguiente de seis zócalos fijos. Cada uno produce 1,5 flechas/s. |
| L2 | Carcaj de viaje | 1, 4, 8, 15, 20 | Inicial | 35 | +16 plazas de carcaj. Capacidades de 24 a 104. |
| L3 | Rueda de savia | 3, 7, 12, 19, 24 | L1 | 45 | +20 % de la producción base de todos los talleres. |
| L4 | Recogida de hojas | 2, 8, 16 | L2 | 35 | +0,75 m al radio de recogida automática de 1,5 m. |
| L5 | Paso del porteador | 4, 10, 14, 20, 25 | L2 | 30 | +6 % de velocidad al caminar con cuatro o más flechas. El HUD muestra cuándo se activa. |
| C1 | Centinela de arco | 7, 9, 11, 13, 15, 17, 19, 20, 22, 24, 26, 28 | L1 | 60 | Construye un puesto en el siguiente de doce zócalos. Cada puesto parte vacío, acepta 12 flechas, gasta una cada 2 s e inflige 8 de daño base. |
| C2 | Marca del vigía | 9, 16, 23 | C1 | 45 | +30 % del daño base de la flecha del centinela. |
| C3 | Tolva de corteza | 8, 14, 19 | C1 | 35 | +8 plazas por tolva. Al máximo aloja 36 flechas por puesto. |
| C4 | Ronda compartida | 12, 21 | C3 | 60 | Una interacción abastece al puesto seleccionado y a uno/dos vecinos construidos. Llena primero el seleccionado, luego los más vacíos, hasta agotar el excedente transportado. |
| F1 | Chispa de copa | 3, 13 | A1 | 40 | Cada 8 sueltas manuales con acierto nace un rayo de 20/40 de daño base al nudo. |
| F2 | Tormenta de copas | 19, 24 | F1 | 55 | Cada tercera Chispa emite tres rayos adicionales de 30/60 de daño base al nudo. |
| F3 | Lluvia de bellotas | 21, 25 | F1 | 50 | Tras 15 s de combate activo caen cuatro bellotas de 50/100 de daño base. Repartirlas entre blancos válidos, con el nudo como destino por defecto. |
| F4 | Hojas en hoz | 22 | F2 | 60 | Cada 10 sueltas manuales con acierto, una ola daña una vez a cada blanco visible por 70 de daño base. |
| F5 | Remolino de raíces | 25 | F3 | 55 | Cada cuarta suelta manual que daña un punto débil atrae blancos secundarios durante 3 s y aplica 120 de daño base a cada uno y al nudo, una vez. |
| F6 | Sol del claro | 27 | F4 y F5 | 65 | Ilumina la copa cada 24 s de combate activo. Tras una señal de 1 s inflige 500 de daño base al nudo y 120 a cada blanco lateral válido. |

**Recuento.** Tiro contiene 24 rangos en 7 nodos, logística 24 en 5, automatización 20 en 4 y fenómenos 9 en 6. Total de **77 rangos en 22 nodos**.

Los centinelas apuntan al cuerpo del nudo o, cuando se divide, al lóbulo vivo más cercano. Se detienen durante transiciones sin blanco. Las dianas opcionales requieren tiro manual. Los secundarios de jefe admiten fenómenos y ecos cuando son vulnerables. Un eco, un centinela o un fenómeno puede causar daño y generar ingreso base, pero solo una suelta manual primaria alimenta los contadores de aciertos, ecos, fenómenos y combo. El reloj de combate activo avanza con el juego sin pausar, con blanco válido y algún acierto manual en los últimos 5 s. Al pausar se congelan todos los temporizadores.

## Economía y escala

**Ingresos.** El presupuesto base de un nudo es `B(n) = piso(20 × 1,5^(n−1))`. Desviar el 60 % entero al daño, `Q = piso(0,60 × B)`. Al infligir daño efectivo acumulado `d` de un total de vida `H`, entregar hasta `piso(Q × d/H)` y abonar únicamente el incremento desde el último pago. La rotura paga el resto, `B−Q`. Las partes de jefe comparten un único presupuesto de daño y rotura. El exceso sobre la vida restante, los escudos y las entidades de evento no consumen presupuesto de daño. Una transición de fase conserva el crédito ya entregado.

**Precios.** Para un rango que abre en el nudo `g`, cobrar `techo(B(g) × porcentaje / 100)` savias. Toda la economía monetaria usa enteros de 64 bits. Acumular las fracciones de bonos en un saldo fijo hasta alcanzar la siguiente unidad. Las monedas, compras, rotura y premios de eventos se confirman una sola vez por transacción, también al guardar y reabrir.

**Primera compra.** N1 tiene 160 de vida y paga 20 savias, de las cuales 12 vienen del daño. Tras seis flechas del arco de rama al cuerpo se han infligido 60 de daño y acreditado 4 savias. Comprar A1 cuesta 4 y el impacto siguiente pasa de 10 a 12 en ese nudo. Si el jugador solo compró A1, cierra N1 con 16 savias más las primas que haya ganado. L1 cuesta 17 en N2, lo que permite activar el primer taller durante ese nudo. A5 cuesta 37 en N4. Comprar daño, un taller y el recurvo antes del primer jefe es una ruta asequible.

**Oferta total.** Estos saldos permiten revisar cuánto puede comprar una partida sin primas. El coste considera todos los rangos abiertos hasta cada nudo, incluidos sus prerrequisitos. En el medio hay que priorizar ramas. Cerca del final se puede completar el árbol.

| Al romper | Ingreso base acumulado | Coste acumulado de todo lo abierto |
| --- | ---: | ---: |
| N5 | 263 | 197 |
| N10 | 2.262 | 2.491 |
| N15 | 17.468 | 21.857 |
| N20 | 132.959 | 179.363 |
| N25 | 1.009.993 | 1.590.730 |
| N29 | 5.113.306 | 3.408.815 |

**Vida y daño.** El factor de potencia del claro es `P(n) = 1,52^(n−1)`. Se actualiza al aparecer cada nudo y multiplica por igual tiro, golpe de rama, centinelas y fenómenos. Mostrarlo al comienzo de acto y en la ficha de equipo. Redondear el daño una vez por impacto después de aplicar factores. Dentro de una familia se suman los porcentajes de rango. Los bonos de dones multiplican la estadística resultante, salvo cuando la descripción concede unidades o segundos. La vida del nudo es `redondear(P(n) × DPS de referencia × segundos de referencia)`. Las dos series siguientes se leen de izquierda a derecha en cada acto. Los segundos incluyen el presupuesto de todas las fases de cada jefe. En un jefe, repartir ese total entre fases y partes.

| Nudos | DPS de referencia antes de P(n) | Segundos de referencia por nudo |
| --- | --- | --- |
| 1–5 | 10, 12, 15, 18, 28 | 16, 45, 60, 80, 130 |
| 6–10 | 36, 40, 42, 46, 50 | 70, 85, 95, 110, 165 |
| 11–15 | 55, 62, 68, 74, 85 | 95, 110, 120, 130, 190 |
| 16–20 | 92, 105, 115, 125, 140 | 110, 125, 140, 150, 210 |
| 21–25 | 150, 165, 190, 210, 230 | 120, 135, 150, 160, 210 |
| 26–30 | 245, 265, 280, 300, 320 | 130, 145, 160, 175, 230 |

N2 resulta en 821 de vida, N10 en 357.311 y N30 en 13.814.712.931. Usar enteros con signo de 64 bits para vida máxima y restante, daño confirmado y acumulados, también al guardarlos. Convertir cada impacto a entero redondeando al más cercano, con los medios hacia arriba, y descontar solo el menor valor entre el impacto y la vida vulnerable restante de su parte o fase. Repartir la vida del jefe entre sus partes con la última absorbiendo cualquier resto de redondeo. Cargar cada punto efectivo una sola vez al total del jefe y al canal que hizo el daño. Resolver impactos coincidentes en orden estable y cerrar una fase una sola vez. El exceso de un impacto que abre una fase nueva se descarta. En N30, asignar la primera mitad entera al umbral de la oferta y el resto al combate posterior. En cada fase hay una superficie alcanzable con el golpe de rama.

La suma de los tiempos de referencia es de 64 min 11 s de daño sostenido para esta propuesta. Recoger, abastecer y resolver fases aumenta el tiempo activo. Las compras y cartas cuentan para el tiempo de vuelta. Validar con dos rutas completas el objetivo de 2–4 horas hasta el 100 % y registrar cuándo se alcanza el desenlace en cada una. Registrar daño por canal, segundos con el carcaj vacío y duración por nudo. Un pico de tiempo con reservas llenas pide revisar vida o accesibilidad del punto débil. Un pico con producción suficiente y puestos vacíos pide revisar recogida y transferencia.

**Prueba de abastecimiento.** Un taller base sostiene 1,5 flechas/s frente al consumo máximo de 2,5 del recurvo. El jugador puede disparar por tandas, cambiar al arco de rama o construir un segundo taller. Al máximo, seis talleres con cinco rangos de Rueda producen 18 flechas/s. Doce centinelas consumen 6/s y el repetidor con A2 completo y Pulso de liebre consume 9,6/s. Quedan 2,4/s de margen bruto antes de contar viajes, inventarios y otros dones. La escena muestra qué puesto está sin carga y en qué zócalo quedó el excedente. Los talleres acumulan unidades fraccionarias internamente y emiten haces enteros. Las pilas se fusionan por zócalo y muestran su cantidad al acercarse.

## Atención, oportunidades y seis elecciones

El combo nace en ×1. Un acierto manual primario al cuerpo suma 0,05. Una suelta que alcanza una Diana de veta o un blanco lateral de oportunidad suma 0,25 en total. Resolver los impactos de abanico como una sola suelta a estos efectos. Tras 2,5 s sin aciertos, cae 0,5 por segundo hasta ×1. El máximo es ×6. Una carga con transferencia positiva concede 2,5 s de gracia una vez por entrega, con 8 s de espera global. Las pausas, elecciones y transiciones de jefe congelan la caída. Un fallo no resta un escalón, aunque el reloj sigue corriendo.

Al entregar la porción de ingreso base por daño manual, sumar una prima de `10 % × (combo−1)` sobre esa porción, usando el combo posterior al acierto. Usar la fracción de daño exacta atribuible a esa suelta y conservar los restos. El máximo es +50 %. La prima alimenta la savia, mientras que la vida, la bonificación de rotura y las flechas se calculan por separado.

La **Diana de veta** aparece desde N2. Es un área temporal del nudo que aplica el multiplicador de punto débil y cuenta para el combo. El **Nudo áureo** aparece a un lado desde N6 y paga `techo(0,08 × B(n))` al acertarle. El **Alijo del guardabosque**, disponible desde N8, se abre con un tiro y deja 12 flechas físicas junto al punto de caída. Estas oportunidades pueden aparecer entre sucesos. Las seis familias de suceso son Lluvia de semillas, Frente de tormenta, Ráfaga de polen, Migración de brotes, Floración dorada y Caravana de alijos. El PRD detalla su presentación. La oportunidad que expira se retira y sigue el combate. Un objetivo de oportunidad paga una sola vez.

Después de romper N5, N10, N15, N20 y N25, pausar el claro y mostrar tres dones distintos. En N30 detener el daño al cruzar la mitad de vida, ofrecer por sexta vez y aplicar el don antes de abrir la fase final. Los 24 diseños siguientes constituyen la bolsa de la edición completa. Elegir un don lo conserva hasta el desenlace y lo retira de futuras ofertas. Cada fila indica cuándo puede entrar en la bolsa. La primera oferta dispone de más de tres opciones aunque el jugador solo use su arco inicial.

| ID | Don | Efecto propuesto | Entra en la bolsa cuando… |
| --- | --- | --- | --- |
| D01 | Pulso de liebre | ×1,50 a la cadencia de todos los arcos. El coste por suelta se conserva. Equivale al efecto explícito de Adrenaline. | Desde el primer jefe. |
| D02 | Veta madre | +25 % al pago de rotura. Interpreta la familia económica de Motherlode. | Hasta la quinta oferta inclusive. |
| D03 | Manantial | +30 % a producción por taller. Interpreta la familia de producción de Gusher. | L1 comprado. |
| D04 | Corteza viva | +20 % al daño de cada flecha manual. | Desde el primer jefe. |
| D05 | Ojo de búho | +0,5 al multiplicador por punto débil manual. | Desde el primer jefe. |
| D06 | Tercera hoja | Cada tercera suelta con acierto consecutivo suma 40 % a su daño directo. Un fallo reinicia la cuenta. | Desde el primer jefe. |
| D07 | Golpe de savia | El golpe de rama inflige daño triple y desprende ocho flechas en vacío. Conserva los 4 s de espera. | Desde el primer jefe. |
| D08 | Carcaj profundo | +24 plazas de carcaj. | Desde el primer jefe. |
| D09 | Hojas imantadas | +2 m al radio de recogida. | Desde el primer jefe. |
| D10 | Paso ligero | +15 % a velocidad al caminar. | Desde el primer jefe. |
| D11 | Brote de recambio | Cada quinta suelta que consuma flechas devuelve una al carcaj, acertando o fallando. | Desde el primer jefe. |
| D12 | Cosecha doble | Los haces soltados al romper un nudo pasan de ocho a dieciséis flechas. | Hasta la quinta oferta inclusive. |
| D13 | Guarda de savia | Ganar una prima adicional del 10 % del pago base de daño manual con combo ×3 o superior. | Desde el primer jefe. |
| D14 | Aliento largo | +2 s a la espera antes de decaer el combo. | Desde el primer jefe. |
| D15 | Rastro dorado | +50 % a la recompensa del Nudo áureo. | Desde N6. Primera oferta elegible en N10. |
| D16 | Hoja ancha | +25 % al diámetro interactivo y visible de las Dianas de veta. | Desde N2. Primera oferta elegible en N5. |
| D17 | Provisiones del claro | Los alijos entregan 24 flechas. | Desde N8. Primera oferta elegible en N10. |
| D18 | Reserva del vigía | +12 plazas de tolva por centinela. | C1 comprado. |
| D19 | Ronda veloz | Tras transferir flechas, el centinela receptor dispara un 50 % más rápido durante 6 s. Otra carga positiva reinicia el tiempo. | C1 comprado. |
| D20 | Ojo compañero | El centinela gana +35 % de daño durante los 4 s que siguen a un acierto manual en punto débil. | C1 comprado. |
| D21 | Rayo mellizo | Cada segunda Chispa de copa añade un rayo de igual potencia. El rayo extra conserva su origen secundario. | F1 comprado. |
| D22 | Larga estación | El intervalo de Lluvia de bellotas baja de 15 a 11 s de combate activo. | F3 comprado. |
| D23 | Pleno sol | +40 % al daño de cualquiera de los seis fenómenos comprados. | Algún fenómeno comprado. |
| D24 | Trama de ramas | Si una suelta de abanico alcanza al menos dos blancos distintos, gana una flecha en el carcaj. | A6 comprado. |

Barajar los dones elegibles sin reemplazo con la semilla de partida y el índice de elección. En N30 ofrecer exclusivamente efectos utilizables en esa segunda mitad. Además de D02 y D12, retirar cartas que dependan de oportunidades suspendidas durante el jefe. Los bonos de savia entran solo si queda una compra útil y asequible antes del desenlace. Guardar los tres IDs antes de mostrarlos y confirmar elección y activación en la misma operación. Esto permite reabrir la pantalla sin volver a sortear ni perder una elección.

## Rutas de prueba y cierre

- **Tiro continuo.** Comprar A1, L1, A5 y A2, recoger una pila antes de entrar al primer jefe y reservar A3 para el punto débil. Anotar cuántos segundos se ganan con el recurvo cuando el taller da abasto, y cuántos se pierden si se ignora la producción.
- **Abastecimiento.** Abrir L1, L2, L3 y C1, conservar un arco de bajo consumo para cuando la reserva sea pequeña. En N7 una descarga de 12 flechas mantiene 24 s de autonomía de un centinela base. Comparar contra la ruta de tiro con iguales semilla, nudo y presupuesto.
- **Fenómenos.** Abrir A1 y F1, comprobar ocho sueltas con el arco de rama y reconocer la chispa por su efecto sobre el nudo. Más adelante combinar F1, F2 y F4, comparando el tiempo y el reparto de daño con el de una ruta con varios centinelas. Las fichas del árbol anticipan qué dispara cada fenómeno.
- **Partida completa.** El resumen muestra tiempo, nudo final, savia, rangos adquiridos sobre 77, seis dones elegidos, unidades producidas y daño por canal. Una nueva partida parte del arco de rama y del carcaj de 24, con tiempo personal y ajustes conservados. El récord local compara la misma modalidad. Se pueden completar todos los rangos en una sola partida y se puede terminar con rangos pendientes.
