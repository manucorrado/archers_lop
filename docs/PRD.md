# El arquero del claro

**Diseño de campaña y alcance de la demo**

Nombre de trabajo. Juego incremental activo de arquería, en primera persona, para una persona. La campaña transcurre en un claro de bosque construido con piezas voxel.

La demo jugable llega al décimo blanco y apunta a una primera vuelta de 15–20 minutos. La estimación del 5–15 % se refiere al contenido del juego completo. La cantidad de actos sigue abierta. Los actos posteriores al segundo, los centinelas y el final propuesto en este documento son hipótesis de campaña. La lista vigente de compras, requisitos y efectos está en el [árbol de la demo](arbol-de-la-demo.md).

| Para trabajar en… | Documento |
|---|---|
| Experiencia del jugador, alcance, reglas de los encuentros y criterios de producto | Este PRD |
| Equivalencias con AmmoDump, 77 rangos, 24 dones, munición y precios | [Catálogo de mejoras y economía](mejoras-y-economia.md) |
| Producción modular, recetas de variantes y validación en cámara | [Dirección de arte y assets voxel](arte-y-assets-voxel.md) |
| Hitos, dependencias, estimación, tareas y pruebas de salida | [Plan de producción](plan-de-produccion.md) |

## 1. El juego que queremos hacer

Un arquero llega a un claro tomado por un nudo de madera. Cada impacto descubre savia bajo la corteza. Con la primera savia compra potencia y levanta un taller que empieza a dejar haces de flechas en el suelo. Una hora después, el jugador circula entre montones de flechas, abastece una línea de centinelas y busca una veta en un tronco que le tapa el cielo. El arco que tiene en las manos sigue siendo la herramienta más rápida para aprovechar esa abertura.

La promesa es **pasar de disparar cada flecha a dirigir todo el claro, sin perder las ganas de apuntar**. El público principal disfruta comprar una mejora y enseguida sentir la diferencia. La segunda vuelta interesa a quien quiera optimizar la ruta de compras y batir su tiempo.

**Definiciones de producto.** Una persona a tiempo completo desarrolla el juego en Godot para Windows, con teclado y ratón. El proyecto no tiene un límite presupuestario ni una fecha comprometida. La campaña es individual y offline, en primera persona y con una arena continua. El récord se conserva en el equipo del jugador.

**Ediciones.** El prototipo N1–3 se prueba localmente. La hoja de ruta contempla una demo pública, acceso anticipado y la versión final en Steam e itch.io. El juego y sus materiales de tienda tendrán inglés y español. El rango de precio previsto para la versión final es de 1–2 €.

### Qué tomamos de la referencia

El punto de partida es el [análisis de AmmoDump facilitado para el proyecto](<C:/Users/Usuario/Downloads/ammo_dump_in_depth_analysis.html>), especialmente sus apartados sobre mecánicas, progresión, ritmo y límites de la evidencia.

| Hallazgo en el análisis | Decisión para el juego |
|---|---|
| Treinta blancos de tamaño creciente, un jefe y una elección cada cinco, final en una o dos horas | Probar bloques de cinco blancos en el mismo claro. Cada jefe cambia lo que conviene apuntar. El total de bloques se decidirá al desarrollar la campaña. |
| Cuatro armas con cadencias distintas y una herramienta cuerpo a cuerpo | Cuatro arcos con patrones reconocibles y un golpe de rama que permite recuperar flechas incluso al principio. |
| Munición en el suelo, seis máquinas y doce torretas que consumen munición | Los haces son inventario real. El arquero decide qué se lleva y qué entrega a los centinelas. Los puestos construidos permanecen visibles. |
| Árbol anunciado de 77 mejoras. Los contadores por nodo sugieren que son rangos. Tres cartas entre 24, con pocos textos exactos documentados | Árbol propio de 77 compras y baraja propia de 24 dones. El catálogo indica qué equivalencias son directas, cuáles son interpretaciones y qué efectos diseñamos. |
| Multiplicador, dianas, blancos dorados, suministros, seis sucesos y grandes efectos | Repartir la atención paga más savia. Los sucesos del claro interrumpen la rutina. Las compras de fenómenos dan poder duradero. |
| En el tramo final se superponen números, impactos, salud y retícula | La salud vive en el borde superior. Se agrupan los números y se reserva espacio visual alrededor de la veta, incluso con todos los puestos activos. |

