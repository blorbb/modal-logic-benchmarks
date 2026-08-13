(*****************************************************************************
 *  Authors:
 *    Daniel N. Goetzmann <dngoetzmann@googlemail.com>
 *    Mark Kaminski <kaminski@ps.uni-saarland.de>
 *
 *  Copyright:
 *     Daniel N. Goetzmann, 2009
 *     Mark Kaminski, 2010
 *
 *  Last modified:
 *    $Date: 2010-04-29 $
 *    $Author: kaminski $
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


val _ =
	let
		val _ = Solver.startTimer ()
		
		fun run () =
			let
				val _ = ReadArgs.readArgs ()
				
				val _ =
					if !Settings.negate andalso !Settings.checksat <> nil
					then (
						  print "Arguments --negate and --checksat must not be combined\n"
						; raise ReadArgs.InvalidArgument
						)
					else ()
				
				val _ = if !Settings.csv then CsvOutput.printSettingsList () else PrintSettings.printSettings ()
				
				val _ = if !Settings.csv then () else print "Parsing input\n"
				
				val timer = Timer.startRealTimer ()
				
				val (parsetree, csp) = Parser.parseInput ()
				
				val _ =
					print (
						if !Settings.csv
						then (Time.toString (Timer.checkRealTimer timer)) ^ ","
						else "Parse time: " ^ (Time.toString (Timer.checkRealTimer timer)) ^ " sec\n"
					)
				
				val (k, cs) =
					let
						val _ = if !Settings.csv then () else print "Translating to NNF\n"
						val timer1 = Timer.startRealTimer ()
						val nnfTree = Parsetree.nnf parsetree
						val nnfChecksat = Option.map (map (fn (c, p) => (c, Parsetree.nnf p))) csp
						val _ = print (if !Settings.csv then (Time.toString (Timer.checkRealTimer timer1)) ^ "," else "Translation time (NNF): " ^ (Time.toString (Timer.checkRealTimer timer1)) ^ " sec\n")
						val timer2 = Timer.startRealTimer ()
						val _ = if !Settings.csv then () else print "Translating to index representation\n"
						val _ = Translator.reset ()
						val k = Translator.translate nnfTree
						val cs = Option.map (map (fn (c, p) => (c, Translator.translate p, Translator.translate (Parsetree.NEG (Parsetree.PROPVAR c))))) nnfChecksat
						val _ = print (if !Settings.csv then (Time.toString (Timer.checkRealTimer timer2)) ^ "," else "Translation time (indexing): " ^ (Time.toString (Timer.checkRealTimer timer2)) ^ " sec\n")
						val _ = (if RelationMgr.listReflexive () = RelationMgr.listRelations () then Settings.lazyWithBoxes := false else ());
						val _ = if !Settings.csv then () else print ("Relational variables: " ^ (Util.listToString (fn x => x) (RelationMgr.listRelations())) ^ "\n")
						val _ = if !Settings.csv then () else print ("Reflexive relations:  " ^ (Util.listToString (fn x => x) (RelationMgr.listReflexive())) ^ "\n")
						val _ = if !Settings.csv then () else print ("Transitive relations: " ^ (Util.listToString (fn x => x) (RelationMgr.listTransitive())) ^ "\n")
						val _ = if !Settings.csv then () else print ("Serial relations:     " ^ (Util.listToString (fn x => x) (RelationMgr.listSerial())) ^ "\n")
					in
						(k, cs)
					end
				
				fun modelOutput c =
					  if !Settings.showModel
					  then (
						  if !Settings.detailedModelView then print (Translator.toString ()) else ()
						; ModelOutput.printModel ()
					    )
					  else
					  (
						case !Settings.dotFileName
							of NONE => ()
							 | SOME f => ModelOutput.writeDot (f ^ c)
					  )

				
				fun checksat (c, k1, k2) =
					let
					in
						if Solver.checksat (c, k, k1, k2)
						then modelOutput ("_" ^ c)
						else ()
					end
			in
				  if Solver.solveTerm k
				  then (
					  modelOutput ""
					; case cs
						of NONE => ()
						 | SOME xs => (
							  app checksat xs
							; print ("Total time: " ^ (Time.toString (Solver.checkTimer ())) ^ "\n")
						 )
				  )
				  else ()
			end
	in
		run ()
		handle HelpMsg.Help => ()
		     | ReadArgs.InvalidArgument => ()
			 | Solver.Timeout => ()
			 | IO.Io {cause = cause, function = function, name = name} =>
					print ("Unable to read from or write to " ^ name ^ "\n")
			 | e => (
					if !Settings.csv
					then (print "Unhandled exception!\n"; OS.Process.exit OS.Process.failure)
					else raise e
					)
	end
