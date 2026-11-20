# Dirección de arte y producción voxel

El arquero empieza en un claro con un nudo de madera a su altura. Al final sigue reconociendo ese lugar por la piedra donde recogió sus primeras flechas, aunque ahora se vea diminuta al pie del nudo. Los atados que se acumulan, los talleres que trabajan y los centinelas que giran cuentan cuánto cambió su capacidad de disparo. El análisis de AmmoDump describe esta progresión espacial y el problema de lectura que genera el exceso de impactos. El kit, la paleta y los valores siguientes son propuestas para nuestro juego.

## El claro visto desde el arco

Una explanada despejada concentra la actividad. Los árboles altos forman el borde exterior. La línea de roca clara que cruza el suelo lleva la vista al blanco y sigue siendo reconocible con la arena llena. Reservar el primer plano inferior para manos y arco, el fondo lateral para máquinas y el cielo por encima del blanco para anunciar eventos. Desde el punto de aparición deben verse a la vez el blanco y el primer recurso recogible.

| Elemento | Forma y material dominantes | Señal al jugar |
| --- | --- | --- |
| Nudo | Cuerpo compacto de corteza oscura, madera expuesta en placas grandes. Crece sumando placas, raíces y anillos de igual grosor aparente. | Una grieta cambia de anchura al perder vida. El desprendimiento final descubre el siguiente cuerpo. |
| Punto débil | Anillo roto, borde marfil de doble contraste y muesca superior. | Primero se abre y luego se enciende. Su contorno persiste sobre corteza clara y oscura. |
| Flechas en el suelo | Vástagos agrupados en abanico, ligadura y plumas claras. | Una recogida reduce el volumen del montón inmediatamente. Tres modelos representan acumulación pequeña, mediana y grande. |
| Savia | Gota ámbar con extremo superior en punta, repetida junto al saldo y a los precios. | El contador pulsa al acreditar una ganancia. La pluma clara identifica el recurso que hace falta recoger del suelo. |
| Taller de flechas | Base cuadrada, techo bajo y bandeja que se mueve verticalmente. | Cada tanda levanta la bandeja y deposita un atado visible en la salida. |
| Centinela de arco | Brazos horizontales y cabeza giratoria, depósito visible en la base. | Vacío, baja la cabeza y muestra el hueco del depósito. Al recibir flechas lo llena, levanta la cabeza y vuelve a apuntar. |
| Oportunidad temporal | Contorno propio para cada tipo. El blanco de precisión tiene círculos concéntricos, el premio una silueta facetada y el suministro un paquete ligado. | La entrada usa movimiento breve y una señal sonora diferenciada. La silueta permite decidir qué perseguir incluso en escala de grises. |

**Paleta inicial.** Tierra `#37352F`, piedra `#73776A`, musgo `#626E4C`, pino `#37493F`, corteza `#59453B`, madera cortada `#A87D54`, cielo `#B6C6BE`, pluma `#EEE2BB`, brillo de premio `#E4AC50`, magia `#8B82CB` y carbón `#292735`. Usar materiales mates y grupos grandes del mismo tono. Los principales contrastes pertenecen a cosas que se pueden apuntar, recoger o alimentar. Ajustar los colores con las capturas de la cámara jugable, incluida una toma en escala de grises.

## Kit y alcance de producción

| Familia | Entrega para el primer jefe | Ampliación para los seis actos |
| --- | --- | --- |
| Escenario | 1 loseta de suelo, 1 borde, 1 piedra de escala, 1 conífera procedural y 1 tocón | Añadir una copa ancha, raíces y un grupo de helechos. Orientación, semilla y composición dan variedad al mismo claro. |
| Arquero | Par de manos en primera persona, arco de rama, recurvo, cuerda y flecha. El golpe de rama reutiliza la mano y una pieza de madera corta. | El de rama conserva una sola curva, el recurvo tiene extremos vueltos, el de abanico se ensancha cerca de la mano y el de tejo repetidor lleva un depósito lateral. Ajustar el ritmo del gesto a cada perfil. |
| Nudos y jefes | Núcleo, placa, grieta, punto débil y fragmento desprendible. Primer jefe con división visible. | Reutilizar el núcleo en los 30 nudos. Para cada jefe sumar el módulo que muestre su regla, por ejemplo un corazón que reaparece en otra placa o cavidades de las que salen fragmentos. |
| Logística | Atado pequeño/mediano/grande, bandeja de taller y maqueta de centinela vacío/cargado para comprobar la silueta. | Una familia de talleres y una de centinelas cubren seis y doce emplazamientos respectivamente. Los estados se leen en piezas móviles y carga visible. |
| Interfaces y efectos | Iconos del arco, flecha, compra, combo y cartas del primer encuentro. Estela corta, impacto en madera, recogida y rotura. | Iconos por familia con distintivo por efecto, seis señales de evento y efectos de alcance global. Reutilizar cortes de estela, segmentos y fragmentos con distintas trayectorias. |

