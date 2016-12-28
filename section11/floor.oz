% 階コンポーネント

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
fun {Floor Num Init Lifts}
   Tid={Timer}
   Fid={NewPortObject Init
        fun {$ state(Called) Msg}
           case Called
           of notcalled then Lran in
              case Msg
              of arrive(Ack) then
%                 {Browse 'Lift at floor '#Num#': open dorrs'}
                 {Send Tid starttimer(5000 Fid)}
                 state(doorsopen(Ack))
              [] call then
                 {Browse 'Floor '#Num#' calls a lift!'}
                 Lran=Lifts.(1+{OS.rand} mod {Width Lifts})
                 {Send Lran call(Num)}
                 state(called)
              end
           [] called then
              case Msg
              of arrive(Ack) then
%                 {Browse 'Lift at floor '#Num#': open doors'}
                 {Send Tid starttimer(5000 Fid)}
                 state(doorsopen(Ack))
              [] call then
                 state(called)
              end
           [] doorsopen(Ack) then
              case Msg
              of stoptimer then
%                 {Browse 'Lift at floor '#Num#': close doors'}
                 Ack=unit
                 state(notcalled)
              [] arrive(A) then
                 A=Ack
                 state(doorsopen(Ack))
              [] call then
                 state(doorsopen(Ack))
              end
           end
        end}
in Fid end

{Offer Floor floor}
{Browse 12345}