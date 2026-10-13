
/* ---------- rendering ---------- */
function btn(label,x,y,w,h,fn,o){o=o||{};const hov=G.mx>=x&&G.mx<=x+w&&G.my>=y&&G.my<=y+h;UI.push({x,y,w,h,fn});ctx.save();rr(x,y,w,h,4);ctx.fillStyle=hov||o.sel?'rgba(61,240,255,.16)':'rgba(10,16,40,.75)';ctx.fill();ctx.strokeStyle=hov||o.sel?C.cyan:'rgba(141,151,196,.5)';ctx.lineWidth=hov||o.sel?2:1;ctx.stroke();ctx.restore();txt(label,x+w/2,y+h/2+6,o.size||17,hov||o.sel?C.cyan:C.bone,'center',F_U,700,2);}
function renderWorld(showPlayer){
 const L=G.lvl,p=G.p,th=L.theme,cam=G.cam,t=G.t;
 const sx=(Math.random()-.5)*G.shake,sy=(Math.random()-.5)*G.shake;
 ctx.save();ctx.translate(sx,sy);
 drawBG(th,cam,t);drawGround(L,cam,th);
 if(L.forgeX)drawForge(L,cam,t);if(L.barrierX)drawBarrier(L,cam,t);drawPad(L,cam,t);
 if(!G.podBroken&&G.introT>0){const k=Math.pow(1-G.introT/2.6,2),py=lerp(-120,GY,k);drawFlame(L.startX-cam,py-100,t,1);drawPod(L.startX-cam,py,.12,false,t);}
 else if((G.mode==='story'&&G.world===0)||(G.mode==='endless'&&G.sector===0))drawPod(L.startX-cam-60,GY,-.18,true,t);
 for(const c of L.crystals)if(!c.got)drawCrystal(c,cam,t);for(const c of L.packs)if(!c.got)drawPack(c,cam,t);
 for(const e of L.enemies)if(!e.dead)drawVoidling(e,t,cam);
 for(const m of G.meteors)drawMeteor(m,cam);
 drawExtras(cam,t);
 if(showPlayer&&G.introT<=0){const blink=p.inv>0&&p.dashT<=0&&Math.floor(t*20)%2===0;if(!blink){const run=p.on?clamp(Math.abs(p.vx)/270,0,1):0;
  drawHero(p.x+14-cam,p.y+48,{s:1,face:p.face,t:p.anim,char:G.char,run,air:!p.on,sword:G.hasSword,atk:p.atkT>0?1-p.atkT/.28:-1});}}
 if(showPlayer&&G.introT<=0)drawShield();
 drawFx(cam);
 drawHole(G.hx,cam,t);
 ctx.restore();
 if(th===TH.nebula&&G.scene==='play'){const px=p.x+14-cam,g=ctx.createRadialGradient(px,p.y,90,px,p.y,330);g.addColorStop(0,'rgba(5,0,15,0)');g.addColorStop(1,'rgba(5,0,15,.93)');ctx.fillStyle=g;ctx.fillRect(0,0,W,H);}
 const d=p.x+14-(G.hx+170);if(d<450){const g=ctx.createLinearGradient(0,0,260,0);g.addColorStop(0,'rgba(255,60,20,'+(.4*(1-d/450)).toFixed(2)+')');g.addColorStop(1,'rgba(255,60,20,0)');ctx.fillStyle=g;ctx.fillRect(0,0,260,H);}
}
function renderPuzzle(){
 renderWorld(true);ctx.fillStyle='rgba(3,5,16,.82)';ctx.fillRect(0,0,W,H);
 const z=G.pz,{gx,gy,cs,cols,rows}=PZ,t=G.t;rr(34,56,892,444,10);ctx.fillStyle='rgba(13,20,51,.95)';ctx.fill();ctx.strokeStyle=C.cyan;ctx.lineWidth=1.5;ctx.stroke();
 if(z.type!=='mirror'){renderPuzzleAlt(z);return;}
 txt('ENERGY FORGE — REACTOR LINE',60,92,16,C.cyan,'left',F_D,700,2);
 ctx.fillStyle='rgba(255,255,255,.04)';ctx.fillRect(gx,gy,cols*cs,rows*cs);ctx.strokeStyle='rgba(141,151,196,.3)';ctx.lineWidth=1;
 for(let i=0;i<=cols;i++){ctx.beginPath();ctx.moveTo(gx+i*cs,gy);ctx.lineTo(gx+i*cs,gy+rows*cs);ctx.stroke();}for(let j=0;j<=rows;j++){ctx.beginPath();ctx.moveTo(gx,gy+j*cs);ctx.lineTo(gx+cols*cs,gy+j*cs);ctx.stroke();}
 const tr=pzTrace(z.m),col=z.solved?C.gold:C.cyan,cx=c=>gx+c*cs+cs/2,cy=r=>gy+r*cs+cs/2;
 ctx.save();ctx.beginPath();ctx.rect(gx,gy,cols*cs,rows*cs);ctx.clip();ctx.lineCap='round';ctx.lineJoin='round';
 ctx.strokeStyle=col;ctx.globalAlpha=.3;ctx.lineWidth=14;ctx.beginPath();tr.pts.forEach((q,i)=>i?ctx.lineTo(cx(q[0]),cy(q[1])):ctx.moveTo(cx(q[0]),cy(q[1])));ctx.stroke();ctx.globalAlpha=1;ctx.lineWidth=4;ctx.stroke();ctx.strokeStyle='#fff';ctx.lineWidth=1.5;ctx.stroke();ctx.restore();
 ctx.fillStyle=C.ember;ctx.beginPath();ctx.arc(cx(PZ.src[0]),cy(PZ.src[1]),14+Math.sin(t*6)*2,0,6.283);ctx.fill();txt('REACTOR',cx(0),cy(3)+34,10,C.ember,'center',F_U,700,1);
 ctx.save();ctx.translate(cx(PZ.tgt[0]),cy(PZ.tgt[1]));ctx.rotate(t);ctx.fillStyle=z.solved?C.gold:'#3a4378';ctx.beginPath();ctx.moveTo(0,-18);ctx.lineTo(18,0);ctx.lineTo(0,18);ctx.lineTo(-18,0);ctx.closePath();ctx.fill();ctx.restore();txt('CORE',cx(5),cy(4)-26,10,C.dim,'center',F_U,700,1);
 for(const k in z.m){const[c,r]=k.split(',').map(Number),x0=gx+c*cs,y0=gy+r*cs,m=z.m[k];ctx.strokeStyle=PZ.keys.includes(k)||true?'#c9d4ff':'#fff';ctx.lineWidth=7;ctx.lineCap='round';ctx.beginPath();if(m==='/'){ctx.moveTo(x0+14,y0+cs-14);ctx.lineTo(x0+cs-14,y0+14);}else{ctx.moveTo(x0+14,y0+14);ctx.lineTo(x0+cs-14,y0+cs-14);}ctx.stroke();
  ctx.strokeStyle='#5c6aa8';ctx.lineWidth=2;rr(x0+6,y0+6,cs-12,cs-12,8);ctx.stroke();
  if(z.hint===k){ctx.strokeStyle=C.gold;ctx.lineWidth=3;ctx.globalAlpha=.5+.5*Math.sin(t*9);rr(x0+2,y0+2,cs-4,cs-4,10);ctx.stroke();ctx.globalAlpha=1;}}
 const rx=560;txt('Rotate the mirrors so the reactor beam',rx,150,15,C.bone,'left',F_U,600);txt('reaches the forge core.',rx,172,15,C.bone,'left',F_U,600);
 txt('Click or tap a mirror to flip it.',rx,208,13,C.dim,'left',F_U,600);txt('Mistakes cost nothing. Take your time —',rx,230,13,C.dim,'left',F_U,600);txt('the Devourer waits while you think.',rx,250,13,C.dim,'left',F_U,600);
 if(z.solved)txt('FORGE ONLINE',rx,320,22,C.gold,'left',F_D,700,2);else{btn('SHOW HINT  (H)',rx,300,200,44,()=>pzHint());btn('CLOSE  (ESC)',rx,356,200,44,()=>{G.scene='play';});}
}
function renderTitle(){
 const t=G.t;drawBG(TH.moon,t*30,t);
 for(let i=0;i<4;i++){const rad=mod(t*60+i*90,360);ctx.strokeStyle='rgba(255,255,255,'+(.12*(1-rad/360)).toFixed(3)+')';ctx.lineWidth=2;ctx.beginPath();ctx.arc(700,260,rad,0,6.283);ctx.stroke();}
 drawHole(700+Math.sin(t*.4)*10,0,t);
 const g=ctx.createLinearGradient(0,0,W*.7,0);g.addColorStop(0,'rgba(5,7,26,.88)');g.addColorStop(1,'rgba(5,7,26,0)');ctx.fillStyle=g;ctx.fillRect(0,0,W,H);
 txt('EVENT',54,170,60,C.bone,'left',F_D,700,6);txt('HORIZON',54,236,60,C.cyan,'left',F_D,700,6);txt('LAST RUN TO EARTH',58,274,15,C.ember,'left',F_U,700,7);
 const sv=store('eh_save'),sw=sv&&sv.world>0?sv.world:0;
 const items=[['STORY RUN',()=>{G.nextMode='story';G.startWorld=0;G.scene='select';}],['INFINITE FRONTIER',()=>{G.nextMode='endless';G.scene='select';}]];
 if(sw)items.push(['CONTINUE · WORLD '+(sw+1),()=>{G.nextMode='story';G.startWorld=sw;G.scene='select';}]);
 G.menuN=items.length;
 items.forEach((it,i)=>btn((i+1)+'   '+it[0],58,306+i*54,300,44,()=>{SFX.click();it[1]();},{sel:G.menu===i}));
 const b=store('eh_best');if(b)txt('BEST  '+b.dist+' KM'+(b.sector?'  ·  SECTOR '+b.sector:''),58,470,13,C.dim,'left',F_U,700,2);
 txt('A black hole is eating the stars. Earth is the last way out.',58,505,13,C.dim,'left',F_U,600,1);
}
function renderSelect(){
 drawBG(TH.moon,G.t*20,G.t);ctx.fillStyle='rgba(5,7,26,.55)';ctx.fillRect(0,0,W,H);
 txt('CHOOSE YOUR SURVIVOR',480,70,24,C.bone,'center',F_D,700,3);txt('Both have the same abilities. Pick who you want to carry to Earth.',480,98,14,C.dim,'center',F_U,600,1);
 [['male','ARIN','Colony engineer'],['female','MIRA','Navigator']].forEach((c,i)=>{const x=140+i*390,sel=G.char===c[0];
  rr(x,125,290,330,10);ctx.fillStyle=sel?'rgba(61,240,255,.1)':'rgba(13,20,51,.7)';ctx.fill();ctx.strokeStyle=sel?C.cyan:'rgba(141,151,196,.4)';ctx.lineWidth=sel?2.5:1;ctx.stroke();UI.push({x,y:125,w:290,h:330,fn:()=>{G.char=c[0];SFX.click();}});
  drawHero(x+145,385,{s:3.3,face:1,t:G.t,char:c[0],run:0,sword:true,atk:-1});txt(c[1],x+145,428,20,sel?C.cyan:C.bone,'center',F_D,700,3);txt(c[2].toUpperCase(),x+145,447,11,C.dim,'center',F_U,700,3);});
 btn('LAUNCH  ↵',360,478,240,46,()=>{if(G.nextMode==='endless')startEndless();else startStory(G.startWorld||0);},{sel:true});
}
function renderDead(){renderWorld(false);const a=clamp(G.deadT/.6,0,1);ctx.fillStyle='rgba(3,3,12,'+(.78*a)+')';ctx.fillRect(0,0,W,H);ctx.globalAlpha=a;
 txt(G.deadWhy,480,240,30,C.ember,'center',F_D,700,3);txt('The Devourer keeps what it takes. You keep your progress.',480,278,15,C.dim,'center',F_U,600,1);
 if(G.deadT>.8)btn('RETRY FROM CHECKPOINT  ↵',300,310,360,48,retry,{sel:true});ctx.globalAlpha=1;}
