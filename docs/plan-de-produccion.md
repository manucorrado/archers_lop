# Plan de producción · Arquero voxel

El alcance previsto es la campaña de 30 nudos. En los primeros diez, el jugador decide dónde apuntar, en qué gastar savia y cuándo abandonar el tiro para abastecer un centinela. Las primeras entregas permiten resolver problemas de puntería, lectura y abastecimiento antes de repetir esos sistemas a escala.

## Entregas y criterios de salida

| Hito | Versión que se puede jugar | Evidencia para avanzar |
| --- | --- | --- |
| H0 · Primera compilación | Ejecutable local de Windows, primera persona en un claro de prueba, ratón y teclado. | Otra persona puede abrirlo en un equipo limpio, entrar al claro, pausar, salir y volver a empezar. Se anota el equipo usado para comparar versiones. |
| H1 · Prototipo local, N1–3 | Arco de rama, golpe de rama, flechas recogibles, savia, primeras compras y taller habilitado en N2. Interfaz ES/EN. Primer pino parametrizable desde el Inspector de Godot. | Una compra cambia perceptiblemente el tiro. Un jugador puede gastar todas sus flechas y volver a progresar. Probar clic y disparo mantenido con el mismo daño. Comprar el taller y recoger su producción a más tardar al terminar N3. |
| H2 · Corte vertical, N1–5 | Cinco nudos encadenados en un claro de bosque con calidad visual representativa. Incluye el arco recurvo y la chispa a más tardar al terminar N5, multiplicador, primer jefe, elección entre tres dones y guardado. | De cinco personas nuevas, al menos cuatro aciertan en 15 s y compran un rango en 90 s sin ayuda oral. En N2–3 se prueba construir el taller, recoger la primera tanda y encontrarlo de nuevo cuando se vacía el carcaj. Tras vencer a la Horqueta gemela, la compra y el don elegido siguen activos al reabrir. |
| H3 · MVP interno, N1–10 | Dos actos seguidos, dos jefes, dos elecciones de don, reservas visibles, taller, centinela abastecible, oportunidades laterales y opciones de lectura. | En N7–10, al menos cuatro de cinco explican por qué se detuvo el primer centinela y lo reactivan en 60 s. Se documentan dos secuencias de compra viables, una centrada en el arquero y otra en abastecimiento. La transición tras N10 muestra fin del MVP y resumen. |
| H4 · Campaña completa, N1–30 | Los seis actos, cuatro arcos más golpe de rama, seis jefes, árbol de 77 rangos, 24 dones, seis tipos de evento, hasta seis talleres y doce centinelas. | Dos recorridos distintos alcanzan el desenlace. Las elecciones de don de N5 a N25 se activan al vencer al jefe y la última al 50 % de vida de N30. El sexto don interviene en la segunda mitad de ese combate. |
| H5 · Candidata para distribuir | Compilación autónoma para Windows, ajustes, guardado recuperable, resumen y tiempos locales. | Se ejecuta la matriz de pruebas en la compilación distribuible, incluida la escena de máxima carga. Se archivan versión, equipo, semillas de prueba, resultados y defectos pendientes. |

N indica el número de nudo. H1, H2 y H3 entregan compilaciones locales reproducibles. Usar el MVP para recalibrar el esfuerzo y el orden de los cuatro actos restantes. Los hitos públicos se preparan por separado.

**La presentación de H1 es provisional.** El HUD y los menús permiten probar el flujo de juego. El nudo, las manos y el arco, el taller, los haces de flechas, la vegetación y los efectos permiten probar escala, puntería y recogida. En H2 se refinan o sustituyen estas piezas con el kit del primer acto y se revisan juntas en una partida. Esa versión sirve de referencia visual para los actos posteriores. H5 cierra el pulido con la campaña completa en pantalla. [Dirección de arte y producción voxel](arte-y-assets-voxel.md).

## Capacidad y estimación

Una persona a tiempo completo cubre desarrollo, diseño, arte y pruebas. Usará Godot, una arena modular y una partida individual en Windows con teclado y ratón. El presupuesto no tiene tope y no hay plazo externo comprometido. Los rangos en **jornadas-persona (JP)** incluyen construcción, integración y primera ronda de correcciones. Cada paquete indica qué trabajo corresponde a **P** (programación), **D** (diseño y balance), **A** (arte y sonido) o **Q** (pruebas).

| Hito | Paquetes | Esfuerzo incremental |
| --- | --- | ---: |
| H0 | T01–T03 | 4–7 JP |
| H1 | T04–T08 | 8–15 JP |
| H2 | T09–T16 | 15–29 JP |
| H3 | T17–T22 | 12–23 JP |
| H4 | T23–T29 | 23–40 JP |
| H5 | T30–T33 | 8–15 JP |
| **Total** | **T01–T33** | **70–129 JP** |

