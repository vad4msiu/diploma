#include <string>
#include <vector>
#include <iostream>
#include <fstream>

using namespace std;

template <class T> unsigned int edit_distance(const T& s1, const T& s2)
{
        const size_t len1 = s1.size(), len2 = s2.size();
        vector<vector<unsigned int> > d(len1 + 1, vector<unsigned int>(len2 + 1));
 
        d[0][0] = 0;
        for(unsigned int i = 1; i <= len1; ++i) d[i][0] = i;
        for(unsigned int i = 1; i <= len2; ++i) d[0][i] = i;
 
        for(unsigned int i = 1; i <= len1; ++i)
                for(unsigned int j = 1; j <= len2; ++j)
 
                      d[i][j] = std::min( std::min(d[i - 1][j] + 1,d[i][j - 1] + 1),
                                          d[i - 1][j - 1] + (s1[i - 1] == s2[j - 1] ? 0 : 1) );
        return d[len1][len2];
}

int main(int argc, char *argv[]) {
	ifstream file1;
	ifstream file2;
	string str1;
	string str2;
	string line;
	int distance_levenshtein;

	file1.open((const char*)argv[1]);
	file2.open((const char*)argv[2]);

	if (file1.is_open()) {
		while (!file1.eof()) {
			getline (file1,line);
		  str1 += line + "\n";
		}
	}
	
	if (file2.is_open()) {
		while (!file2.eof()) {
			getline (file2,line);
		  str2 += line + "\n";
		}
	}
	file1.close();
	file2.close();
	
	str1.erase(str1.length() - 1);
	str2.erase(str2.length() - 1);
	cout << str2.size() << endl;
  distance_levenshtein = edit_distance(str1, str2);
	cout << "ASD" << endl;
	cout << distance_levenshtein << endl;
	cout << (1 - (float)(2 * distance_levenshtein) / (str1.length() + str2.length()));
	return 0;
}