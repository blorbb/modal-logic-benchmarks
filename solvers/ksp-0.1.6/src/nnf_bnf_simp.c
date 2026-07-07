#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "prover.h"
#include "symbol_table.h"
#include "tree.h"

extern int debug;

extern int numsimp;
extern int bnfsimp;
extern int logsimp;
extern int formulasize;
extern int verbose;

extern agent_node *find_agent (int id);

extern tnode *create_tnode(int type, int id, int mdepth, tnode *left, tnode *right, formulalist *list);
extern void copy_node(tnode *t1, tnode *t2);
extern agent_node *find_agent(int id);
extern prop_node *find_prop (int id);
extern prop_node *insert_p_position(prop_node *p, tnode *position);

extern tnode *copy_tree(tnode *s);
extern tnode *free_tree (tnode *s);
extern formulalist *free_formulalist(formulalist *s);
extern void sort_formulalist(int type, formulalist **l);
extern int is_diamond (tnode *t);

extern int print_list(formulalist *);
extern int print_tree(tnode *);

extern int size_tree(tnode *s);
extern int size_list(formulalist *s);

extern unsigned int hash_tree (tnode *t);
extern unsigned int hash_list (formulalist *l);

extern tnode *remove_size_one_list(tnode *s);
extern formulalist *flatten_by_type(int type, formulalist *s);
  
tnode *get_nnfsimp (tnode *s);

int same_tree (tnode *t1, tnode *t2);
int same_list(formulalist *l1, formulalist *l2) {
  if (l1 == NULL) {
    if (l2 == NULL) {
      return 1;
    }
  }
  else if (l2 == NULL) 
    return 0;
  else if (same_tree(l1->formula,l2->formula))
    return (same_list(l1->next,l2->next));
  return 0;
}

int same_tree (tnode *t1, tnode *t2) {
  if (t1 == NULL) {
    if (t2 == NULL) {
      return 1;
    }
  }
  else if (t2 == NULL) 
    return 0;
  else if (t1->type == t2->type && t1->id == t2->id && same_list(t1->list,t2->list))
    return (same_tree(t1->left,t2->left) && same_tree(t1->right,t2->right));
  return 0;
}



int in (tnode *t1, formulalist *l) {
  while (l != NULL) {
    if (t1->value_number == l->formula->value_number && same_tree(t1,l->formula))
      return 1;
    else l = l->next;
  }
  return 0;
}

int in_neg (tnode *t1, formulalist *l) {
  int result = 0;
  
  if (t1->type == NEGATION) {
    result = in(t1->left,l);
  }
  else {
    tnode *parent = t1->parent;
    tnode *aux = create_tnode(NEGATION,NEGATION,t1->mdepth,t1,NULL,NULL);
    result = in(aux,l);
    t1->parent = parent;
    free(aux);
  }
  return result;
}

// t1 = box phi
// aux = ~phi
// it checks if box aux is in l

int in_neg_box(tnode *t1, formulalist *l) {
  int result = 0;
  int flag = 0;
  tnode *aux = NULL;
  if (t1->left->type == NEGATION) {
    aux = t1->left->left;
  }
  else {
    aux = create_tnode(NEGATION,NEGATION,t1->left->mdepth,t1->left,NULL,NULL);
    flag = 1;
  }
  while (l != NULL && result == 0) {
    if (l->formula->type == BOX && l->formula->id == t1->id) {
      if (aux->value_number == l->formula->left->value_number && same_tree(aux,l->formula->left)) {
	  result = 1;
	}
    }
    l = l->next;
  }
  if (flag) {
    free(aux);
    t1->left->parent = t1;
  }
  return result;
}

