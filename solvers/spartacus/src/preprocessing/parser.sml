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


structure Parser =
struct
fun parseInput () =
	let
		val (parsetree, checksat) =
			case !Settings.format
				of Settings.NOINPUT => (HelpMsg.printHelpMsg (); raise HelpMsg.Help)
				 | Settings.ARG =>
					let
						val x = SpartacusParser.parseString (!Settings.formula)
					in
						case x
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse formula!")
					end
				|  Settings.NAT =>
					let
						val x = SpartacusParser.parse (!Settings.fileName)
					in
						case x
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse formula!")
					end
				|  Settings.LWB =>
					let
						val fs = LwbParser.parse (!Settings.fileName)
						
						val f = #2 (
							case (List.find (fn (n, _) => n = (!Settings.index)) fs)
							of SOME x => x
							|  NONE => Exn.error ("Index " ^ (Int.toString (!Settings.index)) ^ 
												" not found in lwb input file!"))
					in
						(f, NONE)
					end
				|  Settings.KSATC =>
					let
						val r = KsatcParser.parse (!Settings.fileName)
					in
						case r
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse KSatC file")
					end
				|  Settings.ALC =>
					let
						val r = AlcParser.parse (!Settings.fileName)
					in
						case r
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse ALC file")
					end
				|  Settings.INTOHYLO =>
					let
						val r = IntohyloParser.parse (!Settings.fileName)
					in
						case r
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse InToHyLo file")
					end
				|  Settings.DIMACS =>
					let
						val r = DimacsParser.parse (!Settings.fileName)
					in
						case r
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse InToHyLo file")
					end
				|  Settings.DFG =>
					let
						val r = DfgParser.parse (!Settings.fileName)
					in
						case r
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse InToHyLo file")
					end
				|  Settings.KRSS =>
					let
						val fs = AdvancedTkbParser.parse (!Settings.fileName)
						
						val f = List.nth (fs, !Settings.index - 1)
					in
						f
					end
				|  Settings.TANCS =>
					let
						val r = TancsParser.parse (!Settings.fileName)
					in
						case r
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse TANCS file")
					end
				|  Settings.OWLFS =>
					let
						val r = OwlFsParser.parse (!Settings.fileName)
					in
						case r
							of SOME p => (p, NONE)
							|  NONE => Exn.error ("Unable to parse OWL file")
					end
		
		val parsetree = if !Settings.negate then Parsetree.neg parsetree else parsetree
		
		val checksat =
			case (checksat, !Settings.checksat)
				of (_, nil) => NONE
				 | (SOME cs, _) => SOME cs
				 | (NONE, ["*"]) => SOME (
					map
						(fn x => (x, Parsetree.EXISTS (Parsetree.PROPVAR x)))
						(Parsetree.listPropvars parsetree)
					)
				  | (NONE, xs) => SOME (
					map
						(fn x => (x, Parsetree.EXISTS (Parsetree.PROPVAR x)))
						xs
					)
		
(*		val parsetree =
			case (!Settings.format, !Settings.checksat)
				of (_, nil) => (parsetree, nil)
				 | (Settings.DL98, _) => parsetree
				 | (_, ["*"]) =>
						Parsetree.conj
							(Parsetree.CONJ (
								map
									(fn x => Parsetree.EXISTS (Parsetree.PROPVAR x))
									(Parsetree.listPropvars parsetree)
								)
							)
							parsetree
				 | (_, xs) =>
						Parsetree.conj
							(Parsetree.CONJ (map (fn x => Parsetree.EXISTS (Parsetree.PROPVAR x)) xs))
							parsetree*)
	in
		(parsetree, checksat)
	end
end
