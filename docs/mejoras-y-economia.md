# Sistemas de mejoras, economía y cartas

## Qué rige a partir del 27 de noviembre de 2026

**Build jugable** describe el código de `654bd1f`. **Acordado** describe qué se quiere construir. **Prueba** señala una alternativa o cifra que necesita juego real. **En revisión** conserva una idea sobre la que todavía falta una decisión. **Retirado** la saca de la planificación activa y conserva su motivo. Los IDs remiten a las respuestas del grill. Las 24 cartas de la tabla son diseños individuales con estados distintos.

| Para encontrar | Documento |
|---|---|
| Precios, efectos, requisitos y cartas que podés probar hoy | [Árbol de la demo](arbol-de-la-demo.md) |
| Las 65 fichas, sus antecedentes y las decisiones de arco, fuego, precisión, taller y movimiento | [Catálogo editable](catalogo-de-mejoras-potenciales.md) |
| Modelo numérico de precios, vida, ingreso, logística y pruebas por ruta | [Rebalanceo económico](curvas-de-costes-incrementales.md) |
| Cómo se ganan y gastan las medallas y qué habilitan | [Prestigio](prestigio.md) |
| Qué significa una idea dudosa, qué alternativas compiten y qué se retiró | [Decisiones pendientes](decisiones-pendientes.md) |

## De dónde viene el poder

Las compras regulares abren mecánicas por inversión y requisitos del Atlas. Las cartas especializan la vuelta. Las compras permanentes de prestigio se acumulan y pueden habilitar nuevas compras de savia, incluida una extensión del Atlas. El total del nuevo árbol debe superar lo asequible en los veinte árboles actuales. Se acepta una ruta muy fuerte al final de la demo y varias rutas razonables deben poder disfrutar ese pico. Los actos sirven para comparar tiempos cuando sea útil. El número de árbol identifica el progreso y los hitos. [A01–A09 y progresión](PRD.md) · [Árbol extendido y barreras](prestigio.md)

Las flechas se producen, caen al suelo, se llevan en el carcaj y se pueden transferir a un depósito. La **savia** paga la progresión de esta vuelta. Las **Medallas de prestigio**, nombre provisional, acreditan progreso permanente. Una mejora de más daño puede adelantar el cobro de la savia; una logística que te devuelve antes al blanco también. Para elegir precios se mide el ciclo completo. Una mejora cuyo único efecto es producir más puede tener poco valor cuando la munición ya se queda sin transportar. [Curvas, pagos e interacciones](curvas-de-costes-incrementales.md)

## Combo, diana, savia y reembolso

| Grill | Decisión de diseño | Ejemplo o comprobación |
|---|---|---|
| C01–C03, C0X | Buena racha se compra. Contar una vez por suelta y usar el mejor acierto. La racha futura aumenta **daño**, con un techo tardío mucho mayor que ×6. | Tres flechas acertadas del mismo clic cuentan una suelta. Con un pago proporcional a vida efectiva, más daño acelera el ingreso hasta llegar a la siguiente fase. La build actual usa prima de savia; falta fijar la nueva curva y el techo. |
| C04–C06, M08 | Prolongar la gracia por sí solo tiene baja prioridad. Probar una compra que sostenga el combo al recoger un lote nuevo (ejemplo, un segundo). Aceptada una gracia por entregar munición real a un puesto. | En el diseño anterior se proponían 2,5 s al cargar y 8 s de espera entre activaciones. Pisar el mismo resto o apretar E con el depósito lleno no debería mantener la racha. La posible racha entre dos recogidas se refiere al combo de combate y sigue en revisión. |
| C07–C09 | La diana difícil debe premiar **daño** en esta revisión. Definir si lo hace sobre ese impacto o en una ventana posterior, y cómo convive con las hasta tres flechas de la build. Se descartan por ahora la prima al primer golpe de cada mitad y los encargos de llevar flechas por savia. | Una oportunidad paga una vez. Una bonificación de precisión compra una decisión diferente del reembolso de munición. Ver O03 antes de tocar las dos cosas juntas. |
| C10–C14 | Evaluar un presupuesto repartido, por ejemplo **90 % por daño y 10 % por rotura**. De aquí depende Veta madre. Aplazar descuentos por rama. Precios fijos definidos con la curva del proyecto, incluyendo arcos, triple y lluvia. Comparar modelos para repetibles y momento de acceso al triple. | Contrastar ahorro, taller primero y precisión con la misma tabla. Evaluar cuánto tarda en pagarse sola una mejora y cuánto dura su ventana de uso. |
| C15–C17 | Conservar licencia barata, clic derecho por un nivel y reintegro de lo realmente pagado. **Preferencia a validar:** devolver automáticamente las compras que pierden sus requisitos al reembolsar al padre. | Previsualizar nodos, niveles y suma a devolver. Decidir el caso con dos caminos válidos. Preservar exceso de carcaj, atados en vuelo/suelo y flechas de un puesto desmontado. En la build actual se conservan los hijos. |
| C18 | Medir por separado ahorro, saldo suficiente y viaje a Pipo. Primera calibración con el autor, luego con jugadores de itch. | Distinguir una espera impuesta por el precio de un jugador que posterga una compra porque eligió seguir disparando. |

