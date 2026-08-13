(*****************************************************************************
 *  Author:
 *    Daniel N. Goetzmann <dngoetzmann@googlemail.com>
 *
 *  Copyright:
 *     Daniel N. Goetzmann, 2009
 *
 *  Last modified:
 *    $Date: 2009-06-22 23:59:07 +0200 (Mon, 22 Jun 2009) $
 *    $Author: goetzmann $
 *    $Revision: 460 $
 *
 *  This file is part of Spartacus,
 *  the tableau prover for hybrid logic
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *****************************************************************************)


structure BranchingMgr :> BRANCHINGMGR =
	struct
		exception Unsat
		
		exception BcpUnsat of Node.node * Dependency.depcy
		
		datatype branchPoint = BP of {node : Node.node, disjuncts : Term.index list, depcy : Dependency.depcy, nogood : Term.index list}
		
		val d = ref 0
		
		val count = ref 1
		
		(*stack of the remaining alternatives:
		contains the node the disjunction was taken from,
		a list of remaining alternatives,
		the dependencies for that disjunction in a dependency set*)
		val branchStack = ref nil : branchPoint list ref
		
		
		val disjunctionMap = DynamicArray.array (32, 0)
		
		fun rememberDisjunction k =
			if !Settings.penalizeDisjunctions
			then DynamicArray.update (disjunctionMap, !d, k)
			else ()
		
		
		(*reset to empty*)
		fun reset () =
			let
			in
				  d := 0
				; count := 1
				; branchStack := nil
			end
		
		
		(*returns the current branching depth*)
		fun getBranchingDepth () = !d
		
		
		(*resets the branchStack to the given depth*)
		fun jumpToDepth d' =
			let
			in
				if d' < 0 then raise Unsat else ();
				branchStack := (List.drop (!branchStack, !d - d'));
				d := d'
			end
		
		
		(*applies backjumping as determined by the dependency set*)
		fun backjump dset =
			let
			in
				Debug.output (fn () => "current: " ^ (Int.toString (!d)) ^"; dependencies: " ^
				(Util.IntBinarySetToString (dset)) ^
				"\n");
				case !branchStack
					of nil => raise Unsat
					|  (BP {disjuncts, ...})::br =>
						if null disjuncts
						then Exn.unexpected "BranchingMgr.backjump: no alternative left"
						else
							if IntBinarySet.member (dset, !d)
							then IntBinarySet.delete (dset, !d)
							else (
								jumpToDepth (!d - 1);
								backjump dset
							)
			end
		
		
		(*takes the next branch*)
		fun branch dso =
			case !branchStack
				of nil => raise Unsat
				|  (BP {node, disjuncts, depcy, nogood})::br =>
					case disjuncts
						of nil => Exn.unexpected "BranchingMgr.branch: no alternative left"
						|  [k] =>
							let
								val newDep = Dependency.merge depcy (!d - 1) dso
							in
								Ref.incr count;
								jumpToDepth (!d - 1);
								Debug.output (fn () => "DETERMINISTIC at branching depth " ^ (Int.toString (!d)) ^ "\n");
								Debug.output (fn () => "disjunct " ^ (Int.toString k) ^ " with dependencies " ^ Dependency.toString(newDep) ^ "\n");
								Debug.output (fn () => Node.toString node);
								Node.propagateDisjunct node (k, newDep, nogood, false);
								Debug.output (fn () => Node.toString node)
							end
						| k::kr =>
							let
								val newDep = Dependency.add (Dependency.merge depcy (!d) dso) (!d)
							in
								Ref.incr count;
								Debug.output (fn () => "BRANCHING at branching depth " ^ (Int.toString (!d)) ^ "\n");
								Debug.output (fn () => "disjunct " ^ (Int.toString k) ^ " with dependencies " ^ Dependency.toString(newDep) ^ "\n");
								branchStack := ((BP {node = node, disjuncts = kr, depcy = depcy, nogood = k::nogood})::br);
								Debug.output (fn () => Node.toString node);
								Node.propagateDisjunct node (k, newDep, nogood, true);
								Debug.output (fn () => Node.toString node)
							end
		
		fun backtrackOther d' =
			let
				val _ = Debug.output (fn () => "backtracking to branching depth " ^ (Int.toString d') ^ "\n");
				
			in
				  Agenda.backtrack d'
				; Nodestore.backtrack d'
				; BlockingMgr.backtrack d'
				; Universalstore.backtrack d'
				; Existentialstore.backtrack d'

			end
		
		fun backtrack (SOME xs) =
			let
				val _ = Debug.output (fn () => "BACKTRACKING with dependencies " ^ Util.listToString Dependency.toString xs ^ "\n")
				
				val dependencies = 
					foldl
						(fn (x, s) => IntBinarySet.union (s, Dependency.depset x))
						IntBinarySet.empty
						xs

				
				val _ = 
					if !Settings.penalizeDisjunctions
					then
						IntBinarySet.app
							(fn d => (Debug.output (fn () => "Penalizing " ^ (Int.toString (DynamicArray.sub (disjunctionMap, d))) ^ "\n"); DisjunctionPenalties.add (DynamicArray.sub (disjunctionMap, d)) 1))
							dependencies
						handle _ => Exn.error "BranchingMgr.backtrack"
					else ()
				
				val dset =
					if !Settings.backjumpingDisabled
					then NONE
					else
						SOME (backjump dependencies)
			in
				backtrackOther (!d - 1);
				branch (dset)
			end
		  | backtrack NONE =
				let
				in
					backtrackOther (!d - 1);
					branch NONE
				end
		
		fun branchOn w (k, d') =
			let
				val (cs, bcpDeps) = case Translator.getTerm k
							of Term.DISJ cs =>
								if !Settings.bcpEnabled
								then Node.bcp w cs
								else (cs, nil)
							|  _ => Exn.unexpected "BranchingMgr.branchOn: not a disjunction"
				
				val ks = Term.Catstore.listItems cs
				
				val d'' = foldl Dependency.union d' bcpDeps
			in
				case ks
					of nil => (Debug.output (fn () => "BCP: unsatisfiable\n"); raise BcpUnsat (w, d''))
					|  [k] => (Debug.output (fn () => "BCP: singleton " ^ (Int.toString k) ^ "\n"); Node.propagateDisjunct w (k, Dependency.updDepth d'' (!d), nil, false))
					|  _ => (
						  Ref.push branchStack (BP {node = w, disjuncts = ks, depcy = d'', nogood = nil})
						; Ref.incr d
						; Ref.decr count
						; rememberDisjunction k
						; branch NONE
						)
			end
			handle Node.Satisfied => Debug.output (fn () => "BCP: satisfied\n")
		
		
		fun bough w k = 
			let
				val d' = Dependency.create (!d)
			in
				  Ref.push branchStack (BP {node = w, disjuncts = [k, 1], depcy = d' , nogood=nil})
				; Ref.incr d
				; Ref.decr count
				; rememberDisjunction k
				; branch NONE
			end
	end
