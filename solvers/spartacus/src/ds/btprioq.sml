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


structure BtprioQ :> BTPRIOQ =
	struct
		datatype 'a queue = Q of ('a, int) Binarymap.dict * (int, 'a list) Binarymap.dict * ('a * 'a -> order)
		
		exception Empty
		
		exception NotFound
		
		fun mkQueue ord = Q (Binarymap.mkDict ord, Binarymap.mkDict Int.compare, ord)
		
		fun backtrack (x as (Q (q, inv, _))) d =
			let
				exception Result of 'a queue
				
				fun ff (d', xs, Q (q', inv', ord)) =
					if d' > d
					then
						let
							val q'' = foldl (fn (a, b) => #1 (Binarymap.remove (b, a))) q' xs
							
							val inv'' = #1 (Binarymap.remove (inv', d'))
						in
							Q (q'', inv'', ord)
						end
					else raise Result (Q (q', inv', ord))
			in
				Binarymap.foldr ff x inv
				handle Result y => y
			end
		
		fun isEmpty (Q (q, _, _)) =
			let
				exception Nonempty
			in
				(Binarymap.app (fn _ => raise Nonempty) q; true) handle Nonempty => false
			end
		
		fun numItems (Q (q, _, _)) = Binarymap.numItems q
		
		fun listItems (Q (q, _, _)) = map #1 (Binarymap.listItems q)
		
		fun insert (x as (Q (q, inv, ord)), a, d) =
			let
			in
				case Binarymap.peek (q, a)
					of NONE =>
						let
							val inv' =
								case Binarymap.peek (inv, d)
									of NONE => Binarymap.insert (inv, d, [a])
									 | SOME xs => Binarymap.insert (inv, d, a::xs)
							
							val q' = Binarymap.insert (q, a, d)
						in
							Q (q', inv', ord)
						end
					|  SOME d' =>
						if d' > d
						then
							let
								val inv' = Binarymap.insert (inv, d', List.filter (fn x => ord (x, a) <> EQUAL) (Binarymap.find (inv, d')))
								
								val inv'' = case Binarymap.peek (inv, d)
									of NONE => Binarymap.insert (inv, d, [a])
									 | SOME xs => Binarymap.insert (inv, d, a::xs)
								
								val q' = Binarymap.insert (q, a, d)
							in
								Q (q', inv'', ord)
							end
						else x
			end
		
		
		fun remove (x as (Q (q, inv, ord)), a) =
			let
				val (q', d') = Binarymap.remove (q, a)
				
				val (a', inv') = case List.partition (fn x => ord (x,a) = EQUAL) (Binarymap.find (inv, d'))
					of ([a'], xs) => (a', Binarymap.insert (inv, d', xs))
						| _ => Exn.unexpected "BtprioQ.remove"
			in
				(Q (q', inv', ord), SOME (a', d'))
			end
			handle Binarymap.NotFound => (x, NONE)
		
		
		fun peek (Q (q, _, _)) =
			let
				exception Found of 'a
			in
				Binarymap.foldl (fn (a, _, _) => raise Found a) (fn () => raise Empty) q ()
				handle Found a => a
			end
		
		fun pop (Q (q, inv, ord)) =
			let
				exception Found of 'a
			in
				Binarymap.foldl (fn (a, _, _) => raise Found a) (fn () => raise Empty) q ()
				handle Found a =>
					let
						val (q', d) = Binarymap.remove (q, a)
						
						val inv' = Binarymap.insert (inv, d, List.filter (fn x => ord (x, a) <> EQUAL) (Binarymap.find (inv, d)))
					in
						(Q (q', inv', ord), a)
					end
			end
		
		fun find f (Q (q, _, _)) =
			let
				exception Found of 'a
			in
				Binarymap.foldl (fn (a, _, _) => if f a then raise Found a else (fn () => raise NotFound)) (fn () => raise Empty) q ()
				handle Found a =>
					(
					  (
						fn Q (q, inv, ord) =>
							let
								val (q', d) = Binarymap.remove (q, a)
								
								val inv' = Binarymap.insert (inv, d, List.filter (fn x => ord (x, a) <> EQUAL) (Binarymap.find (inv, d)))
							in
								Q (q', inv', ord)
							end
					  )
					, a
					)
			end
	end
