
/* ---------- drawing for guardians, hazards, weapons and the new puzzles ---------- */
function drawBoss(B,cam,t){
 if(B.dead&&B.dying<=0)return;const x=B.x-cam,y=B.y,hit=B.hitT>0,th=G.lvl.theme;ctx.globalAlpha=B.dead?clamp(B.dying/1.6,0,1):1;
 const gl=ctx.createRadialGradient(x,y,20,x,y,150);gl.addColorStop(0,th.rim+'88');gl.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=gl;ctx.fillRect(x-160,y-160,320,320);
 ctx.save();ctx.translate(x,y);
 for(let i=0;i<3;i++){ctx.save();ctx.rotate(t*(i%2?-.7:.9)+i);ctx.strokeStyle=hit?'#fff':th.rim;ctx.lineWidth=5-i;ctx.beginPath();ctx.ellipse(0,0,58+i*14,22+i*10,0,.3,5.9);ctx.stroke();ctx.restore();}
 const g=ctx.createRadialGradient(-8,-10,4,0,0,40);g.addColorStop(0,hit?'#fff':'#ffe9c2');g.addColorStop(.5,hit?'#fff':th.rim);g.addColorStop(1,'#120a30');ctx.fillStyle=g;ctx.beginPath();ctx.arc(0,0,40,0,6.283);ctx.fill();
 const dx=clamp((G.p.x-B.x)/60,-1,1)*8;ctx.fillStyle='#120a30';ctx.beginPath();ctx.ellipse(dx,0,15,22,0,0,6.283);ctx.fill();ctx.fillStyle=C.ember;ctx.beginPath();ctx.ellipse(dx,0,6,12,0,0,6.283);ctx.fill();
 ctx.restore();ctx.globalAlpha=1;
}
function drawExtras(cam,t){
 const L=G.lvl;
 if(L.vents)for(const v of L.vents){const x=v.x-cam;if(x<-60||x>W+60)continue;ctx.fillStyle='#120a07';rr(x-22,GY-4,44,6,2);ctx.fill();
  if(v.state>=1){ctx.fillStyle=v.state===1?'rgba(255,122,46,.35)':'rgba(255,122,46,.9)';ctx.fillRect(x-18,GY-4,36,3);}
  if(v.state===2){const g=ctx.createLinearGradient(0,GY,0,GY-170);g.addColorStop(0,'rgba(255,255,255,.95)');g.addColorStop(.3,'rgba(255,190,60,.85)');g.addColorStop(1,'rgba(255,60,20,0)');ctx.fillStyle=g;ctx.beginPath();ctx.moveTo(x-20,GY);ctx.quadraticCurveTo(x-30+Math.sin(t*30)*4,GY-90,x-8,GY-170);ctx.lineTo(x+8,GY-170);ctx.quadraticCurveTo(x+30,GY-90,x+20,GY);ctx.closePath();ctx.fill();}}
 if(L.logs)for(const g of L.logs){if(g.got)continue;const x=g.x-cam,y=g.y+Math.sin(t*2+g.x)*3;ctx.fillStyle='rgba(61,240,255,.25)';ctx.beginPath();ctx.arc(x,y,17,0,6.283);ctx.fill();rr(x-9,y-11,18,22,3);ctx.fillStyle='#d8f4ff';ctx.fill();ctx.fillStyle='#16306a';ctx.fillRect(x-5,y-6,10,2);ctx.fillRect(x-5,y-1,10,2);ctx.fillRect(x-5,y+4,6,2);}
 if(G.boss)drawBoss(G.boss,cam,t);
 for(const q of G.ep){const x=q.x-cam;ctx.fillStyle='rgba(255,122,46,.4)';ctx.beginPath();ctx.arc(x,q.y,17,0,6.283);ctx.fill();ctx.fillStyle='#ffd9a8';ctx.beginPath();ctx.arc(x,q.y,8,0,6.283);ctx.fill();}
 for(const b of G.bolts){const x=b.x-cam;if(b.lance){ctx.fillStyle='rgba(197,139,255,.4)';ctx.beginPath();ctx.arc(x,b.y,30,0,6.283);ctx.fill();ctx.strokeStyle='#e6ccff';ctx.lineWidth=4;ctx.beginPath();ctx.arc(x,b.y,18,0,6.283);ctx.stroke();}else{ctx.fillStyle='rgba(61,240,255,.35)';ctx.beginPath();ctx.arc(x,b.y,10,0,6.283);ctx.fill();ctx.fillStyle='#fff';ctx.beginPath();ctx.arc(x,b.y,4.5,0,6.283);ctx.fill();}}
}
function drawShield(){if(G.shT<=0)return;const p=G.p,x=p.x+14-G.cam,y=p.y+26,a=clamp(G.shT/.4,0,1);ctx.globalAlpha=a;const g=ctx.createRadialGradient(x,y,18,x,y,46);g.addColorStop(0,'rgba(61,240,255,0)');g.addColorStop(1,'rgba(61,240,255,.45)');ctx.fillStyle=g;ctx.beginPath();ctx.arc(x,y,46,0,6.283);ctx.fill();ctx.strokeStyle=C.cyan;ctx.lineWidth=2.5;ctx.stroke();ctx.globalAlpha=1;}
function drawHUD2(){
 const p=G.p,items=[['J','SWORD',G.hasSword],['K','BLASTER',G.hasBlaster],['Q','SHIELD',G.hasShield],['HOLD K','LANCE',G.hasLance]];let x=20;
 items.forEach(it=>{if(!it[2])return;const w=100;rr(x,H-50,w,26,5);ctx.fillStyle='rgba(13,20,51,.8)';ctx.fill();ctx.strokeStyle='rgba(61,240,255,.5)';ctx.lineWidth=1;ctx.stroke();
  if(it[1]==='SHIELD'&&G.shCd>0){ctx.fillStyle='rgba(255,255,255,.18)';ctx.fillRect(x,H-50,w*clamp(G.shCd/6,0,1),26);}
  txt(it[1],x+8,H-32,11,C.bone,'left',F_U,700,1);txt(it[0],x+w-8,H-32,10,C.cyan,'right',F_U,700,1);x+=w+6;});
 if(G.chg>.25&&G.hasLance){const bx=p.x+14-G.cam-24;ctx.fillStyle='rgba(255,255,255,.15)';rr(bx,p.y-18,48,6,3);ctx.fill();ctx.fillStyle=G.chg>=.7?'#c58bff':C.cyan;rr(bx,p.y-18,48*clamp(G.chg/.7,0,1),6,3);ctx.fill();}
 const B=G.boss;if(B&&!B.dead&&Math.abs(p.x-B.x)<1000){txt(B.name,480,76,12,C.ember,'center',F_U,700,3);ctx.fillStyle='rgba(255,255,255,.12)';rr(280,82,400,9,4);ctx.fill();ctx.fillStyle=C.ember;rr(280,82,400*clamp(B.hp/B.max,0,1),9,4);ctx.fill();}
}
function drawMinimap(){
 const L=G.lvl,p=G.p;
 const mx=W/2-180,mw=360,my=H-14,mh=5,r=5;
 // Background bar
 ctx.fillStyle='rgba(3,5,22,.75)';rr(mx-2,my-2,mw+4,mh+4,3);ctx.fill();
 ctx.fillStyle='rgba(255,255,255,.07)';rr(mx,my,mw,mh,2);ctx.fill();
 const sc=v=>mx+clamp(v/L.L,0,1)*mw;
 // Devourer zone (red fill from left)
 const devR=clamp((G.hx+340)/L.L,0,1);
 ctx.fillStyle='rgba(255,60,20,.35)';rr(mx,my,devR*mw,mh,2);ctx.fill();
 // Forge dot (cyan)
 if(L.forgeX&&!G.forgeDone){ctx.fillStyle=C.cyan;ctx.beginPath();ctx.arc(sc(L.forgeX),my+mh/2,r*.9,0,6.283);ctx.fill();}
 // Pad dot (gold)
 ctx.fillStyle=C.gold;ctx.beginPath();ctx.arc(sc(L.padX),my+mh/2,r*.9,0,6.283);ctx.fill();
 // Player dot (white)
 const px=sc(p.x+14);ctx.fillStyle='#fff';ctx.beginPath();ctx.arc(px,my+mh/2,r,0,6.283);ctx.fill();
 // Devourer edge tick
 const dx=sc(G.hx+170);ctx.strokeStyle='#ff4a2a';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(dx,my-2);ctx.lineTo(dx,my+mh+2);ctx.stroke();
}
const SYMCOL=['#3df0ff','#ff5fa8','#ffd166','#5dffb0'];
function drawSym(s,x,y,r,col){ctx.fillStyle=col;ctx.beginPath();
 if(s===0)ctx.arc(x,y,r,0,6.283);else if(s===1){ctx.moveTo(x,y-r);ctx.lineTo(x+r,y+r*.8);ctx.lineTo(x-r,y+r*.8);ctx.closePath();}
 else if(s===2)ctx.rect(x-r*.85,y-r*.85,r*1.7,r*1.7);else{ctx.moveTo(x,y-r*1.1);ctx.lineTo(x+r,y);ctx.lineTo(x,y+r*1.1);ctx.lineTo(x-r,y);ctx.closePath();}ctx.fill();}