function retry(){SFX.click();respawnCP();G.fade=.8;}
function renderLaunch(){
 const L=G.lvl,t=G.t,lt=G.lt;renderWorld(false);const x=L.padX-G.cam,y=GY-8-lt*lt*90;
 drawFlame(x,y,t,1.2);drawPod(x,y,0,false,t);
 const a=clamp((lt-2.3)/1.3,0,1);ctx.fillStyle='rgba(255,255,255,'+a+')';ctx.fillRect(0,0,W,H);
}
function renderEnd(){
 const t=G.t;drawBG(TH.earth,t*10,t);const px=700,py=250;
 const g=ctx.createRadialGradient(px-40,py-40,10,px,py,150);g.addColorStop(0,'#bfe8ff');g.addColorStop(.5,'#2a6fc4');g.addColorStop(1,'#06142e');ctx.fillStyle=g;ctx.beginPath();ctx.arc(px,py,150,0,6.283);ctx.fill();
 ctx.save();ctx.beginPath();ctx.arc(px,py,150,0,6.283);ctx.clip();for(let i=0;i<7;i++){ctx.fillStyle=i%2?'rgba(93,255,176,.28)':'rgba(255,255,255,.18)';ctx.fillRect(px-150,py-140+i*40+Math.sin(t*.3+i)*4,300,12);}
 const sh=ctx.createLinearGradient(px-150,0,px+150,0);sh.addColorStop(0,'rgba(0,0,0,0)');sh.addColorStop(1,'rgba(0,0,0,.75)');ctx.fillStyle=sh;ctx.fillRect(px-150,py-150,300,300);ctx.restore();
 ctx.fillStyle='#cfd3e6';ctx.beginPath();ctx.arc(px-230,py-120,16,0,6.283);ctx.fill();
 const gl=ctx.createLinearGradient(0,0,W*.62,0);gl.addColorStop(0,'rgba(5,7,26,.85)');gl.addColorStop(1,'rgba(5,7,26,0)');ctx.fillStyle=gl;ctx.fillRect(0,0,W,H);
 txt('CAMPAIGN COMPLETE',54,110,13,C.ember,'left',F_U,700,5);txt('EARTH',54,170,48,C.bone,'left',F_D,700,4);
 txt('You reached Earth. The Devourer was never chasing you.',54,215,16,C.bone,'left',F_U,600);txt('It was following the signal in your pod.',54,239,16,C.bone,'left',F_U,600);
 txt('Beyond the galaxy, something answers.',54,263,16,C.cyan,'left',F_U,700);
 txt('CRYSTALS  '+G.crystals+'     VOIDLINGS  '+G.kills+'     TIME  '+Math.floor(G.time)+'s',54,310,14,C.dim,'left',F_U,700,2);
 btn('INFINITE FRONTIER',54,345,300,46,startEndless,{sel:true});btn('PLAY AGAIN',54,401,300,46,startStory);btn('MENU',54,457,300,46,()=>{G.scene='title';});
}
function render(){
 ctx.setTransform(cv.width/W,0,0,cv.height/H,0,0);ctx.clearRect(0,0,W,H);UI=[];
 switch(G.scene){case'title':renderTitle();break;case'select':renderSelect();break;case'play':renderWorld(true);drawHUD();drawHUD2();break;case'puzzle':renderPuzzle();break;case'dead':renderDead();break;case'launch':renderLaunch();break;case'end':renderEnd();break;}
 if(G.fade>0){ctx.fillStyle='rgba(0,0,0,'+clamp(G.fade,0,1)+')';ctx.fillRect(0,0,W,H);}
 if(G.muted)txt('MUTED',W-14,H-10,10,C.dim,'right',F_U,700,2);
}

