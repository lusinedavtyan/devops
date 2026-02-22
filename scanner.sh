path=${1:-.}
echo -n "The largest file name is: " ; find $path -type f -printf '%s %p\n'|sort -nr | head -n 1 | sed 's/.*\///'


