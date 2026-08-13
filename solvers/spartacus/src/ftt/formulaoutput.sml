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


structure FormulaOutput =
	struct
	fun splitTopLevelUniv (Parsetree.ALL t) = (
				case t
					of Parsetree.CONJ ts => (ts, Parsetree.CONJ nil)
					 | t => ([t], Parsetree.CONJ nil)
				)
	  | splitTopLevelUniv (Parsetree.CONJ ts) =
				let
					val (univ', rem) =
						List.partition
							(fn t => (case t of Parsetree.ALL _ => true | _ => false))
							ts
					
					fun mf (Parsetree.ALL t) = t
					  | mf _ = Exn.unexpected "FormulaOutput.fact: universal modality expected."
				in
					(map mf univ', Parsetree.mconj rem)
				end
	 | splitTopLevelUniv t = (nil, t)
		
		
		fun spartacus pt =
			let
				val (npt, nom, rel, refl, trans, ser, sym, sub) = Parsetree.toNumberedTree pt
				
				fun spartacus' (Parsetree.CONJ nil) = "1"
				  | spartacus' (Parsetree.DISJ nil) = "0"
				  | spartacus' (Parsetree.CONJ xs) = "(" ^ (String.extract (concat (map (fn x => " & " ^ (spartacus' x)) xs), 3, NONE)) ^ ")"
				  | spartacus' (Parsetree.DISJ xs) = "(" ^ (String.extract (concat (map (fn x => " | " ^ (spartacus' x)) xs), 3, NONE)) ^ ")"
				  | spartacus' (Parsetree.BOX (r, x)) = "[r" ^ r ^ "]" ^ (spartacus' x)
				  | spartacus' (Parsetree.DIAMOND (r, x)) = "<r" ^ r ^ ">" ^ (spartacus' x)
				  | spartacus' (Parsetree.AT (n, x)) = "@n" ^ n ^ " " ^ (spartacus' x)
				  | spartacus' (Parsetree.PROPVAR x) = "p" ^ x
				  | spartacus' (Parsetree.NOMINAL x) = "=n" ^ x
				  | spartacus' (Parsetree.XOR (t1, t2)) = "(" ^ (spartacus' (Parsetree.neg t1)) ^ " <-> " ^ (spartacus' t2) ^ ")"
				  | spartacus' (Parsetree.NEG (Parsetree.XOR (t1, t2))) = "(" ^ (spartacus' t1) ^ " <-> " ^ (spartacus' t2) ^ ")"
				  | spartacus' (Parsetree.NEG t) = "~ " ^ (spartacus' t)
				  | spartacus' (Parsetree.ALL t) = "A " ^ (spartacus' t)
				  | spartacus' (Parsetree.EXISTS t) = "E " ^ (spartacus' t)
				  | spartacus' (Parsetree.DIFF t) = "D " ^ (spartacus' t)
				  | spartacus' (Parsetree.NEGDIFF t) = "(~D) " ^ (spartacus' t)
			in
				  (concat (map (fn r => "{reflexive: r" ^ r ^ "}") refl))
				^ (concat (map (fn r => "{transitive: r" ^ r ^ "}") trans))
				^ (concat (map (fn r => "{serial: r" ^ r ^ "}") ser))
				^ (spartacus' npt)
				^ "\n"
			end
		
		
		fun ksatc pt =
			let
				fun ksatc' _ (Parsetree.CONJ nil) = "T"
				  | ksatc' _ (Parsetree.DISJ nil) = "F"
				  | ksatc' _ (Parsetree.NEG (Parsetree.CONJ nil)) = "F"
				  | ksatc' _ (Parsetree.NEG (Parsetree.DISJ nil)) = "T"
				  | ksatc' b (Parsetree.CONJ xs) = "^( " ^ (concat (map (fn x => (ksatc' b x) ^ " ") xs)) ^ ")"
				  | ksatc' b (Parsetree.DISJ xs) = "v( " ^ (concat (map (fn x => (ksatc' b x) ^ " ") xs)) ^ ")"
				  | ksatc' b (Parsetree.NEG (Parsetree.CONJ xs)) = "- " ^ (ksatc' (not b) (Parsetree.CONJ xs))
				  | ksatc' b (Parsetree.NEG (Parsetree.DISJ xs)) = "- " ^ (ksatc' (not b) (Parsetree.DISJ xs))
				  | ksatc' b (Parsetree.NEG (Parsetree.NEG pt)) = ksatc' b pt
				  | ksatc' b (Parsetree.BOX (r, x)) = "# (" ^ r ^ ") (" ^ (ksatc' b x) ^ ")"
				  | ksatc' b (Parsetree.NEG (Parsetree.BOX x)) = "- " ^ (ksatc' (not b) (Parsetree.BOX x))
				  | ksatc' b (Parsetree.DIAMOND (r, x)) = ksatc' b (Parsetree.NEG (Parsetree.BOX (r, Parsetree.NEG x)))
				  | ksatc' b (Parsetree.NEG (Parsetree.DIAMOND (r, x))) = ksatc' b (Parsetree.BOX (r, Parsetree.NEG x))
				  | ksatc' _ (Parsetree.PROPVAR x) = x
				  | ksatc' _ (Parsetree.NEG (Parsetree.PROPVAR x)) = "-" ^ x
				  | ksatc' b (Parsetree.XOR (t1, t2)) =
						if b
						then ksatc' b (Parsetree.translateXor (t1, t2))
						else ksatc' b (Parsetree.NEG (Parsetree.translateXor (Parsetree.NEG t1, t2)))
				  | ksatc' b (Parsetree.NEG (Parsetree.XOR (t1, t2))) = 
						if b
						then ksatc' b (Parsetree.translateXor (Parsetree.NEG t1, t2))
						else ksatc' b (Parsetree.NEG (Parsetree.translateXor (t1, t2)))
				  | ksatc' _ (Parsetree.ALL _) = Exn.error "can not represent ALL in KSatC format"
				  | ksatc' _ (Parsetree.EXISTS _) = Exn.error "can not represent EXISTS in KSatC format"
				  | ksatc' _ (Parsetree.DIFF _) = Exn.error "can not represent DIFF in KSatC format"
				  | ksatc' _ (Parsetree.NEGDIFF _) = Exn.error "can not represent NEGDIFF in KSatC format"
				  | ksatc' _ (Parsetree.AT _) = Exn.error "can not represent AT in KSatC format"
				  | ksatc' _ (Parsetree.NOMINAL _) = Exn.error "can not represent NOMINAL in KSatC format"
				  | ksatc' _ (Parsetree.NEG _) = Exn.error "can not represent NEG ? in KSatC format"
			in
				ksatc' true (#1 (Parsetree.toNumberedTree pt))
			end
		
		fun fact pt {c = c, satopcompact = satopcompact} =
			let
				val (npt, nom, rel, refl, trans, ser, sym, sub) = Parsetree.toNumberedTree pt
				
				val (univ, rem) = splitTopLevelUniv npt
				
				val containsGlobalMod =
					Parsetree.containsGlobalMod rem
					orelse List.exists (fn t => Parsetree.containsGlobalMod t) univ
				
				val containsSatOp =
					Parsetree.containsSatOp rem
					orelse List.exists (fn t => Parsetree.containsSatOp t) univ
				
				fun fact' _ (Parsetree.CONJ nil) = "*TOP*"
				  | fact' _ (Parsetree.DISJ nil) = "*BOTTOM*"
				  | fact' _ (Parsetree.NEG (Parsetree.CONJ nil)) = "BOTTOM"
				  | fact' _ (Parsetree.NEG (Parsetree.DISJ nil)) = "TOP"
				  | fact' b (Parsetree.CONJ xs) = "(and " ^ (concat (map (fn x => (fact' b x) ^ " ") xs)) ^ ")"
				  | fact' b (Parsetree.DISJ xs) = "(or " ^ (concat (map (fn x => (fact' b x) ^ " ") xs)) ^ ")"
				  | fact' b (Parsetree.NEG (Parsetree.CONJ xs)) = "(not " ^ (fact' (not b) (Parsetree.CONJ xs)) ^ ")"
				  | fact' b (Parsetree.NEG (Parsetree.DISJ xs)) = "(not " ^ (fact' (not b) (Parsetree.DISJ xs)) ^ ")"
				  | fact' b (Parsetree.NEG (Parsetree.NEG pt)) = fact' b pt
				  | fact' b (Parsetree.BOX (r, x)) = "(all R" ^ r ^ " " ^ (fact' b x) ^ ")"
				  | fact' b (Parsetree.NEG (Parsetree.BOX x)) = "(not " ^ (fact' (not b) (Parsetree.BOX x)) ^ ")"
				  | fact' b (Parsetree.DIAMOND (r, x)) = "(some R" ^ r ^ " " ^ (fact' b x) ^ ")"
				  | fact' b (Parsetree.NEG (Parsetree.DIAMOND x)) = "(not " ^ (fact' (not b) (Parsetree.DIAMOND x)) ^ ")"
				  | fact' _ (Parsetree.PROPVAR x) = "C" ^ x
				  | fact' _ (Parsetree.NEG (Parsetree.PROPVAR x)) = "(not C" ^ x ^ ")"
				  | fact' _ (Parsetree.NOMINAL n) = "(one-of N" ^ n ^ ")"
				  | fact' _ (Parsetree.NEG (Parsetree.NOMINAL n)) = "(not (one-of N" ^ n ^ "))"
				  | fact' b (Parsetree.ALL x) = "(all U " ^ (fact' b x) ^ ")"
				  | fact' b (Parsetree.NEG (Parsetree.ALL x)) = "(not " ^ (fact' (not b) (Parsetree.ALL x)) ^ ")"
				  | fact' b (Parsetree.EXISTS x) = "(some U " ^ (fact' b x) ^ ")"
				  | fact' b (Parsetree.NEG (Parsetree.EXISTS x)) = "(not " ^ (fact' (not b) (Parsetree.EXISTS x)) ^ ")"
				  | fact' b (Parsetree.AT (n, x)) = "(some U (and (one-of N" ^ n ^ ") " ^ (fact' b x) ^ "))"
				  | fact' b (Parsetree.NEG (Parsetree.AT (n, x))) = "(not " ^ (fact' (not b) (Parsetree.AT (n, x))) ^ ")"
				  | fact' b (Parsetree.XOR (t1, t2)) =
						if b
						then fact' b (Parsetree.translateXor (t1, t2))
						else fact' b (Parsetree.NEG (Parsetree.translateXor (Parsetree.NEG t1, t2)))
				  | fact' b (Parsetree.NEG (Parsetree.XOR (t1, t2))) =
						if b
						then fact' b (Parsetree.translateXor (Parsetree.NEG t1, t2))
						else fact' b (Parsetree.NEG (Parsetree.translateXor (t1, t2)))
				  | fact' _ (Parsetree.DIFF _) = Exn.error "can not represent DIFF in FaCT format"
				  | fact' _ (Parsetree.NEGDIFF _) = Exn.error "can not represent NEGDIFF in FaCT format"
				  | fact' _ (Parsetree.NEG _) = Exn.error "can not represent NEG ? in FaCT format"
				
				fun topLevelUnivToString (Parsetree.XOR (t1, t2)) =
						  "(equal_c "
						^ (fact' true (Parsetree.neg t1))
						^ " " ^ (fact' true t2)
						^ ")\n"
				  | topLevelUnivToString (Parsetree.NEG (Parsetree.XOR (t1, t2))) =
						  "(equal_c "
						^ (fact' true t1)
						^ " "
						^ (fact' true t2)
						^ ")\n"
				  | topLevelUnivToString (Parsetree.DISJ [t1, t2]) =
						  "(implies_c "
						^ (fact' true (Parsetree.neg t1))
						^ " "
						^ (fact' true t2)
						^ ")\n"
				  | topLevelUnivToString (Parsetree.DISJ (t::tr)) =
						  "(implies_c "
						^ (fact' true (Parsetree.neg t))
						^ " "
						^ (fact' true (Parsetree.DISJ tr))
						^ ")\n"
				  | topLevelUnivToString t =
						"(equal_c *TOP* " ^ (fact' true t) ^ ")\n"
			in
				  (
					if containsGlobalMod orelse containsSatOp
					then (
							if containsGlobalMod orelse not satopcompact
							then
								  ("(reflexive U)\n(transitive U)\n(symmetric U)\n")
								^ (concat (map (fn r => "(implies_r R" ^ r ^ " U)\n") rel))
							else ""
						  ) 
						^ (concat (map (fn n => "(implies_c *TOP* (some U (one-of N" ^ n ^ ")))\n") nom))
					else ""
				  )
				^ (concat (map (fn r => "(reflexive R" ^ r ^ ")\n") refl))
				^ (concat (map (fn r => "(transitive R" ^ r ^ ")\n") trans))
				^ (concat (map (fn r => "(symmetric R" ^ r ^ ")\n") sym))
				^ (concat (map (fn (r1, r2) => "(implies_r R" ^ r1 ^ " R" ^ r2 ^ ")\n") sub))
				^ (concat (map topLevelUnivToString univ))
				^ (
					if c = "*TOP*" andalso rem = Parsetree.CONJ nil
					then ""
					else "(equal_c " ^ c ^ " " ^ (fact' true rem) ^ ")"
				  )
			end
		
		fun krss pt {c = c} =
			let
				fun krss' _ (Parsetree.CONJ nil) = "TOP"
				  | krss' _ (Parsetree.DISJ nil) = "BOTTOM"
				  | krss' _ (Parsetree.NEG (Parsetree.CONJ nil)) = "BOTTOM"
				  | krss' _ (Parsetree.NEG (Parsetree.DISJ nil)) = "TOP"
				  | krss' b (Parsetree.CONJ xs) = "(and " ^ (concat (map (fn x => (krss' b x) ^ " ") xs)) ^ ")"
				  | krss' b (Parsetree.DISJ xs) = "(or " ^ (concat (map (fn x => (krss' b x) ^ " ") xs)) ^ ")"
				  | krss' b (Parsetree.NEG (Parsetree.CONJ xs)) = "(not " ^ (krss' (not b) (Parsetree.CONJ xs)) ^ ")"
				  | krss' b (Parsetree.NEG (Parsetree.DISJ xs)) = "(not " ^ (krss' (not b) (Parsetree.DISJ xs)) ^ ")"
				  | krss' b (Parsetree.NEG (Parsetree.NEG pt)) = krss' b pt
				  | krss' b (Parsetree.BOX (r, x)) = "(all R" ^ r ^ " " ^ (krss' b x) ^ ")"
				  | krss' b (Parsetree.NEG (Parsetree.BOX x)) = "(not " ^ (krss' (not b) (Parsetree.BOX x)) ^ ")"
				  | krss' b (Parsetree.DIAMOND (r, x)) = "(some R" ^ r ^ " " ^ (krss' b x) ^ ")"
				  | krss' b (Parsetree.NEG (Parsetree.DIAMOND x)) = "(not " ^ (krss' (not b) (Parsetree.DIAMOND x)) ^ ")"
				  | krss' _ (Parsetree.PROPVAR x) = "C" ^ x
				  | krss' _ (Parsetree.NEG (Parsetree.PROPVAR x)) = "(not C" ^ x ^ ")"
				  | krss' _ (Parsetree.NOMINAL n) = "(one-of N" ^ n ^ ")"
				  | krss' _ (Parsetree.NEG (Parsetree.NOMINAL n)) = "(not (one-of N" ^ n ^ "))"
				  | krss' b (Parsetree.ALL x) = "(all *UROLE* " ^ (krss' b x) ^ ")"
				  | krss' b (Parsetree.NEG (Parsetree.ALL x)) = "(not (all *UROLE* " ^ (krss' (not b) x) ^ "))"
				  | krss' b (Parsetree.EXISTS x) = "(some *UROLE* " ^ (krss' b x) ^ ")"
				  | krss' b (Parsetree.NEG (Parsetree.EXISTS x)) = "(not (some *UROLE* " ^ (krss' (not b) x) ^ "))"
				  | krss' b (Parsetree.AT (n, x)) = "(some *UROLE* (and (one-of N" ^ n ^ ") " ^ (krss' b x) ^ "))"
				  | krss' b (Parsetree.NEG (Parsetree.AT (n, x))) = "(some *UROLE* (and (one-of N" ^ n ^ ") " ^ "(not " ^ (krss' (not b) x) ^ ")))"
				  | krss' b (Parsetree.XOR (t1, t2)) =
						if b
						then krss' b (Parsetree.translateXor (t1, t2))
						else krss' b (Parsetree.NEG (Parsetree.translateXor (Parsetree.NEG t1, t2)))
				  | krss' b (Parsetree.NEG (Parsetree.XOR (t1, t2))) = 
						if b
						then krss' b (Parsetree.translateXor (Parsetree.NEG t1, t2))
						else krss' b (Parsetree.NEG (Parsetree.translateXor (t1, t2)))
				  | krss' _ (Parsetree.DIFF _) = Exn.error "can not represent DIFF in KRSS format"
				  | krss' _ (Parsetree.NEGDIFF _) = Exn.error "can not represent NEGDIFF in KRSS format"
				  | krss' _ (Parsetree.NEG _) = Exn.error "can not represent NEG ? in KRSS format"
			in
				"(define-concept " ^ c ^ " " ^ (krss' true (#1 (Parsetree.toNumberedTree pt))) ^ ")"
			end
		
		fun intohylo pt =
			let
				fun intohylo' (Parsetree.CONJ nil) = "true"
				  | intohylo' (Parsetree.DISJ nil) = "false"
				  | intohylo' (Parsetree.CONJ xs) = "(" ^ (String.extract (concat (map (fn x => " & " ^ (intohylo' x)) xs), 3, NONE)) ^ ")"
				  | intohylo' (Parsetree.DISJ xs) = "(" ^ (String.extract (concat (map (fn x => " | " ^ (intohylo' x)) xs), 3, NONE)) ^ ")"
				  | intohylo' (Parsetree.BOX (r, x)) = "[r" ^ r ^ "]" ^ (intohylo' x)
				  | intohylo' (Parsetree.DIAMOND (r, x)) = "<r" ^ r ^ ">" ^ (intohylo' x)
				  | intohylo' (Parsetree.AT (n, x)) = "@n" ^ n ^ " " ^ (intohylo' x)
				  | intohylo' (Parsetree.PROPVAR x) = "p" ^ x
				  | intohylo' (Parsetree.NOMINAL x) = "n" ^ x
				  | intohylo' (Parsetree.XOR (t1, t2)) = "(" ^ (intohylo' (Parsetree.neg t1)) ^ " <-> " ^ (intohylo' t2) ^ ")"
				  | intohylo' (Parsetree.NEG (Parsetree.XOR (t1, t2))) = "(" ^ (intohylo' t1) ^ " <-> " ^ (intohylo' t2) ^ ")"
				  | intohylo' (Parsetree.NEG t) = "~ " ^ (intohylo' t)
				  | intohylo' (Parsetree.ALL t) = "A " ^ (intohylo' t)
				  | intohylo' (Parsetree.EXISTS t) = "E " ^ (intohylo' t)
				  | intohylo' (Parsetree.DIFF t) = "D " ^ (intohylo' t)
				  | intohylo' (Parsetree.NEGDIFF t) = "B " ^ (intohylo' t)
			in
				"begin\n" ^ (intohylo' (#1 (Parsetree.toNumberedTree pt))) ^ "\nend\n"
			end
		
		fun alc pt =
			let
				fun alc' (Parsetree.CONJ nil) = "TOP"
				  | alc' (Parsetree.DISJ nil) = "BOTTOM"
				  | alc' (Parsetree.CONJ ts) = "(AND " ^ (concat (map (fn t => (alc' t) ^ " ") ts)) ^ ")"
				  | alc' (Parsetree.DISJ ts) = "(OR " ^ (concat (map (fn t => (alc' t) ^ " ") ts)) ^ ")"
				  | alc' (Parsetree.BOX (r, t)) = "(ALL R" ^ r ^ " " ^ (alc' t) ^ ")"
				  | alc' (Parsetree.DIAMOND (r, t)) = "(SOME R" ^ r ^ " " ^ (alc' t) ^ ")"
				  | alc' (Parsetree.PROPVAR p) = "C" ^ p
				  | alc' (Parsetree.XOR (t1, t2)) = "(IFF " ^ (alc' (Parsetree.neg t1)) ^ " " ^ (alc' t2) ^ ")"
				  | alc' (Parsetree.NEG (Parsetree.XOR (t1, t2))) = "(IFF " ^ (alc' t1) ^ " " ^ (alc' t2) ^ ")"
				  | alc' (Parsetree.NEG t) = "(NOT " ^ alc' t ^ ")"
				  | alc' (Parsetree.ALL _) = Exn.error "can not represent ALL in alc format"
				  | alc' (Parsetree.EXISTS _) = Exn.error "can not represent EXISTS in alc format"
				  | alc' (Parsetree.DIFF _) = Exn.error "can not represent DIFF in alc format"
				  | alc' (Parsetree.NEGDIFF _) = Exn.error "can not represent NEGDIFF in alc format"
				  | alc' (Parsetree.NOMINAL _) = Exn.error "can not represent NOMINAL in alc format"
				  | alc' (Parsetree.AT _) = Exn.error "can not represent AT in alc format"
			in
				alc' (#1 (Parsetree.toNumberedTree pt))
			end
		
		fun cwb pt =
			let
				fun cc oper nil = Exn.unexpArg "Formulaoutput.cwb.cc"
				  | cc oper [t] = t
				  | cc oper (t::tr) = t ^ oper ^ (cc oper tr)
				
				fun cwb' _ (Parsetree.PROPVAR p) = "p" ^ p
				  | cwb' _ (Parsetree.NEG (Parsetree.PROPVAR p)) = "(~p" ^ p ^ ")"
				  | cwb' b (Parsetree.XOR (t1, t2)) =
						if b
						then cwb' b (Parsetree.translateXor (t1, t2))
						else cwb' b (Parsetree.NEG (Parsetree.translateXor (Parsetree.NEG t1, t2)))
				  | cwb' b (Parsetree.NEG (Parsetree.XOR (t1, t2))) = 
						if b
						then cwb' b (Parsetree.translateXor (Parsetree.NEG t1, t2))
						else cwb' b (Parsetree.NEG (Parsetree.translateXor (t1, t2)))
				  | cwb' b (Parsetree.NEG t) = "~" ^ cwb' (not b) t
				  | cwb' _ (Parsetree.CONJ nil) = "TOP"
				  | cwb' _ (Parsetree.DISJ nil) = "BOTTOM"
				  | cwb' b (Parsetree.CONJ [t]) = cwb' b t
				  | cwb' b (Parsetree.DISJ [t]) = cwb' b t
				  | cwb' b (Parsetree.CONJ ts) = "(" ^ (cc " & " (map (cwb' b) ts)) ^ ")"
				  | cwb' b (Parsetree.DISJ ts) = "(" ^ (cc " | " (map (cwb' b) ts)) ^ ")"
				  | cwb' b (Parsetree.BOX (r, t)) = "(!r" ^ r ^ "." ^ (cwb' b t) ^ ")"
				  | cwb' b (Parsetree.DIAMOND (r, t)) = "(?r" ^ r ^ "." ^ (cwb' b t) ^ ")"
				  | cwb' _ (Parsetree.ALL _) = Exn.error "can not represent ALL in cwb format"
				  | cwb' _ (Parsetree.EXISTS _) = Exn.error "can not represent EXISTS in cwb format"
				  | cwb' _ (Parsetree.DIFF _) = Exn.error "can not represent DIFF in cwb format"
				  | cwb' _ (Parsetree.NEGDIFF _) = Exn.error "can not represent NEGDIFF in cwb format"
				  | cwb' _ (Parsetree.NOMINAL _) = Exn.error "can not represent NOMINAL in cwb format"
				  | cwb' _ (Parsetree.AT _) = Exn.error "can not represent AT in cwb format"
			in
				"|- " ^ (cwb' true pt) ^ "\n"
			end
		
		fun dimacscnf pt =
			let
				fun cnf' (Parsetree.PROPVAR p) = (p ^ " ", Option.valOf (Int.fromString p))
				  | cnf' (Parsetree.NEG (Parsetree.PROPVAR p)) = ("-" ^ p ^ " ", Option.valOf (Int.fromString p))
				  | cnf' (Parsetree.DISJ ts) =
					let
						val xs = map cnf' ts
					in
						((concat (map #1 xs)) ^ "0\n", foldl Int.max 0 (map #2 xs))
					end
				  | cnf' (Parsetree.CONJ ts) =
					let
						val xs = map cnf' ts
						
						val maxvar = foldl Int.max 0 (map #2 xs)
					in
						  (("p cnf " ^ (Int.toString maxvar) ^ " " ^ (Int.toString (length xs)) ^ "\n") ^ (concat (map #1 xs)), maxvar)
					end
				  | cnf' _ = Exn.unexpArg "Formulaoutput.dimacscnf.cnf'"
			in
				#1 (cnf' (Parsetree.toCnf (#1 (Parsetree.toNumberedTree pt))))
			end
		
		fun dfg pt =
			let
				fun dfg' _ (Parsetree.PROPVAR p) = (p, [p])
				  | dfg' b (Parsetree.XOR (t1, t2)) =
						if b
						then dfg' b (Parsetree.translateXor (t1, t2))
						else dfg' b (Parsetree.NEG (Parsetree.translateXor (Parsetree.NEG t1, t2)))
				  | dfg' b (Parsetree.NEG (Parsetree.XOR (t1, t2))) = 
						if b
						then dfg' b (Parsetree.translateXor (Parsetree.NEG t1, t2))
						else dfg' b (Parsetree.NEG (Parsetree.translateXor (t1, t2)))
				  | dfg' b (Parsetree.NEG t) = (fn (s, vs) => ("not(" ^ s ^ ")", vs)) (dfg' (not b) t)
				  | dfg' _ (Parsetree.CONJ nil) = ("true", nil)
				  | dfg' b (Parsetree.CONJ [t]) = dfg' b t
				  | dfg' b (Parsetree.CONJ (t::tr)) = (fn ((s1, vs1), (s2, vs2)) => ("and(" ^ s1 ^ "," ^ s2 ^ ")", vs1@vs2)) (dfg' b t, dfg' b (Parsetree.CONJ tr))
				  | dfg' _ (Parsetree.DISJ nil) = ("false", nil)
				  | dfg' b (Parsetree.DISJ [t]) = dfg' b t
				  | dfg' b (Parsetree.DISJ (t::tr)) = (fn ((s1, vs1), (s2, vs2)) => ("or(" ^ s1 ^ ", " ^ s2 ^ ")", vs1@vs2)) (dfg' b t, dfg' b (Parsetree.DISJ tr))
				  | dfg' b (Parsetree.BOX (r, t)) = (fn (s, vs) => ("box(" ^ r ^ ", " ^ s ^ ")", r::vs)) (dfg' b t)
				  | dfg' b (Parsetree.DIAMOND (r, t)) = (fn (s, vs) => ("dia(" ^ r ^ ", " ^ s ^ ")", r::vs)) (dfg' b t)
				  | dfg' _ (Parsetree.ALL _) = Exn.error "can not represent universal modality in dfg format"
				  | dfg' _ (Parsetree.EXISTS _) = Exn.error "can not represent existential modality in dfg format"
				  | dfg' _ (Parsetree.DIFF _) = Exn.error "can not represent difference modality in dfg format"
				  | dfg' _ (Parsetree.NEGDIFF _) = Exn.error "can not represent dual of difference modality in dfg format"
				  | dfg' _ (Parsetree.AT _) = Exn.error "can not represent satisfaction operator in dfg format"
				  | dfg' _ (Parsetree.NOMINAL _) = Exn.error "can not represent nominal in dfg format"
				
				fun dfg'' (Parsetree.DISJ (ts as (_::_))) =
						foldl
							(fn (t , (s, vs)) => (fn (s', vs') => ("prop_formula(" ^ s' ^ ").\n" ^ s, vs'@vs)) (dfg' true t))
							("", nil)
							ts
				  | dfg'' t = (fn (s', vs') => ("prop_formula(" ^ s' ^ ").\n", vs')) (dfg' true t)
				
				val (s, vs) = dfg'' pt
			in
				  "begin_problem(ftt_translated).\n"
				^ "list_of_descriptions.\n"
				^ "  name({* Unknown *}).\n"
				^ "  author({* Unknown *}).\n"
				^ "  status(unknown).\n"
				^ "  description({* Not available. File generated by fft *}).\n"
				^ "end_of_list.\n"
				^ "\n\n"
				^ "list_of_symbols.\n"
				^ "predicates[  "
				^ (Util.listToString (fn x => "(" ^ x ^ ",0)") (Util.cleanSort String.compare vs))
				^ "  ].\n"
				^ "end_of_list.\n"
				^ "\n\n"
				^ "list_of_special_formulae(conjectures, EML).\n"
				^ s
				^ "end_of_list.\n"
				^ "\n"
				^ "list_of_settings(SPASS).\n"
				^ "{*\n"
				^ "set_flag(Auto,1).\n"
				^ "set_flag(EMLTranslation,2).\n"
				^ "set_flag(EMLFuncNary,1).\n"
				^ "set_flag(DocProof,0).\n"
				^ "set_flag(PProblem,0).\n"
				^ "set_flag(PKept,0).\n"
				^ "set_flag(PGiven,0).\n"
				^ "set_flag(Sorts,0).\n"
				^ "set_flag(Ordering,0).\n"
				^ "set_flag(Select,2).\n"
				^ "set_flag(FullRed,1).\n"
				^ "set_flag(CNFOptSkolem,0).\n"
				^ "set_flag(CNFStrSkolem,0).\n"
				^ "set_flag(RCon,0).\n"
				^ "set_flag(RSST,0).\n"
				^ "set_flag(RInput,0).\n"
				^ "set_flag(SatInput,0).\n"
				^ "set_flag(WDRatio,5).\n"
				^ "*}\n"
				^ "end_of_list.\n"
				^ "\n"
				^ "end_problem."
			end
			
			
		fun owlfs pt {c = c, satopcompact = satopcompact} =
			let
				val (npt, nom, rel, refl, trans, ser, sym, sub) = Parsetree.toNumberedTree pt
				
				val (univ, rem) = splitTopLevelUniv npt
				
				val containsGlobalMod =
					Parsetree.containsGlobalMod rem
					orelse List.exists (fn t => Parsetree.containsGlobalMod t) univ
				
				val containsSatOp =
					Parsetree.containsSatOp rem
					orelse List.exists (fn t => Parsetree.containsSatOp t) univ
				
				fun owlfs' _ (Parsetree.CONJ nil) = "owl:Thing"
				  | owlfs' _ (Parsetree.DISJ nil) = "owl:Nothing"
				  | owlfs' b (Parsetree.CONJ xs) = "ObjectIntersectionOf (" ^ (concat (map (fn x => " " ^ (owlfs' b x)) xs)) ^ ")"
				  | owlfs' b (Parsetree.DISJ xs) = "ObjectUnionOf (" ^ (concat (map (fn x => " " ^ (owlfs' b x)) xs)) ^ ")"
				  | owlfs' b (Parsetree.BOX (r, x)) = "ObjectAllValuesFrom (r" ^ r ^ " " ^ (owlfs' b x) ^ ")"
				  | owlfs' b (Parsetree.DIAMOND (r, x)) = "ObjectSomeValuesFrom (r" ^ r ^ " " ^ (owlfs' b x) ^ ")"
				  | owlfs' b (Parsetree.AT (n, x)) = "ObjectSomeValuesFrom (U ObjectIntersectionOf (ObjectOneOf (n" ^ n ^ ") " ^ (owlfs' b x) ^ "))"
				  | owlfs' _ (Parsetree.PROPVAR x) = "p" ^ x
				  | owlfs' _ (Parsetree.NOMINAL x) = "ObjectOneOf (n" ^ x ^ ")"
				  | owlfs' b (Parsetree.XOR (t1, t2)) =
						if b
						then owlfs' b (Parsetree.translateXor (t1, t2))
						else owlfs' b (Parsetree.NEG (Parsetree.translateXor (Parsetree.NEG t1, t2)))
				  | owlfs' b (Parsetree.NEG (Parsetree.XOR (t1, t2))) = 
						if b
						then owlfs' b (Parsetree.translateXor (Parsetree.NEG t1, t2))
						else owlfs' b (Parsetree.NEG (Parsetree.translateXor (t1, t2)))
				  | owlfs' b (Parsetree.NEG t) = "ObjectComplementOf (" ^ (owlfs' (not b) t) ^ ")"
				  | owlfs' b (Parsetree.ALL t) = "ObjectAllValuesFrom (U " ^ (owlfs' b t) ^ ")"
				  | owlfs' b (Parsetree.EXISTS t) = "ObjectSomeValuesFrom (U " ^ (owlfs' b t) ^ ")"
				  | owlfs' _ (Parsetree.DIFF t) = Exn.error "Cannot represent difference modality in OWL format"
				  | owlfs' _ (Parsetree.NEGDIFF t) = Exn.error "Cannot represent difference modality in OWL format"
				
				fun topLevelUnivToString (Parsetree.XOR (t1, t2)) =
						  "EquivalentClasses ("
						^ (owlfs' true (Parsetree.neg t1))
						^ " "
						^ (owlfs' true t2)
						^ ")\n"
				  | topLevelUnivToString (Parsetree.NEG (Parsetree.XOR (t1, t2))) =
						  "EquivalentClasses ("
						^ (owlfs' true t1)
						^ " "
						^ (owlfs' true t2)
						^ ")\n"
				  | topLevelUnivToString (Parsetree.DISJ [t1, t2]) =
						  "SubClassOf ("
						^ (owlfs' true (Parsetree.neg t1))
						^ " " ^ (owlfs' true t2)
						^ ")\n"
				  | topLevelUnivToString (Parsetree.DISJ (t::tr)) =
						  "SubClassOf ("
						^ (owlfs' true (Parsetree.neg t))
						^ " "
						^ (owlfs' true (Parsetree.DISJ tr))
						^ ")\n"
				  | topLevelUnivToString t =
						"EquivalentClasses (owl:Thing " ^ (owlfs' true t) ^ ")\n"
			in
				  "Namespace(owl=<http://www.w3.org/2002/07/owl#>)\n"
				^ "Ontology (ftt_translated\n"
				^ (
					if containsGlobalMod orelse containsSatOp
					then (
							if containsGlobalMod orelse not satopcompact
							then
								  "ReflexiveObjectProperty (U)\n"
								^ "TransitiveObjectProperty (U)\n"
								^ "SymmetricObjectProperty (U)\n"
								^ (concat (map (fn r => "SubObjectPropertyOf (r" ^ r ^ " U)\n") rel))
							else ""
						  )
						^ (concat (map (fn n => "SubClassOf (owl:Thing ObjectHasValue (U n" ^ n ^ "))\n") nom))
					else ""
				  )
				^ (concat (map (fn r => "ReflexiveObjectProperty (r" ^ r ^ ")\n") refl))
				^ (concat (map (fn r => "TransitiveObjectProperty (r" ^ r ^ ")\n") trans))
				^ (concat (map (fn r => "SymmetricObjectProperty (r" ^ r ^ ")\n") sym))
				^ (concat (map (fn (r1, r2) => "SubObjectPropertyOf (r" ^ r1 ^ " r" ^ r2 ^ ")\n") sub))
				^ (concat (map topLevelUnivToString univ))
				^ (
					if c = "owl:Thing" andalso rem = Parsetree.CONJ nil
					then ""
					else "EquivalentClasses (" ^ c ^ " " ^ (owlfs' true rem) ^ ")"
				  )
				^ "\n)\n"
			end
	end
