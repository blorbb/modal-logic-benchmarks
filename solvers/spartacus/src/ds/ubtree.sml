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


structure Ubtree =
	struct
		datatype 'a tree =
			  ROOT of ('a * 'a -> order) * ('a, 'a tree) Binarymap.dict
			| NODE of ('a, 'a tree) Binarymap.dict * bool
		
		
		fun mkTree ord = ROOT (ord, Binarymap.mkDict ord)
		
		
		fun insert ((NODE _), _) = Exn.unexpArg "Ubtree.insert"
		  | insert (_, nil) = Exn.unexpArg "Ubtree.insert: empty set"
		  | insert (root as ROOT (ord, _), xs) =
			let
				val xs = Util.cleanSort ord xs
				
				fun mkPath nil = NODE (Binarymap.mkDict ord, true)
				  | mkPath (x::xr) = NODE (Binarymap.insert (Binarymap.mkDict ord, x, mkPath xr), false)
				
				fun insert' (_, nil) = Exn.unexpArg "Ubtree.insert.insert'"
				  | insert' (ROOT (ord, dict), xs) = ROOT (ord, insert'' (dict, xs))
				  | insert' (NODE (dict, eop), xs) = NODE (insert'' (dict, xs), eop)
				and insert'' (dict, [x]) = (
					case Binarymap.peek (dict, x)
						of NONE => Binarymap.insert (dict, x, mkPath nil)
						 | SOME (NODE (_, true)) => dict
						 | SOME (NODE (dict', false)) => Binarymap.insert (dict, x, NODE (dict', true))
						 | SOME (ROOT _) => Exn.unexpected "Ubtree.insert.insert''"
					)
				  | insert'' (dict, xs as x::xr) = (
						case Binarymap.peek (dict, x)
							of NONE => Binarymap.insert (dict, x, mkPath xr)
							 | SOME node => Binarymap.insert (dict, x, insert' (node, xr))
					)
				  | insert'' (_, nil) = Exn.unexpArg "Ubtree.insert.insert''"
			in
				insert' (root, xs)
			end
		
		
		fun findSubset (NODE _, _) = Exn.unexpArg "Ubtree.findSubset"
		  | findSubset (_, nil) = NONE
		  | findSubset (ROOT (ord, dict), xs) =
			let
				val xs = Util.cleanSort ord xs
				
				fun lookup (dict, [x]) = (
					case Binarymap.peek (dict, x)
						of SOME (NODE (_, true)) => SOME [x]
						 | _ => NONE
					)
				  | lookup (dict, x::xr) = (
					case Binarymap.peek (dict, x)
						of SOME (NODE (_, true)) => SOME [x]
						 | SOME (NODE (dict', false)) => (
							case lookup (dict', xr)
								of SOME ys => SOME (x::ys)
								 | NONE => lookup (dict, xr)
							)
						 | SOME (ROOT _) => Exn.unexpArg "Ubtree.findSubset.lookup.mf"
						 | NONE => lookup (dict, xr)
					)
				  | lookup (_, nil) = NONE
			in
				lookup (dict, xs)
			end
			
		
		fun findSuperset f (NODE _, _) = Exn.unexpArg "Ubtree.findSuperset"
		  | findSuperset f (ROOT (ord, dict), xs) =
			let
				val xs = Util.cleanSort ord xs
				
				fun walkPath dict =
					let
						fun walkPath' (_, _, SOME res) = SOME res
						  | walkPath' (y, NODE (_, true), NONE) = SOME [y]
						  | walkPath' (y, NODE (dict, false), NONE) = (
							case Binarymap.foldl walkPath' NONE dict
								of NONE => Exn.unexpected "Ubtree.findSuperset.walkPath.walkPath'"
								 | SOME ys => SOME (y::ys)
							)
						  | walkPath' _ = Exn.unexpArg "Ubtree.findSuperset.walkPath.walkPath'"
					in
						Binarymap.foldl walkPath' NONE dict
					end
				
				fun lookup (dict, nil) = walkPath dict
				  | lookup (dict, xs) = Binarymap.foldl (lookup' xs) NONE dict
				and lookup' _ (_, _, SOME res) = SOME res
				  | lookup' nil _ = Exn.unexpArg "Ubtree.findSuperset.lookup'"
				  | lookup' (xs as (x::xr)) (y, NODE (dict, eop), NONE) = (
					case ord (x, y)
						of LESS => NONE
						 | EQUAL => (if null xr andalso eop then SOME [x] else case lookup (dict, xr) of NONE => NONE | SOME ys => SOME (x::ys))
						 | GREATER => (case lookup (dict, xs) of NONE => NONE | SOME ys => SOME (y::ys))
					)
				  | lookup' _ _ = Exn.unexpArg "Ubtree.findSuperset.lookup'"
			in
				lookup (dict, xs)
			end
		
		
		fun hasSubset x = not ((findSubset x) = NONE)
		
		
		fun hasSuperset (NODE _, _) = Exn.unexpArg "Ubtree.hasSuperset"
		  | hasSuperset (ROOT (ord, dict), xs) =
			let
				val xs = Util.cleanSort ord xs
				
				exception Found
				
				fun lookup (dict, nil) = raise Found
				  | lookup (dict, xs) = Binarymap.app (lookup' xs) dict
				and lookup' nil _ = Exn.unexpArg "Ubtree.hasSuperset.lookup'"
				  | lookup' (xs as (x::xr)) (y, NODE (dict, eop)) = (
					case ord (x, y)
						of LESS => ()
						 | EQUAL => if null xr andalso eop then raise Found else lookup (dict, xr)
						 | GREATER => lookup (dict, xs)
					)
				  | lookup' _ _ = Exn.unexpArg "Ubtree.hasSuperset.lookup'"
			in
				(lookup (dict, xs); false) handle Found => true
			end
		
		
		fun toString f (NODE _) = Exn.unexpArg "Ubtree.toString"
		  | toString f (ROOT (_, dict)) =
			let
				fun indent 0 = ""
				  | indent n = "  " ^ (indent (n - 1))
				
				fun toString' n (y, NODE (dict, eop)) = (indent n) ^ (f y) ^ (if eop then "$" else "") ^ "\n" ^ (concat (map (toString' (n + 1)) (Binarymap.listItems dict)))
				  | toString' n _ = Exn.unexpArg "Ubtree.toString"
			in
				concat (map (toString' 0) (Binarymap.listItems dict))
			end
	end