Llegar al MVP interno demanda **39–74 JP**. Con cinco jornadas productivas por semana, una persona necesitaría unas 8–15 semanas de trabajo para el MVP y 14–26 para H0–H5. Reservar aproximadamente un 20 % adicional para iteraciones y pruebas con personas. Los tiempos de tiendas, la localización de todo el contenido y el soporte durante el acceso anticipado requieren una estimación aparte. Reestimar en H2 con el tiempo medido para crear una familia de assets, un jefe y un acto.

## Backlog ordenado

La columna «Tras» nombra las dependencias directas. Con una persona a cargo, ejecutar las tareas independientes en el orden que permita primero jugar el hito completo. Antes de ampliar contenido, archivar la compilación y revisar su criterio de salida.

### H0 · Base verificable

| ID | Responsable · JP | Tras | Trabajo y aceptación |
| --- | --- | --- | --- |
| T01 | D/P · 1–2 | — | Fijar versión de motor, controles provisionales, PC de prueba y resolución. Exportar un claro gris para Windows con entrada, movimiento, pausa y salida. Anotar CPU, GPU, RAM y resolución del equipo en el informe de la compilación. |
| T02 | P/D · 2–3 | T01 | Definir datos editables de nudo, arco, rango, don y desbloqueo con identificadores estables. Cargar un nudo desde datos y rechazar una referencia rota con el ID del registro. |
| T03 | P/Q · 1–2 | T01 | Preparar selector de nudo y semilla para desarrollo, captura local de tiempos de fotograma y registro de hitos. Verificar que las ayudas de depuración estén deshabilitadas en la compilación de distribución. |

### H1 · Demostrar el bucle manual

| ID | Responsable · JP | Tras | Trabajo y aceptación |
| --- | --- | --- | --- |
| T04 | P/D · 2–4 | T02 | Implementar puntería en primera persona, arco de rama y golpe de rama. Cada suelta gasta lo indicado aunque falle. Un impacto muestra el punto de contacto y aplica el daño una sola vez. El golpe funciona con carcaj vacío. |
| T05 | P/D · 1–2 | T04 | Crear N1–3 con aumento visible de tamaño, integridad, haz de rotura y transición. Dos impactos simultáneos que agoten el último punto activan una única recompensa y un único cambio de nudo. |
| T06 | P/D · 2–3 | T04 | Implementar savia, flechas, carcaj, recogida y primera compra de daño. Al comprar se ve precio, rango y efecto. El jugador puede repetir el ciclo disparar → cobrar → comprar → romper. |
| T07 | P/A · 2–4 | T05, T06 | Habilitar la compra del primer taller en N2 y mostrarlo en su sitio al construirlo. Produce recogibles con saldo contable y representación en el suelo. Una pila parcialmente recogida conserva las unidades sobrantes. |
| T08 | D/Q · 1–2 | T03, T07 | Comparar clic individual y disparo mantenido en N1–3. Registrar sensación de respuesta, tiempo a primera compra y rotura, recuperación de munición y diferencia tras comprar daño. Después de la prueba base, evaluar si merece ensayar un bono por soltar al terminar de tensar. |

### H2 · Validar el primer acto con la presentación de referencia

