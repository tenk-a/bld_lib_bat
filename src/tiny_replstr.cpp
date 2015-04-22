/**
 *  @file   tiny_replstr.cpp
 *  @brief  replace string
 *  @author Masashi Kitamura (tenka@6809.net)
 *  @date   2015-04-19
 *  @license boost software license version 1.0
 */
#include <cstdio>
#include <vector>
#include <string>
#include <iostream>
using namespace std;

class App {
public:
    App() : dic_mode_(false) {}

    int main(int argc, char* argv[]) {
        if (argc <= 1)
            return usage();

        string fname;
        if (argc == 4 && string(argv[1]) != "++") {
            dic_.push_back( Elem(argv[1], argv[2]) );
            fname = argv[3];
        } else {
            for (int i = 1; i < argc; ++i) {
                string arg = argv[i];
                if (arg == "-?" || arg == "-h" || arg == "--help") {
                    return usage();
                } else if (arg == "++") {
                    dic_mode_ = true;
                } else if (arg == "--") {
                    dic_mode_ = false;
                } else if (dic_mode_) {
                    if (i+1 < argc) {
                        dic_.push_back( Elem(arg, argv[i+1]) );
                        ++i;
                    } else {
                        cerr << "not pair:" << arg << endl;
                        return 1;
                    }
                } else if (fname.empty()) {
                    fname = arg;
                } else {
                    cerr << "too many arguments.(" << arg << ")" << endl;
                    return 1;
                }
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
            cerr << fname << " not found." << endl;
            return false;
        }
        if (!text.empty()) {
            for (Dic::iterator it = dic_.begin(); it != dic_.end(); ++it)
                replaceStr(text, it->first, it->second);
        }
        cout << text;
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

    int usage() {
        cerr << "usage> tiny_replstr [old-str] [new-str] file" << endl;
        cerr << "       tiny_replstr ++ [old1] [new1] [old2] [new2] ...  -- file" << endl;
        return 1;
    }

private:
    //typedef map<string, string>   Dic;
    typedef pair<string, string>    Elem;
    typedef vector< Elem >          Dic;
    Dic             dic_;
    bool            dic_mode_;
};

int main(int argc, char* argv[]) {
    return App().main(argc, argv);
}
