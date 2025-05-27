pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--p8ng ホ゜ン
-- by leandro pereira
version="v.0.0.2"
cartdata"llp_p8ng_v1"

--todo:
--dynamic difficulty rules

game_mode=1
game_mode_names=
 {"p1 X p2",
  "soccer",
  "subp8ng",
  "freefly"}

game_mode_desc=
 {"regular p8ng",
  "2ND paddle at your court",
  "2ND paddle at opponent's court ",
  "⬅️➡️ moves 2ND paddle sideways   "}

pad1desc={"⬅️⬆️➡️⬇️","s e f d","cpu"}
pad2desc={"⬅️⬆️➡️⬇️","s e f d","cpu"}
balldesc={"  rupture >","< stable"}

dirx=split"-1,1,0,0,0,0"
diry=split"0,0,1,-1,.2,-.2"

angspr=0
anglua=0
match_total=1200

function _init()
 ver,url="v001",stat(102)
 pirate=(url!="www.lexaloffle.com" and url!=0)

 menuitem(1,"reset stats",reset_score)

 splash=true

 hcy=129

 load_menu()

 init_llp()
 init_menu()
end

function init_menu()
 ti=0

 menu={x=170,mx=32,dx=0,y=60}
 py=188

 stars={}
 for i=0,40do
  local _p={
   x=rnd(127),
   y=-300-rnd(300),
   r=rnd(2),
   c=rnd({5,6,7})
  }

  if(_p.c==5)_p.dy=rnd()
  if(_p.c==6)_p.dy=(2+rnd())
  if(_p.c==7)_p.dy=(3+rnd(2))

  add(stars,_p)
 end

 ini=true

 gpadx,gpady,gang,gpady2=39,55,0,0

 --wetbandits
 wetbandits={a=112,b=117,da=1,db=-1}
end

function init_game()
 sfx(1)

 local p1t=selpad1>2and"cpu"or"human"
 local p2t=selpad2>2and"cpu"or"human"
 local p1c=selpad1-1
 local p2c=selpad2-1

 if(p1c==2)p1c=nil
 if(p2c==2)p2c=nil

 p1=create_player(1,p1t,p1c)
 p2=create_player(2,p2t,p2c)
 p={p1,p2}

 if game_mode>1then
  if game_mode==2then
   p1b=create_player(3,p1t,p1c)
   p2b=create_player(4,p2t,p2c)
  elseif game_mode==3then
   p1b=create_player(4,p1t,p1c)
   p2b=create_player(3,p2t,p2c)
  elseif game_mode==4then
   p1b=create_player(3,"sidekick",p1c)
   p2b=create_player(4,"sidekick",p2c)
  end
  add(p,p1b)
  add(p,p2b)
 end
 balls={create_ball()}

 timer=0
 timergoal=30

 goal=0

 match_point=false
 freeze_timer=-20
 match_timer=match_total
 blink=0
end

function init_game_over()
 sfx(9)
 sfx(10)

 for ball in all(balls)do
  ball.y=-10
 end

 if p1.score<p2.score then

  losers={p1}
  if(p1b~=nil)add(losers,p1b)
  save_score(p2.mode=="human")
 else

  losers={p2}
  if(p2b~=nil)add(losers,p2b)
  save_score(p1.mode=="human")
 end

 loser_parts={}

 for loser in all(losers)do
  loser.visible=false
  for x=loser.x,loser.x+loser.w do
   for y=loser.y,loser.y+loser.h do
    add(loser_parts,
       {x=x
       ,y=y
       ,dx=((1+rnd(4))-2)
       ,dy=((1+rnd(4))-2)
       ,c=loser.col
       })
   end
  end
 end
 scorex=130
 sscore=0
end

function game_state(st)
 if st=="init" then
  _drw=_drw_llp
  _upd=_upd_llp
 elseif st=="game" then
  init_game()
  _drw=_drw_game
  _upd=_upd_game
 elseif st=="menu" then
  sfx(6)
  init_menu()
  _drw=_drw_menu
  _upd=_upd_menu
 elseif st=="game over" then
  sfx(5)
  init_game_over()
  _upd=_upd_game_over
  _drw=_drw_game_over
 end
end

function save_menu()
 dset(0,selpad1)
 dset(1,selpad2)
 dset(2,selball)
 dset(3,game_mode)
 dset(4,match_total)
end

function load_menu()
 selpad1    =dget(0)or 1
 selpad2    =dget(1)or 3
 selball    =dget(2)or 1
 game_mode  =dget(3)or 1
 match_total=dget(4)or 1200

 if(selpad1  ==0)selpad1=1
 if(selpad2  ==0)selpad2=3
 if(selball  ==0)selball=1
 if(game_mode==0)game_mode=1
 if(match_total==0)match_total=1200
end

matches={}
function load_score()
 matches={}
 for i=1,8
  do
   local p=(i*4)+1
   add(matches,
       concat_ws("|",
        1+((i-1)%4),
        ceil(i/4),
        dget(p),
        dget(p+1),
        dget(p+2),
        dget(p+3)))
 end
end
function save_score(vic)
 load_score()

 local gpos=game_mode+(selball-1)*4
 local m=split(matches[gpos],"|")
 local cpu=iif(selpad1==3or selpad2==3,0,2)
 local cnt,wins=1+m[3+cpu],m[4+cpu]
 if(vic)wins+=1

 local off=1+cpu
 dset(gpos*4+off,cnt)
 dset(gpos*4+off+1,wins)
 load_score()
end

function reset_score()
 for i=5,37do
  dset(i,0)
 end
end
-->8
--upd
function _update()
 ti+=1
 blink=ti%30>=15 and 1 or 0
 _upd()
end

function _upd_game_over()

 if(but(🅾️))game_state"game"

 if but(❎)then
  game_state"menu"
  py=0
 end

 if(but(⬅️,⬆️))if(scorex>0)sscore=-5
 if(but(⬇️,➡️))if(scorex<130)sscore=5

 if(sscore~=0)scorex+=sscore
 if(scorex<=0 or scorex>130)sscore=0

 --explode loser
 for part in all(loser_parts)do
  part.x+=part.dx
  part.y+=part.dy
 end

 --winner rockets up
 for _p in all(p)do
  _p.y-=2.5
 end

 animate_background()
end

