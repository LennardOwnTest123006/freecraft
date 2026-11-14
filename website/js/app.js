"use strict";
const I=window.I18N,C=window.FREECRAFT||{};
const NAMES={en:"English",de:"German (Deutsch)",fr:"French (Français)",es:"Spanish (Español)",it:"Italian (Italiano)",pt:"Portuguese (Português)",nl:"Dutch (Nederlands)",pl:"Polish (Polski)",ru:"Russian (Русский)",tr:"Turkish (Türkçe)",ja:"Japanese (日本語)",zh:"Chinese (中文)"};
const MSG={en:["Downloading","Done – check your Downloads folder","Download failed – please try again"],de:["Lade herunter","Fertig – schau in deinen Downloads-Ordner","Download fehlgeschlagen – bitte nochmal versuchen"],fr:["Téléchargement","Terminé – regarde dans tes Téléchargements","Échec – réessaie"],es:["Descargando","Listo – mira tu carpeta de Descargas","Error – inténtalo de nuevo"],it:["Download in corso","Fatto – controlla la cartella Download","Errore – riprova"],pt:["Baixando","Pronto – veja sua pasta Downloads","Falhou – tente de novo"],nl:["Downloaden","Klaar – kijk in je map Downloads","Mislukt – probeer opnieuw"],pl:["Pobieranie","Gotowe – sprawdź folder Pobrane","Błąd – spróbuj ponownie"],ru:["Загрузка","Готово – посмотрите папку «Загрузки»","Ошибка – попробуйте снова"],tr:["İndiriliyor","Bitti – İndirilenler klasörüne bak","Başarısız – tekrar dene"],ja:["ダウンロード中","完了 – ダウンロードフォルダを確認してください","失敗 – もう一度お試しください"],zh:["下载中","完成 – 请查看“下载”文件夹","失败 – 请重试"]};
const KEY="fc_lang_choice_v2"; // nur eine bewusst gewählte Sprache wird gemerkt (alte Werte werden ignoriert)

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
let pick=chosen();           // "" = automatisch (Systemsprache)
let lang=pick||systemLang();
const T=k=>(I[lang]&&I[lang][k])||I.en[k]||"";

