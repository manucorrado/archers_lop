const $ = id => document.getElementById(id);
const map = $("map"), note = $("note"), lines = $("edges"), layer = $("nodes");
const ranksAtStart = { damage: 4, rate: 2, workshop: 1 };
const levels = {}, depths = {}, buttons = {}, points = {};
let language = "es", sap, ranks, zoom, pan, active = "", press;
const text = (es, en) => language === "es" ? es : en;
const ids = Object.keys(atlas.vertices);
for (const id of ids) {
  const parent = atlas.vertices[id][2];
  depths[id] = parent ? depths[parent] + 1 : 0;
  levels[id] = atlas.costs[id] || [Math.round(depths[id] ** 2 * 4.75) + 2];
}
const maxRanks = ids.reduce((sum,id) => sum + levels[id].length, 0);
function family(id) {
  if(id === "wheel_step_05") return "sentinel";
  if(id === "wheel_step_11") return "seeds";
  return id.replace(/_step_\d+$/, "_step");
}
function state(id) {
  return ranks[id] === levels[id].length ? "owned" : ranks[id] ? "part" : "open";
}
function status(id) {
  return {owned:text("Completa","Complete"),part:text("En progreso","In progress"),open:text("Sin comprar","Unpurchased")}[state(id)];
}
function unlocked(id) {
  const parent = atlas.vertices[id][2];
  return (!parent || ranks[parent] > 0) && (id !== "pet" || ranks.damage >= 10);
}
function visible(id) {
  if(unlocked(id) || ranks[id]) return true;
  return ids.some(other => {
    if(!ranks[other]) return false;
    for(let at = atlas.vertices[other][2]; at; at = atlas.vertices[at][2]) if(at === id) return true;
    return false;
  });
}
function nameOf(id) {
  const key = family(id), caption = atlas.captions[key];
  return caption[language === "es" ? 0 : 1] + (key.endsWith("_step") ? " " + Number(id.split("_").at(-1)) : "");
}
function updateLabels() {
  document.documentElement.lang = language;
  for (const el of document.querySelectorAll("[data-es]")) el.textContent = el.dataset[language];
  $("lang").textContent = text("English","Español");
  $("wallet").textContent = sap.toLocaleString(text("es-AR","en-US"));
  const count = Object.values(ranks).reduce((sum,n) => sum+n,0);
  $("rankTotal").textContent = count + " / " + maxRanks + " " + text("niveles comprados","levels purchased");
  $("map").setAttribute("aria-label", text("Mapa de mejoras","Upgrade map"));
  $("less").setAttribute("aria-label", text("Alejar","Zoom out"));
  $("more").setAttribute("aria-label", text("Acercar","Zoom in"));
  $("homeZoom").setAttribute("aria-label", text("Centrar mapa","Center map"));
}
function glyph(id) {
  const key = id === "damage" && ranks.damage >= 9 ? "multishot" : family(id);
  const s = state(id), max = levels[id].length;
  let ring = "";
  if (s === "part") {
    const segment = 100 / max, gap = 2;
    for(let n=0; n<max; n++){
      ring += '<circle cx="28" cy="28" r="24" fill="none" stroke="'+(n < ranks[id] ? "#75502d" : "#c7b997")+'" stroke-width="'+(n < ranks[id] ? 4.4 : 1.3)+'" pathLength="100" stroke-dasharray="'+(segment-gap)+' '+(100-segment+gap)+'" stroke-dashoffset="'+(-n*segment)+'" transform="rotate(-90 28 28)"/>';
    }
  } else if(s === "owned") {
    ring = '<circle cx="28" cy="28" r="22" fill="none" stroke="#efe3bc" stroke-width=".9"/>';
  }
  const border = s === "open" ? 'stroke-dasharray="3.5 2.2" stroke="#79654a"' : 'stroke="#4a3e2e"';
  const badge = s === "part" ? ranks[id] + "/" + max : s === "owned" ? "✓" : "+";
  return '<svg viewBox="0 0 56 56" aria-hidden="true"><circle cx="28" cy="28" r="26" fill="'+(s === "part" ? "#ead5a5" : "var(--stamp-fill)")+'" '+border+' stroke-width="1.7"/>'+ring+
    '<svg x="14" y="14" width="28" height="28" viewBox="0 0 24 24"><path d="'+atlas.strokes[key]+'" fill="none" stroke="currentColor" stroke-width="1.95" stroke-linecap="round" stroke-linejoin="round"/>' +
    (atlas.fills[key] ? '<path d="'+atlas.fills[key]+'" fill="currentColor"/>' : "") + '</svg></svg><span class="bubble" aria-hidden="true">'+badge+'</span>';
}
function makeButton(id){
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.upgrade = id;
  button.addEventListener("pointerenter",() => { if(!press) inspect(id); });
  button.addEventListener("pointerleave",() => { if(!button.matches(":focus-visible")) inspect(""); });
  button.addEventListener("focus",() => inspect(id));
  button.addEventListener("blur",() => { if(active === id) inspect(""); });
  button.addEventListener("click",event => { if(!press?.moved && !suppressClick) buy(id); });
  button.addEventListener("contextmenu",event => {event.preventDefault(); refund(id);});
  button.addEventListener("keydown",event => {
    if(event.key === "Delete" || event.key === "Backspace"){ event.preventDefault(); refund(id); }
  });
  layer.append(button); return button;
}
function redraw() {
  const w = map.clientWidth, h = map.clientHeight;
  const scale = Math.min(h/143, w/220) * zoom;
  const radius = Math.max(12, Math.min(33, scale*7.6));
  lines.replaceChildren();
  for(const id of ids){
    const btn = buttons[id];
    if(!visible(id)) { if(btn) btn.hidden = true; delete points[id]; continue; }
    const [vx,vy,parent] = atlas.vertices[id];
    const x=(vx-455)*scale + w*.575 + pan.x, y=(vy-459)*scale + h*.47 + pan.y;
    const b=buttons[id] || (buttons[id]=makeButton(id));
    b.hidden=false; b.className="node "+state(id);
    b.style.left=x+"px"; b.style.top=y+"px"; b.style.width=b.style.height=radius*2+"px";
    b.setAttribute("aria-label",nameOf(id)+", "+status(id)+", "+(ranks[id]||0)+"/"+levels[id].length);
    b.setAttribute("aria-disabled", String(state(id)==="owned" || !unlocked(id) || levels[id][ranks[id] || 0]>sap));
    b.innerHTML=glyph(id);
    points[id] = {x,y,radius};
    if(parent && points[parent]) {
      const edge=document.createElementNS("http://www.w3.org/2000/svg","line");
      for(const [key,val] of Object.entries({x1:points[parent].x,y1:points[parent].y,x2:x,y2:y,stroke:ranks[id]?"#463f32":"#877554","stroke-width":ranks[id]?2.7:1.7}))edge.setAttribute(key,val);
      lines.append(edge);
    }
  }
  $("homeZoom").textContent = Math.round(zoom*100)+" %";
  updateLabels(); inspect(active);
}
function inspect(id) {
  if(active && buttons[active]) buttons[active].removeAttribute("aria-describedby");
  active = points[id] ? id : "";
  if(!active || press?.moved){note.hidden=true;return;}
  const rank = ranks[id]||0, limit=levels[id].length;
  $("noteStatus").textContent=status(id)+" · "+rank+"/"+limit;
  $("noteName").textContent=nameOf(id);
  $("noteBody").textContent=atlas.captions[family(id)][language === "es"?2:3];
  const cost=levels[id][rank];
  $("noteBuy").textContent = rank===limit ? text("Todos los niveles comprados","All levels purchased") :
    cost>sap ? text("Necesitás ","Requires ")+cost+text(" de savia"," sap") :
    text("Clic o Enter · Comprar por ","Click or Enter · Buy for ")+cost+text(" de savia"," sap");
  buttons[id].setAttribute("aria-describedby","note");note.hidden=false;
  const {x,y,radius} = points[id], width=note.offsetWidth,height=note.offsetHeight;
  const gap=radius+18, margin=6, mapWidth=map.clientWidth,mapHeight=map.clientHeight;
  const candidates=[[x+gap,y-height*.45],[x-gap-width,y-height*.45],[x-width*.5,y+gap],[x-width*.5,y-height-gap]];
  // Leave neighbouring seals visible when the graph is densely packed.
  candidates.push([x+gap+width*.55,y-height*.45],[x-gap-width*1.55,y-height*.45]);
  let best, bestScore=1e9;
  for(const p of candidates){
    const left=Math.max(margin,Math.min(mapWidth-width-margin,p[0])), top=Math.max(margin,Math.min(mapHeight-height-margin,p[1]));
    let score=Math.abs(left-p[0])+Math.abs(top-p[1]);
    for(const n of Object.values(points)) {
      if(n.x+n.radius>left && n.x-n.radius<left+width && n.y+n.radius>top && n.y-n.radius<top+height) score+=200;
    }
    if (score<bestScore) {bestScore=score;best=[left,top];}
  }
  note.style.left=best[0]+"px";note.style.top=best[1]+"px";
}
function buy(id){
  const rank=ranks[id]||0,price=levels[id][rank];
  if(!unlocked(id)||price===undefined||sap<price)return;
  sap-=price;ranks[id]=rank+1;redraw();
}
function refund(id) {
  if(!ranks.refund || id==="refund" || !ranks[id])return;
  sap+=levels[id][--ranks[id]];redraw();
}
function reset(){
  active="";ranks={...ranksAtStart};sap=850;zoom=1;pan={x:0,y:0};redraw();
}
function zoomBy(factor,center) {
  const previous=zoom, value=Math.min(2.5,Math.max(.45,zoom*factor));
  if(center){
    const k=value/previous;
    pan.x=center.x-(center.x-pan.x)*k;pan.y=center.y-(center.y-pan.y)*k;
  }
  zoom=value;redraw();
}
let suppressClick=false;
map.addEventListener("pointerdown",event=>{
  if(event.button!==0 && event.button!==1)return;
  press={x:event.clientX,y:event.clientY,panX:pan.x,panY:pan.y,moved:false,id:event.pointerId};suppressClick=false;
});
map.addEventListener("pointermove",event=>{
  if(!press || !event.buttons)return;
  const dx=event.clientX-press.x, dy=event.clientY-press.y;
  if(!press.moved && Math.hypot(dx,dy)<5)return;
  if(!press.moved){map.setPointerCapture(press.id);press.moved=true;map.classList.add("dragging");}
  pan.x=press.panX+dx;pan.y=press.panY+dy;inspect("");redraw();
});
function endDrag(){if(press){suppressClick=press.moved;press=null;}map.classList.remove("dragging");}
window.addEventListener("pointerup",endDrag);window.addEventListener("blur",endDrag);
map.addEventListener("pointercancel",endDrag);
map.addEventListener("wheel",event=>{
  event.preventDefault();const rect=map.getBoundingClientRect();
  zoomBy(event.deltaY<0?1.15:1/1.15,{x:event.clientX-rect.left-map.clientWidth*.575,y:event.clientY-rect.top-map.clientHeight*.47});
},{passive:false});
$("less").onclick=()=>zoomBy(1/1.2);
$("more").onclick=()=>zoomBy(1.2);
$("homeZoom").onclick=()=>{zoom=1;pan={x:0,y:0};redraw();};
$("lang").onclick=()=>{language=language==="es"?"en":"es";redraw();};
$("reset").onclick=reset;
window.addEventListener("resize",redraw);reset();
