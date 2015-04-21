#include <string>
#include <fstream>
#include <iostream>
using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 4) {
        cerr << "usage> tiny_replstr src-str dst-str file" << endl;
        return 1;
    }
    string srcstr = argv[1];
    string dststr = argv[2];
    string ifname = argv[3];
    ifstream ifs(ifname);
    if (!ifs.is_open()) {
        cerr << ifname << " not found." << endl;
        return 1;
    }
    string line;
    while (getline(ifs, line)) {
        if (!line.empty()) {
            string::size_type n;
            while ((n = line.find(srcstr, n)) != string::npos) {
                line.replace(n, srcstr.size(), dststr);
                n += dststr.size();
            }
        }
        cout << line << endl;
    }
    return 0;
}
