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


structure AlcParser =
	struct
		structure AlcLrVals =
			AlcLrValsFun (structure Token = LrParser.Token)
		structure AlcLex =
			AlcLexFun (structure Tokens = AlcLrVals.Tokens)
		structure AlcParser =
			Join (
				structure LrParser = LrParser
				structure ParserData = AlcLrVals.ParserData
				structure Lex = AlcLex
			)

		val invoke =
			fn lexstream =>
				let
					exception Error
					
					val raise_error =
						fn (s, i : int, _) => (
							print ("Error, line " ^ (Int.toString i) ^ ", " ^ s ^ "\n");
							raise Error
						)
				in
					AlcParser.parse (0, lexstream, raise_error, ())
				end

		fun parseStream s =
			let
				exception Result of Parsetree.parsetree
				
				val lexer = AlcParser.makeLexer (fn _ => Util.inputLine s)
				val dummyEOF = AlcLrVals.Tokens.EOF (0, 0)
				
				fun loop lexer =
					let
						val (result, lexer) = invoke lexer
						val (nextToken, lexer) = AlcParser.Stream.get lexer
						
						val _ = raise Result result
					in
						if AlcParser.sameToken (nextToken, dummyEOF)
						then NONE
						else loop lexer
					end
				in
					loop lexer
					handle Result r => SOME r
				end

		fun parse f = parseStream (TextIO.openIn f)
	end
