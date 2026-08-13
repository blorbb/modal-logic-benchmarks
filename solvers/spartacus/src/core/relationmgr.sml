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


structure RelationMgr :> RELATIONMGR =
	struct
		val allReflexive = ref false
		val allTransitive = ref false
		val allSerial = ref false
		val allSymmetric = ref false
		
		val relations = ref (Binaryset.empty String.compare)
		
		val reflexive = ref (Binaryset.empty String.compare)
		val transitive = ref (Binaryset.empty String.compare)
		val serial = ref (Binaryset.empty String.compare)
		val symmetric = ref (Binaryset.empty String.compare)
		
		val subrelations = ref nil
		
		fun addRelation r = relations := (Binaryset.add (!relations, r))
		
		fun setReflexive r = reflexive := (Binaryset.add (!reflexive, r))
		fun setTransitive r = transitive := Binaryset.add (!transitive, r)
		fun setSerial r = serial := Binaryset.add (!serial, r)
		fun setSymmetric r = symmetric := (Binaryset.add (!symmetric, r))
		
		fun setAllReflexive () = allReflexive := true
		fun setAllTransitive () = allTransitive := true
		fun setAllSerial () = allSerial := true
		fun setAllSymmetric () = allSymmetric := true
		
		fun isReflexive r = !allReflexive orelse not (Binaryset.peek (!reflexive, r) = NONE)
		fun isTransitive r = !allTransitive orelse not (Binaryset.peek (!transitive, r) = NONE)
		fun isSerial r = !allSerial orelse not (Binaryset.peek (!serial, r) = NONE)
		fun isSymmetric r = !allSymmetric orelse not (Binaryset.peek (!symmetric, r) = NONE)
		
		fun listRelations () = Binaryset.listItems (!relations)
		
		fun listReflexive () = if !allReflexive then listRelations () else Binaryset.listItems (!reflexive)
		fun listTransitive () = if !allTransitive then listRelations () else Binaryset.listItems (!transitive)
		fun listSerial () = if !allSerial then listRelations () else Binaryset.listItems (!serial)
		fun listSymmetric () = if !allSymmetric then listRelations () else Binaryset.listItems (!symmetric)
		
		fun someReflexive () =
			not (Binaryset.isEmpty (!reflexive))
			orelse (!allReflexive andalso not (Binaryset.isEmpty (!relations)))
		fun someSymmetric () = 
			not (Binaryset.isEmpty (!symmetric))
			orelse (!allSymmetric andalso not (Binaryset.isEmpty (!relations)))
		
		fun setSubrelation (x (*as (sub, super)*)) = Ref.push subrelations x
		
		fun listSubrelations () = !subrelations
	end
