#include <string>
#include <vector>
#include <iostream>
#include <fstream>

using namespace std;

int distanceLevenshtein(const string source, const string target) {

  // Step 1

  const int n = source.length();
  const int m = target.length();
  if (n == 0) {
    return m;
  }
  if (m == 0) {
    return n;
  }

  // Good form to declare a TYPEDEF

  typedef vector< vector<int> > Tmatrix;

  Tmatrix matrix(n+1);

  // Size the vectors in the 2.nd dimension. Unfortunately C++ doesn't
  // allow for allocation on declaration of 2.nd dimension of vec of vec

  for (int i = 0; i <= n; i++) {
    matrix[i].resize(m+1);
  }

  // Step 2

  for (int i = 0; i <= n; i++) {
    matrix[i][0]=i;
  }

  for (int j = 0; j <= m; j++) {
    matrix[0][j]=j;
  }

  // Step 3

  for (int i = 1; i <= n; i++) {

    const char s_i = source[i-1];

    // Step 4

    for (int j = 1; j <= m; j++) {

      const char t_j = target[j-1];

      // Step 5

      int cost;
      if (s_i == t_j) {
        cost = 0;
      }
      else {
        cost = 1;
      }

      // Step 6

      const int above = matrix[i-1][j];
      const int left = matrix[i][j-1];
      const int diag = matrix[i-1][j-1];
      int cell = min( above + 1, min(left + 1, diag + cost));

      // Step 6A: Cover transposition, in addition to deletion,
      // insertion and substitution. This step is taken from:
      // Berghel, Hal ; Roach, David : "An Extension of Ukkonen's
      // Enhanced Dynamic Programming ASM Algorithm"
      // (http://www.acm.org/~hlb/publications/asm/asm.html)

      if (i>2 && j>2) {
        int trans=matrix[i-2][j-2]+1;
        if (source[i-2]!=t_j) trans++;
        if (s_i!=target[j-2]) trans++;
        if (cell>trans) cell=trans;
      }

      matrix[i][j]=cell;
    }
  }

  // Step 7

  return matrix[n][m];
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
	
	str1.erase(str1.size() - 1);
	str2.erase(str2.size() - 1);
	cout << "ASD" << endl;
  distance_levenshtein = distanceLevenshtein(str1, str2);
	cout << "ASD" << endl;
	cout << distance_levenshtein << endl;
	cout << (1 - (float)(2 * distance_levenshtein) / (str1.length() + str2.length()));
	return 0;
}