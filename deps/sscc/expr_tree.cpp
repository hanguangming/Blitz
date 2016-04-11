#include "expr_tree.h"
#include "log.h"
#include "define_tree.h"

enum {
    EXPR_OPT_LOGIC_OR,

    EXPR_OPT_LOGIC_AND,

    EXPR_OPT_OR,

    EXPR_OPT_XOR,

    EXPR_OPT_AND,

    EXPR_OPT_EQ,
    EXPR_OPT_NE,

    EXPR_OPT_GT,
    EXPR_OPT_GE,
    EXPR_OPT_LT,
    EXPR_OPT_LE,

    EXPR_OPT_SHIFT_LEFT,
    EXPR_OPT_SHIFT_RIGHT,

    EXPR_OPT_ADD,
    EXPR_OPT_SUB,

    EXPR_OPT_MUL,
    EXPR_OPT_DIV,
    EXPR_OPT_MOD,

    EXPR_OPT_UNKNOWN,
};

static int __precs[EXPR_OPT_UNKNOWN] = {
    10,      // EXPR_OPT_LOGIC_OR
    20,      // EXPR_OPT_LOGIC_AND
    30,      // EXPR_OPT_OR
    40,      // EXPR_OPT_XOR
    50,      // EXPR_OPT_AND
    60,      // EXPR_OPT_EQ
    60,      // EXPR_OPT_NE
    70,      // EXPR_OPT_GT
    70,      // EXPR_OPT_GE
    70,      // EXPR_OPT_LT
    70,      // EXPR_OPT_LE
    80,      // EXPR_OPT_SHIFT_LEFT
    80,      // EXPR_OPT_SHIFT_RIGHT
    90,      // EXPR_OPT_ADD
    90,      // EXPR_OPT_SUB
    100,     // EXPR_OPT_MUL
    100,     // EXPR_OPT_DIV
    100,     // EXPR_OPT_MOD
};

static int __get_opt(ptr<Token> token) {
    switch (token->type()) {
    case TOKEN_LOGIC_OR:
        return EXPR_OPT_LOGIC_OR;
    case TOKEN_LOGIC_AND:
        return EXPR_OPT_LOGIC_AND;
    case '|':
        return EXPR_OPT_OR;
    case '^':
        return EXPR_OPT_XOR;
    case '&':
        return EXPR_OPT_AND;
    case TOKEN_EQ:
        return EXPR_OPT_EQ;
    case TOKEN_NE:
        return EXPR_OPT_NE;
    case '>':
        return EXPR_OPT_GT;
    case TOKEN_GE:
        return EXPR_OPT_GE;
    case '<':
        return EXPR_OPT_LT;
    case TOKEN_LE:
        return EXPR_OPT_LE;
    case TOKEN_SHIFT_LEFT:
        return EXPR_OPT_SHIFT_LEFT;
    case TOKEN_SHIFT_RIGHT:
        return EXPR_OPT_SHIFT_RIGHT;
    case '+':
        return EXPR_OPT_ADD;
    case '-':
        return EXPR_OPT_SUB;
    case '*':
        return EXPR_OPT_MUL;
    case '/':
        return EXPR_OPT_DIV;
    case '%':
        return EXPR_OPT_MOD;
    default:
        return -1;
    }
}

static ptr<ExprTree> __parse_primary(Parser *parser) {
    ptr<ExprTree> tree;

    ptr<Token> cur = parser->cur();
    switch (cur->type()) {
    case TOKEN_INTEGER:
        tree = object<ExprTree>();
        tree->vint(static_cast<IntegerToken*>(cur.get())->value());
        parser->eat(tree->loc);
        break;
    case '(':
        parser->eat(tree->loc);
        tree = object<ExprTree>();
        tree->parse(parser);
        if (*parser->cur() != ')') {
            log_expect(parser->cur()->loc(), "')'");
        }
        parser->eat(tree->loc);
        break;
    case '-':
        parser->eat();
        tree = object<ExprTree>();
        tree->parse(parser);
        if (tree->exprType() == EXPR_STRING) {
            log_expect(cur->loc(), "number");
        }

        tree->vint(-tree->vint());
        break;
    case '~':
        parser->eat(tree->loc);
        tree = object<ExprTree>();
        tree->parse(parser);
        if (tree->exprType() == EXPR_STRING) {
            log_expect(cur->loc(), "number");
        }
        tree->vint(~tree->vint());
        break;
    case '!':
        parser->eat(tree->loc);
        tree = object<ExprTree>();
        tree->parse(parser);
        if (tree->exprType() == EXPR_STRING) {
            log_expect(cur->loc(), "number");
        }
        tree->vint(!tree->vint());
        break;
	default:
		if (cur->is_iden()) {
			ptr<DefineTree> def_tree = parser->symbols().get(cur->text()).cast<DefineTree>();
			if (!def_tree) {
				log_error(cur->loc(), "unknown identifier '%s'", cur->text());
			}
			if (def_tree->type() != TREE_DEFINE) {
				log_error(cur->loc(), "'%s' is not a define", cur->text());
			}
			parser->eat(); 
			tree = def_tree->value();
			break;
		}

        log_expect(cur->loc(), "expression");
        return nullptr;
    }
    return tree;
}

