(*****************************************************************************
 *  Authors:
 *    Daniel N. Goetzmann <dngoetzmann@googlemail.com>
 *    Mark Kaminski <kaminski@ps.uni-saarland.de>
 *
 *  Copyright:
 *     Daniel N. Goetzmann, 2009
 *     Mark Kaminski, 2010
 *
 *  Last modified:
 *    $Date: 2010-04-28 $
 *    $Author: kaminski $
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


structure Solver :> SOLVER =
	struct
		exception Timeout
		
		exception CachedUnsat of (Node.node option * Dependency.depcy list)
		
				
		val _ = Agenda.setBcpFunction (
			fn Agenda.BRANCH (wid, k, d, _) => (
				let
					val _ = Debug.output (fn () => "BCP: \\/" ^ (Int.toString k) ^ "#" ^ (Int.toString wid) ^ "\n")
					
					val w = Nodestore.getNode wid

					val d = if Node.getId w = wid then d else
						(Debug.output (fn () => "nominal propagation detected (" ^
									Int.toString wid ^ "->" ^ Int.toString(Node.getId w) ^ "); updating dependencies\n");
						 case Node.peekDisjDepcy w k of SOME d => d | NONE => raise Exn.unexpected "Solver.fBcp: term not found")
					
					val (cs, bcpDeps) = case Translator.getTerm k
								of Term.DISJ cs => Node.bcp w cs
								|  _ => Exn.unexpected "Solver.fBcp: not a disjunction"
		
					val ks = Term.Catstore.listItems cs

					val d' = foldl Dependency.union d bcpDeps
				in
					case ks
						of nil => (Debug.output (fn () => "BCP: unsatisfiable\n"); raise BranchingMgr.BcpUnsat (w, d'))
						 | [k] => (Debug.output (fn () => "BCP: singleton " ^ (Int.toString k) ^ "\n"); Node.propagateDisjunct w (k, Dependency.updDepth d' (BranchingMgr.getBranchingDepth ()), nil, false); true)
						 | _::_ => false
				end
				handle Node.Satisfied => true
				)
			 | _ => raise BtprioQ.NotFound
			)
		
		val totalTimer = ref (Timer.startRealTimer ())
		
		val timer = ref (Timer.startRealTimer ())
		
		val rac = ref 0
		
		fun startTimer () = totalTimer := (Timer.startRealTimer ())
		
		fun checkTimer () = Timer.checkRealTimer (!totalTimer)
		
		fun propagateDiamond wid (k, d) =
			let
				val _ = Debug.output (fn () => "Propagating diamond " ^ (Int.toString k) ^ "\n")
				val w = Nodestore.getNode wid
			in
				if !Settings.pbBlockingEnabled andalso BlockingMgr.pbBlocking w k (Dependency.updDepth d (BranchingMgr.getBranchingDepth ())) (BranchingMgr.getBranchingDepth ())
				then Debug.output (fn () => "pattern-based blocking applicable for " ^ (Int.toString k) ^ " on node " ^ (Int.toString (Node.getId w)) ^ "\n")
				else
					let
					        val d = if wid = Node.getId w then d else
						    (Debug.output (fn () => "nominal propagation detected (" ^
								   Int.toString wid ^ "->" ^ Int.toString(Node.getId w) ^ "); updating dependencies\n");
						     case Node.peekDmndDepcy w k of SOME d => d |
										    NONE => raise Exn.unexpected "Solver.propagateDiamond: term not found")
						val (rel, dia) =
							case Translator.getTerm k
								of Term.DMD x => x 
								|  _ => Exn.unexpected "Solver.propDiamonds.prop: not a diamond"
						
						val boxes =
							let
								val boxes = Node.listBoxes w
								
								fun mf (k', d') =
									case Translator.getTerm k'
										of Term.BOX (r, k'') => if r = rel then SOME (k'', d') else NONE
										 | _ => Exn.unexpected "Solver.propDiamonds.prop.propBoxes.af: not a box"
								
								fun mfTransitive (k', d') =
									case Translator.getTerm k'
									 of Term.BOX (r, k'') => if r = rel then SOME [(k'', d'), (k', d')] else NONE
										 | _ => Exn.unexpected "Solver.propDiamonds.prop.propBoxes.af: not a box"
							in
								if RelationMgr.isTransitive rel
								then List.concat (List.mapPartial mfTransitive boxes)
								else List.mapPartial mf boxes
							end
						
						val univ = Universalstore.listItems ()
						
						val w' = 
							if !Settings.cachingEnabled
							then
								let
									val pattern = (dia, d)::boxes@univ@(map (fn (k, d) => (~k, d)) univ)
								in
									case Cache.approxDependencies pattern
									of SOME d => (
										  Debug.output
											(fn () =>
												  "Pattern "
												^ (Util.listToString Int.toString (map #1 pattern))
												^ " is cached as unsatisfiable\n"
											)
										; raise CachedUnsat (SOME w, d)
										)
									 | NONE =>
											Node.newNode
												(BranchingMgr.getBranchingDepth ())
												(SOME (Node.getId w))
												(dia, d)
								end
							else
								Node.newNode
									(BranchingMgr.getBranchingDepth ())
									(SOME (Node.getId w))
									(dia, d)
					in
						  Node.propagate w' (BranchingMgr.getBranchingDepth ()) (boxes@univ)
						; Nodestore.addSuccessor w rel w' (Dependency.btDepth d)
					end
			end
		
		
		fun propagateBox wid (k, d) =
			let
				val _ = Debug.output (fn () => "Propagating box " ^ (Int.toString k) ^ "\n")
				val w = Nodestore.getNode wid
				val d = if wid = Node.getId w then d else
					(Debug.output (fn () => "nominal propagation detected (" ^
								Int.toString wid ^ "->" ^ Int.toString(Node.getId w) ^ "); updating dependencies\n");
					 case Node.peekBoxDepcy w k of SOME d => d | NONE => raise Exn.unexpected "Solver.propagateBox: term not found")
				
				val (r, k') =
					case Translator.getTerm k
						of Term.BOX x => x
						|  _ => Exn.unexpected "Solver.propBoxes.prop: not a box"
				
				val successors = Nodestore.listSuccessors w r
				
				fun af w' =
					let
					in
						  Node.propagate w' (BranchingMgr.getBranchingDepth ()) (
							if RelationMgr.isTransitive r
							then [(k', d), (k, d)]
							else [(k', d)]
						  )
						; if !Settings.fullBlocking then BlockingMgr.store w' (BranchingMgr.getBranchingDepth ()) else ()
					end
			in
				  (if RelationMgr.isReflexive r then Node.propagate w (BranchingMgr.getBranchingDepth ()) [(k', d)] else ())
				; app af successors
				; (if !Settings.pbBlockingEnabled then BlockingMgr.findUnblocked w else ())
			end
		
		
		fun propagateExistential (k, d) =
			let
				val univ = Universalstore.listItems ()
		
				val w =
					if !Settings.cachingEnabled
					then
						let
							val pattern = (k, d)::univ@(map (fn (k, d) => (~k, d)) univ)
						in
							case Cache.approxDependencies pattern
							of SOME d => (
								  Debug.output
									(fn () =>
										  "Pattern "
										^ (Util.listToString Int.toString (map #1 pattern))
										^ " is cached as unsatisfiable\n"
									)
								; raise CachedUnsat (NONE, d)
								)
							 | NONE =>
									Node.newNode
										(BranchingMgr.getBranchingDepth ())
										(NONE)
										(k, d)
						end
					else
						Node.newNode
							(BranchingMgr.getBranchingDepth ())
							(NONE)
							(k, d)
			in
				  Node.propagate w (BranchingMgr.getBranchingDepth ()) univ
				; Nodestore.addNode w (Dependency.btDepth d)
			end
		
		
		fun branch wid (k, d) =
			let
				val _ = Debug.output (fn () => "Branching\n")
				val w = Nodestore.getNode wid
				val d = if wid = Node.getId w then d else
					(Debug.output (fn () => "nominal propagation detected (" ^
								Int.toString wid ^ "->" ^ Int.toString(Node.getId w) ^ "); updating dependencies\n");
					 case Node.peekDisjDepcy w k of SOME d => d | NONE => raise Exn.unexpected "Solver.branch: term not found")
			in
				  BranchingMgr.branchOn w (k, d)
			end
		
		
		fun cache ds w =
			let
				val bps = IntBinarySet.addList (IntBinarySet.empty, Node.listBranchPoints w)
				
				exception isNotCacheable
				
				fun pf (k, d') =
					if Translator.isNotCacheable k
					then raise isNotCacheable
					else
						if IntBinarySet.isSubset (Dependency.depset d', ds)
						then SOME k
						else NONE
				
				fun upf (k, d') =
					if Translator.isNotCacheable k
					then raise isNotCacheable
					else
						if IntBinarySet.isSubset (Dependency.depset d', ds)
						then SOME (~k)
						else NONE
				
				fun getPattern () =
					  (List.mapPartial pf (Node.getPattern w))
					@ (List.mapPartial upf (Universalstore.listItems ()))
			in
				if IntBinarySet.isEmpty (IntBinarySet.intersection (ds, bps))
				then (
					  Debug.output (fn () => "dependencies: " ^ (Util.IntBinarySetToString ds) ^ "; branch points: " ^ (Util.IntBinarySetToString bps) ^ "\n")
					; Cache.rememberUnsat (getPattern ())
					; Option.app (fn x => cache ds (Nodestore.getNode x)) (Node.peekPredId w)
				) handle isNotCacheable => ()
				else ()
			end
		
		
		fun solve'' () =
			let
				val _ =
					case ((!rac before Ref.incr rac) mod !Settings.tci, !Settings.timeout)
						of (_, NONE) => ()
						|  (0, SOME x) => if Time.<= (x, Timer.checkRealTimer (!timer)) then raise Timeout else ()
						|  _ => ()
					
				val _ = Debug.output (fn () => Agenda.toString())
			in
				if Agenda.isEmpty ()
				then true
				else
					case Agenda.pop (BranchingMgr.getBranchingDepth ())
						of (Agenda.DIAMOND (w, k, d, _)) => (propagateDiamond w (k, d); solve'' ())
						|  (Agenda.BOX (w, k, d)) => (propagateBox w (k, d); solve'' ())
						|  (Agenda.BRANCH (w, k, d, _)) => (branch w (k, d); solve'' ())
						|  (Agenda.EQ (w, n, d)) => (Nodestore.setEqual w (BranchingMgr.getBranchingDepth ()) (n, d); solve'' ())
						|  (Agenda.AT (n, k, d)) => (Nodestore.propagateTo n (BranchingMgr.getBranchingDepth ()) (k, d); solve'' ())
						|  (Agenda.UNIV (k, d)) => (app (fn w => (Node.propagate w (BranchingMgr.getBranchingDepth ()) [(k, d)])) (Nodestore.listNodes ()); solve'' ())
						|  (Agenda.EXIST (k, d)) => (propagateExistential (k, d) ; solve'' ())
			end
		
		
		fun	handler (Node.Unsat (w ,ds)) = (
				( (
					if !Settings.cachingEnabled
					then cache (foldl (fn (x, s) => IntBinarySet.union (Dependency.depset x, s)) IntBinarySet.empty ds) w
					else ()
				  )
				; BranchingMgr.backtrack (SOME ds)
				) handle e => handler e
			)
		  | handler (Node.CachedUnsat (w, ds)) = (
				(
				  Option.app
					(fn x => cache (foldl (fn (x, s) => IntBinarySet.union (Dependency.depset x, s)) IntBinarySet.empty ds)
						(Nodestore.getNode x))
					(Node.peekPredId w)
				; BranchingMgr.backtrack (SOME ds)
				) handle e => handler e
			)
		  | handler (CachedUnsat (wopt, ds)) = (
				(
				  Option.app
					(fn w => cache (foldl (fn (x, s) => IntBinarySet.union (Dependency.depset x, s)) IntBinarySet.empty ds) w)
					wopt
				; BranchingMgr.backtrack (SOME ds)
				) handle e => handler e
			)
		  | handler (Universalstore.Unsat (d1, d2)) = (BranchingMgr.backtrack (SOME [d1, d2]) handle e => handler e)
		  | handler (BranchingMgr.BcpUnsat (w, d)) = (
				( (
					if !Settings.cachingEnabled
					then cache (Dependency.depset d) w
					else ()
				  )
				; BranchingMgr.backtrack (SOME [d])
				) handle e => handler e
			)
		  | handler Agenda.Bcp = ()
		  | handler e = raise e
		
		
		fun solve' () = solve'' () handle e => (handler e; solve' ())
		
		
		fun initialize k = 
			let
				val _ = Debug.output (fn () => "Initializing (term " ^ (Int.toString k) ^ ")\n")
				
				val _ = Agenda.initialize ()
				
				val d = Dependency.create (BranchingMgr.getBranchingDepth ())
				
				val w = Node.newNode (BranchingMgr.getBranchingDepth ()) NONE (k, d)
			in
				  if RelationMgr.someSymmetric ()
				  then Exn.error "Input contains symmetric relations, which are not supported."
				  else ()
				; if List.null (RelationMgr.listSubrelations ())
				  then ()
				  else Exn.error "Input contains subrelations, which are not supported."
				; app (fn r => Agenda.insert (Agenda.UNIV (Translator.translate (Parsetree.ALL (Parsetree.DIAMOND (r, Parsetree.CONJ nil))), Dependency.create 0), 0)) (RelationMgr.listSerial ())
				; Nodestore.addNode w (BranchingMgr.getBranchingDepth ())
				; app (fn n => Nodestore.propagateTo n (BranchingMgr.getBranchingDepth ()) (1, d)) (Translator.listNominals ())
			end
		
		
		fun solve k =
			let
				val _ = (if !Settings.csv then () else print "Initializing the solver\n")
				val timer3 = Timer.startRealTimer ()
				val _ = BranchingMgr.reset ()
				val _ = Nodestore.reset ()
				val _ = Cache.initialize (Translator.getSize () + 2)
				val _ = Node.reset ()
				val _ = BlockingMgr.initialize (Translator.getSize () + 2);
				val _ = Universalstore.reset ();
				val _ = Existentialstore.reset ();
				val _ = initialize k
				val _ = print (if !Settings.csv then (Time.toString (Timer.checkRealTimer timer3)) ^ "," else "Initialization time: " ^ (Time.toString (Timer.checkRealTimer timer3)) ^ " sec\n")
				val _ = if !Settings.csv then () else print "Solving\n"
			in
				  timer := Timer.startRealTimer()
				; (solve' () handle BranchingMgr.Unsat => false)
				before (
					  print (
						if !Settings.csv
						then (Time.toString (Timer.checkRealTimer (!timer))) ^ ","
						else "Decision time: " ^ (Time.toString (Timer.checkRealTimer (!timer))) ^ " sec\n"
					  )
					; print (
						if !Settings.csv
						then (Int.toString (!BranchingMgr.count)) ^ "," ^ (Int.toString (!rac)) ^ ","
						else "#Branches: " ^ (Int.toString (!BranchingMgr.count)) ^ "\n#Rule applications: " ^ (Int.toString (!rac)) ^ "\n"
						)
					; print (
						if !Settings.csv
						then
							let
								val (stores, hits, misses) = Cache.getStats ()
							in
								  (Int.toString stores) ^ ","
								^ (Int.toString hits) ^ ","
								^ (Int.toString misses) ^ ","
							end
						else
							if !Settings.cachingEnabled
							then
								let
									val (stores, hits, misses) = Cache.getStats ()
								in
									  "Cache store ops: " ^ (Int.toString stores)  ^ "\n"
									^ "Cache hits:      " ^ (Int.toString hits)  ^ "\n"
									^ "Cache misses:    " ^ (Int.toString misses)  ^ "\n"
								end
							else ""
					  )
				)
			end
			handle Node.Unsat _ => (print (if !Settings.csv then "n/a,n/a,1,0,0,0,0," else "Trivial problem!\n"); false)
			
			
		fun solveTerm k =
			let
				fun printTotalTime () =
					print (
						if !Settings.csv
						then (Time.toString (Timer.checkRealTimer (!totalTimer))) ^ ","
						else (
							  if !Settings.checksat = nil
							  then "Total time: "
							  else "Time: "
							)
							^ (Time.toString (Timer.checkRealTimer (!totalTimer)))
							^ "\n"
					)
			in
				  Debug.output (fn () => Translator.toString ())
				; if solve k
				  then (printTotalTime (); print "satisfiable\n"; true)
				  else (printTotalTime (); print "unsatisfiable\n"; false)
			end
			handle Timeout => (print ((Time.toString (Timer.checkRealTimer (!timer))) ^ "," ^ (Int.toString (!BranchingMgr.count)) ^ "," ^ (Time.toString (Timer.checkRealTimer (!totalTimer))) ^ ",Timeout\n"); raise Timeout)
			     | e => (print ((Time.toString (Timer.checkRealTimer (!timer))) ^ "," ^ (Int.toString (!BranchingMgr.count)) ^ "," ^ (Time.toString (Timer.checkRealTimer (!totalTimer))) ^ ",EXCEPTION\n"); raise e)
		
		
		fun checksat (c, k, k1, k2) =
			let
				val _ = Debug.output (fn () => "Checking satisfiability of " ^ c ^ "\n")
				
				val _ = print (c ^ ": ")
				
				val d = BranchingMgr.getBranchingDepth ()
				
				fun db () =
					let
						val d' = Dependency.create d
					in
						  if Universalstore.add (k2, d')
						  then Agenda.insert (Agenda.UNIV (k2, d'), d)
						  else ()
						; if (solve'' () handle BranchingMgr.Unsat => Exn.unexpected "Solver.checksat.db: unexpected exn")
						  then
							if d <> BranchingMgr.getBranchingDepth ()
							then Exn.unexpected "Solver.checksat.db: unexpected branching depth"
							else ()
						  else Exn.unexpected "Solver.checksat.db: unexpected result"
					end
			in
				  Debug.output (fn () => Translator.toString ())
				; if !Settings.cse orelse Translator.isNotCacheable k orelse Translator.isNotCacheable k1
				  then
					let
						val _ = BranchingMgr.reset ()
						val _ = Nodestore.reset ()
						val _ = Node.reset ()
						val _ = BlockingMgr.initialize (Translator.getSize () + 2)
						val _ = Universalstore.reset ()
						val _ = Existentialstore.reset ()
						val _ = initialize k
						val _ = Node.propagate (Nodestore.getNode 0) (BranchingMgr.getBranchingDepth ()) [(k1, Dependency.create (BranchingMgr.getBranchingDepth ()))]
					in
						if ((solve' () before Debug.output (fn () => c ^ ": "))
							handle BranchingMgr.Unsat => false)
						then (print "satisfiable\n"; true)
						else (print "unsatisifiable\n"; false)
					end
				  else
					let
					in
					  BranchingMgr.bough (Nodestore.getNode 0) k1
					; if (solve' () handle BranchingMgr.Unsat => Exn.unexpected "Solver.checksat: unexpected exn")
					  then (
						  Debug.output (fn () => c ^ ": ")
						; case Int.compare (d, BranchingMgr.getBranchingDepth ())
							of EQUAL => (print "unsatisfiable\n"; db (); false)
							 | LESS => (print "satisfiable\n"; true)
							 | GREATER => Exn.unexpected "Solver.checksat: unexpected branching depth"
						)
					  else Exn.unexpected "Solver.checksat: unexpected result"
					end
			end
	end
