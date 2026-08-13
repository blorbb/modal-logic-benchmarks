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


structure ModelOutput =
struct
fun printModel () =
	if !Settings.pbBlockingEnabled
	then
		let
			val xs = Nodestore.toOutputList ()
			
			fun getBlocked w =
				case BlockingMgr.listBlockedSuccessors w
					of nil => ""
					|  xs => (
						  "blocked:      "
						^ (
							Util.listToString
								(fn (r, w) => r ^ ":" ^ (Int.toString (Node.getId w)))
								(Listsort.sort
									(fn ((r1, w1), (r2, w2)) =>
										Util.compare [
											  fn () => String.compare (r1, r2)
											, fn () => Int.compare (Node.getId w1, Node.getId w2)
										]
									)
									xs
								)
						  )
						^ "\n"
						)
			
			fun af (w, s) = (
				print (
					  s
					^ (getBlocked w)
					^ "------------------------------------------------------------\n"))
		in
			print (
				  "--MODEL-----------------------------------------------------\n"
				^ (case length xs of 1 => "1 node\n" | n => (Int.toString n) ^ " nodes\n")
				^ "------------------------------------------------------------\n"
			)
			; app af xs
		end
	else print (Nodestore.toString ())

fun writeDot f =
	let
		val file = TextIO.openOut f
		
		val _ = TextIO.output (file, "digraph Model {\n")
	in
		if !Settings.pbBlockingEnabled
		then
			let
				fun getBlocked w =
					case BlockingMgr.listBlockedSuccessors w
						of nil => ""
						 | ws =>
							concat (
								List.map
									(fn (r, w') => (
										  Int.toString (Node.getId w))
										^ " -> "
										^ (Int.toString (Node.getId (w')))
										^ "[label=\" "
										^ r
										^ " \", style=dashed];\n"
									)
								ws
							)
				
				fun af w = TextIO.output (file, getBlocked w)
			in
				  TextIO.output (file, Nodestore.toDot ())
				; app af (Nodestore.listNodes ())
			end
		else TextIO.output (file, Nodestore.toDot ())
		; TextIO.output (file, "}\n")
		; TextIO.closeOut file
	end
	handle _ => print ("Unable to write model to file " ^ (Option.valOf (!Settings.dotFileName)) ^ "\n")
end
