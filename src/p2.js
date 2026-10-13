
/* ---------- themes & levels ---------- */
const TH={
moon:{name:'THE FRACTURED MOON',sky:['#05071a','#1a1250'],neb:['rgba(120,60,220,.35)','rgba(255,90,120,.18)'],m1:'#150f3a',m2:'#221858',rock:['#2b2457','#14102e'],rim:'#7a6cff',planet:'#e8a05a'},
solar:{name:'SOLAR FRONTIER',sky:['#06091f','#10285a'],neb:['rgba(40,140,255,.3)','rgba(255,170,60,.15)'],m1:'#0c1a3d',m2:'#16295a',rock:['#2a3e66','#101a35'],rim:'#46d4ff',planet:'#ffb86b'},
nebula:{name:'NEBULA EXPANSE',sky:['#12041f','#3a0f4f'],neb:['rgba(255,80,200,.35)','rgba(80,60,255,.3)'],m1:'#2a0b3d',m2:'#401558',rock:['#4a2260','#1b0a2b'],rim:'#ff7bd0',planet:'#c08aff'},
shatter:{name:'SHATTERED GALAXY',sky:['#150507','#3a1018'],neb:['rgba(255,90,40,.3)','rgba(255,200,80,.12)'],m1:'#2a0d10',m2:'#451a1c',rock:['#4a2a2a','#1a0d0d'],rim:'#ff9a5a',planet:'#ff7a4a'},
ancient:{name:'ANCIENT EXPANSE',sky:['#03140f','#0b3a35'],neb:['rgba(60,255,200,.25)','rgba(255,220,100,.12)'],m1:'#08241f','m2':'#0f3b35',rock:['#1f4a44','#0a1f1c'],rim:'#6dffd8',planet:'#ffe08a'},
horizon:{name:'EVENT HORIZON',sky:['#000000','#1a0a2e'],neb:['rgba(255,255,255,.12)','rgba(255,90,30,.35)'],m1:'#12061f',m2:'#22103a',rock:['#2b1a3a','#0a0610'],rim:'#ffb347',planet:'#ffffff'}};
TH.aether={name:'AETHER-7',sky:['#031a1c','#0e4a52'],neb:['rgba(60,255,210,.3)','rgba(255,209,102,.18)'],m1:'#082e33',m2:'#0f4a50',rock:['#2a6a66','#0d2a2c'],rim:'#7dffe0',planet:'#ffd166'};
TH.cinder={name:'CINDER MOON',sky:['#1a0503','#4a1208'],neb:['rgba(255,80,30,.35)','rgba(255,190,60,.15)'],m1:'#2a0b07',m2:'#4a160c',rock:['#5a2a20','#1c0a07'],rim:'#ff7a2e',planet:'#ff9a4a'};
TH.cryos={name:'CRYOS',sky:['#04122a','#123c6a'],neb:['rgba(120,200,255,.3)','rgba(200,160,255,.15)'],m1:'#0b2447',m2:'#173b6a',rock:['#7fb2d8','#1d3a5a'],rim:'#d8f4ff',planet:'#b8e6ff'};
TH.vortex={name:'VORTEX PRIME',sky:['#0a0220','#2a0a5a'],neb:['rgba(180,80,255,.4)','rgba(61,240,255,.2)'],m1:'#180646',m2:'#2c0f6a',rock:['#3a2570','#120a30'],rim:'#c58bff',planet:'#6a3fd0'};
TH.earth={name:'EARTH',sky:['#0a1f4a','#3d86d0'],neb:['rgba(255,255,255,.18)','rgba(255,209,102,.18)'],m1:'#1a4a3a',m2:'#26664a',rock:['#3a6b4a','#14281c'],rim:'#9dffb8',planet:'#ffd166'};
const ENDLESS=[TH.solar,TH.nebula,TH.shatter,TH.ancient,TH.horizon];
const STARS=[70,50,30].map((n,l)=>{const r=rng(11+l);return Array.from({length:n},()=>({x:r()*(W+40),y:r()*H*.85,r:l===2?2.2:l===1?1.6:1.1,sp:1+r()*3,ph:r()*6}));});