| ID | Responsable · JP | Tras | Trabajo y aceptación |
| --- | --- | --- | --- |
| T09 | A/P · 2–4 | T01, T02 | Ampliar el panel de assets a partir del pino editable de H1. Desde el Inspector, una segunda persona debe generar tres variantes en menos de 20 minutos y verlas en el claro. Repetir con una pieza funcional y comprobar escala, pivote, anclajes y colisión sin retoques. |
| T10 | A/D · 2–4 | T07, T09 | Montar el claro y sus referencias de escala con el kit voxel de T09. Refinar o sustituir los modelos de H1 del nudo, manos y arco, taller, haces y vegetación. Sincronizar tensado, suelta, estela, astillas y rotura con el gesto y el sonido. Dar confirmación sonora a la compra. Desde las posiciones de juego deben distinguirse la veta, las reservas y el taller por silueta y sonido. |
| T11 | P/D · 2–3 | T05, T06 | Implementar racha, diana de veta y primer evento con temporizador y prioridad visual. Registrar ganancia y caída del multiplicador. Dejar vencer el evento y comprobar que la campaña sigue avanzando. |
| T12 | P/D · 2–4 | T06, T09 | Habilitar la chispa en N3 y el arco recurvo en N4 con las ramas y prerrequisitos del acto. La ficha muestra valor actual, siguiente rango y coste. Se puede comprobar la diferencia de cadencia entre ambos arcos con igual reserva. |
| T13 | P/D · 2–4 | T05, T11 | Montar N4–5, su regla de jefe y selección de un don entre tres elegibles. Cada elección aplica todas las propiedades del don elegido y se ve en el resumen. Una entrada repetida no duplica la entrega. |
| T14 | P/Q · 2–4 | T07, T12, T13 | Persistir sesión y ajustes con escritura atómica, versión y copia recuperable. Probar guardado manual y automático junto a compras, roturas, cartas y salida. Guardar dentro del jefe y con la oferta pendiente. Al reanudar se recuperan la fase y las cartas exactas. |
| T15 | P/A · 2–4 | T10, T11 | Dar un tratamiento común al HUD y a los menús de inicio, pausa, compras y dones. Probar tipografía, iconos, foco y textos en ES/EN. Integrar indicaciones, retícula, daño agrupado y ajustes de comodidad. Con daño reiterado y suceso activo siguen visibles la diana, el nivel, la integridad, el carcaj y el multiplicador. |
| T16 | D/Q · 1–2 | T08, T12, T13, T14, T15 | Ejecutar la prueba de entrada y taller de H2. Para cada persona anotar segundos a impacto, compra y primera recogida de producción, si regresa al taller al agotarse las flechas y qué decisión tomó. Revisar a 1280 × 720 la grabación desde el primer tiro hasta la división del jefe y las capturas de los menús en ambos idiomas. Se distingue la veta durante el impacto, se ve el resultado de la compra y se pueden leer y elegir los tres dones. Corregir y volver a probar la primera dificultad observada. |

### H3 · Validar el abastecimiento y la segunda pausa de jefe

| ID | Responsable · JP | Tras | Trabajo y aceptación |
| --- | --- | --- | --- |
| T17 | P/D · 3–5 | T07, T14 | Habilitar el primer centinela en N7 e implementar depósito y acción contextual de carga. El centinela gasta unidades solo si dispara, se detiene al agotarlas y vuelve a atacar tras recibirlas. Indicar visualmente los tres estados. |
| T18 | P/D · 2–4 | T11, T12, T13, T17 | Incorporar N6–10 con las compras, dones y oportunidades del acto, Corazón errante y resumen del MVP. Comprobar que los dos cambios de cavidad se anuncian, que el tronco admite daño ordinario y que la victoria registra la segunda elección. |
| T19 | P/Q · 2–4 | T14, T17 | Ampliar guardado a depósitos, flechas de suelo, centinelas, evento y fase de jefe. Cerrar y cargar mientras se transfiere un lote. El total de unidades después de reabrir coincide con el último estado guardado. |
| T20 | A/P · 2–4 | T09, T17 | Integrar piezas definitivas de centinela y reserva, animación de carga, audio de depósito y aviso de vacío con equivalentes visuales. Identificar un puesto vacío con sonido silenciado y verificarlo al interactuar. |
| T21 | D/P · 2–4 | T03, T18 | Registrar compras, producción, consumo manual y automático, saldo de suelo, pausas por falta de flechas y tiempo por nudo. Comparar dos órdenes de compra con la misma semilla. Cada uno debe llegar a N10 y mostrar un intercambio medible entre tiempo, abastecimiento y daño. |
| T22 | Q/D · 1–2 | T16, T18, T19, T20, T21 | Ejecutar la prueba N7–10 de H3. Cronometrar desde la última flecha del centinela hasta que el jugador recoge en el taller, abastece y el puesto retoma el tiro. Comprobar una carga parcial, la reserva del arquero y la segunda elección al reabrir la partida. |

### H4 · Producir la campaña de seis actos

