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


signature DICT =
	sig
		type 'a dict
		
		exception NotFound
		exception Empty
		
		val empty      : unit -> 'a dict
		val clear      : 'a dict -> unit
		val insert     : 'a dict * int * 'a -> unit
		val get        : 'a dict * int -> 'a
		val peek       : 'a dict * int -> 'a option
		val remove     : 'a dict * int -> 'a
		val isEmpty    : 'a dict -> bool
		val numItems   : 'a dict -> int
		val listItems  : 'a dict -> (int * 'a) list
		val app        : (int * 'a -> unit) -> 'a dict -> unit
		val foldr      : (int * 'a * 'b -> 'b)-> 'b -> 'a dict -> 'b
		val foldl      : (int * 'a * 'b -> 'b) -> 'b -> 'a dict -> 'b
		val modify     : (int * 'a -> 'a) -> 'a dict -> unit
		val modifyo    : (int * 'a -> 'a option) -> 'a dict -> unit
		val modifyItem : ('a -> 'a) -> ('a dict * int) -> unit
		val min        : 'a dict -> (int * 'a)
		val max        : 'a dict -> (int * 'a)
		val find       : (int * 'a -> bool) -> 'a dict -> (int * 'a) option
		val revfind    : (int * 'a -> bool) -> 'a dict -> (int * 'a) option
		val filter     : (int * 'a -> bool) -> 'a dict -> unit
	end
