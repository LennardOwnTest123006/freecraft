"use strict";
const I=window.I18N,C=window.FREECRAFT||{};
const CODES=["en","de","fr","es","it","pt","nl","pl","ru","tr","ja","zh"];
const NAMES={en:"English",de:"German (Deutsch)",fr:"French (Français)",es:"Spanish (Español)",it:"Italian (Italiano)",pt:"Portuguese (Português)",nl:"Dutch (Nederlands)",pl:"Polish (Polski)",ru:"Russian (Русский)",tr:"Turkish (Türkçe)",ja:"Japanese (日本語)",zh:"Chinese (中文)"};
const NATIVE={en:"English",de:"Deutsch",fr:"Français",es:"Español",it:"Italiano",pt:"Português",nl:"Nederlands",pl:"Polski",ru:"Русский",tr:"Türkçe",ja:"日本語",zh:"中文"};
const LABEL={en:"Language",de:"Sprache",fr:"Langue",es:"Idioma",it:"Lingua",pt:"Idioma",nl:"Taal",pl:"Język",ru:"Язык",tr:"Dil",ja:"言語",zh:"语言"};
const MSG={en:["Downloading","Done – check your Downloads folder","Download failed – please try again"],de:["Lade herunter","Fertig – schau in deinen Downloads-Ordner","Download fehlgeschlagen – bitte nochmal versuchen"],fr:["Téléchargement","Terminé – regarde dans tes Téléchargements","Échec – réessaie"],es:["Descargando","Listo – mira tu carpeta de Descargas","Error – inténtalo de nuevo"],it:["Download in corso","Fatto – controlla la cartella Download","Errore – riprova"],pt:["Baixando","Pronto – veja sua pasta Downloads","Falhou – tente de novo"],nl:["Downloaden","Klaar – kijk in je map Downloads","Mislukt – probeer opnieuw"],pl:["Pobieranie","Gotowe – sprawdź folder Pobrane","Błąd – spróbuj ponownie"],ru:["Загрузка","Готово – посмотрите папку «Загрузки»","Ошибка – попробуйте снова"],tr:["İndiriliyor","Bitti – İndirilenler klasörüne bak","Başarısız – tekrar dene"],ja:["ダウンロード中","完了 – ダウンロードフォルダを確認してください","失敗 – もう一度お試しください"],zh:["下载中","完成 – 请查看“下载”文件夹","失败 – 请重试"]};
const KEY="fc_lang_choice_v3";
const reduce=matchMedia("(prefers-reduced-motion: reduce)").matches;

/* ---------- Sprache: URL > bewusste Wahl > Systemsprache > Englisch ---------- */
function systemLang(){
  const list=(navigator.languages&&navigator.languages.length?navigator.languages:[navigator.language||"en"]);
  for(const l of list){const c=String(l).slice(0,2).toLowerCase();if(I[c])return c}
  return "en";
}
function chosen(){
  const q=new URLSearchParams(location.search).get("lang");
  if(q&&I[q.slice(0,2).toLowerCase()])return q.slice(0,2).toLowerCase();
  try{const s=localStorage.getItem(KEY);if(s&&I[s])return s}catch(e){}
  return "";
}
let pick=chosen(),lang=pick||systemLang();
const T=k=>(I[lang]&&I[lang][k])||I.en[k]||"";

const sel=document.getElementById("lang");
function buildSelect(){
  sel.textContent="";
  const a=document.createElement("option");a.value="auto";a.textContent=T("lang_auto");sel.appendChild(a);
  for(const k of CODES){const o=document.createElement("option");o.value=k;o.textContent=NAMES[k];sel.appendChild(o)}
  sel.value=pick||"auto";
  sel.setAttribute("aria-label",LABEL[lang]||"Language");
}
sel.addEventListener("change",e=>{
  const v=e.target.value;
  if(v==="auto"){pick="";lang=systemLang();try{localStorage.removeItem(KEY)}catch(x){}}
  else{pick=v;lang=v;try{localStorage.setItem(KEY,v)}catch(x){}}
  render();
});

/* ---------- Galerie ---------- */
const TABS=[["menu","g_menu",true],["skins","g_skins",true],["inv","g_inv",true],["animals","g_animals",false],["world","g_world",false]];
let tab="menu";
const shotSrc=(id,loc)=>"img/shots/"+id+(loc?"_"+lang:"")+".webp?v=13";
const stageBtn=document.getElementById("stageBtn"),stageImg=document.getElementById("stageImg");
function renderTabs(){
  const box=document.getElementById("tabs");box.textContent="";
  TABS.forEach(([id,key])=>{
    const b=document.createElement("button");b.type="button";b.className="tab";b.setAttribute("role","tab");
    b.setAttribute("aria-selected",id===tab);b.textContent=T(key);
    b.addEventListener("click",()=>{if(tab===id)return;tab=id;renderGallery(true)});box.appendChild(b);
  });
}
function renderGallery(animate){
  renderTabs();
  const t=TABS.find(x=>x[0]===tab);
  const apply=()=>{
    stageImg.onerror=()=>{stageImg.onerror=null;stageImg.src="img/shots/"+tab+(t[2]?"_en":"")+".webp?v=13"};
    stageImg.onload=()=>stageBtn.classList.remove("swap");
    stageImg.src=shotSrc(tab,t[2]);stageImg.alt=T(t[1]);
  };
  document.getElementById("stageCap").textContent=T(t[1]);
  if(animate&&!reduce){stageBtn.classList.add("swap");setTimeout(apply,220)}else apply();
}
const lb=document.getElementById("lb");
stageBtn.addEventListener("click",()=>{
  const im=document.getElementById("lbImg");im.src=stageImg.currentSrc||stageImg.src;im.alt=stageImg.alt;
  lb.showModal?lb.showModal():lb.setAttribute("open","");
});
lb.addEventListener("click",e=>{if(e.target!==document.getElementById("lbImg"))lb.close?lb.close():lb.removeAttribute("open")});

