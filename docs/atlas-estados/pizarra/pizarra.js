(() => {
  const get=id=>document.getElementById(id), map=get('map'), tip=get('tip');
  const ns='http://www.w3.org/2000/svg', ids=Object.keys(atlas.vertices);
  const costs={}, depth={}, elements=new Map();
  let ranks={}, sap=850, language=new URLSearchParams(location.search).get('lang')==='en'?'en':'es';
  let zoom=1, pan={x:0,y:0}, center, span, scale, positions={}, active='', drag=null;
  const tr=(es,en)=>language==='es'?es:en;
  const count=id=>ranks[id]||0;
  const kind=id=>id==='wheel_step_05'?'sentinel':id==='wheel_step_11'?'seeds':id.replace(/_step_\d+$/,'_step');
  function name(id){return atlas.captions[kind(id)][language==='es'?0:1]+(kind(id).endsWith('_step')?' '+Number(id.split('_').at(-1)):'');}
  for(const id of ids){
    const parent=atlas.vertices[id][2];depth[id]=parent?depth[parent]+1:0;
    costs[id]=atlas.costs[id]||[Math.round(depth[id]**2*4.75)+2];
  }
  const max=Object.values(costs).reduce((sum,c)=>sum+c.length,0);
  const unlocked=id=>(!atlas.vertices[id][2]||count(atlas.vertices[id][2])>0)&&(id!=='pet'||count('damage')>=10);
  const canRefund=id=>Boolean(count('refund')&&id!=='refund'&&count(id));
  function visible(){
    const shown=new Set(ids.filter(unlocked));
    for(const id of ids)if(count(id))for(let p=id;p;p=atlas.vertices[p][2])shown.add(p);
    return ids.filter(id=>shown.has(id));
  }
  const state=id=>count(id)===costs[id].length?'full':count(id)?'part':'open';
  const description=id=>({open:tr('Sin comprar','Unpurchased'),part:tr('En progreso','In progress'),full:tr('Completa','Complete')})[state(id)];
  function glyph(id){
    const type=state(id), rank=count(id), limit=costs[id].length, shape=id==='damage'&&rank>=9?'multishot':kind(id);
    const ink=type==='full'?'#233636':type==='part'?'#f0d29a':'#e8e7d8';
    const lines=type==='open'?'<circle r="25" fill="#2c4142" stroke="#d8ded0" stroke-width="1.6" stroke-dasharray="4.4 2.5"/>':
      type==='full'?'<circle r="25" fill="#ece9d5" stroke="#e9e3c8" stroke-width="1.8"/><circle r="22.2" fill="none" stroke="#344d4e" stroke-width="1.4"/>':
      '<circle r="25" fill="#273c3d" stroke="#b3bca9" stroke-width="1.2"/>';
    let ticks='';
    if(type==='part')for(let i=0;i<limit;i++){
      const gap=Math.min(13,75/limit), a=360*i/limit+gap/2, b=360*(i+1)/limit-gap/2;
      const point=d=>[Math.sin(d*Math.PI/180)*23.1,-Math.cos(d*Math.PI/180)*23.1].join(' ');
      ticks+='<path d="M'+point(a)+' A23.1 23.1 0 '+(b-a>180?1:0)+' 1 '+point(b)+'" fill="none" stroke="'+(i<rank?'#f0d09b':'#82968d')+'" stroke-width="'+(i<rank?'5.7':'1.3')+'" stroke-linecap="butt"/>';
    }
    const stamp=type==='full'?'<path d="m12 15 4 4 8-9" fill="none" stroke="#233636" stroke-width="5" stroke-linecap="round"/><path d="m12 15 4 4 8-9" fill="none" stroke="#fff8df" stroke-width="2.15" stroke-linecap="round"/>':
      type==='part'?'<rect x="9" y="14" width="27" height="14" rx="2.5" fill="#efd09d"/><text class="digit" x="22.5" y="24.4" text-anchor="middle">'+rank+'/'+limit+'</text>':'';
    return '<circle class="focus" r="29" stroke="#f1d99f" stroke-width="1.5" fill="none"/>'+lines+ticks+'<g transform="translate(-14 -14) scale(1.166)" stroke-linejoin="round" stroke-linecap="round"><path d="'+atlas.strokes[shape]+'" fill="none" stroke="'+ink+'" stroke-width="1.85"/><path d="'+(atlas.fills[shape]||'')+'" fill="'+ink+'"/></g>'+stamp;
  }
  function makeNode(id){
    const n=document.createElementNS(ns,'g');n.classList.add('node');n.dataset.upgrade=id;
    n.setAttribute('role','button');n.setAttribute('tabindex','0');
    n.onpointerenter=()=>{if(!drag)inspect(id);};n.onpointerleave=()=>{if(!n.matches(':focus-visible'))inspect('');};
    n.onfocus=()=>inspect(id);n.onblur=()=>{if(active===id)inspect('');};
    n.onclick=()=>buy(id);n.oncontextmenu=e=>{e.preventDefault();refund(id);};
    n.onkeydown=e=>{
      if(['Enter',' '].includes(e.key)){e.preventDefault();buy(id);}
      if(['Delete','Backspace'].includes(e.key)){e.preventDefault();refund(id);}
    };
    get('nodes').append(n);elements.set(id,n);return n;
  }
  function inspect(id){
    if(elements.has(active))elements.get(active).removeAttribute('aria-describedby');
    active=id;const p=positions[id];tip.hidden=!p;if(!p)return;
    const price=costs[id][count(id)];
    get('status').textContent=description(id)+' · '+count(id)+'/'+costs[id].length;
    get('name').textContent=name(id);get('effect').textContent=atlas.captions[kind(id)][language==='es'?2:3];
    get('cost').textContent=price===undefined?tr('Todos los niveles comprados','All levels purchased'):
      (price>sap?tr('Necesitás ','Requires '):tr('Clic o Enter · Comprar por ','Click or Enter · Buy for '))+price+tr(' de savia',' sap');
    if(canRefund(id))get('cost').textContent+=tr(' · Clic derecho o Supr para devolver',' · Right click or Delete to refund');
    elements.get(id).setAttribute('aria-describedby','tip');
    const ww=tip.offsetWidth,hh=tip.offsetHeight,gap=p.r+13,margin=6,w=map.clientWidth,h=map.clientHeight;
    const covers=(l,t)=>Object.values(positions).reduce((v,q)=>v+(q.x+q.r>l&&q.x-q.r<l+ww&&q.y+q.r>t&&q.y-q.r<t+hh?150:0),0);
    let score=Infinity, at;const legend=document.querySelector('.key'), lh=legend.offsetTop+legend.offsetHeight,lw=legend.offsetWidth;
    for(const [ox,oy] of [[p.x+gap,p.y-hh*.5],[p.x-gap-ww,p.y-hh*.5],[p.x-ww*.5,p.y-gap-hh],[p.x-ww*.5,p.y+gap]]){
      const x=Math.max(margin,Math.min(w-ww-margin,ox)),y=Math.max(margin,Math.min(h-hh-margin,oy));
      const penalty=covers(x,y)+Math.abs(ox-x)+Math.abs(oy-y)+(x<lw&&y<lh?120:0);if(penalty<score){score=penalty;at=[x,y];}
    }
    tip.style.left=at[0]+'px';tip.style.top=at[1]+'px';
  }
  function frame(){
    const pts=visible().map(id=>atlas.vertices[id]);
    const xs=pts.map(p=>p[0]),ys=pts.map(p=>p[1]),x0=Math.min(...xs),x1=Math.max(...xs),y0=Math.min(...ys),y1=Math.max(...ys);
    center=[(x0+x1)/2,(y0+y1)/2];span=[Math.max(135,x1-x0+24),Math.max(137,y1-y0+24)];pan={x:0,y:0};zoom=1;
  }
  function draw(){
    const w=map.clientWidth,h=map.clientHeight,shown=visible();positions={};
    scale=Math.min(w*.7/span[0],h*.92/span[1])*zoom;
    const radius=Math.max(10,Math.min(37,7.7*scale)),links=[];
    for(const [id,n] of elements)if(!shown.includes(id)){n.remove();elements.delete(id);}
    for(const id of shown){
      const [vx,vy,parent]=atlas.vertices[id], x=(vx-center[0])*scale+w*.60+pan.x,y=(vy-center[1])*scale+h*.50+pan.y;
      positions[id]={x,y,r:radius};const n=elements.get(id)||makeNode(id);
      n.setAttribute('transform','translate('+x+' '+y+') scale('+radius/25+')');
      n.dataset.state=state(id);n.innerHTML=glyph(id);
      n.setAttribute('aria-label',name(id)+', '+description(id)+', '+count(id)+'/'+costs[id].length);
      const canBuy=unlocked(id)&&state(id)!=='full'&&costs[id][count(id)]<=sap;
      n.setAttribute('aria-disabled',String(!canBuy&&!canRefund(id)));
      if(parent&&positions[parent]){
        const p=positions[parent], path='M'+p.x+' '+p.y+'L'+x+' '+y;
        links.push('<path class="edge '+(count(id)?'':'empty')+'" d="'+path+'" stroke-width="'+(count(id)?2.5:1.6)+'"/>');
        if(count(id))links.push('<path class="shadowline" d="'+path+'" transform="translate(1.6 1.6)" stroke-width=".9"/>');
      }
    }
    get('edges').innerHTML=links.join('');
    document.documentElement.lang=language;for(const el of document.querySelectorAll('[data-es]'))el.textContent=el.dataset[language];
    map.setAttribute('aria-label',tr('Mapa de mejoras','Upgrade map'));
    get('lang').textContent=tr('English','Español');get('lang').lang=tr('en','es');
    get('wallet').textContent=sap.toLocaleString(tr('es-AR','en-US'));
    get('count').textContent=Object.values(ranks).reduce((a,b)=>a+b,0)+' / '+max+' '+tr('niveles comprados','levels purchased');
    get('fit').textContent=Math.round(zoom*100)+' %';
    for(const [id,label] of [['fit',tr('Encuadrar mapa','Fit map')],['less',tr('Alejar','Zoom out')],['more',tr('Acercar','Zoom in')]]){
      get(id).setAttribute('aria-label',label);get(id).title=label;
    }
    inspect(positions[active]?active:'');
  }
  function buy(id){const r=count(id),price=costs[id][r];if(unlocked(id)&&price!==undefined&&price<=sap){ranks[id]=r+1;sap-=price;draw();}}
  function refund(id){if(canRefund(id)){sap+=costs[id][--ranks[id]];draw();}}
  function reset(){ranks={damage:4,rate:2,workshop:1};sap=850;active='';frame();draw();}
  function magnify(factor,point){
    const previous=zoom;zoom=Math.max(.5,Math.min(3,zoom*factor));
    if(point){const k=zoom/previous;pan.x=point.x-(point.x-pan.x)*k;pan.y=point.y-(point.y-pan.y)*k;}
    draw();
  }
  map.onwheel=e=>{e.preventDefault();const r=map.getBoundingClientRect();magnify(e.deltaY<0?1.15:1/1.15,{x:e.clientX-r.left-r.width*.60,y:e.clientY-r.top-r.height*.50});};
  map.onpointerdown=e=>{if(e.button!==0||e.target.closest('.node'))return;drag=[e.clientX-pan.x,e.clientY-pan.y];map.setPointerCapture(e.pointerId);map.classList.add('drag');inspect('');};
  map.onpointermove=e=>{if(drag){pan={x:e.clientX-drag[0],y:e.clientY-drag[1]};draw();}};
  map.onlostpointercapture=()=>{drag=null;map.classList.remove('drag');};
  get('lang').onclick=()=>{language=tr('en','es');draw();};get('reset').onclick=reset;
  get('fit').onclick=()=>{frame();draw();};get('less').onclick=()=>magnify(1/1.2);get('more').onclick=()=>magnify(1.2);
  window.addEventListener('resize',draw);reset();
})();