**Entrega por hito.** En el prototipo de los nudos 1–3 se usan el arco de rama, el nudo con respuesta al impacto, el atado, el taller, el suelo a escala y un pino editable mediante panel. En el corte vertical 1–5 se entrega la columna central de la tabla. En el MVP 1–10 se incorporan el segundo jefe y los modelos de logística activos en ese tramo. La maqueta del centinela permite probar espacio y lectura antes de su aparición en campaña.

**Crecimiento del nudo.** Una primera maqueta combina un cuerpo del tamaño del arquero y una piedra fija de un metro. Al crecer, se agranda el cuerpo y se repiten las placas exteriores. La piedra conserva sus dimensiones. Comprobar que el punto débil se mantiene visible desde las posiciones válidas de tiro corto y largo, incluso cuando el cuerpo ocupa todo el fondo. Probar un nudo del último acto desde el prototipo, aunque todavía se represente con cubos grises.

## Receta reproducible de assets

**Panel visual del prototipo.** Abrir la [escena del pino](../assets/pino.tscn) en Godot y seleccionar su nodo raíz. En el Inspector, el grupo **Silueta** permite cambiar semilla, altura y anchura. **Paleta** permite elegir corteza, follaje y brotes. La vista 3D actualiza la malla al cambiar cada control. Para conservar el pino de partida, guardar la escena como una variante con otro nombre. La [receta del pino](../scripts/voxel_pine.gd) reproduce la misma forma con los mismos parámetros. Esta prueba establece el recorrido de autoría para las nuevas familias de vegetación y utilería.

La unidad de autoría es un vóxel de 6,25 cm para utilería y estructuras. Las manos y el arco en primera persona admiten media unidad para que la silueta resista un primer plano. Mantener dimensiones en metros durante la exportación, encajar los edificios sobre una retícula horizontal de un metro y elegir un pivote de suelo centrado para los elementos colocables. En manos, cuerda y herramientas se usan pivotes en la junta de animación. La dirección vertical y el frente se comprueban en el importador con una pieza asimétrica.

El archivo editable de una familia conserva volúmenes y roles de material. La exportación entrega una malla por pieza rígida móvil o por objeto estático, comparte paleta y elimina caras interiores. Colisión, puntos de anclaje y volumen interactivo se exportan por separado. Las copias decorativas de un modelo comparten geometría. La semilla solo modifica el aspecto de la familia y nunca el área de recogida ni la lógica de combate.

**Ejemplo de receta para la conífera del borde.** Todas las medidas de este ejemplo están en vóxeles. Con semilla entera no negativa `s`, fijar `v = s mod 3`. Construir un tronco `3 × (20 + 2v) × 3` y centrar tres bloques de follaje con base a `8`, `14 + v` y `20 + 2v` vóxeles del suelo. Los bloques tienen lados horizontales de `17`, `13` y `7` y alturas de `8`, `8` y `6`. Quitar un cubo de `2 × 2 × 2` de cada esquina inferior de la copa mayor. Desplazar la copa central `v − 1` vóxeles en X. Asignar corteza al tronco, pino al follaje y musgo a las caras superiores del follaje. Exportar solo las caras expuestas y unir caras coplanares del mismo color. Las semillas 0, 1 y 2 producen tres copas distinguibles con los mismos materiales y una altura total de 26, 28 y 30 vóxeles. Para los árboles altos del borde, colocar estas variantes con escala uniforme mayor en el escenario.

**Ficha mínima de una variante exportada**

```yaml
id: entorno_conifera_02
familia: entorno_conifera
receta_version: 1
semilla: 2
unidad_m: 0.0625
dimensiones_voxeles_xyz: [17, 30, 17]
pivote: centro_suelo
materiales: [corteza, pino, musgo]
colision: ninguna_decoracion_exterior
salida: entorno_conifera_02.glb
```

En v0.1, las variantes de pino se guardan como escenas de Godot con parámetros editables. Para familias producidas en una herramienta externa, exportar glTF binario (`.glb`) e importar la malla en una escena que conserve interacción, sonidos y colisión al reimportar. Revisar a distancia de juego y conservar la salida aprobada junto a la receta y la semilla. Para el corte vertical, permitir que un cambio de paleta compartida se propague a tres variantes con una sola edición. Mantener las piezas artesanales para manos, punto débil y estados de las máquinas.