/* ---------- Skin- und Mob-Auswahl ---------- */
let skinPick=1,mobPick=0,pickersBuilt=false;
function buildPickers(){
  const sp=document.getElementById("picker"),mp=document.getElementById("mobPicker");
  if(!pickersBuilt){
    for(let i=1;i<=8;i++){
      const b=document.createElement("button");b.type="button";b.className="dot";b.dataset.k=i;b.setAttribute("aria-pressed",i===skinPick);
      const sp2=document.createElement("span");b.appendChild(sp2);
      if(window.FCSkin3D)FCSkin3D.thumb(i,c=>b.insertBefore(c,sp2));
      b.addEventListener("click",()=>{skinPick=i;FCSkin3D.set(i);sp.querySelectorAll(".dot").forEach(d=>d.setAttribute("aria-pressed",+d.dataset.k===i));document.getElementById("skinName").textContent=T("sk"+i)});
      sp.appendChild(b);
    }
    if(window.FCMobs)for(let i=0;i<10;i++){
      const b=document.createElement("button");b.type="button";b.className="dot";b.dataset.k=i;b.setAttribute("aria-pressed",i===mobPick);
      const im=new Image();im.width=54;im.height=54;im.alt="";im.loading="lazy";im.src=FCMobs.thumb(i);
      const s=document.createElement("span");b.append(im,s);
      b.addEventListener("click",()=>{mobPick=i;FCMobs.set(i);mp.querySelectorAll(".dot").forEach(d=>d.setAttribute("aria-pressed",+d.dataset.k===i));document.getElementById("mobName").textContent=T("m"+(i+1))});
      mp.appendChild(b);
    }
    pickersBuilt=true;
  }
  sp.querySelectorAll(".dot").forEach(d=>{d.lastChild.textContent=T("sk"+d.dataset.k)});
  mp.querySelectorAll(".dot").forEach(d=>{d.lastChild.textContent=T("m"+(+d.dataset.k+1))});
  document.getElementById("skinName").textContent=T("sk"+skinPick);
  document.getElementById("mobName").textContent=T("m"+(mobPick+1));
}

/* ---------- Sprachband ---------- */
function buildMarquee(){
  [["row1",CODES],["row2",CODES.slice().reverse()]].forEach(([id,list])=>{
    const r=document.getElementById(id);if(r.childElementCount)return;
    for(let rep=0;rep<2;rep++)list.forEach(c=>{const s=document.createElement("span");s.textContent=NATIVE[c];s.lang=c;r.appendChild(s)});
  });
}

/* ---------- Texte ---------- */
let rel=null,man=null,state="load";
const repo=()=>C.githubRepo&&!/DEIN-NAME/.test(C.githubRepo)?C.githubRepo:"";
function metaHTML(){
  if(!rel)return state==="load"?T("load"):T("err");
  const d=rel.date?new Date(rel.date).toLocaleDateString(lang,{year:"numeric",month:"short",day:"numeric"}):"";
  return `<span>${T("v")}: <b>${rel.tag}</b></span>`+(d?`<span>${T("d")}: <b>${d}</b></span>`:"")+(rel.size?`<span>${T("sz")}: <b>${(rel.size/1048576).toFixed(0)} MB</b></span>`:"");
}
function render(){
  document.documentElement.lang=lang;
  buildSelect();
  document.querySelectorAll("[data-i]").forEach(e=>{e.textContent=T(e.dataset.i)});
  document.title="FreeCraft – "+T("h1");
  document.querySelector('meta[name="description"]').content=T("lead");
  renderGallery(false);
  buildPickers();
  buildMarquee();
  const src=document.getElementById("src"),r=repo();
  src.textContent="";
  if(r){const b=document.createElement("b");b.textContent=T("src")+" ";const a=document.createElement("a");a.href="https://github.com/"+r;a.rel="noopener";a.textContent="github.com/"+r;src.append(b,a)}
  const mail=document.getElementById("mail");mail.textContent=C.contactEmail||"";mail.href="mailto:"+(C.contactEmail||"");
  if(!(btnBusy())){["meta","meta2"].forEach(id=>{document.getElementById(id).innerHTML=metaHTML()})}
  if(rel&&!man)for(const id of ["dl","dl2"])document.getElementById(id).href=rel.url;
}

