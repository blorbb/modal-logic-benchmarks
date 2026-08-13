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


structure BitmatrixCache :> CACHE =
	struct
		val store = ref (Bitmatrix.mkMatrix (0, 1, false))
		
		
		val numStoreOps = ref 0
		val numHits = ref 0
		val numMisses = ref 0
		
		
		fun initialize n =
			let
			in
				  numStoreOps := 0
				; numHits := 0
				; numMisses := 0
				; store := (
					case !Settings.cacheDatastructure
						of Settings.SIZEBOUNDED b => Bitmatrix.mkMatrix (n, b, true)
						 | _ => Bitmatrix.mkMatrix (n, 1, false)
					)
			end
		
		
		fun rememberUnsat ks =
			let
				val _ = Debug.output (fn () => "Caching pattern " ^ (Util.listToString Int.toString ks) ^ " as unsatisfiable\n")
			in
				  Ref.incr numStoreOps
				; Bitmatrix.insert (!store, ks)
			end
		
		
		fun isCachedUnsat ks = 
			if Bitmatrix.hasSubset (!store, ks)
			then (Ref.incr numHits; true)
			else(Ref.incr numMisses; false)
		
		
		fun approxDependencies (xs : (Term.index * Dependency.depcy) list) =
			if isCachedUnsat (map #1 xs) then SOME (map #2 xs) else NONE
		
		
		fun getStats () = (!numStoreOps, !numHits, !numMisses)
	end
