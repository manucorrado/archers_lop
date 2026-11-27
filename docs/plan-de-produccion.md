# Plan de producción del claro

La build que se está equilibrando tiene veinte árboles. Los prototipos de tres, cinco y diez siguen sirviendo para observar problemas concretos. El plan del 27 de noviembre prioriza una demo publicable y permite probar el prestigio en paralelo con una herramienta de desarrollo. La cantidad total de árboles, los jefes posteriores y el número de vueltas de prestigio dependen de pruebas de duración. [Alcance](PRD.md) · [Backlog completo](proximas-tareas.md)

## Entregas y dependencias

| Orden | Resultado | Qué tiene que estar resuelto | Evidencia de salida |
|---|---|---|---|
| 1 · Acordar el corte | Criterios breves de demo con el autor y un agente. | Build de veinte disponible, pendientes inventariados. | Separar los bloqueos para publicar de lo que mejora una futura campaña. Partir de balance de mejoras, balance económico y pocas charlas escritas por el autor. |
| 2 · Medir la base | Dos vueltas por persona, cartas distintas; comparar tiro, abastecimiento y efectos. | Versión y semilla identificables. | Tiempo total y activo, daño por origen, saldo al entrar al 10, tiempo vacío y qué se hizo comprando y viajando. Comparación anterior y posterior a los cambios de vida. |
| 3 · Armar build de práctica | Selector de árbol/fase, monedas y atributos ajustables y escenarios reproducibles. | Inventario de variables de combate, economía, logística y prestigio. | Repetir un tramo variando un parámetro; mostrar valores exactos. Probar N10, N20 y dos configuraciones posprestigio sin tocar el perfil de juego. [Especificación interna](proximas-tareas.md). |
| 4 · Rebalancear | Curvas de precios, pago de savia, vida de árboles y multiplicadores de barrera, reducción de nodos repetidos, taller y salto. | Rutas y mediciones de base; herramientas para iterar o perfiles equivalentes. | Varias rutas llegan a un pico jugable; veinte árboles dejan parte del Atlas ampliado pendiente. Distinguir ahorro de tiempo sin suministro o transporte. [Modelo económico](curvas-de-costes-incrementales.md). |
| 5 · Preparar prueba privada | Primera demo con los textos entregados por el autor y lectura suficiente para interpretar los resultados. | Corte decidido y ronda de balance. | El autor y jugadores en frío prueban en Windows. El triple se puede leer; comparar racha, vuelo del triple y llegada de lluvia. Registrar si hace falta señal de recuperación con rama. |
| 6 · Preparar distribución | Cuentas, correos, fichas de itch.io y Steam, material y canales de prueba. | Alcance, nombre, capturas, textos ES/EN y build candidata. | Instalar, jugar y actualizar desde cada canal que se vaya a publicar. Refinar el balance con datos reales de itch. |
| 7 · Barreras y prestigio | Prototipo interno de Brizno/N20, medallas, primer reinicio y acceso a compras que cambian la barrera. | Un encuentro reproducible y el mismo presupuesto de prueba para las rutas. | Anotar medallas por hora en una ruta corta y otra profunda. Efectuar reset al borde de una transacción; comprobar saldo, inventarios, ayudas y guardado. |
| 8 · Ampliar la campaña | Sumar árboles, mecánicas y tramos narrativos de acuerdo con el ritmo medido. | Probar las familias y resolver el encaje del prestigio con el 100 %. | Medir aproximadamente dos horas hasta créditos y dos a cuatro al 100 % incluyendo prestigio. Definir posibles desenlace verdadero y desafío de cierre. |