/* ---------- Auswahlfeld ---------- */
const sel=document.getElementById("lang");
function buildSelect(){
  sel.innerHTML="";
  const a=document.createElement("option");a.value="auto";a.textContent=T("lang_auto");sel.appendChild(a);
  for(const k of Object.keys(NAMES)){const o=document.createElement("option");o.value=k;o.textContent=NAMES[k];sel.appendChild(o)}
  sel.value=pick||"auto";
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
const shotSrc=(id,loc)=>"img/shots/"+id+(loc?"_"+lang:"")+".webp?v=11";
function buildTabs(){
  const box=document.getElementById("tabs");box.innerHTML="";
  TABS.forEach(([id,key])=>{
    const b=document.createElement("button");b.type="button";b.className="tab";b.setAttribute("role","tab");
    b.setAttribute("aria-selected",id===tab);b.textContent=T(key);
    b.addEventListener("click",()=>{tab=id;renderGallery()});box.appendChild(b);
  });
}
function renderGallery(){
  buildTabs();
  const t=TABS.find(x=>x[0]===tab),img=document.getElementById("stageImg");
  img.onerror=()=>{img.onerror=null;img.src="img/shots/"+tab+(t[2]?"_en":"")+".webp?v=11"};img.src=shotSrc(tab,t[2]);img.alt=T(t[1]);
  document.getElementById("stageCap").textContent=T(t[1]);
}
const lb=document.getElementById("lb");
document.getElementById("stageBtn").addEventListener("click",()=>{
  const im=document.getElementById("lbImg");im.src=document.getElementById("stageImg").src;im.alt=document.getElementById("stageImg").alt;lb.hidden=false;
});
lb.addEventListener("click",()=>{lb.hidden=true});
document.addEventListener("keydown",e=>{if(e.key==="Escape")lb.hidden=true});

/* ---------- 3D-Skin-Auswahl ---------- */
let skinPick=1;
function buildPicker(){
  const box=document.getElementById("picker");box.innerHTML="";
  for(let i=1;i<=6;i++){
    const b=document.createElement("button");b.type="button";b.className="dot";b.setAttribute("aria-pressed",i===skinPick);
    const span=document.createElement("span");span.textContent=T("sk"+i);
    b.appendChild(span);box.appendChild(b);
    if(window.FCSkin3D)FCSkin3D.thumb(i,c=>b.insertBefore(c,span));
    b.addEventListener("click",()=>{skinPick=i;if(window.FCSkin3D)FCSkin3D.set(i);box.querySelectorAll(".dot").forEach((d,j)=>d.setAttribute("aria-pressed",j+1===i))});
  }
}

/* ---------- Texte ---------- */
let rel=null,man=null,state="load",pickerBuilt=false;
const repo=()=>C.githubRepo&&!/DEIN-NAME/.test(C.githubRepo)?C.githubRepo:"";
function render(){
  document.documentElement.lang=lang;
  buildSelect();
  document.querySelectorAll("[data-i]").forEach(e=>{e.textContent=T(e.dataset.i)});
  document.title="FreeCraft – "+T("h1");
  document.querySelector('meta[name="description"]').content=T("lead");
  document.querySelectorAll("img[data-shot]").forEach(i=>{i.src=shotSrc(i.dataset.shot,true)});
  renderGallery();
  if(!pickerBuilt||true)buildPicker();
  const src=document.getElementById("src"),r=repo();
  src.innerHTML=r?`<b>${T("src")}</b> <a href="https://github.com/${r}" rel="noopener">github.com/${r}</a>`:"";
  const mail=document.getElementById("mail");mail.textContent=C.contactEmail||"";mail.href="mailto:"+(C.contactEmail||"");
  const meta=document.getElementById("meta");
  if(rel){
    if(!man)for(const id of ["dl","dl2"])document.getElementById(id).href=rel.url;
    meta.innerHTML=`<span>${T("v")}: <b>${rel.tag}</b></span>`+(rel.date?`<span>${T("d")}: <b>${new Date(rel.date).toLocaleDateString(lang,{year:"numeric",month:"short",day:"numeric"})}</b></span>`:"")+(rel.size?`<span>${T("sz")}: <b>${(rel.size/1048576).toFixed(0)} MB</b></span>`:"");
  }else if(state==="load"){meta.textContent=T("load")}
  else{meta.textContent=T("err")}
}

/* ---------- Download (Teile von GitHub zusammensetzen) ---------- */
let baseIdx=0;const BASES=()=>[].concat(C.downloadBase||["dl/"]);
const BASE=()=>BASES()[baseIdx]||BASES()[0];
const M=i=>(MSG[lang]||MSG.en)[i];
async function getMan(){
  for(baseIdx=0;baseIdx<BASES().length;baseIdx++){
    try{const r=await fetch(BASE()+"manifest.json?"+Date.now(),{cache:"no-store"});if(!r.ok)continue;const j=await r.json();if(j&&j.parts&&j.parts.length){man=j;return}}catch(e){}
  }
  baseIdx=0;
}
async function bigDownload(ev){
  if(!man)return;ev.preventDefault();
  const meta=document.getElementById("meta"),btns=[document.getElementById("dl"),document.getElementById("dl2")];
  if(btns[0].dataset.busy)return;btns.forEach(b=>{b.dataset.busy="1";b.style.opacity=".7"});
  try{
    const chunks=[];let got=0;
    for(const p of man.parts){
      const r=await fetch(BASE()+p);if(!r.ok)throw new Error(p);
      const b=await r.blob();chunks.push(b);got+=b.size;
      meta.textContent=M(0)+" … "+Math.min(100,Math.round(got/man.size*100))+"%";
    }
    const blob=new Blob(chunks,{type:"application/octet-stream"});
    if(blob.size!==man.size)throw new Error("size");
    const a=document.createElement("a");a.href=URL.createObjectURL(blob);a.download=man.name;
    document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(a.href),60000);
    meta.textContent=M(1);
  }catch(e){meta.textContent=M(2)}
  btns.forEach(b=>{delete b.dataset.busy;b.style.opacity=""});
}
for(const id of ["dl","dl2"])document.getElementById(id).addEventListener("click",bigDownload);
async function init(){
  await getMan();
  if(man){rel={tag:"v"+man.version,size:man.size,date:man.date||"",url:"#"};state="ok";render();return}
  const r0=repo();
  if(r0)for(const id of ["dl","dl2"])document.getElementById(id).href=`https://github.com/${r0}/releases/latest/download/FreeCraft-Setup.exe`;
  if(r0){
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
  else if(!rel&&!r0){state="err"}
  render();
}
render();init();