static ptr<ExprTree> __binopt(int opt, ptr<ExprTree> lhs, ptr<ExprTree> rhs) {
    object<ExprTree> tree;
    tree->loc << lhs->loc << rhs->loc;

    if (lhs->exprType() != EXPR_INT) {
        log_expect(lhs->loc, "integer");
    }
    if (rhs->exprType() != EXPR_INT) {
        log_expect(rhs->loc, "integer");
    }

    switch (opt) {
    case EXPR_OPT_LOGIC_OR:
        tree->vint(lhs->vint() || rhs->vint());
        break;
    case EXPR_OPT_LOGIC_AND:
        tree->vint(lhs->vint() && rhs->vint());
        break;
    case EXPR_OPT_OR:
        tree->vint(lhs->vint() | rhs->vint());
        break;
    case EXPR_OPT_XOR:
        tree->vint(lhs->vint() ^ rhs->vint());
        break;
    case EXPR_OPT_AND:
        tree->vint(lhs->vint() & rhs->vint());
        break;
    case EXPR_OPT_EQ:
        tree->vint(lhs->vint() == rhs->vint());
        break;
    case EXPR_OPT_NE:
        tree->vint(lhs->vint() != rhs->vint());
        break;
    case EXPR_OPT_GT:
        tree->vint(lhs->vint() > rhs->vint());
        break;
    case EXPR_OPT_GE:
        tree->vint(lhs->vint() >= rhs->vint());
        break;
    case EXPR_OPT_LT:
        tree->vint(lhs->vint() < rhs->vint());
        break;
    case EXPR_OPT_LE:
        tree->vint(lhs->vint() <= rhs->vint());
        break;
    case EXPR_OPT_SHIFT_LEFT:
        tree->vint(lhs->vint() << rhs->vint());
        break;
    case EXPR_OPT_SHIFT_RIGHT:
        tree->vint(lhs->vint() >> rhs->vint());
        break;
    case EXPR_OPT_ADD:
        tree->vint(lhs->vint() + rhs->vint());
        break;
    case EXPR_OPT_SUB:
        tree->vint(lhs->vint() - rhs->vint());
        break;
    case EXPR_OPT_MUL:
        tree->vint(lhs->vint() * rhs->vint());
        break;
    case EXPR_OPT_DIV:
        if (rhs->vint() == 0) {
            log_error(rhs->loc, "zero div");
        }
        tree->vint(lhs->vint() / rhs->vint()); 
        break;
    case EXPR_OPT_MOD:
        if (rhs->vint() == 0) {
            log_error(rhs->loc, "zero div");
        }
        tree->vint(lhs->vint() % rhs->vint());
        return tree;
    default:
        assert(false);
    }
    return tree;
}

static ptr<ExprTree> __parse_binopt_rhs(Parser *parser, ptr<ExprTree> lhs) {
    while (1) {
        ptr<Token> token_opt = parser->cur();
        int opt = __get_opt(token_opt);
        if (opt < 0) {
            return lhs;
        }
        int prec = __precs[opt];

        parser->eat(); 

        ptr<ExprTree> rhs = __parse_primary(parser);

        ptr<Token> next_token_opt = parser->cur();
        int next_opt = __get_opt(next_token_opt);
        if (next_opt >= 0) {
            int next_prec = __precs[next_opt];
            if (next_prec > prec) {
                rhs = __parse_binopt_rhs(parser, rhs);
            }
        }

        lhs = __binopt(opt, lhs, rhs);
    }
}

void ExprTree::parse(Parser *parser)
{
    ptr<ExprTree> tree = __parse_binopt_rhs(parser, __parse_primary(parser));
    *this = *tree;
}


