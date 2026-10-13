
/* ---------- worlds 2-6 ---------- */
const WORLDS=[null,
 {th:'aether',name:'WORLD 2 — AETHER-7',sub:'A Sentinel guards the launch gate. Crystals hide on the high routes.',len:4300,boss:{name:'AETHER SENTINEL',hp:8,rate:2.4},enemies:5,meteor:2.6,hole:112},
 {th:'cinder',name:'WORLD 3 — CINDER MOON',sub:'Vents erupt on a timer. Decode the armory to earn the plasma blaster.',len:4400,puzzle:'symbol',reward:'blaster',vents:true,enemies:5,meteor:1.7,hole:118},
 {th:'cryos',name:'WORLD 4 — CRYOS',sub:'The ice is slick. Read the research logs. Wake the planets in order.',len:4500,slip:true,puzzle:'seq',order:'in',reward:'shield',logs:3,enemies:6,meteor:2.4,hole:122},
 {th:'vortex',name:'WORLD 5 — VORTEX PRIME',sub:'Recover the gravity lance, then face the Vortex Guardian.',len:4700,puzzle:'seq',order:'out',reward:'lance',boss:{name:'VORTEX GUARDIAN',hp:18,rate:1.7},enemies:5,meteor:2,hole:128},
 {th:'earth',name:'WORLD 6 — EARTH',sub:'Home. The signal followed you.',len:4000,enemies:7,meteor:2.4,hole:130,final:true}];
const LOGS=['The signal woke when we drilled Cryos. Then the stars began to leave.','The Devourer does not hunt. It follows the signal.','Whoever carries the pod carries the signal. Do not take it to Earth.'];
function mkBoss(L){const b=L.boss;return{name:b.name,x:L.L-520,bx:L.L-520,y:GY-125,hp:b.hp,max:b.hp,rate:b.rate,t:0,fire:2.5,hitT:0,dead:false,dying:0};}
function mkWorld(w){
 const c=WORLDS[w],th=TH[c.th],r=rng(500+w*31),len=c.len,segs=[[-800,900]],plats=[],arena=c.boss?len-1480:len+1;
 let x=900;
 while(x<len){const gap=100+r()*(25+w*4),sx=x+gap;let ex=sx+330+r()*380;
  if(c.boss&&ex>arena){segs.push([sx,len]);plats.push({x:x+gap/2-35,y:360,w:70});break;}
  if(len-ex<420)ex=len;segs.push([sx,ex]);plats.push({x:x+gap/2-35,y:360,w:70});x=ex;if(ex>=len)break;}
 const last=segs[segs.length-1];
 segs.forEach((s,i)=>{if(i>0&&s[1]-s[0]>520&&s!==last)plats.push({x:(s[0]+s[1])/2-60,y:285+r()*45,w:120});});
 if(c.boss){const a=last[0];[300,620,940].forEach((o,i)=>plats.push({x:a+o,y:i===1?250:320,w:130}));}
 const L={kind:'story',world:w,name:c.name,sub:c.sub,theme:th,L:len,startX:180,segs,plats,forgeX:null,barrierX:null,padX:len-150,cps:[180],holeSpeed:c.hole,meteorEvery:c.meteor,
  packs:[],enemies:[],crystals:[],vents:null,logs:null,slip:!!c.slip,boss:c.boss||null,final:!!c.final,puzzle:c.puzzle||null,reward:c.reward||null,order:c.order||null};
 if(c.puzzle){let s=segs.find(s=>s[0]>len*.35&&s[1]-s[0]>480&&s!==last&&s[1]<len-500)||segs.filter(s=>s!==last&&s[0]>900).sort((a,b)=>(b[1]-b[0])-(a[1]-a[0]))[0];L.forgeX=Math.floor((s[0]+s[1])/2);L.cps.push(s[0]+60);}
 else{const s=segs[Math.floor(segs.length/2)];L.cps.push(s[0]+60);}
 if(c.boss)L.cps.push(last[0]+100);L.cps.sort((a,b)=>a-b);
 const lim=c.boss?arena-100:len-300;
 for(let i=0;i<c.enemies;i++){const s=segs[1+Math.floor(r()*(segs.length-2))];if(s&&s[1]-s[0]>260&&s[0]>1000&&s[0]<lim)L.enemies.push({cx:s[0]+130+r()*(s[1]-s[0]-260),range:60+r()*70,ph:r()*6,spd:1.2+r()*.9});}
 if(c.vents)segs.forEach(s=>{if(s[0]>900&&s!==last&&s[1]-s[0]>400){const n=1+(r()<.5?1:0);for(let k=0;k<n;k++){const vx=s[0]+120+r()*(s[1]-s[0]-240);if(!L.forgeX||Math.abs(vx-L.forgeX)>130)(L.vents=L.vents||[]).push({x:vx,ph:r()*3.4,state:0});}}});
 if(c.logs){L.logs=[];for(let i=0;i<c.logs;i++){const p=plats[Math.floor(plats.length*(i+1)/(c.logs+1))];L.logs.push({x:p.x+p.w/2,y:p.y-34,got:false,text:LOGS[i]});}}
 plats.forEach(p=>{for(let i=0;i<3;i++)L.crystals.push({x:p.x+p.w*(i+.5)/3,y:p.y-30,got:false});});
 segs.forEach(s=>{for(let x=Math.max(s[0],300)+90;x<s[1]-60;x+=150)if(r()<.35&&(!L.forgeX||Math.abs(x-L.forgeX)>110)&&Math.abs(x-L.padX)>110)L.crystals.push({x,y:GY-34,got:false});});
 if(plats.length>4){L.packs.push({x:plats[3].x+plats[3].w/2,y:plats[3].y-30,got:false});L.packs.push({x:plats[Math.floor(plats.length*.65)].x+60,y:plats[Math.floor(plats.length*.65)].y-30,got:false});}
 L.enemies.forEach(e=>{e.hp=2;e.dead=false;e.hitT=0;e.sx=e.cx;e.sy=GY-74;e.dir=1;e.swing=-1;});
 L.solids=L.segs.map(s=>({x0:s[0],x1:s[1],y:GY})).concat(L.plats.map(p=>({x0:p.x,x1:p.x+p.w,y:p.y})));
 return L;
}

