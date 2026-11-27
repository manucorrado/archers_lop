# Economía de juegos incrementales: resumen práctico

## 1. La idea central

**La variable que conviene equilibrar es cuánto tiempo cuesta comprar una mejora.**

Una mejora de **10 monedas**, con un ingreso de **1 moneda/s**, exige los mismos **10 segundos** que una mejora de **1T**, con un ingreso de **100B/s**. Los números pueden crecer enormemente sin aumentar el esfuerzo económico.

Usamos la notación inglesa habitual: **K = 10³, M = 10⁶, B = 10⁹ y T = 10¹²**.

## 2. Cómo acompañan los ingresos al aumento de precios

Los juegos investigados combinan cuatro mecanismos:

- **Más producción:** más ataques, trabajadores, objetivos procesados o automatización.
- **Más valor por recompensa:** mejores recursos, mayores pagos o bonificaciones de loot.
- **Multiplicadores:** hitos, tecnologías, sinergias y prestigio.
- **Menos limitaciones:** mejor recolección, transporte, combustible o tiempo útil.

Los mecanismos pueden multiplicarse entre sí. Por ejemplo, procesar tres veces más objetivos y obtener diez veces más recompensa por objetivo permite multiplicar el ingreso por 30, si no aparece otro cuello de botella.

### Ejemplos de incrementales

| Juego | Mecanismo económico relevante |
| --- | --- |
| [Nodebuster][nodebuster] | Recursos de nodos que se reinvierten en un árbol de mejoras. |
| [Dwarf Eats Mountain][dwarf] | Minería, máquinas, artefactos y prestigio; transportar las riquezas a la base puede limitar el ingreso. |
| [Ammo Dump][ammo] | Árbol de armas, torretas y efectos frente a cubos crecientes. No se verificó su regla exacta de pago. |
| [To the Core][core] | Recursos por expedición; mejoras de daño, combustible y durabilidad, junto con mastery de recursos. |
| [Digseum][digseum] | Reliquias que atraen visitantes y financian mejoras del museo y de la excavación. |
| [Keep on Mining!][mining] | Mejores estadísticas, valor del mineral y recompensas dobles; repetibles con precios crecientes. |
| [(the) Gnorp Apologue][gnorp] | Generación y recogida de fragmentos como capacidades distintas que hay que equilibrar. |
| [Rock Crusher][rock] | Árbol de mejoras, niveles de moneda, ayudantes y prestigio; la descripción anuncia cifras de trillions. |
| [Idle Colony][colony] | Producción automatizada, tecnologías, mejoras especiales y prestigio. |
| [A Game About Feeding a Black Hole][blackhole] | Efectos que escalan con mejoras y con el tier del objetivo; bonificaciones de dinero. |

**Límite de la investigación:** no se encontraron fórmulas públicas completas de precios e ingresos para Nodebuster, Dwarf Eats Mountain o Ammo Dump. Los modelos siguientes son herramientas de diseño y análisis, no fórmulas atribuidas a su código. La fuente de Ammo Dump reproduce la descripción de su tienda.

## 3. El modelo matemático básico

### Precio de una mejora repetible

$$
C_i(\ell)=\left\lceil b_i\,r_i^\ell\right\rceil
$$

- **bᵢ:** precio inicial de la mejora.
- **rᵢ:** multiplicador por compra; 1,20 representa un aumento del 20 %.
- **ℓ:** niveles ya comprados de esa mejora.
- El redondeo hacia arriba permite precios enteros.

Cada rama puede tener parámetros propios. Una curva similar puede servir para asignar precios por etapa a nodos únicos.

### Tiempo hasta poder comprar

$$
\tau=\frac{\max(C-B,0)}{R}
$$

**C** es el precio, **B** el saldo y **R** el ingreso efectivo por segundo. La fórmula supone ingreso constante mientras ahorrás, sin otras compras ni restricciones adicionales.

### Relación entre precios e ingresos

Para una ruta simplificada:

$$
C(n)=C_0r^n,\qquad R(n)=R_0s^n
$$

Desde saldo cero:

$$
\tau(n)=\frac{C_0}{R_0}\left(\frac{r}{s}\right)^n
$$

| Relación | Resultado |
| --- | --- |
| r = s | Los números crecen y la espera se mantiene. |
| r > s | La espera aumenta: desaceleración o pared de progreso. |
| r < s | La espera disminuye: aceleración. |

**Distinción importante:** ℓ cuenta niveles de una mejora; n cuenta pasos comparables de una ruta completa. El ingreso exponencial es una aproximación de esa ruta, no una ley que deba cumplir cada compra.

