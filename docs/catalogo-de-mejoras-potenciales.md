# Catálogo de mejoras del arquero

El catálogo reúne las decisiones de diseño del 27 de noviembre de 2026, las 65 fichas del documento de trabajo original y la evaluación de las 40 propuestas ofensivas. Los códigos permiten volver a la respuesta que cambió cada idea. **Acordado** describe el diseño elegido. **A probar** identifica una variante que necesita partida y balance. **Abierto** indica qué falta explicar o elegir. **Deprecado** conserva una propuesta retirada.

- [Arcos, daño y proyectiles](#arcos-daño-y-proyectiles)
- [Quemadura](#quemadura)
- [Precisión y trayectorias](#precisión-y-trayectorias)
- [Producción y carcaj](#producción-y-carcaj)
- [Movimiento y rama](#movimiento-y-rama)
- [Otros estados y apoyos](#otros-estados-y-apoyos)
- [Lista histórica de 40 propuestas ofensivas](#lista-histórica-de-40-propuestas-ofensivas)
- [Archivo de las 65 fichas](#archivo-de-las-65-fichas)

Las cifras de la versión jugable se consultan en [el árbol de la demo](arbol-de-la-demo.md). La [economía y las cartas](mejoras-y-economia.md) y el [diseño de campaña](PRD.md) describen cómo encajan las familias entre sí. Las familias acumulables y las exclusivas se detallan en [Prestigio y tienda de Brizno](prestigio.md), y los efectos retirados tienen un [registro de descarte](decisiones-pendientes.md). El objetivo es que dos personas puedan gastar la misma savia de maneras distintas y terminar una ruta razonable. El balance tiene que dejar compras por perseguir después de los veinte árboles actuales.

## Arcos, daño y proyectiles

| Ref. | Mejora | Decisión de diseño |
| --- | --- | --- |
| T01 | Daño por flecha · Pulso de madera | **Acordado.** Primer nivel gratuito, diez rangos de +20 % del daño base de cada arco. El primer nivel sube el impacto del arco de rama de 10 a 12. |
| T02 | Punta reforzada | **A revisar en balance.** El +1 plano entra antes de los multiplicadores, de modo que también puede aportar en el tramo tardío. Los 31 vértices actuales son provisionales. Concentrar parte de ellos en nodos con niveles y liberar espacio para otras mecánicas. Medir flechas por rotura, temprano y tarde. |
| T03 | Potencia multiplicada | **Acordado.** Mantener los tres primeros ×1,2 sobre el daño acumulado. Situar los futuros escalones junto a encuentros que permitan aprovecharlos. |
| T04 | Velocidad de ataque · Ritmo de suelta | **Acordado.** Diez niveles iniciales de +12 % sobre la cadencia base del arco equipado. |
| T05 | Suelta ágil | **A revisar en balance.** Los 36 vértices del +2 % de cadencia también son provisionales. Conservar los incrementos que tengan valor en la fórmula y agruparlos en menos nodos con niveles al introducir modificadores de disparo. |
| T06 | Disparo adicional | **A probar.** El +1 suelta/s por rango sirve en los tres arcos. Hoy da demasiado poder por su precio. Comparar un beneficio menor y un precio mayor, mostrando el consumo real de munición cuando está activo el triple. |
| T07 | Arco de rama | **Abierto.** La eficiencia de munición o un tiro de precisión propio podrían darle identidad tardía. Hoy apuntar con y sin zoom requiere un esfuerzo parecido. Hace falta una mecánica que justifique esa diferencia antes de construir una especialización alrededor del zoom. |
| T08 | Arco rápido · recurvo | **Acordado.** Mantener su función de presión sostenida con mayor consumo. Referencia de la build: 11 de daño, 2,5 sueltas/s y 370 de savia. Comparar el momento en que se consigue ahorrando o comprando el taller primero. |
| T09 | Arco largo | **Acordado.** Sus 22 de daño por flecha ya lo favorecen cuando falta suministro a mitad o al final de una vuelta. Medir esa ventaja con el mismo carcaj antes de agregarle otra especialización. La build parte de 2 sueltas/s y un precio de 16.700. |
| T10 | Arco en abanico | **A probar en balance.** El diseño de campaña lo situaba en el árbol 12. Como el triple universal ya existe, probar una versión mucho más tardía que, combinada con él, dibuje una matriz de proyectiles tipo escopeta. Definir apertura y gasto viendo el resultado. |
| T11 | Arco de tejo repetidor | **A probar.** Partir de cuatro sueltas/s y medir la ráfaga con un suministro real. Diez por segundo parece excesivo como cadencia base. |
| T12 | Cadencia alta | **Acordado.** Buscar varios segundos de ráfaga sostenida y reconocible. Distinguir sueltas, proyectiles que salen del carcaj e impactos de lluvia al medirla. |
| T13 | Secuencia de arcos | **Acordado.** Cada desbloqueo debe sentirse poderoso en su estreno. Volver al anterior puede surgir por eficiencia o gusto, sin convertirlo en requisito de diseño. |
| T14 | Triple al alcanzar daño 10 | **Aclaración pendiente.** «Triple» describe hasta tres flechas de una suelta, al comprar **el nivel 10 de Daño**. Cada flecha conserva su daño individual; la build consume hasta tres flechas y dispara la central si queda una. Probar apertura a distintas distancias. **Candidato de prestigio:** reducir el gasto de los tiros múltiples, posiblemente hasta una sola flecha. |
| T15 | Lluvia de flechas | **Acordado.** Disponible para cualquier arco. Cada flecha gastada llama otras tres al mismo punto. Con triple y tres de munición hay tres primarias y nueve de lluvia. El tiro dirigido abre cavidades y cobra dianas. Para el triple, sumar el daño de sus tres primarias en **un único número**. |
| T16 | Tiro sostenido | **Abierto.** La build premia con +20 % la cuarta suelta seguida incluso si las anteriores fallaron. Comparar mantener cadencia y exigir aciertos, distinguiéndolo de Tercera hoja, que ya premia una secuencia de aciertos. |
| T17 | Primer tiro después de recargar | **A probar.** Una mejora prepara una sola flecha al salir del estado vacío, también tras recoger parte de un atado. Falta lograr que el beneficio se sienta en combate. |
| T18 | Tiro alternado | **Deprecado.** El bono histórico de rama seguida de rápido obligaría a cambiar de arco repetidamente. A alta cadencia el gesto estorba al tiro. |
| T19 | Última flecha | **A probar en balance.** Dar más daño a la última flecha del carcaj si acierta al cuerpo. Contrastar ese beneficio con el coste de vaciar el carcaj tirando al aire. |
| T20 | Golpe crítico | **Acordado.** Separar los rangos de probabilidad y multiplicador. La build parte de un 10 % de probabilidad de duplicar el daño de esa suelta. Mostrar los dos valores al comprar. |
| T21 | Crítico preparado | **Acordado.** Una diana difícil puede garantizar el crítico de la próxima suelta, incluso cambiando al arco largo. El indicador extra en el HUD se descartó en I07. |
| T22 | Tensado perfecto | **Deprecado.** La cadencia crece demasiado pronto para exigir soltar en un instante exacto. Conservar el clic y la repetición sostenida. |
| T23 | Tiro que consume recursos | **Abierto.** Probar una gran descarga que cueste munición. Una variante propuesta es un arco que vacía el carcaj entero en un único impacto muy potente. Comparar coste fijo y carcaj completo con diferentes capacidades. |
| T24 | Daño porcentual sobre vida actual | **Candidato de prestigio.** Probarlo en aperturas y jefes de mucha vida. Falta decidir porcentaje, límite y frecuencia. La variante histórica de una vez por parte con tope queda como ensayo posible. |
| T25 | Bono por rotura | **Acordado.** Se obtiene mediante mejora o prestigio. La ventana de daño empieza cuando se puede golpear al siguiente árbol, después de la transición y de cualquier carta. |
| T26 | Arco láser | **A probar en el tramo final.** Comparar haz continuo, pulsos muy rápidos y flechas convertidas en líneas de luz. Ofrecer **más de un tronco** para disfrutarlo. Probar legibilidad, sonido, impacto sostenido y suministro. |
| T27 | Munición del láser | **Abierto.** Decidir con el prototipo entre gastar flechas normales, transformar una reserva cargada en segundos de emisión o disponer de una ventana sin coste. |

## Quemadura

Una flecha puede prender la parte alcanzada. Cada aplicación añade una carga que sigue causando daño entre disparos. Quedarse a tirar permite acumular más cargas. El viaje al taller permite comprobar cuánto tarda en decaer el fuego.

| Ref. | Aspecto | Decisión de diseño |
| --- | --- | --- |
| F00 | Acceso por prestigio | **Dirección preferida, por confirmar.** Una compra permanente puede habilitar la familia de fuego y sus nodos en un Atlas extendido. La primera compra, su coste en medallas y el acceso dentro de la vuelta quedan por precisar con X07. Las familias se pueden combinar libremente. |
| F01 | Conducta principal | **Acordado.** El interés principal es acumular cargas disparando. Medir cuántas quedan al volver de una recogida breve. |
| F02 | Probabilidad | **Acordado.** 10 % independiente por flecha elegible, sin protección frente a rachas de mala suerte. |
| F03 | Triple y lluvia | **Acordado.** Cada primaria que sale del carcaj puede aplicar una carga al acertar. Tres primarias consumidas dan hasta tres oportunidades. Las flechas gratuitas de la lluvia hacen daño directo y quedan fuera del sorteo de estados. |
| F04 | Fallo | **Acordado.** Una incendiaria que falla se pierde. El disparo siguiente vuelve a tener su propia oportunidad. |
| F05 | Dónde se acumula | **Acordado.** En un árbol común existe una sola reserva de cargas. Las mitades con vida propia conservan reservas independientes y el impacto solo prende la que alcanzó. |
| F06 | Daño periódico | **Dos ensayos.** A: cada carga guarda una fracción del daño de la flecha que la aplicó. B: usa una fracción mucho menor de la vida del blanco. Comparar ambos modelos en un árbol normal y en una barrera con gran multiplicador de vida. Elegir la base de vida, el porcentaje y el intervalo con esas pruebas. |
| F07 | Pérdida de cargas | **Acordado.** Tras dejar de aplicar fuego, las cargas caen de a una. El intervalo entre pérdidas se acorta progresivamente hasta que se refresca la aplicación. Medir el margen de una recogida real. |
| F08 | Tope inicial | **Punto de partida.** Probar cinco cargas. Revisar el límite midiendo cuánto tarda en llenarlo el arco de rama frente al rápido. |
| F09 | Especialización de acumulación | **A probar.** Quitar el límite de verdad. Medir el daño que alcanza una acumulación larga y su efecto en un jefe antes de fijar el balance. |
| F10 | Especialización de potencia | **Acordado.** Subir el daño de cada carga por separado. Debe rendir también con fuegos cortos y arcos de menor cadencia. |
| F11 | Especialización de duración | **A probar.** Empezar por espaciar las pérdidas. Probar otra regla de duración si no se percibe al volver desde el taller. |
| F12 | Combinación | **Acordado.** Acumulación, potencia y duración son compatibles, con costes que permitan especializarse al principio. Precisar dónde se compra el acceso inicial a estas mejoras una vez definido el desbloqueo de prestigio. |
| F13 | Bonos y críticos | **Acordado.** El fuego funciona como una fuente propia. Mantener separada su base de los críticos de la suelta, la veta y el tiro sostenido. **Candidata:** una probabilidad de crítico específica del fuego. |
| F14 | Rotura, savia y racha | **Acordado.** El daño periódico puede romper el árbol y pagar savia por los puntos de vida efectivos que quita. El contador de racha de puntería lo alimentan las sueltas manuales. |
| F15 | Cambio de blanco | **Acordado.** Al morir el blanco se pierden sus cargas. **Candidata:** una compra que transfiera cargas al siguiente. Precisar aparte qué ocurre si se cierra temporalmente una cavidad cuya parte sigue viva. |
| F16 | Lectura | **Acordado.** Mostrar un icono y la cantidad bajo la barra de vida. Agrupar el daño periódico sobre la madera, cerca del fuego. El HUD puede prescindir del ritmo de pérdida. |
| F17 | Veneno y veneno acumulativo | **Deprecado.** Conservar en el historial la segunda familia de daño continuo y su variante de transmisión entre partes. |
| F18 | Mejora general de daño de estados de armas | **Deprecado.** La búsqueda de nuevas compras para prestigio sigue abierta. |

## Precisión y trayectorias

| Ref. | Mejora | Decisión de diseño |
| --- | --- | --- |
| H01 | Ojo de veta | **Por explicar y decidir.** En la build, con una flecha que quita 10 al cuerpo, la veta quita 15 antes de comprar y 20 después. El diseño histórico escalonaba el multiplicador hasta ×2,25. Resolver si se desea ese salto único, rangos tardíos, o trasladar parte de la especialización al combo. La propuesta de cambiar la carta Ojo de búho figura en D05. |
| H02 | Daño específico | **Acordado.** Especializarse contra partes vulnerables y objetivos laterales identificables. |
| H03 | Anchura y ventana | **Acordado.** Dos compras distintas. Una amplía el área dibujada y la que acepta el impacto en igual medida. La otra mantiene el punto vulnerable visible más tiempo. El punto débil pasará a un círculo luminoso integrado en la madera. |
| H04 | Cambio de lado | **A probar.** Tras acertar una parte viva, bonificar el primer impacto sobre otra dentro de una ventana corta. Comparar en un tronco dividido con concentrarse en un lado. |
| H05 | Remate de una parte | **A probar.** Aumentar el daño de las flechas cuando a la parte le queda poca vida. El exceso termina en esa parte al abrirse una fase. |
| H06 | Marca de preparación | **Deprecado.** Queda archivado golpear una raíz con la rama para aumentar después el daño de las flechas sobre ella. |
| H07 | Tiro lejano | **Acordado para prestigio.** Aumentar el daño por metro de distancia. Probar en tiros precisos y medir cómo afecta la decisión de salir a recoger. Alcance, progresión y superficie elegible requieren balance. |
| H08 | Eco fantasmal | **Acordado.** Copiar la trayectoria del tiro con un retraso corto, daño parcial y sin gastar otra flecha. Dibujarlo translúcido, azul verdoso. **Candidata:** una carga necrótica que haga al blanco más vulnerable al daño recibido. |
| H09 | Flecha de eco lateral | **A probar por separado.** Tras acertar una veta, saltar a otra parte vulnerable o blanco lateral cercano. Referencia histórica: 8 m, un eco por suelta y 20/40/60 % de daño. Comparar en encuentros con dos destinos válidos. Darle nombre y señal distinguibles de la copia fantasmal. |
| H10 | Interacciones de eco | **Descartadas de entrada.** Ambas propuestas de eco infligen daño secundario. El eco no hace crítico ni genera fuego, lluvia u otro eco por defecto. |
| H11 | Astilla de rebote | **Deprecada por ahora.** Es la astilla lateral que surgiría al casi acertar una veta. Se distingue de la astilla al apuntar con zoom de X02, considerada de poco impacto para prestigio. |
| H12 | Rebote físico | **Condicionado.** Reabrir cuando exista una superficie y un ángulo que permitan alcanzar deliberadamente un objetivo fuera de la línea recta. |
| H13 | Cadena entre vecinos | **A probar cuando existan grupos.** Distancia corta, destinos distintos y menos daño por salto. Vincularla a la flecha empoderada por la nueva Chispa. |
| H14 | Penetración | **A probar.** Atravesar una hilera de blancos o brotes y conservar la utilidad de acertar a uno solo. |
| H15 | Daño de área al impactar | **Deprecado por ahora.** El árbol suele ser el único objetivo y normalmente tiene una sola parte. |
| H16 | Potencia de los proyectiles generados | **Acordado.** Mejoras separadas para cada familia que se implemente, por ejemplo eco y lluvia. |
| H17 | Golpe adicional gratis | **Deprecado por ahora.** La flecha extra automática genérica queda en el historial junto a las copias ya cubiertas por eco y lluvia. |

## Producción y carcaj

| Ref. | Mejora | Decisión de diseño |
| --- | --- | --- |
| L01 | Primer taller | **Acordado.** Quieto se puede recoger una parte suficiente para reconocer la fuente. Recorrer los sectores debe seguir dando una ventaja clara, ya perceptible en la build. Medir la proporción sin fijarla de antemano. |
| L02 | Producción del taller | **Acordado como familia.** Abrir mejoras de producción por segundo, tamaño de lote y, potencialmente, un segundo taller. Algunas de las más fuertes pueden ser de prestigio. Comparar cuánto llega al suelo, cuánto se recoge y cuánto tiempo se pasa vacío. |
| L03 | Rueda de savia y engranajes | **A revisar en balance.** Los numerosos +0,025 flechas/s son provisionales. Concentrarlos en nodos con niveles o en compras más caras que aumenten la producción de forma perceptible. Mostrar el tiempo entre atados. |
| L04 | Tandas más grandes | **A probar.** Más flechas por tanda deben aumentar proporcionalmente la producción por minuto. Probar el rendimiento de cada viaje y el tiempo entre lanzamientos. |
| L05 | Selector de caída | **A probar.** Elegir un sector y, al mejorar, fijar dos o tres destinos para que todos los lotes caigan allí. Observar si todavía se disfruta usar el salto dirigido para recorrerlos. |
| L06 | Taller adicional | **Acordado para prueba.** Añadir un segundo taller antes de considerar más. Los seis talleres del plan inicial son una referencia histórica. |
| L07 | Carcaj de viaje | **Acordado.** Ampliar la progresión de 24 → 40 → 56 hacia 104 y eventualmente más, a medida que el suministro pueda llenarlo. **Pendiente de interfaz:** sumar un pictograma de carcaj donde hoy se muestra la munición. |
| L08 | Recogida de hojas | **Descartada para ampliar por ahora.** Durante la prueba, aumentar el radio de recogida resultó poco perceptible. La compra 1,5 → 2,25 m sigue documentada como comportamiento de la build. Hojas imantadas también está descartada en D09. |
| L09 | Compartimento de reserva | **Abierto.** La idea de guardar flechas físicas en el taller y soltarlas cuando el carcaj queda vacío aún no convence. Compararla con la candidata de recarga de emergencia de prestigio antes de dedicarle un nodo. |
| L10 | Flecha recuperada · Brote de recambio | **Acordado.** Devolver una flecha **cada cinco disparos** acertados o fallados. La unidad es la suelta: una suelta triple cuenta una vez. Aplicar el límite del carcaj. Elegir una procedencia principal para la mejora (D11). |
| L11 | Rotura abundante · Cosecha doble | **Acordado.** Emitir un solo haz por árbol completo, incluso si se divide. Que la cantidad sea mejorable. Otra mejora podría lanzarlo hacia la zona aproximada de aparición del jugador. La posición instantánea del arquero no determina la caída. El valor de la carta histórica de 8 → 16 se revisa por separado en D12. |
| L12 | Compra por adelantado | **A probar.** Pagar savia por un lote que se agrega a la tanda siguiente. Medir precio y frecuencia como gasto de emergencia frente al coste de invertir en producción permanente durante la vuelta. |
| L13 | Abundancia física | **Acordado.** Los grupos grandes representan cantidades reales. La recogida parcial deja el sobrante en el mismo lugar. Poder reconocer visualmente una reserva grande, incluida una de 500 en el suelo. Decidir por separado si merece una hazaña (P14). |
| L14 | Máximo de producción | **Objetivo de prueba.** Arrancar por **70–80 flechas/s** al combinar el máximo de compras, prestigio y cartas. El objetivo es poder abastecer casi cualquier consumo en esa situación. Comparar producción bruta, recogida efectiva y consumo conjunto de arco y ballestas. |
| L15 | Cuello de botella | **Acordado.** Tanto producir como transportar deben seguir importando en el tramo tardío. Un montón fuera de alcance cuenta en la producción bruta, pero llega al arquero o al puesto después del viaje. |
| L16 | Reloj de producción | **Acordado.** Respetar la preferencia actual de seguir en segundo plano al cambiar de ventana. Parar producción al pausar manualmente o cerrar el juego. Identificar si cada reto usa tiempo activo, tiempo total o unidades producidas. |

## Movimiento y rama

| Ref. | Mejora | Decisión de diseño |
| --- | --- | --- |
| M01 | Paso del porteador | **Cambio a probar.** Sustituir +6 % con cuatro flechas por aproximadamente **+15 % de velocidad mientras quede al menos una**. La carta Paso ligero daría +25 % siempre y se combinaría con otros bonos (D10). |
| M02 | Salto al atado | **Acordado.** Probar ambas ampliaciones: mayor alcance y encadenar el viaje con otro salto. Comparar rutas entre los sectores del taller. |
| M03 | Selección de atado | **Acordado.** Entre destinos alcanzables, elegir el más alineado con la mira y anunciar ese destino antes del salto. Fuera de esa intención se conserva el salto libre. |
| M04 | Impulso al recoger | **Acordado como mejora.** Velocidad temporal al recoger un atado nuevo. El sobrante de la misma tanda no vuelve a activarla. |
| M05 | Agarre en movimiento | **Deprecado.** Queda archivado disparar tras recoger conservando un bono de movimiento mientras se apunta. |
| M06 | Recogida en el aire | **A probar.** Interceptar una tanda lanzada podría aportar sus flechas y una prima pequeña de savia, una vez por tanda. Si se la deja pasar, aterriza completa. Falta revisar si la recompensa justifica la jugada. |
| M07 | Tiro tras aterrizar | **Deprecado.** Se retira el daño adicional a la flecha siguiente tras aterrizar cerca de un atado. |
| M08 | Paso entre recogidas | **Por aclarar.** La «racha» propuesta era la de puntería de Buena racha. Levantar flechas en **dos sectores distintos** prolongaría su ventana. La alternativa de C05 consiste en que una compra sostenga el combo alrededor de un segundo al recoger un lote, sin pedir un circuito de dos sectores. Decidir si aporta algo la segunda condición. |
| M09 | Tiro en el aire | **Acordado.** El bono se decide en el momento de soltar mientras el arquero está en el aire. Puede impactar después del aterrizaje. |
| M10 | Giro de 360° | **Variante a probar.** Un giro completo en cualquiera de los sentidos durante el mismo salto y un tiro acertado dentro de una ventana breve. La respuesta admite la ejecución tardía y opcional; M11 condiciona qué premio conviene asignarle. |
| M11 | Frecuencia y recompensa del giro | **Límite de diseño.** Dejarlo como adorno expresivo o hazaña. Excluir la repetición obligada de giros de la rutina central de daño. Definir si hay algún premio puntual compatible con ese criterio y con el confort. |
| M12 | Eficacia y alcance de rama | **A probar.** Priorizar cuántas flechas se extraen con el carcaj vacío y desde qué distancia. El golpe seguirá siendo una fuente marginal de daño. La referencia de la build es una extracción de cuatro con cuatro segundos de espera. |
| M13 | Golpear y retroceder | **Por aclarar.** La ficha proponía que, tras tocar madera con la rama, mantuvieras la tecla de retroceso para volver más rápido a distancia de tiro. El jugador controla dirección y momento. Decidir si hay una necesidad real, especialmente junto a una pared o un atado. |

## Otros estados y apoyos

| Ref. | Propuesta | Decisión de diseño |
| --- | --- | --- |
| Y01 | Daño de todo el equipo | **Deprecado.** La lista original lo proponía en dos entradas. El juego actual carece de grupo de aliados. Los puestos tienen su propia familia de potencia. |
| Y02 | Mascotas o invocaciones ofensivas y su daño | **Deprecado.** Pipo conserva su papel de compañero y acceso al Atlas. |
| Y03 | Sombra o duplicado ofensivo del arquero | **Deprecado.** El eco fantasmal H08 copia un proyectil. |
| Y04 | Inspiración de grupo | **Deprecado.** Se archiva la bonificación temporal que haría que parte de los aliados infligiera su daño máximo. |
| Y05 | Aliado temporal que potencia al grupo | **Deprecado.** Se archiva el visitante temporal que aumentaría el daño grupal. |
| Y06 | Aturdimiento y vulnerabilidad | **Abierto.** Hace falta definir qué objetivo puede detenerse y cómo aprovechar el tiempo de daño extra. Probar cuando exista una parte móvil o un brote que dé sentido a la inmovilización. |
| Y07 | Aturdimiento frontal por probabilidad | **Deprecado.** Queda fuera la segunda variante por acertar en una cara frontal. |
| Y08 | Congelación | **Nueva interpretación a probar.** Durante X segundos se acumula el daño que habría recibido el blanco. Al terminar, aplicarlo de golpe con un multiplicador. Definir duración, factor, qué fuentes entran, transición de fase y momento de entrega de la savia. La lista original proponía ralentizar movimiento o ataques. |
| Y09 | Drenar o robar ataque | **Deprecado.** Se descarta también convertir el supuesto drenaje en una transferencia desde una cubierta hacia la próxima flecha. |
| Y10 | Pila de descarte | **Acordado.** Conservar por nombre las ideas retiradas y el motivo conocido. Una reapertura será una nueva decisión de diseño. |

## Lista histórica de 40 propuestas ofensivas

Se conserva la numeración de la lista aportada. Dos entradas describían daño grupal. Las referencias remiten a la decisión del grill incluso cuando el efecto cambió de forma.

| Nº | Propuesta original | Equivalencia y estado |
| ---: | --- | --- |
| 1 | Aumenta el daño base de los ataques físicos o disparos (porcentaje de daño). | T01–T03 · Conservar aumentos de daño base y medir el aporte plano tras multiplicadores. |
| 2 | Incrementa el daño infligido por todos los héroes aliados (multiplicador global de daño de equipo). | Y01 · Deprecado por ausencia de equipo de aliados. |
| 3 | Aumenta el daño de las invocaciones o mascotas de apoyo. | Y02 · Deprecado con las mascotas ofensivas. |
| 4 | Potencia el daño de ataques especiales o habilidades heróicas (por ejemplo, amplifica el daño de habilidades tipo War Cry o Deadly Strike). | E10–E11 · La potencia individual y global interesa para efectos definidos. Falta identificar el especial que serviría como primer caso. |
| 5 | Mejora el multiplicador de daño crítico (incrementa cuánto más daño hacen los golpes críticos). | T20 · Rangos de multiplicador separados de la probabilidad. |
| 6 | Aumenta la probabilidad de golpe crítico en los ataques. | T20 · Rangos de probabilidad separados del multiplicador. |
| 7 | Aumenta la velocidad de ataque o de clic (más golpes/disparos por segundo). | T04–T06 · Diez niveles base de cadencia. Reagrupar los pequeños y rebalancear +1 suelta/s. |
| 8 | Genera golpes adicionales automáticos al atacar (ataques extra gratis al presionar). | H17 · Golpe adicional automático genérico, deprecado por ahora. |
| 9 | Incrementa la cadencia en ráfagas de ataque sucesivas (acumular golpes consecutivos aumenta el multiplicador de daño). | T12, T16, D06 · Buscar ráfaga sostenida reconocible. Comparar premio por mantener ritmo con premio por aciertos consecutivos. |
| 10 | Acelera la generación de proyectiles al disparar (más balas lanzadas por ataque). | T10, T14–T15 · Triple y lluvia ya generan varios proyectiles. Probar la matriz tardía y estudiar el ahorro de flechas del triple por prestigio. |
| 11 | Inflige daño de área (splash) a múltiples enemigos cercanos al impactar. | H15, E08 · Salpicadura de impacto deprecada por ahora. La frecuencia de blancos múltiples condiciona el valor del área. |
| 12 | Proyectiles rebotantes: cada rebote en superficies genera disparos adicionales que golpean otros blancos. | H11–H12 · Astilla por casi acierto deprecada. El rebote físico requiere una superficie que permita dirigirlo a un segundo blanco. |
| 13 | Proyectiles encadenantes (chain lightning): los ataques saltan automáticamente a varios enemigos contiguos. | H13, E01–E02 · Posible cadena de la munición empoderada. Probar destinos diferentes, alcance corto y pérdida de daño por salto. |
| 14 | Disparos penetrantes: los proyectiles atraviesan enemigos, dañando a los siguientes en línea. | H14 · Probar penetración en blancos alineados y verificar su utilidad con un único acierto. |
| 15 | Invoca ataques de área masivos (por ejemplo, meteoritos o explosiones que dañan a todos los enemigos). | E04, E07–E08 · Meteorito y explosión quedan bajo revisión por la escasez de grupos. Se prefiere probar un rayo solar sobre el árbol. |
| 16 | Aplica veneno: el objetivo recibe daño continuo tras ser golpeado. | F17 · Veneno deprecado. |
| 17 | Aplica quemadura: inflige daño progresivo adicional por un tiempo (efecto incendiario). | F00–F16 · Probar fuego acumulable, con probable acceso desde prestigio. La probabilidad inicial es 10 % por flecha elegible. |
| 18 | Aturde al enemigo: tras el impacto, el enemigo queda paralizado brevemente y recibe daño extra durante ese aturdimiento. | Y06 · Queda por diseñar la ventana de vulnerabilidad de un blanco móvil. |
| 19 | Ralentiza o congela al enemigo: reduce la velocidad de ataque/movimiento tras el golpe (efecto helada). | Y08 · Ensayar congelación que acumula el daño y lo libera multiplicado al terminar. |
| 20 | Causa daño porcentual sobre la salud actual del enemigo (ataque basado en % de HP restante). | T24, F06 · Candidata de prestigio. Ensayar también una variante de quemadura por fracción muy pequeña de vida. |
| 21 | Invoca aliados o mascotas adicionales que atacan automáticamente al enemigo. | Y02 · Invocar aliados o mascotas atacantes queda deprecado. |
| 22 | Despliega torretas o dispositivos automáticos (p. ej. cañones) que disparan a los enemigos. | B05, B10–B11 · Ballestas en posiciones fijas. Probar dos, con hasta cuatro mejorables; se descarta colocarlas libremente. |
| 23 | Crea duplicados/sombras del personaje que atacan junto a ti (ataques paralelos adicionales). | Y03, H08 · Duplicado del arquero deprecado. La copia fantasmal admitida sigue la trayectoria de una flecha. |
| 24 | Proyectiles especiales disparan efectos secundarios al impactar (por ejemplo, rayos que saltan entre objetivos). | E01–E02 · Ensayar la nueva Chispa: un rayo empodera una reserva de flechas en el suelo; esas flechas pueden disparar un rayo al impactar. |
| 25 | Permite lanzar varias veces seguidas una misma habilidad especial (multi-cast de spells). | E10 · Pendiente hasta definir qué ataque especial se podría repetir. Quitar si no tiene un caso propio. |
| 26 | Tras cada enemigo abatido se obtiene un aumento temporal de daño (efecto de racha de muertes). | T25 · Habilitar la ventana tras rotura mediante una mejora o prestigio. Empieza al quedar vulnerable el nuevo árbol. |
| 27 | Algunos ataques garantizan crítico o daño maximizado por habilidad (por ejemplo, siempre crítico). | T21 · Una diana difícil puede preparar un crítico en la siguiente suelta. |
| 28 | Cada golpe tiene probabilidad de desencadenar un ataque especial adicional (por ejemplo, activación de Lightning Strike). | E01, E09 · Probar activación probabilística desde las flechas empoderadas. Revisar la relación con la gran descarga cargada. |
| 29 | Sacrificio de recursos para potenciar el ataque: consumir maná u otro recurso incrementa significativamente el daño durante un tiempo. | T23 · Considerar coste fijo frente a consumir el carcaj completo en un golpe muy potente. |
| 30 | Al golpear, drenar o robar fuerza al enemigo (reduce su ataque mientras aumenta el propio). | Y09 · Drenaje y robo de ataque deprecados. |
| 31 | Mejora de daño para todos los aliados: aumenta el daño de todos los personajes del equipo simultáneamente. | Y01 · Segunda formulación del daño grupal. Deprecada junto a la entrada 2. |
| 32 | Héroes inspirados: un porcentaje de aliados inflige daño máximo durante un buff grupal activo. | Y04 · Inspiración de grupo deprecada. |
| 33 | Clan Mate: invocar un aliado temporal aumenta el daño global de los héroes mientras dura. | Y05 · Aliado temporal que potencia al grupo deprecado. |
| 34 | Mejora el daño de ataques con proyectiles generados (por ejemplo, dagas arrojadizas automáticas). | H16 · Mejorar por separado el daño de cada familia de proyectiles generados. |
| 35 | Aumenta el daño de estado infligido por armas especiales (por ejemplo, bonificación de daño de veneno). | F18 · El bono general de daño de estado de armas especiales queda deprecado. |
| 36 | Habilidad de área especial: lanza un ataque masivo que daña múltiples objetivos (p. ej. Blade Stream/Blade Cyclone). | E05, E08 · Barrido de hojas y ciclón en revisión. Primero identificar qué blanco adicional alcanzaría la habilidad en este juego. |
| 37 | Incrementa el daño y reduce el tiempo de espera de ráfagas rápidas (p. ej. más dagas por segundo en Blade Stream). | E11 · Proponer compras individuales de potencia y reducción de espera por efecto, junto a alguna mejora global de daño. |
| 38 | Impacto frontal con probabilidad de aturdir: ciertos ataques tienen efecto de stun en el enemigo. | Y07 · Aturdimiento frontal deprecado. |
| 39 | Desata un ataque relámpago poderoso tras cargarse (Thunder Ship con descarga final Thunder Volley). | O12, E07, E09 · La descarga grande evoluciona a rayo solar. La regla de carga y su relación con la Chispa requieren revisión. |
| 40 | Veneno acumulativo: los efectos de veneno pueden apilarse varias veces para amplificar su daño. | F17 · Veneno acumulativo deprecado. Las cargas aprobadas corresponden a la quemadura. |

## Archivo de las 65 fichas

El documento original comparaba ideas para una demo de diez blancos. Se conservan los efectos, el origen, la prueba individual y los siete ensayos de familia. En estas tablas **Base** significa que la compra venía del prototipo, **Plan** que procedía del diseño de campaña, **Carta** que se había propuesto como recompensa de jefe e **Idea** que se incorporaba para discutirla. La última columna remite a la revisión del 27 de noviembre, también para las fichas retiradas.

### Qué se agotaba en el primer acto

El primer acto ofrecía diez mejoras y doce compras. En la partida observada, la última mejora distinta se compró a los 3:35 de juego activo. Al vencer al quinto blanco a los 4:35, quedaban 126 de savia y estaban hechas las doce compras. La tabla reconstruye la economía de aquella versión.

| Al romper el blanco | Savia base acumulada | Coste de todo lo abierto |
| ---: | ---: | ---: |
| 1 | 20 | 11 |
| 2 | 50 | 67 |
| 3 | 95 | 115 |
| 4 | 162 | 197 |
| 5 | 263 | 197 |

### Decisiones que guiaban la demo de diez blancos

Aquella demo apuntaba a 15–20 minutos y a llegar al último blanco con pocas cosas por comprar. Pipo abría el árbol. La raíz de daño era gratuita y el décimo nivel habilitaba tres flechas con el daño completo de cada una. El texto original describía daño multiplicativo por rango y una suelta/s por nivel de cadencia. La revisión distingue los diez rangos iniciales aditivos (T01 y T04), el daño multiplicativo (T03) y las sueltas adicionales (T06).

El arco largo seguía al rápido. El taller, el carcaj, los puntos débiles, la racha, el crítico y el salto al atado competían por la savia. Una compra temprana permitía devolver un nivel con el botón derecho. Acariciar a Pipo era una de las últimas compras. La build pasó a veinte blancos y el árbol actualizado debe dejar mejoras pendientes en ese recorrido. [Árbol de la demo](arbol-de-la-demo.md)

### Daño y ritmo de tiro

Una flecha más fuerte permite cuidar el carcaj. Disparar más seguido permite sostener una racha, pero adelanta el próximo viaje a buscar flechas.

| Ficha de origen | Origen | Qué cambiaba al jugar | Qué proponía probar | Revisión |
| --- | --- | --- | --- | --- |
| Daño por flecha | Base | Cada nivel suma daño al impacto manual. La primera compra es gratis y abre el árbol. | Compará cuántas flechas hacen falta para romper el mismo blanco. | T01 |
| Velocidad de ataque | Base | Cada nivel acorta la espera entre tiros con ambos arcos. Se piden al menos diez niveles. | Medí cuánto dura un carcaj lleno manteniendo apretado el botón de disparo. | T04 |
| Arco rápido | Base | Desbloqueá un segundo arco. Su base pasa de 1 a 2,5 tiros por segundo y consume una flecha por tiro. | Al cambiar de arco tienen que conservarse el carcaj y la espera del último disparo. | T08 |
| Primer tiro después de recargar | Idea | Después de recoger una tanda mientras estabas vacío, el siguiente impacto pega más fuerte. | Una tanda da un solo tiro mejorado, aunque se recoja en varias partes. | T17 |
| Tres aciertos seguidos | Carta | La tercera flecha acertada recibe un bono. Un disparo fallado reinicia la cuenta. | Que fallar cueste ese bono y todavía permita terminar el blanco. | D06 |
| Tiro alternado | Idea | Acertá con el arco de rama y aprovechá un bono en el siguiente impacto del arco rápido. | Probá que cambiar repetidamente de arco sin disparar no otorgue el premio. | T18 |
| Última flecha | Idea | La última flecha del carcaj recibe daño extra si acertás al tronco. | Evitá que disparar al aire para vaciar el carcaj sea rentable. | T19 |
| Arco en abanico | Plan | Gastá hasta tres flechas para cubrir el centro y los costados con un solo disparo. | Con una sola flecha disponible, debe salir por el centro. | T10 |
| Arco repetidor | Plan | Un arco de cuatro tiros por segundo permite concentrar el fuego si tenés suficiente munición. | Probalo con y sin taller para juzgar cuánto vale su consumo. | T11–T12 |

**Prueba en el claro.** En una misma partida, alterná cinco segundos de fuego con cada arco. Anotá tiros, impactos, flechas gastadas y daño. Repetí tras subir daño y tras subir velocidad.

### Precisión y partes del blanco

Estas compras premian dónde apuntás. La grieta visible, la señal de que el tronco se partió y la posibilidad de acertarle a cada mitad forman parte de la lectura básica del encuentro.

| Ficha de origen | Origen | Qué cambiaba al jugar | Qué proponía probar | Revisión |
| --- | --- | --- | --- | --- |
| Daño en el punto débil | Base | Cuando acertás en el punto marcado, aumenta el multiplicador de ese tiro. | Probá con la misma flecha al centro, en el borde del punto y afuera. | H01 |
| Flecha de eco | Plan | Acertarle al punto débil manda una parte del daño a otro blanco cercano. | El segundo golpe necesita otra parte vulnerable. El eco nunca genera otro eco. | H09 |
| Punto débil más ancho | Carta | Ampliá el área marcada durante su aparición. El borde dibujado coincide con la zona que recibe el premio. | Medí si mejora la precisión desde lejos sin volver irrelevante apuntar. | H03, D16 |
| Ventana de puntería | Idea | El punto débil permanece visible un poco más por aparición. | Conservá momentos en los que convenga volver al cuerpo del tronco. | H03 |
| Cambio de lado | Idea | Tras acertar en un lado vivo, el primer impacto en un lado distinto recibe un bono breve. | En el jefe del blanco 10 debe premiar cambiar de objetivo, sin bloquear el de un solo lado. | H04 |
| Remate de una parte | Idea | El tramo final de resistencia de cada parte recibe más daño de tus flechas. | Ningún tiro sobrante debe borrar una parte que acaba de abrirse. | H05 |
| Astilla de rebote | Idea | Un impacto en la madera junto al punto débil desprende una astilla que alcanza un objetivo lateral. | Limitá a un blanco adicional. Un acierto al costado sigue valiendo menos que uno preciso. | H11 |
| Marca de preparación | Idea | Golpeá una raíz con la rama y durante unos segundos tus flechas golpean más fuerte esa parte. | El recorrido hacia la raíz debe compensar el tiempo que dejás de disparar. | H06 |
| Tiro lejano | Idea | Un acierto en un punto débil desde el borde del claro da más daño directo. | Medí si el beneficio conserva el incentivo de moverse para recargar. | H07 |

**Prueba en el claro.** Contra el tronco partido, probá romper todo el lado izquierdo de corrido y después alternar entre lados. Observá si ambas rutas se entienden y cuándo conviene elegir cada una.

### Flechas y taller

El taller arroja tandas a distintos lugares del claro. Las mejoras pueden cambiar el tamaño de cada viaje, la cantidad de viajes que rinden o el recorrido necesario para completar el carcaj.

| Ficha de origen | Origen | Qué cambiaba al jugar | Qué proponía probar | Revisión |
| --- | --- | --- | --- | --- |
| Primer taller | Base | Construí el taller que fabrica flechas. Cada tanda sale despedida hacia un lugar alcanzable. | Desde un mismo punto, medí qué proporción de la producción podés juntar sin moverte. | L01 |
| Producción del taller | Base | Aumentá las flechas producidas por segundo sobre la nueva tasa reducida. | Compará suministro efectivo tras caminar y consumo de los dos arcos. | L02–L03 |
| Capacidad del carcaj | Base | Sumá lugar para flechas. El rango inicial amplía la capacidad de 24 a 40. | Recoger con dos lugares libres debe dejar en el suelo el resto de la tanda. | L07 |
| Alcance de recogida | Base | Juntá flechas por proximidad desde un poco más lejos. | Al máximo, dos o más zonas de caída todavía tienen que requerir desplazamiento. | L08 |
| Tandas más grandes | Idea | El taller acumula más flechas antes de lanzarlas. El promedio por minuto se conserva. | Deben hacer falta menos viajes, con una espera más larga entre lanzamientos. | L04 |
| Selector de caída | Idea | Al pasar por el taller podés elegir el próximo sector de caída entre dos destinos. | El beneficio es organizar el recorrido. Evitá fijar la salida sobre el jugador. | L05 |
| Compartimento de reserva | Idea | Una pequeña reserva cargada al pasar por el taller se libera la primera vez que te quedás vacío. | Solo se rellena recogiendo flechas reales. Registrá cada transferencia. | L09 |
| Flecha recuperada | Carta | Cada quinta flecha que disparás vuelve al carcaj, incluso si errás. | Una devolución por gasto válido. Comprobá el límite del carcaj. | L10, D11 |
| Rotura abundante | Carta | Al romper el tronco aparece una tanda de 16 flechas en vez de ocho. | La rotura de dos partes debe dejar un único premio por el blanco completo. | L11, D12 |
| Taller adicional | Plan | Comprá otro taller en un lugar fijo. Cada uno lanza sus propios lotes. | Medí si el recorrido entre dos talleres desplaza por completo la puntería. | L06, X09 |

**Prueba en el claro.** Vaciá el carcaj dos veces. Primero quedate en la salida del taller. Después recorré los lugares de caída. Anotá cuántas flechas juntás en el mismo intervalo.

### Movimiento y golpe de rama

Saltar con Espacio es un movimiento básico. Estas compras optativas exploran cómo aprovechar el viaje de ida y vuelta por el claro. Todos los blancos principales siguen siendo alcanzables desde el suelo.

| Ficha de origen | Origen | Qué cambiaba al jugar | Qué proponía probar | Revisión |
| --- | --- | --- | --- | --- |
| Paso con el carcaj cargado | Base | Caminá más rápido mientras llevás al menos cuatro flechas. | Probalo llevando tres y cuatro flechas por el mismo trayecto. | M01 |
| Impulso al recoger | Idea | Al juntar un lote nuevo ganás unos segundos de velocidad para volver al tronco. | Evitá renovar el bono infinitamente al pasar por el sobrante de una misma tanda. | M04 |
| Eficacia de la rama | Carta | El golpe cercano causa daño extra y arranca más flechas al acertar con el carcaj vacío. | Separá el daño del plazo de espera para que soltar flechas no se repita cada golpe. | M12, D07 |
| Mayor alcance de rama | Idea | Podés golpear una raíz desde un paso más lejos. | Aún hace falta acercarse. Un lado roto deja de ser un blanco válido. | M12 |
| Golpear y retroceder | Idea | Golpear madera con la rama mejora brevemente la velocidad al retroceder. | El desplazamiento lo sigue dirigiendo quien juega. Revisá comodidad junto a una pared. | M13 |
| Agarre en movimiento | Idea | El primer tiro después de recoger mantiene el bono de velocidad mientras apuntás. | Probalo durante un viaje verdadero y mirando al blanco desde la bandeja. | M05 |
| Recogida en el aire | Idea | Interceptá un lote lanzado por el taller mientras saltás y obtené un premio chico de savia una vez por lote. | Un lote que nadie intercepte debe aterrizar con su cantidad completa. | M06 |
| Tiro tras aterrizar | Idea | Aterrizá cerca de un lote después de salir a buscarlo. La próxima flecha acertada gana daño. | Saltos repetidos en el mismo lugar no deberían ser la mejor forma de disparar. | M07 |
| Paso entre recogidas | Idea | Alcanzá dos lugares de caída distintos y extendé brevemente la duración de tu racha. | Probá con cada lote parcialmente lleno para evitar cobrarlo dos veces. | M08, C05 |

**Prueba en el claro.** Hacé el circuito primero caminando y luego saltando. Medí qué cambia en tus decisiones. El balance de esta familia merece esperar si la altura del salto todavía resulta incómoda.

### Racha y savia

La savia es la moneda de la tienda. Una mejora económica funciona si cambia cuándo podés hacer la compra siguiente. Si se paga sola enseguida en cualquier ruta, pasa a ser obligatoria.

| Ficha de origen | Origen | Qué cambiaba al jugar | Qué proponía probar | Revisión |
| --- | --- | --- | --- | --- |
| Más tiempo para la racha | Carta | Después de un acierto, tarda más en empezar a bajar el multiplicador. | Cronometrá una ida corta a recoger con la misma racha inicial. | C04, D14 |
| Premio por buena racha | Carta | Superar un nivel de racha aumenta el ingreso por el daño de tus flechas. | Una flecha que acierta puede sumar el bono una vez, aunque produzca efectos. | C01–C03, D13 |
| Prima por rotura | Carta | Al completar un blanco ganás más savia de su pago final. | Proyectá cuántos blancos quedan para recuperar el costo de la compra. | C10, D02 |
| Relevo tras recoger | Idea | La primera recogida de un lote nuevo congela por un instante la caída de la racha. | No debería renovarse al pisar un sobrante o al esperar junto a un taller. | C05 |
| Premio por precisión | Idea | Acertar un punto débil temporal paga una pequeña suma fija además del daño. | Calculá el ingreso máximo por aparición para no desbordar los precios. | C07 |
| Primer acierto en cada parte | Idea | Cada parte nueva del jefe paga savia la primera vez que recibe una flecha. | Volver a cargar el juego conserva cuáles ya pagaron. | C08 |
| Encargo de abastecimiento | Idea | Durante un blanco, llevá cierta cantidad de flechas a un puesto y cobrá una vez. | Restá del carcaj solo las flechas aceptadas. Requiere un puesto activo. | C09 |
| Ahorro para una rama | Idea | Elegí una rama al comprar esta mejora. Su primera compra cara recibe un descuento fijo. | Mantener los precios vigentes exige presentar cualquier descuento como una decisión nueva. | C11 |
| Compra por adelantado | Idea | Invertí savia en un lote de repuesto que el taller lanza con la próxima tanda. | Puede servir como gasto repetible. Verificá que comprar flechas no vuelva superfluo el taller. | L12 |

**Prueba en el claro.** En dos partidas con la misma semilla, anotá cuándo podés pagar la próxima mejora que querés. Separá los segundos de ahorro de aquellos en los que ya compraste todo lo que te interesa.

### Puestos que disparan por su cuenta

Estas ideas requieren un puesto automático que el arquero cargue con flechas. En la demo se pueden reservar para otra entrega si preferís que el segundo acto siga centrado en apuntar y moverse.

| Ficha de origen | Origen | Qué cambiaba al jugar | Qué proponía probar | Revisión |
| --- | --- | --- | --- | --- |
| Primer puesto automático | Plan | Construí un puesto que dispara al tronco mientras tenga flechas. El arquero decide cuándo cargarlo. | Medí cuánto tiempo dejás de apuntar para ponerlo otra vez en marcha. | B01 |
| Potencia del puesto | Plan | Cada flecha del puesto causa más daño, con el mismo gasto de munición. | Separá ese daño del manual al comparar las dos rutas. | B02, B05 |
| Depósito más grande | Plan | Aumentá la cantidad de flechas que acepta el puesto en cada visita. | El sobrante se queda en el carcaj. Una visita debería comprar más tiempo de autonomía. | B03, D18 |
| Carga de puestos vecinos | Plan | Al cargar un puesto, el excedente puede repartir flechas a otros cercanos. | Necesita dos puestos. Un depósito lleno no debe consumir flechas del arquero. | B06 |
| Segundo puesto | Plan | Abrí otro puesto orientado a otro sector con su propio depósito. | Comprobá si dos viajes valen más que mejorar el daño de un solo puesto. | B05, B10 |
| Ráfaga después de cargar | Carta | Al entregar flechas, el puesto dispara más rápido durante unos segundos. | Solo una entrega con flechas reales puede iniciar la ráfaga. | B07, D19 |
| Puesto que sigue tu puntería | Carta | Un acierto manual en un punto débil aumenta el daño del puesto durante unos segundos. | Hacé distinguibles el blanco que marcaste y el que recibe la flecha automática. | B08, D20 |
| Apuntar al mismo lado | Idea | Elegí desde el puesto qué parte viva del jefe debe priorizar. | Si esa parte cae, el puesto tiene que elegir otra parte válida sin perder flechas. | B09 |
| Reserva personal regulable | Idea | Elegí cuántas flechas conservar al cargar un puesto. Mostrá la cantidad antes de entregar. | Probá con menos flechas que la reserva y con un depósito al que le queda un solo lugar. | B04 |

**Prueba en el claro.** Al entrar con doce flechas, ofrecé una oportunidad atractiva del otro lado del claro. Observá cuántas flechas decide conservar el jugador y si vuelve voluntariamente a abastecer.

### Descargas y oportunidades del claro

Las descargas nacen de una compra. Las semillas y otros blancos temporales aparecen en el claro durante el juego. Una mejora puede vincular ambos sistemas siempre que el jugador reconozca qué activó el efecto.

| Ficha de origen | Origen | Qué cambiaba al jugar | Qué proponía probar | Revisión |
| --- | --- | --- | --- | --- |
| Chispa por aciertos | Base | Una descarga golpea al tronco cada ocho disparos manuales que aciertan. | Mostrá cuántos aciertos faltan. El daño de una descarga no adelanta la siguiente. | E01 |
| Chispa doble | Carta | Cada segunda descarga agrega otra del mismo poder. | Contá las dos como efectos secundarios. Comprobá el cruce de fase del jefe. | E02, D21 |
| Descarga ramificada | Plan | Cada cierta cantidad de chispas, aparecen rayos adicionales. | Compará si tener más rayos cambia tu blanco preferido o solo acelera el daño. | E03 |
| Lluvia de bellotas | Plan | Mientras disparás caen varias bellotas sobre partes vulnerables. | Con un solo blanco, fijate dónde impactó cada una y cuánto daño hizo. | E04, D22 |
| Hojas en arco | Plan | Una ola de hojas cruza el claro tras una serie de aciertos y daña varias partes visibles. | Cada parte debe recibir un solo golpe de la misma ola. | E05 |
| Raíces que agrupan | Plan | Una secuencia de puntos débiles acertados atrae blancos secundarios durante unos segundos. | Los lados fijos de un jefe conservan su posición y su resistencia. | E06 |
| Sol sobre el claro | Plan | Después de una señal visible se produce un impacto grande sobre el tronco y sus costados. | Comprobá que se entiende con el volumen y los destellos al mínimo. | E07 |
| Semillas con más flechas | Idea | Una semilla acertada deja un lote más grande para ir a buscarlo. | Tiene que seguir existiendo un motivo para invertir en el taller. | O06 |
| Más premio por blanco dorado | Carta | Al acertar al blanco dorado de un costado ganás más savia. Requiere ese evento. | Hay que cobrar una sola vez y poder seguir jugando si se escapa. | O07, D15 |
| Alijos más generosos | Carta | Aumentá el lote que deja una caja de suministros acertada. Requiere cajas en ese tramo. | Si el carcaj se llena, el resto de las flechas espera donde aterrizó. | O08, D17 |

**Prueba en el claro.** En una grabación sin sonido, pedile a alguien que identifique qué disparó la chispa y qué soltó las flechas. Después repetí con los efectos reducidos.

### Líneas abiertas al cerrar el documento original

Se estimaba que la demo de diez blancos cubría un 5–15 % del contenido final. El número de actos quedaba abierto. Estas fueron las cinco líneas posteriores del catálogo. Los códigos apuntan a la decisión posterior.

| Línea | Propuesta histórica | Revisión |
| --- | --- | --- |
| Quemadura y especializaciones | En promedio una flecha de cada diez prendería el blanco. Las cargas dañarían entre disparos y empezarían con un límite. Tres compras permitirían quitar el límite, aumentar el daño de cada carga o demorar la pérdida. El indicador debía reflejar el cambio. | F00–F16, X07 |
| Ecos y más blancos activos | Una copia fantasmal de la flecha debía probarse con distinto daño, consumo y capacidad de disparar otros efectos. Otra compra acortaría la espera hasta el siguiente blanco opcional, para competir por la atención durante las ráfagas. | H08–H10, O01 |
| Tiros en el aire | El salto libre y el dirigido a un atado daban pie a un bono al disparar en el aire. Un giro completo antes de disparar ofrecería una variante acrobática. La prueba debía comprobar la comodidad durante una partida entera. | M02–M03, M09–M11 |
| Ballesta fija con munición propia | Probar la elección de dejar ocho flechas en la ballesta de pie o llevarlas para buscar un punto débil. El depósito y el sonido debían avisar cuándo hacía falta cargarla. | B01–B12, X11 |
| Más arcos y láser | Tras el largo, comparar arcos de gran cadencia con variaciones de trayectoria o impactos. Reservar el láser de daño y cadencia extremos para el tramo final, donde aún deben leerse los impactos. | T10–T13, T26–T27, X13 |
