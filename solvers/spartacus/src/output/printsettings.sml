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


structure PrintSettings =
struct
	fun printSettings () =
		print (
			  "backjumping: "
			^ (if !Settings.backjumpingDisabled then "off" else "on")
			^ "\npattern-based blocking: "
			^ (
				case (!Settings.pbBlockingEnabled, !Settings.fullBlocking, !Settings.pbbDatastructure)
					of (true, true, Settings.LISTS) => "eager (using list-based data structure)"
					 | (true, true, Settings.UBTREE) => "eager (using tree-based data structure)"
					 | (true, true, Settings.BITMATRIX)=> "eager (using bit-matrix-based data structure"
					 | (true, false, Settings.LISTS) => "on (using list-based data structure)"
					 | (true, false, Settings.UBTREE) => "on (using tree-based data structure)"
					 | (true, false, Settings.BITMATRIX) => "on (using bit-matrix-based data structure"
					 | (false, _, _) => "off"
					 | (true, _, _) => Exn.unexpected "PrintSettings.printSettings: settings for blocking"
			  )
			^ "\ncaching: "
			^ (
				case (!Settings.cachingEnabled, !Settings.checkCacheOften, !Settings.cacheDatastructure)
					of (true, true, Settings.UBTREE) => "eager (using tree-based datastructure)"
					 | (true, true, Settings.BITMATRIX) => "eager (using bit-matrix-based datastructure)"
					 | (true, true, Settings.SIZEBOUNDED n) => (
						  "eager (using size-bounded ("
						^ (Int.toString n)
						^ ") bit-matrix-based datastructure)"
						)
					 | (true, false, Settings.UBTREE) => "on (using tree-based datastructure)"
					 | (true, false, Settings.BITMATRIX) => "on (using bit-matrix-based datastructure)"
					 | (true, false, Settings.SIZEBOUNDED n) => (
						  "on (using size-bounded ("
						^ (Int.toString n)
						^ ") bit-matrix-based datastructure)"
						)
					 | (false, _, _) => "off"
					 | (true, _, _) => Exn.unexpected "PrintSettings.printSettings: settings for caching"
			  )
			^ "\nboolean constraint propagation: "
			^ (
				if !Settings.bcpFullyEnabled
				then "eager"
				else
					if !Settings.bcpEnabled
					then "on"
					else "off"
			  )
			^ "\nearly conflict detection: "
			^ (if !Settings.ecdDisabled then "off" else "on")
			^ "\ndisjoint branching: "
			^ (
				if !Settings.semanticBranchingEnabled
				then
					if !Settings.semanticBranchingNgl
					then "no-good lists only"
					else "on"
				else "off"
			  )
			^ "\nlazy branching: "
			^ (
				if !Settings.lazyBranching orelse !Settings.lazyWithBoxes orelse !Settings.lazyWithNominals
				then (
					  (if !Settings.lazyBranching then "prop" else "") ^ "+"
					^ (if !Settings.lazyWithBoxes then "box" else "") ^ "+"
					^ (if !Settings.lazyWithNominals then "nom" else "")
				)
				else "off"
			  )
			^ "\nExpansion order: "
			^ (Agenda.getOrder ())
			^ "\nDisjunct ordering: "
			^ (String.implode (!Term.Catstore.listOrder))
			^ "\nDiamond ordering: "
			^ (
				if !Settings.diadisjdep
				then "with disjunctions by dependencies"
				else (
					case !Settings.diaExpOrder
						of Settings.FIFO => "FIFO"
						 | Settings.LIFO => "LIFO"
						 | Settings.OLDWORLD => "old nodes first"
						 | Settings.NEWWORLD => "new nodes first"
						 | Settings.DEP => "minimal dependencies first"
						 | Settings.CARNEW => "high cardinality/new nodes first"
						 | Settings.CAROLD => "high cardinality/old nodes first"
						 | _ => Exn.unexpected "PrintSettings.printSettings")
			  )
			^ "\nDisjunction ordering: "
			^ (
				if !Settings.diadisjdep
				then "with diamonds by dependencies"
				else (
					case !Settings.disjExpOrder
						of Settings.FIFO => "FIFO"
						 | Settings.LIFO => "LIFO"
						 | Settings.OLDWORLD => "old nodes first"
						 | Settings.NEWWORLD => "new nodes first"
						 | Settings.DEP => "minimal dependencies first"
						 | Settings.OLDPEN => "old nodes/high penalties first"
						 | Settings.NEWPEN => "new nodes/high penalties first"
						 | Settings.PENOLD => "high penalties/old nodes first"
						 | Settings.PENNEW => "high penalties/new nodes first"
						 | _ => Exn.unexpected "PrintSettings.printSettings")
			  )
			^ "\nNominal substitution: "
			^ (
				if !Settings.dontMergeSuccLists
				then "reschedule diamond expansions"
				else "merge successors"
			  )
			^ "\nfile name: "
			^ (!Settings.fileName)
			^ "\nindex: "
			^ (Int.toString (!Settings.index))
			^ "\n"
		)
end