Los nombres de los jefes finales, las fórmulas, el reparto de rangos y los textos de los dones de este proyecto son decisiones de diseño. Las tasas de logros que cita el análisis describen a los jugadores de la referencia en la muestra que consultó su autor. Nuestros criterios se medirán en pruebas propias.

## 2. Una vuelta por el claro

1. **Apuntar y soltar.** El primer nudo está frente al jugador, a distancia de tiro. Al impactar, se abre una grieta, baja la integridad y sube la savia. Se entiende el resultado incluso con los números de daño desactivados.
2. **Elegir una compra.** Acercarse al perro sentado y apretar la tecla de interacción abre el árbol. Cada icono detalla su requisito, precio, nivel y efecto al pasar el puntero o darle foco. El taller lanza atados que hay que ir a buscar.
3. **Administrar flechas.** El arquero recoge por proximidad. Puede tirar a una Diana de veta, guardar flechas en el carcaj o desviarse hasta un centinela para cargarlo. Mientras apunta a una oportunidad lateral, oye si el centinela sigue trabajando.
4. **Romper y seguir.** El nudo suelta un haz. En el mismo sitio crece otro más grande. El arco equipado, las compras, las existencias y los puestos continúan con el jugador.
5. **Elegir un don y cerrar la campaña.** Las roturas 5, 10, 15, 20 y 25 dan a elegir una de tres cartas. En el nudo 30 la sexta elección ocurre al abrir el núcleo, a media integridad, para poder usarla en el desenlace. La rotura 30 muestra tiempo de juego, mejor combo, rangos adquiridos y contribución de arco, centinelas y fenómenos.

**Una decisión en el segundo acto.** Te quedan doce flechas. El centinela junto al taller está vacío y acaba de aparecer un Nudo áureo al otro lado del tronco. Si la tolva tiene espacio, podés dejar ocho flechas en ella, quedarte con cuatro e intentar romper el áureo mientras el centinela trabaja sobre el blanco principal. También podés llevarte las doce, usar el recurvo para sostener el combo y volver cuando el taller haya producido otro haz. El sonido del centinela, el nivel de la tolva y el contador del carcaj tienen que permitir esa decisión de un vistazo.

### Primeros minutos

| Momento de la primera partida | Experiencia que debe ocurrir | Señal para el diseñador |
|---|---|---|
| Entrada | Se ven la veta, el arco de rama y 24 flechas. Un único aviso enseña disparo. | Se puede acertar desde donde aparece el personaje. |
| Primera compra y primera rotura | Junto a Pipo, el jugador puede obtener el primer nivel de daño gratis. Cada ocho puntos de vida que le quita al blanco gana una savia. Cuando rompe el tronco caen flechas. | El probador explica qué consiguió y distingue savia de flechas. |
| Nudos 2–3 | Aparece el plano del taller, se construye y se puede recoger su primera producción. | El probador sabe volver al taller cuando se vacía el carcaj. |
| Nudos 3–5 | Entran la Chispa de copa y el recurvo. La primera horqueta divide el blanco. | El jugador reconoce una compra por el cambio que siente al disparar. |
| Blancos 6–10 | El arco largo ofrece más daño por flecha. Tres puntos débiles del jefe cambian qué conviene apuntar. | El jugador distingue los arcos y encuentra el siguiente punto encendido. |

### Interacción y cámara