// t1 is ~box phi or dia phi
// aux is ~phi
// search for ~box~phi in l
int in_neg_dia(tnode *t1, formulalist *l) {
  int result = 0;
  int flag = 0;
  int id = is_diamond(t1);
  tnode *parent;
  tnode *aux = NULL;
  if (t1->type == NEGATION && t1->left->left->type == NEGATION ) //~box ~phi ==> aux = phi
    aux = t1->left->left->left;  
  else if (t1->type == NEGATION) {//~box phi ==> aux = ~phi
    aux = create_tnode(NEGATION,NEGATION,t1->left->left->mdepth,t1->left->left,NULL,NULL);
    flag = 1;
    parent = t1->left;
  }
  else if (t1->type == DIAMOND && t1->left->type == NEGATION) // dia ~phi ==> aux = phi
    aux = t1->left->left;
  else { // dia phi ==> aux = ~phi
    aux = create_tnode(NEGATION,NEGATION,t1->left->mdepth,t1->left,NULL,NULL);
    flag = 2;
    parent = t1;
  }
  
  while (l != NULL && result == 0) {
    int id2;
    if ((id2 = is_diamond(l->formula)) && id == id2) {
      tnode *aux2 = NULL;
      if (l->formula->type == NEGATION) {
	aux2 = l->formula->left->left;
      }
      else aux2 = l->formula->left;
      if (aux->value_number == aux2->value_number && same_tree(aux,aux2)) {
	  result = 1;
	}
    }
    l = l->next;
  }
  if (flag) {
    free(aux);
    if (flag == 1) t1->left->left->parent = parent;
    if (flag == 2) t1->left->parent = parent;
  }
  return result;
}

extern int compare_formula_nnf(tnode *t1, tnode *t2);
formulalist *propagate_in_conjunction_or_disjunction(int type, tnode *formula, formulalist *l) {
  return l;

  if (l == NULL) {
    return l;
  }
  else {
    l->next = propagate_in_conjunction_or_disjunction(type,formula,l->next);
    if (l->formula->type == type) {
      formulalist *aux = l->formula->list;
      formulalist *first = NULL;
      while (aux != NULL && (compare_formula_nnf(aux->formula,formula))) {
	if (!(same_tree(formula,aux->formula))) {
	  formulalist *new = malloc(sizeof(formulalist));
	  new->formula = aux->formula;
	  new->next = first;
	  first = new;
	}
	else {
	  int size = 0;
	  if (verbose)
	     size = size_tree(aux->formula);
	  free_tree(aux->formula);
	  numsimp++;
	  formulasize = formulasize - size;
	}
	formulalist *tmp = aux;
	aux = aux->next;
	free(tmp);
      }
      if (aux != NULL) {
	while (aux != NULL) {
	  formulalist *new = malloc(sizeof(formulalist));
	  new->formula = aux->formula;
	  new->next = first;
	  first = new;
	  aux = aux->next;
	}
      }
      if (first != NULL) {
	sort_formulalist(type,&first);
	l->formula->list = first;
      }
      else {
	l->formula->type = CONSTANT;
	l->formula->left = NULL;
	l->formula->right = NULL;
	l->formula->list = NULL;
	if (type == CONJUNCTION) {
	  l->formula->id = CTRUE;
	}
	else l->formula->id = CFALSE;
	l->formula->value_number = hash_tree(l->formula);
      }
    }
  }

  sort_formulalist(type,&(l));
  if (l != NULL) {
    l->value_number = hash_list(l);
  }
  return l;
}
  

formulalist *in_conjunction_or_disjunction(int type, tnode *formula, formulalist *l) {
  return l;
  if (l == NULL) {
    return l;
  }
  else {
    l->next = in_conjunction_or_disjunction(type,formula,l->next);
    if (l->formula->type == type && (in(formula,l->formula->list))) {
      int size = 0;
      if (verbose)
	size_list(l->formula->list);
      l->formula->list = free_formulalist(l->formula->list);
      free(l->formula);
      formulalist *tmp = l;
      l = l->next;
      free(tmp);
      numsimp++;
      formulasize = formulasize - size;
    }
    else if (l->formula->type == type && formula->type == type) {
      int in_formula = 1;
      formulalist *aux = formula->list;
      while (in_formula && aux != NULL) {
	in_formula = in(aux->formula,l->formula->list);
	aux = aux->next;
      }
      if (in_formula) {
	int size = size_list(l->formula->list);
	free_formulalist(l->formula->list);
	free(l->formula);
	formulalist *tmp = l;
	l = l->next;
	free(tmp);
	numsimp = numsimp + size;
	formulasize = formulasize - size;
      }
    }
  }

  sort_formulalist(type,&(l));
  if (l != NULL) {
    l->value_number = hash_list(l);
  }
  return l;
}

int in_diamond(formulalist *l, int id) {
  int result = 0;
  int dia_id;
  while (l != NULL && !result) {
    if ((dia_id = is_diamond(l->formula)) && dia_id == id)
      result = 1;
    l = l->next;
  }
  return result;
}

