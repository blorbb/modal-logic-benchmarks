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


exception Help
		
val _ =
	let
		datatype inputFormat = NOINPUT | NAT | LWB | KSATC | ALC | INTOHYLO | DIMACS | DFG | KRSS | TANCS | OWLFS
		
		val helpMsg =
			"Usage: ftt [OPTIONS]...\n" ^
			"\nInput:\n" ^
			"--file=FILE              read formula from FILE\n" ^
			"--dfgascFile=FILE        read formula in dfg-ascii format from FILE\n" ^
			"--dimacsFile=FILE        read formula in dimacs format from FILE\n" ^
			"--krssFile=FILE          read formula in KRSS format from FILE\n" ^
			"--factFile=FILE          read formula in FaCT format from FILE\n" ^
			"--intohyloFile=FILE      read formula in InToHyLo format from FILE\n" ^
			"--ksatcFile=FILE         read formula in KSatC format from FILE\n" ^
			"--ksatlFile=FILE         read formula in KSatLisp format from FILE\n" ^
			"--lwbFile=FILE           read formula in LWB format from FILE\n" ^
			"--tancsFile=FILE         read formula in TANCS format from FILE\n" ^
			"--owlfsFile=FILE         read formula in OWL functional-style syntax\n" ^
			"                         from FILE\n" ^
			"--negate                 negate the input formula\n" ^
			"\nOutput:\n" ^
			"-c                       translate the formula to KSatC format\n" ^
			"-d                       translate the formula to DIMACS CNF format\n" ^
			"-f                       translate the formula to FaCT format\n" ^
			"-g                       translate the formula to DFG format\n" ^
			"-h                       translate the formula to KRSS format\n" ^
			"-i                       translate the formula to InToHyLo format\n" ^
			"-k                       translate the formula to KSatLisp format\n" ^
			"-o                       translate the formula to OWL functional-style\n" ^
			"                         format\n" ^
			"-s                       translate the formula to Spartacus format\n" ^
			"-w                       translate the formula to cwb format\n" ^
			"\nAdditional options:\n" ^
			"--consistency=C          in combination with -f, -h or -o:\n" ^
			"                         translate into consistency of C\n" ^
			"                         (default: *TOP*, TEST or owl:Thing, resp.)\n" ^
			"--reflexive              in combination with -f, -o or -s:\n" ^
			"                         set all relations to be reflexive\n" ^
			"--transitive             in combination with -f, -o or -s:\n" ^
			"                         set all relations to be transitive\n" ^
			"--iff-conj               represent s<->t as (~s|t)&(s|~t)\n" ^
			"--iff-disj               represent s<->t as (s&t)|(~s&~t)\n" ^
			"--iff-auto               represent s<->t as (~s|t)&(s|~t) if s or t is a\n" ^
			"                         prop. literal, (s&t)|(~s&~t) otherwise (default)\n" ^
			"--satop=compact          in combination with -f or -o:\n" ^
			"                         if possible, use a compact translation of\n" ^
			"                         satisfaction operators (default)\n" ^
			"--satop=uni              in combination with -f or -o:\n" ^
			"                         always translate satisfaction operators\n" ^
			"                         using the universal role\n"
		
		val format = ref NOINPUT
		val fileName = ref ""
		
		val negate = ref false
		
		val refl = ref false
		val trans = ref false
		
		val outC = ref false
		val outD = ref false
		val outF = ref false
		val outG = ref false
		val outH = ref false
		val outI = ref false
		val outK = ref false
		val outO = ref false
		val outS = ref false
		val outW = ref false
		
		val consistency = ref NONE
		val satopcompact = ref true
		
		val parsetree = ref (Parsetree.DISJ [])
		
		val args = CommandLine.arguments ()
		
		fun writeC t f =
			let
				val file = TextIO.openOut f
			in
				TextIO.output (file, FormulaOutput.ksatc t);
				TextIO.closeOut file
			end
		
		fun writeD t f =
			let
				val file = TextIO.openOut f
			in
				TextIO.output (file, FormulaOutput.dimacscnf t);
				TextIO.closeOut file
			end
		
		fun writeF t f =
			let
				val file = TextIO.openOut f
				
				val c =
					case !consistency
						of NONE => "*TOP*"
						 | SOME c => c
			in
				TextIO.output (file, FormulaOutput.fact t {c = c, satopcompact = !satopcompact});
				TextIO.closeOut file
			end
		
		fun writeG t f =
			let
				val file = TextIO.openOut f
			in
				TextIO.output (file, FormulaOutput.dfg t);
				TextIO.closeOut file
			end
		
		fun writeH t f =
			let
				val file = TextIO.openOut f
				
				val c =
					case !consistency
						of NONE => "TEST"
						 | SOME c => c
			in
				TextIO.output (file, FormulaOutput.krss t {c = c});
				TextIO.closeOut file
			end
		
		fun writeI t f =
			let
				val file = TextIO.openOut f
			in
				TextIO.output (file, FormulaOutput.intohylo t);
				TextIO.closeOut file
			end
		
		fun writeK t f =
			let
				val file = TextIO.openOut f
			in
				TextIO.output (file, FormulaOutput.alc t);
				TextIO.closeOut file
			end
		
		fun writeO t f =
			let
				val file = TextIO.openOut f
				
				val c =
					case !consistency
						of NONE => "owl:Thing"
						 | SOME c => c
			in
				TextIO.output (file, FormulaOutput.owlfs t  {c = c, satopcompact = !satopcompact});
				TextIO.closeOut file
			end
		
		fun writeS t f =
			let
				val file = TextIO.openOut f
			in
				TextIO.output (file, FormulaOutput.spartacus t);
				TextIO.closeOut file
			end
		
		fun writeW t f =
			let
				val file = TextIO.openOut f
			in
				TextIO.output (file, FormulaOutput.cwb t);
				TextIO.closeOut file
			end
		
		fun write t f =
			let
				val t' = if !negate then Parsetree.neg t else t
			in
				if !outC then writeC t (f ^ ".ksatc") else ();
				if !outD then writeD t (f ^ ".cnf") else ();
				if !outF then writeF t (f ^ ".tbox") else ();
				if !outG then writeG t (f ^ ".dfg") else ();
				if !outH then writeH t (f ^ ".krss") else ();
				if !outI then writeI t (f ^ ".intohylo") else ();
				if !outK then writeK t (f ^ ".alc") else ();
				if !outO then writeO t (f ^ ".func") else ();
				if !outS then writeS t (f ^ ".hlf") else ();
				if !outW then writeW t (f ^ ".cwb") else ()
			end
		
		fun readargs "--help" = (print helpMsg; raise Help)
		  | readargs "-negate" = negate := true
		  | readargs "--negate" = negate := true
		  | readargs "-c" = outC := true
		  | readargs "-d" = outD := true
		  | readargs "-f" = outF := true
		  | readargs "-g" = outG := true
		  | readargs "-h" = outH := true
		  | readargs "-i" = outI := true
		  | readargs "-k" = outK := true
		  | readargs "-o" = outO := true
		  | readargs "-s" = outS := true
		  | readargs "-w" = outW := true
		  | readargs "--reflexive" = RelationMgr.setAllReflexive ()
		  | readargs "--transitive" = RelationMgr.setAllTransitive ()
		  | readargs "--iff-conj" = Parsetree.xorRepresentation := Parsetree.XORC
		  | readargs "--iff-disj" = Parsetree.xorRepresentation := Parsetree.XORD
		  | readargs "--iff-auto" = Parsetree.xorRepresentation := Parsetree.XORA
		  | readargs "--satop=compact" = satopcompact := true
		  | readargs "--satop=uni" = satopcompact := false
		  | readargs s =
				if String.isPrefix "-file=" s
				then (fileName := (String.extract (s, 6, NONE)); format := NAT)
				else if String.isPrefix "--file=" s
				then (fileName := (String.extract (s, 7, NONE)); format := NAT)
				else if String.isPrefix "-lwbFile=" s
				then (fileName := (String.extract (s, 9, NONE)); format := LWB)
				else if String.isPrefix "--lwbFile=" s
				then (fileName := (String.extract (s, 10, NONE)); format := LWB)
				else if String.isPrefix "-ksatcFile=" s
				then (fileName := (String.extract (s, 11, NONE)); format := KSATC)
				else if String.isPrefix "--ksatcFile=" s
				then (fileName := (String.extract (s, 12, NONE)); format := KSATC)
				else if String.isPrefix "-alcFile=" s
				then (fileName := (String.extract (s, 9, NONE)); format := ALC)
				else if String.isPrefix "--alcFile=" s
				then (fileName := (String.extract (s, 10, NONE)); format := ALC)
				else if String.isPrefix "-intohyloFile=" s
				then (fileName := (String.extract (s, 14, NONE)); format := INTOHYLO)
				else if String.isPrefix "--intohyloFile=" s
				then (fileName := (String.extract (s, 15, NONE)); format := INTOHYLO)
				else if String.isPrefix "-dimacsFile=" s
				then (fileName := (String.extract (s, 12, NONE)); format := DIMACS)
				else if String.isPrefix "--dimacsFile=" s
				then (fileName := (String.extract (s, 13, NONE)); format := DIMACS)
				else if String.isPrefix "-dfgascFile=" s
				then (fileName := (String.extract (s, 12, NONE)); format := DFG)
				else if String.isPrefix "--dfgascFile=" s
				then (fileName := (String.extract (s, 13, NONE)); format := DFG)
				else if String.isPrefix "-tkbFile=" s
				then (fileName := (String.extract (s, 9, NONE)); format := KRSS)
				else if String.isPrefix "--tkbFile=" s
				then (fileName := (String.extract (s, 10, NONE)); format := KRSS)
				else if String.isPrefix "-dl98File=" s
				then (fileName := (String.extract (s, 10, NONE)); format := KRSS)
				else if String.isPrefix "--dl98File=" s
				then (fileName := (String.extract (s, 11, NONE)); format := KRSS)
				else if String.isPrefix "-krssFile=" s
				then (fileName := (String.extract (s, 10, NONE)); format := KRSS)
				else if String.isPrefix "--krssFile=" s
				then (fileName := (String.extract (s, 11, NONE)); format := KRSS)
				else if String.isPrefix "-factFile=" s
				then (fileName := (String.extract (s, 10, NONE)); format := KRSS)
				else if String.isPrefix "--factFile=" s
				then (fileName := (String.extract (s, 11, NONE)); format := KRSS)
				else if String.isPrefix "-tancsFile=" s
				then (fileName := (String.extract (s, 11, NONE)); format := TANCS)
				else if String.isPrefix "--tancsFile=" s
				then (fileName := (String.extract (s, 12, NONE)); format := TANCS)
				else if String.isPrefix "-ksatlFile=" s
				then (fileName := (String.extract (s, 11, NONE)); format := ALC)
				else if String.isPrefix "--ksatlFile=" s
				then (fileName := (String.extract (s, 12, NONE)); format := ALC)
				else if String.isPrefix "-owlfsFile=" s
				then (fileName := (String.extract (s, 11, NONE)); format := OWLFS)
				else if String.isPrefix "--owlfsFile=" s
				then (fileName := (String.extract (s, 12, NONE)); format := OWLFS)
				else if String.isPrefix "--consistency=" s
				then (consistency := (SOME (String.extract (s, 14, NONE))))
				else print ("Skipping argument: " ^ s ^ "\n")
		
		fun condNegate t =
			let
				val _ = map RelationMgr.addRelation (Parsetree.listRelations t)
			in
				Util.condMap Parsetree.neg (!negate) t
			end
	in
		app readargs args;
		case !format
			of NOINPUT => (print helpMsg; raise Help)
			 | NAT =>
				let
					val x = SpartacusParser.parse (!fileName)
				in
					case x
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse formula!")
				end
			|  LWB =>
				let
					val fs = LwbParser.parse (!fileName)
				in
					app (fn (n, t) => write (condNegate t) (!fileName ^ "." ^ (Int.toString n))) fs
				end
			|  KSATC =>
				let
					val r = KsatcParser.parse (!fileName)
				in
					case r
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse KSatC file")
				end
			|  ALC =>
				let
					val r = AlcParser.parse (!fileName)
				in
					case r
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse alc file")
				end
			|  INTOHYLO =>
				let
					val r = IntohyloParser.parse (!fileName)
				in
					case r
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse intohylo file")
				end
			|  DIMACS =>
				let
					val r = DimacsParser.parse (!fileName)
				in
					case r
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse dimacs file")
				end
			|  DFG =>
				let
					val r = DfgParser.parse (!fileName)
				in
					case r
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse dfg-ascii file")
				end
			|  KRSS =>
				let
					val fs = map #1 (AdvancedTkbParser.parse (!fileName))
					handle _ => Exn.error "Unable to parse dl98 file"
					
					fun appi _ _ nil = ()
					  | appi n f (x::xr) = (f (n, x); appi (n + 1) f xr)
				in
					appi 0 (fn (n, t) => write (condNegate t) (!fileName ^ "." ^ (Int.toString n))) fs
				end
			|  TANCS =>
				let
					val r = TancsParser.parse (!fileName)
				in
					case r
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse TANCS file")
				end
			|  OWLFS =>
				let
					val r = OwlFsParser.parse (!fileName)
				in
					case r
						of SOME pt => write (condNegate pt) (!fileName)
						|  NONE => Exn.error ("Unable to parse OWLFS file")
				end
	end
	handle Help => ()
		 | IO.Io {cause = cause, function = function, name = name} =>
				print ("Unable to read from or write to " ^ name ^ "\n")