function _upd_menu()
 --menu
 if ini then
  menu.x+=menu.dx
  py+=menu.dx/3
  if(menu.x<menu.mx)then
   py=-32
   menu.x=menu.mx
   ini=false
  end

  if btnp()>0 then
   menu.dx=-4
   py=0
   hcy=-500
  end

 else
  if but(❎,🅾️)or
     but(❎,🅾️)then
   if selline==5 then
    save_menu()
    init_game()
    menu.dx=0
    menu.x=150
    py=0
    ini=true
    _drw=_drw_game
    _upd=_upd_game
   else
    selline+=1
   end
  end
 end

 local _1=0
 if(but(⬅️))_1=-1
 if(but(➡️))_1=1

 local bact={
  function()selpad1+=_1 end,
  function()selpad2+=_1 end,
  function()match_total+=_1*300end,
  function()selball+=_1 end,
  function()game_mode+=_1 end}

 if(_1!=0)bact[selline]()

 if but(⬆️,⬇️) then
    sfx(2)
    selline+=iif(but(⬇️),1,-1)
 end

 --limitations
 selpad1=mid(1,selpad1,3)
 selpad2=mid(1,selpad2,3)
 match_total=mid(0,match_total,30000)
 selline=mid(1,selline,5)
 selball=mid(1,selball,2)
 game_mode=mid(1,game_mode,#game_mode_names)

 gang+=0.01
 if(gang>1)gang-=1
 local sang,cang=sin(gang),cos(gang)

 gpady =50+sang*20
 gpady2=50+cang*20
 gpadx =40+cang*32
 gpadx2=40+sang*32

 animate_background()
end

xplode={}
function _upd_game()
 --players
 for _p in all(p) do
  if _p.mode=="cpu"then
   _p:mov()
  else
   local b
   for i=0,5do
    if(btn(i,_p.control))_p:mov(i)
   end
  end

  --fx
  for ball in all(balls)do
   if ball:collide(_p) then
    for i=0,_p.h do
     add(xplode,
     {x =_p.w/2+_p.x,
      y =_p.y+i,
      c =_p.col,
      age=3+rnd(2),
      dx=ball.dx*rnd(10),
      dy=sin(i/_p.h*2)*3
      })
    end
   end
  end
 end

 for f in all(xplode)do
  f.x+=f.dx
  f.y+=f.dy
  f.age-=1
 end

 freeze_timer+=1
 if freeze_timer>0then
  for ball in all(balls)do
   ball:mov()
  end
 end

 match_timer-=1
 match_timer=max(match_timer,0)

 match_point=(match_timer<60 and p1.score==p2.score)

 if match_timer<=0 and not match_point then
  game_state("game over")
 end

 if(match_timer%60==0and match_timer<=180)sfx(4)

 if selball==1 then
  if match_timer==match_total/2.5 then
   for ball in all(balls)do
    ball.c=9
   end
  end

  --new ball
  if match_timer==(match_total/2.5)-60 or match_total==0 then
   sfx(8)
   add(balls,create_ball(balls[1].dx*-1,balls[1].x,balls[1].y))
  end
 end

 animate_background()
end

function animate_background()
 for _p in all(stars)do
  _p.y+=_p.dy
  if _p.y>127 then
   _p.y=-rnd(3)
   _p.x=flr(rnd(126))
  end
 end
end

-->8
--drw
function _draw()
 cls()
 _drw()
 if(msg~=nil)?msg,0,0,8
end

function _drw_game_over()
 _drw_game()

 drw_explosion()
 drw_nozzle()

 if p1.score>p2.score then
  ?"\^phohoho", 8,48,6-blink
  ?"\^ploser" ,78,56,5+blink
  cprint("❎ to menu",70,nil,false,false,true,p1.col,7)
  cprint("🅾️ to retry",78,nil,false,false,true,p1.col,7)
  cprint("⬆️⬅️ to stats",86,nil,false,false,true,p1.col,7)
 else
  ?"\^phohoho",74,48,6-blink
  ?"\^ploser" ,12,56,5+blink
  cprint("❎ to menu",70,nil,false,false,true,p2.col,7)
  cprint("🅾️ to retry",78,nil,false,false,true,p2.col,7)
  cprint("⬆️⬅️ to stats",86,nil,false,false,true,p2.col,7)
 end

 drw_score(17+scorex,10)
end

function drw_explosion()
 --explosion
 local c=0
 for part in all(loser_parts)do
  c+=1
  drw_gift(part.x,part.y,c)
 end
end

function drw_nozzle()
 --nozzle
 for _p in all(p)do
  if _p.visible then
   circfill(_p.x+_p.w/2,_p.y  +_p.h,4,9+tonum(ti%10<5))
   circfill(_p.x+_p.w/2,_p.y-1+_p.h,2,9+tonum(ti%10>5))
  end
 end
end

function _drw_menu()
 drw_stardust()

 hcy-=.5

 if(py>0)py-=.5
  cprint("oN cHRISTMAS eVE, STARSHIPS",hcy)
  cprint("gRUBBER 16 AND nAKATOMI 4 RACED",hcy+8)
  cprint("THROUGH SPACE TO HELP sANTA ",hcy+16)
  cprint("DELIVER GIFTS TO CHILDREN ",hcy+24)
  cprint("ON THE UNKNOWN PLANET OF tAKAGI.",hcy+32)

  cprint("aS THEY PLAYED A GAME OF FESTIVE ",hcy+42)
  cprint("pONG, EACH SUCCESSFUL HIT SENT A",hcy+50)
  cprint("GIFT TO WAITING CHILDREN,",hcy+58)
  cprint("ENSURING NO ONE WAS LEFT ",hcy+66)
  cprint("WITHOUT A PRESENT.",hcy+74)
  cprint("lET THE COSMIC pONG GAME BEGIN ",hcy+84)
  cprint("AND SAVE cHRISTMAS.",hcy+92)

  cprint("y p e - i y y",hcy+102,nil,false,false,true,0,8+blink)
  cprint(" i p e k - a ",hcy+102,nil,false,false,true,0,9-blink)


  --mr grubber
  local hansd=1

  if(hcy<0)hansd=hcy*1.5
  if(flr(hansd)==-1)sfx(11)
  local hansy=102

  if hcy>-56 and hcy<24then
   pset(91,hcy-hansd+hansy-1,9)
   pset(91,hcy-hansd+hansy,6)
   pset(90,hcy-hansd+hansy-iif(hansd<-5,blink),15)
   if(hansd<-5)pset(92,hcy-hansd+hansy+iif(hansd<-5,blink),15)
   pset(91,hcy-hansd+hansy+1,5)
   pset(91,hcy-hansd+hansy+2,5)
  end

  if blink==0 and flr(py)<=0 then
   if(flr(py)<0)cprint("select mode and",110,nil,false,false,true,0,12)
   cprint("press ❎ to start ",118,nil,false,false,true,0,12)
  end

  --wetbandits
  if flr(py)<=0then
   if(gang<.2)pal(10,8)
   spr(42,110,111,2,2)
   pal()

   local ba=wetbandits.a+(gpadx/12)
   local bb=wetbandits.b-(gpadx/12)/2

   --marv
   pset(ba,122,15)
   pset(ba,123,4)
   pset(ba,124,4)
   pset(ba,125,0)

   --harry
   pset(bb,123,5)
   pset(bb,124,15)
   pset(bb,125,0)
  end

 drw_logo()
 drw_menu(menu.x,menu.y)
end


function drw_logo()
 --logo
 local _t=t()
 local st,ct=sin(_t),cos(_t)

 spr(12,51,60+py+ct,2,1)
 spr(14,67,60+py+st,1,2)
 spr(15,75,60+py+ct,1,1)
 spr(28,51,68+py+st,2,1)
 spr(31,75,68+py+st,1,1)
 line(68,55+py+gpady/4,68,57+py+gpady/4,12)
 line(73,54+py+gpady2/4,73,56+py+gpady2/4,8)

 --santa cap
 spr(63,59,53+py+ct,1,1)
 --antlers
 spr(62,75,53+py+ct,1,1)
end

function drw_menu(x,y)
 --menu
 local gm=game_mode_names[game_mode]

 --ghost
 if not ini and ti%15<=7then
  fillp(▒)
  if selline==1then
   rectfill(1,gpady,5,gpady+16,12)
  elseif selline==2 then
   rectfill(121,gpady,125,gpady+16,8)
  else
   fillp(█)
   if selball==1then
    rectfill(66-gpadx/4,44,68-gpadx/4,46,9)
    rectfill(64+gpadx/4,44,66+gpadx/4,46,9)
   else
    rectfill(45+gpadx/2,44,47+gpadx/2,46,10)
   end
   fillp(▒)

   rectfill(1,gpady,5,gpady+16,12)
   if game_mode==1then
    rectfill(122,gpady2,127,gpady2+16,8)
   elseif game_mode==2then
    rectfill(39,gpady,43,gpady+16,12)
    rectfill(90,gpady2,94,gpady2+16,8)
    rectfill(122,gpady2,127,gpady2+16,8)
   elseif game_mode==3then
    rectfill(39,gpady2,43,gpady2+16,8)
    rectfill(90,gpady,94,gpady+16,12)
    rectfill(122,gpady2,127,gpady2+16,8)
   elseif game_mode==4then
    rectfill(gpadx   ,gpady ,gpadx+4 ,gpady+16,12)
    rectfill(gpadx2+43,gpady2,gpadx2+47,gpady2+16,8)
    rectfill(122,     gpady2,127,     gpady2+16,8)
   end
  end
  fillp()
 end

 local mnu_col=5

 ?"p1:",x,y,mnu_col
 ?(selpad1==1 and "  " or "< ") .. pad1desc[selpad1] .. (selpad1==3 and "  " or " >"),x+20,y,mnu_col+tonum(selline==1)

 ?"p2:",x,y+8,mnu_col
 ?(selpad2==1 and "  " or "< ") .. pad2desc[selpad2] .. (selpad2==3 and "  " or " >"),x+20,y+8,mnu_col+tonum(selline==2)

 ?"time:",x,y+16,mnu_col
 local mt=match_total/30
 print((match_total==0 and "  " or "< ")..mt.."S "..
  (mt==1000and" " or ">")..
  (mt==1000and" ENOGH"or
  (mt== 500and" STOPPIT!"or
 (
  (mt > 350and" BUT WHY?"or
  (mt > 180and" BORING"or""))))
 ),x+20,y+16,mnu_col+tonum(selline==3))

 ?"ball:",x,y+24,mnu_col
 ?balldesc[selball],x+20,y+24,mnu_col+tonum(selline==4)

 ?"mode:",x,y+32,mnu_col
 ?(game_mode==1and"  "or"< ")..gm..(game_mode==4and"  "or" >"),x+20,y+32,mnu_col+tonum(selline==5)

 local desc=game_mode_desc[game_mode]
 ?desc,x+34-#desc*2,y+40,mnu_col
end

function _drw_game()
 --enterprise
 spr(16
    ,-(match_total/4)+
     (match_total-match_timer)
     /match_total*127*18
    ,110-(match_total-match_timer)
     /match_total*5*127)

 --lua
 anglua+=.003
 rotate(3,
   (match_total-match_timer)/match_total*65
   ,-16+(match_timer/2)
   ,anglua
   ,0,2,2)

 drw_stardust()

 --terra
 circfill(64,270+match_timer,160,12)
 circfill(64,272+match_timer,160,6)
 circfill(64,278+match_timer,163,5)

 --satellite
 local nx,ny=
       66+(cos(ti/100))*80,
       150+match_timer+(sin(ti/100))*50
 angspr+=.02
 if(angspr>1)angspr-=1
 rotate(48,nx-8,ny-4,angspr)

 drw_gamescreen()
 drw_scoreboard()

 --xmas tree
 spr(64,48,91+match_timer,4,4)
 drw_gift(53,118+match_timer,1)
 drw_gift(58,121+match_timer,2)
 drw_gift(65,118+match_timer,3)

 drw_audience()
 drw_pads()
 drw_ball()
end

function drw_ball()
 drw_ball_tail()
 for ball in all(balls)do
  ball:drw()
 end
end

tail={}
function drw_ball_tail()
 --add tail
 for ball in all(balls)do
  add(tail,{ball.x+(rnd(3)-1.5)
           ,ball.y+(rnd(3)-1.5)
           ,4+rnd(6)})
 end

 --move
 for i=#tail,1,-1do
  local t=tail[i]
  t[3]-=1
  if t[3]>0then
   pset(t[1],t[2],5+tonum(t[3]>5))
  else
   deli(tail,i)
  end
 end

 --xplode
 for i=#xplode,1,-1do
  s=xplode[i]
  pset(s.x,s.y,s.c)
  if(s.age<=0)deli(xplode,i)
 end
end

function drw_pads()
 for _p in all(p)do
  _p:drw()
 end
end

function drw_gamescreen()
 --progression bar
 local perc=(match_total-match_timer)/match_total
 local col=3
 if perc>.66then
  col=8
 elseif perc>.33then
  col=9
 end

 cprint("スコア    ",1,nil,false,false,true,0,p1.score==p2.score and 7 or p1.score>p2.score and p1.col or p2.col)

 fillp(▤)
 line(63,8,63,127,6)
 line(63,8,63,8+perc*119,col)
 fillp()

 if match_point and ti%30>=15 then
  ?"\^pmatch point",20,119,7
 end
end

function drw_audience()
 if goal>0 then
  if(#balls==1)freeze_timer=-10

  camera((rnd(2)-1),(rnd(2)-1))

  timer+=1

  local clr=iif(goal==1,p1.col,p2.col)
  for i=0,8do
   local i15=i*15
   pal(15,clr)
   --people
   spr(1,i15,119,1,1)
   if i%((p1.score+p2.score)/2)==0then
    --flags
    spr(2,(i15)+8+rnd(3),115)
   else
    --gifts
    drw_gift(i15+4,115+rnd(2),i)
   end
  end
  pal()
  if timer==timergoal then
   goal=0
   timer=0
  end
 else
  camera()
 end
end

function drw_stardust()
 for _p in all(stars)do
  circ(_p.x+sin(t()/1.5),_p.y,_p.r,_p.c)
 end
end

function drw_scoreboard()
 --score board
 ?"\^p" .. p1.score,59-#tostr(p1.score)*6,10,7
 ?"\^p" .. p2.score,68,10,7
end

function drw_gift(x,y,s)
 local pl={{9,10,4,8},
           {7,14,2,12},
           {3,11,5,14},
           {12,9,1,10}}
 local plt=s%4+1
 if plt>1then
  for i=1,4 do
   pal(pl[1][i],pl[plt][i])
  end
 end
 spr(7+(s%5),x,y)
 pal()
end

function drw_score(x,y)

 local function fmt(n)
  local ns=tostr(n)
  while #ns<3 do
   ns=" " .. ns
  end
  return ns
 end

 local y88,y10,y8,x38,x54,x82,x122=y+88,y+10,y+8,x+38,x+54,x+82,x+94

 local l=game_mode+(selball-1)*4

 rectfill(x,y8,x122,y88,8)
 rectfill(x38,y,x122,y8,3)

 if(blink>0)then
  rectfill(x38,y+9+(l*9),x122,y+15+(l*9),2)
  cprint("⬇️➡️ to return  ",120,5,false,false,true,8,3,scorex)
 end

 color(7)

 line(x38,y,x122,y)
 line(x,y8,x122,y8)
 line(x,y+16,x122,y+16)

 fillp(▒)
 rect(x,y+52,x122,y+53)
 fillp()

 line(x,y88,x122,y88)

 line(x,y8,x,y88)
 line(x+30,y8,x+30,y88)
 line(x38,y,x38,y88)
 line(x+80,y,x+80,y88)
 line(x+95,y,x+95,y88)

 ?"mode",x+2,y10
 ?"●",x+31,y10

 ?"cpu",x54,y+2
 ?"qty",x+40,y10
 ?"win",x54,y10
 ?"  %",x+68,y10

 ?"pVp",x+82,y+2
 ?"qty",x+82,y10

 for i=1,8do
  local i9=i*9
  local m=split(matches[i],"|")

  ?game_mode_names[m[1]],x+2,y10+i9
  ?m[2]==1and"r"or"s",x+33,y10+i9

  ?fmt(m[3]),x+40,y10+i9
  ?fmt(m[4]),x54,y10+i9
  if(m[3]>0)?fmt(ceil(m[4]/m[3]*100)),x+68,y10+(i9)

  ?fmt(m[5]),x+82,y10+i9
 end

 for i=1,6do
  spr(37+iif(i%2==0,2),x+(i-1)*16,y88,3,3)
 end

 spr(3,x+27,y-4,2,2)
end
-->8
--player
function create_player(p,mode,control)
 local transf=game_mode>2and p>2
 local x,_g=1,1

 if(p==2)x,_g=121,-1

 if game_mode~=3then
  if(p==3)x,_g=31+iif(transf,-7), 1
  if(p==4)x,_g=91,-1
 else
  if(p==3)x,_g=39+iif(transf,-7),-1
  if(p==4)x,_g=83, 1
 end

 local c=control==0and 12
      or control==1and 14
      or 8

 return{
  p=p,
  x=x,
  y=55,

  goal=_g,

  w=iif(transf,10,5),
  h=iif(transf,12,16),

  y_center=0,
  y_speed=4,

  slw=false,
  y_slw=1,
  y_max=4,

  timer=0,
  rate=iif(game_mode==1,2,3),
  score=0,
  visible=true,
  control=control,
  mode=mode,
  col=c,

  drw=function(s)
   if s.visible then
    rectfill(s.x,s.y-1,s.x+s.w-1,s.y+s.h-1,s.col)
    fillp(▒)
    rectfill(s.x,s.y,s.x+s.w-1,s.y+s.h-2,7)
    fillp()
   end
  end,

  mov=function(s,b)
   s.y_center=s.y+(s.h*.5)

   if s.mode=="sidekick"and s.control==nil then
    if(freeze_timer<0)return

    --freefly
    s.timer+=1
    if s.timer>=s.rate then
     local ball=balls[1]
     local dist_x=abs(s.x-balls[1].x)

     --avoid own goal
     if(sgn(ball.dx)==s.goal)dist_x*=-1

     --closer ball
     for b in all(balls)do
      if dist_x<abs(s.x-b.x) then
       ball=b
       dist_x=abs(s.x-b.x)
      end
     end

     s.timer=0
     local dir=nbool(ball.x<s.x)*s.goal
     s.x+=dir*(s.y_speed/2)*nbool(s.goal~=ball.dx)
    end

   elseif s.mode=="cpu"or s.control==nil then
    if(freeze_timer<0)return
    --soccer/subpong
    s.timer+=1
    if s.timer>=s.rate then
     s.timer=0

     local ball=balls[1]
     local dist_x=abs(s.x-balls[1].x)

     for b in all(balls)do
      if dist_x<abs(s.x-b.x) then
       ball=b
       dist_x=abs(s.x-b.x)
      end
     end

     local dist_y=flr(ball.y-s.y_center)

     --avoid own goal
     if(sgn(ball.dx)==s.goal)then
      dist_y*=-1
      --move
      if
        abs((dist_y/127)-
               (s.h/127))>.15 and
        abs(dist_x)<30 then
       s.y_speed=abs(s.y_speed)*sgn(dist_y)
       s.y+=s.y_speed

       if game_mode~=1then
        if(s.p==1)p1b.y=s.y
        if(s.p==2)p2b.y=s.y
       end
       if game_mode==3 then
        if(s.p==4)p1.y=s.y
        if(s.p==3)p2.y=s.y
       else
        if(s.p==3)p1.y=s.y
        if(s.p==4)p2.y=s.y
       end

      end
     else
      --move
      if abs(dist_y)>s.h/2then
       s.y_speed=abs(s.y_speed)*sgn(dist_y)
       s.y+=s.y_speed

       if game_mode~=1then
        if(s.p==1)p1b.y=s.y
        if(s.p==2)p2b.y=s.y
       end
       if game_mode==3 then
        if(s.p==4)p1.y=s.y
        if(s.p==3)p2.y=s.y
       else
        if(s.p==3)p1.y=s.y
        if(s.p==4)p2.y=s.y
       end
      end
     end

    end
   else
    --controller
    if b==🅾️ or b==❎ then
     s.y_speed=s.y_slw
    else
     s.y_speed=s.y_max
    end

    if s.mode=="sidekick" then
     s.x+=dirx[b+1]*s.y_speed*.7
     s.y-=diry[b+1]*s.y_speed
    else
     s.y+=nbool(b%2~=0)*s.y_speed
    end
   end

   --court collision
   if(s.y<=0)s.y=1
   if(s.y>127-s.h)s.y=127-s.h

   if s.mode=="sidekick"then
    local lim=2.5*s.w
    if(s.x<lim)s.x=lim
    if(s.x>127-s.w-lim)s.x=127-s.w-lim
   end

   --center
   s.y_center=s.y+(s.h*.5)
  end
 }
end
-->8
--ball
function create_ball(_dx,_x,_y)
 ball_color = 10
 ball_speed = 2

 local __dx
 if _dx==nil then
  __dx=sgn(rnd()-.5)*ball_speed
 else
  __dx=sgn(_dx)*ball_speed
  ball_color=9
 end

 return{
  x=_x or 63,
  y=_y or 63,
  h=3,
  w=3,
  r=1,
  dx=__dx,
  dy=rnd(ball_speed*3)-ball_speed,
  c=ball_color,

  drw=function(_ENV)
   rectfill(x-r,y-r,x+r,y+r,c)
  end,

  mov=function(s)
   s.x+=s.dx
   s.y+=s.dy or 0

   if(s.y<=4)then
    sfx(2)
    s.dy=abs(s.dy)
   elseif(s.y>=125)then
    sfx(2)
    s.dy=-abs(s.dy)
   end

   local function reset_ball()
    sfx(3)
    if(s.y<4 or s.y>124)s.y=60
    s.x=63
    s.dx*=-1
    s.dy=rnd(2.5)
    match_point=false
    _drw()
   end

   if s.x<2then
    reset_ball()
    p2.score+=1
    goal=2
   end

   if s.x>=127then
    reset_ball()
    p1.score+=1
    goal=1
   end

  end,

  collide=function(b,p)
   local res,cl=false,false

   local function bounce()
    sfx(0)
    b.dy=min((b.y-p.y_center)/2,3)
    if(cl.top)b.dy=-abs(b.dy)
    if(cl.bot)b.dy= abs(b.dy)
    if(cl.lft)b.dx=-abs(b.dx)
    if(cl.rgt)b.dx= abs(b.dx)
    res=true
   end

   local nb={}
   nb={
     x=b.x-1,
     y=b.y-1,
     h=b.h,
     w=b.w,
     dx=b.dx,
     dy=b.dy}

   cl=check_hcollision(nb,p)

   if cl.c then
    bounce()
   else
    nb={
      x=b.x-1,
      y=b.y-1,
      h=b.h,
      w=b.w,
      dx=b.dx,
      dy=b.dy}

    for newx=b.x
            ,b.x+b.dx
            ,sgn(b.dx)do
     nb.x=newx
     nb.y+=tonum(sgn(b.dy))

     cl=check_hcollision(nb,p)

     if cl.c then
      bounce()
      break
     end
    end
   end

   --stuck ball
   if b.y<0then
    p.y=p.y+b.h+1
   end

   if b.y>127then
    p.y-=-1
   end

   return res
  end
 }
end
-->8
--functions
function iif(a,b,c)
 return a and b or (c or 0)
end

function check_hcollision(b,p)
 local v,f=true,false
 local c={lft=f,
          rgt=f,
          top=f,
          bot=f,
          c=f}

 if b.x+b.w>p.x and
    b.x    <p.x then
  c.lft=v
 elseif b.x    <p.x+p.w and
        b.x+b.w>p.x+p.w then
  c.rgt=v
 end

 if b.y+b.h>p.y and
    b.y    <p.y then
  c.top=v
 elseif b.y    <p.y+p.h and
        b.y+b.h>p.y+p.h then
  c.bot=v
 end

 local aw2,ah2=b.w/2,b.h/2
 local bw2,bh2=p.w/2,p.h/2

 local xd=abs((b.x+aw2)-(p.x+bw2))
 local xs=aw2+bw2
 local yd=abs((b.y+ah2)-(p.y+bh2))
 local ys=ah2+bh2

 c.c=(xd<xs and yd<ys)

 return c
end

function cprint(t,y,bg,wide,tall,outline,c1,c2,ox)
 ox=ox or 0
--t text
--y
--bg background color
--wide
--tall
--outline
--c1,c2 outline colors
 local _c=c1==nil and 7 or c1
 local fat,fath=1,1
 local nt=#t

 if wide then
  t="\^w"..t
  fat=2
 end

 if tall then
  t="\^t"..t
  fath=2
 end

 local _x,_y=65-((nt*4*fat)/2),y

 if bg~=nil then
  if outline then
    rectfill(
     _x-fat+ox
    ,_y-fath
    ,_x+((nt*4*fat))+(1-fat)+ox
    ,_y+(4*fath)+(1+fath)
    ,bg)
  else
   if(bg>9)bg=chr(55+bg)
   t="\#"..bg..t
  end
 end

 if outline then
  for i=1,4 do
   ?t,_x+dirx[i]+ox,_y+diry[i],c2
  end
 end

 ?t,_x+ox,_y,_c
end

function rotate(sp,x,y,ang,t,w,h)
 t=t or 0
 local c,s=cos(ang),sin(ang)
 local _w=(w or 1)*8
 local _h=(h or 1)*8
 local _w2=_w/2
 local _h2=_h/2

 for sy=0,_h do
  for sx=0,_w do
   local dx=sx-_w2
   local dy=sy-_h2
   local tx=(dx*c)-(dy*s)+x+_w2
   local ty=(dx*s)+(dy*c)+y+_h2
   local c=sget((flr(sp%16)*8)+sx,(flr(sp/16)*8)+sy)
   if(c~=t)pset(tx,ty,c)
  end
 end
end

function nbool(b)
 return b and 1or-1
end

function concat_ws(sep,...)
 local args,res={...},""
 for i,v in ipairs(args)do
  if(i>1)res..=sep
  res..=v
 end
 return res
end


function but(...)
 for p=0,1do
  for v in all({...})do
   if(btnp(v,p))return true
  end
 end
 return false
end

-->8
--splash
function init_llp()
 sk=rnd()

 function new_xplod()
  return{
  --constants
  water=split"12,13,12,1,6",
  fire=split"7,8,8,9,9,10,10,6,5,5",
  ice=split"6,7,5",

  --general parameters
  num=20,
  spd=10,
  windspd=0,
  gravity=0,
  age=20,
  aging=true,
  shape=1,
   --1 dots
   --2 line
   --3 circle
   --4 square
  radius=0,
  drwlayer=false,

  --internal use
  parts={},
  palet={},

  boom=function(self,x,y,c,a,d,ma,mxa)
   --c   - color
   --d   - direction
   --a   - angle (1)
   --ma  - min angle (360)
   --mxa - max angle degee (360)
   local _dx,_dy=rnd(),rnd()
   local _ang=nil
   local s=self

   for i=0,s.num do
    --direction
    if a ~=nil then
     _ang=a
    elseif ma~=nil then
     local _mx,_m=mxa/360,ma/360
     _ang=rnd(_mx-_m)+_m
    else
     if d==⬆️ then
      _ang=rnd()/2
     elseif d==⬇️ then
      _ang=1-rnd()/2
     elseif d==⬅️ then
      _ang=0.25+rnd()/2
     elseif d==➡️ then
      _ang=.75+rnd()/2
     elseif d==nil then
      _ang=rnd()
     end
    end

    --color
    local _c={}
    if type(c)=="table"then
     _c=c
    else
     _c={c or rnd(15)}
    end
    s.palet=_c

    local _age=rnd(s.age)

    add(s.parts,{
      x=x or ceil(rnd(127)),
      y=y or ceil(rnd(127)),
      dx=cos(_ang),
      dy=sin(_ang),
      spd=s.spd>0and flr(rnd(s.spd))or 0,
      age=_age,
      mage=_age,
      c=rnd(_c),
      rad=rnd(s.radius)
      })
   end
  end,

  drw=function(self)
   s=self.shape
   if self.drwlayer then
   for c=#self.palet,1,-1do
    for p in all(self.parts)do
     if p.c==self.palet[c]then
      if s==1then
       pset(p.x,p.y,p.c)
      elseif s==2then
       line(p.x,p.y,p.x+(p.dx*p.rad),p.y+(p.dy*p.rad),p.c)
      elseif s==3then
       circfill(p.x,p.y,p.rad,p.c)
      elseif s==4then
       rectfill(p.x,p.y,p.x+p.rad,p.y+p.rad,p.c)
      end
     end
    end
   end
   else
    for p in all(self.parts)do
     if s==1then
      pset(p.x,p.y,p.c)
     elseif s==2then
      line(p.x,p.y,p.x+(p.dx*p.rad),p.y+(p.dy*p.rad),p.c)
     elseif s==3then
      circfill(p.x,p.y,p.rad,p.c)
     elseif s==4then
      rectfill(p.x,p.y,p.x+p.rad,p.y+p.rad,p.c)
     end
    end
   end
  end,

  upd=function(self)
   local s=self
   for x in all(s.parts)do
    --apply gravity
    x.dy+=s.gravity

    --wind
    x.dx+=s.windspd

    --move particle
    x.x+=x.dx*x.spd
    x.y+=x.dy*x.spd

    x.age-=1

    if(x.rad>.2)x.rad-=.2

    if s.aging then
     local ix=ceil((1-x.age/x.mage)*#self.palet)
     x.c=s.palet[ix]
    end

    if(s.spd>0)x.spd+=rnd()/10

    --kill
    if(x.age<=0)del(s.parts,x)
   end
 end
 }
 end

 tx=-30

 mx=38
 my=88
 ang=0

 grndry=100
 grndrx=0

 spark=new_xplod()

 do
  local _ENV=spark
  spd=7
  aging=false
  age=15
  gravity=.1
  num=15
  shape=2
  radius=5
  ice[4]=9
 end

 smoke=new_xplod()
 do
  local _ENV=smoke
  spd=1
  ice[4]=5
  age=25
  num=20
  shape=3
  radius=3
  gravity=-.01
  windspd=.1
 end

 trail=new_xplod()
 do
  local _ENV=trail
  spd=0
  num=1
  age=65
 end

 fx={spark,smoke,trail}

 _drw=_drw_llp
 _upd=_upd_llp
end

function _upd_llp()

 if but(❎,🅾️)then
  if tx<200then
   tx=200
  else
   game_state("menu")
  end
 end

 tx+=1
 if(tx<=0)return
 if tx<25then
  my-=2
 elseif tx<50then
  mx+=2
 elseif tx<75then
  my+=2
 elseif tx<100then
  mx-=2
 elseif tx==190 or tx==210then
  spark.gravity=0
  spark:boom(mx,my,spark.ice,nil,nil,ang,ang+30)
 end

 --cut
 if tx<100then
  ang+=rnd(4)
  trail:boom(mx,my,split"7,8,9,5",0)
  spark:boom(mx,my,spark.ice,nil,nil,ang,ang+30)
 end

 --smoke
 if(tx==125)then
  for i=46,92,2do
   smoke:boom(i,100,smoke.ice,rnd())
  end
 end

 if tx==160then
  mx=60
  my=75
  ang=75
 end

 if tx<100or tx==190or tx==210then
  sfx(21)
 elseif tx==125then
  sfx(20)
 end

 if tx>210then
  grndry-=5
  grndrx+=2.5

  --smoke logo
  if tx==215then
   local f=smoke
   f.radius=5
   f.gravity=-.1
   f.windspd=.01
   f.num=10

   for i=10,120,5do
    f:boom(i,95)
    f:boom(i,105,f.ice,rnd())
   end

  --grinders
   trail.spd=4
   trail.num=14
   trail.age=30
  end
 end

 if tx>=215then
  trail:boom(60,grndry+3)
  trail:boom(50-grndrx,grndry+3)
  trail:boom(70+grndrx,grndry+3,{9,14,2,5})
 end

 if(tx==270)my=0
 if(tx>270)my+=10

 for s in all(fx)do
  s:upd()
 end

 if tx>300then
  game_state("menu")
 end
end

function _drw_llp()
 cls()

 if tx>=125 and tx<=150then
  camera()
  if(tx<150)camera(rnd(2)-1,rnd(2)-1)
 end

 if tx>210 and tx<250then
  sfx(22)
  spr(74,60,grndry,2,2)
  spr(74,50-grndrx,grndry,2,2)
  spr(74,70+grndrx,grndry,2,2)
  rectfill(0,91,127,127,0)
 end

 if tx>=125then
  rectfill(38,40,88,90,6)

  if sk<.125then
   --orion
   pal(4,3)
   pal(15,11)
  elseif sk <.25then
  --andorian
   pal(4,10)
   pal(6,9)
   pal(15,12)
  elseif sk<.625then
  --afro
   pal(4,9)
   pal(15,4)
  end
  spr(76,42,67,3,3)
  spr(79,48,62,1,1)
  pal()

  spr(64,60,59,4,4)
  --door
  line    (46,102,38,92,1)
  rectfill(46,102,97,103,1)
 end

 if(tx>215)cprint("abrasive games",94,nil,true,true,true,3,9)

 if tx>270then
  rectfill(0,127,127,127-my,0)

  for i=5,125,5do
   smoke:boom(i,127-my,smoke.ice,rnd())
  end

  drw_logo()
 end

 for s in all(fx)do
  s:drw()
 end
end


__gfx__
00000000000085000fe0000000000000000000000000000000000000008000000000000000000000000000000000000000cccc0000bbbb000000000000eeee00
0000000000088000f00f0000000000000000000000000cc555c0000000080800008080000080800000000000000000000c0000c00b0000b000a000a00e0000e0
0070070000566500e00e000000000000003333000000ccc5555c00000048800000080000000800000000000000008080c000000cb000000b0a0a00a0e000000e
0007700000c77c07f000000000008880333b300000055ccc555556000498a4009a98a9a4099899400080800080800800c000000cb000000b0a0a00a0e000000e
000770007066660fe0000000000878880b33000000055ccc5555506049a89a40a9a89a940998994000080000080aa8a9c000000cb000000b0a0a00a0e0000000
00700700f066660ff0000000000868880030000000ccccccc55556004a98a9409a98a9a4099899409a98a9a49894a8a9c500000cb300000b0a0a00a0e0000000
000000000ff66ff0e0000000000888820888000000ccccccc555750004a89400a9a89a9409989940a9a89a949894a8a9cc5555c00b3333b00a0a00a0e0000000
0000000000ffff00f0000000000022208788800000ccc555557555000048400000000000000000000000000098940000c0cccc0000bbbb000a0a00a0e000ee00
060006000000000000000000003008880688800000ccc555575555000000000000000000000000000000000000000000c00000000b0000b00a0a00a0e00e00e0
0f0000600000000000000000033b8788888820000655555655555c000000000000000000000000000000000000000000c0000000b000000b0a00a0a0e000000e
08050044000000000000000003b386888222000006055675555550000000000000000000000000000000000000000000c0000000b000000b0a00a0a0e000000e
8580444400000000000000000333888820300000006c6cccccc5c0000000000000000000000000000000000000000000c0000000b000000b0a00a0a0e000000e
8880044000000000000000003330022203b330000000cccccccc00000000000000000000000000000000000000000000c0000000b300000b0a00a0a0e200000e
55504040000000000000000033000000333b300000000cccccc000000000000000000000000000000000000000000000c00000000b3333b00a009aa00e2222e0
000000000000000000000000000000000033330000000000000000000000000000000000000000000000000000000000c000000000bbbb000a00090000eeee00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000000000000000000000000000000000000000000940000000000000099000000000000000000000000000000000000000000000000000000000000000
00055000000500000000000000000000000000000000009004000000000000900900000000000000000000000000000000000000000000000000000000000000
0085677000855c760000000000000000000000000000288888820000000028888882000000000000000000000000000000000000000000000000000000000000
00056c76008566600085c7600000000000000000000289898a8a2000000289898a8a200000000000000080000000000000000000000000000000000000000000
008566600005500000056000000000000000000000289898a8a8820000289898a8a8820000000000000888000000000000000000000000000000000000000000
00055000000500000050000000000000000bbb000088888888888800008888888888880000000000000888800000000000000000000000000000000000000000
000500000000000000000000000000bbbbb330000288888888888820028886888886882000000000008888880000000000000000000000000000000000000000
000000000000000000000000000bbb00000b00000888888888888880088888688888688000000000008888880888880000000000000000000000000000000000
0076677000000000000000000000b000003000000888888888888880048588448588448000000000088888a88088888000000000000000000000000000000000
00067670000000000000000000030000088800000888888888888880048844448844448000000000088888a88888888800000000000000000000000000060000
00088880000000000000000000888000878880000888888888888880088884488884488000000000888888888888880000000000000000004040040400008000
00088880000000000000000008788800868880000288888888888820028848488848482000000000088888888888880000000000000000000400004000008200
00088880000000000000000008688800888820000088888888888800008888888888880000000000088888888888880000000000000000004400004400008200
0288888000000000000000000888820002220000002889898a8a8200002889898a8a820000000000088888888888880000000000000000000040040000088820
088888800000000000000000002220000000000000029898a8a8200000029898a8a8200000000000088888888888880000000000000000000340043000888820
02888820000000000000000000000000000000000000288888820000000028888882000000000000333333333333330000000000000000000080080007677760
00000000000000000000000000000000000000000000000000000000000000000000000000000000500085550000000000000000444040000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000550855655000000000000004044440000000000007682000
00000000000000a00000000000000000000000000000000000000000000000000000000000000000055856565000000000000045445450000000000007788200
0000000000000a6a000000000000000000000000000000000000000000000000000000000000000000585565580000000000005555555000000000000008e200
00000000000000a00000000000000000000000000000000000000000000000000000000000000000008885558000000000000d666f666d00000000000008e200
00000000000000330000000000000000000000000000000000000000000000000000000000000000088888880000000000000d6776776d000000000000888e20
00000000000003333000000000000000000000000000000000000000000000000000000000000000888888000000000000000d677f776d000000000008888e20
00000000000003b3300000000000000000000000000000000000000000000000000000000000000008888000000000000000001fffff10000000000076777770
00000000000003833000000000000000000000000000000000000000000000000000000000000000008800000000000000000011111110000000000000000000
00000000000038883300000000000000000000000000000000000000000000000000000000000000000000000000000000000011111110000000000000000000
00000000000033833300000000000000000000000000000000000000000000000000000000000000000000000000000000000001111100085550000000000000
00000000000033333300000000000000000000000000000000000000000000000000000000000000000000000000000000eeddefffffed855655000000000000
0000000000033333333000000000000000000000000000000000000000000000000000000000000000000000000000000eeeddeefffeed856565000000000000
0000000000033b33333000000000000000000000000000000000000000000000000000000000000000000000000000000eeeddeeeeeeed855655800000000000
000000000003333333300000000000000000000000000000000000000000000000000000000000000000000000000000eeeeddddddddd8885558000000000000
000000000033333b33800000000000000000000000000000000000000000000000000000000000000000000000000000eeeeddaaaaaa8888888e000000000000
0000000000333b3338880000000000000000000000000000000000000000000000000000000000000000000000000000eef0ddaaaaa8888883eee00000000000
000000000033833333830000000000000000000000000000000000000000000000000000000000000000000000000000eeffffffffaa888803fee00000000000
000000000338883b33333000000000000000000000000000000000000000000000000000000000000000000000000000effffffffff118800f3fe00000000000
0000000003338333333330000000000000000000000000000000000000000000000000000000000000000000000000000000daaaff111ad000ffe00000000000
00000000033b3b33333330000000000000000000000000000000000000000000000000000000000000000000000000000000daaaa111aad000fff00000000000
00000000333333333b3333000000000000000000000000000000000000000000000000000000000000000000000000000000d55ddd155dd00000000000000000
0000000033b33333333333300000000000000000000000000000000000000000000000000000000000000000000000000000d55dddd55dd00000000000000000
000000033383333b333b833000000000000000000000000000000000000000000000000000000000000000000000000000005555555555500000000000000000
000000033888b3333338883300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000333383b3b333338b3330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000333b333333b8b333b330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000003b3333333b38883333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000333333333338333333b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000004494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
0000000000000000000000000000000000000000000000000000888880008888800088888b300000000000000006060000000000000000000000000000000000
00000000000000000000000000000000000000000000000000080000080800000808000008000000000000000000600000000000000000000000000000000000
00000000000000007000000000000000000000000000000000008888080088880800888808000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000080800000080800808080000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000008800800088880800808800000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000080088080800000808080000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000008800800088888000800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000606080000007000000000000000000000000000000000000000000000000700000000
00000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000007070000000
00000000000000000000000000000000000000000000000000000700070000080000707070000000000000000000000000000000000000000000000700000000
00000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000700070000080000700000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000707070000080000707070000000000000000000000000000006000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000080000000070000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000070000080000707070000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000005000000000000000000000000000
00000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000
00006060000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000700000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000000700000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000700000000000000000000007070000
00000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000700000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000060000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000006060000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000600000000000000000000000000000000000000000000000000000
0ccccc00000000000000000000000000000000000000000000000000000000000000000006060000000000000000000000000000000000000000000000000000
0c7c7c00000060000000000000000000000000000000000000000000000000080000000000600000000000000000000000000000000000000000000000000000
07c7c700000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c7c7c00000060000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
07c7c700000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccc00000000000000000000000000000000000
0c7c7c00000000000000000000000000888888888800000000000000000000080000000050000000000c7c7c7c7c700000000000000000000000000008888800
07c7c7000000000000000000000000008787878787000000000000000000000000000000000000000007c7c7c7c7c00000000000000000000000000007878700
0c7c7c00000000000000000000000000787878787800000000000000000000080000000000000000000c7c7c7c7c700000000000000000000000000008787800
07c7c7000000000000000000000000008787878787000000000000000000000000000000000000000007c7c7c7c7c00000000000000000000000000007878700
0c7c7c00000000000000000000000000787878787800000000000000000000080000000000000000000c7c7c7c7c700000000000000000000000000008787800
07c7c7000000000000000000000000008787878787000000000000000000000000000000000000000007c7c7c7c7c00000000000000000000000000007878700
0c7c7c00000000000000000000000000787878787800000000000000000000080000000000700000000c7c7c7c7c700000000000000000000000000008787800
07c7c7000000000000000000000000008787878787000000000000000000000000000000070700000007c7c7c7c7c00000000000000007000000000007878700
0c7c7c00000000000000000000000000787878787800000000000000000000080000000000700000000c7c7c7c7c700000000000000070700000000008787800
07c7c7000000000000000000000000008787878787000000000000000000000000000000000000000007c7c7c7c7c00000000000000007000000000007878700
0c7c7c00000000000000000000000000787878787800000000000000000000080000000000000000000c7c7c7c7c700000000000000000000000000008787800
0ccccc00000000000000000000000000878787878700000000000000000000000000000000000000000cccccccccc00000000000000000000000000007878700
00000000000000000000000000000000888888888800000000000000000000080000000000000000000000000000000000000000000000000000000008787800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007878700
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000008787800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007878700
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000008888800
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000060000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000500000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000760000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000087070000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000
00000000000000005000000000000000000000000000000000000000000000080000000000000000000500000000000000000000000000000000000000000000
00000000000000050500000000000000000000000000000000000000000000000000000000000000005050000000000000000000000000000000000000000000
00000000000000005000000000000000000000000000000000000000000000080000000000000000000500000000000000000000000000000000000000000000
00000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000a80000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000a6a0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000a80000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000005003333000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000006000000000000000000000000000003b33000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000003833000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000038883300000000000000000000000000000000000000000000000000000000000000
0000aaa0000000000000000000000000000000000000000000000000000033833300000000000000000000000000000000000000000000000000000000000000
0000aaa0000000000000000000000000000000000000000000000000000033333300000000000000000000000000000000000000000000000000000000000000
0000aaa0000000000000000000000000000000000000000000000000000333333330000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000033b333330000000000000000000000000000000000000000000600000000000000000
00000000506000000000000000000000000000000000000000000000000333333330000000000000070000000000000000000000000006060000000000000000
000000000000500000000000000000000000000000000000000000000033333b3380000000000000000000000000000000000000000000600000000000000000
0000000000000000000000000000000000000000000000000000000000333b333888000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000003383333383000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000338883b3333300000000000000000000000000000000000000000000000000000000000
0000000000000000500000000000000000000000000000000000ccccc333833333333cccccccc000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000cccccccccccccc33b3b3333333ccccccccccccccccc000000000000000000000000000000000000000000
000000000000000000000000000000000000cccccccccccccccc6666333333333b33336666666cccccccccccccccc00000000000000000000000000000000000
0000000000000000000000000000000cccccccccccc666666666666633b333333333333666666666666666cccccccccccc000000000000000000000000000000
000000000000000000000000000ccccccccc666666666666666666633383333b333b8336666666666666666666666ccccccccc00000000000000000000000000
00000000000000000000000cccccccc66666666666666666666655533888b3333338883355555666666666666666666666cccccccc0000000000000000000000
0000000000000000000cccccccc666666666666666555555555555333383b3b333338b33355555555555555666666666666666cccccccc000000000000000000
0000000000000000ccccccc6666666666666555555555555555555333b333333b8b333b33555555555555555555556666666666666ccccccc000000000000000
0000000000000cccccc66666666666655555555555555555555553b3333333b38883333335555555555555555555555555666666666666cccccc000000000000
0000000000cccccc666666666655555555555555555555555555553c3c33333338333333b5555555555555555555555555555556666666666cccccc000000000
0000000cccccc6666666666555555555555555555555555555555555c55554494555555555555555555555555555555555555555556666666666cccccc000000
00000ccccc66666666655555555555555555555555555555555557e7ce7e2449455a5a5555555555555555555555555555555555555555666666666ccccc0000
000cccc6666666665555555555555555555555555555555555555e7ec7e7e4e94555a55555555555555555555555555555555555555555555666666666cccc00

__sfx__
000100002805000000000002100025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c0500e0501005011050000000c05011050110000c0000e00010000110000c00011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001362019610136201961012620196101162018600126000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400001b0501b0501b050180501b05018050130500f0500c0000700007000050000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000515005150051500515000100001000010000100051500515005150051500010000100001000010005150051500515005150001000010000100000000000000000000000000000000000000000000000
0006000027053270532c0532c05326053260530000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
041400000c7320c732117320c7320773207732117020c702077320773207700077000770007700007020070210732107321373210732097320973200702007020973209732097000970009700097000070200702
00060000356502e65029640246301f630156300b63013620086200a61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000356512e65129641246311f631156310b63113621086210a6110a6110a6010060000600006001d6001f60022600246002760027600296002b6002e6003060033600356003760037600376000000000000
00100000036500565007650076500a6500c6501165013650166501b6501d650226502465029650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ab0a00002f2512b2512825124251212511d2511a25100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201002010020100201
013c0000115501155011550135001155011550115500050011550135500e550105501155010500135501355013550005001155011550115500050010550115501055011550105500050015550005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020600001425315253172531a2531e253002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
020600001b2531d25322253272532b263000000020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
020600001465315653176531a6531e653006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
__music__
06 07424344

