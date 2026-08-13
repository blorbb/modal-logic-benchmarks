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


structure Dynarraydict :> DICT =
	struct
		datatype 'a dict = D of (IntBinarySet.set ref * ('a option) DynamicArray.array)
		
		exception NotFound
		exception Empty
		
		fun empty () = D (ref IntBinarySet.empty, DynamicArray.array (100, NONE))
		
		fun clear (D (s, arr)) =
			let
			in
				IntBinarySet.app (fn k => DynamicArray.update (arr, k, NONE)) (!s)
				; s := IntBinarySet.empty
			end
		
		fun insert (D (s, arr), k, x) =
			let
			in
				  s := (IntBinarySet.add (!s, k))
				; DynamicArray.update (arr, k, SOME x)
			end
		
		fun get (D (_, arr), k) =
				case DynamicArray.sub (arr, k)
					of NONE => raise NotFound
					|  SOME x => x
		
		fun peek (D (_, arr), k) = DynamicArray.sub (arr, k)
		
		fun remove (D (s, arr), k) =
			let
			in
				  s := (IntBinarySet.delete (!s, k))
				; Option.valOf (DynamicArray.sub (arr, k))
				before DynamicArray.update (arr, k, NONE)
			end
		
		fun isEmpty (D (s, _)) = IntBinarySet.isEmpty (!s)
		
		fun numItems (D (s, _)) = IntBinarySet.numItems (!s)
		
		fun listItems (D (s, arr)) = IntBinarySet.foldr (fn (k, xs) => (k, Option.valOf (DynamicArray.sub (arr, k)))::xs) nil (!s)
		
		fun app f (D (s, arr)) = IntBinarySet.app (fn k => f (k, Option.valOf (DynamicArray.sub (arr, k)))) (!s)
		
		fun foldr f b (D (s, arr)) = IntBinarySet.foldr (fn (k, y) => f (k, Option.valOf (DynamicArray.sub (arr, k)), y)) b (!s)
		
		fun foldl f b (D (s, arr)) = IntBinarySet.foldl (fn (k, y) => f (k, Option.valOf (DynamicArray.sub (arr, k)), y)) b (!s)
		
		fun modify f (D (s, arr)) = IntBinarySet.app (fn k => DynamicArray.update (arr, k, Option.map (fn x => f (k, x)) (DynamicArray.sub (arr, k)))) (!s)
		
		fun modifyo f (d as D (s, arr)) =
			let
				fun af k =
					case f (k, Option.valOf (DynamicArray.sub (arr, k)))
						of NONE => ignore (remove (d, k))
						|  SOME x => insert (d, k, x)
			in
				IntBinarySet.app af (!s)
			end
		
		fun modifyItem f (d, k) = insert (d, k, f (get (d, k)))
		
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
		
		fun filter p (d as D (s, arr)) = IntBinarySet.app (fn k => if p (k, Option.valOf (DynamicArray.sub (arr, k))) then () else ignore (remove (d, k))) (!s)
	end
