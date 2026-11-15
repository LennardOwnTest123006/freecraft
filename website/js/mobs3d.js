/* FreeCraft – Mob-Drehansicht. Echte Spiel-Aufnahmen (16 Winkel), weich überblendet, mit Trägheit. */
(function(){
"use strict";
var view=document.getElementById("mobViewer");
if(!view)return;
var box=view.querySelector(".mobimgs");
var N=16,NAMES=["cow","pig","sheep","chicken","horse","wolf","villager","iron_golem","zombie","spider"];
var reduce=window.matchMedia&&matchMedia("(prefers-reduced-motion: reduce)").matches;
var cache={},imgs=[],cur=-1,ang=0,vel=0,drag=false,lx=0,lt=0,idle=9,visible=true,last=performance.now(),shown=[-1,-1];
function src(m,k){return "img/mobs/"+m+"_"+(k<10?"0":"")+k+".webp?v=14"}
function load(m){
  if(cache[m])return cache[m];
  var a=[];for(var k=0;k<N;k++){var im=new Image();im.decoding="async";im.alt="";im.width=480;im.height=450;im.draggable=false;im.src=src(m,k);im.style.opacity=0;a.push(im)}
  return cache[m]=a;
}
function show(i){
  if(i===cur)return;cur=i;
  imgs=load(NAMES[i]);
  box.textContent="";imgs.forEach(function(im){im.style.opacity=0;box.appendChild(im)});
  ang=0;vel=0;idle=0;shown=[-1,-1];
}
function frame(now){
  requestAnimationFrame(frame);
  var dt=Math.min(.05,(now-last)/1000);last=now;
  if(!visible||!imgs.length)return;
  if(!drag){
    idle+=dt;ang+=vel*dt;vel*=Math.pow(.05,dt);
    if(idle>1.4&&!reduce)vel+=(1.1-vel)*Math.min(1,dt*1.5);
  }
  var a=((ang%N)+N)%N,i0=Math.floor(a),f=a-i0,i1=(i0+1)%N;
  var g=Math.max(0,Math.min(1,(f-0.3)/0.4));g=g*g*(3-2*g);
  for(var k=0;k<N;k++){imgs[k].style.opacity=0}
  imgs[i0].style.opacity=1;if(g>0.004)imgs[i1].style.opacity=g;
}
function down(e){drag=true;idle=0;vel=0;lx=e.clientX;lt=performance.now();try{view.setPointerCapture(e.pointerId)}catch(x){}}
function move(e){
  if(!drag)return;
  var now=performance.now(),dx=e.clientX-lx,dt=Math.max(8,now-lt)/1000,d=-dx*0.032;
  ang+=d;vel=vel*0.5+(d/dt)*0.5;lx=e.clientX;lt=now;
}
function up(){drag=false;idle=0;vel=Math.max(-14,Math.min(14,vel))}
view.addEventListener("pointerdown",down);view.addEventListener("pointermove",move);
view.addEventListener("pointerup",up);view.addEventListener("pointercancel",up);
view.addEventListener("keydown",function(e){if(e.key==="ArrowLeft"){vel+=3;idle=0}if(e.key==="ArrowRight"){vel-=3;idle=0}});
if("IntersectionObserver" in window){new IntersectionObserver(function(es){visible=es[0].isIntersecting;if(visible&&cur<0)show(0)},{rootMargin:"200px"}).observe(view)}
window.FCMobs={names:NAMES,set:show,thumb:function(i){return "img/mobs/"+NAMES[i]+"_00.webp?v=14"}};
requestAnimationFrame(frame);
})();
