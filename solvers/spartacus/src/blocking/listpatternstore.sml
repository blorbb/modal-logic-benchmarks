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


structure ListPatternstore :> PATTERNSTORE =
	struct
		datatype store = S of {inv : (int list) Array.array, nextId : int ref, btr : (int * int) list ref}
		
		
		fun mkStore n = S {inv = Array.array (n, nil), nextId = ref 0, btr = ref [(~1, ~1)]}
		
		
		fun backtrack (S {inv, btr, ...}) d =
			let
				fun mf _ nil = nil
				  | mf p (xs as x::xr) = if x >= p then mf p xr else xs
				
				fun backtrack' _ nil = Exn.unexpArg "ListPatternstore.backtrack.backtrack'"
				  | backtrack' p (ts as ((d', p')::tr)) =
						if d < d'
						then backtrack' p' tr
						else (btr := ts; Array.modify (mf p) inv)
			in
				case !btr
					of (d', p)::tr => if d < d' then backtrack' p tr else ()
					 | nil => Exn.unexpected "ListPatternstore.backtrack"
			end
		
		
		fun add (S {inv, nextId, btr}) (ks, d) =
			let
				fun checkDepth() =
					case !btr
						of ts as (d', _)::tr => (
							case Int.compare (d', d)
								of EQUAL => ()
								 | LESS => btr := ((d, !nextId)::ts)
								 | GREATER => Exn.unexpected "ListPatternstore.add.checkDepth: insertion depth too small."
							)
						 | nil => Exn.unexpected "ListPatternstore.add.checkDepth: list is empty"
				
				fun add' k =
					Array.update (inv, k, (!nextId)::(Array.sub (inv, k)))
					handle _ => Exn.unexpected ("ListPatternstore.add.add': k = " ^ (Int.toString k) ^ ", ter(k) = " ^ (Term.toString (Translator.getTerm k)))
			in
				  checkDepth ()
				; app add' ks
				; Ref.incr nextId
			end
		
		
		fun hasMatch _ nil = Exn.unexpArg "Patternstore.hasMatch"
		  | hasMatch (S {inv, ...}) [k] = Array.sub (inv, k) <> nil
		  | hasMatch (S {inv, nextId, ...}) (k::kr) =
			let
				exception NoMatch
				
				fun dropUntilMatch nil _ = (nil, nil)
				  | dropUntilMatch _ nil = (nil, nil)
				  | dropUntilMatch (qs as q::qr) (xs as x::xr) =
						if q = x
						then (qs, xs)
						else if q < x
						then dropUntilMatch qs xr
						else dropUntilMatch qr xs
				
				fun findMatch _ nil _ = false
				  | findMatch _ _ (nil::_) = Exn.unexpArg "ListPatternstore.hasMatch.findMatch"
				  | findMatch rs qs (x::xr) =
					let
						val (qs', x') = dropUntilMatch qs x
					in
						findMatch (x'::rs) qs' xr
					end
				  | findMatch rs (qs as q::qr) nil = (
						case List.rev rs
							of (xs as (x::_)::_) => if q = x then true else findMatch nil qs xs
							 | nil::_ => Exn.unexpected "ListPatternstore.hasMatch.findMatch"
							 | nil => Exn.unexpected "ListPatternstore.hasMatch.findMatch"
						)
			in
				findMatch nil (case Array.sub (inv, k) of nil => raise NoMatch | xs => xs) (map (fn k => case Array.sub (inv, k) of nil => raise NoMatch | xs => xs) kr) handle NoMatch => false
			end
	end
