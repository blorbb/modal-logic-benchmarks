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
 *    $Date: 2010-04-28 $
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


signature NODE =
	sig
		type node
		
		exception Unsat of node * Dependency.depcy list
		exception CachedUnsat of node * Dependency.depcy list
		
		exception Satisfied
		
		val reset                 : unit -> unit
		val newNode               : int -> int option -> Term.index * Dependency.depcy -> node
		val getId                 : node -> int
		val peekPredId            : node -> int option
		val propagate             : node -> int -> (Term.index * Dependency.depcy) list -> unit
		val addNominalDepcy       : node -> int -> Dependency.depcy -> unit
		val blockDiamond          : node -> int -> Term.index -> unit
		val unblockDiamonds       : node -> ((Term.index * int) -> bool) -> unit
		val listBlockedDiamonds   : node -> Term.index list
		val bcp                   : node -> Term.Catstore.catstore -> (Term.Catstore.catstore * Dependency.depcy list)
		val listBranchPoints      : node -> int list
		val propagateDisjunct     : node -> (Term.index * Dependency.depcy * Term.index list * bool) -> unit
		val getPattern            : node -> (Term.index * Dependency.depcy) list
		val listBoxes             : node -> (Term.index * Dependency.depcy) list
		val listPropositions      : node -> (Term.propvar * bool) list
		val listNominals          : node -> (Term.nominal * bool) list
		val mergeInto             : node -> int -> node -> Dependency.depcy -> unit
		val backtrack             : node -> int -> unit
		val toString              : node -> string
		val peekDisjDepcy         : node -> int -> Dependency.depcy option
		val peekBoxDepcy          : node -> int -> Dependency.depcy option
		val peekDmndDepcy         : node -> int -> Dependency.depcy option
	end
