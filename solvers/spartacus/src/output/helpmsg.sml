(*****************************************************************************
 *  Authors:
 *    Daniel N. Goetzmann <dngoetzmann@googlemail.com>
 *    Mark Kaminski <kaminski@ps.uni-saarland.de>
 *
 *  Copyright:
 *     Daniel N. Goetzmann, 2009
 *     Mark Kaminski, 2010
 *
 *  Last modified:
 *    $Date: 2010-04-29 $
 *    $Author: kaminski $
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


structure HelpMsg =
struct
exception Help

val helpMsg =
	  "Usage: spartacus [OPTIONS]...\n"
	^ "\nInput:\n"
	^ "--formula=FORMULA         use the given FORMULA as input\n"
	^ "--file=FILE               read formula from FILE\n"
	^ "--dfgFile=FILE            read formula in dfg-ascii format from FILE\n"
	^ "--dimacsFile=FILE         read formula in DIMACS format from FILE\n"
	^ "--krssFile=FILE           read formula in KRSS format from FILE\n"
	^ "--factFile=FILE           read formula in FaCT format from FILE\n"
	^ "--intohyloFile=FILE       read formula in InToHyLo format from FILE\n"
	^ "--ksatcFile=FILE          read formula in KSatC format from FILE\n"
	^ "--ksatlFile=FILE          read formula in KSatLisp format from FILE\n"
	^ "--lwbFile=FILE            read formula in LWB format from FILE\n"
	^ "--tancsFile=FILE          read formula in TANCS format from FILE\n"
	^ "--index=n                 run the prover on the nth formula\n"
	^ "                          (e.g. when using an LWB file as input)\n"
	^ "--negate                  run spartacus on the negation of the given formula\n"
	^ "--checksat=c1,c2,...,cn   check satisfiability of atomic DL-concepts\n"
	^ "                          c1,c2,...,cn\n"
	^ "--checksat=*              check satisfiability of all atomic DL-concepts\n"
	^ "--cse                     do not reuse blocking information when running\n"
	^ "                          --checksat with more than one concept name\n"
	^ "                          (or with *)\n"
	^ "--reflexive               handle relations as reflexive\n"
	^ "--transitive              handle relations as transitive\n"
	^ "--serial                  handle relations as serial\n"
	^ "--iff-conj                represent s<->t as (~s|t)&(s|~t)\n"
	^ "--iff-disj                represent s<->t as (s&t)|(~s&~t)\n"
	^ "--iff-auto                represent s<->t as (~s|t)&(s|~t) if s or t is a\n"
	^ "                          prop. literal, (s&t)|(~s&~t) otherwise (default)\n"
	^ "--dc-conj                 represent (define-concept s t) as (~s|t)&(s|~t)\n"
	^ "--dc-disj                 represent (define-concept s t) as (s&t)|(~s&~t)\n"
	^ "--dc-norm                 represent (define-concept s t) as s<->t\n"
	^ "                          according to --iff-* option (default)\n"
	^ "\nPredefined configuration profile:\n"
	^ "--profile=FILE            use options as specified in FILE\n"
	^ "\nOrder:\n"
	^ "--exp-ord=S               order in which rules are applied.\n"
	^ "                          S is a string containing\n"
	^ "                              n (nominals), N (negated nominals),\n"
	^ "                              < (diamonds), [ (boxes),\n"
	^ "                              A (universal modalities),\n"
	^ "                              E (existential modalities),\n"
	^ "                              @ (satisfaction ops.), | (disjunctions).\n"
	^ "                          If x occurs before y in S, the rule for x\n"
	^ "                          will be applied before the rule for y.\n"
	^ "--disj-ord=S              order in which disjuncts are processed.\n"
	^ "                          S is a string containing\n"
	^ "                              p (propositions), n (nominals),\n"
	^ "                              N (negated nominals), < (diamonds),\n"
	^ "                              [ (boxes), A (universal modalities),\n"
	^ "                              E (existential modalities),\n"
	^ "                              @ (satisfaction ops.), & (conjunctions).\n"
	^ "                          If x occurs before y in S, disjuncts of type\n"
	^ "                          x will be considered before terms of type y.\n"
	^ "--dia-old                 higher precedence to diamonds on old nodes\n"
	^ "--dia-new                 higher precedence to diamonds on new nodes (default)\n"
	^ "--dia-lifo                higher precedence to (globally) new diamonds\n"
	^ "--dia-fifo                higher precedence to (globally) old diamonds\n"
	^ "--dia-dep                 higher precedence to diamonds whose dependency set\n"
	^ "                          contain less recent branching points\n"
	^ "--dia-car-new             higher precedence to diamonds with larger patterns\n"
	^ "                          (tie broken with --dia-new)\n"
	^ "--dia-car-old             higher precedence to diamonds with larger patterns\n"
	^ "                          (tie broken with --dia-old)\n"
	^ "--disj-old                higher precedence to disjunctions on old nodes\n"
	^ "                          (default)\n"
	^ "--disj-new                higher precedence to disjunctions on new nodes\n"
	^ "--disj-lifo               higher precedence to (globally) new disjunctions\n"
	^ "--disj-fifo               higher precedence to (globally) old disjunctions\n"
	^ "--disj-dep                higher precedence to disjunctions whose dependency\n"
	^ "                          sets contain less recent branching points\n"
	^ "--disj-old-pen            higher precedence to disjunctions on old nodes\n"
	^ "                          (tie broken with --disj-pen-old)\n"
	^ "--disj-new-pen            higher precedence to disjunctions on new nodes\n"
	^ "                          (tie broken with --disj-pen-new)\n"
	^ "--disj-pen-old            higher precedence to disjunctions that cause more\n"  
	^ "                          clashes (tie broken with --disj-old)\n"
	^ "--disj-pen-new            higher precedence to disjunctions that cause more\n"  
	^ "                          clashes (tie broken with --disj-new)\n"
	^ "\nOptimizations and Blocking:\n"
	^ "--backjumping=[off|on]    turn backjumping off/on (default: on)\n"
	^ "--blocking=[off|on|eager] turn pattern-based blocking off/on/on including\n"
	^ "                          new boxes (default: eager)\n"
	^ "--caching=[off|on|eager]  turn caching off/on/on with additional cache\n"
	^ "                          queries when propagating (default: off)\n"
	^ "--bcp=[off|on|eager]      turn boolean constraint propagation off/\n"
	^ "                          on considering only next disjunction/\n"
	^ "                          on searching for disjunctions (default: eager)\n"
	^ "--ecd=[off|on]            turn early conflict detection off/on (default: on)\n"
	^ "--db=[off|on|ngl]         turn disjoint branching off/on/\n"
	^ "                          use no good lists only(default: on)\n"
	^ "--lazy=[off|on            turn lazy branching off/on (default: on)\n"
	^ "       |prop|box|nom      propos./box/nominal variants of lazy branching only\n"
	^ "       |prop+box|...]     combination of variants of lazy branching\n"
	^ "\nData structures:\n"
	^ "--blockingds=[list|tree   use list-based/tree-based/bitmatrix-based data\n"
	^ "             |matrix]     structure for pattern-based blocking (default: tree)\n"
	^ "--cachingds=[tree|matrix] use tree-based/bit-matrix-based d.s. for caching\n"
	^ "                          (default: tree)\n"
	^ "--cachingds=matrix:N      use size-bounded bit-matrix-based data structure\n"
	^ "                          for caching with size bound N\n"
	^ "\nOutput:\n"
	^ "--showModel               print a model if the formula is satisfiable\n"
	^ "--dotFile=FILE            save a model in dot format to FILE\n"
	^ "--dmv                     print a detailed view for each node in the model\n"
	^ "--snc                     show negative constraints in output\n"
	^ "--debug                   print debug output\n"
	^ "--csv                     output as comma-separated list\n"
	^ "--csvheader               output a header showing the columns of csv output\n"
	^ "\nTimeout:\n"
	^ "--timeout=n               run for at most n seconds\n"
	^ "--tci=n                   check timeout after every n rule applications\n"
	^ "                          (default: 1000)\n"
	
fun printHelpMsg () = print helpMsg
end
