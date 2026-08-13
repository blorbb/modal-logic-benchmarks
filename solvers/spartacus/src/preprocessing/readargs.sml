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


structure ReadArgs =
struct
exception InvalidArgument

fun readArg "--help" = (HelpMsg.printHelpMsg (); raise HelpMsg.Help)
  | readArg "--csv" = Settings.csv := true
  | readArg "--csvheader" = (print CsvOutput.csvHeader; raise HelpMsg.Help)
  | readArg "--caching=on" = (Settings.cachingEnabled := true; Settings.checkCacheOften := false)
  | readArg "--caching=off" = Settings.cachingEnabled := false
  | readArg "--caching=eager" = (Settings.cachingEnabled := true; Settings.checkCacheOften := true)
  | readArg "--blocking=on" = (Settings.pbBlockingEnabled := true; Settings.fullBlocking := false)
  | readArg "--blocking=off" = (Settings.pbBlockingEnabled := false; Settings.fullBlocking := false)
  | readArg "--blocking=eager" = (Settings.pbBlockingEnabled := true; Settings.fullBlocking := true)
  | readArg "--ecd=on" = Settings.ecdDisabled := false
  | readArg "--ecd=off" = Settings.ecdDisabled := true
  | readArg "--db=on" = (Settings.semanticBranchingEnabled := true; Settings.semanticBranchingNgl := false)
  | readArg "--db=ngl" = (Settings.semanticBranchingEnabled := true; Settings.semanticBranchingNgl := true)
  | readArg "--db=off" = (Settings.semanticBranchingEnabled := false; Settings.semanticBranchingNgl := false)
  | readArg "--lazy=off" = (Settings.lazyBranching := false; Settings.lazyWithBoxes := false; Settings.lazyWithNominals := false)
  | readArg "--lazy=on" = (Settings.lazyBranching := true; Settings.lazyWithBoxes := true; Settings.lazyWithNominals := true)
  | readArg "--debug" = Debug.outputEnabled := true
  | readArg "--xdb" = Agenda.setOrder "<[nAE@|"
  | readArg "--xbd" = Agenda.setOrder "[nAE@|<"
  | readArg "--showModel" = Settings.showModel := true
  | readArg "--dmv" = Settings.detailedModelView := true
  | readArg "--snc" = Settings.showNegativeConstraints := true
  | readArg "--negate" = Settings.negate := true
  | readArg "--backjumping=on" = Settings.backjumpingDisabled := false
  | readArg "--backjumping=off" = Settings.backjumpingDisabled := true
  | readArg "--bcp=eager" = (Settings.bcpEnabled := true; Settings.bcpFullyEnabled := true)
  | readArg "--bcp=on" = (Settings.bcpEnabled := true; Settings.bcpFullyEnabled := false)
  | readArg "--bcp=off" = (Settings.bcpEnabled := false; Settings.bcpFullyEnabled := false)
  | readArg "--dia-old" = Settings.diaExpOrder := Settings.OLDWORLD
  | readArg "--dia-new" = Settings.diaExpOrder := Settings.NEWWORLD
  | readArg "--dia-lifo" = Settings.diaExpOrder := Settings.LIFO
  | readArg "--dia-fifo" = Settings.diaExpOrder := Settings.FIFO
  | readArg "--dia-dep" = Settings.diaExpOrder := Settings.DEP
  | readArg "--dia-car-new" = Settings.diaExpOrder := Settings.CARNEW
  | readArg "--dia-car-old" = Settings.diaExpOrder := Settings.CAROLD
  | readArg "--disj-old" = Settings.disjExpOrder := Settings.OLDWORLD
  | readArg "--disj-new" = Settings.disjExpOrder := Settings.NEWWORLD
  | readArg "--disj-lifo" = Settings.disjExpOrder := Settings.LIFO
  | readArg "--disj-fifo" = Settings.disjExpOrder := Settings.FIFO
  | readArg "--disj-dep" = Settings.disjExpOrder := Settings.DEP
  | readArg "--disj-old-pen" = (Settings.disjExpOrder := Settings.OLDPEN; Settings.penalizeDisjunctions := true)
  | readArg "--disj-new-pen" = (Settings.disjExpOrder := Settings.NEWPEN; Settings.penalizeDisjunctions := true)
  | readArg "--disj-pen-old" = (Settings.disjExpOrder := Settings.PENOLD; Settings.penalizeDisjunctions := true)
  | readArg "--disj-pen-new" = (Settings.disjExpOrder := Settings.PENNEW; Settings.penalizeDisjunctions := true)
  | readArg "--blockingds=list" = Settings.pbbDatastructure := Settings.LISTS
  | readArg "--blockingds=tree" = Settings.pbbDatastructure := Settings.UBTREE
  | readArg "--blockingds=matrix" = Settings.pbbDatastructure := Settings.BITMATRIX
  | readArg "--cachingds=tree" = Settings.cacheDatastructure := Settings.UBTREE
  | readArg "--cachingds=matrix" = Settings.cacheDatastructure := Settings.BITMATRIX
  | readArg "--reflexive" = RelationMgr.setAllReflexive ()
  | readArg "--transitive" = RelationMgr.setAllTransitive ()
  | readArg "--serial" = RelationMgr.setAllSerial ()
  | readArg "--iff-conj" = Parsetree.xorRepresentation := Parsetree.XORC
  | readArg "--iff-disj" = Parsetree.xorRepresentation := Parsetree.XORD
  | readArg "--iff-auto" = Parsetree.xorRepresentation := Parsetree.XORA
  | readArg "--dc-conj" = Settings.dcRepresentation := Settings.DCRCONJ
  | readArg "--dc-disj" = Settings.dcRepresentation := Settings.DCRDISJ
  | readArg "--dc-norm" = Settings.dcRepresentation := Settings.DCRNORM
  | readArg "--cse" = Settings.cse := true
  | readArg "--succ-merge" = Settings.dontMergeSuccLists := false
  | readArg "--succ-exp" = Settings.dontMergeSuccLists := true
  | readArg "--checksat=*" = Settings.checksat := ["*"]
  | readArg s =
		if String.isPrefix "--formula=" s
		then (Settings.formula := (String.extract (s, 10, NONE)); Settings.format := Settings.ARG)
		else if String.isPrefix "--file=" s
		then (Settings.fileName := (String.extract (s, 7, NONE)); Settings.format := Settings.NAT)
		else if String.isPrefix "--lwbFile=" s
		then (Settings.fileName := (String.extract (s, 10, NONE)); Settings.format := Settings.LWB)
		else if String.isPrefix "--ksatcFile=" s
		then (Settings.fileName := (String.extract (s, 12, NONE)); Settings.format := Settings.KSATC)
		else if String.isPrefix "--alcFile=" s
		then (Settings.fileName := (String.extract (s, 10, NONE)); Settings.format := Settings.ALC)
		else if String.isPrefix "--ksatlFile=" s
		then (Settings.fileName := (String.extract (s, 12, NONE)); Settings.format := Settings.ALC)
		else if String.isPrefix "--intohyloFile=" s
		then (Settings.fileName := (String.extract (s, 15, NONE)); Settings.format := Settings.INTOHYLO)
		else if String.isPrefix "--dimacsFile=" s
		then (Settings.fileName := (String.extract (s, 13, NONE)); Settings.format := Settings.DIMACS)
		else if String.isPrefix "--dfgFile=" s
		then (Settings.fileName := (String.extract (s, 10, NONE)); Settings.format := Settings.DFG)
		else if String.isPrefix "--tkbFile=" s
		then (Settings.fileName := (String.extract (s, 10, NONE)); Settings.format := Settings.KRSS)
		else if String.isPrefix "--dl98File=" s
		then (Settings.fileName := (String.extract (s, 11, NONE)); Settings.format := Settings.KRSS)
		else if String.isPrefix "--krssFile=" s
		then (Settings.fileName := (String.extract (s, 11, NONE)); Settings.format := Settings.KRSS)
		else if String.isPrefix "--factFile=" s
		then (Settings.fileName := (String.extract (s, 11, NONE)); Settings.format := Settings.KRSS)
		else if String.isPrefix "--tancsFile=" s
		then (Settings.fileName := (String.extract (s, 12, NONE)); Settings.format := Settings.TANCS)
		else if String.isPrefix "--owlfsFile=" s
		then (Settings.fileName := (String.extract (s, 12, NONE)); Settings.format := Settings.OWLFS)
		else if String.isPrefix "--index=" s
		then Settings.index := (Option.getOpt (Int.fromString (String.extract (s, 8, NONE)), !Settings.index))
		else if String.isPrefix "--lwbIndex=" s
		then Settings.index := (Option.getOpt (Int.fromString (String.extract (s, 11, NONE)), !Settings.index))
		else if String.isPrefix "--checksat=" s
		then Settings.checksat := (String.tokens (fn x => x = #",") (String.extract (s, 11, NONE)))
		else if String.isPrefix "--timeout=" s
		then Settings.timeout := SOME (Time.fromReal (Option.getOpt (Real.fromString (String.extract (s, 10, NONE)), 0.0)))
		else if String.isPrefix "--tci=" s
		then Settings.tci := (Option.valOf (Int.fromString (String.extract (s, 6, NONE))))
		else if String.isPrefix "--disj-ord=" s
		then Term.Catstore.setOrder (String.extract (s, 11, NONE))
		else if String.isPrefix "--exp-ord=" s
		then Agenda.setOrder (String.extract (s, 10, NONE))
		else if String.isPrefix "--dotFile=" s
		then Settings.dotFileName := (SOME (String.extract (s, 10, NONE)))
		else if String.isPrefix "--lazy=" s
		then
			let
				fun setLazy "prop" = Settings.lazyBranching := true
				  | setLazy "box" = Settings.lazyWithBoxes := true
				  | setLazy "nom" = Settings.lazyWithNominals := true
				  | setLazy s = (print ("Invalid argument: --lazy=*" ^ s ^ "*\n"); raise InvalidArgument)
			in
				  Settings.lazyBranching := false
				; Settings.lazyWithBoxes := false
				; Settings.lazyWithNominals := false
				; app setLazy (String.tokens (fn c => c = #"+") (String.extract (s, 7, NONE)))
			end
		else if String.isPrefix "--cachingds=matrix:" s
		then Settings.cacheDatastructure := (Settings.SIZEBOUNDED ((fn n => if n > 0 then n else (print "Invalid argument for cache size bound\n"; raise InvalidArgument)) (Option.getOpt (Int.fromString (String.extract (s, 19, NONE)), !Settings.index))))
		else if String.isPrefix "--profile=" s
		then
			let
				val f = TextIO.openIn (String.extract (s, 10, NONE))
				
				fun ignoreComment s = if String.isPrefix "//" s then "" else s
				
				fun readall () =
					if TextIO.endOfStream f
					then ()
					else (
						  app
							readArg
							(String.tokens
								(fn c => c = #" " orelse c = #"\t" orelse c = #"\n")
								(ignoreComment (Option.valOf (TextIO.inputLine f)))
							)
						; readall ()
					)
			in
				readall ()
			end
		else (print ("Invalid argument: " ^ s ^ "\n"); raise InvalidArgument)


fun readArgs () = app readArg (CommandLine.arguments ())
end
