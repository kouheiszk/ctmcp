%%% 7.8.1 例

declare
class BallGame
   attr other count:0
   meth init(Other)
      other:=Other
   end
   meth ball
      count:=@count+1
      {@other ball}
   end
   meth get(X)
      X = @count
   end
end
B1={NewActive BallGame init(B2)}
B2={NewActive BallGame init(B1)}

{B1 ball}

declare X in
{B1 get(X)}
{Browse X}


%%% 7.8.2 NewActive抽象

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


%%% 7.8.3 フラウィウス・ヨセフスの問題

declare
class Victim
   attr ident step last succ pred alive:true
   meth init(I K L) ident:=I step:=K last:=L end
   meth setSucc(S) succ:=S end
   meth setPred(P) pred:=P end
   meth kill(X S)
      if @alive then
	 if S==1 then @last=@ident
	 elseif X mod @step==0 then
	    alive:=false
	    {@pred newsucc(@succ)}
	    {@succ newpred(@pred)}
	    {@succ kill(X+1 S-1)}
	 else
	    {@succ kill(X+1 S)}
	 end
      else {@succ kill(X S)} end
   end
   meth newsucc(S)
      if @alive then succ:=S
      else {@pred newsucc(S)} end
   end
   meth newpred(P)
      if @alive then pred:=P
      else {@succ newpred(P)} end
   end
end

declare
fun {Josephus N K}
   A={NewArray 1 N null}
   Last
in
   for I in 1..N do
      A.I:={NewActive Victim init(I K Last)}
   end
   for I in 2..N do {A.I setPred(A.(I-1))} end
   {A.1 setPred(A.N)}
   for I in 1..(N-1) do {A.I setSucc(A.(I+1))} end
   {A.N setSucc(A.1)}
   {A.1 kill(1 N)}
   Last
end

declare
L={Josephus 40 3}
{Browse L}

% 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
% 1 2 x 4 5 x 7 8 x 10 11  x 13 14  x 16 17  x 19 20
% x 2   4 x   7 8    x 11    13  x    16 17     x 20
%   2   x     7 8       x    13       16  x       20
%   2         x 8            13        x          20
%   2           x            13                   20
%   x                        13                   20
%                             x                    L

% 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
% 1 2 x 4 5 x 7 8 x 10 11  x 13 14  x 16 17  x 19 20
% x 2 x x 5 x x 8 x  x 11  x  x 14  x  x 17  x  x 20
% x x x x x x x x x  x  x  x  x  x  x  x  x  x  x 20


%%%% 宣言的モデルによる解

declare
fun {Pipe Xs L H F}
   if L=<H then {Pipe {F Xs L} L+1 H F} else Xs end
end

declare
fun {Josephus2 N K}
   fun {Victim Xs I}
      if I == 20 then
	 {Browse Xs.1}
      end
      case Xs of kill(X S)|Xr then
	 if S==1 then Last=I nil % 残りが1つだったらLastにI入れてnilを返す
	 elseif X mod K==0 then
	    kill(X+1 S-1)|Xr % 死んだら自分の次に回して、残りのストリームをくっつけておく
	 else
	    kill(X+1 S)|{Victim Xr I} % 生き残ったら自分の次に回して、自分にまた順番が回ってくるようにして
	 end
      [] nil then nil end
   end
   Last Zs
in
   Zs={Pipe kill(1 N)|Zs 1 N
       fun {$ Is I} thread {Victim Is I} end end}
   Last
end

declare 
L2={Josephus2 20 3}
{Browse L2}


%%% 7.8.4 その他の能動的オブジェクト抽象

%%%% 同期的能動的オブジェクト

