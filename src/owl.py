from lark import Lark, Transformer

intohylo_grammar = r"""
start: "begin" fml "end"

?fml: equiv_expr

?equiv_expr: impl_expr ("<->" impl_expr)* -> equiv
?impl_expr: or_expr ("->" or_expr)* -> impl
?or_expr: and_expr ("|" and_expr)* -> dij
?and_expr: unary_expr ("&" unary_expr)* -> conj

?unary_expr: "<" REL ">" unary_expr       -> diamond
           | "[" REL "]" unary_expr       -> box
           | "~" unary_expr               -> not_expr
           | "(" fml ")"
           | "true"                       -> top
           | "false"                      -> bottom
           | PROP                         -> var

REL: /r[0-9]+/
PROP: /p[0-9]+/

%import common.WS
%ignore WS

COMMENT: /%[^\n]*/
%ignore COMMENT
"""


# For the FaCT++ reasoner.
# Adapted from code written by Anthony Peigné and Cormac Kikkert.
class InToHyLoToKrss(Transformer):
    def var(self, items):
        return str(items[0])

    def top(self, items):
        return "*TOP*"

    def bottom(self, items):
        return "(not *TOP*)"

    def not_expr(self, items):
        return f"(not {items[0]})"

    def diamond(self, items):
        rel = str(items[0])
        if rel != "r1":
            raise ValueError(
                f"Error: Relation '{rel}' is not supported. Only 'r1' is allowed."
            )
        return f"(some {rel} {items[1]})"

    def box(self, items):
        rel = str(items[0])
        if rel != "r1":
            raise ValueError(
                f"Error: Relation '{rel}' is not supported. Only 'r1' is allowed."
            )
        return f"(all {rel} {items[1]})"

    def _binary_op(self, op, items):
        if not items:
            return ""
        result = items[-1]
        for item in reversed(items[:-1]):
            if op == "impl":
                result = f"(or (not {item}) {result})"
            elif op == "equiv":
                result = f"(and (or (not {item}) {result}) (or (not {result}) {item}))"
            else:
                result = f"({op} {item} {result})"
        return result

    def conj(self, items):
        return self._binary_op("and", items)

    def dij(self, items):
        return self._binary_op("or", items)

    def impl(self, items):
        return self._binary_op("impl", items)

    def equiv(self, items):
        return self._binary_op("equiv", items)

    def start(self, items):
        return f"(defconcept D0 {items[0]})"


# For the Konclude reasoner.
# Based on https://github.com/konclude/Konclude/issues/25
class InToHyLoToOwl(Transformer):
    def __init__(self):
        super().__init__()
        self.props = set()
        self.rels = set()

    def var(self, items):
        prop = str(items[0])
        self.props.add(prop)
        return f":{prop}"

    def top(self, items):
        return "owl:Thing"

    def bottom(self, items):
        return "owl:Nothing"

    def not_expr(self, items):
        return f"ObjectComplementOf({items[0]})"

    def diamond(self, items):
        rel = str(items[0])
        self.rels.add(rel)
        return f"ObjectSomeValuesFrom(:{rel} {items[1]})"

    def box(self, items):
        rel = str(items[0])
        self.rels.add(rel)
        return f"ObjectAllValuesFrom(:{rel} {items[1]})"

    def _binary_op(self, op, items):
        if not items:
            return ""
        result = items[-1]
        for item in reversed(items[:-1]):
            if op == "impl":
                result = f"ObjectUnionOf(ObjectComplementOf({item}) {result})"
            elif op == "equiv":
                result = f"ObjectIntersectionOf(ObjectUnionOf(ObjectComplementOf({item}) {result}) ObjectUnionOf(ObjectComplementOf({result}) {item}))"
            elif op == "and":
                result = f"ObjectIntersectionOf({item} {result})"
            elif op == "or":
                result = f"ObjectUnionOf({item} {result})"
        return result

    def conj(self, items):
        return self._binary_op("and", items)

    def dij(self, items):
        return self._binary_op("or", items)

    def impl(self, items):
        return self._binary_op("impl", items)

    def equiv(self, items):
        return self._binary_op("equiv", items)

    def start(self, items):
        declarations = "\n".join(
            ["Declaration(Class(:D0))"]
            + [f"Declaration(Class(:{var}))" for var in self.props]
            + [f"Declaration(ObjectProperty(:{rel}))" for rel in self.rels]
        )

        return f"""
Prefix(:=<http://example.org/ontology#>)
Prefix(owl:=<http://www.w3.org/2002/07/owl#>)
Ontology(<http://example.org/ontology>
  {declarations}
  EquivalentClasses(:D0 {items[0]})
)"""


def intohylo_to_owl(modal_str: str) -> str:
    parser = Lark(intohylo_grammar, parser="lalr", transformer=InToHyLoToOwl())
    return str(parser.parse(modal_str))


def intohylo_to_krss(modal_str: str) -> str:
    parser = Lark(intohylo_grammar, parser="lalr", transformer=InToHyLoToKrss())
    return str(parser.parse(modal_str))


if __name__ == "__main__":
    example_formula = """
    begin
      [r1] p1 & <r1> ~p2
    end
    """

    print(intohylo_to_krss(example_formula))
    print(intohylo_to_owl(example_formula))
