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


structure Bitmatrix :> BITMATRIX =
	struct
		datatype pos = FRESH of int | USED of int
		
		datatype bitmatrix = BM of {size : int ref, bound : bool, next : pos ref, arr : BitArray.array option Array.array}
		
		fun mkMatrix (rows, columns, bound) = BM {size = ref columns, bound = bound, next = ref (FRESH 0) , arr = Array.array (rows, NONE)}
		
		
		fun copy (BM {size, bound, next, arr}) =
			let
				val arr' = Array.tabulate (Array.length arr, (fn n => Option.map (fn ba => BitArray.extend0 (ba, !size)) (Array.sub (arr, n))))
			in
				BM {size = ref (!size), bound = bound, next = ref (!next), arr = arr'}
			end
		
		
		fun retain (BM {size, bound, next, arr}, n) =
			let
				val empty = BitArray.bits (0, nil)
			in
				  if bound then Exn.unexpected "Bitmatrix.retain: bit matrix is size bound." else ()
				; (
					if n = 0
					then (
						  Array.modify (fn _ => NONE) arr
						; next := (FRESH 0)
						; size := 100
						)
					else (
						  Array.modify (Option.map (fn ba => BitArray.orb (ba, BitArray.bits (0, nil), n))) arr
						; next := FRESH n
						; size := n
						)
				)
			end
		
		
		fun getPos (BM {next, ...}) =
			case !next
				of FRESH n => n
				 | _ => Exn.unexpArg "Bitmatrix.getPos"
		
		
		fun insert (BM {size, bound, next, arr}, xs) =
			let
				val (used, pos) =
					case !next
						of FRESH p =>
							if bound andalso p >= !size
							then (true, 0)
							else (false, p)
						 | USED p =>
							if p >= !size 
							then (true, 0)
							else (true, p)
			in
				  (
					if used
					then Array.app (Option.app (fn ba => BitArray.clrBit (ba, pos))) arr
					else ()
				  )
				; (
					if not bound andalso pos >= !size
					then (
						  Array.modify (Option.map (fn ba => BitArray.extend0 (ba, !size * 2))) arr
						; size := (!size * 2)
					)
					else ()
				  )
				; app (fn x => case Array.sub (arr, x) of SOME ba => BitArray.setBit (ba, pos) | NONE => Array.update (arr, x, SOME (BitArray.bits (!size, [pos])))) xs handle _ => Exn.unexpected ("Bitmatrix.insert: pos = " ^ (Int.toString pos) ^ ", size = " ^ (Int.toString (!size)))
				; next := (if used then USED (pos + 1) else FRESH (pos + 1))
			end
		
		fun hasSubset (BM {arr, next, size, ...}, xs) =
			let
				val xs' = (fn ba => (BitArray.complement ba; BitArray.getBits ba)) (BitArray.bits (Array.length arr, xs))
				
				val res = foldl (fn (y, s) => case Array.sub (arr, y) of SOME ba => BitArray.orb (ba, s, !size) | NONE => s) (BitArray.bits (!size, nil)) xs'
			in
				  BitArray.complement res
				; case ((BitArray.getBits res), !next)
					of (_::_, USED _) => true
					 | (y::_, FRESH pos) => y < pos
					 | (nil, _) => false
			end
		
		fun hasSuperset (BM {arr, size, ...}, xs) =
			let
				exception Negative
				
				val one =
					let
						val x = BitArray.bits (!size, nil)
					in
						  BitArray.complement x
						; x
					end
				
				fun ff (y, s) =
					case Array.sub (arr, y)
						of SOME ba => BitArray.andb (ba, s, !size)
						 | NONE => raise Negative
			in
				not (BitArray.isZero (foldl ff one xs)) handle Negative => false
			end
		
		fun toString (BM _) = "not implemented"
	end
