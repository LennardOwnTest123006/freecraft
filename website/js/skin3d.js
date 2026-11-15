/* FreeCraft – WebGL-Viewer für Spieler-Skins (64x32). Keine Abhängigkeiten.
   Weiche Drehung mit Trägheit, sanfte Geh-Animation, Kopfbewegung, Schatten per CSS. */
(function(){
"use strict";
var canvas=document.getElementById("skinCanvas");
if(!canvas)return;
var viewer=document.getElementById("skinViewer")||canvas.parentNode;
var gl=canvas.getContext("webgl",{alpha:true,antialias:true,premultipliedAlpha:false})||canvas.getContext("experimental-webgl");
if(!gl){viewer.style.display="none";return}
var reduce=window.matchMedia&&matchMedia("(prefers-reduced-motion: reduce)").matches;

/* ---------- Mathe ---------- */
function persp(f,a,n,r){var t=1/Math.tan(f/2),m=new Float32Array(16);m[0]=t/a;m[5]=t;m[10]=(r+n)/(n-r);m[11]=-1;m[14]=2*r*n/(n-r);return m}
function mul(a,b){var o=new Float32Array(16);for(var i=0;i<4;i++)for(var j=0;j<4;j++){var s=0;for(var k=0;k<4;k++)s+=a[k*4+j]*b[i*4+k];o[i*4+j]=s}return o}
function ident(){var m=new Float32Array(16);m[0]=m[5]=m[10]=m[15]=1;return m}
function trans(x,y,z){var m=ident();m[12]=x;m[13]=y;m[14]=z;return m}
function rotX(a){var m=ident(),c=Math.cos(a),s=Math.sin(a);m[5]=c;m[6]=s;m[9]=-s;m[10]=c;return m}
function rotY(a){var m=ident(),c=Math.cos(a),s=Math.sin(a);m[0]=c;m[2]=-s;m[8]=s;m[10]=c;return m}

/* ---------- Shader ---------- */
function sh(t,src){var s=gl.createShader(t);gl.shaderSource(s,src);gl.compileShader(s);return s}
var prog=gl.createProgram();
gl.attachShader(prog,sh(gl.VERTEX_SHADER,"attribute vec3 p;attribute vec2 t;attribute float l;uniform mat4 mvp;varying vec2 vt;varying float vl;void main(){vt=t;vl=l;gl_Position=mvp*vec4(p,1.0);}"));
gl.attachShader(prog,sh(gl.FRAGMENT_SHADER,"precision mediump float;varying vec2 vt;varying float vl;uniform sampler2D tex;void main(){vec4 c=texture2D(tex,vt);if(c.a<0.5)discard;gl_FragColor=vec4(c.rgb*(0.28+0.78*vl),1.0);}"));
gl.linkProgram(prog);gl.useProgram(prog);
var aP=gl.getAttribLocation(prog,"p"),aT=gl.getAttribLocation(prog,"t"),aL=gl.getAttribLocation(prog,"l"),uM=gl.getUniformLocation(prog,"mvp");

/* ---------- Modell: Quader mit Skin-UVs ---------- */
var TW=64,TH=32;
function boxFaces(w,h,d,u,v,mirror,grow){
  var g=grow||0,W=w+2*g,H=h+2*g,D=d+2*g,x=W/2,y=H/2,z=D/2;
  var R=[u,v+d,d,h],F=[u+d,v+d,w,h],L=[u+d+w,v+d,d,h],B=[u+2*d+w,v+d,w,h],T=[u+d,v,w,d],Bo=[u+d+w,v,w,d];
  if(mirror){var tmp=R;R=L;L=tmp}
  return [
    {o:[-x,y,z],  a:[W,0,0], b:[0,-H,0], r:F, l:.95, m:mirror},
    {o:[x,y,-z],  a:[-W,0,0],b:[0,-H,0], r:B, l:.78, m:mirror},
    {o:[-x,y,-z], a:[0,0,D], b:[0,-H,0], r:R, l:.66, m:mirror},
    {o:[x,y,z],   a:[0,0,-D],b:[0,-H,0], r:L, l:.66, m:mirror},
    {o:[-x,y,-z], a:[W,0,0], b:[0,0,D],  r:T, l:1.0, m:mirror},
    {o:[-x,-y,z], a:[W,0,0], b:[0,0,-D], r:Bo,l:.45, m:mirror}
  ];
}
function build(pt){
  var data=[];
  boxFaces(pt.w,pt.h,pt.d,pt.u,pt.v,pt.mirror,pt.grow).forEach(function(f){
    var r=f.r,u0=r[0]/TW,v0=r[1]/TH,u1=(r[0]+r[2])/TW,v1=(r[1]+r[3])/TH;
    if(f.m){var s=u0;u0=u1;u1=s}
    var c=[[0,0,u0,v0],[1,0,u1,v0],[1,1,u1,v1],[0,1,u0,v1]];
    [0,1,2,0,2,3].forEach(function(i){var k=c[i];
      data.push(f.o[0]+f.a[0]*k[0]+f.b[0]*k[1]+pt.cx,f.o[1]+f.a[1]*k[0]+f.b[1]*k[1]+pt.cy,f.o[2]+f.a[2]*k[0]+f.b[2]*k[1]+pt.cz,k[2],k[3],f.l)});
  });
  return new Float32Array(data);
}
var defs=[
 {n:"head", w:8,h:8,d:8, u:0, v:0, cx:0, cy:28,cz:0, py:24},
 {n:"hat",  w:8,h:8,d:8, u:32,v:0, cx:0, cy:28,cz:0, py:24, grow:.5},
 {n:"body", w:8,h:12,d:4,u:16,v:16,cx:0, cy:18,cz:0},
 {n:"rarm", w:4,h:12,d:4,u:40,v:16,cx:-6,cy:18,cz:0, px:-6,py:24},
 {n:"larm", w:4,h:12,d:4,u:40,v:16,cx:6, cy:18,cz:0, px:6, py:24, mirror:true},
 {n:"rleg", w:4,h:12,d:4,u:0, v:16,cx:-2,cy:6, cz:0, px:-2,py:12},
 {n:"lleg", w:4,h:12,d:4,u:0, v:16,cx:2, cy:6, cz:0, px:2, py:12, mirror:true}
];
defs.forEach(function(d){d.buf=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,d.buf);gl.bufferData(gl.ARRAY_BUFFER,build(d),gl.STATIC_DRAW)});

/* ---------- Textur ---------- */
var tex=gl.createTexture(),loaded=false,imgs={},cur=0;
function setSkin(img){
  gl.bindTexture(gl.TEXTURE_2D,tex);
  gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA,gl.RGBA,gl.UNSIGNED_BYTE,img);
  [[gl.TEXTURE_MIN_FILTER,gl.NEAREST],[gl.TEXTURE_MAG_FILTER,gl.NEAREST],[gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE],[gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE]].forEach(function(p){gl.texParameteri(gl.TEXTURE_2D,p[0],p[1])});
  loaded=true;
}
function loadSkin(n,cb){
  if(imgs[n]){cb(imgs[n]);return}
  var im=new Image();im.onload=function(){imgs[n]=im;cb(im)};im.src="img/skins/skin"+n+".png?v=16";
}

