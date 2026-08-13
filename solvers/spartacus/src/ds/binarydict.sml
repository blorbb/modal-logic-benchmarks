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


structure Binarydict :> DICT =
	struct
		datatype 'a dict = D of (int, 'a) Binarymap.dict ref
		
		exception NotFound
		exception Empty
		
		fun empty () = D (ref (Binarymap.mkDict Int.compare))
		
		fun clear (D r) = r := (Binarymap.mkDict Int.compare)
		
		fun insert (D r, k, x) = r := (Binarymap.insert (!r, k, x))
		
		fun get (D r, k) = Binarymap.find (!r, k) handle Binarymap.NotFound => raise NotFound
		
		fun peek (D r, k) = Binarymap.peek (!r, k)
		
		fun remove (D r, k) = (fn (bm, res) => (r := bm; res)) (Binarymap.remove (!r, k)) handle Binarymap.NotFound => raise NotFound
		
		fun isEmpty (D r) =
			let
				exception Nonempty
			in
				Binarymap.foldl (fn _ => raise Nonempty) true (!r) handle Nonempty => false
			end
		
		fun numItems (D r) = Binarymap.numItems (!r)
		
		fun listItems (D r) = Binarymap.listItems (!r)
		
		fun app f (D r) = Binarymap.app f (!r)
		
		fun foldr f b (D r) = Binarymap.foldr f b (!r)
		
		fun foldl f b (D r) = Binarymap.foldl f b (!r)
		
		fun modify f (D r) = r := (Binarymap.map f (!r))
		
		fun modifyo f (D r) =
			let
				fun ff (k, x, y) =
					case f (k, x)
						of NONE => y
						|  SOME x' => Binarymap.insert (y, k, x')
			in
				r := (Binarymap.foldl ff (Binarymap.mkDict Int.compare) (!r))
			end
		
		fun modifyItem f (D r, k) = r := (Binarymap.insert (!r, k, f (Binarymap.find (!r, k)))) handle Binarymap.NotFound => raise NotFound
		
		fun min d =
			let
				exception Result of int * 'a
			in
				foldl (fn (k, x, y) => raise Result (k, x)) (fn () => raise Empty) d () handle Result res => res
			end
		
		fun max d =
			let
				exception Result of int * 'a
			in
				foldr (fn (k, x, y) => raise Result (k, x)) (fn () => raise Empty) d () handle Result res => res
			end
		
		fun find p d =
			let
				exception Result of int * 'a
			in
				foldl (fn (k, x, y) => if p (k, x) then raise Result (k, x) else y) NONE d handle Result res => SOME res
			end
		
		fun revfind p d =
			let
				exception Result of int * 'a
			in
				foldr (fn (k, x, y) => if p (k, x) then raise Result (k, x) else y) NONE d handle Result res => SOME res
			end
		
		fun filter p (D r) =
			let
				fun ff (k, x, y) = if p (k, x) then y else #1 (Binarymap.remove (y, k))
			in
				r := (Binarymap.foldl ff (!r) (!r))
			end
	end