function mkLevel(kind,n){
 if(kind==='story'&&n>0)return mkWorld(n);
 let L;
 if(kind==='story'){
  const r=rng(7);
  L={kind,name:'WORLD 1 — THE FRACTURED MOON',theme:TH.moon,L:4500,startX:180,
   segs:[[-800,980],[1110,1700],[1840,2500],[2640,4500]],
   plats:[[360,340,130],[640,285,110],[1005,360,80],[1330,330,150],[1560,270,120],[1735,360,70],[2060,330,130],[2300,280,110],[2530,360,80],[3000,330,130],[3250,290,130],[3750,340,130],[3980,300,110]].map(a=>({x:a[0],y:a[1],w:a[2]})),
   forgeX:2850,barrierX:3600,padX:4250,cps:[180,1900,2700],holeSpeed:105,meteorEvery:2.6,
   packs:[{x:2120,y:296},{x:3310,y:256}],enemies:[3150,3380,3880,4060].map((x,i)=>({cx:x,range:90,ph:i*1.7,spd:1.3}))};
  L.crystals=[];
  L.plats.forEach(p=>{for(let i=0;i<3;i++)L.crystals.push({x:p.x+p.w*(i+.5)/3,y:p.y-30});});
  L.segs.forEach(s=>{for(let x=Math.max(s[0],250)+80;x<s[1]-60;x+=140){if(r()<.5&&Math.abs(x-L.forgeX)>110&&Math.abs(x-L.barrierX)>110&&Math.abs(x-L.padX)>110)L.crystals.push({x,y:GY-34});}});
 } else {
  const r=rng(1000+n*77+(Math.random()*1e6|0));
  const th=ENDLESS[n%5],len=3000+Math.min(n,8)*350,segs=[],plats=[];
  let x=-800;segs.push([x,700]);x=700;
  while(x<len){const gap=95+r()*(30+Math.min(n,6)*6),sx=x+gap;let ex=sx+320+r()*380;if(len-ex<420)ex=len;segs.push([sx,ex]);plats.push({x:x+gap/2-35,y:360,w:70});x=ex;if(ex>=len)break;}
  segs.forEach(s=>{if(s[1]-s[0]>520&&s[0]>0)plats.push({x:(s[0]+s[1])/2-60,y:290+r()*40,w:th===TH.shatter?90:120});});
  L={kind,name:'SECTOR '+(n+1)+' — '+th.name,theme:th,L:len,startX:180,segs,plats,forgeX:null,barrierX:null,padX:len-200,cps:[180],
   holeSpeed:Math.min(170,100+n*8),meteorEvery:Math.max(1.1,2.2-n*.12),packs:[],enemies:[],crystals:[]};
  const ec=Math.min(2+n,10);
  for(let i=0;i<ec;i++){const s=segs[1+Math.floor(r()*(segs.length-1))];if(s[1]-s[0]>260&&s[0]>800)L.enemies.push({cx:s[0]+130+r()*(s[1]-s[0]-260),range:60+r()*70,ph:r()*6,spd:1.2+r()*.8+(th===TH.horizon?.8:0)});}
  plats.forEach(p=>{for(let i=0;i<3;i++)L.crystals.push({x:p.x+p.w*(i+.5)/3,y:p.y-30});});
  segs.forEach(s=>{for(let x=Math.max(s[0],300)+90;x<s[1]-60;x+=150)if(r()<.4)L.crystals.push({x,y:GY-34});});
  if(n%2===1&&plats.length>3){const p=plats[2];L.packs.push({x:p.x+p.w/2,y:p.y-30});}
 }
 L.crystals.forEach(c=>c.got=false);L.packs.forEach(c=>c.got=false);
 L.enemies.forEach(e=>{e.hp=2;e.dead=false;e.hitT=0;e.sx=e.cx;e.sy=GY-74;e.dir=1;e.swing=-1;});
 L.solids=L.segs.map(s=>({x0:s[0],x1:s[1],y:GY})).concat(L.plats.map(p=>({x0:p.x,x1:p.x+p.w,y:p.y})));
 return L;
}

