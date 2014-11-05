local X Y Z in
    f(X b)=f(a Y)
    f(Z a)=Z
    {Browse [X Y Z]}
end


declare X Y Z in
a(X c(Z) Z) = a(b(Y) Y d(X))
{Browse X#Y#Z}




declare L1 L2 L3 Head Tail in
L1=Head|Tail
Head=1
Tail=2|nil

L2=[1 2]
{Browse L1==L2}

L3='|'(1:1 2:'|'(2 nil))
{Browse L1==L3}





declare L1 L2 X in
L1=[1]
L2=[X]
{Browse L1==L2}

X=1


declare L1 L2 X Y in
X=Y
L1=[X]
L2=[Y]
{Browse L1==L2}


declare L1 L2 X in
L1=[1 a]
L2=[X b]
{Browse L1==L2}


%%% 2.9.10

declare SMerge A in
SMerge = proc {$ Xs Ys ?T}	    
	    case Xs of nil then T = Ys else
	       case Ys of nil then T = Xs else
		  local X Y Xr Yr T1 T2 in
		     '#'(X Xr) = Xs
		     '#'(Y Yr) = Ys
	             T1 = X=<Y
		     if T1 then
			T = '#'(X T2)
			{SMerge Xr Ys T2}
		     else
	                T = '#'(Y T2)
	                {SMerge Xs Yr T2}
	             end
		  end
	       end
	    end
	 end

{SMerge '#'(1 '#'(3 nil)) '#'(2 nil) A}
{Browse A}


%%% 2.9.11

% p.70

([{IsEven X}, {X=>x1}], {x1=N})
([{IsOdd  X}, {X=>x2}], {x2=N-1, x1=N})
([{IsEven X}, {X=>x3}], {x3=N-2, x2=N-1, x1=N})
...


%%% 2.9.12

local IsE E in
   try
      <s1>
      IsE = false
   catch X then
      E = X
      IsE = true
   end
   <s2>
   if IsE then
      raise E end
   end
end


%%% 2.9.13

declare W X Y Z
X = [a Z]
Y = [W b]
X = Y
{Browse W#X#Y#Z}


declare W X Y Z
X = [a Z]
X = Y
Y = [W b]
{Browse W#X#Y#Z}


declare W X Y Z

Y = [W b]
X = [a Z]
X = Y
{Browse W#X#Y#Z}


declare W X Y Z
Y = [W b]
X = Y

X = [a Z]
{Browse W#X#Y#Z}


declare W X Y Z

X = Y
X = [a Z]
Y = [W b]
{Browse W#X#Y#Z}


declare W X Y Z
X = Y

Y = [W b]
X = [a Z]
{Browse W#X#Y#Z}
