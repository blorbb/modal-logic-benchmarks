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


structure Dependency :> DEPENDENCY =
	struct
		datatype depcy =
				DEPJ of int * IntBinarySet.set ref
			  | DEP of int
		
		
		fun create d =
				if !Settings.backjumpingDisabled andalso not (!Settings.cachingEnabled)
				then DEP d
				else DEPJ (d, ref (IntBinarySet.empty))
		
		
		fun updDepth (x as (DEPJ (d, ds))) d' = DEPJ (d', ds)
		  | updDepth (x as (DEP d)) d' = DEP d'
		
		
		fun btDepth (DEPJ (d, _)) = d
		  | btDepth (DEP d) = d
		
		
		fun add (DEPJ (d, ds)) n = DEPJ (d, ref (IntBinarySet.add (!ds, n)))
		  | add (x as (DEP d)) _ = x
		
		
		fun depset (DEPJ (_, ds)) = !ds
		  | depset (DEP _) = Exn.unexpected "Dependency.depset: No dependency set stored"
		
		
		fun merge (DEPJ (_, ds)) d dso = DEPJ (d, ref (case dso of NONE => !ds | SOME ds' => IntBinarySet.union (!ds, ds')))
		  | merge (DEP _) d _ = DEP d
		
		
		fun union (DEPJ (d1, ds1), DEPJ (d2, ds2)) = DEPJ (Int.max (d1, d2), ref (IntBinarySet.union (!ds1, !ds2)))
		  | union ((DEP d1), (DEP d2)) = DEP (Int.max (d1, d2))
		  | union _ = Exn.unexpected "Dependency.union"
		
		
		fun toString (DEPJ (d, ds)) = (Int.toString d) ^ ":{" ^ (Util.IntBinarySetToString (!ds)) ^ "}"
		  | toString (DEP d) = Int.toString d
		
		
		fun compare (DEPJ (_, ds1), (DEPJ (_, ds2))) =
			let
				fun peekLast s =
					let
						exception Found of int
					in
						IntBinarySet.foldr (fn (x, _) => raise (Found x)) NONE s handle Found x => SOME x
					end
				
				fun compare' (x, y) =
					case (peekLast x, peekLast y)
						of (NONE, NONE) => EQUAL
						 | (SOME _, NONE) => GREATER
						 | (NONE, SOME _) => LESS
						 | (SOME a, SOME b) =>
							case Int.compare (a, b)
								of EQUAL => compare' (IntBinarySet.delete (x, a), IntBinarySet.delete (y, b))
								 | r => r
			in
				compare' (!ds1, !ds2)
			end
		  | compare (DEP d1, DEP d2) = Int.compare (d1, d2)
		  | compare _ = Exn.unexpected "Dependency.compare"
	end