## Ballestas

| Grill | Qué se diseña y qué sigue abierto |
|---|---|
| B01 | En la build, E transfiere hasta ocho flechas a la ballesta, dejando cuatro propias y respetando espacio libre. Con doce en el carcaj y depósito vacío podés dejar ocho o seguir con doce. El diseño busca una decisión simple de abastecimiento. Revisar si los valores 8 y 4 producen una decisión que se sienta. |
| B02, B05 | Probar una ballesta lenta de golpes fuertes junto a la actual de una flecha cada dos segundos. Tomar dos puestos fijos como prueba inicial. Aclarar si «prefiero 2» señalaba dos puestos o la segunda opción de B05, duplicar daño. Una compra fuerte de daño tendría además un cambio de aspecto visible. |
| B03, B04 | Probar el primer aumento propuesto de depósito, +8 plazas. La reserva personal regulable queda en revisión. La ficha muestra cuántas flechas entran y qué autonomía compran. |
| B06–B07 | Sin necesidad actual de repartir entre vecinos. Se retira la ráfaga tras cargar. Comparar en su lugar daño que crece con la proporción de depósito **vacío** o **lleno**. Un caso invita a apurar el depósito, el otro premia mantenerlo abastecido. |
| B08–B11 | Apuntado automático al centro del árbol o de la parte viva más cercana. Simplificar selección de lado y órdenes. Priorizar dos ballestas, máximo cuatro mejorables y con ubicación fija. Conservar como candidata de prestigio el abastecimiento automático y definir su fuente de flechas. |
| B12 | Depósito vacío legible a distancia con banderita roja y/o brillo. Comprobarlo con destellos reducidos y durante fuego rápido. |

## Oportunidades del claro

| Grill | Tratamiento acordado o propuesto |
|---|---|
| O01–O03 | La mejora de frecuencia acorta la espera de los blancos opcionales. Primera aparición garantizada por tipo; ensayar 15–25 s entre oportunidades y 45–75 s entre sucesos elegibles. La Diana de veta actual es una zona temporal del mismo árbol. Desde N6 en los tramos habilitados un tiro manual recupera hasta tres flechas, una vez por aparición. Revisar su premio junto a C07. |
| O04–O06 | Semillas aladas requiere compra. Rediseñar modelo, animación, recompensas y cantidad. Empezar por trayectoria y altura de caída. Probar por separado mejorar el premio de cada acierto y el multiplicador por completar todas. Base actual para comparar: tres semillas de 8, 9 y 10 s, premios totales 4, 8 o 24 según cuántas acertás. |
| O07–O08 | Blanco dorado en revisión integral. El alijo proviene de los suministros del diseño de campaña. El cajón colgado fue una variante posterior: cortar la soga, dejarlo caer y elegir cuándo acercarse. Decidir si añade algo sobre las semillas. |
| O09–O11 | Una secuencia de marcas podría devolver flechas por acierto. Atado al viento en revisión: el momento del corte decide dónde cae. Una hilera de brotes sería una oportunidad lateral para acertar uno o alinear varios; faltan interés y encaje con un solo árbol. |
| O12–O14 | Transformar la tormenta en una **mejora de rayo solar que cae del cielo**, posible prestigio. Floración dorada significaba dos opcionales dorados en lados opuestos; depende de resolver el blanco dorado. Caravana de alijos retirada. |
| O15–O16 | Base con una aparición manejable a la vez y avance posible ignorando las opcionales. Para la prueba inicial, evitar repetición inmediata cuando haya alternativas y suspender nuevas apariciones en fases delicadas del jefe. Mejora muy tardía para superponer muchos eventos y llevar el claro al caos deliberadamente. Probar si se sigue viendo el tronco y dónde vale la pena apuntar. |