| ID | Responsable · JP | Tras | Trabajo y aceptación |
| --- | --- | --- | --- |
| T23 | P/D · 3–5 | T12, T18 | Añadir arco de abanico en N12 y arco de tejo repetidor en N22, sus consumos y las familias restantes de mejoras de tiro. Medir impacto, cadencia, coste por suelta y daño sostenido con y sin suministro para cada arco. |
| T24 | P/D · 4–7 | T11, T18 | Completar los seis sucesos del claro y los seis fenómenos del catálogo. Probar ventanas de 45–75 s activas, un solo suceso en curso, suspensión ante un jefe y persistencia de semilla y temporizador. Superponer dos fenómenos y comprobar atribución del daño y legibilidad. |
| T25 | P/A · 3–5 | T17, T20 | Ampliar el claro hasta seis talleres y doce centinelas, con pilas agrupadas y modelos instanciados. Un recorrido de recogida y recarga en la arena completa conserva las unidades y deja paso al jugador. |
| T26 | D/P/A · 4–7 | T13, T18, T23 | Implementar reglas, señales y transiciones de N15, N20, N25 y N30. Una semilla de prueba alcanza cada fase. El disparo que cruza el 50 % del último jefe abre la oferta final una sola vez, incluso con daño simultáneo. |
| T27 | D/P · 3–5 | T12, T18, T23, T24, T25 | Completar árbol y dones según el catálogo. Un validador cuenta 77 rangos y 24 dones, comprueba IDs, prerrequisitos y ciclos e identifica ofertas sin tres opciones válidas. Probar cada efecto al menos una vez en su sistema receptor. |
| T28 | D/P/A · 3–6 | T10, T24, T25, T26, T27 | Secuenciar N11–30, escala de los nudos, introducción de efectos y desenlace. El resumen registra tiempo, mejor combo, rangos y daño por canal. Guardar las marcas locales del PRD al cumplir su condición. Comprobar la marca de reserva al pasar de 499 a 500 flechas en el suelo. Una partida nueva confirmada conserva marcas, récord y ajustes. |
| T29 | D/Q · 3–5 | T19, T21, T28 | Completar campaña desde cero en dos rutas, registrar duración por acto y reparto de daño, e intentar la ruta de menos de 90 minutos. Comparar con el objetivo de 60–120 min y ajustar costes, vida o ventanas en el acto que concentra la demora. |

### H5 · Estabilizar y cerrar

| ID | Responsable · JP | Tras | Trabajo y aceptación |
| --- | --- | --- | --- |
| T30 | P/A · 2–4 | T24, T25, T28 | Perfilar el escenario de máxima carga. Si el presupuesto se supera, agrupar números y pilas, reutilizar emisores y medir de nuevo con la misma semilla. Guardar trazas antes y después. |
| T31 | P/Q · 2–4 | T19, T26, T28 | Interrumpir una escritura y recuperar el último estado completo. Probar guardado en distintas fases del jefe, incluido el umbral de N30. Terminar una vez con arco, otra con centinela y otra con fenómeno. Cada recorrido deja un solo resultado con su tiempo. |
| T32 | A/D/Q · 2–4 | T15, T28, T30 | Comparar la entrada al claro, los menús y N29–30 con las capturas de referencia de H2. Completar la revisión de materiales, siluetas, animaciones, HUD y efectos. El texto cabe en ES/EN y se identifica la acción seleccionada en cada menú. Ajustar contraste, impacto sonoro, vibración y destellos hasta superar la prueba de legibilidad a carga máxima, también sin audio y con efectos reducidos. |
| T33 | Q/P · 2–3 | T29, T30, T31, T32 | Exportar candidata limpia, superar la matriz de salida, instalar en un segundo Windows y abrir guardado de la candidata anterior. Comprobar final, récord local y arranque de una partida nueva. |

## Cómo se valida una entrega

