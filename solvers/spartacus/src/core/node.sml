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


structure Node :> NODE =
	struct
		exception Satisfied
		
		datatype node =
			  W of {
				  id              : int
				, predId          : int option
				, creationDepcy   : Dependency.depcy
				, nominalDepcies  : Dependency.depcy list ref
				, pattern         : Termstore.store
				, propositions    : Propstore.pstore
				, nominals        : Propstore.pstore
				, diamonds        : Termstore.store
				, boxes           : Termstore.store
				, disjunctions    : Termstore.store
				, nglstore        : Termstore.store
				, lazyProps       : Lazystore.store
				, lazyNoms        : Lazynomstore.store
				, lazyBoxes       : Lazyboxstore.store
				, blockedDiamonds : (Term.index * int) list ref
				, branchPoints    : int list ref
				}
		

		exception Unsat of node * Dependency.depcy list
		exception CachedUnsat of node * Dependency.depcy list
		
		val nextId = ref 0
		
		
		fun reset () = nextId := 0
		
		
		fun peekDisjDepcy (W {disjunctions, ...}) k = Termstore.peek disjunctions k
		fun peekBoxDepcy (W {boxes, ...}) k = Termstore.peek boxes k
		fun peekDmndDepcy (W {diamonds, ...}) k = Termstore.peek diamonds k

		fun scheduleDisjunction (w as W {id, ...}) (t, d) =
			Agenda.insert (Agenda.BRANCH (id, t, d, (DisjunctionPenalties.get t)), Dependency.btDepth d)
		
		fun tryLazyNoms (w as W {lazyNoms, ...}) (t, d) =
			if !Settings.lazyWithNominals
				andalso Lazynomstore.add lazyNoms (t, d)
			then ()
			else scheduleDisjunction w (t, d)
		
		fun tryLazyProps (w as W {lazyProps, ...}) (t, d) =
			if !Settings.lazyBranching andalso Lazystore.add lazyProps (t, d)
			then ()
			else tryLazyNoms w (t, d)
		
		fun tryLazyBoxes (w as W {lazyBoxes, ...}) (t, d) =
			if !Settings.lazyWithBoxes andalso Lazyboxstore.add lazyBoxes (t, d)
			then ()
			else tryLazyProps w (t, d)
			
			
		fun foldin (w as W {id, pattern, propositions, nominals, diamonds, boxes, disjunctions, nglstore, lazyProps, lazyNoms, lazyBoxes, ...}) (k, d) =
			let
				fun appLazy f (t, d') = f w (t, Dependency.updDepth d' (Dependency.btDepth d))
				
				fun foldin' k = (
					  (
						if !Settings.ecdDisabled
						then
							case Translator.getTerm k
								of Term.A (p, b) => (
									  if (
										Propstore.add propositions p b d
										handle Propstore.Unsat (p, d, d') => raise Unsat (w, [d, d'])
									  )
									  then
									    if !Settings.lazyBranching
									    then app (appLazy tryLazyNoms) (Lazystore.assert lazyProps (p, b) (Dependency.btDepth d))
										else ()
									  else ()
									)
								|  Term.DMD (r, _) => (
										  app (appLazy tryLazyProps) (Lazyboxstore.assert lazyBoxes r (Dependency.btDepth d))
										; if Termstore.add diamonds (k, d)
										  then Agenda.insert (Agenda.DIAMOND (id, k, d, Termstore.numItems boxes), Dependency.btDepth d)
										  else ()
									)
								|  Term.BOX _ =>
									if Termstore.add boxes (k, d)
									then Agenda.insert (Agenda.BOX (id, k, d), Dependency.btDepth d)
									else ()
								|  Term.DISJ cs =>
									if Termstore.add disjunctions (k, d)
									then tryLazyBoxes w (k, d)
									else ()
								|  Term.ALL k' => if Universalstore.add (k', d) then Agenda.insert (Agenda.UNIV (k, d), Dependency.btDepth d) else ()
								|  Term.EX k' => if Existentialstore.add (k', d) then Agenda.insert (Agenda.EXIST (k', d), Dependency.btDepth d) else ()
								|  Term.CONJ cs => app foldin' (Term.Catstore.listItems cs)
								|  Term.AT (n, k') => Agenda.insert (Agenda.AT (n, k', d), Dependency.btDepth d)
								|  Term.EQ n => (
									  if (
									    Propstore.add nominals n true d
									    handle Propstore.Unsat (n, d1, d2) => raise Unsat (w, [d1, d2])
									  )
									  then (
									      Agenda.insert (Agenda.EQ (id, n, d), Dependency.btDepth d)
									    ; if !Settings.lazyWithNominals
									      then app (appLazy scheduleDisjunction) (Lazynomstore.assert lazyNoms n (Dependency.btDepth d))
									      else ()
									  )
									  else ()
									)
								|  Term.NEQ n =>
								    ignore (
									  Propstore.add nominals n false d
									  handle Propstore.Unsat (n, d1, d2) => raise Unsat (w, [d1, d2])
									)
						else
							case Translator.getTerm k
								of Term.A (p, b) => (
									  if (
										Propstore.add propositions p b d
										handle Propstore.Unsat (p, d, d') => raise Unsat (w, [d, d'])
									  )
									  then
									    if !Settings.lazyBranching
									    then app (appLazy tryLazyNoms) (Lazystore.assert lazyProps (p, b) (Dependency.btDepth d))
										else ()
									  else ()
									)
								|  Term.DMD (r, _) => (
									case Termstore.peek boxes (Translator.getNegation k)
										of NONE => (
											  app (appLazy tryLazyProps) (Lazyboxstore.assert lazyBoxes r (Dependency.btDepth d))
											; if Termstore.add diamonds (k, d)
											  then Agenda.insert (Agenda.DIAMOND (id, k, d, Termstore.numItems boxes), Dependency.btDepth d)
											  else ()
											)
										|  SOME d' => raise Unsat (w, [d, d'])
									)
								|  Term.BOX _ => (
									case Termstore.peek diamonds (Translator.getNegation k)
										of NONE =>
												if Termstore.add boxes (k, d)
												then Agenda.insert (Agenda.BOX (id, k, d), Dependency.btDepth d)
												else ()
										|  SOME d' => raise Unsat (w, [d, d'])
									)
								|  Term.DISJ cs => (
									if cs = Term.Catstore.empty
									then raise Unsat (w, [d])
									else
										case Termstore.peek pattern (Translator.getNegation k)
											of NONE =>
													if Termstore.add disjunctions (k, d)
													then tryLazyBoxes w (k, d)
													else ()
											|  SOME d' => raise Unsat (w, [d, d'])
									)
								|  Term.ALL k' => (
									case Existentialstore.peek k'
										of NONE => if Universalstore.add (k', d) then Agenda.insert (Agenda.UNIV (k', d), Dependency.btDepth d) else ()
										|  SOME d' => raise Unsat (w, [d, d'])
									)
								|  Term.EX k' => (
									case Universalstore.peek k'
										of NONE => if Existentialstore.add (k', d) then Agenda.insert (Agenda.EXIST (k', d), Dependency.btDepth d) else ()
										|  SOME d' => raise Unsat (w, [d, d'])
									)
								|  Term.CONJ cs => (
										case Termstore.peek disjunctions (Translator.getNegation k)
											of NONE => app foldin' (Term.Catstore.listItems cs)
											|  SOME d' => raise Unsat (w, [d, d'])
									)
								|  Term.AT (n, k') => Agenda.insert (Agenda.AT (n, k', d), Dependency.btDepth d)
								|  Term.EQ n => (
									  if (
										Propstore.add nominals n true d
										handle Propstore.Unsat (n, d1, d2) => raise Unsat (w, [d1, d2])
									  )
									  then (
										  Agenda.insert (Agenda.EQ (id, n, d), Dependency.btDepth d)
										; if !Settings.lazyWithNominals
										  then app (appLazy scheduleDisjunction) (Lazynomstore.assert lazyNoms n (Dependency.btDepth d))
										  else ()
									  )
									  else ()
									)
								|  Term.NEQ n => ignore (
									  Propstore.add nominals n false d
									  handle Propstore.Unsat (n, d1, d2) => raise Unsat (w, [d1, d2])
									)
					  )
					; (
						if !Settings.semanticBranchingNgl
						then (case Termstore.peek nglstore k of SOME d' => (Debug.output (fn () => "Semantic branching: Conflict with NGL item " ^ (Int.toString k) ^ "\n"); raise Unsat (w, [d, d'])) | _ => ())
						else ()
					  )
				)
			in
				foldin' k
			end
		
		
		fun newNode curDepth predId (k, d) =
			let
				val d' = Dependency.updDepth d curDepth
				
				val pstore = Propstore.empty ()
				val nominals = Propstore.empty ()
				
				val w =	W {
						  id              = !nextId
						, predId          = predId
						, creationDepcy   = d'
						, nominalDepcies  = ref nil
						, pattern         = let val pattern = Termstore.empty () in Termstore.add pattern (k, d'); pattern end
						, propositions    = pstore
						, nominals        = nominals
						, diamonds        = Termstore.empty ()
						, boxes           = Termstore.empty ()
						, disjunctions    = Termstore.empty ()
						, nglstore        = Termstore.empty ()
						, lazyProps       = Lazystore.empty pstore
						, lazyNoms        = Lazynomstore.empty nominals
						, lazyBoxes       = Lazyboxstore.empty (RelationMgr.listReflexive ())
						, blockedDiamonds = ref nil
						, branchPoints    = ref nil
						}
				in
					w before (Ref.incr nextId; foldin w (k, d'))
			end
		
		
		fun getId (W {id, ...}) = id
		
		
		fun peekPredId (W {predId, ...}) = predId
		
		
		fun propagate (w as W {id, creationDepcy, nominalDepcies, pattern, ...}) curDepth xs =
			let
				fun propagate' (k, d) =
					let
						val d' =
							Dependency.updDepth (Dependency.union (d, hd (!nominalDepcies)
								handle List.Empty => creationDepcy)) curDepth
					in
						  Termstore.add pattern (k, d')
						; foldin w (k, d')
					end
			in
				  Debug.output (fn () => "Propagating " ^ (Util.listToString (fn (k, _) => Int.toString k) xs) ^ " to node " ^ (Int.toString id) ^ "\n")
				; (
					if !Settings.checkCacheOften andalso !Settings.cachingEnabled
					then
						let
							val univ = Universalstore.listItems ()
							
							val pattern = xs@(Termstore.listItems pattern)@(map (fn (k, d) => (~k, d)) univ)
						in
							case Cache.approxDependencies pattern
							of SOME d => (
								  Debug.output
									(fn () =>
										  "Pattern "
										^ (Util.listToString Int.toString (map #1 pattern))
										^ " is cached as unsatisfiable\n"
									)
								; raise CachedUnsat (w, d)
								)
							 | NONE => ()
						end
					else ()
				  )
				; app propagate' xs
			end
		
		
		fun addNominalDepcy (w as W {id, nominals, creationDepcy, nominalDepcies, ...}) curDepth d =
			let
				val d' = (Dependency.updDepth (Dependency.union
					(d, hd (!nominalDepcies) handle List.Empty => creationDepcy)) curDepth)
			in
				  Ref.push nominalDepcies d'
			end
		
		
		fun blockDiamond (w as W {blockedDiamonds, ...}) d k =
			Ref.push blockedDiamonds (k, d)
		
		
		fun unblockDiamonds (W {id, diamonds, blockedDiamonds, boxes, ...}) pf =
			let
				fun unblockDiamond (k, _) =
					let
						val d =
							case Termstore.peek diamonds k
								of NONE => Exn.unexpected "Termstore.unblock: diamond to be unblocked not stored."
								 | SOME d => d
					in
						Agenda.insert (Agenda.DIAMOND (id, k, d, Termstore.numItems boxes), Dependency.btDepth d)
					end
				
				val (remaining, unblocked) =
					List.partition pf (!blockedDiamonds)
			in
				  Debug.output (fn () => (Int.toString (length unblocked)) ^ " out of " ^ (Int.toString ((length unblocked) + (length remaining))) ^ " diamonds are no longer blocked\n")
				; app unblockDiamond unblocked
				; blockedDiamonds := remaining
			end
		
		
		fun listBlockedDiamonds (W {blockedDiamonds, ...}) = map #1 (!blockedDiamonds)
		
		
		fun listBranchPoints (W {branchPoints, ...}) = !branchPoints
		
		
		fun propagateDisjunct (w as W {id, nglstore, propositions, disjunctions, diamonds, boxes, nominals, branchPoints, ...}) (k, d, ngs, more) =
			let
				fun checkNgl k = (
					case Translator.getTerm k
						of Term.A (p, b) => (
							case Propstore.peek propositions p
								of SOME (b', d') => if b = b' then raise Unsat (w, [d, d']) else ()
								 | _ => ()
							)
						|  Term.EQ n => (
							case Propstore.peek nominals n
								of SOME (b, d') => if b then raise Unsat (w, [d, d']) else ()
								 | _ => ()
							)
						|  Term.NEQ n => (
							case Propstore.peek nominals n
								of SOME (b, d') => if b then () else raise Unsat (w, [d, d'])
								 | _ => ()
							)
						|  Term.DISJ _ => (
							case Termstore.peek disjunctions k
								of SOME d' => raise Unsat (w, [d, d'])
								 | _ => ()
							)
						|  Term.DMD _ => (
							case Termstore.peek diamonds k
								of SOME d' => raise Unsat (w, [d, d'])
								 | _ => ()
							)
						|  Term.BOX _ => (
							case Termstore.peek boxes k
								of SOME d' => raise Unsat (w, [d, d'])
								 | _ => ()
							)
						|  _ => ()
				) handle (e as Unsat _) => (Debug.output (fn () => "Semantic Branching: Conflict with new NGL item\n"); raise e)
			in
				  if more then Ref.push branchPoints (Dependency.btDepth d) else ()
				; app (fn k => ignore (Termstore.add nglstore (k, d))) ngs
				; foldin w (k, d)
				; (
					if !Settings.semanticBranchingEnabled
					then if !Settings.semanticBranchingNgl
					then app checkNgl ngs
					else app (fn k => foldin w (Translator.getNegation k, d)) ngs
					else ()
				  )
			end
		
		
		fun getPattern (W {pattern, ...}) = Termstore.listItems pattern
		
		fun listBoxes (W {boxes, ...}) = Termstore.listItems boxes
		
		
		fun listPropositions (W {propositions, lazyProps, ...}) =
			if !Settings.lazyBranching
			then 
				Listsort.sort
					(fn ((x, _), (y, _)) => String.compare (x, y))
					((map (fn x => (#1 x, #2 x)) (Propstore.listItems propositions)) @ (Lazystore.listPropositions lazyProps))
			else map (fn x => (#1 x, #2 x)) (Propstore.listItems propositions)
		
		
		fun listNominals (W {nominals, lazyNoms, ...}) =
			if !Settings.lazyWithNominals
			then
				Listsort.sort
					(fn ((x, _), (y, _)) => String.compare (x, y))
					(
					    (map (fn x => (#1 x, #2 x)) (Propstore.listItems nominals))
					  @ (map (fn x => (x, false)) (Lazynomstore.listNominals lazyNoms))
					)
			else map (fn x => (#1 x, #2 x)) (Propstore.listItems nominals)
		
		
		fun bcp (W {pattern, propositions, nominals, diamonds, boxes, disjunctions, nglstore, ...}) cs =
			let
				val dsr = ref nil
				
				fun fDiamonds k =
					case Termstore.peek diamonds k
						of SOME _ => raise Satisfied
						|  NONE => (
							case Termstore.peek boxes (Translator.getNegation k)
								of NONE => true
								|  SOME d => (Ref.push dsr d; false)
							)
				
				fun fBoxes k =
					case Termstore.peek boxes k
						of SOME _ => raise Satisfied
						|  NONE => (
							case Termstore.peek diamonds (Translator.getNegation k)
								of NONE => true
								|  SOME d => (Ref.push dsr d; false)
							)
				
				fun fConjunctions k =
					case Termstore.peek pattern k
						of SOME _ => raise Satisfied
						|  NONE => (
							case Termstore.peek disjunctions (Translator.getNegation k)
								of NONE => true
								|  SOME d => (Ref.push dsr d; false)
							)
				
				fun fDisjunctions k =
					case Termstore.peek disjunctions k
						of SOME _ => raise Satisfied
						|  NONE => (
							case Termstore.peek pattern (Translator.getNegation k)
								of NONE => true
								|  SOME d => (Ref.push dsr d; false)
							)
				
				fun fUniversals k =
					case Universalstore.peek k
						of SOME _ => raise Satisfied
						|  NONE => (
							case Existentialstore.peek (Translator.getNegation k)
								of NONE => true
								|  SOME d => (Ref.push dsr d; false)
							)
				
				fun fExistentials k =
					case Existentialstore.peek k
						of SOME _ => raise Satisfied
						|  NONE => (
							case Universalstore.peek (Translator.getNegation k)
								of NONE => true
								|  SOME d => (Ref.push dsr d; false)
							)
				
				fun ff k =
					let
						fun ffa k =
							case Translator.getTerm k
								of Term.A (p, b) => (
									case Propstore.peek propositions p
										of NONE => true
										|  SOME (b', d) =>
											if b = b'
											then raise Satisfied
											else (Ref.push dsr d; false)
									)
								|  Term.DMD _ => fDiamonds k
								|  Term.BOX _ => fBoxes k
								|  Term.CONJ _ => fConjunctions k
								|  Term.DISJ _ => fDisjunctions k
								|  Term.ALL k' => fUniversals k'
								|  Term.EX k' => fExistentials k'
								|  Term.EQ n => (
										case Propstore.peek nominals n
											of NONE => true
											 | SOME (true, d) => raise Satisfied
											 | SOME (false, d) => (Ref.push dsr d; false)
									)
								| Term.NEQ n => (
										case Propstore.peek nominals n
											of NONE => true
											 | SOME (true, d) => (Ref.push dsr d; false)
											 | SOME (false, d) => raise Satisfied
									)
								|  _ => true
						
						fun ffb k =
							case Termstore.peek nglstore k
								of NONE => true
								|  SOME d => (Ref.push dsr d; false)
					in
						ffa k andalso (not (!Settings.semanticBranchingNgl) orelse ffb k)
					end
			in
				(Term.Catstore.filter ff cs, !dsr)
			end
		
		
		fun mergeInto
			(w1 as W {nominalDepcies = r_nd, pattern = r_pat, propositions = r_props, nominals = r_noms, diamonds = r_dias, boxes = r_boxes, disjunctions = r_disj, lazyProps = r_lazyProps, lazyNoms = r_lazyNoms, lazyBoxes = r_lazyBoxes, id, ...})
			curDepth
			(w2 as W {nominalDepcies = o_nd, pattern = o_pat, propositions = o_props, nominals = o_noms, diamonds = o_dias, boxes = o_boxes, disjunctions = o_disj, lazyProps = o_lazyProps, lazyNoms = o_lazyNoms, lazyBoxes = o_lazyBoxes, id = o_id, ...})
			d =
			let
				val _ = Debug.output (fn () => "Merging " ^ (Int.toString o_id) ^ " into " ^ (Int.toString id) ^ "\n")
				
				val d' = Dependency.updDepth (Dependency.union (hd (!r_nd), hd (!o_nd))) curDepth
				
				fun appLazy f (k, d'') = f w1 (k, Dependency.union (Dependency.union (d, d'), d''))
			in
				  (*add the dependency set of the nominal causing the merge to the set of nominal dependencies*)
				  Ref.push r_nd d'
				  (*merge the patterns*)
				; app (fn (k, d) => ignore (Termstore.add r_pat (k, Dependency.union (d, d')))) (Termstore.listItems o_pat)
				  (*copy propositional literals; check laziness conditions if necessary*)
				; app
					(fn (p, b, d) => (
						  if (Propstore.add r_props p b (Dependency.union (d, d')))
						  then
							if !Settings.lazyBranching
							then app (appLazy tryLazyNoms) (Lazystore.assert r_lazyProps (p, b) (curDepth))
							else ()
						  else ()
						)
					)
					(Propstore.listItems o_props)
				  handle Propstore.Unsat (p, d, d') => raise Unsat (w1, [d, d'])
				  (*copy nominal literals; check laziness conditions if necessary*)
				; app
					(fn (n, b, d) => (
						  ignore (Propstore.add r_noms n b (Dependency.union (d, d')))
						; if !Settings.lazyWithNominals
						  then app (appLazy scheduleDisjunction) (Lazynomstore.assert r_lazyNoms n (curDepth))
						  else ()
						)
					)
					(Propstore.listItems o_noms)
				  handle Propstore.Unsat (n, d1, d2) => raise Unsat (w1, [d1, d2])
				  (*copy diamonds; check laziness conditions if necessary*)
				; app
					(fn (k, d) => (
						  ignore (Termstore.add r_dias (k, Dependency.union (d, d')))
						; if !Settings.lazyWithBoxes
						  then
							app
								(appLazy scheduleDisjunction)
								(Lazyboxstore.assert
									r_lazyBoxes
									(case Translator.getTerm k
										of Term.DMD (r, _) => r
										 | _ => Exn.unexpected "Node.merge: not a diamond"
									)
									(curDepth)
								)
						  else ()
						; if !Settings.dontMergeSuccLists
						  then Agenda.insert (Agenda.DIAMOND (o_id, k, Dependency.union (d, d'), Termstore.numItems r_boxes), curDepth)
						  else ()
						)
					)
					(Termstore.listItems o_dias)
				  (*copy boxes*)
				; app (fn (k, d) => ignore (Termstore.add r_boxes (k, Dependency.union (d, d')))) (Termstore.listItems o_boxes)
				  (*copy disjunctions*)
				; app (fn (k, d) => ignore (Termstore.add r_disj (k, Dependency.union (d, d')))) (Termstore.listItems o_disj)
				  (*copy contents of lazy branching stores*)
				; app (appLazy tryLazyBoxes) (Lazyboxstore.listItems o_lazyBoxes)
				; app (appLazy tryLazyProps) (Lazystore.listItems o_lazyProps)
				; app (appLazy tryLazyNoms) (Lazynomstore.listItems o_lazyNoms)
				  (*add boxes to the agenda*)
				; if !Settings.dontMergeSuccLists
				  then
					app
						(fn (k, d) => Agenda.insert (Agenda.BOX (id, k, Dependency.union (d, d')), curDepth))
						(Termstore.listItems o_boxes)
				  else
					(*add all boxes to the agenda*)
					app
						(fn (k, d) => Agenda.insertX (Agenda.BOX (id, k, Dependency.union (d, d')), curDepth))
						(Termstore.listItems r_boxes)
			end
	
	
	fun backtrack (w as W {id, nominalDepcies, pattern, propositions, nominals, diamonds, boxes, disjunctions, nglstore, lazyProps, lazyNoms, lazyBoxes, blockedDiamonds, branchPoints, ...}) d =
		let
			fun bdmf nil = nil
			  | bdmf (xs as (_, d')::xr) = if d' <= d then xs else bdmf xr
			
			fun bpmf nil = nil
			  | bpmf (xs as (x::xr)) = if x <= d then xs else bpmf xr
		in
			  Termstore.backtrack pattern d
			; Ref.modify (List.filter (fn d' => Dependency.btDepth d' <= d)) nominalDepcies
			; Propstore.backtrack propositions d
			; Propstore.backtrack nominals d
			; Termstore.backtrack diamonds d
			; Termstore.backtrack boxes d
			; Termstore.backtrack disjunctions d
			; Termstore.backtrack nglstore d
			; Lazystore.backtrack lazyProps d
			; Lazynomstore.backtrack lazyNoms d
			; Lazyboxstore.backtrack lazyBoxes d
			; Ref.modify bdmf blockedDiamonds
			; Ref.modify bpmf branchPoints
		end
		
		
		fun toString (W {id, pattern, propositions, nominals, diamonds, boxes, disjunctions, nglstore, ...}) =
			  "\n-------NODE-------"
			^ "\n id: " ^ (Int.toString id)
			^ "\n nominals:     " ^ (Propstore.toString nominals)
			^ "\n pattern:      " ^ (Termstore.toString pattern)
			^ "\n propositions: " ^ (Propstore.toString propositions)
			^ "\n boxes:        " ^ (Termstore.toString boxes)
			^ "\n diamonds:     " ^ (Termstore.toString diamonds)
			^ "\n disjunctions: " ^ (Termstore.toString disjunctions)
			^ "\n ngl:          " ^ (Termstore.toString nglstore)
			^ "\n-------------------\n\n"
	end
