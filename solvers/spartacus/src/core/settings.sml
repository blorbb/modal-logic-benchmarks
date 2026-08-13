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


structure Settings =
struct
datatype ds = BITMATRIX | LISTS | UBTREE | SIZEBOUNDED of int
datatype exporder = OLDWORLD | NEWWORLD | LIFO | FIFO | DEP | PENOLD | PENNEW | NEWPEN | OLDPEN | CARNEW | CAROLD
datatype inputFormat = NOINPUT | ARG | NAT | LWB | KSATC | ALC | INTOHYLO | DIMACS | DFG | KRSS | TANCS | OWLFS
datatype dcRepr = DCRNORM | DCRCONJ | DCRDISJ

val format = ref NOINPUT

val formula = ref "1"

val fileName = ref ""

val index = ref 1

val dotFileName = ref NONE : string option ref

val negate = ref false

val showModel = ref false

val cachingEnabled = ref false

val checkCacheOften = ref false

val pbBlockingEnabled = ref true

val fullBlocking = ref true

val ecdDisabled = ref false

val backjumpingDisabled = ref false
	
val bcpEnabled = ref true

val bcpFullyEnabled = ref true

val showNegativeConstraints = ref false

val detailedModelView = ref false

val timeout = ref NONE : Time.time option ref

val diaExpOrder = ref NEWWORLD

val disjExpOrder = ref OLDWORLD

val semanticBranchingEnabled = ref true

val semanticBranchingNgl = ref false

val pbbDatastructure = ref UBTREE

val cacheDatastructure = ref UBTREE

val csv = ref false

val lazyBranching = ref true

val lazyWithBoxes = ref true

val lazyWithNominals = ref true

val diadisjdep = ref false

val checksat = ref nil : string list ref

val penalizeDisjunctions = ref false

val cse = ref false

val dontMergeSuccLists = ref true

val dcRepresentation = ref DCRNORM

val tci = ref 1000
end
