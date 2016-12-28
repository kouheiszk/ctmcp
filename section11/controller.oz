% 制御装置コンポーネント

declare
proc {Offer X FN}
   {Pickle.save {Connection.offerUnlimited X} FN}
end

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

declare
fun {Controller Init}
   Tid={Timer}
   Cid={NewPortObject Init
        fun {$ state(Motor F Lid) Msg}
           case Motor
           of running then
              case Msg
              of stoptimer then
                 {Send Lid 'at'(F)}
                 state(stopped F Lid)
              end
           [] stopped then
              case Msg
              of step(Dest) then
                 if F==Dest then
                    state(stopped F Lid)
                 elseif F<Dest then
                    {Send Tid starttimer(5000 Cid)}
                    state(running F+1 Lid)
                 else
                    {Send Tid starttimer(5000 Cid)}
                    state(running F-1 Lid)
                 end
              end
           end
        end}
in Cid end

{Offer Controller controller}
