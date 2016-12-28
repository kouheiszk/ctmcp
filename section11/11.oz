{Browse 1}

### 11.3.2 宣言的データを共有すること

declare
X=the_novel(text:"It was a dark and stormy night. ..."
	    author:"E.G.E. Bulwer-Lytton"
	    year:1803)
{Browse {Connection.offerUnlimited X}}



### 11.3.3 チケット配布

declare
proc {Offer X FN}
   {Pickle.save {Connection.offerUnlimited X} FN}
end

declare
fun {Take FNURL}
   {Connection.take {Pickle.load FNURL}}
end


### 11.3.4 ストリーム通信

declare Xs Sum in
{Offer Xs tickfile}
fun {Sum Xs A}
   case Xs of X|Xr then {Sum Xr A+X} [] nil then A end
end
{Browse {Sum Xs 0}}



## 11.4 状態の分散

### 11.4.1 分散ロック

declare
class Coder
   attr seed
   meth init(S) seed:=S end
   meth get(X)
      X=@seed
      seed:=(@seed*1234+4449) mod 33667
   end
   meth peek
      {Browse @seed}
   end
end

C={New Coder init(100)}
{Offer C tickfile}


### 11.4.2 分散字句的スコープ

declare
C={NewCell 0}
fun {Inc X} X+@C end
{Offer C tickfile1}
{Offer Inc tickfile2}


## 11.5 ネットワークアウェアネス


## 11.6 共通分散プログラミングパターン

### 11.6.1 静止オブジェクトとモバイルオブジェクト

declare
fun {NewStat Class Init}
   P Obj={New Class Init} in
   thread S in
      {NewPort S P}
      for M#X in S do
	 try {Obj M} X=normal
	 catch E then X=exception(E) end
      end
   end
   proc {$ M}
      X in
      {Send P M#X}
      case X of normal then skip
      [] exception(E) then raise E end end
   end
end

declare
C={New Coder init(100)}
{Offer C tickfile1}


declare
C={NewStat Coder init(100)}
{Offer C tickfile2}


### 11.6.2 非同期オブジェクトとデータフロー

declare
fun {NewActive Class Init}
   Obj = {New Class Init}
   P
in
   thread S in
      {NewPort S P}
      for M in S do {Obj M} end
   end
   proc {$ M} {Send P M} end
end

declare
C={NewActive Coder init(100)}
{Offer C tickfile}


### 11.6.3 サーバ

#### 計算サーバ

declare
class ComputeServer
   meth init skip end
   meth run(P) {P} end
end
C={NewStat ComputeServer init}
{Offer C tickfile}


#### 資源を使う分散プログラミング

declare S P in
{NewPort S P}
{Offer proc {$ M} {Send P M} end tickfile}
for X in S do {Browse X} end

declare Browse2 in
Browse2={Take t_browse2}
{Browse2 9876543210}



declare
class ComputeServer
   meth init skip end
   meth run(F) {Module.apply [F] _} end
end
C={NewStat ComputeServer init}
{Offer C tickfile}

{Browse OS.time}



#### 動的改良可能計算サーバ


declare
proc {MakeStat PO ?StatP}
   S P={NewPort S}
   N={NewName}
in 
   % Client side:
   proc {StatP M}
   R in 
      {Send P M#R}
      if R==N then skip else raise R end end 
   end 
   % Server side:
   thread 
      {ForAll S
       proc {$ M#R}
          thread 
             try {PO M} R=N catch X then R=X end 
          end 
       end}
   end 
end


declare
proc {NewUpgradableStat Class Init ?Upg ?Srv}
   Obj={New Class Init}
   C={NewCell Obj}
in
   Srv={MakeStat
	proc {$ M} {@C M} end}
   Upg={MakeStat
	proc {$ Class2#Init2}
	   C:={New Class2 Init2} end}
end

declare Srv Upg in
Srv={NewUpgradableStat ComputeServer init Upg}

declare
class CComputeServer from ComputeServer
   meth run(P Prio<=medium)
      thread
	 {Thread.setThisPriority Prio}
	 ComputeServer, run(P)
      end
   end
end

{Upg CComputeServer#init}



### 11.6.4 クローズド分散


declare
R={New Remote.manager init}

declare
RR={New Remote.manager init(host:'hoge.fuga.moga.com')}



## 11.8 部分的失敗

### 11.8.2 失敗処理の簡単な場合

#### 問題を検出し、行動を起こすこと

declare S P in
{NewPort S P}
{Offer proc {$ M} {Send P M} end tickfile}
for X in S do {Browse X} end



declare
fun {NewStat Class Init}
   Obj={New Class Init}
   P
in
   thread S in
      {NewPort S P}
      for M#X in S do
         try {Obj M} X=normal
         catch E then
            try X=exception(E)
            catch system(dp(...) ...) then
                  skip % クライアントの失敗を検出
            end
         end
      end
   end
   proc {$ M}
   X in
      try {Send P M#X} catch system(dp(...) ...) then
          raise serverFailure end
      end
      case X of normal then skip
      [] exception(E) then raise E end end
   end
end


declare
C={NewStat ComputeServer init}
{Offer C tickfile}



## 11.11

#### 分散リフト制御システム

declare
fun {NewPortObject Init Fun}
Sin Sout in
    thread {FoldL Sin Fun Init Sout} end
    {NewPort Sin}
end

fun {NewPortObject2 Proc}
Sin in
    thread for Msg in Sin do {Proc Msg} end end
    {NewPort Sin}
end

fun {Timer}
   {NewPortObject2
    proc {$ Msg}
       case Msg of starttimer(T Pid) then
          thread {Delay T} {Send Pid stoptimer} end
       end
   end}
end


% Documents/workspace/src/github.com/kouheiszk/ctmcp/section11
% controller
% floor
% lift
% building

declare Building F L in
Building={Take building}
{Building 10 2 F L}

{Send F.9 call}
{Send F.10 call}
{Send L.1 call(4)}
{Send L.2 call(5)}


%%%% 簡単なチャットルーム

declare
class ChatRoom
   meth init skip end
   meth run(F) {Module.apply [F] _} end
end
C={NewStat ComputeServer init}
{Offer C tickfile}



declare
class ChatRoom
   attr clients
   attr messages
   meth init skip end
   meth connect(C)
      clients:=@clients|C
      {SendMessages C @messages}
   end
   meth post(M)
      messages:=@messages|M
      {SendMessage @clients}
   end
   proc {SendMessage Cs M}
      case Cs
      of nil then skip
      [] X|Cr then
	 {X display(M)}
	 {SendMessage Cr M}
      end
   end
   proc {SendMessages C Ms}
      case Ms
      of nil then skip
      [] X|Mr then
	 {C display(X)}
	 {SendMessages C Mr}
      end
   end
end
R={NewStat ChatRoom init}
{Offer R tickfile}


declare
class Client
   attr room
   meth init(R)
      room:=R
      {@room connect(self)}
   end
   meth display(M)
      {Browse M}
   end
   meth post(M)
      {@room post(M)}
   end
end
