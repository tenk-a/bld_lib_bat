/**
 *  @file   tiny_replstr.cpp
 *  @brief  tiny replace string command
 *  @author Masashi Kitamura (tenka@6809.net)
 *  @date   2015-04-19
 *  @license boost software license version 1.0
 */
#include <vector>
#include <string>
#include <utility>
#include <stdio.h>
#include <stdlib.h>
using namespace std;

class App {
public:
    App() : dic_mode_(false), one_mode_(true), overwrite_(false) {}

    int usage() {
        fprintf(stderr,
            "usage> tiny_replstr [opts] [old-str] [new-str] file\n"
            "       tiny_replstr [opts] ++ [old1] [new1] [old2] [new2] ...  -- file\n"
            "  opts:
            "    -x   Overwite the same file.\n");
        return 1;
    }

    int main(int argc, char* argv[]) {
        if (argc <= 1)
            return usage();

        string fname;
        for (int i = 1; i < argc; ++i) {
            string arg = argv[i];
            if (arg == "-?" || arg == "-h" || arg == "--help") {
                return usage();
            } else if (arg == "-x") {
                overwrite_ = true;
            } else if (arg == "++") {
                dic_mode_ = true;
                one_mode_ = false;
            } else if (arg == "--") {
                dic_mode_ = false;
                one_mode_ = false;
            } else if (dic_mode_ || one_mode_) {
                one_mode_ = false;
                if (i+1 < argc) {
                    dic_.push_back( Elem(arg, argv[i+1]) );
                    ++i;
                } else {
                    fprintf(stderr, "No new-string: %s\n", arg.c_str());
                    return 1;
                }
            } else if (fname.empty()) {
                fname = arg;
            } else {
                fprintf(stderr, "Too many arguments.(%s)\n", arg.c_str());
                return 1;
            }
        }
        if (dic_.empty())
            return usage();

        return conv(fname) ? 0 : 1;
    }

private:
    bool conv(string const& fname) {
        string text;
        if (!load(fname, text)) {
            fprintf(stderr, "File '%s' not found.\n", fname.c_str());
            return false;
        }
        if (!text.empty()) {
            for (Dic::iterator it = dic_.begin(); it != dic_.end(); ++it)
                replaceStr(text, it->first, it->second);
        }
        if (overwrite_) {
            saveSameFile(fname, text);
        } else {
            fprintf(stdout, "%s", text.c_str());
        }
        return true;
    }

    bool load(string const& fname, string& text) {
        FILE* fp = fopen(fname.c_str(), "rt");
        if (!fp)
            return false;
        text.clear();
        text.reserve(0x100000);
        char buf[ 0x10000 ];
        size_t n;
        while ((n = fread(buf, 1, sizeof buf, fp)) > 0)
            text.append(buf, n);
        fclose(fp);
        return true;
    }

    void replaceStr(string& text, string const& src, string const& dst) {
        string::size_type n = 0;
        while ((n = text.find(src, n)) != string::npos) {
            text.replace(n, src.size(), dst);
            n += dst.size();
        }
    }

    void saveSameFile(string const& fname, string const& text) {
        string bak_name = fname + ".bak";
        FILE* fp = fopen(bak_name.c_str(), "rb");
        if (fp) {
            fclose(fp);
            remove(bak_name.c_str());
        }
        rename(fname.c_str(), bak_name.c_str());
        fp = fopen(fname.c_str(), "wt");
        if (fwrite(text.c_str(), 1, text.size(), fp) != text.size())
            fprintf(stderr, "Write error (%s)\n", fname.c_str());
        fclose(fp);
    }

private:
    typedef pair<string, string>    Elem;
    typedef vector< Elem >          Dic;
    Dic             dic_;
    bool            dic_mode_;
    bool            one_mode_;
    bool            overwrite_;
};

int main(int argc, char* argv[]) {
    return App().main(argc, argv);
}
