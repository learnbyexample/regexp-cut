# Examples

Examples for various options and combinations are shown below. These will also act as a source for testing the `rcut` command.

## Default field separators

Same as `awk`. Given newline as record separator, space and tab characters will be trimmed from the start/end of input lines. One or more space/tab characters will then act as the field separator.

Sample input file:

```bash
$ cat spaces.txt
   1 2	3  
x y z
 i          j 		k	
$ cat -A spaces.txt
   1 2^I3  $
x y z$
 i          j ^I^Ik^I$
```

Here's some example operations with default field separators:

```bash
# format lines with single space between fields
# leading/trailing space/tab characters will be removed as well
# same as: awk '{$1=$1} 1' spaces.txt
$ rcut spaces.txt
1 2 3
x y z
i j k

# specific field
$ rcut -f2 spaces.txt
2
y
j

# multiple fields can be specified separated by , character
# unlike cut, order matters
$ rcut -f3,1 spaces.txt
3 1
z x
k i
```

## Changing output field separator

```bash
$ rcut -o: spaces.txt
1:2:3
x:y:z
i:j:k

$ rcut -o'{-}' spaces.txt
1{-}2{-}3
x{-}y{-}z
i{-}j{-}k
```

## Changing input field separator

Here's some examples with `csv` input:

```bash
$ cat scores.csv
Name,Maths,Physics,Chemistry
Ith,100,100,100
Cy,97,98,95
Lin,78,83,80

# single character input field separator
# implies same output field separator as well
$ rcut -d, -f1,4 scores.csv
Name,Chemistry
Ith,100
Cy,95
Lin,80

$ rcut -d, -o: -f4,2 scores.csv
Chemistry:Maths
100:100
95:97
80:78
```

Input field separator can be multi-character as well:

```bash
$ echo 'apple:-:fig:-:guava' | rcut -d:-: -f2
fig

# output field separator won't be same as input in this case
$ echo 'apple:-:fig:-:guava' | rcut -d:-: -f2,1
fig apple
```

## Selecting range of fields

Range of fields can be specified separated by a `-` character.

```bash
$ printf '1 2 3 4 5\na b c d e\n' | rcut -f1-3
1 2 3
a b c

# multiple ranges can be specified, order matters
$ printf '1 2 3 4 5\na b c d e\n' | rcut -f2-3,5,1,2-4
2 3 5 1 2 3 4
b c e a b c d
```

Beginning or ending or both can be ignored for a range. Here's some examples:

```bash
# if - alone is used, it indicates all the fields
$ printf '1 2 3 4 5\na b c d e\n' | rcut -f-,1
1 2 3 4 5 1
a b c d e a

# if beginning of the range is left out, default is 1
$ rcut -f-2 spaces.txt
1 2
x y
i j

# if ending of the range is left out, default is last field of that line
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f2- -o,
ball,cat
2,3,4,5
```

## Regexp based input field separator

```bash
$ echo 'apple  : fig :    guava' | rcut -d' *: *' -f2
fig

$ echo 'Sample123string42with777numbers' | rcut -d'[0-9]+' -f1,4
Sample numbers

# if you change mawk to gawk, you can also use rcut -d'\\W+'
$ echo 'load;err_msg--\ant,r2..not' | rcut -d'[^[:alnum:]_]+'
load err_msg ant r2 not
```

## Miscellaneous

```bash
$ echo '1α2α3' | rcut -dα -f3,1,2
3α1α2

# input field separator is considered as multiple characters here
# so, output field separator will be space instead of α
$ echo '1α2α3' | LC_ALL=C rcut -dα -f3,1,2
3 1 2
```

Minimum field number is forced to be `1`. Maximum field number is forced to be the last field of that particular input line.

```bash
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f0
apple
1
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f22
cat
5
```

*More to come*

