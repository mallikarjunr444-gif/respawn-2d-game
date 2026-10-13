
/* ---------- gameplay ---------- */
function hurt(n,fromX,force){const p=G.p;if(!force&&(p.inv>0||p.dashT>0))return;p.hp-=n;p.inv=1.2;p.vx=(p.x<fromX?-1:1)*320;p.vy=-300;p.on=false;G.shake=10;SFX.hurt();burst(p.x+14,p.y+24,10,C.pink,220,.5,true);if(p.hp<=0)die('SYSTEMS FAILURE');}
function die(why){G.scene='dead';G.deadWhy=why;G.deadT=0;G.shake=16;SFX.boom();burst(G.p.x+14,G.p.y+24,30,C.cyan,300,.9,true);saveBest();}
function spawnMeteor(){const p=G.p,L=G.lvl,tx=p.x+120+Math.random()*380;if(tx>L.L-60)return;if(!L.solids.some(s=>s.y===GY&&tx>s.x0+30&&tx<s.x1-30))return;G.meteors.push({tx,t:0,dur:1.05,sx:tx+260,sy:-80,boom:false,fade:.4});}
function completeLevel(){saveBest();if(G.mode==='story'){G.scene='launch';G.lt=0;SFX.ok();}else{G.distBase+=G.lvl.L;G.sector++;const hp=G.p.hp;loadLevel(mkLevel('endless',G.sector),false);G.p.hp=Math.min(5,hp+1);G.fade=1;SFX.ok();}}
function updatePlay(dt){
 const L=G.lvl,p=G.p;G.fade=Math.max(0,G.fade-dt*1.2);G.hint-=dt;if(G.toast)G.toast.t-=dt;G.shake=Math.max(0,G.shake-dt*30);
 if(G.introT>0){G.introT-=dt;if(G.introT<=0){G.podBroken=true;G.shake=18;SFX.boom();burst(L.startX,GY-20,40,C.ember,360,1,true);}
  else if(Math.random()<.7)spawn(L.startX+Math.random()*20-10,lerp(-100,GY-40,Math.pow(1-G.introT/2.6,2))-30,Math.random()*60-30,-60,.5,6,'#ff9a3c',0,true);
  updFx(dt);G.cam=lerp(G.cam,Math.max(0,L.startX-380),.1);return;}
 G.time+=dt;if(G.podBroken&&Math.random()<.15)spawn(L.startX+Math.random()*16-8,GY-70,Math.random()*20-10,-40,1.6,5,'rgba(180,180,200,.5)',0,false);
 const ax=(held.right?1:0)-(held.left?1:0);if(ax)p.face=ax;
 p.coy-=dt;p.buf-=dt;p.dashCd-=dt;p.atkCd-=dt;p.inv-=dt;p.anim+=dt;
 if(pressed('jump'))p.buf=.12;if(p.on){p.coy=.1;p.dashAir=false;}
 if(pressed('dash')&&p.dashCd<=0&&(p.on||!p.dashAir)){p.dashT=.17;p.dashCd=.65;p.dashDir=p.face;if(!p.on)p.dashAir=true;p.inv=Math.max(p.inv,.22);SFX.dash();}
 if(p.dashT>0){p.dashT-=dt;p.vx=p.dashDir*700;p.vy=0;spawn(p.x+14,p.y+24,0,0,.25,13,'rgba(61,240,255,.55)',0,true);}
 else{const tg=ax*270,ac=p.on?3200:2000;if(p.vx<tg)p.vx=Math.min(tg,p.vx+ac*dt);else p.vx=Math.max(tg,p.vx-ac*dt);p.vy=Math.min(900,p.vy+1900*dt);}
 if(p.buf>0&&p.coy>0){p.vy=-650;p.on=false;p.coy=0;p.buf=0;p.jumping=true;SFX.jump();burst(p.x+14,p.y+48,5,'#9aa3d8',90,.3);}
 if(p.jumping&&!held.jump&&p.vy<-250){p.vy*=.5;p.jumping=false;}if(p.vy>=0)p.jumping=false;
 if(pressed('atk')&&G.hasSword&&p.atkCd<=0){p.atkT=.28;p.atkCd=.38;p.swing=(p.swing||0)+1;SFX.swing();}
 if(p.atkT>0){p.atkT-=dt;const k=.28-p.atkT;if(k>.04&&k<.2){const bx=p.face>0?p.x+14:p.x+14-78,by=p.y-14,bw=78,bh=p.h+22;
  for(const e of L.enemies){if(e.dead||e.swing===p.swing)continue;if(e.sx+22>bx&&e.sx-22<bx+bw&&e.sy+22>by&&e.sy-22<by+bh){e.swing=p.swing;e.hp--;e.hitT=.2;SFX.hit();G.shake=5;burst(e.sx,e.sy,8,'#c59bff',200,.4,true);if(e.hp<=0){e.dead=true;G.kills++;burst(e.sx,e.sy,22,'#c59bff',280,.8,true);for(let i=0;i<2;i++)G.crystals++;SFX.gem();}}}
  if(L.barrierX&&G.barrierAlive&&L.barrierX+34>bx&&L.barrierX<bx+bw){G.barrierAlive=false;G.shake=14;SFX.boom();burst(L.barrierX+16,GY-100,50,C.cyan,380,1,true);burst(L.barrierX+16,GY-60,30,'#fff',300,.8,true);}}}
 p.x+=p.vx*dt;
 if(L.barrierX&&G.barrierAlive){const bx=L.barrierX,bw=34;if(p.x+p.w>bx&&p.x<bx+bw&&p.y+p.h>GY-210){if(p.x+p.w/2<bx+bw/2)p.x=bx-p.w;else p.x=bx+bw;p.vx=0;}}
 p.x=Math.max(p.x,-700);
 const ob=p.y+p.h;p.y+=p.vy*dt;const nb=p.y+p.h,was=p.on;p.on=false;
 if(p.vy>=0)for(const s of L.solids){if(p.x+p.w-6>s.x0&&p.x+6<s.x1&&ob<=s.y+3&&nb>=s.y){if(!was&&p.vy>300)burst(p.x+14,s.y,6,'#9aa3d8',110,.3);p.y=s.y-p.h;p.vy=0;p.on=true;p.sol=s;break;}}
 if(p.on&&p.sol&&p.x>p.sol.x0+40&&p.x+p.w<p.sol.x1-40)G.safe={x:p.x,y:p.y};
 if(p.y>H+80){p.hp--;SFX.hurt();G.shake=8;if(p.hp<=0){die('LOST TO THE VOID');}else{p.x=G.safe.x;p.y=G.safe.y;p.vx=p.vy=0;p.inv=1.4;G.hx=Math.min(G.hx,p.x-780);}}
 for(let i=L.cps.length-1;i>G.cp;i--)if(p.x>L.cps[i]){G.cp=i;break;}
 for(const e of L.enemies){if(e.dead)continue;const px=e.sx;e.sx=e.cx+Math.sin(G.t*e.spd+e.ph)*e.range;e.sy=GY-74+Math.sin(G.t*2.3+e.ph)*10;e.dir=e.sx>=px?1:-1;e.hitT-=dt;
  const nx=clamp(e.sx,p.x,p.x+p.w),ny=clamp(e.sy,p.y,p.y+p.h);if(Math.hypot(e.sx-nx,e.sy-ny)<20)hurt(1,e.sx);}
 for(const c of L.crystals)if(!c.got&&Math.hypot(c.x-(p.x+14),c.y-(p.y+24))<28){c.got=true;G.crystals++;SFX.gem();burst(c.x,c.y,6,C.cyan,120,.4,true);}
 for(const c of L.packs)if(!c.got&&Math.hypot(c.x-(p.x+14),c.y-(p.y+24))<28&&p.hp<5){c.got=true;p.hp++;SFX.ok();burst(c.x,c.y,10,C.green,160,.5,true);}
 if(L.forgeX&&!G.forgeDone&&p.on&&Math.abs(p.x+14-L.forgeX)<110&&pressed('use')){G.scene='puzzle';if(!G.pz)initPuzzle();G.pz.idle=0;SFX.click();}
 if(p.x+14>L.padX-30&&p.on&&(G.mode==='endless'||G.forgeDone)&&!(L.barrierX&&G.barrierAlive))completeLevel();
 G.meteorT-=dt;if(G.meteorT<=0){G.meteorT=L.meteorEvery*(.7+Math.random()*.6);spawnMeteor();}
 for(let i=G.meteors.length-1;i>=0;i--){const m=G.meteors[i];if(!m.boom){m.t+=dt;if(m.t>=m.dur){m.boom=true;SFX.boom();G.shake=Math.max(G.shake,9);burst(m.tx,GY-10,20,C.ember,300,.7,true);if(Math.abs(p.x+14-m.tx)<64&&p.y+p.h>GY-80)hurt(1,m.tx);}}else{m.fade-=dt;if(m.fade<=0)G.meteors.splice(i,1);}}
 const sp=L.holeSpeed*(1+.15*clamp(p.x/L.L,0,1));G.hx+=sp*dt;const dl=G.hx+170,d=p.x+p.w/2-dl;
 if(d<0)die('CONSUMED BY THE DEVOURER');else if(d<500)p.vx-=380*(1-d/500)*dt;
 if(Math.random()<.5)spawn(G.cam+Math.random()*W,80+Math.random()*340,-60-Math.random()*50,0,1.4,2,'rgba(255,170,100,.7)',0,true);
 G.cam=lerp(G.cam,clamp(p.x-380,0,Math.max(0,L.L-W+120)),Math.min(1,dt*6));
 updFx(dt);
 if(droneG&&AC)droneG.gain.setTargetAtTime(.03+.2*(1-clamp(d/900,0,1)),AC.currentTime,.2);
}

