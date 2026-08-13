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


structure BlockingMgr :> BLOCKINGMGR =
	struct
		type pattern = Term.index * (Term.index list)
		
		
		val patterns = ref (Patternstore.mkStore 0)
		
		
		fun initialize size =
			let
			in
				  patterns := (Patternstore.mkStore size)
			end
		
		
		fun listBlockedSuccessors w =
			let
				fun getPattern k =
					case Translator.getTerm k
						of Term.DMD (r, t) =>
							(r, t,
								List.mapPartial
									(fn (k', _) =>
										case Translator.getTerm k'
											of Term.BOX (r', t') => if r' = r then SOME t' else NONE
											|  _ => Exn.unexpected "BlockingMgr.listBlockedSuccessors.getPattern: not a box"
									)
									(Node.listBoxes w)
							)
						|  _ => Exn.unexpected "BlockingMgr.listBlockedSuccessors.getPattern: not a diamond"
			in
				map
					(fn k =>
						case getPattern k
							of (r, t, ts) => (
									r,
									case Nodestore.findPattern (t::ts)
										of SOME w => w
										|  _ => Exn.unexpected ("BlockingMgr.listBlockedSuccessors: no node expands the pattern [" ^ (Util.listToString Int.toString (t::ts)) ^ "] for node " ^ (Int.toString (Node.getId w)))
									)
					)
					(Node.listBlockedDiamonds w)
			end
		
		
		fun backtrack d =
			let
				fun mf nil = NONE
				  | mf (xs as ((_, d')::xr)) = if d < d' then mf xr else SOME xs
			in
				  Patternstore.backtrack (!patterns) d
			end
		
		
		fun pbBlocking w k d curDepth =
			let
				val (rel, dia) =
					case Translator.getTerm k
						of Term.DMD x => x
						 | _ => Exn.unexpArg "BlockingMgr.pbBlocking: not a diamond"
				
				val boxes =
					if RelationMgr.isTransitive rel
					then
						List.concat (
							List.mapPartial
								(fn (k, _) =>
									case Translator.getTerm k
										of Term.BOX (r, k') => if r = rel then SOME [k, k'] else NONE
										 | _ => Exn.unexpected "BlockingMgr.pbBlocking: not a box"
								)
								(Node.listBoxes w)
						)
					else
						List.mapPartial
							(fn (k, _) =>
								case Translator.getTerm k
									of Term.BOX (r, k') => if r = rel then SOME k' else NONE
									 | _ => Exn.unexpected "BlockingMgr.pbBlocking: not a box"
							)
							(Node.listBoxes w)
			in
				if Patternstore.hasMatch (!patterns) (dia::boxes)
				then (Node.blockDiamond w curDepth k; true)
				else (
					  Debug.output (fn () => "Remembering pattern " ^ (Util.listToString Int.toString (dia::boxes)) ^ "\n")
					; Patternstore.add (!patterns) (dia::boxes, curDepth)
					; false)
			end
		
		
		fun findUnblocked w =
			let
				val _ = Debug.output (fn () => "taking unblocked diamonds\n")
				
				val id = Node.getId w
				
				val bs = map (fn (x, d) => case Translator.getTerm x of Term.BOX y => (y, d) | _ => Exn.unexpected "BlockingMgr.findUnblocked: not a box") (Node.listBoxes w)
				
				fun pf (k, _) =
					let
						
						val (rel,  dia) = case Translator.getTerm k of Term.DMD x => x | _ => Exn.unexpected "BlockingMgr.findUnblocked: not a diamond"
						
						val boxes =
							List.mapPartial
								(fn (k, _) =>
									case Translator.getTerm k
										of Term.BOX (r, k') => if r = rel then SOME k' else NONE
										 | _ => Exn.unexpected "BlockingMgr.pbBlocking: not a box"
								)
								(Node.listBoxes w)
					in
						Patternstore.hasMatch (!patterns) (dia::boxes)
				end
			in
				Node.unblockDiamonds w pf
			end
		
		
		fun store w d = Patternstore.add (!patterns) (map #1 (Node.getPattern w), d)
	end