/* ---------- combat extras: shield, blaster, lance, guardians, vents, logs ---------- */
function hitEnemy(e,n){e.hp-=n;e.hitT=.2;SFX.hit();burst(e.sx,e.sy,8,'#c59bff',200,.4,true);if(e.hp<=0){e.dead=true;G.kills++;G.crystals+=2;burst(e.sx,e.sy,22,'#c59bff',280,.8,true);SFX.gem();}}
function hitBoss(n){const B=G.boss;if(!B||B.dead)return;B.hp-=n;B.hitT=.15;SFX.hit();G.shake=Math.max(G.shake,5);burst(B.x,B.y,10,'#fff',220,.4,true);
 if(B.hp<=0){B.dead=true;B.dying=1.6;G.ep=[];G.crystals+=10;SFX.boom();G.shake=18;burst(B.x,B.y,60,C.gold,420,1.2,true);G.toast={a:'GUARDIAN DOWN',b:'The gate is open. Reach the pod.',t:4};}}
function pullEnemies(x,y){for(const e of G.lvl.enemies)if(!e.dead&&Math.hypot(e.sx-x,e.sy-y)<170)e.cx+=(x-e.sx)*.5;}
function grantReward(){const L=G.lvl,r=L.reward||'sword';burst(L.forgeX,GY-72,40,C.gold,320,1,true);
 if(r==='sword'){G.hasSword=true;return{a:'ENERGY SWORD ACQUIRED',b:'J slashes. Voidlings and crystal barriers break.',t:4.5};}
 if(r==='blaster'){G.hasBlaster=true;return{a:'PLASMA BLASTER ACQUIRED',b:'K fires. Hits foes and guardians from range.',t:4.5};}
 if(r==='shield'){G.hasShield=true;return{a:'PHASE SHIELD ACQUIRED',b:'Q blocks projectiles and fire for 1.6 seconds.',t:4.5};}
 G.hasLance=true;return{a:'GRAVITY LANCE ACQUIRED',b:'Hold K, release to fire. It pierces and pulls enemies together.',t:4.5};}
