/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Skeleton interface for Bison GLR parsers in C

   Copyright (C) 2002-2015, 2018-2021 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 12 "parser.y"

#include "tree.h"
#include "symbol_table.h"
  
  extern tnode *root;
  extern tnode *create_tnode(int type, int id, int mdepth, tnode *left, tnode *right, formulalist *list);
  extern formulalist *tree_to_list(int type, tnode *left, tnode *right);

  //extern void print_tree(tnode *t);
  
  extern prop_node *find_prop (int id);
  extern prop_node *create_p_node (char *name, int id);
  extern agent_node *create_a_node (char *name, int id);

  extern agent_node *insert_a_node (char *name);
  extern prop_node *insert_p_node (char *name);
  extern prop_node *insert_p_position(prop_node *p, tnode *position);

  extern struct prop_node *propsname;
  extern struct prop_node *propsid;    /* important! initialize to NULL */
  extern struct agent_node *agentsname; 
  extern struct agent_node *agentsid;
  
  char *getBoxName (char *);

  /*  typedef struct axiom_list {
    int axiom;
    struct axiom_list *next;
  } axiom_list;
  */
  
  typedef struct prop_list {
    char *prop;
    struct prop_list *next;
  } prop_list;

  void process_ordering(prop_list *props);
  unsigned int process_axiom(char *name);

#line 84 "parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    TSET = 258,                    /* "set option command"  */
    TDOT = 259,                    /* "."  */
    TCOMMA = 260,                  /* ","  */
    TCLAUSES = 261,                /* "clauses"  */
    TFORMULAS = 262,               /* "formulas"  */
    TSOS = 263,                    /* "sos"  */
    TUSABLE = 264,                 /* "usable"  */
    TEND = 265,                    /* "end of list"  */
    TNAME = 266,                   /* "identifier"  */
    TNUMBER = 267,                 /* "number"  */
    TSTART = 268,                  /* "constant start"  */
    TTRUE = 269,                   /* "constant true"  */
    TFALSE = 270,                  /* "constant false"  */
    TIFF = 271,                    /* "double implication"  */
    TIMPLY = 272,                  /* "implication"  */
    TONLYIF = 273,                 /* "only if"  */
    TOR = 274,                     /* "disjunction"  */
    TAND = 275,                    /* "conjunction"  */
    TNOT = 276,                    /* "negation"  */
    TPOSSIBLE = 277,               /* "diamond operator"  */
    TNECESSARY = 278,              /* "box operator"  */
    TOBOX = 279,                   /* "box delimiter (open)"  */
    TODIA = 280,                   /* "diamond delimiter (open)"  */
    TCBOX = 281,                   /* "box delimiter (close)"  */
    TCDIA = 282,                   /* "diamond delimiter (close)"  */
    TLPAREN = 283,                 /* "("  */
    TRPAREN = 284                  /* ")"  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 157 "parser.y"

  char *strValue;
  tnode *tnode;
  formulalist *formulalist;
  unsigned int UIntValue;
  prop_list *prop_list;

#line 138 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif



int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