declare
fun {NewSync Class Init}
   P Obj={New Class Init} in
   thread S in
      {NewPort S P}
      for M#X in S do {Obj M} X=unit end
   end
   proc {$ M} X in {Send P M#X} {Wait X} end
end


%%%% 例外処理を行う能動的オブジェクト

declare
fun {NewActiveExc Class Init}
   P Obj={New Class Init} in
   thread S in
      {NewPort S P}
      for M#X in S do
	 try {Obj M} X=normal
	 catch E then X=exception(E) end
      end
   end
   proc {$ M X} {Send P M#X} end
end



%%% 7.8.5 能動的オブジェクトを使うイベントマネージャー

declare
class EventManager
   attr handlers
   meth init handlers:=nil end
   meth event(E)
      handlers:={Map @handlers fun {$ Id#F#S} Id#F#{F E S} end}
   end
   meth add(F S ?Id)
      Id={NewName}
      handlers:=Id#F#S|@handlers
   end
   meth delete(DId ?DS)
      handlers:={List.partition
		 @handlers fun {$ Id#F#S} DId==Id end [_#_#DS]}
   end
end

declare
EM={NewActive EventManager init}


%%%% エラーロギングに使ってみる

declare
MemH=fun {$ E Buf} E|Buf end
Id={EM add(MemH nil $)}
{Browse Id}


declare
File={New Open.file init(name: 'event.log' flags:[write create])}
Buf={EM delete(Id $)}
for E in {Reverse Buf} do {File write(vs:E)} end


declare
DiskH=fun {$ E F} {F write(vs:E)} F end
Id2={EM add(DiskH File $)}
{Browse Id2}


%%%% 継承を使って機能を追加すること

declare
class ReplaceEventManager from EventManager
   meth replace(NewF NewS OldId NewId insert:P<=proc {$ _} skip end)
      Buf=EventManager,delete(OldId $)
   in
      {P Buf}
      NewId=EventManager,add(NewF NewS $)
   end
end

declare
EM={NewActive ReplaceEventManager init}

declare
MemH=fun {$ E Buf} E|Buf end
Id={EM add(MemH nil $)}
{Browse Id}

declare
DiskH=fun {$ E S} {S write(vs:E)} S end
File={New Open.file init(name:'event.log' flags:[write create])}
Id2

{EM replace(DiskH File Id Id2 insert:
				 proc {$ S}
				    for E in {Reverse S} do
				       {File write(vs:E)} end
				 end)}
{Browse Id2}


%%%% mixinクラスを使うバッチ操作

declare
class Batcher
   meth batch(L)
      for X in L do
	 if {IsProcedure X} then {X} else {self X} end
      end
   end
end
class BatchingEventManager from EventManager Batcher end

declare
EM={NewActive BatchingEventManager init}

declare
MemH=fun {$ E Buf} E|Buf end
Id={EM add(MemH nil $)}
{Browse Id}

declare
DiskH=fun {$ E S} {S write(vs:E)} S end
File={New Open.file init(name:'event.log' flags:[write create])}
Buf Id2

{EM batch([delete(Id Buf)
	   proc {$}
	      for E in {Reverse Buf} do {File write(vs:E)} end
	   end
	   add(DiskH File Id2)])}
{Browse Id2}



%% 7.9 練習問題

%%%% 問題5

declare
fun {NewPortObject2 Proc}
   Sin in
   thread for Msg in Sin do {Proc Msg} end end
   {NewPort Sin}
end

declare
proc {ServerProc Msg}
   case Msg
   of calc(X Y) then
      Y=X*X+2.0*X+2.0
   end
end
Server={NewPortObject2 ServerProc}

declare
proc {ClientProc Msg}
   case Msg
   of work(Y) then Y1 Y2 in
      {Send Server calc(10.0 Y1)}
      {Wait Y1}
      {Send Server calc(20.0 Y2)}
      {Wait Y2}
      Y=Y1+Y2 % 564
   end
end
Client={NewPortObject2 ClientProc}

{Browse {Send Client work($)}}


declare
class Server
   attr f
   meth init(F)
      f:=F
   end
   meth calc(X Y)
      Y={@f X}
   end
end
S={NewSync Server init(fun {$ X} X*X+2.0*X+2.0 end)}

declare
class Client
   attr server
   meth init(S)
      server:=S
   end
   meth work(Y)
      Y={@server calc(10.0 $)}+{@server calc(20.0 $)}
   end
end
C={NewActive Client init(S)}      
      
declare
{Browse {C work($)}} % 564


%%%% 問題6(a)


%%%%% 短絡しないパターン

declare
class Victim
   attr kill last number still array step:0
   meth init(N K L)
      number:=N
      still:=N
      kill:=K
      last:=L
      array:={NewArray 1 N null}
      for I in 1..N do
	 @array.I:=true
      end
   end
   meth kill
      local B in
	 for while:@still>1 do
	    for I in 1..@number break:B do
	       if @array.I then
		  step:=@step+1
		  if @still==1 then
		     @last=I
		     {B}
		  elseif @step mod @kill==0 then
		     @array.I:=false
		     still:=@still-1
		  end
	       end
	    end
	 end
      end
   end
end

declare
fun {Josephus3 N K}
   V
   Last
in
   V={New Victim init(N K Last)}
   {V kill}
   Last
end

declare L T1 T2
T1 = {Property.get 'time.total'}
L={Josephus3 40 3}
T2 = {Property.get 'time.total'}
{Browse L}
{Browse 'Total Time = '#(T2-T1)}

%%%%% 短絡するパターン

declare
class Victim
   attr ident step last succ pred alive:true
   meth init(I K L) ident:=I step:=K last:=L end
   meth setSucc(S) succ:=S end
   meth setPred(P) pred:=P end
   meth kill(X S)
      if @alive then
	 if S==1 then @last=@ident
	 elseif X mod @step==0 then
	    alive:=false
	    {@pred newsucc(@succ)}
	    {@succ newpred(@pred)}
	    {@succ kill(X+1 S-1)}
	 else
	    {@succ kill(X+1 S)}
	 end
      else {@succ kill(X S)} end
   end
   meth newsucc(S)
      if @alive then succ:=S
      else {@pred newsucc(S)} end
   end
   meth newpred(P)
      if @alive then pred:=P
      else {@succ newpred(P)} end
   end
end

declare
fun {Josephus4 N K}
   A={NewArray 1 N null}
   Last
in
   for I in 1..N do
      A.I:={New Victim init(I K Last)}
   end
   for I in 2..N do {A.I setPred(A.(I-1))} end
   {A.1 setPred(A.N)}
   for I in 1..(N-1) do {A.I setSucc(A.(I+1))} end
   {A.N setSucc(A.1)}
   {A.1 kill(1 N)}
   Last
end

declare
L={Josephus4 40 3}
{Browse L}


declare L T1 T2
T1 = {Property.get 'time.total'}
L={Josephus4 40000 900}
T2 = {Property.get 'time.total'}
{Browse L}
{Browse T1}
{Browse T2}
{Browse 'Total Time = '#(T2-T1)}



% 短絡しないパターンはクラスに属性いっぱい持たせて複雑になってる感じ
% 短絡しないパターンは同じに書けない
% 短絡するパターンは同じに書ける

%%%% 問題6(b)