## Chispa, estados y reloj de efectos

| Grill | Diseño y prueba |
|---|---|
| E01 | Rediseñar Chispa. Un rayo pequeño viaja a un **atado en el suelo** y encanta esas flechas con probabilidad de disparar un rayo al usarlas. Poder dejar un lote para que se cargue introduce una decisión de ruta. Falta definir disparador, selección, duración, probabilidad y conservación al recoger solo parte. |
| E02–E03 | Probar cadena de rayos a partir de las flechas encantadas. Retirar la antigua Tormenta de copas que añadía tres rayos por contador. Para un único tronco entero hay que definir a qué puede saltar una cadena. |
| E04–E06, E08 | Bellotas era daño automático descendente; semillas son objetivos a los que disparás para recuperar munición. Hojas en hoz y daño de área recaían sobre cada objetivo diferente alcanzable. La inmensa mayoría de árboles tienen **una** parte: con uno presente solo habría un golpe. Revisar su utilidad antes de especificar áreas, meteorito o ciclón. Se descarta Remolino de raíces. |
| E07, E09–E10 | Unificar el gran rayo del cielo y Sol del claro en el rayo solar. Reevaluar azar frente a carga según la Chispa nueva. Repetir un ataque especial depende de que primero se diseñe uno que se pueda repetir. |
| E11–E13 | Admitir compras de potencia e intervalo individuales por efecto y algunas globales, por ejemplo daño de todos los efectos. Los relojes avanzan en combate y al recoger aunque no haya habido acierto reciente. Se detienen en menús, cartas y tramos sin blanco. Dejar al menos un encuentro para reconocer cada fenómeno nuevo. |
| F, H, Y | Fuego acumulable por parte, probablemente habilitado con prestigio; eco fantasmal y eventual marca necrótica; congelación experimental que acumula daño y lo libera multiplicado al terminar. El dato de daño efectivo se registra al quitar vida. Contabilizar por origen para comparar rutas y evitar acreditar el mismo daño dos veces. [Detalles y descartes](catalogo-de-mejoras-potenciales.md) |

## Decisiones sobre las 24 cartas

Todas las cifras propuestas pasan por balance. La primera oferta de la build tiene tres cartas fijas; la elección posterior, la elegibilidad, el orden de ampliación y el catálogo definitivo siguen en revisión. La oferta se guarda tal cual al cerrar y se excluyen las cartas ya elegidas en esa vuelta. Se evalúa una compra de prestigio para volver a sortear entre cartas elegibles. En un último jefe la producción puede seguir siendo útil si todavía hay tiempo de recoger y disparar. [D25–D27 y dudas](decisiones-pendientes.md)

