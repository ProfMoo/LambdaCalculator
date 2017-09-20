local Parser
   proc {RunAll ListOfExpressions}
      if ListOfExpressions == nil then skip
      else
	 {Browse {Run ListOfExpressions.1}}
	 {RunAll ListOfExpressions.2}
      end
   end

   % Create alphabet to use for alpha renaming.
   fun {MakeAlphabet}
      ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z']
   end
   
   % Get a list of free variables.
   fun {GetFreeVars Exp BoundList FreeList}
      case Exp of lambda(BoundVar LExp) then 
         {GetFreeVars LExp BoundVar|BoundList FreeList} % Recurse, simplifying LExp and adding BoundVar to BoundList
      [] [Exp1 Exp2] then 
         {GetFreeVars Exp1 BoundList {GetFreeVars Exp2 BoundList FreeList}}
      [] Atom then 
         if {List.member Atom BoundList} then 
            FreeList 
         else 
            Atom|FreeList
         end
      end
   end

   % Get a list of bound variables
   fun {GetBoundVars Exp BoundList}
      case Exp of lambda(BoundVar LExp) then 
         BoundVar|{GetBoundVars LExp BoundVar|BoundList} % Recurse, simplifying LExp and adding BoundVar to BoundList
      [] [Exp1 Exp2] then 
         {GetBoundVars Exp1 {GetBoundVars Exp2 BoundList}}
      [] Atom then 
         nil
      end
   end

   % Find the letters that can be used to alpha rename.
   fun {NonIntersection Free Bound Alphabet}
      case Alphabet of H|T then
        if {Or {Member H Free} {Member H Bound}} then % If the head of the alphabet is in our free vars
          {NonIntersection Free Bound T} % recurse with alph tail
        else % Head is not a free or bound variable, is ok to use for renaming
          H|{NonIntersection Free Bound T}
        end
      else %Alphabet is single element
        if {Or {Member Alphabet Free} {Member Alphabet Bound}} then % If one element in list and in both, return itis free
          nil
      else %If not free variable, return it
          Alphabet
       end
      end
   end

   fun {Run Exp}
      local
        Free = {GetFreeVars Exp nil nil}
        Unused = {NonIntersection Free {GetBoundVars Exp nil} {MakeAlphabet}}
      in
       {Reduce {Reduce {AlphaRename Exp Unused Free}}}
      end
   end

   fun {Reduce Exp}
      case Exp of lambda(V E) then % \x.Expression    
         {EtaReduce Exp}  
      [] [V E] then % Apply
         {BetaReduce{Reduce V} {Reduce E}}
      else % Atom
         Exp
      end
   end

   % Checks if beta reduction possible, else recurse inwards
   fun {BetaReduce Exp1 Exp2}
      case Exp1 of lambda(BoundVar LExp) then % In this case, we are in form \x.Expression
         {Replace BoundVar LExp Exp2}
      else
         [Exp1 Exp2]
      end
   end

   % Actually replace the bound variables with the free expression.
   fun {Replace BoundVar LExp FreeExp}
      case LExp of lambda(V E) then
         lambda(V {Replace BoundVar {Reduce E} {Reduce FreeExp}})
      [] [V E] then
         [{Replace BoundVar V FreeExp} {Replace BoundVar E FreeExp}]
      [] Atom then 
         if LExp == BoundVar then
            FreeExp
         else
            LExp
	       end
      end
   end
      
   % Eta reduce or do nothing.
   fun {EtaReduce Exp}
      case Exp of  lambda(X [V X]) then
	      {Reduce V}
      else
	      Exp
      end
   end

   % This function determines what case the expression is.
   fun {AlphaRename Exp UnusedVars FreeVars} 
      case Exp of lambda(BoundVar LExp) then % If the input expression is of the lambda case, we must check if it needs to be alpha renamed.
         {AlphaRename2 LExp BoundVar UnusedVars FreeVars}
      [] [Exp1 Exp2] then % If the input is of the Apply case, we must see if each expression needs any alpha renaming.
         [{AlphaRename Exp1 UnusedVars FreeVars} {AlphaRename Exp2 UnusedVars FreeVars}]
      [] Atom then % If the input is an atom, it is a free variable.
         Atom
      end
   end

   % This function determines if an expression needs to be alpha renamed.
   fun {AlphaRename2 LExp BoundVar UnusedVars FreeVars}
      if {Member BoundVar FreeVars} then % If BoundVar has the same name as a variable that is free, we need to perform an alpha renaming.
        lambda( UnusedVars.1 {AlphaRename3 LExp BoundVar UnusedVars.1 UnusedVars.2 FreeVars})
      else % If BoundVar doesn't have the same name as a variable that is free, we don't need to alpha rename. 
        lambda( BoundVar {AlphaRename LExp UnusedVars FreeVars})
      end
   end

   % This is the function where the actual renaming will occur.
   fun{AlphaRename3 LExp BoundVar Replacement UnusedVars FreeVars}
      case LExp of lambda(V E) then % If LExp is another lambda expression, it needs to be reduced again before we can actually try to rename it.
         {AlphaRename2 E V UnusedVars FreeVars} 
      [] [V E] then % If LExp is of the apply form, then we have \x.(e e) and need to see if either of the e's are the same as a free variable.
         [{AlphaRename3 V BoundVar Replacement UnusedVars FreeVars} {AlphaRename3 E BoundVar Replacement UnusedVars FreeVars}]
      [] Atom then % If LExp is an atom, then we need to check if it is the same as the variable it is bound to.
          % If it is the same as the variable it is bound to, then we must change the Atom to an unused variable.
          if Atom == BoundVar then
            Replacement
          else % If it is not the same as the variable it is bound to, we do not need to replace the atom
            Atom
          end
      end
   end

in
   [Parser] = {Module.link ['parser.ozf']}
   {RunAll {Parser.getExpsFromFile 'input.lambda'}}
end