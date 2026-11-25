// Copia de los vértices, pictogramas y valores de la demo para la prueba local.
const atlas = {
  "vertices": {
    "damage": [
      438,
      470,
      ""
    ],
    "weak": [
      405,
      437,
      "damage"
    ],
    "rate": [
      471,
      437,
      "damage"
    ],
    "refund": [
      405,
      503,
      "damage"
    ],
    "workshop": [
      471,
      503,
      "damage"
    ],
    "recurve": [
      507,
      401,
      "rate"
    ],
    "rate_step_01": [
      594,
      314,
      "recurve"
    ],
    "rate_step_02": [
      691,
      217,
      "rate_step_01"
    ],
    "longbow": [
      756,
      152,
      "rate_step_02"
    ],
    "rate_flat": [
      792,
      116,
      "longbow"
    ],
    "rain": [
      688,
      180,
      "longbow"
    ],
    "spark": [
      364,
      389,
      "weak"
    ],
    "combo": [
      339,
      382,
      "weak"
    ],
    "damage_step_01": [
      297,
      322,
      "spark"
    ],
    "crit": [
      263,
      285,
      "damage_step_01"
    ],
    "damage_step_02": [
      189,
      221,
      "crit"
    ],
    "damage_step_03": [
      233,
      201,
      "damage_step_02"
    ],
    "damage_step_04": [
      168,
      167,
      "damage_step_03"
    ],
    "damage_mult": [
      101,
      133,
      "damage_step_04"
    ],
    "damage_step_05": [
      135,
      199,
      "damage_mult"
    ],
    "damage_step_06": [
      169,
      265,
      "damage_step_05"
    ],
    "rate_step_03": [
      343,
      215,
      "crit"
    ],
    "rate_step_04": [
      426,
      172,
      "rate_step_03"
    ],
    "rate_step_05": [
      531,
      156,
      "rate_step_04"
    ],
    "rate_step_06": [
      641,
      165,
      "rate_step_05"
    ],
    "rate_step_07": [
      369,
      256,
      "damage_step_01"
    ],
    "rate_step_08": [
      439,
      210,
      "rate_step_07"
    ],
    "rate_step_09": [
      535,
      194,
      "rate_step_08"
    ],
    "rate_step_10": [
      649,
      195,
      "rate_step_09"
    ],
    "steady": [
      285,
      336,
      "combo"
    ],
    "damage_step_07": [
      248,
      302,
      "steady"
    ],
    "damage_step_08": [
      183,
      375,
      "damage_step_07"
    ],
    "damage_step_09": [
      140,
      458,
      "damage_step_08"
    ],
    "damage_step_10": [
      124,
      563,
      "damage_step_09"
    ],
    "damage_step_11": [
      133,
      673,
      "damage_step_10"
    ],
    "damage_step_12": [
      120,
      754,
      "damage_step_11"
    ],
    "rate_step_11": [
      224,
      401,
      "steady"
    ],
    "rate_step_12": [
      178,
      471,
      "rate_step_11"
    ],
    "rate_step_13": [
      162,
      567,
      "rate_step_12"
    ],
    "rate_step_14": [
      163,
      681,
      "rate_step_13"
    ],
    "rate_step_15": [
      144,
      739,
      "rate_step_14"
    ],
    "damage_step_13": [
      355,
      553,
      "refund"
    ],
    "damage_step_14": [
      296,
      612,
      "damage_step_13"
    ],
    "damage_step_15": [
      222,
      686,
      "damage_step_14"
    ],
    "damage_step_16": [
      124,
      784,
      "damage_step_15"
    ],
    "pet": [
      87,
      821,
      "damage_step_16"
    ],
    "wheel": [
      480,
      519,
      "workshop"
    ],
    "capacity": [
      515,
      476,
      "workshop"
    ],
    "wheel_step_01": [
      544,
      583,
      "wheel"
    ],
    "wheel_step_02": [
      599,
      638,
      "wheel_step_01"
    ],
    "wheel_step_03": [
      624,
      663,
      "wheel_step_02"
    ],
    "wheel_step_04": [
      630,
      708,
      "wheel_step_03"
    ],
    "wheel_step_05": [
      704,
      781,
      "wheel_step_04"
    ],
    "wheel_step_06": [
      707,
      739,
      "wheel_step_05"
    ],
    "wheel_step_07": [
      749,
      736,
      "wheel_step_06"
    ],
    "wheel_step_08": [
      676,
      662,
      "wheel_step_07"
    ],
    "wheel_step_09": [
      652,
      661,
      "wheel_step_08"
    ],
    "pace": [
      529,
      554,
      "capacity"
    ],
    "wheel_step_10": [
      589,
      614,
      "pace"
    ],
    "wheel_step_11": [
      441,
      563,
      "wheel"
    ],
    "wheel_step_12": [
      404,
      607,
      "wheel_step_11"
    ],
    "wheel_step_13": [
      338,
      687,
      "wheel_step_12"
    ],
    "wheel_step_14": [
      273,
      774,
      "wheel_step_13"
    ],
    "wheel_step_15": [
      254,
      800,
      "wheel_step_14"
    ],
    "wheel_step_16": [
      255,
      824,
      "wheel_step_15"
    ],
    "wheel_step_17": [
      287,
      854,
      "wheel_step_16"
    ],
    "wheel_step_18": [
      333,
      838,
      "wheel_step_17"
    ],
    "wheel_step_19": [
      299,
      814,
      "wheel_step_18"
    ],
    "wheel_step_20": [
      419,
      778,
      "wheel_step_18"
    ],
    "wheel_step_21": [
      375,
      728,
      "wheel_step_20"
    ],
    "rate_step_16": [
      485,
      620,
      "wheel_step_11"
    ],
    "rate_step_17": [
      536,
      684,
      "rate_step_16"
    ],
    "rate_step_18": [
      499,
      710,
      "rate_step_17"
    ],
    "rate_step_19": [
      451,
      661,
      "rate_step_18"
    ],
    "pickup": [
      550,
      436,
      "capacity"
    ],
    "leap": [
      584,
      397,
      "pickup"
    ],
    "damage_step_17": [
      615,
      415,
      "leap"
    ],
    "damage_step_18": [
      644,
      436,
      "damage_step_17"
    ],
    "damage_step_19": [
      670,
      462,
      "damage_step_18"
    ],
    "damage_step_20": [
      691,
      491,
      "damage_step_19"
    ],
    "damage_step_21": [
      716,
      529,
      "damage_step_20"
    ],
    "wheel_step_22": [
      605,
      430,
      "leap"
    ],
    "wheel_step_23": [
      625,
      458,
      "wheel_step_22"
    ],
    "wheel_step_24": [
      651,
      483,
      "wheel_step_23"
    ],
    "wheel_step_25": [
      678,
      505,
      "wheel_step_24"
    ],
    "wheel_step_26": [
      661,
      570,
      "wheel_step_10"
    ],
    "rate_step_20": [
      664,
      354,
      "damage_step_17"
    ],
    "rate_step_21": [
      702,
      309,
      "rate_step_20"
    ],
    "rate_step_22": [
      705,
      276,
      "rate_step_21"
    ],
    "rate_step_23": [
      765,
      203,
      "rate_step_22"
    ],
    "rate_step_24": [
      767,
      232,
      "rate_step_23"
    ],
    "rate_step_25": [
      786,
      210,
      "rate_step_24"
    ],
    "rate_step_26": [
      794,
      230,
      "rate_step_25"
    ],
    "rate_step_27": [
      734,
      302,
      "rate_step_26"
    ],
    "rate_step_28": [
      707,
      403,
      "damage_step_18"
    ],
    "rate_step_29": [
      751,
      358,
      "rate_step_28"
    ],
    "rate_step_30": [
      754,
      326,
      "rate_step_29"
    ],
    "rate_step_31": [
      806,
      275,
      "rate_step_30"
    ],
    "rate_step_32": [
      821,
      259,
      "rate_step_31"
    ],
    "rate_step_33": [
      842,
      267,
      "rate_step_31"
    ],
    "rate_step_34": [
      850,
      288,
      "rate_step_33"
    ],
    "rate_step_35": [
      811,
      326,
      "rate_step_34"
    ],
    "rate_step_36": [
      782,
      355,
      "rate_step_35"
    ],
    "damage_step_22": [
      728,
      419,
      "damage_step_19"
    ],
    "damage_step_23": [
      746,
      447,
      "damage_step_20"
    ],
    "damage_step_24": [
      797,
      404,
      "damage_step_23"
    ],
    "damage_step_25": [
      831,
      402,
      "damage_step_24"
    ],
    "damage_step_26": [
      903,
      341,
      "damage_step_25"
    ],
    "damage_step_27": [
      896,
      320,
      "damage_step_26"
    ],
    "damage_step_28": [
      849,
      360,
      "damage_step_27"
    ],
    "damage_step_29": [
      816,
      389,
      "damage_step_28"
    ],
    "damage_step_30": [
      804,
      374,
      "damage_step_24"
    ],
    "damage_step_31": [
      875,
      313,
      "damage_step_30"
    ]
  },
  "costs": {
    "damage": [
      0,
      9,
      9,
      14,
      21,
      31,
      46,
      69,
      103,
      1250
    ],
    "rate": [
      14,
      21,
      31,
      46,
      68,
      103,
      154,
      231,
      346,
      346
    ],
    "weak": [
      14
    ],
    "workshop": [
      17
    ],
    "refund": [
      6
    ],
    "recurve": [
      370
    ],
    "longbow": [
      16700
    ],
    "spark": [
      18
    ],
    "crit": [
      24
    ],
    "combo": [
      190
    ],
    "rain": [
      3200
    ],
    "steady": [
      26
    ],
    "wheel": [
      21
    ],
    "capacity": [
      7,
      24
    ],
    "pickup": [
      11
    ],
    "pace": [
      21
    ],
    "leap": [
      32
    ],
    "pet": [
      28
    ],
    "damage_mult": [
      390,
      820,
      1460
    ],
    "rate_flat": [
      260,
      320,
      420,
      550,
      720,
      930,
      1210,
      1560
    ]
  },
  "captions": {
    "seeds": [
      "Semillas aladas",
      "Winged seeds",
      "Caen tres semillas a distinta velocidad. Cada acierto deja 4 flechas en el suelo. Si rompés las tres, duplicás la cosecha a 24 flechas en total. El taller también gana 0,025 flechas/s.",
      "Three seeds fall at different speeds. Each hit drops 4 arrows on the ground. Hit all three to double the harvest to 24 arrows total. The workshop also gains 0.025 arrows/s."
    ],
    "sentinel": [
      "Ballesta del claro",
      "Clearing crossbow",
      "Instalá una ballesta a la derecha del sendero y sumá 0,025 flechas/s al taller. Cargala de a ocho. Conservás cuatro flechas. Dispara al tronco y espera cuando tenés que acertar al punto débil.",
      "Build a crossbow to the right of the path and add 0.025 arrows/s to the workshop. Load up to eight arrows and keep four. It fires at the trunk and waits when you need to hit a weak spot."
    ],
    "damage": [
      "Daño por flecha",
      "Arrow damage",
      "Cada nivel suma un 20 % del daño base del arco. En el nivel 10 salen hasta tres flechas por disparo.",
      "Each level adds 20% of your bow’s base damage. At level 10, release up to three arrows per shot."
    ],
    "workshop": [
      "Taller de flechas",
      "Arrow workshop",
      "Construí un taller que lanza atados de tres flechas por el claro.",
      "Build a workshop that launches bundles of three arrows across the clearing."
    ],
    "capacity": [
      "Carcaj de viaje",
      "Travel quiver",
      "Llevá 16 flechas más por cada nivel.",
      "Carry 16 extra arrows per level."
    ],
    "rate": [
      "Velocidad de ataque",
      "Attack speed",
      "Cada nivel suma un 12 % de la cadencia base de tu arco.",
      "Each level adds 12% of your bow’s base firing rate."
    ],
    "damage_step": [
      "Punta reforzada",
      "Reinforced tip",
      "Sumá 1 de daño base por flecha antes de aplicar los multiplicadores.",
      "Add 1 base damage per arrow before multipliers."
    ],
    "rate_step": [
      "Suelta ágil",
      "Quick release",
      "Sumá un 2 % de la cadencia base de tu arco.",
      "Add 2% of your bow’s base firing rate."
    ],
    "wheel_step": [
      "Engranaje del taller",
      "Workshop gearing",
      "El taller produce 0,025 flechas más por segundo.",
      "The workshop produces an extra 0.025 arrows per second."
    ],
    "damage_mult": [
      "Potencia multiplicada",
      "Compound power",
      "Cada nivel multiplica por 1,2 el daño que ya tiene cada flecha.",
      "Each level multiplies your existing arrow damage by 1.2."
    ],
    "rate_flat": [
      "Disparo adicional",
      "Extra shot",
      "Cada nivel agrega un disparo por segundo a cualquiera de tus arcos.",
      "Each level adds one shot per second to any bow."
    ],
    "weak": [
      "Ojo de veta",
      "Grain eye",
      "Duplicá el daño de tus flechas al acertar en el punto débil.",
      "Deal double arrow damage when you hit a weak point."
    ],
    "recurve": [
      "Arco rápido",
      "Recurve bow",
      "Desbloqueá un segundo arco de tiro rápido. Usa las flechas de tu carcaj.",
      "Unlock a second, faster-firing bow. It uses arrows from your quiver."
    ],
    "wheel": [
      "Rueda de savia",
      "Sap wheel",
      "Acelerá la producción del taller para que lance atados más seguido.",
      "Speed up workshop production so bundles launch more often."
    ],
    "pickup": [
      "Recogida de hojas",
      "Leaf gathering",
      "Juntá los atados desde más lejos al pasar cerca.",
      "Collect nearby bundles from farther away."
    ],
    "pace": [
      "Paso del porteador",
      "Carrier’s stride",
      "Caminá un 6 % más rápido mientras llevás al menos cuatro flechas.",
      "Walk 6% faster while carrying at least four arrows."
    ],
    "spark": [
      "Chispa de copa",
      "Canopy spark",
      "Cada ocho aciertos, una descarga le hace daño extra al blanco.",
      "Every eight hits, a spark deals extra damage to the target."
    ],
    "refund": [
      "Recuperar savia",
      "Reclaim sap",
      "Con un clic derecho sobre una mejora comprada, devolvés un nivel y recuperás lo que pagaste.",
      "Right-click a purchased upgrade to return one level and recover the sap you spent."
    ],
    "longbow": [
      "Arco largo",
      "Longbow",
      "Desbloqueá un tercer arco. Sus flechas pegan más fuerte que las del arco rápido.",
      "Unlock a third bow. Its arrows hit harder than the recurve bow’s."
    ],
    "combo": [
      "Buena racha",
      "On a roll",
      "Desbloqueá el combo. Los aciertos seguidos dan savia extra y los puntos débiles hacen crecer la racha más rápido.",
      "Unlock the combo. Consecutive hits earn bonus sap and weak points build your streak faster."
    ],
    "rain": [
      "Lluvia de flechas",
      "Arrow rain",
      "Por cada flecha que soltás, caen tres más sobre el mismo lugar. Solo la primera sale de tu carcaj.",
      "Every arrow you release calls three more down on the same spot. Only the original comes from your quiver."
    ],
    "crit": [
      "Golpe crítico",
      "Critical hit",
      "Cada vez que disparás hay un 10 % de probabilidad de que todas las flechas de ese tiro hagan el doble de daño.",
      "Each shot has a 10% chance to deal double damage with every arrow in that volley."
    ],
    "steady": [
      "Tiro sostenido",
      "Steady fire",
      "Encadená cuatro disparos sin parar para ganar un 20 % de daño.",
      "Fire four shots without a break to gain 20% damage."
    ],
    "leap": [
      "Salto al atado",
      "Bundle leap",
      "Mirá un atado de flechas en el suelo y saltá para impulsarte hacia él.",
      "Look at a bundle of arrows on the ground and jump to spring toward it."
    ],
    "pet": [
      "Una caricia",
      "Pet the dog",
      "Acercate a tu perro para darle una caricia.",
      "Walk over to your dog to give it a pat."
    ]
  },
  "strokes": {
    "damage": "M3 21 15 9",
    "damage_step": "M5 20l6-6",
    "rate": "M4 5l7 7-7 7 M13 5l7 7-7 7",
    "rate_step": "M3 9h6 M2 15h5 M12 5l7 7-7 7",
    "weak": "M21 12a9 9 0 1 1-18 0 9 9 0 1 1 18 0Z",
    "workshop": "M2 11l10-8 10 8 M5 10v10h14V10 M10 20v-6h4v6",
    "refund": "M4 11a8 8 0 1 1 2 8 M3 5v7h7",
    "recurve": "M3 20l3-3q8-1 9-9l4-4 M3 20l16-16",
    "longbow": "M3 21Q21 20 21 3L3 21Z",
    "spark": "M14 2 5 13h6l-1 9L20 10h-7l1-8Z",
    "combo": "M10 14a4 4 0 0 0 6 0l4-4a4 4 0 0 0-6-6l-2 2 M14 10a4 4 0 0 0-6 0l-4 4a4 4 0 0 0 6 6l2-2",
    "multishot": "M12 21V4 M9 7l3-3 3 3 M12 20 3 9 M3 13V9h4 M12 20 21 9 M17 9h4v4",
    "rain": "M5 3v11 M2 11l3 4 3-4 M12 7v12 M9 16l3 4 3-4 M19 3v11 M16 11l3 4 3-4",
    "crit": "M12 2l2.5 6.5L21 6l-3.5 6L22 16l-7-1-3 7-2-7-7 1 4-5-3-5 6 2Z",
    "steady": "M2 12h5l3-6 4 12 3-6h5",
    "wheel": "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z M12 4v16 M4 12h16",
    "wheel_step": "M17 12a5 5 0 1 1-10 0 5 5 0 1 1 10 0Z M12 4v3 M12 17v3 M4 12h3 M17 12h3",
    "capacity": "m5 10 10 3-4 8-8-3Z M9 10l3-7 M13 11l5-7",
    "pickup": "M3 20 15 8 M5 16C3 7 11 4 21 3c-1 9-6 16-16 13Z",
    "seeds": "M7 14C3 14 2 10 2 7c5 0 8 2 9 6 M11 14c0-7 3-11 10-12 0 6-3 11-8 13 M13 14c4 2 3 6 0 8-4 0-7-3-6-6 1-2 3-3 6-2Z",
    "pace": "M6 4h6v7l3 2 4 1 2 3v3H4v-5l2-3Z",
    "leap": "M3 19Q8 4 20 5 M14 2l7 2-2 7",
    "pet": "M8 14q4-6 8 0l2 4q0 3-4 2l-2-1-3 1q-4 1-3-3Z",
    "damage_mult": "M3 21l10-10 M16 15l5 5 M21 15l-5 5",
    "rate_flat": "M2 5l6 7-6 7 M10 6l5 6-5 6 M16 17h6 M19 14v6",
    "sentinel": "M2 8q9-9 20 0L3 8 M12 4v10 M8 21l4-8 5 8"
  },
  "fills": {
    "damage": "M10 9 21 3l-5 12Z",
    "damage_step": "M5 12 20 3l-6 15-2-5Z",
    "weak": "M15 12a3 3 0 1 1-6 0 3 3 0 1 1 6 0Z",
    "wheel_step": "M13.7 12a1.7 1.7 0 1 1-3.4 0 1.7 1.7 0 1 1 3.4 0Z",
    "pet": "M6 9a2 2.4 0 1 1-4 0 2 2.4 0 1 1 4 0Z M11 5.5a2 2.5 0 1 1-4 0 2 2.5 0 1 1 4 0Z M17 5.5a2 2.5 0 1 1-4 0 2 2.5 0 1 1 4 0Z M22 9a2 2.4 0 1 1-4 0 2 2.4 0 1 1 4 0Z",
    "damage_mult": "M8 9 19 3l-6 11Z"
  }
};