function updateExtras(dt){
 const L=G.lvl,p=G.p;G.bolCd-=dt;G.shCd-=dt;if(G.shT>0)G.shT-=dt;
 if(pressed('shield')&&G.hasShield&&G.shCd<=0){G.shT=1.6;G.shCd=6;SFX.ok();burst(p.x+14,p.y+24,14,C.cyan,200,.5,true);}
 if(held.shoot&&(G.hasBlaster||G.hasLance))G.chg+=dt;
 if(!held.shoot&&G.chg>0){const c=G.chg;G.chg=0;
  if(c>=.7&&G.hasLance){G.bolts.push({x:p.x+14,y:p.y+22,vx:p.face*420,life:.9,lance:true,hit:new Set()});tone(120,.4,'sawtooth',.12,3);G.shake=4;}
  else if(G.hasBlaster&&G.bolCd<=0){G.bolts.push({x:p.x+14+p.face*18,y:p.y+22,vx:p.face*640,life:1.1,lance:false});G.bolCd=.28;tone(520,.1,'square',.07,.5);}}
 for(let i=G.bolts.length-1;i>=0;i--){const b=G.bolts[i];b.x+=b.vx*dt;b.life-=dt;let gone=b.life<=0;spawn(b.x,b.y,0,0,.25,b.lance?10:4,b.lance?'#c58bff':C.cyan,0,true);
  for(const e of L.enemies){if(e.dead||(b.hit&&b.hit.has(e)))continue;if(Math.hypot(e.sx-b.x,e.sy-b.y)<(b.lance?40:24)){hitEnemy(e,b.lance?2:1);if(b.lance){b.hit.add(e);pullEnemies(e.sx,e.sy);}else gone=true;}}
  const B=G.boss;if(B&&!B.dead&&Math.abs(b.x-B.x)<(b.lance?68:48)&&Math.abs(b.y-B.y)<95&&!(b.hit&&b.hit.has(B))){hitBoss(b.lance?3:1);if(b.lance)b.hit.add(B);else gone=true;}
  for(const q of G.ep)if(Math.abs(q.x-b.x)<16&&Math.abs(q.y-b.y)<16){q.life=0;burst(q.x,q.y,5,'#fff',100,.3,true);if(!b.lance)gone=true;}
  if(gone)G.bolts.splice(i,1);}
 const B=G.boss;
 if(B){if(B.dead){B.dying-=dt;if(B.dying>0&&Math.random()<.5)burst(B.x+(Math.random()-.5)*60,B.y+(Math.random()-.5)*80,4,'#ffb347',200,.6,true);}
  else if(Math.abs(p.x-B.x)<900){B.t+=dt;B.hitT-=dt;B.x=B.bx+Math.sin(B.t*.9)*170;B.y=GY-125+Math.sin(B.t*1.7)*28;B.fire-=dt;
   if(B.fire<=0){B.fire=B.rate*(B.hp<B.max/2?.7:1);const n=B.hp<B.max/2?5:3,a0=Math.atan2(p.y+20-B.y,p.x+14-B.x);for(let i=0;i<n;i++){const a=a0+(i-(n-1)/2)*.28;G.ep.push({x:B.x,y:B.y,vx:Math.cos(a)*270,vy:Math.sin(a)*270,life:3.2});}tone(150,.3,'sawtooth',.1,.5);}
   if(Math.abs(p.x+14-B.x)<46&&Math.abs(p.y+24-B.y)<95)hurt(1,B.x);}}
 for(let i=G.ep.length-1;i>=0;i--){const q=G.ep[i];q.x+=q.vx*dt;q.y+=q.vy*dt;q.life-=dt;
  if(q.life>0&&Math.hypot(q.x-(p.x+14),q.y-(p.y+24))<22){if(G.shT>0){burst(q.x,q.y,6,C.cyan,120,.3,true);q.life=0;}else if(p.inv<=0&&p.dashT<=0){hurt(1,q.x);q.life=0;}}
  if(q.life<=0||q.y>H+20)G.ep.splice(i,1);}
 if(L.vents)for(const v of L.vents){const ph=(G.t+v.ph)%3.4;v.state=ph<1.8?0:ph<2.5?1:2;if(v.state===2){if(Math.abs(p.x+14-v.x)<26&&p.y+p.h>GY-170)hurt(1,v.x);if(Math.random()<.5)spawn(v.x+(Math.random()-.5)*20,GY-10,0,-300,.5,4,'#ffb347',0,true);}}
 if(L.logs)for(const g of L.logs)if(!g.got&&Math.hypot(g.x-(p.x+14),g.y-(p.y+24))<30){g.got=true;G.logs++;SFX.ok();G.toast={a:'RESEARCH LOG '+G.logs+' / '+L.logs.length,b:g.text,t:6};}
}