/* ---------- state ---------- */
const G={scene:'title',t:0,menu:0,char:'female',mx:-1,my:-1,cam:0,hx:-600,shake:0,fade:1,toast:null,meteors:[],muted:false,
 mode:'story',sector:0,crystals:0,kills:0,time:0,distBase:0,hasSword:false,forgeDone:false,barrierAlive:true,cp:0,introT:0,podBroken:false,lt:0,deadT:0,deadWhy:'',pz:null,lvl:null,p:null,safe:null,meteorT:3,hint:6,world:0,hasBlaster:false,hasShield:false,hasLance:false,boss:null,ep:[],bolts:[],logs:0,chg:0,shT:0,shCd:0,bolCd:0,reveal:null,revealT:0};

let UI=[];
function newPlayer(x){return{x,y:GY-48,w:28,h:48,vx:0,vy:0,face:1,on:true,coy:0,buf:0,dashT:0,dashCd:0,dashDir:1,dashAir:false,atkT:0,atkCd:0,hp:5,inv:0,jumping:false,sol:null,anim:0};}
function loadLevel(L,intro){G.lvl=L;G.p=newPlayer(L.startX);G.hx=L.startX-780;G.meteors=[];P.length=0;G.cp=0;G.cam=0;G.safe={x:L.startX,y:GY-48};G.introT=intro?2.6:0;G.podBroken=!intro;G.meteorT=5;G.hint=8;G.barrierAlive=true;G.ep=[];G.bolts=[];G.chg=0;G.shT=0;G.logs=0;G.boss=L.boss?mkBoss(L):null;if(L.kind==='story')G.forgeDone=!L.forgeX;G.pz=null;
 G.toast={a:L.name,b:L.sub||(L.kind==='story'?'Outrun the Devourer. Find the energy forge.':'Reach the beacon before the Devourer does.'),t:3.8};}
function setWeapons(w){G.hasSword=w>=1;G.hasBlaster=w>=3;G.hasShield=w>=4;G.hasLance=w>=5;}
function startStory(w){w=(typeof w==='number')?w:0;G.mode='story';G.world=w;G.sector=0;G.crystals=0;G.kills=0;G.time=0;G.distBase=0;setWeapons(w);loadLevel(mkLevel('story',w),w===0);G.scene='play';G.fade=1;SFX.click();store('eh_save',{world:w});}
function nextWorld(){const w=G.world+1;G.world=w;setWeapons(w);loadLevel(mkLevel('story',w),false);G.scene='play';G.fade=1;store('eh_save',{world:w});}
function startEndless(){G.mode='endless';G.sector=0;G.crystals=0;G.kills=0;G.time=0;G.distBase=0;G.hasSword=G.hasBlaster=G.hasShield=G.hasLance=true;G.forgeDone=true;loadLevel(mkLevel('endless',0),false);G.scene='play';G.fade=1;SFX.click();}
function respawnCP(){const L=G.lvl,cx=L.cps[G.cp]||L.startX,p=G.p;Object.assign(p,{x:cx,y:GY-48,vx:0,vy:0,hp:5,inv:1.5,dashT:0,atkT:0});G.hx=cx-780;G.meteors=[];G.ep=[];G.bolts=[];G.chg=0;G.safe={x:cx,y:GY-48};G.meteorT=3;G.scene='play';}
function getDist(){return G.distBase+Math.max(0,G.p.x);}
function saveBest(){const b=store('eh_best')||{dist:0,sector:0};b.dist=Math.max(b.dist,Math.floor(getDist()/10));if(G.mode==='endless')b.sector=Math.max(b.sector,G.sector+1);store('eh_best',b);}