| Acción | Control propuesto en PC | Comportamiento |
|---|---|---|
| Mirar y desplazarse | Ratón y WASD | Movimiento libre por terreno continuo. Los puestos y los haces son accesibles a ras del suelo. |
| Disparar | Botón principal | En v0.1, pulsar dispara y mantener repite al ritmo del arco. La animación y el sonido comunican cada suelta. Para la versión completa se prevé poder alternar la repetición con un clic. |
| Apuntar con precisión | Botón secundario | Acercamiento suave configurable. La misma veta puede acertarse desde la vista normal. |
| Cambiar de arco | 1–4 o rueda | Entre los ya adquiridos. Se conserva el carcaj compartido. Un cambio de arma respeta el tiempo pendiente de la última suelta. |
| Golpear con la rama | F | Acción de corto alcance disponible desde el inicio. Con el carcaj vacío permite recuperar flechas. |
| Abastecer | E junto al centinela | Vista previa de la transferencia, entrega confirmada por sonido y cambio visible en la tolva. Se preserva una reserva para el jugador. |
| Comprar, pausar y guardar | E junto al perro abre el árbol. Esc abre pausa. | Clic para comprar un nivel. Con la mejora de reembolso, clic derecho para devolverlo. La simulación se detiene en árbol, cartas y pausa. |

El arco de rama premia elegir el punto de impacto. El recurvo sostiene una cadencia regular. El de abanico abre un frente de hasta tres flechas y admite una suelta parcial cuando queda poca munición. El de tejo repetidor convierte el suministro continuo en una ráfaga sostenida. La trayectoria del proyectil y el impacto deben ser visibles. En la prueba inicial se priorizan respuesta inmediata, leve arco visual y coincidencia entre la retícula y el impacto a la distancia habitual del claro. Ajustar el modelo de vuelo con el prototipo.

**Prueba de tensado.** En N1–3 se mide cómo se siente el tiro con clic y con el botón mantenido, con idéntico daño por flecha. Después de esa prueba, comparar la base con una variante que premie soltar en el punto justo con un pequeño bono. Mantener el tiro sostenido accesible y registrar precisión, fatiga percibida y preferencia antes de decidir si incluir el bono.

### Reglas que evitan bloqueos

- La savia compra rangos. Las flechas alimentan tanto al arquero como a los centinelas. Tomar parte de un haz deja el resto en el suelo. Un puesto vacío muestra su tolva abierta y vuelve a disparar en cuanto recibe munición.
- Se puede terminar con cualquier arco desbloqueado, sin acertar objetivos cronometrados. Cada fase deja una superficie de madera golpeable junto al suelo. Si hay dos lóbulos, cada uno conserva una raíz conectada a su propia reserva de vida. El jugador puede acercarse, usar la rama y reabastecerse aun con todos los puestos secos.
- No hay vida del arquero, daño por enemigos ni pérdida de campaña por fallar. El coste de una mala secuencia de compras es tardar más. Una oportunidad expirada se retira sin quitar integridad ya dañada ni savia ya ganada.
- En la demo, la compra Buena racha activa el combo. Llega a ×6 y el daño de los tiros manuales puede generar una prima de savia. Los aciertos a puntos débiles lo hacen subir más rápido.

## 3. Campaña y encuentros

Un **nudo** es un objetivo de madera formado por módulos. Probar con una altura inicial de 1,5 m y una final de 35–40 m, con la misma piedra de un metro como referencia en ambos extremos. Su huella se conserva dentro del área central y gana altura y volumen por etapas. Los puntos interactivos aparecen sobre caras visibles desde el corredor de tiro. La línea de tiro, el acceso a las pilas y la ubicación de los talleres siguen siendo reconocibles al final. El paso de nudo no recarga la escena ni borra las existencias.

Los primeros diez blancos tienen un objetivo de 15–20 minutos activos. Las filas posteriores ilustran una posible campaña de unas 100 min. En la demo, cada requisito de compra se cumple invirtiendo en el árbol. Los posibles desbloqueos por hitos quedan para una decisión posterior.

