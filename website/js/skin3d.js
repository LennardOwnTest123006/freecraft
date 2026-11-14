/* FreeCraft – kleiner WebGL-Viewer für Spieler-Skins (64x32). Keine Abhängigkeiten. */
(function(){
"use strict";
var canvas=document.getElementById("skinCanvas");
if(!canvas)return;
var gl=canvas.getContext("webgl",{alpha:true,antialias:true,premultipliedAlpha:false})||canvas.getContext("experimental-webgl");
var viewer=canvas.parentNode;
if(!gl){viewer.style.display="none";return}

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
gl.attachShader(prog,sh(gl.FRAGMENT_SHADER,"precision mediump float;varying vec2 vt;varying float vl;uniform sampler2D tex;uniform float gamma;void main(){vec4 c=texture2D(tex,vt);if(c.a<0.5)discard;gl_FragColor=vec4(c.rgb*vl*gamma,1.0);}"));
gl.linkProgram(prog);gl.useProgram(prog);
var aP=gl.getAttribLocation(prog,"p"),aT=gl.getAttribLocation(prog,"t"),aL=gl.getAttribLocation(prog,"l");
var uM=gl.getUniformLocation(prog,"mvp"),uG=gl.getUniformLocation(prog,"gamma");

/* ---------- Modell: Quader mit Skin-UVs ---------- */
var TW=64,TH=32;
// Flächen: Ursprung (obere linke Ecke), u-Achse, v-Achse (Textur nach unten), Textur-Rechteck, Licht
function boxFaces(w,h,d,u,v,mirror,grow){
  var g=grow||0,W=w+2*g,H=h+2*g,D=d+2*g,x=W/2,y=H/2,z=D/2;
  var R=[u,v+d,d,h],F=[u+d,v+d,w,h],L=[u+d+w,v+d,d,h],B=[u+2*d+w,v+d,w,h],T=[u+d,v,w,d],Bo=[u+d+w,v,w,d];
  if(mirror){var tmp=R;R=L;L=tmp}
  // Jede Fläche: [Ursprung, uAchse(Länge), vAchse(Länge), rect, licht, spiegeln]
  return [
    {o:[-x,y,z],  a:[W,0,0], b:[0,-H,0], r:F, l:.92, m:mirror},
    {o:[x,y,-z],  a:[-W,0,0],b:[0,-H,0], r:B, l:.80, m:mirror},
    {o:[-x,y,-z], a:[0,0,D], b:[0,-H,0], r:R, l:.70, m:mirror},
    {o:[x,y,z],   a:[0,0,-D],b:[0,-H,0], r:L, l:.70, m:mirror},
    {o:[-x,y,-z], a:[W,0,0], b:[0,0,D],  r:T, l:1.0, m:mirror},
    {o:[-x,-y,z], a:[W,0,0], b:[0,0,-D], r:Bo,l:.55, m:mirror}
  ];
}
function build(parts){
  var data=[];
  parts.forEach(function(pt){
    boxFaces(pt.w,pt.h,pt.d,pt.u,pt.v,pt.mirror,pt.grow).forEach(function(f){
      var r=f.r,u0=r[0]/TW,v0=r[1]/TH,u1=(r[0]+r[2])/TW,v1=(r[1]+r[3])/TH;
      if(f.m){var s=u0;u0=u1;u1=s}
      var c=[[0,0,u0,v0],[1,0,u1,v0],[1,1,u1,v1],[0,1,u0,v1]];
      var idx=[0,1,2,0,2,3];
      idx.forEach(function(i){
        var k=c[i];
        data.push(f.o[0]+f.a[0]*k[0]+f.b[0]*k[1]+pt.cx,f.o[1]+f.a[1]*k[0]+f.b[1]*k[1]+pt.cy,f.o[2]+f.a[2]*k[0]+f.b[2]*k[1]+pt.cz,k[2],k[3],f.l);
      });
    });
  });
  return new Float32Array(data);
}
// Teile (Einheit = 1 Skin-Pixel, Füße auf y=0). pivot = Drehpunkt für die Animation.
var defs=[
 {n:"head",   w:8,h:8,d:8, u:0, v:0, cx:0,  cy:28, cz:0, px:0, py:24},
 {n:"hat",    w:8,h:8,d:8, u:32,v:0, cx:0,  cy:28, cz:0, grow:.5, px:0, py:24},
 {n:"body",   w:8,h:12,d:4,u:16,v:16,cx:0,  cy:18, cz:0, px:0, py:18},
 {n:"rarm",   w:4,h:12,d:4,u:40,v:16,cx:-6, cy:18, cz:0, px:-6,py:24},
 {n:"larm",   w:4,h:12,d:4,u:40,v:16,cx:6,  cy:18, cz:0, px:6, py:24, mirror:true},
 {n:"rleg",   w:4,h:12,d:4,u:0, v:16,cx:-2, cy:6,  cz:0, px:-2,py:12},
 {n:"lleg",   w:4,h:12,d:4,u:0, v:16,cx:2,  cy:6,  cz:0, px:2, py:12, mirror:true}
];
defs.forEach(function(d){d.buf=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,d.buf);gl.bufferData(gl.ARRAY_BUFFER,build([d]),gl.STATIC_DRAW)});

/* ---------- Textur ---------- */
var tex=gl.createTexture();
function setSkin(img){
  gl.bindTexture(gl.TEXTURE_2D,tex);
  gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA,gl.RGBA,gl.UNSIGNED_BYTE,img);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE);
  loaded=true;
}
var loaded=false,imgs={};
function loadSkin(n,cb){
  if(imgs[n]){cb(imgs[n]);return}
  var im=new Image();im.onload=function(){imgs[n]=im;cb(im)};im.src="img/skins/skin"+n+".png?v=11";
}

