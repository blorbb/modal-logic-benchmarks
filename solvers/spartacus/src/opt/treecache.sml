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


structure TreeCache :> CACHE =
	struct
		val store = ref (Ubtree.mkTree Int.compare)
		
		
		val numStoreOps = ref 0
		val numHits = ref 0
		val numMisses = ref 0
		
		
		fun initialize _ =
			let
			in
				  numStoreOps := 0
				; numHits := 0
				; numMisses := 0
				; store := (Ubtree.mkTree Int.compare)
			end
		
		
		fun rememberUnsat ks =
			let
				val _ = Debug.output (fn () => "Caching pattern " ^ (Util.listToString Int.toString ks) ^ " as unsatisfiable\n")
			  in
				  Ref.incr numStoreOps
				; store := (Ubtree.insert (!store, ks))
			end
		
		
		fun isCachedUnsat ks =
			if Ubtree.hasSubset (!store, ks)
			then (Ref.incr numHits; true)
			else(Ref.incr numMisses; false)
		
		
		fun approxDependencies (xs : (Term.index * Dependency.depcy) list) =
			let
				fun mf ks (k, d) = if List.exists (fn k' => k = k') ks then SOME d else NONE
			in
				case Ubtree.findSubset (!store, map #1 xs)
					of NONE => (Ref.incr numMisses; NONE)
					 | SOME ks => (Ref.incr numHits; SOME (List.mapPartial (mf ks) xs))
			end
		
		
		fun getStats () = (!numStoreOps, !numHits, !numMisses)
	end