| Acto | Tiempo de referencia | Cambio dominante | Jefe y regla propuesta |
|---|---|---|---|
| I · N1–5 | 0–10 min | Disparo manual, primera compra, taller, chispa y recurvo | **Horqueta gemela (5).** A media integridad se abren dos lóbulos con reservas visibles. Al romper uno, las flechas restantes deben dirigirse al otro. |
| II · N6–10 | Fin de la demo hacia los 15–20 min | Ahorrar para un arco más potente o invertir en la cadencia y el suministro. | **Segundo jefe (10).** Tiene tres puntos débiles sucesivos. El tronco recibe daño ordinario y cada fase requiere acertar al punto activo o golpear la raíz correspondiente. |
| III · N11–15 | 25–45 min | El abanico y las oportunidades laterales cambian qué blancos conviene agrupar. | **Semillero fugitivo (15).** Suelta brotes por carriles cortos. Acertarles transfiere daño al tronco. Los que salen del claro solo cierran esa oportunidad. |
| IV · N16–20 | 45–65 min | Alimentar varios puestos aumenta el daño mientras el jugador se mueve. | **Corona acorazada (20).** Tres placas reciben el fuego sostenido de los puestos. El arquero puede quebrar a mano un broche lateral para exponer antes la veta de esa placa. |
| V · N21–25 | 65–85 min | Repetidor, altas necesidades de flechas y efectos de área. | **Tronco de los dos cauces (25).** Dos raíces laterales envían pulsos que dan una cubierta temporal al nudo. Cortar el pulso a tiempo abre la veta. Las cubiertas caducan, tienen tope y jamás devuelven integridad perdida. |
| VI · N26–30 | 85–120 min | El claro alcanza su mayor escala. El jugador sigue distinguiendo el origen de cada gran impacto. | **Árbol del sol hueco (30).** Primero abre los dos lóbulos. A mitad de la integridad total expone el núcleo y ofrece el sexto don. En el cierre alterna veta móvil y brotes, de a una regla por vez. La última suelta que agote la integridad, manual o automática, cierra la campaña. |

Los tres primeros jefes retoman familias descritas en el informe. Los tres últimos son diseños propios. Cuando el cuerpo se divide, cada centinela toma como blanco el lóbulo vivo más cercano y cambia al otro cuando cae. El jugador puede concentrar fuego en el que prefiera. Cada transición se dispara una sola vez, incluso si se cruza el umbral con varios impactos simultáneos. En el jefe final, el umbral del 50 % detiene la resolución de daño, registra la elección pendiente y abre la oferta. La segunda mitad arranca después de elegir. Guardar en esa transición debe conservar las mismas tres cartas.

### Oportunidades y sucesos

La **Diana de veta** aparece sobre el nudo desde N2 y recompensa precisión. El **Nudo áureo** entra en N6 y paga savia con un acierto lateral. El **Alijo del guardabosque** entra en N8 y deja flechas físicas donde cae. En cada estreno se garantiza una aparición de muestra. Después, fuera de jefes y sucesos, probar una oportunidad elegible cada 15–25 s, una a la vez. Estos tres objetos se reutilizan en los siguientes sucesos. Los fenómenos que se compran en el árbol tienen disparadores y efectos propios.

| Suceso del claro | Primera ventana propuesta | Acción y recompensa |
|---|---|---|
| Lluvia de semillas | Acto I, después de la primera compra | Caen blancos lentos alrededor del nudo. Los aciertos desprenden flechas. |
| Frente de tormenta | Acto II | Una nube anuncia una veta conductora. Acertarla deriva una descarga hacia el nudo. |
| Ráfaga de polen | Acto III | El polen dibuja una secuencia de dianas. Cada acierto manual ya aporta una prima aunque se deje pasar el resto. |
| Migración de brotes | Acto III, después del primer abanico disponible | Una hilera atraviesa un lateral. Una buena suelta puede alcanzar varios y convertirlos en daño al nudo. |
| Floración dorada | Acto IV | Aparecen nudos áureos en dos lados del claro. El jugador decide si interrumpe su recorrido para romperlos. |
| Caravana de alijos | Acto V | Llegan alijos por el borde del claro. Abrir uno deja un haz de flechas para abastecer a los próximos puestos. |

