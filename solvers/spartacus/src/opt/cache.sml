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


structure Cache :> CACHE =
	struct
		fun initialize n =
			case !Settings.cacheDatastructure
				of Settings.UBTREE => TreeCache.initialize n
				 | Settings.BITMATRIX => BitmatrixCache.initialize n
				 | Settings.SIZEBOUNDED b => BitmatrixCache.initialize n
				 | _ => Exn.unexpected "Cache.initialize: unexpected datastructure."
		
		
		fun rememberUnsat ks =
			case !Settings.cacheDatastructure
				of Settings.UBTREE => TreeCache.rememberUnsat ks
				 | Settings.BITMATRIX => BitmatrixCache.rememberUnsat ks
				 | Settings.SIZEBOUNDED _ => BitmatrixCache.rememberUnsat ks
				 | _ => Exn.unexpected "Cache.rememberUnsat: unexpected datastructure"
		
		
		fun isCachedUnsat ks =
			case !Settings.cacheDatastructure
				of Settings.UBTREE => TreeCache.isCachedUnsat ks
				 | Settings.BITMATRIX => BitmatrixCache.isCachedUnsat ks
				 | Settings.SIZEBOUNDED _ => BitmatrixCache.isCachedUnsat ks
				 | _ => Exn.unexpected "Cache.isCachedUnsat: unexpected datastructure"
		
		
		fun approxDependencies xs =
			case !Settings.cacheDatastructure
				of Settings.UBTREE => TreeCache.approxDependencies xs
				 | Settings.BITMATRIX => BitmatrixCache.approxDependencies xs
				 | Settings.SIZEBOUNDED _ => BitmatrixCache.approxDependencies xs
				 | _ => Exn.unexpected "Cache.isCachedUnsat: unexpected datastructure"
		
		
		fun getStats () =
			case !Settings.cacheDatastructure
				of Settings.UBTREE => TreeCache.getStats ()
				 | Settings.BITMATRIX => BitmatrixCache.getStats ()
				 | Settings.SIZEBOUNDED _ => BitmatrixCache.getStats ()
				 | _ => Exn.unexpected "Cache.getStats: unexpected datastructure"
	end