/* ---------- Zeichnen & Eingabe ---------- */
var yaw=-0.6,vel=0,pitch=0.1,pitchT=0.1,drag=false,lx=0,ly=0,lt=0,idle=9,last=performance.now(),visible=true,amp=0.55,ampT=0.55,walkT=0,appear=0;
function resize(){
  var dpr=Math.min(window.devicePixelRatio||1,2),w=viewer.clientWidth,h=viewer.clientHeight;
  var W=Math.round(w*dpr),H=Math.round(h*dpr);
  if(canvas.width!==W||canvas.height!==H){canvas.width=W;canvas.height=H}
}
function frame(now){
  requestAnimationFrame(frame);
  var dt=Math.min(.05,(now-last)/1000);last=now;
  if(!loaded||!visible)return;
  resize();
  if(!drag){
    idle+=dt;
    yaw+=vel*dt;vel*=Math.pow(.04,dt);               // Trägheit
    if(idle>1.4&&!reduce){vel+=(0.55-vel)*Math.min(1,dt*1.6)}  // sanft wieder drehen
    pitch+=(pitchT-pitch)*Math.min(1,dt*3);
  }
  ampT=drag?0.25:(reduce?0:0.55);amp+=(ampT-amp)*Math.min(1,dt*4);
  walkT+=dt*(2.2+Math.abs(vel)*0.6);
  appear=Math.min(1,appear+dt*2.4);
  var ease=1-Math.pow(1-appear,3);
  gl.viewport(0,0,canvas.width,canvas.height);
  gl.clearColor(0,0,0,0);gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);
  gl.enable(gl.DEPTH_TEST);gl.disable(gl.CULL_FACE);
  var asp=canvas.width/canvas.height;
  var fov=0.5,dist=asp<0.9?150:122;
  var proj=persp(fov,asp,1,500);
  var view=mul(trans(0,-1.5,-dist),mul(rotX(pitch),mul(rotY(yaw),mul(trans(0,-16,0),mul(trans(0,16,0),mul(rotY(0),trans(0,-16+(1-ease)*-6,0)))))));
  gl.activeTexture(gl.TEXTURE0);gl.bindTexture(gl.TEXTURE_2D,tex);
  var sw=Math.sin(walkT)*amp,bob=Math.abs(Math.cos(walkT))*0.35*amp;
  defs.forEach(function(d){
    var m;
    if(d.n==="rarm")m=mul(trans(d.px,d.py,0),mul(rotX(sw),trans(-d.px,-d.py,0)));
    else if(d.n==="larm")m=mul(trans(d.px,d.py,0),mul(rotX(-sw),trans(-d.px,-d.py,0)));
    else if(d.n==="rleg")m=mul(trans(d.px,d.py,0),mul(rotX(-sw*0.9),trans(-d.px,-d.py,0)));
    else if(d.n==="lleg")m=mul(trans(d.px,d.py,0),mul(rotX(sw*0.9),trans(-d.px,-d.py,0)));
    else if(d.n==="head"||d.n==="hat")m=mul(trans(0,d.py,0),mul(rotY(Math.sin(walkT*0.5)*0.22*(amp+.15)),trans(0,-d.py,0)));
    else m=ident();
    m=mul(trans(0,bob,0),m);
    gl.uniformMatrix4fv(uM,false,mul(proj,mul(view,m)));
    gl.bindBuffer(gl.ARRAY_BUFFER,d.buf);
    gl.enableVertexAttribArray(aP);gl.vertexAttribPointer(aP,3,gl.FLOAT,false,24,0);
    gl.enableVertexAttribArray(aT);gl.vertexAttribPointer(aT,2,gl.FLOAT,false,24,12);
    gl.enableVertexAttribArray(aL);gl.vertexAttribPointer(aL,1,gl.FLOAT,false,24,20);
    gl.drawArrays(gl.TRIANGLES,0,36);
  });
}
function down(e){drag=true;idle=0;vel=0;lx=e.clientX;ly=e.clientY;lt=performance.now();try{viewer.setPointerCapture(e.pointerId)}catch(x){}}
function move(e){
  if(!drag)return;
  var now=performance.now(),dx=e.clientX-lx,dt=Math.max(8,now-lt)/1000;
  yaw+=dx*0.011;vel=vel*0.5+(dx*0.011/dt)*0.5;
  pitch=Math.max(-0.35,Math.min(0.55,pitch+(e.clientY-ly)*0.004));pitchT=Math.max(0.0,Math.min(0.25,pitch));
  lx=e.clientX;ly=e.clientY;lt=now;
}
function up(){drag=false;idle=0;vel=Math.max(-9,Math.min(9,vel))}
viewer.addEventListener("pointerdown",down);viewer.addEventListener("pointermove",move);
viewer.addEventListener("pointerup",up);viewer.addEventListener("pointercancel",up);
viewer.addEventListener("keydown",function(e){if(e.key==="ArrowLeft"){vel-=2.2;idle=0}if(e.key==="ArrowRight"){vel+=2.2;idle=0}});
if("IntersectionObserver" in window){new IntersectionObserver(function(es){visible=es[0].isIntersecting}).observe(viewer)}

/* ---------- Auswahl ---------- */
window.FCSkin3D={
  count:8,
  set:function(n){cur=n;appear=0;loadSkin(n,setSkin)},
  thumb:function(n,cb){loadSkin(n,function(im){
    var c=document.createElement("canvas");c.width=c.height=48;var x=c.getContext("2d");x.imageSmoothingEnabled=false;
    x.drawImage(im,8,8,8,8,0,0,48,48);x.drawImage(im,40,8,8,8,0,0,48,48);cb(c)})}
};
FCSkin3D.set(1);
requestAnimationFrame(frame);
})();