/* ---------- loop & pointer ---------- */
function update(dt){
 if(pressed('mute')){muted=!muted;G.muted=muted;if(master)master.gain.value=muted?0:.55;}
 switch(G.scene){
  case'title':{const n=G.menuN||2;if(pressed('down'))G.menu=Math.min(n-1,G.menu+1);if(pressed('up'))G.menu=Math.max(0,G.menu-1);if(pressed('n1'))G.menu=0;if(pressed('n2'))G.menu=1;if(pressed('n3')&&n>2)G.menu=2;
   if(pressed('enter')||pressed('n1')||pressed('n2')||(pressed('n3')&&n>2)){const sv=store('eh_save');G.nextMode=G.menu===1?'endless':'story';G.startWorld=G.menu===2&&sv?sv.world:0;G.scene='select';SFX.click();}break;}
  case'select':if(pressed('left'))G.char='male';if(pressed('right'))G.char='female';if(pressed('esc')){G.scene='title';}
   if(pressed('enter')){if(G.nextMode==='endless')startEndless();else startStory(G.startWorld||0);}break;
  case'play':updatePlay(dt);break;
  case'puzzle':updatePuzzle(dt);break;
  case'dead':G.deadT+=dt;G.shake=Math.max(0,G.shake-dt*30);updFx(dt);if(G.deadT>.8&&(pressed('enter')||pressed('retry')))retry();break;
  case'launch':G.lt+=dt;G.shake=Math.max(4,G.shake);for(let i=0;i<3;i++)spawn(G.lvl.padX+Math.random()*30-15,GY-8-G.lt*G.lt*90+10,Math.random()*80-40,120+Math.random()*100,.6,5,'#ff9a3c',0,true);updFx(dt);if(G.lt>4.1){if(G.lvl.final){G.scene='end';G.fade=1;}else nextWorld();}break;
  case'end':G.fade=Math.max(0,G.fade-dt);break;
 }
}
let last=0;
function frame(ts){requestAnimationFrame(frame);const dt=Math.min(.033,(ts-last)/1000||0);last=ts;G.t+=dt;update(dt);render();pq={};}
function toLogical(e){const r=cv.getBoundingClientRect();return[(e.clientX-r.left)*W/r.width,(e.clientY-r.top)*H/r.height];}
cv.addEventListener('pointermove',e=>{const q=toLogical(e);G.mx=q[0];G.my=q[1];});
cv.addEventListener('pointerdown',e=>{audioInit();cv.focus();const q=toLogical(e);G.mx=q[0];G.my=q[1];
 if(G.scene==='puzzle'&&G.pz&&!UI.some(u=>q[0]>=u.x&&q[0]<=u.x+u.w&&q[1]>=u.y&&q[1]<=u.y+u.h)){pzClick(q[0],q[1]);return;}
 for(let i=UI.length-1;i>=0;i--){const u=UI[i];if(q[0]>=u.x&&q[0]<=u.x+u.w&&q[1]>=u.y&&q[1]<=u.y+u.h){u.fn();return;}}
 if(G.scene==='dead'&&G.deadT>.8)retry();});
if(window.ResizeObserver)new ResizeObserver(fit).observe(cv);
document.fonts&&document.fonts.load&&['700 20px Syncopate','600 14px "Chakra Petch"','700 14px "Chakra Petch"'].forEach(f=>document.fonts.load(f).catch(()=>{}));
requestAnimationFrame(frame);
})();
</script>
