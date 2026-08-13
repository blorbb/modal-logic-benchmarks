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


structure Nodestore :> NODESTORE =
	struct
		datatype node =
				  ROOT of (Node.node * int * (int * Term.relvar * int) list)
				| POINTER of (int * int * node)
		
		val nodes = Dynarraydict.empty ()
			: node Dynarraydict.dict
		
		
		val nominalMap = ref (Binarymap.mkDict String.compare)
			: (string, int * int) Binarymap.dict ref
		
		
		fun reset () =
			let
			in
				  Dynarraydict.clear nodes
				; nominalMap := (Binarymap.mkDict String.compare)
			end
		
		
		fun backtrack d =
			let
				val mfSuccessors = List.filter (fn (_, _, d') => d' <= d)
				
				fun mf (_, y as ROOT (w, d', xs)) =
						if d' <= d
						then
							let
							in
								  Node.backtrack w d
								; SOME (ROOT (w, d', mfSuccessors xs))
							end
						else NONE
				  | mf (_, y as POINTER (wid, d', ROOT (w, d'', xs))) =
						if d' <= d
						then SOME y
						else if d'' <= d
						then
							let
							in
								  Node.backtrack w d
								; SOME (ROOT (w, d'', mfSuccessors xs))
							end
						else NONE
				  | mf (_, y as POINTER (_, _, POINTER _)) = Exn.unexpArg "Nodestore.backtrack.mf"
				
				fun btNominalMap () =
					nominalMap := (Binarymap.foldl (fn (n, (_, d'), m) => if d' <= d then m else #1 (Binarymap.remove (m, n))) (!nominalMap) (!nominalMap))
			in
				  Dynarraydict.modifyo mf nodes
				; btNominalMap ()
			end
		
		
		fun addNode w d = Dynarraydict.insert (nodes, Node.getId w, ROOT (w, d, nil))
		
		
		fun addSuccessor pred r succ d =
			let
				fun mf (ROOT (w, d', xs)) = ROOT (w, d', (Node.getId succ, r, d)::xs)
				  | mf _ = Exn.unexpArg "Nodestore.addSuccessor.mf"
			in
				  addNode succ d
				; Dynarraydict.modifyItem mf (nodes, Node.getId pred)
			end
		
		
		fun peekNode n =
			case Dynarraydict.peek (nodes, n)
				of SOME (ROOT (w, _, _)) => SOME w
				 | SOME (POINTER (wid, _, _)) => peekNode wid
				 | NONE => NONE
		
		
		fun getNode n =
				Option.valOf (peekNode n)
				handle Option => Exn.unexpected ("Nodestore.getNode. Node with index " ^ (Int.toString n) ^ " does not exist.")
		
		
		fun propagateTo n curDepth (k, d) =
			case Binarymap.peek (!nominalMap, n)
				of NONE =>
					let
						val w = Node.newNode curDepth NONE (Translator.getKey (Term.EQ n), d)
					in
						  addNode w curDepth
						; Node.propagate w curDepth ((k, d)::(Universalstore.listItems ()))
						; Ref.modify (fn m => Binarymap.insert (m, n, (Node.getId w, curDepth))) nominalMap
					end
				 | SOME (wid, _) => Node.propagate (getNode wid) curDepth [(k, d)]
		
		
		fun setEqual wid curDepth (n, d) =
			case Binarymap.peek (!nominalMap, n)
				of NONE =>
					let
						val w = getNode wid
					in
						  Node.addNominalDepcy w curDepth d
						; Ref.modify (fn m => Binarymap.insert (m, n, (Node.getId w, curDepth))) nominalMap
					end
				 | SOME (wid', _) =>
					let
						val w1 = getNode wid
						val w2 = getNode wid'
					in
						if Node.getId w1 = Node.getId w2
						then ()
						else
							if Node.getId w1 < Node.getId w2
							then
								let
									val succs =
										if !Settings.dontMergeSuccLists
										then nil
										else
											case Dynarraydict.get (nodes, Node.getId w2)
												of ROOT (_, _, xs) =>
													List.map (fn (x, r, _) => (x, r, curDepth)) xs
												 | _ => Exn.unexpected "Nodestore.setEqual"
								in
									  Node.addNominalDepcy w1 curDepth d
									; Node.addNominalDepcy w2 curDepth d
									; Node.mergeInto w1 curDepth w2 d
									; Dynarraydict.modifyItem
										(fn ROOT x => POINTER (Node.getId w1, curDepth, ROOT x) | _ => Exn.unexpected "Nodestore.setEqual")
										(nodes, Node.getId w2)
									; Dynarraydict.modifyItem
										(fn ROOT (w, d', xs) => ROOT (w, d', succs@xs) | _ => Exn.unexpected "Nodestore.setEqual")
										(nodes, Node.getId w1)
								end
							else
								let
									val succs =
										if !Settings.dontMergeSuccLists
										then nil
										else
											case Dynarraydict.get (nodes, Node.getId w1)
												of ROOT (_, _, xs) =>
													List.map (fn (x, r, _) => (x, r, curDepth)) xs
												 | _ => Exn.unexpected "Nodestore.setEqual"
								in
									  Node.addNominalDepcy w1 curDepth d
									; Node.addNominalDepcy w2 curDepth d
									; Node.mergeInto w2 curDepth w1 d
									; Dynarraydict.modifyItem
										(fn ROOT x => POINTER (Node.getId w2, curDepth, ROOT x) | _ => Exn.unexpected "Nodestore.setEqual")
										(nodes, Node.getId w1)
									; Dynarraydict.modifyItem
										(fn ROOT (w, d', xs) => ROOT (w, d', succs@xs) | _ => Exn.unexpected "Nodestore.setEqual")
										(nodes, Node.getId w2)
								end
					end
		
		
		fun listSuccessors w r =
			let
				val succs =
					case Dynarraydict.get (nodes, Node.getId w)
						of ROOT (_, _, succs) => succs
						 | _ => Exn.unexpArg "Nodestore.listSuccessors.succs"
			in
				List.mapPartial (fn (n, r', _) => if r = r' then SOME (getNode n) else NONE) succs
			end
		
		
		fun listNodes () = Dynarraydict.foldr (fn (_, ROOT item, ys) => (#1 item)::ys | (_, _, ys) => ys) nil nodes
		
		
		fun toOutputList () =
			let
				fun relToString ys =
					let
						fun relSort ((x, r, _), (x', r', _)) =
							case String.compare (r, r')
								of LESS => LESS
								|  GREATER => GREATER
								|  EQUAL => Int.compare (x, x')
						
						val xs = Listsort.sort relSort ys
					in
						  "successors:   "
						^ (Util.listToString (fn (w', r, _) => r ^ ":" ^ (Int.toString (Node.getId (getNode w')))) xs) ^ "\n"
					end
				
				fun nodeToString w =
					let
						val id = Node.getId w
						val ps =
							Listsort.sort
								(fn ((x, _), (y, _)) => String.compare (x, y))
								(
									if !Settings.showNegativeConstraints
									then (Node.listPropositions w)
									else List.filter #2 (Node.listPropositions w)
								)
						
						val ns =
							Listsort.sort
							(fn ((x, _), (y, _)) => String.compare (x, y))
							(
								if !Settings.showNegativeConstraints
								then (Node.listNominals w)
								else List.filter #2 (Node.listNominals w)
							)
						
						val dmv = if !Settings.detailedModelView then Node.toString w else ""
					in
						  "Node " ^ (Int.toString id)
						^ (if ns = nil then "" else " (" ^ (Util.listToString (fn (x, b) => (if b then "" else "~") ^ x) ns) ^ ")")
						^ "\n"
						^ "propositions: " ^ (Util.listToString (fn (x, b) => (if b then "" else "~") ^ x) ps)
						^ "\n" ^ dmv
					end
				
				fun mf (_, ROOT (w, _, xs)) =
					SOME (w, nodeToString w ^ relToString xs)
 				  | mf _ = NONE
			in
				List.mapPartial mf (Dynarraydict.listItems nodes)
			end
		
		
		fun toString () =
			let
				fun mf (_, s) = s ^ "------------------------------------------------------------\n"
			in
				  "--MODEL-----------------------------------------------------\n"
				^ (case Dynarraydict.foldl (fn (_, ROOT _, y) => y + 1 | (_, _, y) => y) 0 nodes of 1 => "1 node\n" | n => (Int.toString n) ^ " nodes\n")
				^ "------------------------------------------------------------\n"
				^ (concat (map mf (toOutputList ())))
			end
		
		
		fun toDot () =
			let
				fun wmf (_, ROOT (w, _, _)) =
					  (Int.toString (Node.getId w))
					^ " [label=\"{"
					^ (Util.listToString (fn (n, b) => (if b then "" else "~") ^ n) 
						(
							if !Settings.showNegativeConstraints
							then Node.listNominals w
							else List.filter #2 (Node.listNominals w)
						)
					  )
					^ "}\\n{"
					^ (Util.listToString (fn (p, b) => (if b then "" else "~") ^ p)
						(
							if !Settings.showNegativeConstraints
							then Node.listPropositions w
							else List.filter #2 (Node.listPropositions w)
						)
					  )
					^ "}\"];\n"
				  | wmf _ = ""
				
				fun smf (_, ROOT (w, _, xs)) =
					concat (
						List.map (
							fn (w', r, _) =>
								  (Int.toString (Node.getId w))
								^ " -> "
								^ (Int.toString (Node.getId (getNode (w'))))
								^ " [label=\" " ^ r ^ " \"];\n"
							)
						xs
					)
				  | smf _ = ""
			in
				  (concat (List.map wmf (Dynarraydict.listItems nodes)))
				^ (concat (List.map smf (Dynarraydict.listItems nodes)))
			end
		
		
		fun findPattern ks =
			let
				val ksq = Util.cleanSort Int.compare ks
				
				fun findPattern' w =
					let
						val ksw = Util.cleanSort Int.compare (map #1 (Node.getPattern w))
						
						fun subset nil ys = true
						  | subset (x::xr) nil = false
						  | subset (x::xr) (y::yr) =
							(x = y andalso subset xr yr) orelse (x > y andalso subset (x::xr) yr)
					in
						subset ksq ksw
					end
			in
				case Dynarraydict.revfind (fn (_, ROOT (w, _, _)) => findPattern' w | _ => false) nodes
					of SOME (_, ROOT (w, _, _)) => SOME w
					 | SOME (_, POINTER _) => Exn.unexpected "Nodestore.findPattern"
					 | NONE => NONE
			end
	end
