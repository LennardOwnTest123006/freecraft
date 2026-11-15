/* FreeCraft – Intro, 3D-Voxel-Würfel und Scroll-Effekte (GSAP). Respektiert prefers-reduced-motion. */
(function(){
"use strict";
var reduce=matchMedia("(prefers-reduced-motion:reduce)").matches;
var coarse=matchMedia("(pointer:coarse)").matches;
var small=innerWidth<700;

/* --- kleine Pixel-Texturen (nearest) --- */
function rnd(seed){var s=seed;return function(){s=(s*16807)%2147483647;return s/2147483647}}
function tex(base,vary,seed,spots){
  var c=document.createElement("canvas");c.width=c.height=8;var x=c.getContext("2d"),r=rnd(seed);
  for(var i=0;i<8;i++)for(var j=0;j<8;j++){
    var d=(r()-.5)*vary,col=base.map(function(v){return Math.max(0,Math.min(255,Math.round(v+d)))});
    x.fillStyle="rgb("+col+")";x.fillRect(i,j,1,1);
  }
  if(spots){x.fillStyle=spots;[[2,2],[5,2],[2,5],[5,5]].forEach(function(p){x.fillRect(p[0],p[1],1,1)})}
  return c.toDataURL();
}
var T={
  top:tex([43,196,222],40,11),
  side:tex([58,63,166],36,23,"#ffc83d"),
  sun:tex([255,200,61],34,5),
  grass:tex([47,158,79],40,9),
  dirt:tex([122,84,52],34,13),
  dark:tex([20,38,74],24,17)
};
var SETS=[["top","side","side"],["sun","sun","sun"],["grass","dirt","dirt"],["top","top","top"],["dark","side","dark"]];
function cube(size,set){
  var e=document.createElement("div");e.className="cube";e.style.setProperty("--s",size+"px");
  var s=SETS[set%SETS.length];
  [["ft",1],["bk",1],["rt",1],["lf",1],["tp",0],["bt",2]].forEach(function(f){
    var i=document.createElement("i");i.className=f[0];i.style.backgroundImage="url("+T[s[f[1]]]+")";e.appendChild(i);
  });
  return e;
}

/* --- Intro --- */
function intro(done){
  if(reduce||!window.gsap){done();return}
  var g=gsap,el=document.createElement("div");el.id="intro";el.setAttribute("aria-hidden","true");
  el.innerHTML='<img class="ilogo" src="img/jumpin.webp" width="512" height="512" alt=""><div class="iscene"></div><div class="ibar"><b></b></div><button class="iskip" type="button" tabindex="-1">Skip ›</button>';
  document.body.appendChild(el);document.body.classList.add("introing");
  var sc=el.querySelector(".iscene"),size=small?96:130,cb=cube(size,0);cb.style.left=-size/2+"px";cb.style.top=-size/2+"px";sc.appendChild(cb);
  var finished=false;
  function end(){
    if(finished)return;finished=true;
    document.body.classList.remove("introing");el.remove();done();
  }
  g.set(".ilogo",{opacity:0,scale:.7,y:20});g.set(cb,{scale:.01,rotationX:-25,rotationY:-200});
  var tl=g.timeline({onComplete:end});
  tl.to(".ilogo",{opacity:1,scale:1,y:0,duration:.7,ease:"back.out(1.6)"})
    .to(".ibar b",{scaleX:1,duration:2.1,ease:"power1.inOut"},0)
    .to(".ilogo",{opacity:0,scale:.8,y:-24,duration:.45,ease:"power2.in"},1.0)
    .to(cb,{scale:1,rotationY:340,duration:1.1,ease:"power3.out"},1.15)
    .to(cb,{rotationX:-18,rotationY:405,duration:.6,ease:"power2.inOut"},2.15)
    .to(".ibar",{opacity:0,duration:.3},2.4)
    .to(cb,{scale:14,duration:.75,ease:"power3.in"},2.7)
    .to(el,{opacity:0,duration:.45,ease:"power1.out"},3.0);
  el.querySelector(".iskip").addEventListener("click",function(){tl.progress(.97)});
  addEventListener("keydown",function k(e){if(e.key==="Escape"||e.key==="Enter"){tl.progress(.97);removeEventListener("keydown",k)}});
  setTimeout(end,6500);
}

/* --- Effekte nach dem Intro --- */
function fx(){
  if(reduce||!window.gsap)return;
  var g=gsap,ST=window.ScrollTrigger;if(!ST)return;g.registerPlugin(ST);

  /* Fortschrittsbalken */
  var prog=document.createElement("div");prog.id="prog";prog.setAttribute("aria-hidden","true");document.body.appendChild(prog);
  g.to(prog,{scaleX:1,ease:"none",scrollTrigger:{start:0,end:"max",scrub:.2}});

  /* schwebende Würfel */
  function field(host,n,seedOff){
    var box=document.createElement("div");box.className="fx-cubes";box.setAttribute("aria-hidden","true");host.insertBefore(box,host.querySelector(".hero-panel,.wrap"));
    var cubes=[],r=rnd(7+seedOff);
    for(var i=0;i<n;i++){
      var d=.35+r()*.9,size=Math.round((small?18:26)+r()*(small?30:56)*d),c=cube(size,Math.floor(r()*5));
      var left=small?(r()*88):(i%2?(62+r()*34):(r()*34));
      c.style.left=left+"%";c.style.top=(small&&host.id==="hero"?(4+r()*26):(8+r()*78))+"%";c.style.opacity=(.55+d*.35).toFixed(2);
      box.appendChild(c);cubes.push({c:c,d:d});
      g.set(c,{rotationX:r()*360,rotationY:r()*360,z:(d-.7)*260});
      g.to(c,{rotationY:"+=360",rotationX:"+="+(r()>.5?360:-360),duration:14+r()*16,repeat:-1,ease:"none"});
      g.to(c,{y:(r()>.5?-1:1)*(14+r()*22),duration:3+r()*3,yoyo:true,repeat:-1,ease:"sine.inOut"});
    }
    ST.create({trigger:host,start:"top bottom",end:"bottom top",scrub:true,onUpdate:function(s){
      cubes.forEach(function(o){g.set(o.c,{yPercent:(s.progress-.5)*-90*o.d})});
    }});
    if(!coarse){
      host.addEventListener("pointermove",function(e){
        var nx=e.clientX/innerWidth-.5,ny=e.clientY/innerHeight-.5;
        cubes.forEach(function(o){g.to(o.c,{x:nx*-70*o.d,overwrite:"auto",duration:1.1,ease:"power3"})});
      });
    }
  }
  var hero=document.getElementById("hero");if(hero)field(hero,small?7:14,0);
  var fin=document.querySelector(".final");if(fin)field(fin,small?6:12,9);

  /* Hero-Panel kippt mit Zeigerbewegung / Neigung */
  var panel=document.getElementById("heroPanel");
  if(panel){
    g.set(panel,{transformPerspective:1100});
    var rx=g.quickTo(panel,"rotationX",{duration:.8,ease:"power3"}),ry=g.quickTo(panel,"rotationY",{duration:.8,ease:"power3"});
    if(!coarse){hero.addEventListener("pointermove",function(e){ry((e.clientX/innerWidth-.5)*7);rx((e.clientY/innerHeight-.5)*-5)})}
    else if(window.DeviceOrientationEvent&&typeof DeviceOrientationEvent.requestPermission!=="function"){
      addEventListener("deviceorientation",function(e){if(e.gamma==null)return;ry(Math.max(-8,Math.min(8,e.gamma/5)));rx(Math.max(-6,Math.min(6,((e.beta||0)-50)/-8)))},{passive:true});
    }
    g.to(panel,{y:-60,opacity:.2,scale:.96,ease:"none",scrollTrigger:{trigger:hero,start:"60% top",end:"bottom top",scrub:true}});
  }

  /* Überschriften kippen herein */
  g.utils.toArray(".sec-h").forEach(function(h){
    g.from(h,{rotationX:-40,y:36,opacity:0,transformPerspective:800,transformOrigin:"50% 100%",duration:.9,ease:"power3.out",scrollTrigger:{trigger:h,start:"top 88%",once:true}});
  });
  /* Karten: 3D-Auftritt + Tilt */
  ST.batch(".bento>*,.steps li,.req",{start:"top 90%",once:true,onEnter:function(b){
    g.fromTo(b,{rotationY:-28,rotationX:12,y:56,opacity:0,z:-120,transformPerspective:900},{rotationY:0,rotationX:0,y:0,opacity:1,z:0,duration:.9,stagger:.09,ease:"power3.out",clearProps:"opacity"});
  }});
  if(!coarse){
    g.utils.toArray(".bento>*,.req").forEach(function(c){
      c.addEventListener("pointermove",function(e){
        var r=c.getBoundingClientRect(),px=(e.clientX-r.left)/r.width-.5,py=(e.clientY-r.top)/r.height-.5;
        g.to(c,{rotationY:px*10,rotationX:py*-10,transformPerspective:800,duration:.35,ease:"power2.out",overwrite:"auto"});
      });
      c.addEventListener("pointerleave",function(){g.to(c,{rotationY:0,rotationX:0,duration:.6,ease:"power3.out",overwrite:"auto"})});
    });
  }
  /* Screenshot-Bühne und Viewer legen sich aus der Tiefe an */
  g.fromTo("#stage",{rotationX:16,y:50,transformPerspective:1200,transformOrigin:"50% 100%",scale:.92},{rotationX:0,y:0,scale:1,ease:"none",scrollTrigger:{trigger:"#stage",start:"top 100%",end:"top 40%",scrub:true}});
  g.utils.toArray(".viewer").forEach(function(v,i){
    g.fromTo(v,{rotationY:i?-14:14,x:i?-40:40,opacity:.2,transformPerspective:1000},{rotationY:0,x:0,opacity:1,ease:"none",scrollTrigger:{trigger:v,start:"top 105%",end:"top 55%",scrub:true}});
  });
  /* Sprach-Reihen driften beim Scrollen */
  g.utils.toArray(".langs .row").forEach(function(r,i){
    g.to(r,{xPercent:i?6:-6,ease:"none",scrollTrigger:{trigger:".langs",start:"top bottom",end:"bottom top",scrub:true}});
  });
  /* Download-Button pulsiert beim Erscheinen */
  g.from("#dl2",{scale:.8,rotationX:30,opacity:0,transformPerspective:700,duration:.9,ease:"back.out(1.7)",scrollTrigger:{trigger:"#dl2",start:"top 92%",once:true}});

  /* Scroll-Würfel */
  var b=document.createElement("button");b.id="vxTop";b.type="button";b.setAttribute("aria-label","Top");
  var c=cube(32,1);b.appendChild(c);document.body.appendChild(b);
  g.set(c,{rotationX:-24,rotationY:20});
  ST.create({start:0,end:"max",onUpdate:function(s){
    g.set(c,{rotationY:20+s.progress*1080,rotationX:-24+Math.sin(s.progress*12)*14});
    b.classList.toggle("on",scrollY>innerHeight*.7);
  }});
  b.addEventListener("click",function(){scrollTo({top:0,behavior:"smooth"})});
}

window.FCIntro=function(cb){intro(function(){cb();fx()})};
})();