/* ---------- forge puzzle: route the reactor beam into the forge core ---------- */
const PZ={cols:6,rows:5,cs:72,gx:70,gy:122,src:[0,3],tgt:[5,4],
 sol:{'3,3':'/','3,1':'/','5,1':'\\'},keys:['3,3','3,1','5,1'],
 init:{'3,3':'\\','3,1':'\\','5,1':'/','1,1':'/','4,3':'\\','1,4':'/','4,0':'\\'}};
function initPuzzle(){G.pz={m:Object.assign({},PZ.init),idle:0,hint:null,hintT:0,solved:false,st:0};}
function pzTrace(m){const pts=[[PZ.src[0],PZ.src[1]]];let c=PZ.src[0],r=PZ.src[1],dx=1,dy=0,hit=false;
 for(let i=0;i<40;i++){c+=dx;r+=dy;pts.push([c,r]);if(c<0||c>=PZ.cols||r<0||r>=PZ.rows)break;if(c===PZ.tgt[0]&&r===PZ.tgt[1]){hit=true;break;}
  const mm=m[c+','+r];if(mm==='/'){const a=-dy,b=-dx;dx=a;dy=b;}else if(mm==='\\'){const a=dy,b=dx;dx=a;dy=b;}}
 return{pts,hit};}
function pzHint(){const z=G.pz;for(const k of PZ.keys)if(z.m[k]!==PZ.sol[k]){z.hint=k;z.hintT=4;return;}}
function pzClick(mx,my){const z=G.pz;if(!z||z.solved)return;const c=Math.floor((mx-PZ.gx)/PZ.cs),r=Math.floor((my-PZ.gy)/PZ.cs),k=c+','+r;
 if(c<0||r<0||c>=PZ.cols||r>=PZ.rows||!z.m[k])return;z.m[k]=z.m[k]==='/'?'\\':'/';z.idle=0;z.hint=null;SFX.click();
 if(pzTrace(z.m).hit){z.solved=true;z.st=0;SFX.ok();G.shake=6;}}
function updatePuzzle(dt){const z=G.pz;z.idle+=dt;z.hintT-=dt;if(z.hintT<=0)z.hint=null;if(z.idle>12&&!z.hint&&!z.solved)pzHint();
 if(pressed('hint')&&!z.solved)pzHint();if(pressed('esc')&&!z.solved){G.scene='play';}
 G.shake=Math.max(0,G.shake-dt*30);updFx(dt);
 if(z.solved){z.st+=dt;if(z.st>1.5){G.forgeDone=true;G.hasSword=true;G.scene='play';G.toast={a:'ENERGY SWORD ACQUIRED',b:'Press J to slash — voidlings and crystal barriers break',t:4};burst(G.lvl.forgeX,GY-72,40,C.gold,320,1,true);G.p.inv=1;}}}