int in_diamond_true (formulalist *l, int id) {
  int result = 0;
  int dia_id;
  while (l != NULL && !result) {
    if ((dia_id = is_diamond(l->formula)) && dia_id == id)
      if ((l->formula->type == NEGATION && l->formula->left->left->type == CONSTANT && l->formula->left->left->id == CFALSE) ||
	  (l->formula->left->type == CONSTANT && l->formula->left->id == CTRUE))
      result = 1;
    l = l->next;
  }
  return result;
}

int check_prefix(tnode *s, int id, int n, int type,...) {
  va_list va;
  int i = 0;
  int flag = 1;
  va_start(va,type);
  while (flag && (i < n) && (s != NULL) && (s->id == id)) {
    if (s->type != type) flag = 0;
    type = va_arg(va,int);
    s=s->left;
    i++;}
  va_end(va);
  if (i == n && flag) return 1; else return 0;
}

tnode *get_logsimp(tnode *s) { // note this should be a box or a diamond, so we can get the agent from it
  if (s->type != BOX || s->type != DIAMOND)
    return s;
  else {
    agent_node *a = find_agent(s->id);
    if (a->axioms & FIVE) {
      if (check_prefix(s, a->id, 4, BOX, DIAMOND, BOX, DIAMOND) ||
	  check_prefix(s, a->id, 4, DIAMOND, BOX, DIAMOND, BOX)) { // []<>[]<> ==> []<> or <>[]<>[] = <>[]
	tnode *aux = s->left;
	s->left = s->left->left->left;
	s->left->parent = s;
	hash_tree(s);
	free(aux->left);
	free(aux);
	return get_logsimp(s);
      }
      if (check_prefix(s, a->id, 2, BOX, BOX) ||
	  check_prefix(s, a->id, 2, DIAMOND, DIAMOND)) { // [][] ==> [] or <><> = <>
	tnode *aux = s->left;
	s->left = s->left->left;
	s->left->parent = s;
	hash_tree(s);
	free(aux);
	return get_logsimp(s);
      }
    }
  }
  return s;
}

