from PIL import Image, ImageDraw, ImageFilter, ImageEnhance, ImageChops
import random, os
random.seed(5)
OUT="/home/claude/work/ui"
def clamp(v): return max(0,min(255,v))
def noise(c,v): d=random.randint(-v,v); return tuple(clamp(x+d) for x in c[:3])+((c[3],) if len(c)>3 else ())
def button(name, base, hi, lo, edge, noisev=4):
    W,H=64,24
    im=Image.new("RGBA",(W,H))
    for x in range(W):
        for y in range(H):
            im.putpixel((x,y),noise(base+(255,),noisev))
    d=ImageDraw.Draw(im)
    d.rectangle([0,0,W-1,H-1],outline=edge+(255,))
    d.line([(1,1),(W-2,1)],fill=hi+(255,)); d.line([(1,1),(1,H-2)],fill=hi+(255,))
    d.line([(2,2),(W-3,2)],fill=tuple(clamp(c-25) for c in hi)+(255,))
    d.line([(1,H-2),(W-2,H-2)],fill=lo+(255,)); d.line([(W-2,1),(W-2,H-2)],fill=lo+(255,))
    d.line([(2,H-3),(W-3,H-3)],fill=tuple(clamp(c+20) for c in lo)+(255,))
    # round corners
    for p in [(0,0),(W-1,0),(0,H-1),(W-1,H-1)]: im.putpixel(p,(0,0,0,0))
    im.save(f"{OUT}/{name}.png")
button("fc_btn",(52,58,78),(120,132,170),(22,26,40),(8,10,18))
button("fc_btn_h",(66,98,128),(140,226,240),(26,44,66),(70,220,235))
button("fc_btn_p",(34,40,58),(26,30,44),(90,104,140),(8,10,18))
button("fc_btn_go",(28,128,138),(110,236,236),(14,66,86),(8,10,18))
button("fc_btn_go_h",(40,160,170),(170,250,250),(18,84,104),(250,210,80))
button("fc_btn_d",(40,42,52),(60,64,78),(28,30,40),(14,16,22),2)
# panel
W=48
p=Image.new("RGBA",(W,W),(10,14,30,208)); d=ImageDraw.Draw(p)
d.rectangle([0,0,W-1,W-1],outline=(6,8,16,255))
d.rectangle([1,1,W-2,W-2],outline=(74,90,130,255))
d.rectangle([2,2,W-3,W-3],outline=(30,38,64,255))
p.save(f"{OUT}/fc_panel.png")
# field bg strip
f=Image.new("RGBA",(8,8),(6,8,18,230)); ImageDraw.Draw(f).rectangle([0,0,7,7],outline=(70,86,124,255)); f.save(f"{OUT}/fc_field.png")
# list bg
# ---------- logo
G={
"F":["11111","10000","10000","11110","10000","10000","10000"],
"R":["11110","10001","10001","11110","10100","10010","10001"],
"E":["11111","10000","10000","11110","10000","10000","11111"],
"C":["01111","10000","10000","10000","10000","10000","01111"],
"A":["01110","10001","10001","11111","10001","10001","10001"],
"T":["11111","00100","00100","00100","00100","00100","00100"],
}
text="FREECRAFT"
cell=15; dep=7
cols=len(text)*6-1
Wl=cols*cell+dep*2+100; Hl=7*cell+dep*2+100
S=4
def render():
    lay=Image.new("RGBA",(Wl*1,Hl*1),(0,0,0,0))
    ox,oy=50,50
    # extrusion first (back to front)
    for step in range(dep,0,-1):
        d=ImageDraw.Draw(lay)
        for i,ch in enumerate(text):
            for r,row in enumerate(G[ch]):
                for c,v in enumerate(row):
                    if v=="1":
                        x=ox+(i*6+c)*cell+step; y=oy+r*cell+step
                        shade=int(30+ (dep-step)*6)
                        d.rectangle([x,y,x+cell-1,y+cell-1],fill=(18,24+shade//2,70+shade,255))
    d=ImageDraw.Draw(lay)
    for i,ch in enumerate(text):
        for r,row in enumerate(G[ch]):
            for c,v in enumerate(row):
                if v=="1":
                    x=ox+(i*6+c)*cell; y=oy+r*cell
                    t=r/6
                    base=(int(70-30*t),int(232-70*t),int(236-20*t))
                    for xx in range(cell):
                        for yy in range(cell):
                            col=noise(base,5)
                            d.point((x+xx,y+yy),fill=col+(255,))
                    d.line([(x,y),(x+cell-1,y)],fill=(190,255,255,255))
                    d.line([(x,y),(x,y+cell-1)],fill=(150,250,250,255))
                    d.line([(x,y+cell-1),(x+cell-1,y+cell-1)],fill=(14,90,130,255))
                    d.line([(x+cell-1,y),(x+cell-1,y+cell-1)],fill=(14,90,130,255))
    return lay
lay=render()
# outline
a=lay.split()[3]
out=a.filter(ImageFilter.MaxFilter(5))
black=Image.new("RGBA",lay.size,(6,8,20,255)); black.putalpha(out)
comp=Image.new("RGBA",lay.size,(0,0,0,0)); comp.alpha_composite(black); comp.alpha_composite(lay)
# soft glow
glow=Image.new("RGBA",lay.size,(60,230,240,0)); ga=a.filter(ImageFilter.GaussianBlur(14)).point(lambda v:int(v*0.55)); glow.putalpha(ga)
final=Image.new("RGBA",lay.size,(0,0,0,0)); final.alpha_composite(glow); final.alpha_composite(comp)
# gold accent line under logo
dd=ImageDraw.Draw(final)
canvas=Image.new("RGBA",(960,286),(0,0,0,0))
sc=min(940/final.width, 230/final.height)
fl=final.resize((int(final.width*sc),int(final.height*sc)),Image.LANCZOS)
canvas.alpha_composite(fl,((960-fl.width)//2,(286-fl.height)//2-6))
cd=ImageDraw.Draw(canvas)
y=(286+fl.height)//2+2
cd.rectangle([330,y,630,y+4],fill=(250,200,70,255)); cd.rectangle([330,y+5,630,y+6],fill=(150,100,20,255))
canvas.save(f"{OUT}/header.png")
canvas.resize((480,143),Image.LANCZOS).save(f"{OUT}/logo_small.png")
# footer: transparent
Image.new("RGBA",(1920,74),(0,0,0,0)).save(f"{OUT}/footer.png")
print("ok")
