
declare
fun {L2M GL}
   M = {Map GL fun {$ I#_} I end}
   L = {FoldL M Min M.1}
   H = {FoldL M Max M.1}
   GM = {NewArray L H unit}
in
   for I#Ns in GL do
      GM.I := {NewArray L H false}
      for J in Ns do GM.I.J := true end
   end
   GM
end


declare
fun {M2L GM}
   L = {Array.low GM}
   H = {Array.high GM}
in
   for I in L..h collect:C do
      {C I#for J in L..H collect:D do
        if GM.I.J then {D J} end
      end}
   end
end


declare
fun {Succ X G}
   case G of Y#SY|G2 then
      if X == Y then SY else {Succ X G2} end
   end
end

declare
fun {Union A B}
   case A#B
   of nil#B then B
   [] A#nil then A
   [] (X|A2)#(Y|B2) then
      if X==Y then X|{Union A2 B2}
      elseif X<Y then X|{Union A2 B}
      elseif X>Y then Y|{Union A B2}
      end
   end
end




declare
fun {DeclTrans G}
   Xs = {Map G fun {$ X#_} X end}
in
   {FoldL Xs
    fun {$ InG X}
       SX = {Succ X InG} in
       {Map InG
	fun {$ Y#SY}
	   Y#if {Member X SY} then
		{Union SY SX} else SY end
	   end}
    end G}
end