formulalist *simplify_and (formulalist *s) {

  sort_formulalist(CONJUNCTION,&(s));
  if (debug) {  printf("\n Begining: simplify_and:\n");print_list(s);}
  int id;
  if (s != NULL) {
    if (s->formula->type == CONJUNCTION) {
      s = flatten_by_type(CONJUNCTION,s);
      s->value_number = hash_list(s);
      s = simplify_and(s);
      formulasize = formulasize - 1;
    }
    else {
      if (s->formula->type == CONSTANT) {
	if (s->formula->id == CFALSE) {
	  int size = 0;
	  if (verbose)
	    size = size_list(s->next);
	  s->next = free_formulalist(s->next);
	  s->next = NULL;
	  numsimp++;
	  if (debug) printf("\n and false");
	  formulasize = formulasize - size - 1; // formulae + conjunction
	}
	else if (s->formula->id == CTRUE) {
	  if (s->next != NULL) {
	    s->formula = free_tree(s->formula);
	    formulalist *aux = s->next;
	    free(s);
	    s = aux;
	    numsimp++;
	    if (debug)  printf("\n and true");
	    s = simplify_and(s);
	    formulasize = formulasize - 2; //symbol + conjunction
	  }
	}
      }
      else if (s->next != NULL) {
	s->next = simplify_and(s->next); // NEED TO GO BACK TO THESE FIRST TWO CONDITIONS
	if (s->next->formula->type == CONSTANT) {
	  if (s->next->formula->id == CFALSE) {
	    int size = 0;
	    if (verbose)
	      size = size_tree(s->formula);
	    s->formula = free_tree(s->formula);
	    formulalist *aux = s;
	    s = s->next;
	    s->next = free_formulalist(s->next);
	    free(aux);
	    numsimp++;
	    if (debug) printf("\n and false, next");
	    formulasize = formulasize - size - 1;
	  }
	  else if (s->next->formula->id == CTRUE) {
	    s->next->formula = free_tree(s->next->formula);
	    formulalist *aux = s->next->next;
	    free(s->next);
	    s->next = aux;
	    numsimp++;
	    if (debug) printf("\n and true, next");
	    formulasize = formulasize - 2; //symbol + conjunction
	  }
	}
	else if (in(s->formula,s->next)) {
	  int size = 0;
	  if (verbose)
	    size = size_tree(s->formula);
	  s->formula = free_tree(s->formula);
	  formulalist *aux = s->next;
	  free(s);
	  s = aux;
	  numsimp++;
	  if (debug) printf("\n and repeated");
	  formulasize = formulasize - size - 1;
	}
	else if (in_neg(s->formula,s->next)) { // simplify phi and neg phi
	      int size = 0;
	      if (verbose) {
		size = size_list(s->next);
		size = size + size_tree(s->formula);
	      }
	      s->next = free_formulalist(s->next);
	      s->formula = free_tree(s->formula);
	      s->formula = create_tnode(CONSTANT,CFALSE,s->mdepth,NULL,NULL,NULL);
	      s->formula->parent = s->parent;
	      s->formula->value_number = hash_tree(s->formula);
	      prop_node *p = find_prop(s->formula->id);
	      p = insert_p_position(p,s->formula);
	      numsimp++;
	      if (debug) printf("\n and f and neg f");
	      formulasize = 1 + formulasize - size;
	}
	else if (s->formula->type == BOX) {  // box phi & box false = box false
	  if (s->next != NULL &&
	      s->next->formula->type == BOX &&
	      s->formula->id == s->next->formula->id &&
	      s->next->formula->left->type == CONSTANT && s->next->formula->left->id == CFALSE) {
	    int size = 0;
	    if (verbose)
	      size = size_tree(s->formula);
	    s->formula = free_tree(s->formula);
	    formulalist *aux = s->next;
	    free(s);
	    s = aux;
	    numsimp++;
	    if (debug) printf("\n and box f and box false");
	    formulasize = formulasize - size;
	  }
	  else if (s->formula->left->type == CONSTANT && s->formula->left->id == CFALSE) { // box false & dia phi = false
	    if (in_diamond(s->next,s->formula->id)) {
	      int size = 0;
	      if (verbose)
		size = size_list(s->next);
	      s->next = free_formulalist(s->next);
	      if (verbose)
		size = size + size_tree(s->formula->left);
	      s->formula->left = free_tree(s->formula->left);
	      s->next = NULL;
	      s->formula->type = CONSTANT;
	      s->formula->id = CFALSE;
	      s->formula->mdepth = 0;
	      s->formula->value_number = hash_tree(s->formula);
	      numsimp++;
	      if (debug) 	    printf("\n and box false and dia phi");
	      formulasize = formulasize - size;
	      prop_node *p = find_prop(s->formula->id);
	      p = insert_p_position(p,s->formula);
	    }
	    else { // box false & box phi = box false
	      formulalist *aux = s->next;
	      while (aux != NULL && aux->formula->type == BOX && aux->formula->id == s->formula->id) {
		s->next = aux->next;
		int size = 0;
		if (verbose)
		  size = size_tree(aux->formula);
		free_tree(aux->formula);
		free(aux);
		aux = s->next;
		numsimp++;
		if (debug) 	printf("\n and box false and box phi\n Formula:");
		formulasize = formulasize - size - 1; //minus conjunction as well
	      }
	    }
	  }
	  else if (in_neg_box(s->formula,s->next)) { // box phi & box ~phi = box false
	    int size = 0;
	    if (verbose)
	      size = size_tree(s->formula->left);
	    s->formula->left = free_tree(s->formula->left);
	    s->formula->left = malloc(sizeof(tnode));
	    s->formula->left->type = CONSTANT;
	    s->formula->left->id = CFALSE;
	    s->formula->left->mdepth = 0;
	    s->formula->left->left = NULL;
	    s->formula->left->right = NULL;
	    s->formula->left->list = NULL;
	    s->formula->left->parent = s->formula; 
	    s->formula->left->value_number = hash_tree(s->formula->left);
	    s->formula->mdepth = 1;
	    s->formula->value_number = hash_tree(s->formula);
	    numsimp++;
	    if (debug) printf("\n and box phi and box ~phi");
	    formulasize = formulasize - size;
	    prop_node *p = find_prop(s->formula->left->id);
	    p = insert_p_position(p,s->formula->left);

	    sort_formulalist(CONJUNCTION,&s);
	    s = simplify_and(s);
	  }
	}
	else if ((id = is_diamond(s->formula))) { // <> TRUE & [] PHI == <> PHI 
	  int id2;
	  if (((s->formula->type == DIAMOND &&
		s->formula->left->type == CONSTANT &&
		s->formula->left->id == CTRUE) ||
	       (s->formula->type == NEGATION &&
		s->formula->left->left->type == CONSTANT &&
		s->formula->left->left->id == CFALSE)) &&
	      s->next != NULL &&
	      (id2 = is_diamond(s->next->formula)) &&
	      id == id2) {
	    int size = 0;
	    if (verbose)
	      size = size_tree(s->formula);
	    s->formula = free_tree(s->formula);
	    formulalist *aux = s->next;
	    free(s);
	    s = aux;
	    numsimp++;
	    if (debug) 	    printf("\n and dia true and box phi");
	    formulasize = formulasize - size;
	  }
	}
      }
    }

    /*	  s->next = in_conjunction_or_disjunction(DISJUNCTION,s->formula,s->next); // phi & (phi | psi) = phi
    // propagation
    if (s->formula->type == NEGATION) {
      s->next = propagate_in_conjunction_or_disjunction(DISJUNCTION,s->formula->left,s->next);
    }
    else {
      tnode *aux = create_tnode(NEGATION,NEGATION,s->formula->mdepth,s->formula,NULL,NULL);
      s->next = propagate_in_conjunction_or_disjunction(DISJUNCTION,aux,s->next);
      free(aux);
    } */
  }
    
  sort_formulalist(CONJUNCTION,&s);
  if (s != NULL) {
    s->value_number = hash_list(s);
  }
  if (debug) {printf("\n End: simplify_and: \n"); print_list(s);}
  return s;
}