/* ---------- Zeichnen & Eingabe ---------- */
var yaw=-0.55,pitch=0.12,drag=false,lx=0,ly=0,auto=true,idle=0,t0=performance.now(),visible=true;
function resize(){
  var dpr=Math.min(window.devicePixelRatio||1,2),w=viewer.clientWidth,h=viewer.clientHeight;
  if(canvas.width!==Math.round(w*dpr)||canvas.height!==Math.round(h*dpr)){canvas.width=Math.round(w*dpr);canvas.height=Math.round(h*dpr)}
}
function frame(now){
  requestAnimationFrame(frame);
  if(!loaded||!visible)return;
  resize();
  var dt=(now-t0)/1000;t0=now;
  if(!drag){idle+=dt;if(idle>1.2)auto=true}
  if(auto&&!drag)yaw+=dt*0.7;
  gl.viewport(0,0,canvas.width,canvas.height);
  gl.clearColor(0,0,0,0);gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);
  gl.enable(gl.DEPTH_TEST);gl.disable(gl.CULL_FACE);
  var asp=canvas.width/canvas.height;
  var fov=asp<0.8?1.0:0.72;
  var dist=asp<0.8?96:78;
  var proj=persp(fov,asp,1,400);
  var view=mul(trans(0,0,-dist),mul(rotX(pitch),mul(rotY(yaw),trans(0,-16,0))));
  gl.activeTexture(gl.TEXTURE0);gl.bindTexture(gl.TEXTURE_2D,tex);
  gl.uniform1f(uG,1.0);
  var sw=Math.sin(now/520)*0.5;
  defs.forEach(function(d){
    var m=ident();
    if(d.n==="rarm")m=mul(trans(d.px,d.py,0),mul(rotX(sw),trans(-d.px,-d.py,0)));
    else if(d.n==="larm")m=mul(trans(d.px,d.py,0),mul(rotX(-sw),trans(-d.px,-d.py,0)));
    else if(d.n==="rleg")m=mul(trans(d.px,d.py,0),mul(rotX(-sw*0.9),trans(-d.px,-d.py,0)));
    else if(d.n==="lleg")m=mul(trans(d.px,d.py,0),mul(rotX(sw*0.9),trans(-d.px,-d.py,0)));
    else if(d.n==="head"||d.n==="hat")m=mul(trans(0,d.py,0),mul(rotY(Math.sin(now/1300)*0.28),trans(0,-d.py,0)));
    gl.uniformMatrix4fv(uM,false,mul(proj,mul(view,m)));
    gl.bindBuffer(gl.ARRAY_BUFFER,d.buf);
    gl.enableVertexAttribArray(aP);gl.vertexAttribPointer(aP,3,gl.FLOAT,false,24,0);
    gl.enableVertexAttribArray(aT);gl.vertexAttribPointer(aT,2,gl.FLOAT,false,24,12);
    gl.enableVertexAttribArray(aL);gl.vertexAttribPointer(aL,1,gl.FLOAT,false,24,20);
    gl.drawArrays(gl.TRIANGLES,0,36);
  });
}
function down(e){drag=true;auto=false;idle=0;lx=e.clientX;ly=e.clientY;try{viewer.setPointerCapture(e.pointerId)}catch(x){}}
function move(e){if(!drag)return;yaw+=(e.clientX-lx)*0.012;pitch=Math.max(-0.6,Math.min(0.7,pitch+(e.clientY-ly)*0.006));lx=e.clientX;ly=e.clientY}
function up(){drag=false;idle=0}
viewer.addEventListener("pointerdown",down);viewer.addEventListener("pointermove",move);
viewer.addEventListener("pointerup",up);viewer.addEventListener("pointercancel",up);
if("IntersectionObserver" in window){new IntersectionObserver(function(es){visible=es[0].isIntersecting}).observe(viewer)}

/* ---------- Skin-Auswahl ---------- */
window.FCSkin3D={
  count:6,
  set:function(n){loadSkin(n,setSkin)},
  thumb:function(n,cb){loadSkin(n,function(im){
    // Kopf-Vorschau (Gesicht + Hut-Ebene) hochskaliert, ohne Weichzeichnen
    var c=document.createElement("canvas");c.width=c.height=48;var x=c.getContext("2d");x.imageSmoothingEnabled=false;
    x.drawImage(im,8,8,8,8,0,0,48,48);x.drawImage(im,40,8,8,8,0,0,48,48);cb(c)})}
};
FCSkin3D.set(1);
requestAnimationFrame(frame);
})();
