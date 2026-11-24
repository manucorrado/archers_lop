"use strict";
const pairs = [
  ["Palatino Linotype","Segoe UI","book"], ["Constantia","Trebuchet MS","book"],
  ["Bahnschrift","Cambria","tool"], ["Sitka Text","Segoe UI","book"],
  ["Alegreya","Trebuchet MS","book"], ["Fraunces","Segoe UI","book"],
  ["Bitter","Segoe UI","tool"], ["Bree Serif","Trebuchet MS","tool"],
  ["Bricolage Grotesque","Constantia","tool"], ["Oxanium","Trebuchet MS","tool"],
  ["Exo 2","Constantia","tool"], ["Averia Serif Libre","Trebuchet MS","book"],
  ["Pixelify Sans","Trebuchet MS","pixel"], ["Silkscreen","Segoe UI","pixel"],
  ["Tiny5","Trebuchet MS","pixel"], ["VT323","Constantia","pixel"]
];
const $ = id => document.getElementById(id);
const pick = n => Number.isInteger(n) && n >= 1 && n <= pairs.length;
const hash = new URLSearchParams(location.hash.slice(1));
let reference = pick(+hash.get("ref")) ? +hash.get("ref") : 2;
let chosen = pick(+hash.get("ver")) ? +hash.get("ver") : 13;
let group = "all", english = hash.get("idioma") === "en";
const say = (es,en) => english ? en : es;
const labels = {all:["Todas","All"],book:["De libro","Book"],tool:["De taller","Workshop"],pixel:["De píxeles","Pixel"]};
function style(element, number) {
  const [title,body] = pairs[number-1];
  element.style.setProperty("--headline",'"'+title+'",serif');
  element.style.setProperty("--body",'"'+body+'",sans-serif');
}
function saveSelection() {
  const params = new URLSearchParams({ref:reference,ver:chosen,idioma:english?"en":"es"});
  history.replaceState(null,"","#"+params);
}
function page(id, number) {
  const article = $(id);
  const [title,body] = pairs[number-1];
  style(article, number);
  article.innerHTML = '<div class="meta"><span></span><span class="role"></span></div>'+
    '<div class="folio"><strong></strong><span></span></div><h3 class="upname"></h3>'+
    '<p class="bodycopy"></p><div class="purchase"><span></span><span class="price"></span></div>';
  article.querySelector(".meta span").textContent = 'F'+number+' · '+title+' / '+body;
  if (id === "reference") article.querySelector(".role").textContent=say("Referencia","Reference");
  else {
    const pin=document.createElement("button");pin.className="pin";pin.type="button";pin.disabled=number===reference;
    pin.textContent=say("Fijar de referencia","Set as reference");
    pin.onclick=()=>{reference=chosen;draw();};article.querySelector(".role").append(pin);
  }
  article.querySelector(".folio strong").textContent=say("Árbol de mejoras","Upgrade tree");
  article.querySelector(".folio span").textContent=say("34.640 de savia","34,640 sap");
  article.querySelector(".upname").textContent=say("Disparo triple","Triple shot");
  article.querySelector(".bodycopy").textContent=say("Soltá hasta tres flechas en abanico. Cada flecha hace el daño completo del arco.","Release up to three arrows in a fan. Each arrow deals the bow’s full damage.");
  article.querySelector(".purchase span").textContent=say("Daño · Nivel 9/10","Damage · Level 9/10");
  article.querySelector(".price").textContent=say("Comprar · 1.250 de savia","Buy · 1,250 sap");
}
function draw() {
  document.documentElement.lang=english?"en":"es";$("language").textContent=say("English","Español");$("language").lang=say("en","es");
  $("title").textContent=say("Tipografías para el Atlas","Type for the Atlas");
  $("help").textContent=say("Elegí una muestra para verla al lado de la referencia. Las dos fichas usan el mismo texto y tamaño para que puedas comparar los trazos.","Choose a sample to compare it with the reference. Both cards use the same text and sizes so you can compare the letterforms.");
  $("catalog").textContent=say("16 muestras","16 samples");$("note").textContent=say("F1–F4 usan fuentes de Windows. F5–F16 incluyen la fuente para verlas sin conexión.","F1–F4 use Windows fonts. F5–F16 include the font for offline comparison.");
  $("filters").setAttribute("aria-label",say("Filtrar muestras","Filter samples"));document.querySelector(".spread").setAttribute("aria-label",say("Comparación tipográfica","Type comparison"));
  page("reference",reference);page("chosen",chosen);
  for (const [key, label] of Object.entries(labels)) {
    let button=$("filters").querySelector('[data-group="'+key+'"]');
    if(!button){button=document.createElement("button");button.dataset.group=key;button.onclick=()=>{group=key;draw();};$("filters").append(button);}
    button.textContent=say(...label);button.setAttribute("aria-pressed",String(key===group));
  }
  pairs.forEach(([title,body,category],index)=>{
    const number=index+1;
    let button=$("samples").querySelector('[data-id="'+number+'"]');
    if(!button){button=document.createElement("button");button.className="sample";button.dataset.id=number;button.innerHTML="<small></small><b></b>";button.onclick=()=>{chosen=number;draw();};$("samples").append(button);}
    style(button,number);button.hidden=group!=="all" && category!==group;
    button.style.display=button.hidden?"none":"";
    button.querySelector("small").textContent='F'+number+' · '+title;
    button.querySelector("b").textContent=say("Madera y savia","Wood and sap");
    button.setAttribute("aria-label",'F'+number+' · '+title+' / '+body);button.setAttribute("aria-pressed",String(chosen===number));
  });
  saveSelection();
}
$("language").onclick=()=>{english=!english;draw();};draw();
