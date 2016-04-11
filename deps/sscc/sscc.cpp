
#include "input.h"
#include "parser.h"
#include "lex.h"
#include "cpp_lang.h"
#include "luavar_lang.h"

void usage() {
     fprintf(stderr, "Usage: sscc -i input_file -o output_file -l language\n");
     exit(1);
}

int main(int argc, char *argv[])
{
    int opt;
    const char *input_name = nullptr;
    const char *output_name = nullptr;
    const char *lang_name = nullptr;

    Input input;
    while ((opt = getopt(argc, argv, "i:o:l:I:")) != -1) {
        switch (opt) {
        case 'i':
            input_name = optarg;
            break;
        case 'o':
            output_name = optarg;
            break;
        case 'l':
            lang_name = optarg;
            break;
        case 'I':
            input.addPath(object<Path>(optarg));
            break;
        default:
            usage();
        }
    }

    if (!input_name || !output_name || !lang_name) {
        usage();
    }

    Token::init();
    Language::reg<CppLang>();
    Language::reg<LuaVarLang>();

    input.load(object<Path>(input_name), false);

    SymbolTable symbols;

    Parser parser(input, symbols);
    parser.parse();


    Language *lang = Language::get(lang_name);
    if (!lang) {
        log_fail("unknown language name '%s'", lang_name);
    }

    FILE *output = fopen(output_name, "w");
    if (!output) {
        perror("open output file failed.");
        exit(1);
    }
    lang->print(symbols, output);
    fclose(output);
    return 0;
}