function renderPuzzleAlt(z){
 const t=G.t,rx=560;
 if(z.type==='symbol'){
  txt('ARMORY LOCK — DECODE THE SIGNAL',60,92,16,C.cyan,'left',F_D,700,2);
  const ri=Math.min(z.round,1),R=SYM_ROUNDS[ri],n=R.seq.length;txt('SIGNAL '+(ri+1)+' / 2',60,140,13,C.dim,'left',F_U,700,3);
  for(let i=0;i<=n;i++){const x=70+i*60,y=200;rr(x,y,52,52,8);ctx.fillStyle='rgba(255,255,255,.05)';ctx.fill();ctx.strokeStyle=i===n?C.gold:'rgba(141,151,196,.4)';ctx.lineWidth=i===n?2.5:1;ctx.stroke();
   if(i<n)drawSym(R.seq[i],x+26,y+26,15,SYMCOL[R.seq[i]]);else txt('?',x+26,y+38,30,C.gold,'center',F_D,700);}
  txt('WHICH SYMBOL COMES NEXT?',70,300,12,C.dim,'left',F_U,700,3);
  z.order[ri].forEach((s,i)=>{const x=70+i*110,y=320,corr=s===R.ans,hl=z.hint&&corr;rr(x,y,90,90,10);ctx.fillStyle='rgba(61,240,255,.08)';ctx.fill();ctx.strokeStyle=hl?C.gold:'rgba(141,151,196,.6)';ctx.lineWidth=hl?3:1.5;ctx.stroke();drawSym(s,x+45,y+45,22,SYMCOL[s]);});
  txt('Find the rule, then pick the symbol',rx,150,15,C.bone,'left',F_U,600);txt('that completes the sequence.',rx,172,15,C.bone,'left',F_U,600);
  txt('Two signals to decode. A wrong pick',rx,208,13,C.dim,'left',F_U,600);txt('costs nothing. Try again.',rx,228,13,C.dim,'left',F_U,600);
 }else{
  txt('ORBITAL LOCK — WAKE THE PLANETS',60,92,16,C.cyan,'left',F_D,700,2);
  ctx.fillStyle=C.gold;ctx.beginPath();ctx.arc(SEQX,SEQY,14,0,6.283);ctx.fill();
  SEQ_PL.forEach(q=>{ctx.strokeStyle='rgba(141,151,196,.25)';ctx.lineWidth=1;ctx.beginPath();ctx.ellipse(SEQX,SEQY,q.r,q.r*.62,0,0,6.283);ctx.stroke();});
  SEQ_PL.forEach((q,i)=>{const pp=seqPos(i),lit=z.lit.includes(i),nxt=z.hint&&z.order[z.next]===i;
   if(lit||nxt){ctx.fillStyle=lit?'rgba(255,209,102,.35)':'rgba(255,255,255,.25)';ctx.beginPath();ctx.arc(pp[0],pp[1],q.sz+12+(nxt?Math.sin(t*9)*3:0),0,6.283);ctx.fill();}
   ctx.fillStyle=q.col;ctx.beginPath();ctx.arc(pp[0],pp[1],q.sz,0,6.283);ctx.fill();if(lit)txt(String(z.lit.indexOf(i)+1),pp[0],pp[1]+5,13,'#1a1030','center',F_U,700);});
  const inn=z.order[0]===0;txt(inn?'Wake the planets by orbit,':'Wake the planets by orbit,',rx,150,15,C.bone,'left',F_U,600);txt(inn?'starting with the innermost.':'starting with the outermost.',rx,172,15,C.bone,'left',F_U,600);
  txt('Click each planet as it moves past.',rx,208,13,C.dim,'left',F_U,600);txt('A wrong order resets the chain.',rx,228,13,C.dim,'left',F_U,600);
 }
 if(z.err>0){ctx.fillStyle='rgba(255,60,40,'+(z.err*.3)+')';ctx.fillRect(34,56,892,444);}
 if(z.solved)txt('LOCK OPEN',rx,320,22,C.gold,'left',F_D,700,2);else{btn('SHOW HINT  (H)',rx,300,200,44,()=>pzHint());btn('CLOSE  (ESC)',rx,356,200,44,()=>{G.scene='play';});}
}
