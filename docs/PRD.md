# El arquero del claro

## Producto y alcance

Juego incremental activo de arquería en primera persona para Windows. Una persona, teclado y ratón, un claro continuo construido con piezas voxel y una campaña offline. Quien juega ya sabe apuntar. La primera compra, el movimiento de los atados y el tiro contra la madera enseñan el funcionamiento del claro. Si cuesta descubrir que golpear con la rama estando vacío desprende flechas, alcanza con una indicación breve en ese momento.

**Build de referencia.** La vuelta disponible llega al blanco 20. Hay elecciones de cartas al romper el 5, el 10 y el 15. El 5 se divide y el 10 tiene tres cavidades sucesivas. El Atlas de Pipo tiene 113 nodos y 141 niveles. El primer rango de daño es gratis. Los récords guardan por separado la llegada al décimo y el cierre del vigésimo. Sus reglas y precios se documentan tal como se pueden probar hoy. [Árbol de la demo](arbol-de-la-demo.md)

**Objetivo de campaña (A01–A09).** Unas dos horas hasta los créditos y entre dos y cuatro hasta el 100 %, sujeto a medición. Completar el juego al 100 % y conseguir todas las mejoras requiere **prestigiar**. Habrá muchos más árboles que los veinte actuales. Cualquier ruta razonable debe poder experimentar el pico de poder. Los veinte actuales deben dejar mejoras del Atlas actualizado pendientes. La secuencia de compras normales depende de requisitos de compra y savia. Los hitos del recorrido pueden entregar cartas y medallas. Las cartas especializan; las compras abren mecánicas. Una buena prueba inicial para una compra importante es poder decir qué hiciste distinto en el siguiente árbol. Hay espacio para compras numéricas cuyo efecto se acumula.

**Numeración.** N significa número de árbol desde el inicio de una vuelta. Un *acto* puede servir para comparar cuánto tarda, por ejemplo, N6–10 en dos versiones y para conservar los tiempos históricos del registro. Diseñar por número de árbol y por barrera evita atar contenido, historia y moneda a grupos de cinco. La cantidad de árboles, los hitos que pagan medallas y el primer árbol prácticamente infranqueable sin prestigio quedan abiertos.

| Documento | Uso |
|---|---|
| [Catálogo de propuestas](catalogo-de-mejoras-potenciales.md) | Las 65 fichas, sus antecedentes, el estado de las familias y las propuestas descartadas. |
| [Sistemas y cartas](mejoras-y-economia.md) | Reglas de combo, puestos, sucesos, fenómenos y decisión individual sobre las 24 cartas. |
| [Curvas de costes e ingresos](curvas-de-costes-incrementales.md) | Cómo calcular y medir precios, vida, daño efectivo, producción, transporte y savia por tiempo de vuelta. |
| [Prestigio](prestigio.md) | Barreras, reinicio, medallas, extensiones del Atlas y tienda de Brizno. |
| [Decisiones pendientes](decisiones-pendientes.md) | Explicaciones, pruebas propuestas y descarte con los IDs del grill. |
| [Producción](plan-de-produccion.md) y [próximas tareas](proximas-tareas.md) | Corte de demo, herramientas de prueba, validación y publicación. |
| [Dirección de arte](arte-y-assets-voxel.md) | Lectura de impactos, puntos débiles, interfaz, animación y presupuesto visual. |

## La vuelta y el reinicio

1. **Disparar.** La madera, la grieta, las cifras y el sonido responden al impacto. El jugador puede apuntar o mantener el tiro. Daño por flecha y cadencia iniciales conservan sus diez niveles. El daño plano anterior a los multiplicadores sigue teniendo valor. El tiempo exacto de soltar la cuerda queda descartado como mecánica a alta cadencia.
2. **Abastecerse.** Se empieza con 24 flechas. El taller catapulta atados; al recoger parte de uno, el sobrante queda en el suelo. La rama permite recuperar flechas estando vacío. En el diseño objetivo la rama puede mejorar alcance y extracción; romper un blanco avanzado solo con ella sería técnicamente posible y muy lento. La máxima combinación de producción, cartas y prestigio debe acercarse a abastecer casi todo el consumo; primer ensayo de 70–80 flechas/s. También importa poder llevarlas.
3. **Invertir.** E cerca de Pipo abre el Atlas. A medida que comprás se revelan los vértices que dibujan arco y carcaj. Los nodos pequeños de daño, velocidad y taller eran relleno provisional. Consolidarlos en menos nodos con niveles o en compras más significativas y volver a medir el costo de una ruta completa. Se considera un segundo dibujo de mejoras al terminar el primero y obtener el prestigio pertinente.
4. **Elegir.** Entre apuntar, buscar el próximo atado y dejar flechas en un puesto se forma el recorrido. Los opcionales pueden ignorarse. Cartas y árboles específicos ofrecen oportunidades para especializar; apuntar al árbol principal sigue siendo viable. Se esperan pausas en el crecimiento y momentos en que algunos árboles se derriten.
5. **Prestigiar.** Brizno explica la primera oportunidad con un salto y giro. Se ven medallas pendientes, cobro disponible, siguiente hito y consecuencias del reinicio. El jugador decide si espera otra medalla o empieza una vuelta con capacidades acumulables que le permiten cruzar una barrera antes prohibitiva. N20 es el primer banco de prueba interno. [Definición y dudas del prestigio](prestigio.md)