formulalist *simplify_or (formulalist *s) {
  sort_formulalist(DISJUNCTION,&(s));
  if (debug) {  printf("\n Beginning: simplify_or:\n");print_list(s);} 
  int id;
  if (s != NULL) {
    if (s->formula->type == DISJUNCTION) {
      s = flatten_by_type(DISJUNCTION,s);
      s->value_number = hash_list(s);
      s = simplify_or(s);
      formulasize = formulasize - 1;
    }
    else {
      if (s->formula->type == CONSTANT) {
	if (s->formula->id == CTRUE) {
	  int size = 0;
	  if (verbose)
	    size = size_list(s->next);
	  s->next = free_formulalist(s->next);
	  s->next = NULL;
	  numsimp++;
	  if (debug)  printf("\n or true");
	  formulasize = formulasize - size - 1;
	}
	else if (s->formula->id == CFALSE) {
	  if (s->next != NULL) {
	    s->formula = free_tree(s->formula);
	    formulalist *aux = s->next;
	    free(s);
	    s = aux;
	    numsimp++;
	    if (debug)  printf("\n or false");
	    s = simplify_or(s);
	    formulasize = formulasize - 2; // symbol + disjunction
	  }
	}
      }
      else if (s->next != NULL) {
	s->next = simplify_or(s->next);
	if (s->next->formula->type == CONSTANT) {
	  if (s->next->formula->id == CTRUE) {
	    int size = 0;
	    if (verbose)
	      size = size_tree(s->formula);
	    s->formula = free_tree(s->formula);
	    formulalist *aux = s;
	    s = s->next;
	    s->next = free_formulalist(s->next);
	    //s->formula = s->next->formula;
	    //s->next = s->next->next;
	    free(aux);
	    numsimp++;
	    if (debug)  printf("\n or true, next");
	    formulasize = formulasize - size - 1;
	  }
	  else if (s->next->formula->id == CFALSE) {
	    s->next->formula = free_tree(s->next->formula);
	    formulalist *aux = s->next->next;
	    free(s->next);
	    //	    s->next = free_formulalist(s->next);
	    s->next = aux;
	    numsimp++;
	    if (debug) printf("\n or false,next");
	    formulasize = formulasize - 2; // symbol + disjunction
	  }
	}
	else if (in(s->formula,s->next)) {
	  int size = 0;
	  if (verbose)
	    size_tree(s->formula);
	  s->formula = free_tree(s->formula);
	  formulalist *aux = s->next;
	  free(s);
	  s = aux;
	  numsimp++;
	  if (debug) printf("\n or repeated");
	  formulasize = formulasize - size - 1;
	}
	else if (in_neg(s->formula,s->next)) {
	  int size = 0;
	  if (verbose) {
	    size = size_list(s->next);
	    size = size + size_tree(s->formula);
	  }
	  s->next = free_formulalist(s->next);
	  s->formula = free_tree(s->formula);
	  s->formula = create_tnode(CONSTANT,CTRUE,s->mdepth,NULL,NULL,NULL);
	  s->formula->parent = s->parent;
	  s->formula->value_number = hash_tree(s->formula);
	  numsimp++;
	  if (debug) printf("\n or f ~f");
	  formulasize = 1 + formulasize - size;
	  prop_node *p = find_prop(s->formula->id);
	  p = insert_p_position(p,s->formula);
	}
	else if ((id = is_diamond(s->formula))) { 
	  int id2;
	  if (s->next != NULL &&
	      (id2 = is_diamond(s->next->formula)) &&
	      id == id2 &&
	      ((s->next->formula->left->type == CONSTANT && s->next->formula->left->id == CTRUE) ||
	       (s->formula->type == NEGATION && s->next->formula->left->type == BOX && s->next->formula->left->left->type == CONSTANT && s->next->formula->left->left->id == CFALSE) // <> PHI | <> TRUE == <> TRUE
	       )) {
	    int size = 0;
	    if (verbose)
	      size_tree(s->formula);
	    s->formula = free_tree(s->formula);
	    formulalist *aux = s->next;
	    free(s);
	    s = aux;
	    numsimp++;
	    if (debug)  printf("\n or dia f, dia true");
	    formulasize = formulasize - size;
	  }
	  else if ((s->formula->left->type == CONSTANT && s->formula->left->id == CTRUE) ||
		   (s->formula->type == NEGATION && s->formula->left->type == BOX && s->formula->left->left->type == CONSTANT && s->formula->left->left->id == CFALSE)
		   ) { // remove other diamonds of same id from list <> TRUE | <> phi = <> TRUE
	    formulalist *aux = s->next;
	    while (aux != NULL && (id2 = is_diamond(aux->formula)) && id == id2) {
	      s->next = aux->next;
	      int size = 0;
	      if (verbose)
		size_tree(aux->formula);
	      aux->formula = free_tree(aux->formula);
	      free(aux);
	      aux = s->next;
	      numsimp++;
	      if (debug) printf("\n or dia true, dia f");
	      formulasize = formulasize - size - 1;
	    }
	  }
	  else if (in_neg_dia(s->formula,s->next)) { // dia phi | dia ~phi = dia true
	    int size = 0;
	    if (s->formula->type == NEGATION) {
	      if (verbose)
		size = size_tree(s->formula->left->left);
	      s->formula->left->left = free_tree(s->formula->left->left);
	      s->formula->left->left = malloc(sizeof(tnode));
	      s->formula->left->left->type = CONSTANT;
	      s->formula->left->left->id = CFALSE;
	      s->formula->left->left->mdepth = 0;
	      s->formula->left->left->mlevel = s->formula->left->mlevel + 1;
	      s->formula->left->left->polarity = s->formula->left->polarity;
	      s->formula->left->left->left = NULL;
	      s->formula->left->left->right = NULL;
	      s->formula->left->left->list = NULL;
	      s->formula->left->left->parent = s->formula->left; // changed here 2023-01-24
	      s->formula->left->left->value_number = hash_tree(s->formula->left->left);
	      prop_node *p = find_prop(s->formula->left->left->id);
	      p = insert_p_position(p,s->formula->left->left);

	    }
	    else {
	      if (verbose)
		size = size_tree(s->formula->left);
	      s->formula->left = free_tree(s->formula->left);
	      s->formula->left = malloc(sizeof(tnode));
	      s->formula->left->type = CONSTANT;
	      s->formula->left->id = CTRUE;
	      s->formula->left->mdepth = 0;
	      s->formula->left->left = NULL;
	      s->formula->left->right = NULL;
	      s->formula->left->list = NULL;
	      s->formula->left->parent = s->formula->left; // changed here 2023-01-24
	      s->formula->left->value_number = hash_tree(s->formula->left);
	      prop_node *p = find_prop(s->formula->left->id);
	      p = insert_p_position(p,s->formula->left);
	    }
	      
	    s->formula->left->value_number = hash_tree(s->formula->left);
	    s->formula->value_number = hash_tree(s->formula);
	    numsimp++;
	    if (debug) printf("\n or dia f, dia ~f");
	    formulasize = formulasize - size;
	    sort_formulalist(DISJUNCTION,&s);
	    s = simplify_or(s);
	  }
	}
	else if (s->formula->type == BOX && s->formula->left->type == CONSTANT && s->formula->left->id == CFALSE &&
		 s->next != NULL && s->next->formula->type == BOX && s->next->formula->id == s->formula->id) { // [] FALSE | [] PHI = BOX PHI
	  int size = 0;
	  if (verbose)
	    size_tree(s->formula);
	  s->formula = free_tree(s->formula);
	  formulalist *aux = s->next;
	  free(s);
	  s = aux;
	  numsimp++;
	  if (debug) printf("\n or box false or box phi == box phi (this is absorption: phi v (phi & psi) == phi ==> []p v ([]p & []~p)");
	  formulasize = formulasize - size - 1;
	}
	else if (s->formula->type == BOX) {
	  if (in_diamond_true(s->next,s->formula->id)) { // dia true | box phi = dia phi | dia ~phi | box phi = dia phi | ~box phi | box phi = true
	    if (s->next != NULL) {
	      int size = 0;
	      if (verbose) {
		size_list(s->next);
		size = size + size_tree(s->formula->left);
	      }
	      s->next = free_formulalist(s->next);
	      s->formula->left = free_tree(s->formula->left);
	      s->next = NULL;
	      s->formula->type = CONSTANT;
	      s->formula->id = CTRUE;
	      s->formula->value_number = hash_tree(s->formula);
	      numsimp++;
	      if (debug) printf("\n or box true");
	      formulasize = formulasize - size;
	      prop_node *p = find_prop(s->formula->id);
	      p = insert_p_position(p,s->formula);

	    }
	  }
	}
      }
    }
    
    /*    s->next = in_conjunction_or_disjunction(CONJUNCTION,s->formula,s->next); // phi | (phi & psi) = phi
    // propagation
    if (s->formula->type == NEGATION) {
      s->next = propagate_in_conjunction_or_disjunction(CONJUNCTION,s->formula->left,s->next);
    }
    else {
      tnode *aux = create_tnode(NEGATION,NEGATION,s->formula->mdepth,s->formula,NULL,NULL);
      s->next = propagate_in_conjunction_or_disjunction(CONJUNCTION,aux,s->next);
      free(aux);
      } */
    } 

  if (s != NULL) {
    sort_formulalist(DISJUNCTION,&s);
    s->value_number = hash_list(s);
  }
  if (debug) {printf("\n End: simplify_or: \n"); print_list(s);}
  return s;
}