### Ejemplo: de 10 monedas a 1T

Para multiplicar el precio desde 10 hasta 10¹² en 100 pasos:

$$
r=\left(\frac{10^{12}}{10}\right)^{1/100}\approx1{,}28825
$$

Si el ingreso crece al mismo ritmo:

| Paso | Precio | Ingreso/s | Espera desde cero |
| ---: | ---: | ---: | ---: |
| 0 | 10 | 1 | 10 s |
| 50 | 3,16M | 316,23K | 10 s |
| 100 | 1T | 100B | 10 s |

Es un ejemplo didáctico, no una medición de un juego ni una simulación completa de campaña.

## 4. Cómo medir el ingreso en juegos activos

Para intentos o expediciones comparables:

$$
R_{\mathrm{efectivo}}=
\frac{\text{recompensa media por intento}}
{\text{duración media total del ciclo}}
$$

La duración incluye recolección, recarga, viaje, menús y reinicio cuando corresponda. Si solo se compra al terminar una expedición, hay que considerar intentos enteros.

**DPS no equivale automáticamente a ingreso.** Más daño puede aportar poco si ya destruís todo de un golpe o si la limitación está en los objetivos disponibles o en recoger los recursos.

En una economía limitada por extracción y transporte, una aproximación sostenida es:

$$
R_{\mathrm{disponible}}\approx
\min(R_{\mathrm{extracción}},R_{\mathrm{entrega}})
$$

Ambas capacidades deben expresarse en la misma unidad. Los recursos acumulados y las pérdidas requieren ajustes. Las monedas diferentes se analizan por separado.

## 5. Cómo diseñaría una economía reutilizable

La fórmula práctica para generar precios durante el balance es:

$$
\boxed{
C(n)=\left\lceil
R_{\mathrm{referencia}}(n)\,
\tau_{\mathrm{objetivo}}(n)
\right\rceil
}
$$

**Precio = producción esperada en esa etapa × tiempo de ahorro buscado.**

Procedimiento:

1. Elegí la magnitud inicial y final de los números.
2. Construí o medí una ruta razonable de producción.
3. Definí el tiempo o cantidad de intentos deseados entre compras.
4. Calculá los precios y ajustá hitos, desbloqueos y cuellos de botella.
5. Fijá esos precios y comprobá cómo se comportan distintas estrategias.

**No recalcules los precios en vivo según el ingreso real del jugador:** anularías la ventaja de una estrategia más eficiente.

Para analizar un juego existente, registrá precios, ingresos antes y después de cada compra, duración de los ciclos y desbloqueos. Compará el tiempo de compra y, cuando corresponda, el retorno inmediato:

$$
T_{\mathrm{recuperación}}=\frac{C}{\Delta R}
$$

Este último mide cuánto tarda la producción adicional en recuperar el gasto después de comprar. No captura por sí solo el valor de desbloquear una zona o una sinergia.

## 6. Fuentes matemáticas para profundizar

- [Anthony Pecorella — The Math of Idle Games, Part I](https://www.kongregate.com/en/pages/the-math-of-idle-games-part-i): costes geométricos, producción y multiplicadores; ejemplo histórico de AdVenture Capitalist.
- [Orteil — Idle Game Maker Handbook](https://orteil.dashnet.org/experiments/idlegamemaker/help): documenta el factor de precio 1,15 de Cookie Clicker.
- [Antimatter Dimensions — manual oficial](https://ivark.github.io/howto): productores en cadena y cambios de precio por bloques de compras.
- [Digseum — logros oficiales](https://steamcommunity.com/achievements/3361470): confirma prestigio y un logro por ganar 10²⁷ G.

[nodebuster]: https://store.steampowered.com/app/3107330/Nodebuster/
[dwarf]: https://store.steampowered.com/app/4078200/Dwarf_Eats_Mountain/
[ammo]: https://www.dekudeals.com/items/ammo-dump?platform=all
[core]: https://store.steampowered.com/app/1988550/To_The_Core/
[digseum]: https://store.steampowered.com/app/3361470/Digseum/
[mining]: https://steamcommunity.com/app/3769130/announcements/
[gnorp]: https://gnorp.dev/
[rock]: https://store.steampowered.com/app/3456800/Rock_Crusher/
[colony]: https://store.steampowered.com/app/2843640/Idle_Colony/
[blackhole]: https://steamcommunity.com/app/3694480/discussions/0/582806854239846979/