**Programación de sucesos.** Probar una ventana cada 45–75 s de juego activo después de su introducción. Máximo un suceso activo, sin repetir inmediatamente si hay otra opción elegible. Si ya hay una oportunidad suelta, esperar a que se resuelva antes de iniciar el suceso. Guardar la semilla y el tiempo restante. Si llega un jefe, concluye el suceso en curso y se suspenden nuevas apariciones hasta la rotura. Las vetas y los brotes propios del jefe siguen sus reglas de fase. Una señal sonora direccional y un icono identifican cada oportunidad. Los tiempos y recompensas son parámetros de prueba.

## 4. Interfaz, persistencia y accesibilidad

| Pantalla o estado | Requisito de producto |
|---|---|
| HUD · Cuaderno de campo | La ficha del blanco y su vida se leen en el margen superior izquierdo. El cuaderno inferior reúne arco, carcaj y savia. La guía opcional del primer recorrido marca el destino en el claro y se retira tras disparar con las primeras flechas recogidas del taller. El depósito de la ballesta muestra su carga en el mundo y al acercarse. |
| Árbol | El cuaderno se abre en dos páginas. La izquierda dibuja el arco con 112 nodos y 140 niveles y admite zoom con la rueda. La ficha de la derecha muestra nivel, costo, próximo efecto y compras necesarias. |
| Charlas del claro | Brizno, un mensajero alado, tiene relatos cortos en español e inglés que se habilitan según el estado del claro. Se le habla de cerca, con la misma tecla de interacción que a Pipo. |
| Dones | Tres opciones legibles con efecto, unidad y sistema beneficiado. Pausa sin cuenta atrás. Confirmar una opción aplica el efecto una vez. |
| Lectura y confort | Retícula configurable, números de daño agrupables con opacidad hasta cero, temblor y destellos reducibles, sensibilidad, campo de visión, volumen por familia y control reasignable. Cada aviso importante tiene forma o sonido además de color. |
| Guardado local | Una campaña activa y récords locales por separado. Guardado manual desde pausa, automático en compras, elecciones, cambios de nudo y al salir normalmente. Guardar también dentro de un jefe mediante pausa. Escritura atómica, copia anterior recuperable y versión de esquema. |
| Reanudar | Recuperar nudo y etapa, integridad, cartera, carcaj, pilas, tolvas, arcos, rangos, dones, combo, sucesos y reloj. Las ofertas pendientes se reabren intactas. Tiempo cerrado y menús pausados no producen flechas ni avanzan la campaña. |
| Final y repetición | Pantalla de resultados, mejor tiempo local y marcas por acto. Nueva vuelta con compras a cero tras confirmación si hay una campaña activa. La ruta sub-90 minutos es una meta opcional. |

**Tiempo de partida.** El reloj empieza cuando el jugador recibe el control en N1 y termina en la rotura de N30. Cuenta movimiento, tiro, espera voluntaria y abastecimiento. Se congela mientras la simulación está en pausa. Guardar y reanudar conserva el acumulado. El resumen identifica la versión de reglas y la semilla para poder comparar dos rutas.

**Marcas locales de campaña.** En el resumen se pueden consultar el primer nudo roto con un golpe de rama, el primer combo ×6, una reserva de 500 flechas simultáneas en el suelo, los seis talleres y doce centinelas construidos, el árbol de 77 rangos completo y el final en menos de 90 minutos. La reserva reconoce una abundancia que también se ve en el mundo. Las marcas quedan en el perfil local al iniciar otra vuelta y su única recompensa es el registro.

## 5. Alcance y prueba de éxito

