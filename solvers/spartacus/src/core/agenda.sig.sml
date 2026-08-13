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


signature AGENDA =
	sig
		datatype action =
				  DIAMOND of int * Term.index * Dependency.depcy * int
				| BOX of int * Term.index * Dependency.depcy
				| BRANCH of int * Term.index * Dependency.depcy * int
				| AT of string * Term.index * Dependency.depcy
				| EQ of int * string * Dependency.depcy
				| UNIV of Term.index * Dependency.depcy
				| EXIST of Term.index * Dependency.depcy
		
		exception Empty
		
		exception Bcp
		
		val initialize : unit -> unit
		
		val backtrack : int -> unit
		
		val insert : (action * int) -> unit
		
		val insertX : (action * int) -> unit
		
		val isEmpty : unit -> bool
		
		val pop : int -> action
		
		val setBcpFunction : (action -> bool) -> unit
		
		val setOrder : string -> unit
		
		val getOrder : unit -> string
		
		val toString : unit -> string
	end