## Encuentros y barreras

La altura del árbol comunica importancia e intimidación. La maqueta de escala conserva una piedra de referencia; el objetivo histórico para N10 era cerca del doble de ancho y cinco veces la altura del primero. Hay un solo árbol principal y habitualmente una sola parte golpeable. Un efecto que necesita tres blancos distintos requiere contenido que los presente.

| Referencia | Build y decisión para la siguiente versión |
|---|---|
| J01 · N5, árbol partido | Mantener las dos mitades con vida propia y quitar las dianas centrales dibujadas en ambas. Comparar apuntar a una sola mitad con alternar lados o acumular fuego en cada una. |
| J02–J03 · N10, tres cavidades | Conservar el orden en la presentación inicial. Guardar el orden libre o el punto móvil como posibles variantes de desafío. Representar huecos reales; al agotar una cavidad se desprende ese trozo o queda inequívocamente agotado. El término «abanico» describe tres flechas que se separan desde el arco. El aumento de escala tiene prioridad estética. |
| J04, J10 · vida y barreras | Los anteriores ×100 de N11–19 y ×1.000 de N20 fueron experimentos de daño. Diseñar una función de vida por número de árbol con factor adicional por jefe o barrera; ×10 en N10 es un ejemplo del autor, pendiente de calibrar. Usar corteza resistente si se puede reconocer y contrarrestar. Probar un blanco que se derrite tras una gran compra y otro que permita usarla varias veces. |
| J05 · Semillero fugitivo, antiguo N15 | Propuesta histórica: brotes cruzan carriles y al acertarles transfieren daño al árbol central. Revisar si merece ese encuentro. Hoy N15 entrega carta. |
| J06 · Corona acorazada, antiguo N20 | Prototipo por evaluar: placas que los puestos desgastan y broches que el arquero puede abrir. Hoy N20 cierra la vuelta. La idea debe funcionar con pocos puestos fijos. |
| J07 · Dos cauces, antiguo N25 | Propuesta por testear: interrumpir un pulso de una raíz abriría una veta; si pasa, aparece una cubierta temporal con tope. Conserva el daño ya hecho. |
| J08 · Sol hueco, antiguo N30 | Propuesta por testear: abrir dos mitades, elegir una carta a media vida y alternar veta y brotes al cerrar. Evaluar utilidad de las tres cartas durante el combate restante, incluida producción si quedan viajes. |
| J09 · Recuperación | Cada fase necesita una forma de recuperar munición o acceder a madera alcanzable. La referencia de equilibrio es poder reabastecerse y volver a disparar. |

La cadencia de oportunidades individuales, semillas, rayos, posible rayo solar y sucesos simultáneos tardíos se decide por su utilidad frente a este único árbol. [Oportunidades y fenómenos](mejoras-y-economia.md)

## Interacción, interfaz y persistencia

| Acción | Control en PC | Comportamiento |
|---|---|---|
| Mirar y desplazarse | Ratón y WASD | Movimiento libre por terreno continuo. Los puestos y los haces son accesibles a ras del suelo. |
| Disparar | Botón principal | Pulsar dispara y mantener repite al ritmo del arco. Un ajuste permite iniciar y detener la repetición con un clic. La animación y el sonido comunican cada suelta. |
| Apuntar con precisión | Botón secundario | Acercamiento suave configurable. La misma veta puede acertarse desde la vista normal. |
| Cambiar de arco | 1–3 o rueda | Entre los ya adquiridos. Se conserva el carcaj compartido. Un cambio de arma respeta el tiempo pendiente de la última suelta. |
| Golpear con la rama | F | Acción de corto alcance disponible desde el inicio. Con el carcaj vacío permite recuperar flechas. |
| Abastecer | E junto al centinela | Vista previa de la transferencia, entrega confirmada por sonido y cambio visible en la tolva. Se preserva una reserva para el jugador. |
| Comprar, pausar y guardar | E junto al perro abre el árbol. Esc abre pausa. | Clic para comprar un nivel. Con la mejora de reembolso, clic derecho para devolverlo. La simulación se detiene en árbol, cartas y pausa. |

