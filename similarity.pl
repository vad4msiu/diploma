use String::Similarity;

open FILE1, "<", $ARGV[0];
open FILE2, "<", $ARGV[1];
$lines1 = "";
$lines2 = "";

while (<FILE1>) {
  $lines1 = $lines1 . $_
}

while (<FILE2>) {
  $lines2 = $lines2 . $_
}

$similarity = similarity $lines1, $lines2;
print $similarity;