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


structure Parsetree =
	struct
		datatype xorRepresentationType = XORA | XORC | XORD
		
		datatype parsetree =
			  CONJ of parsetree list
			| DISJ of parsetree list
			| NEG of parsetree
			| PROPVAR of string
			| NOMINAL of string
			| DIAMOND of string * parsetree
			| BOX of string * parsetree
			| ALL of parsetree
			| EXISTS of parsetree
			| DIFF of parsetree
			| NEGDIFF of parsetree
			| AT of string * parsetree
			| XOR of parsetree * parsetree
		
		
		val xorRepresentation = ref XORA
		
		
		fun neg (NEG x) = x
		  | neg x = NEG x
		
		fun conj (CONJ xs) (CONJ ys) = CONJ (xs @ ys)
		  | conj (CONJ xs) y         = CONJ (xs @ [y])
		  | conj x         (CONJ ys) = CONJ (x::ys)
		  | conj x         y         = CONJ [x, y]
		
		
		fun disj (DISJ xs) (DISJ ys) = DISJ (xs @ ys)
		  | disj (DISJ xs) y         = DISJ (xs @ [y])
		  | disj x         (DISJ ys) = DISJ (x::ys)
		  | disj x         y         = DISJ [x, y]
		
		fun mconj [x] = x
		  | mconj xr = CONJ xr
		
		fun mdisj [x] = x
		  | mdisj xr = DISJ xr
		
		fun impl x y = DISJ [neg x, y]
		
		
		fun dimpl x y = neg (XOR (x, y))
		
		
		fun xor x y = XOR (x, y)
		
		
		fun mxor nil = DISJ nil
		  | mxor [x] = x
		  | mxor (x::xr) = xor x (mxor xr)
		
		
		fun mequal xs = DISJ [CONJ xs, CONJ (map neg xs)]
		
		
		fun translateXor (t1, t2) =
			let
				fun conjRepr () = CONJ [DISJ [t1, t2], DISJ [neg t1, neg t2]]
				fun disjRepr () = DISJ [CONJ [neg t1, t2], CONJ [t1, neg t2]]
			in
				case !xorRepresentation
					of XORD => disjRepr ()
					 | XORC => conjRepr ()
					 | XORA =>
						case (t1, t2)
							of (PROPVAR _, _) => conjRepr ()
							 | (NEG (PROPVAR _), _) => conjRepr ()
							 | (_, PROPVAR _) => conjRepr ()
							 | (_, NEG (PROPVAR _)) => conjRepr ()
							 | _ => disjRepr ()
			end
		
		
		fun toString (CONJ ts) =
				"/\\(" ^ (Util.listToString toString ts) ^ ")"
		  | toString (DISJ ts) =
				"\\/(" ^ (Util.listToString toString ts) ^ ")"
		  | toString (NEG t) = "~" ^ (toString t)
		  | toString (PROPVAR p) = p
		  | toString (NOMINAL n) = "(=)" ^ n
		  | toString (DIAMOND (r, t)) = "<" ^ r ^ ">" ^ (toString t)
		  | toString (BOX (r, t)) = "[" ^ r ^ "]" ^ (toString t)
		  | toString (ALL t) = "A" ^ (toString t)
		  | toString (EXISTS t) = "E" ^ (toString t)
		  | toString (DIFF t) = "D" ^ (toString t)
		  | toString (NEGDIFF t) = "(~D)" ^ (toString t)
		  | toString (AT (x, t)) = "@" ^ x ^ ":" ^ (toString t)
		  | toString (XOR (t1, t2)) = "XOR (" ^ (toString t1) ^ ", " ^ (toString t2) ^ ")"
		
		
		fun flatten (PROPVAR p) = (PROPVAR p)
		  | flatten (NOMINAL n) = (NOMINAL n)
		  | flatten (NEG (NEG t)) = t
		  | flatten (NEG t) = NEG (flatten t)
		  | flatten (CONJ ts) =
				let
					val (cnj, oth) = List.partition (fn CONJ _ => true | _ => false) (map flatten ts)
					
					fun ff (CONJ ts, xs) = ts @ xs
					  | ff _ = Exn.unexpected "Parsetree.flatten.ff: #1 of arg is not a CONJ _"
				in
					CONJ (oth @ (foldl ff nil cnj))
				end
		  | flatten (DISJ ts) =
				let
					val (dsj, oth) = List.partition (fn DISJ _ => true | _ => false) (map flatten ts)
					
					fun ff (DISJ ts, xs) = ts @ xs
					  | ff _ = Exn.unexpected "Parsetree.flatten.ff: #1 of arg is not a DISJ _"
				in
					DISJ (oth @ (foldl ff nil dsj))
				end
		  | flatten (DIAMOND (r, t)) = DIAMOND (r, flatten t)
		  | flatten (BOX (r, t)) = BOX (r, flatten t)
		  | flatten (ALL t) = ALL (flatten t)
		  | flatten (EXISTS t) = EXISTS (flatten t)
		  | flatten (DIFF t) = DIFF (flatten t)
		  | flatten (NEGDIFF t) = NEGDIFF (flatten t)
		  | flatten (AT (x, t)) = AT (x, flatten t)
		  | flatten (XOR (t1, t2)) = Exn.unexpArg "Translator.flatten"
		
		
		fun nnf t =
			let
				fun nnf' (PROPVAR p) = PROPVAR p
				  | nnf' (NOMINAL n) = NOMINAL n
				  | nnf' (NEG (PROPVAR p)) = NEG (PROPVAR p)
				  | nnf' (NEG (NOMINAL n)) = NEG (NOMINAL n)
				  | nnf' (CONJ ts) = CONJ (map nnf' ts)
				  | nnf' (NEG (CONJ ts)) = DISJ (map (nnf' o NEG) ts)
				  | nnf' (DISJ ts) = DISJ (map nnf' ts)
				  | nnf' (NEG (DISJ ts)) = CONJ (map (nnf' o NEG) ts)
				  | nnf' (DIAMOND (r, t)) = DIAMOND (r, nnf' t)
				  | nnf' (NEG (DIAMOND (r, t))) = BOX (r, nnf' (NEG t))
				  | nnf' (BOX (r, t)) = BOX (r, nnf' t)
				  | nnf' (NEG (BOX (r, t))) = DIAMOND (r, nnf' (NEG t))
				  | nnf' (ALL t) = ALL (nnf' t)
				  | nnf' (NEG (ALL t)) = EXISTS (nnf' (NEG t))
				  | nnf' (EXISTS t) = EXISTS (nnf' t)
				  | nnf' (NEG (EXISTS t)) = ALL (nnf' (NEG t))
				  | nnf' (DIFF t) = DIFF (nnf' t)
				  | nnf' (NEG (DIFF t)) = NEGDIFF (nnf' (NEG t))
				  | nnf' (NEGDIFF t) = NEGDIFF (nnf' t)
				  | nnf' (NEG (NEGDIFF t)) = DIFF (nnf' (NEG t))
				  | nnf' (AT (x, t)) = AT (x, nnf' t)
				  | nnf' (NEG (AT (x, t))) = AT (x, nnf' (NEG t))
				  | nnf' (XOR (t1, t2)) = nnf' (translateXor (nnf' t1, nnf' t2))
				  | nnf' (NEG (XOR (t1, t2))) = nnf' (translateXor (nnf' (neg t1), nnf' t2))
				  | nnf' (NEG (NEG t)) = nnf' t
			in
				flatten (nnf' t)
			end
		
		fun toNumberedTree pt =
			let
				exception NotFound
				
				datatype varType = NV | PV | RV
				
				val bm = ref (Binarymap.mkDict String.compare) : (string, int) Binarymap.dict ref
				
				val propvars = ref IntBinarySet.empty
				val nominals = ref IntBinarySet.empty
				val relvars = ref IntBinarySet.empty
				
				fun lookup vt v =
					let
						val prefix =
							case vt
								of NV => "nv"
								|  PV => "pv"
								|  RV => "rv"
						
						fun assignNew () =
							let
								fun keepDigits x = if Char.isDigit x then Char.toString x else ""
								
								val number = 
									let
										fun setNext s n =
											if IntBinarySet.member (!s, n)
											then setNext s (n + 1)
											else (s := (IntBinarySet.add (!s, n)); n)
										
										val s =
											case vt
												of NV => nominals
												|  PV => propvars
												|  RV => relvars
										
										val n = Option.getOpt (Int.fromString (String.translate keepDigits v), 1)
									in
										setNext s (Int.max (n, 1))
									end
							in
								(Ref.modify (fn m => Binarymap.insert (m, prefix ^ v, number)) bm; number)
							end
					in
						case Binarymap.peek (!bm, prefix ^ v)
							of SOME v' => Int.toString v'
							|  NONE => Int.toString (assignNew ())
					end
				
				fun tnt (CONJ ts) = CONJ (map tnt ts)
				  | tnt (DISJ ts) = DISJ (map tnt ts)
				  | tnt (NEG t) = NEG (tnt t)
				  | tnt (PROPVAR p) = PROPVAR (lookup PV p)
				  | tnt (NOMINAL p) = NOMINAL (lookup NV p)
				  | tnt (DIAMOND (r, t)) = DIAMOND (lookup RV r, tnt t)
				  | tnt (BOX (r, t)) = BOX (lookup RV r, tnt t)
				  | tnt (ALL t) = ALL (tnt t)
				  | tnt (EXISTS t) = EXISTS (tnt t)
				  | tnt (DIFF t) = DIFF (tnt t)
				  | tnt (NEGDIFF t) = NEGDIFF (tnt t)
				  | tnt (AT (n, t)) = AT (lookup NV n, tnt t)
				  | tnt (XOR (t1, t2)) = XOR (tnt t1, tnt t2)
			in
				(
					  tnt pt
					, map Int.toString (IntBinarySet.listItems (!nominals))
					, map Int.toString (IntBinarySet.listItems (!relvars))
					, map (lookup RV) (RelationMgr.listReflexive ())
					, map (lookup RV) (RelationMgr.listTransitive ())
					, map (lookup RV) (RelationMgr.listSerial ())
					, map (lookup RV) (RelationMgr.listSymmetric ())
					, map (fn (x, y) => (lookup RV x, lookup RV y)) (RelationMgr.listSubrelations ())
				)
			end
		
		
		fun toCnf pt =
			let
				fun toCnf' (PROPVAR p) = PROPVAR p
				  | toCnf' (NEG (PROPVAR p)) = NEG (PROPVAR p)
				  | toCnf' (CONJ ts) = flatten (CONJ (map toCnf' ts))
				  | toCnf' (DISJ ts) =
					let
						fun distribute (DISJ ts) =
							let
								val (conj, lit) = List.partition (fn CONJ _ => true | _ => false) ts
								
								fun prod (xs, nil) = nil
								  | prod (xs, (y::yr)) = (map (fn x => y::x) xs) @ (prod (xs, yr))
								
								fun distribute' ds nil = ds
								  | distribute' ds ((CONJ ts')::xr) = distribute' (prod (ds, ts')) xr
								  | distribute' _ _ = Exn.unexpArg "Parsetree.toCnf.toCnf'.distribute.distribute'"
							in
								if conj = nil
								then DISJ lit
								else CONJ (map DISJ (distribute' [lit] conj))
							end
						  | distribute _ = Exn.unexpArg "Parsetree.toCnf.toCnf'.distribute"
					in
						distribute (flatten (DISJ (map toCnf' ts)))
					end
				  | toCnf' _ = Exn.error "Unable to transform formula to CNF"
			in
				case toCnf' (nnf pt)
					of CONJ ts => CONJ (map (fn t => case t of x as DISJ _ => x | t' => DISJ [t']) ts)
					 | DISJ ts => CONJ [DISJ ts]
					 | t => CONJ  [DISJ [t]]
			end
		
		fun listPropvars pt =
			let
				fun ms nil ys = ys
				  | ms xs nil = xs
				  | ms (xs as x::xr) (ys as y::yr) =
						case String.compare (x, y)
							of LESS => x::(ms xr ys)
							 | EQUAL => x::(ms xr yr)
							 | GREATER => y::(ms xs yr)
				
				fun lp (CONJ xs) = foldl (fn (x, ys) => ms ys (lp x)) nil xs
				  | lp (DISJ xs) = foldl (fn (x, ys) => ms ys (lp x)) nil xs
				  | lp (NEG x) = lp x
				  | lp (PROPVAR x) = [x]
				  | lp (NOMINAL x) = nil
				  | lp (DIAMOND (_, x)) = lp x
				  | lp (BOX (_, x)) = lp x
				  | lp (ALL x) = lp x
				  | lp (EXISTS x) = lp x
				  | lp (DIFF x) = lp x
				  | lp (NEGDIFF x) = lp x
				  | lp (AT (_, x)) = lp x
				  | lp (XOR (x, y)) = ms (lp x) (lp y)
			in
				lp pt
			end
		
		fun listNominals pt =
			let
				fun ms nil ys = ys
				  | ms xs nil = xs
				  | ms (xs as x::xr) (ys as y::yr) =
						case String.compare (x, y)
							of LESS => x::(ms xr ys)
							 | EQUAL => x::(ms xr yr)
							 | GREATER => y::(ms xs yr)
				
				fun lp (CONJ xs) = foldl (fn (x, ys) => ms ys (lp x)) nil xs
				  | lp (DISJ xs) = foldl (fn (x, ys) => ms ys (lp x)) nil xs
				  | lp (NEG x) = lp x
				  | lp (PROPVAR x) = nil
				  | lp (NOMINAL x) = [x]
				  | lp (DIAMOND (_, x)) = lp x
				  | lp (BOX (_, x)) = lp x
				  | lp (ALL x) = lp x
				  | lp (EXISTS x) = lp x
				  | lp (DIFF x) = lp x
				  | lp (NEGDIFF x) = lp x
				  | lp (AT (n, x)) = ms [n] (lp x)
				  | lp (XOR (x, y)) = ms (lp x) (lp y)
			in
				lp pt
			end
		
		fun listRelations pt =
			let
				fun ms nil ys = ys
				  | ms xs nil = xs
				  | ms (xs as x::xr) (ys as y::yr) =
						case String.compare (x, y)
							of LESS => x::(ms xr ys)
							 | EQUAL => x::(ms xr yr)
							 | GREATER => y::(ms xs yr)
				
				fun lp (CONJ xs) = foldl (fn (x, ys) => ms ys (lp x)) nil xs
				  | lp (DISJ xs) = foldl (fn (x, ys) => ms ys (lp x)) nil xs
				  | lp (NEG x) = lp x
				  | lp (PROPVAR x) = nil
				  | lp (NOMINAL x) = nil
				  | lp (DIAMOND (r, x)) = ms [r] (lp x)
				  | lp (BOX (r, x)) = ms [r] (lp x)
				  | lp (ALL x) = lp x
				  | lp (EXISTS x) = lp x
				  | lp (DIFF x) = lp x
				  | lp (NEGDIFF x) = lp x
				  | lp (AT (_, x)) = lp x
				  | lp (XOR (x, y)) = ms (lp x) (lp y)
			in
				lp pt
			end
	
	
		fun containsGlobalMod (CONJ ts) = foldl (fn (t, b) => b orelse containsGlobalMod t) false ts
		  | containsGlobalMod (DISJ ts) = foldl (fn (t, b) => b orelse containsGlobalMod t) false ts
		  | containsGlobalMod (NEG t) = containsGlobalMod t
		  | containsGlobalMod (PROPVAR x) = false
		  | containsGlobalMod (NOMINAL x) = false
		  | containsGlobalMod (BOX (_, t)) = containsGlobalMod t
		  | containsGlobalMod (DIAMOND (_, t)) = containsGlobalMod t
		  | containsGlobalMod (ALL _) = true
		  | containsGlobalMod (EXISTS _) = true
		  | containsGlobalMod (DIFF t) = true
		  | containsGlobalMod (NEGDIFF t) = true
		  | containsGlobalMod (AT (_, t)) = false
		  | containsGlobalMod (XOR (s, t)) = containsGlobalMod s orelse containsGlobalMod t
	
	
		fun containsSatOp (CONJ ts) = foldl (fn (t, b) => b orelse containsSatOp t) false ts
		  | containsSatOp (DISJ ts) = foldl (fn (t, b) => b orelse containsSatOp t) false ts
		  | containsSatOp (NEG t) = containsSatOp t
		  | containsSatOp (PROPVAR x) = false
		  | containsSatOp (NOMINAL x) = false
		  | containsSatOp (BOX (_, t)) = containsSatOp t
		  | containsSatOp (DIAMOND (_, t)) = containsSatOp t
		  | containsSatOp (ALL _) = false
		  | containsSatOp (EXISTS _) = false
		  | containsSatOp (DIFF t) = false
		  | containsSatOp (NEGDIFF t) = false
		  | containsSatOp (AT (_, t)) = true
		  | containsSatOp (XOR (s, t)) = containsSatOp s orelse containsSatOp t
	end
