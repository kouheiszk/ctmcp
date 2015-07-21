% 6 明示的状態

%%% 6.1.1 暗黙的状態

declare
fun {SumList Xs S}
   case Xs
   of nil then S
      [] X|Xr then {SumList Xr X+S}
   end
end

{Browse {SumList [1 2 3 4] 0}}

%%% 6.1.2 明示的状態

declare
local
   C = {NewCell 0}
in
   fun {SumList Xs S}
      C := @C + 1
      case Xs
      of nil then S
      [] X|Xr then {SumList Xr X+S}
      end
   end
   fun {SumCount}
      @C
   end
end

{Browse {SumList [1 2 3 4] 0}}
{Browse {SumCount}}

%%% 6.3.3 宣言的プログラミングとの関係

declare
fun {Reverse Xs}
   Rs = {NewCell nil}
in
   for X in Xs do Rs := X|@Rs end
   @Rs
end

{Browse {Reverse [1 2 3 4]}}

%%% 6.3.4 共有と同等

%%%% 共有

declare X Y in
X = {NewCell 0}
Y = X

Y := 10
{Browse @X}


%%%% 同等

declare X Y in
X = person(age:25 name:"George")
Y = person(age:25 name:"George")

{Browse X==Y}


declare X Y in
X = {NewCell 10}
Y = {NewCell 10}

{Browse X==Y}
{Browse @X==@Y}


%%% 6.4.2 スタックの変種

%%%% 開放的宣言的スタック

declare
local
   fun {NewStack} nil end
   fun {Push S E} E|S end
   fun {Pop S ?E}
      case S
      of X|S1 then
	 E = X
	 S1
      end
   end
   fun {IsEmpty S} S == nil end
in
   Stack=stack(new:NewStack push:Push pop:Pop isEmpty:IsEmpty)
end

declare S0 S1 S2 S3 A in
S0 = {Stack.new}
S1 = {Stack.push S0 1}
S2 = {Stack.push S1 2}
S3 = {Stack.pop S2 A}

{Browse S0}
{Browse S1}
{Browse S2}
{Browse S3}


%%%% 安全で宣言的な、バンドルされていないスタック

declare
proc {NewWrapper Wrap Unwrap}
   Key = {NewName} in
   fun {Wrap X}
      {Chunk.new w(Key:X)}
   end
   fun {Unwrap W}
      try W.Key catch _ then raise error(unwrap(W)) end end
   end
end


declare
local Wrap Unwrap
   {NewWrapper Wrap Unwrap}
   fun {NewStack} {Wrap nil} end
   fun {Push S E} {Wrap E|{Unwrap S}} end
   fun {Pop S ?E}
      case {Unwrap S}
      of X|S1 then
	 E = X
	 {Wrap S1}
      end
   end
   fun {IsEmpty S} {Unwrap S} == nil end
in
   Stack=stack(new:NewStack push:Push pop:Pop isEmpty:IsEmpty)
end

declare S0 S1 S2 S3 A in
S0 = {Stack.new}
S1 = {Stack.push S0 1}
S2 = {Stack.push S1 2}
S3 = {Stack.pop S2 A}

{Browse S0}
{Browse S1}
{Browse S2}
{Browse S3}
{Browse A}


%%%% 安全で宣言的な、バンドルされているスタック

declare
local
   fun {StackObject S}
      fun {Push E} {StackObject E|S} end
      fun {Pop ?E}
	 case S
	 of X|S1 then
	    E = X
	    {StackObject S1}
	 end
      end
      fun {IsEmpty} S == nil end
   in
      stack(push:Push pop:Pop isEmpty:IsEmpty)
   end
in
   fun {NewStack} {StackObject nil} end
end


declare S1 S2 S3 E in
S1 = {NewStack}
{Browse {S1.isEmpty}}
S2 = {S1.push 23}
S3 = {S2.pop E}
{Browse E}


%%%% 安全で状態ありの、バンドルされているスタック

declare
fun {NewStack}
   C = {NewCell nil}
   proc {Push E} C := E|@C end
   fun {Pop}
      case @C
      of X|S1 then
	 C := S1
	 X
      end
   end
   fun {IsEmpty} @C == nil end
in
   stack(push:Push pop:Pop isEmpty:IsEmpty)
end


declare S A B in
S = {NewStack}
{Browse {S.isEmpty}}
{S.push 1}
{S.push 23}
A = {S.pop}
B = {S.pop}
{Browse A}
{Browse B}


%%%% 安全で状態ありの、バンドルされているスタック（手続きディスパッチを行う版）

declare
fun {NewStack}
   C = {NewCell nil}
   proc {Push E} C := E|@C end
   fun {Pop}
      case @C
      of X|S1 then
	 C := S1
	 X
      end
   end
   fun {IsEmpty} @C == nil end
in
   proc {$ Msg}
      case Msg
      of push(X) then {Push X}
      [] pop(?E) then E = {Pop}
      [] isEmpty(?B) then B = {IsEmpty}
      end
   end