tnode *get_nnfsimp (tnode *s) {
  if (s == NULL)
    return s;
  switch (s->type) {
    case SETC:
      {
	s->right = get_nnfsimp(s->right);
	return s;
      }
      break;
    case SETF: 
      {
	s->left = get_nnfsimp(s->left);
	s->right = get_nnfsimp(s->right);
	return s;
      }
      break;
    case NEGATION: 
      {
	if (s->left != NULL) {
	  if (s->left->type == NEGATION) { // simplifies double negations
	    tnode *parent = s->parent;
	    tnode *new = s->left->left;
	    s->left->left = NULL;
	    s->left = free_tree(s->left);
	    s = new;
	    s->parent = parent;
	    formulasize = formulasize - 2;
	    numsimp = numsimp + 2;
	    s = get_nnfsimp(s);
	  }
	  else if (s->left->type == CONSTANT && s->left->id != CSTART) {
	    s->type = CONSTANT;
	    if (s->left->id == CTRUE)
	      s->id = CFALSE;
	    else s->id = CTRUE;
	    s->left = free_tree(s->left);
	    s->value_number = hash_tree(s);
	    formulasize = formulasize - 1;
	    prop_node *p = find_prop(s->id);
	    numsimp++;
	    p = insert_p_position(p,s);
	  }
	  if (s->left != NULL) {
	    s->left = get_nnfsimp(s->left);
	    s->left->parent = s;
	  }	  
	  if (s->type == NEGATION && s->left->type != BOX && s->left->type != PROP) {
	    s = get_nnfsimp(s);
	  }
	}
	return s;
      }      
      break;
    case CONSTANT:
    case PROP:
      return s;
      break;
    case BOX:
      {
	s->left = get_nnfsimp(s->left);
	s->mdepth = s->left->mdepth + 1;
	if (s->left->type == CONSTANT && s->left->id == CTRUE) {
	  s->type = CONSTANT;
	  s->id = CTRUE;
	  s->left = free_tree(s->left);
	  s->mdepth = 0;
	  s->value_number = hash_tree(s);
	  numsimp++;
	  formulasize = formulasize - 2;
	  prop_node *p = find_prop(s->id);
	  p = insert_p_position(p,s);
	}
	return s;
      }
      break;
    case DIAMOND:
      {
	s->left = get_nnfsimp(s->left);
	s->mdepth = s->left->mdepth + 1;
	if (s->left->type == CONSTANT && s->left->id == CFALSE) {
	  s->type = CONSTANT;
	  s->id = CFALSE;
	  s->left = free_tree(s->left);
	  s->mdepth = 0;
	  s->value_number = hash_tree(s);
	  numsimp++;
	  formulasize = formulasize - 2;
	  prop_node *p = find_prop(s->id);
	  p = insert_p_position(p,s);
	}
	return s;
      }
      break;
    case DISJUNCTION:
      {
	sort_formulalist(DISJUNCTION,&(s->list));
	formulalist *aux = s->list;
	int md = 0;
	while (aux != NULL) {
          aux->formula = get_nnfsimp(aux->formula);
	  if (md > aux->formula->mdepth)
	    md = aux->formula->mdepth;
	  aux = aux->next;
	}
	
	s->mdepth = md;
	aux = s->list;

	int flag = 0;
	while (aux != NULL) {
	  if (aux->formula->type == DISJUNCTION) {
	    flag = 1;
	    formulalist *aux2 = aux->formula->list;
	    formulalist *aux3 = aux->formula->list;
	    while (aux3->next != NULL) {
	      aux3 = aux3->next;
	    }
	    aux3->next = aux->next;
	    aux->formula = aux2->formula;
	    aux->next = aux2->next;
	    free(aux2);
	    aux = aux3; // moves to the end of the list in formula then goes to the next
	  }
	  aux = aux->next;
	}

	if (flag) {
	  sort_formulalist(DISJUNCTION,&(s->list));
	  s->list->value_number = hash_list(s->list);
	  s->value_number = hash_tree(s);
	}
	s->list = simplify_or(s->list);
	
	if (s->list == NULL) {
	  tnode *new = malloc(sizeof(tnode));
	  new->type = CONSTANT;
	  new->id = CFALSE;
	  new->left = NULL;
	  new->right = NULL;
	  new->list = NULL;
	  new->parent = s->parent;
	  new->value_number = hash_tree(new);
	  free(s);
	  s = new;
	  prop_node *p = find_prop(s->id);
	  p = insert_p_position(p,s);
	}
	else if (s->list->next == NULL)	  {// this is a list of size 1;
	  tnode *aux = s->list->formula;
	  aux->parent = s->parent;
	  free(s->list);
	  free(s);
	  s = aux;
	  formulasize = formulasize - 1;
	  numsimp++;
	}
	return s;
      }
      break;
    case CONJUNCTION:
      {

	sort_formulalist(CONJUNCTION,&(s->list));
	formulalist *aux = s->list;

	int md = 0;
	while (aux != NULL) {
	  aux->formula = get_nnfsimp(aux->formula);
	  if (md > aux->formula->mdepth)
	    md = aux->formula->mdepth;
	  aux = aux->next;
	}

	s->mdepth = md;
	aux = s->list;

	int flag = 0;
	while (aux != NULL) {
	  if (aux->formula->type == CONJUNCTION) {
	    flag = 1;
	    formulalist *aux2 = aux->formula->list;
	    formulalist *aux3 = aux->formula->list;
	    while (aux3->next != NULL) {
	      aux3 = aux3->next;
	    }
	    aux3->next = aux->next;
	    aux->formula = aux2->formula;
	    aux->next = aux2->next;
	    free(aux2);
	    numsimp++;
	    aux = aux3;
	  }
	  aux = aux->next;
	}

	if (flag) {
	  sort_formulalist(CONJUNCTION,&(s->list));
	  s->list->value_number = hash_list(s->list);
	  s->value_number = hash_tree(s);
	}
	s->list = simplify_and(s->list);

	if (s->list == NULL) {
	  tnode *new = malloc(sizeof(tnode));
	  new->type = CONSTANT;
	  new->id = CTRUE;
	  new->left = NULL;
	  new->right = NULL;
	  new->list = NULL;
	  new->parent = s->parent;
	  new->value_number = hash_tree(new);
	  free(s);
	  s = new;
	  prop_node *p = find_prop(s->id);
	  p = insert_p_position(p,s);
	}
	else if (s->list->next == NULL)	  {// this is a list of size 1;
	  tnode *aux = s->list->formula;
	  aux->parent = s->parent;
	  free(s->list);
	  free(s);
	  s = aux;
	  formulasize = formulasize - 1;
	  numsimp++;
	}
	return s;
      }
      break;
    default:
      return s;
    }
}