| ID y carta | Efecto de referencia | Decisión y criterio para revisarlo |
|---|---|---|
| D01 Pulso de liebre | ×1,5 a la cadencia de los arcos | Aceptada. Comparar la presión adicional sobre el carcaj con el tiempo realmente ganado. |
| D02 Veta madre | +25 % al **pago de rotura** del diseño anterior | Explicar y revisar con C10. Si un árbol paga 100 con reparto 90/10, +25 % sobre sus 10 de rotura agrega 2,5 antes de acumular fracciones. No se puede dar por útil con la economía vigente. |
| D03 Manantial | +30 % a producción por taller | Aceptada. Probar su aporte sobre uno y dos talleres, incluida la capacidad de transportarlo. |
| D04 Corteza viva | +20 % a cada flecha manual | Aceptada como referencia constante. Con tres impactos base de 1 hace 3,6 antes de redondeos. |
| D05 Ojo de búho | Hoy añade 0,5 al multiplicador del punto débil | Aceptada con revisión de identidad y texto. «Sube el máximo de combo en X» sería otro efecto real, que compite con especialización en precisión. Decidir cuál se implementa. |
| D06 Tercera hoja | La tercera suelta acertada seguida recibe +40 % | Aceptación condicionada. Tres aciertos iguales hacen 3,4 frente a 3,6 con Corteza. Para igualar esa media hace falta +60 % al tercero si nunca fallás. Medir el premio mayor o una utilidad particular que justifique el riesgo. |
| D07 Golpe de savia | Propuesta antigua de rama ×3 y ocho flechas al golpear en vacío | Revisar para centrarse en extracción y alcance. La rama recupera munición. Su daño tiene importancia secundaria. |
| D08 Carcaj profundo | La build da 24 plazas | Rediseñar como +X % sobre la capacidad base. Definir qué niveles constituyen la base y cómo redondea antes de fijar X; tiene que seguir sirviendo con carcajes grandes. |
| D09 Hojas imantadas | +2 m de radio de recogida | Descartada en el diseño objetivo por escaso cambio de dinámica. Distinguirla de la carta que todavía existe en la build. |
| D10 Paso ligero | +15 % en la build | Nuevo objetivo +25 % siempre, con y sin flechas; se combina con los demás bonos de movimiento. |
| D11 Brote de recambio | Recupera una flecha cada cinco **sueltas** que gastan munición, incluso fallidas | Una procedencia principal. Un clic triple avanza una de las cinco sueltas. Definir si esta carta es su única procedencia. |
| D12 Cosecha doble | En la build, cada árbol roto deja 16 flechas en vez de ocho con esta carta | Explicar y decidir encaje con la mejora normal de rotura, incluida la que lanza el haz hacia la zona de aparición. |
| D13 Guarda de savia | Históricamente añadía 10 % al pago de daño manual al alcanzar combo ×3 | En revisión. Ejemplo antiguo: 10 de ingreso elegible añadirían 1. El combo rediseñado da daño; decidir si tiene sentido una excepción monetaria. |
| D14 Aliento largo | Dos segundos adicionales antes de decaer el combo | Poco impacto. Apartada para posible sustitución, contrastar con sostenerlo al recoger. |
| D15 Rastro dorado | +50 % al premio de un blanco dorado | Poco impacto y objetivo en revisión. Apartar hasta decidir si el blanco permanece. |
| D16 Hoja ancha | Diana temporal de diámetro 25 % mayor | Revisar identidad, aspecto y borde interactivo junto al punto débil y la propuesta de ampliar su ventana. |
| D17 Provisiones del claro | El alijo abierto entrega 24 flechas | Se conserva para balance. Depende de definir el alijo individual; la caravana está descartada. |
| D18 Reserva del vigía | +12 plazas por depósito | En revisión. En una ballesta base de doce permite guardar 24 y pasar más tiempo sin recargar. Comparar con la compra regular de capacidad. |
| D19 Ronda veloz | Una entrega aceleraba el puesto 50 % durante seis segundos | Explicar el diseño anterior; B07 retira esa ráfaga. Posible reemplazo por daño según la fracción de carga. |
| D20 Ojo compañero | Una veta manual daba +35 % de daño a la ballesta durante cuatro segundos | En revisión. El efecto anterior era un bono de daño. La puntería objetivo del puesto sigue automática al centro; revisar si el bono agrega una decisión deseada. |
| D21 Rayo mellizo | Cada segunda Chispa añadía un rayo de igual potencia | Rediseñar para las flechas de suelo encantadas y la posible cadena de rayos. |
| D22 Larga estación | Bajaba el intervalo de bellotas de 15 a 11 s | Aceptada con valores a ajustar. Si se retiran las bellotas, decidir qué efecto concreto gana frecuencia. |
| D23 Pleno sol | +40 % al daño de los fenómenos comprados | Aceptada. Fijar la lista efectiva de fenómenos y probar bono y combinaciones antes de fijar el porcentaje. |
| D24 Trama de ramas | Un disparo en abanico devuelve una flecha si alcanza **dos blancos distintos** | Explicar y revisar. Tres impactos en el mismo tronco no cumplen esa condición. Hace falta decidir si las dos mitades de un jefe cuentan y si sucede con suficiente frecuencia. |

## Antecedente de campaña

La comparación con *Ammo Dump* dio origen a una propuesta de **22 nodos, 77 rangos y 24 dones**. Los antiguos bloqueos por número de árbol, los seis actos, las doce torretas, el reparto 60/40 y la prima monetaria de combo son antecedentes útiles para leer las fichas. La build de veinte blancos y las decisiones de arriba tienen sus propios valores. [Diseño histórico completo, incluidas sus fórmulas y 77 rangos](https://github.com/manucorrado/archers_lop/blob/654bd1fc91f4c4d5e189df0ead6ed8831f91c9e7/docs/mejoras-y-economia.md) · [Catálogo en Markdown](catalogo-de-mejoras-potenciales.md)