end


declare S A B E in
S = {NewStack}
{S isEmpty(E)} 
{Browse E} % true
{S push(2)}
{S push(24)}
{S pop(A)}
{S pop(B)}
{Browse A} % 24
{Browse B} % 2


%%%% 安全で状態ありの、バンドルされていないスタック

declare
local Wrap Unwrap
   {NewWrapper Wrap Unwrap}
   fun {NewStack} {Wrap {NewCell nil}} end
   proc {Push S E}
      C = {Unwrap S}
   in
      C := E|@C
   end
   fun {Pop S}
      C = {Unwrap S}
   in
      case @C
      of X|S1 then
	 C := S1
	 X
      end
   end
   fun {IsEmpty S} @{Unwrap S} == nil end
in
   Stack = stack(new:NewStack push:Push pop:Pop isEmpty:IsEmpty)
end


declare S in
S = {Stack.new}
{Stack.push S 10}
{Stack.push S 20}
{Browse {Stack.pop S}} % 20
{Browse {Stack.pop S}} % 10


%%% 6.4.3 多様性

%%%% CollectionのADT実装

declare
local Wrap Unwrap
   {NewWrapper Wrap Unwrap}
   fun {NewCollection} {Wrap {Stack.new}} end
   proc {Put C X} S = {Unwrap C} in {Stack.push S X} end
   fun {Get C} S = {Unwrap C} in {Stack.pop S} end
   fun {IsEmpty C} {Stack.isEmpty {Unwrap C}} end
%   proc {Union C1 C2}
%      S1 = {Unwrap C1}
%      S2 = {Unwrap C2}
%   in
%      {DoUntil
%       fun {$} {Stack.isEmpty S2} end
%       proc {$} {Stack.push S1 {Stack.pop S2}} end}
%   end
   proc {Union C1 C2}
      {DoUntil
       fun {$} {Collection.isEmpty C2} end
       proc {$} {Collection.put C1 {Collection.get C2}} end}
   end
in
   Collection = collection(new:NewCollection put:Put get:Get isEmpty:IsEmpty union:Union)
end


declare C
C = {Collection.new}
{Collection.put C 1}
{Collection.put C 2}
{Browse {Collection.get C}}
{Browse {Collection.get C}}


%%%% Collectionのオブジェクト実装

declare
fun {NewCollection}
   S = {NewStack}
   proc {Put X} {S.push X} end
   fun {Get} {S.pop} end
   fun {IsEmpty} {S.isEmpty} end
   proc {Union C2}
      {DoUntil
       C2.isEmpty
       proc {$} {S1.push {C2.get}} end}
   end
in
   collection(put:Put get:Get isEmpty:IsEmpty union:Union)
end


declare C
C = {NewCollection}
{C.put 1}
{C.put 2}
{Browse {C.get}}
{Browse {C.get}}


%%%% 例:Collection型

declare
proc {DoUntil BF S}
   if {BF} then skip else {S} {DoUntil BF S} end
end


%%%% ADT実装にunion操作を付加すること

declare C1 C2 in
C1 = {Collection.new}
C2 = {Collection.new}
for I in [1 2 3] do {Collection.put C1 I} end
for I in [4 5 6] do {Collection.put C2 I} end
{Collection.union C1 C2}
{Browse {Collection.isEmpty C2}}
{DoUntil
 fun {$} {Collection.isEmpty C1} end
 proc {$} {Browse {Collection.get C1}} end}


%%%% オブジェクト実装にunion操作を付加すること

declare
fun {NewCollection}
   S = {NewStack}
   proc {Put X} {S.push X} end
   fun {Get} {S.pop} end
   fun {IsEmpty} {S.isEmpty} end
   proc {Union C2}
      {DoUntil
       C2.isEmpty
       proc {$} {This.put {C2.get}} end}
   end
   This = collection(put:Put get:Get isEmpty:IsEmpty union:Union)
in
   This
end


declare C1 C2 in
C1 = {NewCollection}
C2 = {NewCollection}
for I in [1 2 3] do {C1.put I} end
for I in [4 5 6] do {C2.put I} end
{C1.union C2}
{Browse {C2.isEmpty}}
{DoUntil
 fun {$} {C1.isEmpty} end
 proc {$} {Browse {C1.get}} end}


%%% 6.4.5 取り消し可能資格

declare
proc {Revocable Obj ?R ?RObj}
   C = {NewCell Obj}
in
   proc {R}
      C := proc {$ M} raise revokedError end end
   end
   proc {RObj M}
      {@C M}
   end
end

declare
fun {NewCollector}
   Lst = {NewCell nil}
in
   proc {$ M}
      case M
      of add(X) then T in {Exchange Lst T X|T}
      [] get(L) then L = {Reverse @Lst}
      end
   end
end

declare C R O P in
C = {Revocable {NewCollector} R}
{C add(12)}
{C add(24)}
{C get(O)}
{Browse O}
{R}
{C add 36}
{C get(P)}