| Caso reproducible | Qué se mide | Criterio de aceptación |
| --- | --- | --- |
| Inicio completamente en frío | Desde «Nueva partida» hasta primer impacto, primera rotura y primera compra. En N2–3 observar construcción, primera recogida de producción y regreso al taller con el carcaj vacío. | Cuatro de cinco aciertan en 15 s y compran un rango en 90 s sin indicaciones verbales. El recorrido de prueba recoge producción antes de terminar N3. Registrar en qué paso se pierde la persona que necesitó ayuda. |
| Saldo de flechas por intervalo | Comparar el inventario al inicio y al final de un intervalo. Contar las flechas enteras emitidas por talleres, roturas, golpe de rama, alijos y sucesos, aplicando los modificadores de don al origen. Añadir cada devolución de Brote de recambio y Trama de ramas. Descontar sueltas y tiros de centinela por el gasto real. Recogida y recarga solo transfieren unidades. | `carcaj + suelo + tolvas = inventario inicial + emisiones y devoluciones − consumos`. La partida nueva empieza con 24 en el carcaj. Probar abanico parcial, reserva personal de cuatro, devoluciones simultáneas, sobrante de un haz y carga al guardar. El resto fraccional de cada taller se conserva aparte y al reanudar produce la siguiente unidad a su debido tiempo. |
| Umbrales de jefe y guardado | Guardar justo antes y después de una compra, una rotura y una oferta, con dos fuentes de daño simultáneas. En N30 cruzar el 50 % con daño suficiente para agotar toda la integridad. Pausar con la oferta abierta, salir y reanudar. | El daño se detiene en la transición, se conservan las tres cartas y la segunda mitad empieza tras una sola elección. Verificar el desenlace de arco, centinela y fenómeno en corridas separadas. Cada recorrido genera un único resultado. |
| Recuperación y tiempo detenido | Guardar manualmente durante un jefe, salir y reabrir después de una espera conocida. Repetir desde árbol, oferta y pausa. Simular una escritura interrumpida antes del reemplazo del archivo. | Se conserva el último estado completo de campaña, combo, sucesos, saldos y reloj. El cierre y los menús pausados añaden cero tiempo de campaña y cero producción. Los récords locales sobreviven a la recuperación. |
| Ruta de abastecimiento | Entre N7 y N10, observar a cinco personas. Con un centinela a punto de agotarse, medir tiempo de interrupción y desvío, qué causa reconocen, dónde obtienen flechas y si vuelven a apuntar tras cargarlo. | Al menos cuatro identifican la falta de flechas y reactivan el puesto en 60 s desde el cese del fuego. La ruta manual y la logística llegan a sus respectivos finales. |
| Legibilidad y carga de N29–30 | Medir al menos 120 s, incluida una captura de 60 s, con el nudo gigante, infraestructura completa, reserva abundante y dos fenómenos simultáneos. Repetir la búsqueda de la veta y la tolva vacía con números y destellos desactivados. | Cuatro de cinco localizan la veta en 2 s y detectan qué centinela necesita carga en 3 s. Presupuesto propuesto de 60 FPS a 1080p en el PC de T01, p95 ≤16,7 ms y p99 ≤33,3 ms. Aumentar el saldo de un haz conserva el número de entidades de su representación. |
| Duración y repetición | Separar tiempo de juego y de pausa según reglas del PRD. Medir dos partidas completas y un intento optimizado, con versión y semilla. | H4 busca una primera campaña de 60–120 min y una ruta repetible inferior a 90 min. Si el intento no la consigue, documentar dónde se pierde tiempo, reajustar y repetir. Las cifras de retención del juego de referencia quedan fuera de estos criterios. |

## Riesgos que pueden cambiar el plan

| Señal temprana | Decisión operativa | Cuándo resolverla |
| --- | --- | --- |
| Disparar resulta monótono antes de desbloquear el siguiente arco. | Iterar respuesta de impacto, sonido, primera compra y primera diana con el mismo contenido y volver a probar H1. | Antes del kit visual completo. |
| El jugador mira el suelo durante la mayor parte de la sesión o queda vacío entre recogidas. | Ajustar tamaño del lote y distancia entre taller y centinela con los registros de consumo. Mantener una decisión real de abastecimiento. | Antes de multiplicar los puestos en H4. |
| Fabricar una variante voxel requiere retoques manuales repetidos. | Localizar el paso repetido, trasladarlo a la receta y revisar escala, anclajes y paleta en una segunda familia. | T09 y T20, antes de autorizar nuevos lotes de arte. |
| El último tercio agrega efectos que apenas se llegan a usar o tapa el punto débil. | Separar desbloqueos por nudo, alargar su ventana práctica y reducir densidad de efectos secundarios. Comparar una captura con la misma situación inicial. | T28–T32. |
| La creación del primer acto supera la capacidad semanal prevista para una persona. | Conservar el corte jugable, medir el trabajo repetible y recalcular las jornadas por acto, incluyendo localización y soporte. | Tras H2 y al preparar la primera salida pública. |

## Salidas públicas en Steam e itch.io

| Edición | Trabajo antes de publicar | Criterio de salida |
| --- | --- | --- |
| Demo pública | Elegir el tramo tras probar los cortes N1–5 y N1–10. Cerrar su final, preparar fichas de tienda, controles, capturas y textos en inglés y español. | Instalar la demo desde cada canal de prueba en Windows, completar el tramo en ambos idiomas y verificar que el cierre describe el alcance disponible. |
| Acceso anticipado | Definir el contenido de la primera versión pública, preparar notas de versión bilingües, un canal de comentarios y una copia recuperable de cada compilación distribuida. | Una instalación nueva y una actualización completan el contenido anunciado. El catálogo de cada tienda identifica el estado de desarrollo. |
| Versión final | Completar H4–H5, revisar las dos traducciones y publicar la campaña con precio previsto entre **1 y 2 €**. Elegir importe y calendario al preparar el lanzamiento. | La compilación final instalada desde ambos canales permite terminar en ambos idiomas. Se conservan las marcas y el récord local según la política de migración publicada. |

Los récords personales cubren la competición por tiempo. El producto se desarrolla para Windows con teclado y ratón. H1 se distribuye al responsable del proyecto como prototipo local.
