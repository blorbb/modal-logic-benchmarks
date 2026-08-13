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


structure Patternstore :> PATTERNSTORE =
	struct
		datatype store = LPS of ListPatternstore.store | TPS of TreePatternstore.store | BPS of BitmatrixPatternstore.store
		
		fun mkStore n =
			case !Settings.pbbDatastructure
				of Settings.LISTS => LPS (ListPatternstore.mkStore n)
				 | Settings.UBTREE => TPS (TreePatternstore.mkStore n)
				 | Settings.BITMATRIX => BPS (BitmatrixPatternstore.mkStore n)
				 | _ => Exn.unexpArg "Patternstore.mkStore"
		
		fun backtrack (LPS s) = ListPatternstore.backtrack s
		  | backtrack (TPS s) = TreePatternstore.backtrack s
		  | backtrack (BPS s) = BitmatrixPatternstore.backtrack s
		
		
		fun add (LPS s) = ListPatternstore.add s
		  | add (TPS s) = TreePatternstore.add s
		  | add (BPS s) = BitmatrixPatternstore.add s
		
		
		fun hasMatch (LPS s) = ListPatternstore.hasMatch s
		  | hasMatch (TPS s) = TreePatternstore.hasMatch s
		  | hasMatch (BPS s) = BitmatrixPatternstore.hasMatch s
	end
