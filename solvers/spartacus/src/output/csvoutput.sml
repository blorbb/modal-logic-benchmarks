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


structure CsvOutput =
struct
val csvHeader =
	  "file name, "
	^ "index, "
	^ "--negate?, "
	^ "exp-ord, "
	^ "disj-ord, "
	^ "--dia-X, "
	^ "--disj-X, "
	^ "backjumping, "
	^ "blocking, "
	^ "caching, "
	^ "bcp, "
	^ "ecd, "
	^ "db, "
	^ "lazy, "
	^ "blocking ds, "
	^ "caching ds, "
	^ "--succ-X, "
	^ "timeout, "
	^ "tci, "
	^ "parse time, "
	^ "nnf translation time, "
	^ "indexing time, "
	^ "initialization time, "
	^ "decision time, "
	^ "branches, "
	^ "rule applications, "
	^ "cache store ops, "
	^ "cache hits, "
	^ "cache misses, "
	^ "total time, "
	^ "result\n"


fun printSettingsList () =
	print (
		  (!Settings.fileName)
		^ ","
		^ (Int.toString (!Settings.index))
		^ ","
		^ (if (!Settings.negate) then "--negate" else "")
		^ ","
		^ (Agenda.getOrder ())
		^ ","
		^ (String.implode (!Term.Catstore.listOrder))
		^ ","
		^ (
			if !Settings.diadisjdep
			then "n/a"
			else
				case !Settings.diaExpOrder
					of Settings.OLDWORLD => "--dia-old"
					| Settings.NEWWORLD => "--dia-new"
					| Settings.LIFO => "--dia-lifo"
					| Settings.FIFO => "--dia-fifo"
					| Settings.DEP => "--dia-dep"
					| Settings.CARNEW => "--dia-car-new"
					| Settings.CAROLD => "--dia-car-old"
					| _ => Exn.unexpected "CsvOutput.printSettingsList"
		  )
		^ ","
		^ (
			if !Settings.diadisjdep
			then "n/a"
			else
				case !Settings.disjExpOrder
					of Settings.OLDWORLD => "--disj-old"
					| Settings.NEWWORLD => "--disj-new"
					| Settings.LIFO => "--disj-lifo"
					| Settings.FIFO => "--disj-fifo"
					| Settings.DEP => "--disj-dep"
					| Settings.OLDPEN => "--disj-old-pen"
					| Settings.NEWPEN => "--disj-new-pen"
					| Settings.PENOLD => "--disj-pen-old"
					| Settings.PENNEW => "--disj-pen-new"
					| _ => Exn.unexpected "CsvOutput.printSettingsList"
		  )
		^ ","
		^ (
			if !Settings.backjumpingDisabled
			then "--backjumping=off"
			else "--backjumping=on"
		  )
		^ ","
		^ (
			if !Settings.pbBlockingEnabled
			then
				if !Settings.fullBlocking
				then "--blocking=eager"
				else "--blocking=on"
			else "--blocking=off"
		  )
		^ ","
		^ (
			if !Settings.cachingEnabled
			then
				if !Settings.checkCacheOften
				then "--caching=eager"
				else "--caching=on"
			else "--caching=off"
		  )
		^ ","
		^ (
			if !Settings.bcpFullyEnabled
			then "--bcp=eager"
			else
				if !Settings.bcpEnabled
				then "--bcp=on"
				else "--bcp=off"
		  )
		^ ","
		^ (if !Settings.ecdDisabled then "--ecd=off" else "--ecd=on")
		^ ","
		^ (
			if !Settings.semanticBranchingEnabled
			then
				if !Settings.semanticBranchingNgl
				then "--db=ngl"
				else "--db=on"
			else "--db=off"
		  )
		^ ","
		^ "--lazy="
		^ (
			if !Settings.lazyBranching orelse !Settings.lazyWithBoxes orelse !Settings.lazyWithNominals
			then (
				  (if !Settings.lazyBranching then "prop" else "") ^ "+"
				^ (if !Settings.lazyWithBoxes then "box" else "") ^ "+"
				^ (if !Settings.lazyWithNominals then "nom" else "")
			)
			else "off"
		  )
		^ ","
		^ (
			case !Settings.pbbDatastructure
				of Settings.LISTS => "--blockingds=list"
				 | Settings.UBTREE => "--blockingds=tree"
				 | Settings.BITMATRIX => "--blockingds=matrix"
				 | _ => Exn.unexpected "Prover.printSettingsList: unexpected data structure for blocking."
		  )
		^ ","
		^ (
			case !Settings.cacheDatastructure
				of Settings.UBTREE => "--cachingds=tree"
				 | Settings.BITMATRIX => "--cachingds=matrix"
				 | Settings.SIZEBOUNDED n => "--cachingds=matrix:" ^ (Int.toString n)
				 | _ => Exn.unexpected "Prover.printSettingsList: unexpected data structure for caching."
		  )
		^ ","
		^ (
			if !Settings.dontMergeSuccLists
			then "--succ-exp"
			else "--succ-merge"
		  )
		^ ","
		^ (
			case !Settings.timeout
				of NONE => ""
				 | SOME t => "--timeout=" ^ (Time.toString t)
		  )
		^ ","
		^ (Int.toString (!Settings.tci))
		^ ","
	)
end