**Segunda aplicación, atados.** Modelar una flecha de recogida de tres piezas y una ligadura. Para los tres tamaños, instanciar la misma flecha en grupos de 3, 5 u 8 con las plumas hacia arriba y ajustar la ligadura al ancho del grupo. Combinar las piezas estáticas durante la exportación. El saldo y el área de recogida pertenecen al montón. Los tres modelos se pueden sustituir en la misma escena y probar entregando exactamente el mismo saldo al carcaj.

## Movimiento, impactos y lectura

1. **Tensar y soltar.** Ligar la distancia entre mano y empuñadura al avance del gesto. Anclar ambos extremos de la cuerda al arco y el centro a la mano hasta el evento de salida. Soltar, crear la estela y tocar el sonido en el mismo evento de simulación. En tiro rápido se acorta la recuperación. Con vibración de cámara en cero deben seguir distinguiéndose tensado, disparo e impacto.
2. **Leer el golpe.** Una astilla sale en dirección lateral. El punto débil pulsa por el borde y la madera alcanzada cambia de valor brevemente. Las marcas de flecha son decorativas y caducan por antigüedad. El último disparo siempre recibe confirmación, incluso al superar el cupo de marcas.
3. **Seguir apuntando.** El centro de la retícula conserva un disco libre de texto con radio inicial del 4 % de la altura de imagen. La barra de vida ocupa la franja superior. El daño automático se reúne en un total lateral por intervalo de medio segundo. Las estelas globales recorren principalmente los bordes, con intensidad regulable y opción de reducir destellos. Los ajustes visuales conservan el instante del impacto y la información del punto débil.
4. **Ver el excedente.** Un montón representa la cantidad real mediante tres tamaños y un contador al acercarse. La producción agrega unidades al saldo aunque ya se haya alcanzado el límite visual. Las astillas desaparecen antes que una señal de recogida o una guía de objetivo.

Los efectos globales comparten una biblioteca de seis formas fáciles de animar. **Chispa de copa** salta entre dos marcas con un trazo angular. **Tormenta de copas** ramifica ese trazo desde el cielo. **Lluvia de bellotas** cae en grupos de proyectiles opacos con silueta de bellota. **Hojas en hoz** cruza el encuadre en arcos laterales. **Remolino de raíces** enrolla segmentos a ras del suelo. **Sol del claro** levanta un disco escalonado que baña el borde del nudo. Comprobar cada efecto al entrar en escena, al impactar y en combinación con otro.

## Presupuesto inicial y prueba de aceptación

Los topes son valores de partida para medir en el hardware objetivo. Usar hasta 1.500 triángulos para cada silueta principal en primera persona, 800 por estructura, 250 por pieza vegetal y 120 por atado. Empezar con un material opaco compartido de paleta y otro para los efectos. Limitar a 48 montones **visibles**, 32 marcas de flecha y 24 fragmentos de impacto en pantalla. Reutilizar sus instancias y representar un montón con una misma unidad de interacción aunque contenga cientos de flechas.

| Trabajo | Prueba de aceptación |
| --- | --- |
| A1 · Fijar escala, paleta y exportación | Importar la pieza asimétrica, la piedra de un metro, el arco y el primer blanco. Verificar dimensiones, pivotes y alineación de la flecha tras cada reimportación. |
| A2 · Crear una familia con variantes | Entregar receta, tres semillas, tres mallas y sus fichas. Con la receta ya instalada, una segunda persona debe poder regenerarlas y verlas en el claro con un color común nuevo en menos de 20 minutos. Cronometrar el recorrido completo. |
| A3 · Montar el claro del primer acto | Grabar desde el inicio hasta la primera recogida, la primera compra y la división del jefe. Se distinguen el blanco activo, la recogida y el efecto de la compra en movimiento a 1280 × 720. |
| A4 · Validar el extremo de la campaña | Grabar un recorrido de al menos 120 s con el nudo del acto VI, seis talleres, doce centinelas, montones al límite y dos efectos superpuestos. Revisar fotogramas de muestra y la traza de tiempos. Meta provisional para Windows a 1080p en un equipo de referencia por definir, percentil 95 de tiempo de cuadro ≤ 16,7 ms (60 fps). |
| A5 · Probar las señales con jugadores | En una prueba breve, al menos cuatro de cinco personas deben localizar el punto débil en dos segundos e identificar cuál de dos centinelas necesita carga en tres. Repetir con destellos y números desactivados. Si falla, ajustar silueta, señales o contraste antes de sumar detalle. |

Si A4 supera el presupuesto, medir por separado mallas, transparencias e instancias. Primero acortar estelas secundarias y agrupar geometría repetida. Volver a probar con la misma cámara, semilla y saldo de flechas. El corte se aprueba cuando A4 y A5 pasan en la misma versión.
