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


structure Translator :> TRANSLATOR =
	struct
		exception NotFound of string
		
		(*number of the first Term.index that is not used yet*)
		val nextKey = ref 0
		
		
		(*contains the pair (t, k) if k is the Term.index that corresponds to the term t*)
		val dict  = ref (Binarymap.mkDict Term.compare) : (Term.term, Term.index) Binarymap.dict ref
		
		
		(*contains SOME t at position k iff k is the Term.index that corresponds to the term t*)
		val ktm   = DynamicArray.array (100, NONE) : (Term.term option) DynamicArray.array
		
		
		val termsNotCacheable = ref (Binaryset.empty Int.compare) : Term.index Binaryset.set ref
		
		
		val nominals = ref (Binaryset.empty String.compare) : Term.nominal Binaryset.set ref
		
		
		fun getSize () = !nextKey
		
		
		(*returns the Term.index that corresponds to the negation of the term that corresponds to the Term.index k*)
		fun getNegation k =
			if (Int.mod (k, 2)) = 0
			then k + 1
			else k - 1
		
		
		val negate =
			let
				fun negate' f s xs = foldl (fn (x, y) => f y (getNegation x)) s xs
			in
				fn (Term.A (x, b)) => Term.A (x, not b)
				| (Term.CONJ s) =>
					let
						val cs1 = negate' Term.Catstore.addAtom Term.Catstore.empty (Term.Catstore.getAtoms s)
						val cs2 = negate' Term.Catstore.addConjunction cs1 (Term.Catstore.getDisjunctions s)
						val cs3 = negate' Term.Catstore.addDisjunction cs2 (Term.Catstore.getConjunctions s)
						val cs4 = negate' Term.Catstore.addDiamond cs3 (Term.Catstore.getBoxes s)
						val cs5 = negate' Term.Catstore.addBox cs4 (Term.Catstore.getDiamonds s)
						val cs6 = negate' Term.Catstore.addUniversal cs5 (Term.Catstore.getExistentials s)
						val cs7 = negate' Term.Catstore.addExistential cs6 (Term.Catstore.getUniversals s)
						val cs8 = negate' Term.Catstore.addAt cs7 (Term.Catstore.getAts s)
						val cs9 = negate' Term.Catstore.addEq cs8 (Term.Catstore.getNeqs s)
						val cs10 = negate' Term.Catstore.addNeq cs9 (Term.Catstore.getEqs s)
					in
						Term.DISJ cs10
					end
				| (Term.DISJ s) =>
					let
						val cs1 = negate' Term.Catstore.addAtom Term.Catstore.empty (Term.Catstore.getAtoms s)
						val cs2 = negate' Term.Catstore.addConjunction cs1 (Term.Catstore.getDisjunctions s)
						val cs3 = negate' Term.Catstore.addDisjunction cs2 (Term.Catstore.getConjunctions s)
						val cs4 = negate' Term.Catstore.addDiamond cs3 (Term.Catstore.getBoxes s)
						val cs5 = negate' Term.Catstore.addBox cs4 (Term.Catstore.getDiamonds s)
						val cs6 = negate' Term.Catstore.addUniversal cs5 (Term.Catstore.getExistentials s)
						val cs7 = negate' Term.Catstore.addExistential cs6 (Term.Catstore.getUniversals s)
						val cs8 = negate' Term.Catstore.addAt cs7 (Term.Catstore.getAts s)
						val cs9 = negate' Term.Catstore.addEq cs8 (Term.Catstore.getNeqs s)
						val cs10 = negate' Term.Catstore.addNeq cs9 (Term.Catstore.getEqs s)
					in
						Term.CONJ cs10
					end
				| (Term.DMD (r, k)) => Term.BOX (r, getNegation k)
				| (Term.BOX (r, k)) => Term.DMD (r, getNegation k)
				| (Term.EX k) => Term.ALL (getNegation k)
				| (Term.ALL k) => Term.EX (getNegation k)
				| (Term.AT (n, k)) => Term.AT (n, getNegation k)
				| (Term.EQ n) => Term.NEQ n
				| (Term.NEQ n) => Term.EQ n
			end
		
		
		(*returns the Term.index that corresponds to the given term t;
		if it does not exist yet, a new Term.index is created*)
		fun getKey t = (
			case Binarymap.peek (!dict,  t)
				of SOME k => k + 0
				|  NONE => (
					  dict := (Binarymap.insert (!dict, t, !nextKey))
					; DynamicArray.update (ktm, !nextKey, SOME t)
					; if checkNotCacheable t then termsNotCacheable := (Binaryset.add (!termsNotCacheable, !nextKey)) else ()
					; (!nextKey)
					before (
						Ref.incr nextKey;
						ignore (getKey (negate t))
					)
				)
		)
		
		(*returns the term that corresponds to the Term.index k*)
		and getTerm k =
			case DynamicArray.sub (ktm, k)
				of SOME t => t
				|  NONE => raise NotFound "ktm"
		
		and checkNotCacheable (Term.A _) = false
		  | checkNotCacheable (Term.EQ _) = true
		  | checkNotCacheable (Term.NEQ _) = false
		  | checkNotCacheable (Term.CONJ cs) = foldl (fn (k, s) => s orelse Binaryset.member (!termsNotCacheable, k)) false (Term.Catstore.listItems cs)
		  | checkNotCacheable (Term.DISJ cs) = foldl (fn (k, s) => s orelse Binaryset.member (!termsNotCacheable, k)) false (Term.Catstore.listItems cs)
		  | checkNotCacheable (Term.DMD (_, k)) = false
		  | checkNotCacheable (Term.BOX (_, k)) = false
		  | checkNotCacheable (Term.ALL k) = Binaryset.member (!termsNotCacheable, k)
		  | checkNotCacheable (Term.EX k) = false
		  | checkNotCacheable (Term.AT (_, k)) = false
		
		fun translate (Parsetree.PROPVAR p) = getKey (Term.A (p, true))
		  | translate (Parsetree.NEG (Parsetree.PROPVAR p)) = getKey (Term.A (p, false))
		  | translate (Parsetree.NOMINAL n) = (nominals := (Binaryset.add (!nominals, n)); getKey (Term.EQ n))
		  | translate (Parsetree.NEG (Parsetree.NOMINAL n)) = (nominals := (Binaryset.add (!nominals, n)); getKey (Term.NEQ n))
		  | translate (Parsetree.NEG _) = Exn.error "Translator.translate: formula not in NNF"
		  | translate (Parsetree.CONJ [t]) = translate t
		  | translate (Parsetree.CONJ ts) =
			let
			in
				case Term.Catstore.cleanConj (subterms ts)
					of NONE => 0
					 | SOME cs =>
						if Term.Catstore.size cs = 1
						then (case Term.Catstore.listItems cs of [k] => k | _ => Exn.unexpected "Translator.translate: CONJ")
						else getKey (Term.CONJ cs)
			end
		  | translate (Parsetree.DISJ [t]) = translate t
		  | translate (Parsetree.DISJ ts) =
			let
			in
				case Term.Catstore.cleanDisj (subterms ts)
					of NONE => 1
					 | SOME cs =>
						if Term.Catstore.size cs = 1
						then (case Term.Catstore.listItems cs of [k] => k | _ => Exn.unexpected "Translator.translate: DISJ")
						else getKey (Term.DISJ cs)
			end
		  | translate (Parsetree.DIAMOND (r, t)) =
			let
				val k = translate t
			in
				  RelationMgr.addRelation r
				; if k = 0
				  then 0
				  else getKey (Term.DMD (r, k))
			end
		  | translate (Parsetree.BOX (r, t)) =
			let
				val k = translate t
			in
				  RelationMgr.addRelation r
				; if k = 1
				  then 1
				  else getKey (Term.BOX (r, k))
			end
		  | translate (Parsetree.ALL t) =
			let
				val k = translate t
			in
				if k = 0
				then 0
				else
					if k = 1
					then 1
					else getKey (Term.ALL k)
			end
		  | translate (Parsetree.EXISTS t) =
			let
				val k = translate t
			in
				if k = 0
				then 0
				else
					if k = 1
					then 1
					else getKey (Term.EX k)
			end
		  | translate (Parsetree.AT (n, t)) =
			let
				(*=n must have a key, since a node containing =n will be created during initialization*)
				val _ = translate (Parsetree.NOMINAL n)
				
				val k = translate t
			in
				  nominals := (Binaryset.add (!nominals, n))
				; if k = 0
				  then 0
				  else
					if k = 1
					then 1
					else getKey (Term.AT (n, k))
			end
		  | translate _ = Exn.error "Translator.translate: not implemented"
		and subterms xs =
			let
				fun sort (t, cs) =
					let
						val k = translate t
						
						val add =
							case getTerm k
								of Term.A _ => Term.Catstore.addAtom
								 | Term.EQ _ => Term.Catstore.addEq
								 | Term.NEQ _ => Term.Catstore.addNeq
								 | Term.CONJ _ => Term.Catstore.addConjunction
								 | Term.DISJ _ => Term.Catstore.addDisjunction
								 | Term.DMD _ => Term.Catstore.addDiamond
								 | Term.BOX _ => Term.Catstore.addBox
								 | Term.ALL _ => Term.Catstore.addUniversal
								 | Term.EX _ => Term.Catstore.addExistential
								 | Term.AT _ => Term.Catstore.addAt
					in
						add cs k
					end
			in
				foldl sort Term.Catstore.empty xs
			end
		
		
		fun isNotCacheable k = Binaryset.member (!termsNotCacheable, k)
		
		
		fun listNominals () = Binaryset.listItems (!nominals)
		
		
		fun reset () =
			let
				fun clearKtm n =
					if n < 0
					then ()
					else (
						DynamicArray.update (ktm, n, NONE);
						clearKtm (n - 1)
					)
			in
				  clearKtm (!nextKey - 1)
				; termsNotCacheable := Binaryset.empty Int.compare
				; nominals := Binaryset.empty String.compare
				; nextKey := 0
				; dict := (Binarymap.mkDict Term.compare)
				; ignore (translate (Parsetree.DISJ nil))
			end
		
		
		fun termToString (Term.A (p, b)) = (if b then "" else "~") ^ "p" ^ p
		  | termToString (Term.CONJ cs) =
				  "("
				^ ( String.translate
					(fn #"," => " &" | c => String.str c)
					(Util.listToString (termToString o getTerm) (Term.Catstore.listItems cs))
				  )
				^ ")"
		  | termToString (Term.DISJ cs) =
				  "("
				^ ( String.translate
					(fn #"," => " |" | c => String.str c)
					(Util.listToString (termToString o getTerm) (Term.Catstore.listItems cs))
				  )
				^ ")"
		  | termToString (Term.DMD (r, k')) = "<r" ^ r ^ ">" ^ (termToString (getTerm k'))
		  | termToString (Term.BOX (r, k')) = "[r" ^ r ^ "]" ^ (termToString (getTerm k'))
		  | termToString (Term.EX k') = "E " ^ (termToString (getTerm k'))
		  | termToString (Term.ALL k') = "A " ^ (termToString (getTerm k'))
		  | termToString (Term.AT (n, k')) = "@x" ^ n ^ " " ^ (termToString (getTerm k'))
		  | termToString (Term.EQ n) = "(=x" ^ n ^ ")"
		  | termToString (Term.NEQ n) = "(~=x" ^ n ^ ")"
		
		
		fun toString () =
			let
				fun long' (Term.A (p, b)) = (if b then "" else "~") ^ p
				  | long' (Term.CONJ cs) = 
							"/\\("
							^ (Util.listToString (long' o getTerm) (Term.Catstore.listItems cs))
							^ ")"
				  | long' (Term.DISJ cs) =
							"\\/("
							^ (Util.listToString (long' o getTerm) (Term.Catstore.listItems cs))
							^ ")"
				  | long' (Term.DMD (r, k')) = "<" ^ r ^ ">" ^ (long' (getTerm k'))
				  | long' (Term.BOX (r, k')) = "[" ^ r ^ "]" ^ (long' (getTerm k'))
				  | long' (Term.EX k') = "E " ^ (long' (getTerm k'))
				  | long' (Term.ALL k') = "A " ^ (long' (getTerm k'))
				  | long' (Term.AT (n, k')) = "@" ^ n ^ " " ^ (long' (getTerm k'))
				  | long' (Term.EQ n) = "(=" ^ n ^ ")"
				  | long' (Term.NEQ n) = "(~=" ^ n ^ ")"
				
				fun long k =
						  (Int.toString k)
						^ ": "
						^ (if k < 10 then " " else "")
						^ (if k < 100 then " " else "")
						^ (if k < 1000 then " " else "")
						^ (if isNotCacheable k then "* " else "  ")
						^ (long' (getTerm k))
						^ "\n"
				
				fun short k = 
						  (Int.toString k)
						^ ": "
						^ (if k < 10 then " " else "")
						^ (if k < 100 then " " else "")
						^ (if k < 1000 then " " else "")
						^ (if isNotCacheable k then "* " else "  ")
						^ (Term.toString (getTerm k))
						^ "\n"
			in
				  "\n--INDEX->TERM MAPPING (COMPACT)-----------------------------\n"
				^ (concat (List.tabulate (!nextKey, short)))
				^ "\n--INDEX->TERM MAPPING---------------------------------------\n"
				^ (concat (List.tabulate (!nextKey, long)))
				^ "------------------------------------------------------------\n\n"
			end
	end