La versión jugable permite equipar tres arcos. Probar el cuarto y revisar los arcos tardíos antes de fijar su cantidad. Contemplar una indicación de la transferencia efectiva al abastecer y la elección de habilidades que compitan por un botón. Mantener todas las opciones y señales en español e inglés. El arquero carece de barra de vida y un fallo cuesta tiempo o munición. En una pausa manual o con el juego cerrado se detienen la simulación y el taller. [Controles de la build](../README.md)

| Área | Dirección acordada |
|---|---|
| Atlas y fichas (I01–I04) | Distinguir disponible, parcialmente comprado, completo y fuera de presupuesto en ambos aspectos del Atlas y con foco de teclado. Mostrar efecto actual y siguiente, precio y saldo posterior, sujeto a iteración. Probar resplandor y pequeño movimiento para compras que cambian mecánicas. |
| Efectos de combate (I05–I09) | Diseñar señales distintas para racha, triple y lluvia. Triple muestra **un solo número con la suma de los tres impactos**. Cargas de fuego debajo de la vida, daño sobre la madera junto a su animación. La interfaz existente ya muestra el carcaj vacío; el crítico preparado no necesita indicador. Agregar pictograma de carcaj junto al contador. Probar sonido con varias cadencias y densidades de eventos. |
| Atlas completo (I06) | La imagen de arco y carcaj aparece gradualmente, luego desaparece gradualmente y vuelve el árbol interactivo. Definir comportamiento tras reembolso. |
| Ayudas, Pipo y Brizno (I10–I12) | Sin reactivar las pistas tutoriales al prestigiar. Conservar la caricia a Pipo como compra tardía, previsiblemente mucho más cara tras rebalancear. Brizno es tienda de prestigio y vehículo narrativo, con muy pocas reacciones al fuego o a hitos. El autor escribe y cura su texto; el material actual es provisional. |
| Guardado | Conservar vida por fase, inventarios, cartera, compras y su costo pagado, arcos, ofertas y reloj. Hacer recuperables medallas y compras permanentes. Al confirmar un reinicio se muestran los bienes que se entregan y los que se conservan. |
| Lectura y comodidad | Retícula, sensibilidad, campo de visión, números agrupables, cámara y destellos reducibles. Probar con audio apagado. El golpe, la acción disponible y el objetivo golpeable deben poder reconocerse aun sin números. |

## Narrativa, demo y edición final

El número de árboles restantes puede vincular el progreso a la historia; «quedan 500 árboles en todo el mundo» es una **premisa por explorar**. Resolver qué cuenta el mundo y qué vuelve al prestigiar antes de escribir ese contador. Otro candidato es un desenlace verdadero en un espacio liminal totalmente blanco, con una conversación larga con Brizno. Definir acceso, relación con créditos y 100 %, y si existe desafío final. Al concluir quedan vueltas libres.

La siguiente demo requiere principalmente **balance de mejoras, balance económico y algunas conversaciones de Brizno escritas por el autor**. La prueba privada precede a la distribución. Delimitar en una conversación específica qué alcanza para publicar y qué se posterga; el catálogo amplio y las ideas de prestigio alimentan la campaña. Se mantienen Windows, español e inglés y la intención de publicar en itch.io y Steam. El precio histórico previsto para la edición final era 1–2 €, a decidir al preparar el lanzamiento.

Para validar, registrar **dos vueltas completas con cartas diferentes**, tanto con el autor experimentado como con jugadores nuevos. Que el autor llegue en cinco minutos a un final pensado para unas dos horas sería una alarma de balance. Comparar tiro continuo, abastecimiento y efectos con igual semilla y presupuesto. Medir tiempo total y activo, paso por árbol, segundos vacío, saldo y compras al entrar a N10, daño por fuente y tiempo de vuelta al superar una barrera. Más adelante, incluir dos rutas con iguales medallas y compras permanentes distintas. [Plan de producción y pruebas](plan-de-produccion.md)

La documentación original que tradujo la referencia *Ammo Dump* conserva los antecedentes sobre los seis actos, las máquinas, torretas y reglas históricas. [PRD anterior a esta revisión](https://github.com/manucorrado/archers_lop/blob/654bd1fc91f4c4d5e189df0ead6ed8831f91c9e7/docs/PRD.md)