| Entrega | Qué se juega | Qué decisión permite tomar |
|---|---|---|
| Prototipo local · N1–3 | Arco de rama, impactos, compra de daño, primer taller, pilas, recogida y recuperación con la rama. Menús en español e inglés y primer pino editable desde el Inspector de Godot. | ¿Qué se siente al disparar y cuánto tarda el jugador en encontrar su primera producción de flechas? |
| Corte vertical · N1–5 | Primer acto completo, recurvo, primer fenómeno, un suceso, primer jefe y primera oferta. Un claro con calidad visual representativa. | ¿Se entienden el disparo, la compra, la transformación del claro y la elección sin un tutorial largo? |
| Demo · blancos 1–10 | Dos actos, dos jefes, tres arcos, taller, ballesta abastecible, Pipo, Brizno y árbol de mejoras con reembolsos. El registro guarda marcas por acto y por vuelta. | ¿Se llega al décimo blanco con casi todo el árbol comprado? ¿Se entiende cuándo conviene repartir las flechas entre el carcaj y la ballesta? |
| Campaña completa · N1–30 | Seis jefes, seis elecciones, cuatro arcos y rama, 77 rangos, 24 dones, seis talleres, doce centinelas, seis sucesos y los seis fenómenos del catálogo | ¿El último acto paga la escalada, cierra la historia mecánica y admite una segunda vuelta más rápida? |

La entrega base es offline y finita. Quedan fuera multijugador, tabla pública, prestigio infinito, editor para jugadores, mundo abierto, móvil y destrucción voxel bloque por bloque. El panel visual de assets es una herramienta interna para que quien desarrolla el juego pueda generar y previsualizar variantes directamente. El primer caso es el pino. El bosque se construye una vez con zócalos fijos y se transforma delante del jugador.

### Pruebas que decidirán el ajuste

| Prueba | Criterio inicial para aceptar o iterar |
|---|---|
| Entrada en frío con cinco personas del público objetivo | Al menos cuatro aciertan en 15 s y compran un primer rango en 90 s sin indicaciones verbales. Registrar dónde se detuvo la quinta. |
| Economía y decisiones en N7–10 | Anotar cuántos niveles se podrían comprar con la savia obtenida antes del jefe y qué priorizó cada jugador. Comprobar si se distingue cuándo conviene ahorrar para el arco largo o mejorar el que ya se tiene. |
| Ritmo de la campaña | Registrar tiempo por acto, segundos sin flechas, compras y daño por origen. Buscar primera vuelta de 60–120 min y demostrar al menos una ruta de menos de 90 min sin fallos de progreso. Si un acto se alarga, distinguir espera de munición, vida excesiva y compras inasequibles. |
| Lectura tardía | En una captura jugable de N29–30 con doce centinelas y efecto global, al menos cuatro de cinco localizan la nueva veta en 2 s. Repetir con números y destellos desactivados. |
| Persistencia y final | Reanudar antes y después de una compra, una rotura, una oferta y la mitad del jefe 30. El saldo, las cartas y el tiempo cuadran. Completar con arco, con centinela y con fenómeno da exactamente un resultado por vuelta. |
| Rendimiento | Objetivo de 60 FPS a 1080p en el PC de referencia que se acuerde. Medir tiempo de cuadro p95 en la escena tardía cargada. Representar más flechas en un haz no debe crear una entidad por flecha almacenada. |
| Producción de contenido | Una segunda persona puede generar una variante de árbol desde una receta, colocarla y verla a escala correcta sin corregir pivote, materiales ni colisión a mano. Repetir con una pieza funcional en el corte vertical. |

Una muestra inicial de cinco participantes permite localizar problemas de usabilidad. Para balance, guardar un registro local de nivel, tiempo activo, daño por origen, flechas producidas/recogidas/consumidas, compras, huecos sin suministro y don elegido. El plan detalla cuándo levantar cada muestra y cuándo frenar la expansión.

**Primera prueba de juego.** Construir hasta el primer taller y observar una partida desde cero. Ajustar la primera compra y la recogida con esa prueba antes de llevar la secuencia hasta el primer jefe. Los 77 rangos ya están especificados para que ese trabajo escale.