Los pasos 3 y 7 se pueden prototipar antes de cerrar la demo. En el paso 1 se decide cuáles tienen que llegar a la build pública. Una persona cubre desarrollo, diseño, arte y pruebas en Godot para Windows. Las estimaciones antiguas de H0–H5 suponían seis actos terminados y doce puestos; reestimar el trabajo restante cuando estén definidos el corte de demo y el alcance del primer prestigio. [Plan histórico con T01–T33, dependencias y jornadas](https://github.com/manucorrado/archers_lop/blob/654bd1fc91f4c4d5e189df0ead6ed8831f91c9e7/docs/plan-de-produccion.md)

## Validación de una entrega

| Caso | Qué observar |
|---|---|
| Primer recorrido | En una muestra de cinco, referencia histórica de cuatro que aciertan en 15 s y compran en 90 s. Observar si vuelven a tirar después de recoger y si saben recuperar flechas en vacío. Evitar añadir tutoriales de puntería por defecto. |
| Inventario y suministro | Cuadrar carcaj + suelo + en vuelo + reserva interna del taller + depósitos respecto del saldo inicial, producción, botín, devoluciones y consumo real. Llevar aparte la fracción de producción. Probar carga parcial, depósito lleno, recogida parcial y flechas baratas por multitiro si se desbloquean. |
| Economía y compra | Con igual semilla, separar ganancia bruta, gasto, reembolso y saldo. Medir el intervalo hasta que el jugador puede pagar y hasta que realmente compra. Probar devolución de padre con hijos y caminos alternativos si se adopta la devolución en cascada. |
| Daño y fases | Un triple puede pegar en dos mitades, errar parte de sus flechas o coincidir con fuego/ballesta. Al jugador se le muestra una suma por suelta. Internamente cada fuente quita como máximo la vida vulnerable y el cruce de fase o la rotura pagan una vez. |
| Guardado, pausa y oferta | Guardar antes y después de una compra, una oferta, un jefe y un reinicio. Restaurar inventarios, vida, cartas ofrecidas, medallas pendientes y acreditadas. Una oferta vuelve con los mismos IDs salvo uso explícito de un eventual nuevo sorteo. Diferenciar juego de fondo, pausa manual y juego cerrado. |
| Ballesta | Entender la transferencia con 12 flechas y un depósito vacío, reactivarla tras vaciarse e identificar el puesto por banderita o brillo. Contrastar una rápida con una lenta y fuerte a presupuesto comparable. |
| Lectura y rendimiento | Recorrido de al menos 120 s con un árbol grande, hasta cuatro puestos, atados abundantes, multitiro y superposición de efectos; incluir una captura de 60 s. Meta orientativa en equipo Windows de referencia: 1080p, 60 FPS, p95 ≤16,7 ms y p99 ≤33,3 ms. Aspirar a que cuatro de cinco identifiquen la veta en 2 s y el puesto vacío en 3 s incluso con destellos y números desactivados. |
| Rutas y duración | Medir al autor experto y a participantes nuevos. Una diferencia extrema que reduzca a cinco minutos la campaña estimada en unas dos horas requiere investigar la ruta. Registrar créditos, 100 %, máximo árbol y tiempos parciales con versión, semilla y estado del prestigio. |
| Criterios para iterar | Volver a probar si nadie percibe la compra, si repetir una acción monótona es óptimo o si una opción gana en toda situación. Registrar qué acción cambió después de comprar y qué atasco encontró cada persona. |

## Salidas públicas

La demo pública pide alcance acotado, instalación de Windows comprobada y textos ES/EN. Para itch.io y Steam preparar los correos y las cuentas, identificar quién conserva acceso, reunir capturas, material de tienda, controles y una descripción fiel a la build. Probar actualizaciones con un guardado de la candidata previa. La hoja de ruta conserva la posibilidad de acceso anticipado y edición final; definir fechas y precio cuando corresponda. [Trabajo de tiendas y observación post-itch](proximas-tareas.md)

El plan histórico incluía el kit voxel editable, exportación limpia, escritura atómica, guardado de elecciones y pruebas reproducibles. Los contratos técnicos y artísticos se conservan en sus fuentes, pruebas y guía de construcción. [Kit y presupuesto visual](arte-y-assets-voxel.md) · [Ejecutar pruebas y exportar](../README.md)
