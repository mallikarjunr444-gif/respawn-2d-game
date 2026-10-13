
/* ---------- characters & objects ---------- */
function drawHero(x,y,o){
 const s=o.s||1,f=o.face||1,t=o.t||0,fem=o.char==='female',run=o.run||0,air=!!o.air;
 const suit=fem?'#e4dcff':'#d4e8ff',dark=fem?'#2a1f55':'#16264f',acc=fem?C.pink:C.cyan,ph=t*13;
 ctx.save();ctx.translate(x,y);ctx.scale(s*f,s);ctx.lineCap='round';ctx.lineJoin='round';
 const leg=(k,col)=>{let fx,fy;if(air){fx=k*5+3;fy=-10-(k>0?5:0);}else{const a=ph+(k>0?0:Math.PI);fx=Math.sin(a)*11*run;fy=-Math.max(0,Math.cos(a))*8*run-3;}
  ctx.strokeStyle=col;ctx.lineWidth=8;ctx.beginPath();ctx.moveTo(k*3,-22);ctx.lineTo(fx+k*2,fy-4);ctx.stroke();ctx.fillStyle=acc;rr(fx+k*2-5,fy-5,12,6,2);ctx.fill();};
 leg(-1,dark);
 ctx.strokeStyle=dark;ctx.lineWidth=6;ctx.beginPath();ctx.moveTo(0,-38);ctx.lineTo(-Math.sin(ph)*9*run-3,-27);ctx.stroke();
 ctx.fillStyle=dark;rr(-17,-46,8,22,3);ctx.fill();
 if(o.sword&&o.atk<0){ctx.strokeStyle=C.cyan;ctx.lineWidth=3;ctx.beginPath();ctx.moveTo(-12,-40);ctx.lineTo(-20,-70);ctx.stroke();}
 ctx.fillStyle=suit;rr(-10,-48,21,28,7);ctx.fill();ctx.fillStyle=acc;rr(-10,-30,21,5,2);ctx.fill();ctx.beginPath();ctx.arc(4,-40,2.5,0,6.283);ctx.fill();
 if(!fem){ctx.fillStyle=suit;rr(-12,-50,10,6,3);ctx.fill();}
 leg(1,'#b8c4ee');
 ctx.fillStyle=suit;ctx.beginPath();ctx.arc(2,-58,12,0,6.283);ctx.fill();ctx.strokeStyle=dark;ctx.lineWidth=1.5;ctx.stroke();
 if(fem){ctx.strokeStyle='#7a3fd0';ctx.lineWidth=6;ctx.beginPath();ctx.moveTo(-8,-62);ctx.bezierCurveTo(-18,-66,-24,-54+Math.sin(t*7)*3,-20,-44+Math.sin(t*7+1)*4);ctx.stroke();}
 else{ctx.strokeStyle=dark;ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(-4,-69);ctx.lineTo(-8,-78);ctx.stroke();ctx.fillStyle=C.ember;ctx.beginPath();ctx.arc(-8,-78,2,0,6.283);ctx.fill();}
 const vg=ctx.createLinearGradient(0,-64,0,-52);vg.addColorStop(0,C.cyan);vg.addColorStop(1,'#16306a');ctx.fillStyle=vg;ctx.beginPath();ctx.ellipse(6,-58,8,6.5,0,0,6.283);ctx.fill();
 ctx.strokeStyle='rgba(255,255,255,.7)';ctx.lineWidth=1.5;ctx.beginPath();ctx.arc(6,-58,5,3.6,4.6);ctx.stroke();
 let hx=4+Math.sin(ph)*8*run,hy=-28;
 if(o.atk>=0){hx=9;hy=-36;}
 ctx.strokeStyle=suit;ctx.lineWidth=6;ctx.beginPath();ctx.moveTo(2,-38);ctx.lineTo(hx,hy);ctx.stroke();ctx.fillStyle=acc;ctx.beginPath();ctx.arc(hx,hy,3.2,0,6.283);ctx.fill();
 if(o.sword&&o.atk>=0){const a=lerp(-2.1,.7,clamp(o.atk,0,1)),bx=hx+Math.cos(a)*54,by=hy+Math.sin(a)*54;
  ctx.globalCompositeOperation='lighter';ctx.strokeStyle='rgba(61,240,255,.55)';ctx.lineWidth=9;ctx.beginPath();ctx.arc(hx,hy,52,a-1,a);ctx.stroke();
  ctx.strokeStyle=C.cyan;ctx.lineWidth=6;ctx.beginPath();ctx.moveTo(hx,hy);ctx.lineTo(bx,by);ctx.stroke();ctx.globalCompositeOperation='source-over';
  ctx.strokeStyle='#fff';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(hx,hy);ctx.lineTo(bx,by);ctx.stroke();ctx.strokeStyle=C.gold;ctx.lineWidth=4;ctx.beginPath();ctx.moveTo(hx-Math.cos(a)*4,hy-Math.sin(a)*4);ctx.lineTo(hx+Math.cos(a)*6,hy+Math.sin(a)*6);ctx.stroke();}
 ctx.restore();
}
function drawVoidling(e,t,cam){
 const x=e.sx-cam,y=e.sy,hit=e.hitT>0;ctx.save();ctx.translate(x,y);ctx.lineCap='round';
 const gl=ctx.createRadialGradient(0,0,10,0,0,50);gl.addColorStop(0,'rgba(160,80,255,.35)');gl.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=gl;ctx.fillRect(-50,-50,100,100);
 for(let i=0;i<5;i++){const a=(i-2)*.45;ctx.strokeStyle=hit?'#fff':'#7b3fd6';ctx.lineWidth=4;ctx.beginPath();ctx.moveTo(Math.sin(a)*12,12);ctx.quadraticCurveTo(Math.sin(a)*20+Math.sin(t*5+i)*6,28,Math.sin(a)*24+Math.sin(t*4+i*2)*9,38+Math.cos(t*3+i)*4);ctx.stroke();}
 const g=ctx.createRadialGradient(-6,-8,3,0,0,24);g.addColorStop(0,hit?'#fff':'#c59bff');g.addColorStop(1,hit?'#ffe':'#3a1a7a');ctx.fillStyle=g;ctx.beginPath();ctx.arc(0,0,22,0,6.283);ctx.fill();
 ctx.fillStyle=C.ember;for(const ex of[-7,7]){ctx.beginPath();ctx.ellipse(ex+e.dir*3,-3,3.6,6,0,0,6.283);ctx.fill();}
 ctx.restore();
}
function drawPod(x,y,rot,broken,t){
 ctx.save();ctx.translate(x,y);ctx.rotate(rot);const hull=broken?'#7d86a8':'#cfd6f5';
 ctx.fillStyle=broken?'#4a4f6a':'#8a93bd';ctx.beginPath();ctx.moveTo(-24,0);ctx.lineTo(-38,8);ctx.lineTo(-22,-30);ctx.closePath();ctx.fill();ctx.beginPath();ctx.moveTo(24,0);ctx.lineTo(38,8);ctx.lineTo(22,-30);ctx.closePath();ctx.fill();
 ctx.fillStyle=hull;ctx.beginPath();ctx.moveTo(-24,0);ctx.lineTo(-24,-52);ctx.quadraticCurveTo(0,-110,24,-52);ctx.lineTo(24,0);ctx.closePath();ctx.fill();
 ctx.fillStyle=C.ember;ctx.fillRect(-24,-28,48,7);
 const wg=ctx.createRadialGradient(0,-58,2,0,-58,12);wg.addColorStop(0,broken?'#334':'#c9fbff');wg.addColorStop(1,broken?'#112':C.cyan);ctx.fillStyle=wg;ctx.beginPath();ctx.arc(0,-58,11,0,6.283);ctx.fill();
 if(broken){ctx.strokeStyle='#222';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(-8,-80);ctx.lineTo(0,-62);ctx.lineTo(10,-70);ctx.stroke();}
 ctx.restore();
}
function drawFlame(x,y,t,sc){const g=ctx.createLinearGradient(0,y,0,y+90*sc);g.addColorStop(0,'#fff');g.addColorStop(.3,C.gold);g.addColorStop(.7,C.ember);g.addColorStop(1,'rgba(255,60,20,0)');ctx.fillStyle=g;ctx.beginPath();ctx.moveTo(x-18,y);ctx.quadraticCurveTo(x,y+110*sc+Math.sin(t*40)*12,x+18,y);ctx.closePath();ctx.fill();}
function drawForge(L,cam,t){
 const x=L.forgeX-cam;if(x<-120||x>W+120)return;const on=!G.forgeDone;
 ctx.fillStyle='#1b1f45';ctx.beginPath();ctx.moveTo(x-60,GY);ctx.lineTo(x-40,GY-26);ctx.lineTo(x+40,GY-26);ctx.lineTo(x+60,GY);ctx.closePath();ctx.fill();
 for(const px of[-46,46]){ctx.fillStyle='#252b5e';rr(x+px-9,GY-120,18,100,4);ctx.fill();ctx.fillStyle=on?C.cyan:C.gold;ctx.fillRect(x+px-3,GY-110+(Math.sin(t*3)*4),6,14);}
 const col=on?C.cyan:C.gold,gl=ctx.createRadialGradient(x,GY-72,4,x,GY-72,90);gl.addColorStop(0,col+(on?'88':'cc'));gl.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=gl;ctx.fillRect(x-100,GY-170,200,200);
 ctx.save();ctx.translate(x,GY-72+Math.sin(t*2)*4);ctx.rotate(t*.8);ctx.fillStyle=col;ctx.globalAlpha=on?.9:.6;ctx.beginPath();ctx.moveTo(0,-20);ctx.lineTo(14,0);ctx.lineTo(0,20);ctx.lineTo(-14,0);ctx.closePath();ctx.fill();ctx.restore();ctx.globalAlpha=1;
 if(on&&Math.abs(G.p.x+14-L.forgeX)<110){const w=ctx.measureText?150:150;rr(x-w/2,GY-170,w,30,6);ctx.fillStyle='rgba(7,10,26,.85)';ctx.fill();ctx.strokeStyle=C.cyan;ctx.lineWidth=1.5;ctx.stroke();txt('E  ACTIVATE FORGE',x,GY-150,13,C.cyan,'center',F_U,700,1);}
}
function drawBarrier(L,cam,t){
 if(!G.barrierAlive)return;const x=L.barrierX-cam;if(x<-60||x>W+60)return;
 const gl=ctx.createLinearGradient(x-40,0,x+70,0);gl.addColorStop(0,'rgba(61,240,255,0)');gl.addColorStop(.5,'rgba(61,240,255,.25)');gl.addColorStop(1,'rgba(61,240,255,0)');ctx.fillStyle=gl;ctx.fillRect(x-40,GY-230,110,230);
 const r=rng(3);for(let i=0;i<9;i++){const bx=x+r()*30-6,h=60+r()*150,w=10+r()*12;ctx.fillStyle=i%2?'rgba(124,108,255,.8)':'rgba(120,240,255,.75)';ctx.beginPath();ctx.moveTo(bx,GY);ctx.lineTo(bx+w/2,GY-h);ctx.lineTo(bx+w,GY);ctx.closePath();ctx.fill();ctx.strokeStyle='rgba(255,255,255,.6)';ctx.lineWidth=1;ctx.stroke();}
 if(Math.abs(G.p.x-L.barrierX)<260&&!G.hasSword)txt('CRYSTAL BARRIER — needs a blade',x+14,GY-250,13,C.cyan,'center',F_U,600,1);
}
function drawPad(L,cam,t){
 const x=L.padX-cam;if(x<-80||x>W+80)return;
 const bg=ctx.createLinearGradient(0,0,0,GY);bg.addColorStop(0,'rgba(61,240,255,0)');bg.addColorStop(1,'rgba(61,240,255,.4)');ctx.fillStyle=bg;ctx.fillRect(x-24,0,48,GY);
 ctx.fillStyle='#252b5e';rr(x-60,GY-8,120,8,3);ctx.fill();drawPod(x,GY-8,0,false,t);
 ctx.strokeStyle=C.cyan;ctx.globalAlpha=.6;ctx.lineWidth=2;ctx.beginPath();ctx.ellipse(x,GY-4,50+Math.sin(t*3)*6,8,0,0,6.283);ctx.stroke();ctx.globalAlpha=1;
}
function drawCrystal(c,cam,t){const x=c.x-cam,y=c.y+Math.sin(t*3+c.x)*3;if(x<-20||x>W+20)return;ctx.fillStyle=C.cyan;ctx.globalAlpha=.25;ctx.beginPath();ctx.arc(x,y,13,0,6.283);ctx.fill();ctx.globalAlpha=1;ctx.beginPath();ctx.moveTo(x,y-10);ctx.lineTo(x+7,y);ctx.lineTo(x,y+10);ctx.lineTo(x-7,y);ctx.closePath();ctx.fillStyle=C.cyan;ctx.fill();ctx.fillStyle='#fff';ctx.fillRect(x-1.5,y-6,3,5);}
function heart(x,y,s,col){ctx.fillStyle=col;ctx.beginPath();ctx.moveTo(x,y+s*.9);ctx.bezierCurveTo(x-s*1.4,y-s*.1,x-s*.7,y-s*1.1,x,y-s*.35);ctx.bezierCurveTo(x+s*.7,y-s*1.1,x+s*1.4,y-s*.1,x,y+s*.9);ctx.fill();}
function drawPack(c,cam,t){const x=c.x-cam,y=c.y+Math.sin(t*2.5)*3;if(x<-20||x>W+20)return;ctx.fillStyle='rgba(93,255,176,.25)';ctx.beginPath();ctx.arc(x,y,16,0,6.283);ctx.fill();rr(x-9,y-9,18,18,4);ctx.fillStyle=C.green;ctx.fill();ctx.fillStyle='#062';ctx.fillRect(x-1.5,y-6,3,12);ctx.fillRect(x-6,y-1.5,12,3);}
function drawMeteor(m,cam){
 const k=clamp(m.t/m.dur,0,1),tx=m.tx-cam;
 if(!m.boom){const pr=24+(1-k)*30;ctx.strokeStyle='rgba(255,90,40,'+(.35+.4*k)+')';ctx.lineWidth=2.5;ctx.beginPath();ctx.ellipse(tx,GY,pr,pr*.22,0,0,6.283);ctx.stroke();ctx.fillStyle='rgba(255,90,40,'+(.12*k)+')';ctx.fill();
  const e=k*k,mx=lerp(m.sx,m.tx,e)-cam,my=lerp(m.sy,GY-16,e);ctx.fillStyle='#ff9a3c';ctx.globalAlpha=.4;ctx.beginPath();ctx.arc(mx,my,26,0,6.283);ctx.fill();ctx.globalAlpha=1;
  ctx.fillStyle='#5b4a52';ctx.beginPath();ctx.arc(mx,my,15,0,6.283);ctx.fill();ctx.fillStyle='#8a6a60';ctx.beginPath();ctx.arc(mx-4,my-4,6,0,6.283);ctx.fill();spawn(mx+cam,my,Math.random()*30,-20,.4,5,'#ff7a2e',0,true);}
 else{const f=clamp(m.fade/.4,0,1);ctx.globalAlpha=f;const g=ctx.createRadialGradient(tx,GY-20,4,tx,GY-20,80);g.addColorStop(0,'#fff');g.addColorStop(.4,C.ember);g.addColorStop(1,'rgba(255,60,20,0)');ctx.fillStyle=g;ctx.fillRect(tx-90,GY-110,180,140);ctx.globalAlpha=1;}
}
function drawHole(hx,cam,t,big){
 const sx=hx-cam,sy=300,R=170;
 const gl=ctx.createRadialGradient(sx,sy,R*.8,sx,sy,R*3.1);gl.addColorStop(0,'rgba(255,122,46,.55)');gl.addColorStop(.35,'rgba(130,60,220,.28)');gl.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=gl;ctx.fillRect(sx-R*3.2,sy-R*3.2,R*6.4,R*6.4);
 ctx.save();ctx.translate(sx,sy);ctx.rotate(-.35);ctx.globalCompositeOperation='lighter';
 for(let i=0;i<4;i++){ctx.strokeStyle=['rgba(255,170,80,.55)','rgba(255,95,168,.4)','rgba(150,110,255,.35)','rgba(255,220,160,.5)'][i];ctx.lineWidth=14-i*2.5;ctx.beginPath();ctx.ellipse(0,0,R*(1.5+i*.28),R*(.28+i*.07),0,t*.2,t*.2+5.6);ctx.stroke();}
 ctx.globalCompositeOperation='source-over';ctx.restore();
 ctx.fillStyle='#000';ctx.beginPath();ctx.arc(sx,sy,R,0,6.283);ctx.fill();
 ctx.strokeStyle='rgba(255,200,140,.9)';ctx.lineWidth=3;ctx.shadowColor=C.ember;ctx.shadowBlur=24;ctx.beginPath();ctx.arc(sx,sy,R+2,0,6.283);ctx.stroke();ctx.shadowBlur=0;
}
function drawHUD(){
 const p=G.p,L=G.lvl;
 for(let i=0;i<5;i++)heart(26+i*26,28,9,i<p.hp?C.pink:'rgba(255,255,255,.14)');
 ctx.fillStyle=C.cyan;ctx.beginPath();ctx.moveTo(24,50);ctx.lineTo(31,58);ctx.lineTo(24,66);ctx.lineTo(17,58);ctx.closePath();ctx.fill();txt(String(G.crystals),40,63,17,C.bone,'left',F_U,700);
 const d=p.x+p.w/2-(G.hx+170),k=1-clamp(d/1000,0,1),mx=330,mw=300;
 txt('THE DEVOURER',480,24,11,k>.6?C.ember:C.dim,'center',F_U,700,3);
 ctx.fillStyle='rgba(255,255,255,.1)';rr(mx,32,mw,8,4);ctx.fill();const c2=k>.6?'#ff4a2a':k>.35?C.ember:C.cyan;ctx.fillStyle=c2;rr(mx,32,Math.max(8,mw*k),8,4);ctx.fill();
 if(k>.6){ctx.fillStyle='rgba(255,60,20,'+(.06+.05*Math.sin(G.t*10))+')';ctx.fillRect(0,0,W,H);}
 txt(L.name,W-20,26,12,C.dim,'right',F_U,700,2);
 const pr=clamp(p.x/L.L,0,1);ctx.fillStyle='rgba(255,255,255,.1)';rr(W-220,36,200,5,3);ctx.fill();ctx.fillStyle=C.gold;rr(W-220,36,200*pr,5,3);ctx.fill();txt(Math.floor(getDist()/10)+' KM',W-20,58,12,C.bone,'right',F_U,600,1);
 let obj;if(G.mode==='endless')obj='Reach the launch beacon';else if(!G.forgeDone)obj='Reach the energy forge';else if(G.barrierAlive)obj='Shatter the crystal barrier — J';else obj='Reach the escape pod';
 txt(obj.toUpperCase(),480,H-18,12,C.cyan,'center',F_U,700,3);
 if(G.hint>0&&G.introT<=0)txt('A / D  MOVE     SPACE  JUMP     SHIFT  DASH (INVULNERABLE)',480,H-42,12,C.dim,'center',F_U,600,2);
 const t=G.toast;if(t&&t.t>0){const a=clamp(Math.min(t.t,1),0,1);ctx.globalAlpha=a;txt(t.a,480,110,24,C.bone,'center',F_D,700,3);txt(t.b,480,136,14,C.cyan,'center',F_U,600,1);ctx.globalAlpha=1;}
}