/* ---------- puzzles: dispatcher, symbol lock, orbital lock ---------- */
function initPuzzle(){const t=G.lvl.puzzle||'mirror';G.pz=t==='symbol'?symInit():t==='seq'?seqInit():mirrorInit();}
function pzHint(){const z=G.pz;if(z.type==='mirror')mirrorHint();else{z.hint=true;z.hintT=4;}}
function pzClick(mx,my){const z=G.pz;if(!z||z.solved)return;if(z.type==='mirror')mirrorClick(mx,my);else if(z.type==='symbol')symClick(mx,my);else seqClick(mx,my);}
const SYM_ROUNDS=[{seq:[0,1,2,0,1],ans:2},{seq:[0,0,1,1,2,2,0,0],ans:1}];
function symInit(){return{type:'symbol',round:0,idle:0,hint:false,hintT:0,solved:false,st:0,err:0,wrong:0,order:[[1,3,0,2],[3,1,2,0]]};}
function symClick(mx,my){const z=G.pz,i=Math.floor((mx-70)/110);if(my<320||my>410||i<0||i>3||(mx-70)%110>90)return;const s=z.order[z.round][i];z.idle=0;
 if(s===SYM_ROUNDS[z.round].ans){z.round++;z.hint=false;z.wrong=0;SFX.gem();if(z.round>=2){z.solved=true;z.st=0;SFX.ok();G.shake=6;}}
 else{z.wrong++;z.err=.5;SFX.hurt();if(z.wrong>=2){z.hint=true;z.hintT=4;}}}
const SEQX=300,SEQY=300,SEQ_PL=[{r:55,sp:1.3,ph:0,sz:9,col:'#ffd166'},{r:95,sp:.9,ph:2,sz:12,col:'#ff5fa8'},{r:135,sp:.65,ph:4,sz:15,col:'#3df0ff'},{r:175,sp:.45,ph:1,sz:18,col:'#5dffb0'}];
function seqPos(i){const q=SEQ_PL[i],a=G.t*q.sp+q.ph;return[SEQX+Math.cos(a)*q.r,SEQY+Math.sin(a)*q.r*.62];}
function seqInit(){return{type:'seq',order:G.lvl.order==='out'?[3,2,1,0]:[0,1,2,3],next:0,lit:[],idle:0,hint:false,hintT:0,solved:false,st:0,err:0};}
function seqClick(mx,my){const z=G.pz;for(let i=0;i<4;i++){const q=SEQ_PL[i],pp=seqPos(i);if(Math.hypot(mx-pp[0],my-pp[1])<q.sz+14){z.idle=0;
  if(i===z.order[z.next]&&!z.lit.includes(i)){z.lit.push(i);z.next++;SFX.gem();if(z.next>=4){z.solved=true;z.st=0;SFX.ok();G.shake=6;}}
  else{z.lit=[];z.next=0;z.err=.5;SFX.hurt();}return;}}}
