{Browse 2}


### 11.3.2

declare
X2={Connection.take "oz-ticket://192.168.0.2:9000/h3543648#0"}
{Browse X2}


### 11.3.3 チケット配布

declare
proc {Offer X FN}
   {Pickle.save {Connection.offerUnlimited X} FN}
end

declare
fun {Take FNURL}
   {Connection.take {Pickle.load FNURL}}
end


### 11.3.4

declare Xs Generate in
Xs={Take tickfile}
fun {Generate N Limit}
   if N<Limit then N|{Generate N+1 Limit} else nil end
end
Xs={Generate 0 150000}


### 11.4.2

declare 
C={Take tickfile1}
Inc={Take tickfile2}
{Browse @C}
{Browse {Inc 2}}
C:=3

{Browse 2}



## 11.6 共通分散プログラミングパターン

### 11.6.1 静止オブジェクトとモバイルオブジェクト

declare
C2={Take tickfile}
local A in
   {C2 get(A)}
   {Browse A}
end


declare C1 T1 T2
T1 = {Time.time}
C1={Take tickfile1}
for I in 1..100000 do {C1 get(_)} end
{Browse done}
T2 = {Time.time}
{Browse T1}
{Browse T2}
{Browse 'Total Time = '#(T2-T1)}


declare C2 T1 T2
T1 = {Time.time}
C2={Take tickfile2}
for I in 1..100000 do {C2 get(_)} end
{Browse done}
T2 = {Time.time}
{Browse T1}
{Browse T2}
{Browse 'Total Time = '#(T2-T1)}


### 11.6.2 非同期オブジェクトとデータフロー

declare C1 X Y Z S
C1={Take tickfile}
X={C1 get($)}
Y={C1 get($)}
Z={C1 get($)}
S=X+Y+Z
{Browse S}


### 11.6.3 サーバ

#### 計算サーバ

declare
fun {Fibo N}
   if N<2 then 1 else {Fibo N-1}+{Fibo N-2} end
end

declare
C={Take tickfile}

local F in
   {C run(proc {$} F={Fibo 30} end)}
   {Browse F}
end
local F in
   F={Fibo 30}
   {Browse F}
end


#### 資源を使う分散プログラミング

declare Browse2 in
Browse2={Take tickfile}
{Browse2 1234567890}

{Offer Browse2 t_browse2}



declare F T in
functor F
   import OS
define
   T={OS.time}
end



declare
C={Take tickfile}

declare
{C run(functor $
       import OS
       define
	  T={OS.time} in
	  {Browse T}
       end)}
{Browse T}

{Browse OS.time}




## 11.8 部分的失敗

### 11.8.2 失敗処理の簡単な場合

#### 問題を検出し、行動を起こすこと


declare X in
X={Take tickfile}
{X 1234567890}


{Fault.installWatcher X [tempFail permFail]
 proc {$ _ _}
    {Browse X#' has problems! Its use is discouraged.'}
 end _}


### 11.8.3 回復可能サーバ

declare C in
C={Take tickfile}
{C hoge}


