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


signature RELATIONMGR =
	sig
		val addRelation      : string -> unit
		
		val setAllReflexive  : unit -> unit
		val setAllTransitive : unit -> unit
		val setAllSerial     : unit -> unit
		val setAllSymmetric  : unit -> unit
		
		val setReflexive     : string -> unit
		val setTransitive    : string -> unit
		val setSerial        : string -> unit
		val setSymmetric     : string -> unit
		
		val isReflexive      : string -> bool
		val isTransitive     : string -> bool
		val isSerial         : string -> bool
		val isSymmetric      : string -> bool
		
		val listRelations    : unit -> string list
		
		val listReflexive    : unit -> string list
		val listTransitive   : unit -> string list
		val listSerial       : unit -> string list
		val listSymmetric    : unit -> string list
		
		val someReflexive    : unit -> bool
		val someSymmetric    : unit -> bool
		
		val setSubrelation   : string * string -> unit
		val listSubrelations : unit -> (string * string) list
	end