/* ---------- background ---------- */
function ridge(cam,f,base,amp,col,s){ctx.fillStyle=col;ctx.beginPath();ctx.moveTo(-10,H);for(let x=-10;x<=W+10;x+=12){const wx=x+cam*f;ctx.lineTo(x,base-amp*(.5+.5*Math.sin(wx*.004+s))-amp*.4*Math.sin(wx*.011+s*2)+Math.sin(wx*.05)*3);}ctx.lineTo(W+10,H);ctx.closePath();ctx.fill();}
function drawBG(th,cam,t){
 const g=ctx.createLinearGradient(0,0,0,H);g.addColorStop(0,th.sky[0]);g.addColorStop(1,th.sky[1]);ctx.fillStyle=g;ctx.fillRect(-20,-20,W+40,H+40);
 for(let i=0;i<4;i++){const nx=mod(i*420-cam*.04,W+700)-350,ny=120+(i%2)*200+Math.sin(t*.1+i)*10;const gr=ctx.createRadialGradient(nx,ny,10,nx,ny,330);gr.addColorStop(0,th.neb[i%2]);gr.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=gr;ctx.fillRect(nx-330,ny-330,660,660);}
 for(let l=0;l<3;l++){const f=[.02,.06,.12][l];ctx.fillStyle='#fff';for(const s of STARS[l]){const x=mod(s.x-cam*f,W+40)-20;ctx.globalAlpha=(.35+.65*(.5+.5*Math.sin(t*s.sp+s.ph)))*(l===0?.6:1);ctx.fillRect(x,s.y,s.r,s.r);}}
 ctx.globalAlpha=1;
 const px=720-cam*.05,py=140,pg=ctx.createRadialGradient(px-20,py-20,6,px,py,66);pg.addColorStop(0,th.planet);pg.addColorStop(1,'#10081f');ctx.fillStyle=pg;ctx.beginPath();ctx.arc(px,py,64,0,6.283);ctx.fill();
 ctx.strokeStyle='rgba(255,255,255,.18)';ctx.lineWidth=3;ctx.beginPath();ctx.ellipse(px,py,106,20,-.35,0,6.283);ctx.stroke();
 ridge(cam,.18,330,70,th.m1,1);ridge(cam,.34,385,60,th.m2,2.7);
}
function drawGround(L,cam,th){
 for(const s of L.segs){if(s[1]<cam-30||s[0]>cam+W+30)continue;const x0=s[0]-cam,x1=s[1]-cam;
  const g=ctx.createLinearGradient(0,GY,0,H);g.addColorStop(0,th.rock[0]);g.addColorStop(1,th.rock[1]);ctx.fillStyle=g;
  ctx.beginPath();ctx.moveTo(x0,GY);ctx.lineTo(x1,GY);ctx.lineTo(x1,GY+30);ctx.lineTo(x1-10,GY+60);ctx.lineTo(x1-2,GY+90);ctx.lineTo(x1-16,H+2);ctx.lineTo(x0+16,H+2);ctx.lineTo(x0+2,GY+90);ctx.lineTo(x0+10,GY+60);ctx.lineTo(x0,GY+30);ctx.closePath();ctx.fill();
  ctx.strokeStyle='rgba(0,0,0,.35)';ctx.lineWidth=2;const r=rng(Math.floor(s[0])+5);ctx.beginPath();for(let i=0;i<8;i++){const cx=x0+r()*(x1-x0),cy=GY+20+r()*70;ctx.moveTo(cx,cy);ctx.lineTo(cx+r()*40-20,cy+r()*30);}ctx.stroke();
  ctx.fillStyle=th.rock[0];for(let x=Math.max(x0,-20);x<Math.min(x1,W+20);x+=70){const h=3+((Math.floor((x+cam)/70)*37)%7);rr(x+6,GY-h,20,h,3);ctx.fill();}
  ctx.strokeStyle=th.rim;ctx.globalAlpha=.25;ctx.lineWidth=9;ctx.beginPath();ctx.moveTo(x0,GY);ctx.lineTo(x1,GY);ctx.stroke();ctx.globalAlpha=1;ctx.lineWidth=3;ctx.stroke();}
 for(const p of L.plats){if(p.x+p.w<cam-20||p.x>cam+W+20)continue;const x=p.x-cam,g=ctx.createLinearGradient(0,p.y,0,p.y+18);g.addColorStop(0,th.rock[0]);g.addColorStop(1,th.rock[1]);
  const gl=ctx.createRadialGradient(x+p.w/2,p.y+22,2,x+p.w/2,p.y+22,p.w*.6);gl.addColorStop(0,th.rim+'66');gl.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=gl;ctx.fillRect(x-20,p.y,p.w+40,70);
  ctx.fillStyle=g;rr(x,p.y,p.w,16,5);ctx.fill();ctx.strokeStyle=th.rim;ctx.lineWidth=3;ctx.beginPath();ctx.moveTo(x+3,p.y+1);ctx.lineTo(x+p.w-3,p.y+1);ctx.stroke();}
}