/* ---------- Download (Teile von GitHub zusammensetzen) ---------- */
let baseIdx=0;const BASES=()=>[].concat(C.downloadBase||["dl/"]);
const BASE=()=>BASES()[baseIdx]||BASES()[0];
const M=i=>(MSG[lang]||MSG.en)[i];
const dlBtns=()=>[document.getElementById("dl"),document.getElementById("dl2")];
const btnBusy=()=>!!dlBtns()[0].dataset.busy;
const say=t=>["meta","meta2"].forEach(id=>{document.getElementById(id).textContent=t});
async function getMan(){
  for(baseIdx=0;baseIdx<BASES().length;baseIdx++){
    try{const r=await fetch(BASE()+"manifest.json?"+Date.now(),{cache:"no-store"});if(!r.ok)continue;const j=await r.json();if(j&&j.parts&&j.parts.length){man=j;return}}catch(e){}
  }
  baseIdx=0;
}
async function bigDownload(ev){
  if(!man)return;ev.preventDefault();
  if(btnBusy())return;
  dlBtns().forEach(b=>b.dataset.busy="1");
  try{
    const chunks=[];let got=0;
    for(const p of man.parts){
      const r=await fetch(BASE()+p);if(!r.ok)throw new Error(p);
      const b=await r.blob();chunks.push(b);got+=b.size;
      say(M(0)+" … "+Math.min(100,Math.round(got/man.size*100))+"%");
    }
    const blob=new Blob(chunks,{type:"application/octet-stream"});
    if(blob.size!==man.size)throw new Error("size");
    const a=document.createElement("a");a.href=URL.createObjectURL(blob);a.download=man.name;
    document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(a.href),60000);
    say(M(1));
  }catch(e){say(M(2))}
  dlBtns().forEach(b=>delete b.dataset.busy);
}
dlBtns().forEach(b=>b.addEventListener("click",bigDownload));
async function init(){
  await getMan();
  if(man){rel={tag:"v"+man.version,size:man.size,date:man.date||"",url:"#install"};state="ok";render();return}
  const r0=repo();
  if(r0){
    for(const id of ["dl","dl2"])document.getElementById(id).href=`https://github.com/${r0}/releases/latest/download/FreeCraft-Setup.exe`;
    try{
      const r=await fetch(`https://api.github.com/repos/${r0}/releases/latest`,{headers:{Accept:"application/vnd.github+json"}});
      if(!r.ok)throw new Error(r.status);
      const j=await r.json();const as=j.assets||[];
      const a=as.find(x=>/setup.*\.exe$/i.test(x.name))||as.find(x=>/\.exe$/i.test(x.name))||as.find(x=>/\.zip$/i.test(x.name))||as[0];
      if(!a)throw new Error("no asset");
      rel={tag:j.tag_name||j.name,date:j.published_at,size:a.size,url:a.browser_download_url};
    }catch(e){state="err"}
  }
  if(!rel&&C.fallbackUrl){rel={tag:C.fallbackVersion||"",url:C.fallbackUrl};state="ok"}
  else if(!rel){state="err"}
  render();
}

/* ---------- Bewegung (GSAP) – ein Auftritt im Hero, sanfte Tiefe beim Scrollen ---------- */
function motion(){
  if(reduce||!window.gsap)return;
  const g=gsap;if(window.ScrollTrigger)g.registerPlugin(ScrollTrigger);
  const tl=g.timeline({defaults:{ease:"power3.out"}});
  tl.from(".hero-bg img",{scale:1.14,duration:2.2,ease:"power2.out"},0)
    .from("#heroPanel",{y:36,opacity:0,duration:.8},.15)
    .from("#wordmark",{clipPath:"inset(0 100% 0 0)",duration:.9,ease:"steps(12)"},.45)
    .from("#heroPanel .badge,#heroPanel h1,#heroPanel .lead,#heroPanel .cta-row,#heroPanel .meta",{y:18,opacity:0,duration:.6,stagger:.08},.85);
  if(window.ScrollTrigger){
    g.to(".hero-bg",{yPercent:10,ease:"none",scrollTrigger:{trigger:"#hero",start:"top top",end:"bottom top",scrub:true}});
    g.from("#stage",{scale:.94,ease:"none",scrollTrigger:{trigger:"#stage",start:"top 95%",end:"top 45%",scrub:true}});
  }
  const bg=document.querySelector(".hero-bg");
  if(bg&&matchMedia("(hover:hover)").matches){
    const qx=g.quickTo(bg,"x",{duration:1.2,ease:"power3"}),qy=g.quickTo(bg,"y",{duration:1.2,ease:"power3"});
    document.getElementById("hero").addEventListener("pointermove",e=>{qx((e.clientX/innerWidth-.5)*-22);qy((e.clientY/innerHeight-.5)*-14)});
  }
}
render();init();motion();
