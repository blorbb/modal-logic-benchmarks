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


signature NODESTORE =
	sig
		(*reset to empty*)
		val reset            : unit -> unit
		
		(*removes all nodes that have been created later than the given branching depth
		and calls the backtrack function for all other nodes;
		repropagates the diamonds that have to be repropagated according to the given list*)
		val backtrack        : int -> unit
		
		(*adds a new node at the given depth*)
		val addNode         : Node.node -> int -> unit
		
		(*addSuccessor w w' d adds w' as a new successor of w at depth d*)
		val addSuccessor     : Node.node -> Term.relvar -> Node.node -> int -> unit
		
		val peekNode         : int -> Node.node option
		
		val getNode         : int -> Node.node
		
		val propagateTo      : Term.nominal -> int -> (Term.index * Dependency.depcy) -> unit
		
		val setEqual         : int -> int -> (Term.nominal * Dependency.depcy) -> unit
		
		(*returns a list of successors of the given node*)
		val listSuccessors   : Node.node -> Term.relvar -> Node.node list
		
		(*lists all nodes contained in the store*)
		val listNodes       : unit -> Node.node list
		
		val findPattern      : Term.index list -> Node.node option
		
		val toString         : unit -> string
		
		val toOutputList     : unit -> (Node.node * string) list
		
		val toDot            : unit -> string
	end
