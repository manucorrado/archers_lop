(() => {
 const $=id=>document.getElementById(id), map=$('map'), tip=$('tip');
 const words={
   title:['Atlas de mejoras','Upgrade atlas'], collection:['Colección','Collection'], drawing:['Arco, flecha y carcaj','Bow, arrow and quiver'], close:['Cerrar','Close'],
   sap:['savia','sap'],states:['Estado de las piezas','Piece status'],open:['Sin comprar','Unpurchased'],partial:['En progreso','In progress'],complete:['Completa','Complete'],
   levels:['niveles comprados','levels purchased'],back:['← Volver a las opciones','← Back to studies'], reset:['Reiniciar prueba','Reset study'],
   buy:['Clic o Enter · Comprar por','Click or Enter · Buy for'],insufficient:['Falta savia','More sap needed'],all:['Todos los niveles comprados','All levels purchased'],
   less:['Alejar','Zoom out'],more:['Acercar','Zoom in'],fit:['Centrar mapa','Center map']
 };
 const ids=Object.keys(atlas.vertices), depths={}, costs={};
 for(const id of ids){
   const parent=atlas.vertices[id][2];
   depths[id]=parent?depths[parent]+1:0;
   costs[id]=atlas.costs[id]||[Math.round(depths[id]**2*4.75)+2];
 }
 const total=Object.values(costs).reduce((sum,c)=>sum+c.length,0);
 let ranks,balance,lang=0,zoom,center,view,idOver='',drag,blockClick=false;
 const w=k=>words[k][lang],ns='http://www.w3.org/2000/svg';
 const tag=(kind,attrs={})=>{const e=document.createElementNS(ns,kind);for(const [k,v] of Object.entries(attrs))e.setAttribute(k,v);return e;};
 function keyFor(id){if(id==='wheel_step_05')return 'sentinel';if(id==='wheel_step_11')return 'seeds';return id.replace(/_step_\d+$/,'_step');}
 function title(id){const key=keyFor(id);return atlas.captions[key][lang]+(key.endsWith('_step')?' '+Number(id.split('_').pop()):'');}
 function stage(id){return ranks[id]===costs[id].length?'complete':ranks[id]?'partial':'open';}
 function unlocked(id){const parent=atlas.vertices[id][2];return (!parent || ranks[parent]>0) && (id!=='pet'||ranks.damage>=10);}
 function revealed(){const visible=new Set(ids.filter(unlocked));for(const id of ids.filter(id=>ranks[id]))for(let step=id;step;step=atlas.vertices[step][2])visible.add(step);return [...visible];}
 const plate='M-6.9 -8H4.2L7.7 -4.6V5.2L5.3 7.7H-5.1L-7.7 5V-7.2Z';
 function glyph(state,icon,rank,max){
   const g=tag('g',{'aria-hidden':'true'}), open=state==='open',done=state==='complete';
   // An unfilled mortise, a partly inlaid plate with its level, and a polished piece with two rivets.
   const face=open?'#392a22':done?'url(#metal)':'#5c452e';
   g.append(tag('path',{d:plate,transform:'translate(.37 .56)',fill:'#24170f',stroke:'#1f130d','stroke-width':.65}));
   g.append(tag('path',{d:plate,class:'outline',fill:face,stroke:open?'#ae8d61':'#f5d69c','stroke-width':open?.38:.55}));
   if(open){
     g.append(tag('path',{d:'M-5.8 -6.2H3.6L5.9 -4.1V4.2L4.4 5.8H-4.5L-5.9 4.4Z',fill:'none',stroke:'#be9a70','stroke-width':.25,'stroke-dasharray':'1.2 .7'}));
   } else if(done){
     g.append(tag('path',{d:'M-6.4 -6.5H3.7L6.3 -4V4.5L4.8 6.2H-4.8L-6.3 4.4Z',stroke:'#705839',fill:'none','stroke-width':.25}));
     for(const x of [-5.5,5.25])g.append(tag('circle',{cx:x,cy:0,r:.48,fill:'#634928'}));
   } else {
     const width=12/max;
     for(let i=0;i<max;i++)g.append(tag('path',{d:'M'+(-6+i*width)+' 5.8h'+(width*.7),stroke:i<rank?'#fff0b3':'#77634e','stroke-width':i<rank?1.3:.4}));
   }
   const ink=done?'#47341e':open?'#cdb795':'#f4daaa';
   const pict=tag('g',{transform:'translate(-4.2 -5.3) scale(.36)',stroke:ink,'stroke-width':1.85,'stroke-linecap':'round','stroke-linejoin':'round',fill:'none'});
   pict.append(tag('path',{d:atlas.strokes[icon]}));
   if(atlas.fills[icon])pict.append(tag('path',{d:atlas.fills[icon],stroke:'none',fill:ink}));
   g.append(pict);
   const badge=state==='partial'?rank+'/'+max:done?'✓':'+';
   const width=state==='partial'?8.8:3.9;
   g.append(tag('rect',{x:-width/2,y:6.6,width,height:3.35,rx:.3,fill:open?'#382820':done?'#f2d6a0':'url(#brass)',stroke:'#bd995f','stroke-width':.24}));
   const label=tag('text',{x:0,y:9.13,'font-size':state==='partial'?2.65:2.95,'font-weight':700,'font-family':'Segoe UI,sans-serif','text-anchor':'middle',fill:open?'#dfc09a':'#35271a'});
   label.textContent=badge;g.append(label);return g;
 }
 function labels(){
   document.documentElement.lang=lang?'en':'es';document.querySelectorAll('[data-word]').forEach(e=>{e.textContent=w(e.dataset.word);});
   $('lang').textContent=lang?'Español':'English';$('close').textContent=w('close');
   $('sap').textContent=balance.toLocaleString(lang?'en-US':'es-AR');$('levels').textContent=Object.values(ranks).reduce((s,n)=>s+n,0)+' / '+total+' '+w('levels');
   map.setAttribute('aria-label',w('title'));$('minus').setAttribute('aria-label',w('less'));$('plus').setAttribute('aria-label',w('more'));$('fit').setAttribute('aria-label',w('fit'));
   $('legend').replaceChildren();
   for(const [state,rank] of [['open',0],['partial',4],['complete',10]]){
     const li=document.createElement('li'),sample=tag('svg',{viewBox:'-10 -10 20 22','aria-hidden':'true'});
     sample.append(glyph(state,'damage',rank,10));li.append(sample,document.createTextNode(w(state)));$('legend').append(li);
   }
 }
 function frame(){
   const rect=map.getBoundingClientRect(), height=152/zoom;
   const width=height*(rect.width/rect.height);
   view={left:center.x-width*.58,top:center.y-height*.5,width,height};
   map.setAttribute('viewBox',[view.left,view.top,width,height].join(' '));$('fit').textContent=Math.round(zoom*100)+' %';if(idOver)inspect(idOver);
 }
 function redraw(){
   const visible=revealed(), routes=$('routes'), pieces=$('pieces');
   const elements=new Map(Array.from(pieces.children,e=>[e.dataset.id,e]));
   routes.replaceChildren();
   for(const id of visible){
     const [x,y,parent]=atlas.vertices[id],status=stage(id);
     if(parent && visible.includes(parent)){
       const [px,py]=atlas.vertices[parent],coords={x1:px,y1:py,x2:x,y2:y};
       routes.append(tag('line',{...coords,'class':'route-shadow'}),tag('line',{...coords,class:'route'+(ranks[id]?' established':'')}));
     }
     let e=elements.get(id);
     if(!e){
       e=tag('g',{class:'tier',role:'button',tabindex:0,'data-id':id,'data-upgrade':id,transform:'translate('+x+' '+y+')'});
       e.addEventListener('pointerenter',()=>{if(!drag)inspect(id);});e.addEventListener('pointerleave',()=>{if(!e.matches(':focus-visible'))inspect('');});
       e.addEventListener('focus',()=>inspect(id));e.addEventListener('blur',()=>{if(idOver===id)inspect('');});
       e.addEventListener('click',()=>{if(!blockClick)purchase(id);});
       e.addEventListener('contextmenu',event=>{event.preventDefault();refund(id);});
       e.addEventListener('keydown',event=>{
         if([' ','Enter'].includes(event.key)){event.preventDefault();purchase(id);}
         if(['Delete','Backspace'].includes(event.key)){event.preventDefault();refund(id);}
       });
       pieces.append(e);
     }
     e.dataset.state=status;e.setAttribute('aria-label',title(id)+' · '+w(status)+' · '+(ranks[id]||0)+'/'+costs[id].length);
     e.setAttribute('aria-disabled',String(status==='complete'||!unlocked(id)||costs[id][ranks[id]||0]>balance));
     const icon=id==='damage' && ranks[id]>=9?'multishot':keyFor(id);
     e.replaceChildren(glyph(status,icon,ranks[id]||0,costs[id].length));elements.delete(id);
   }
   for(const [id,e] of elements){e.remove();if(idOver===id)idOver='';}
   labels();frame();inspect(idOver);
 }
 function inspect(id){
   if(idOver)map.querySelector('[data-id="'+idOver+'"]')?.removeAttribute('aria-describedby');
   const item=id?map.querySelector('[data-id="'+id+'"]'):null;idOver=item?id:'';
   if(!item){tip.hidden=true;return;}
   const rank=ranks[id]||0,max=costs[id].length,cost=costs[id][rank];
   $('status').textContent=w(stage(id))+' · '+rank+'/'+max;$('name').textContent=title(id);
   $('effect').textContent=atlas.captions[keyFor(id)][lang+2];$('price').textContent=rank===max?w('all'):(cost>balance?w('insufficient')+' · ':w('buy')+' ')+cost+' '+w('sap');
   tip.hidden=false;item.setAttribute('aria-describedby','tip');
   const room=map.getBoundingClientRect(), node=item.getBoundingClientRect(), tw=tip.offsetWidth,th=tip.offsetHeight;
   const cx=(node.left+node.right)/2-room.left,cy=(node.top+node.bottom)/2-room.top,r=node.width*.5+12;
   const others=[...$('pieces').children,$('legend')].map(e=>e.getBoundingClientRect());
   const choices=[[cx+r,cy-th/2],[cx-r-tw,cy-th/2],[cx-tw/2,cy+r],[cx-tw/2,cy-r-th],
     [cx-r-tw*1.5,cy-th/2],[cx+r+tw*.5,cy-th/2],[cx-r-tw*1.5,cy-th*.35],[cx+r+tw*.5,cy-th*.35]];
   let best,lowest=Infinity;
   for(const [x0,y0] of choices){
     const x=Math.max(8,Math.min(room.width-tw-8,x0)),y=Math.max(8,Math.min(room.height-th-8,y0));
     let cost=Math.abs(x-x0)+Math.abs(y-y0);
     for(const b of others)cost+=Math.max(0,Math.min(x+tw,b.right-room.left)-Math.max(x,b.left-room.left))*Math.max(0,Math.min(y+th,b.bottom-room.top)-Math.max(y,b.top-room.top));
     if(cost<lowest){lowest=cost;best=[x,y];}
   }
   tip.style.left=best[0]+'px';tip.style.top=best[1]+'px';
 }
 function purchase(id){const rank=ranks[id]||0,price=costs[id][rank];if(price===undefined||price>balance||!unlocked(id))return;balance-=price;ranks[id]=rank+1;redraw();}
 function refund(id){if(!ranks.refund||id==='refund'||!ranks[id])return;balance+=costs[id][--ranks[id]];redraw();}
 function home(){zoom=1;center={x:455,y:460};}
 function reset(){ranks={damage:4,rate:2,workshop:1};balance=850;idOver='';home();redraw();}
 function zoomBy(factor,point){const old=zoom;zoom=Math.max(.45,Math.min(3,zoom*factor));if(point){const k=1-old/zoom;center.x+=(point.x-center.x)*k;center.y+=(point.y-center.y)*k;}frame();}
 map.addEventListener('wheel',e=>{e.preventDefault();const p=new DOMPoint(e.clientX,e.clientY).matrixTransform(map.getScreenCTM().inverse());zoomBy(e.deltaY<0?1.16:1/1.16,p);},{passive:false});
 map.addEventListener('pointerdown',e=>{blockClick=false;if(e.target.closest('.tier')||e.button>1)return;drag={x:e.clientX,y:e.clientY,cx:center.x,cy:center.y};map.setPointerCapture(e.pointerId);});
 map.addEventListener('pointermove',e=>{if(!drag)return;const k=view.width/map.clientWidth;center={x:drag.cx+(drag.x-e.clientX)*k,y:drag.cy+(drag.y-e.clientY)*k};blockClick=true;inspect('');frame();});
 map.addEventListener('lostpointercapture',()=>{drag=null;});
 $('minus').onclick=()=>zoomBy(1/1.2);$('plus').onclick=()=>zoomBy(1.2);$('fit').onclick=()=>{home();frame();};$('reset').onclick=reset;
 $('lang').onclick=()=>{lang=1-lang;redraw();};$('collection').onclick=()=>$('drawing').showModal();$('close').onclick=()=>$('drawing').close();
 window.addEventListener('resize',frame);document.addEventListener('keydown',e=>{if(e.key==='Home'){home();frame();}if(e.key==='Escape')inspect('');});
 if(new URLSearchParams(location.search).get('lang')==='en')lang=1;
 reset();
})();
