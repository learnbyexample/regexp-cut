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

Input field separator can be multiple characters as well:

```bash
$ echo 'apple:-:fig:-:guava' | rcut -d:-: -f2
fig

# output field separator won't be same as input in this case
$ echo 'apple:-:fig:-:guava' | rcut -d:-: -f2,1
fig apple
```

## Selecting range of fields

Range of fields can be specified separated by a `-` character. If negative indexing option `-n` is enabled (discussed later), the separator changes to `:` character. 

```bash
$ printf '1 2 3 4 5\na b c d e\n' | rcut -f1-3
1 2 3
a b c

# multiple ranges can be specified, order matters
$ printf '1 2 3 4 5\na b c d e\n' | rcut -f2-3,5,1,2-4
2 3 5 1 2 3 4
b c e a b c d
```

Beginning or ending or both can be ignored for a range.

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

Regular expression syntax will depend on the `awk` version.

```bash
$ echo 'apple  : fig :    guava' | rcut -d' *: *' -f2
fig

$ echo 'Sample123string42with777numbers' | rcut -d'[0-9]+' -f1,4
Sample numbers

# if you change mawk to gawk, you can also use rcut -d'\\W+'
$ echo 'load;err_msg--\ant,r2..not' | rcut -d'[^[:alnum:]_]+'
load err_msg ant r2 not
```

## Fixed string input field separator

Using `-F` option will cause the content passed to `-d` option to be matched literally. If `-o` option isn't set, value passed to the `-d` option will be used.

```bash
$ echo '1\x5e2' | rcut -Fd'\x5e' -f1,2,1
1\x5e2\x5e1
$ echo 'a\b' | rcut -Fd'\' -f1,2,1
a\b\a
$ echo 'a\\b' | rcut -Fd'\\' -f1,2,1
a\\b\\a

$ echo '123)(%)*#^&(*@#.[](\\){1}\xyz' | rcut -Fd')(%)*#^&(*@#.[](\\){1}\' -f1
123
$ echo '123)(%)*#^&(*@#.[](\\){1}\xyz' | rcut -Fd')(%)*#^&(*@#.[](\\){1}\' -f2
xyz

# output should be same as input here
$ echo '123)(%)*#^&(*@#.[](\\){1}\xyz' | rcut -Fd')(%)*#^&(*@#.[](\\){1}\' -f1,2
123)(%)*#^&(*@#.[](\\){1}\xyz

# saner output with , as output delimiter
$ echo '123)(%)*#^&(*@#.[](\\){1}\xyz' | rcut -Fd')(%)*#^&(*@#.[](\\){1}\' -f1,2 -o,
123,xyz
```

## Negative indexing

When `-n` option is used, you can specify `-1` for last field, `-2` for second-last field and so on. You'll have to use `:` character for ranges.

```bash
# last field
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf-1
cat
5

# last field and third-last field
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf-1,-3
cat apple
5 3

# first and last field
$ echo 'Sample123string42with777numbers' | rcut -d'[0-9]+' -nf1,-1
Sample numbers

# range separator is : when -n is active
# last four fields
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf-4:
apple ball cat
2 3 4 5
```

## Complement

The `-c` option will invert the field selections. Unlike the normal field extraction, order doesn't matter. All the fields except those specified by the `-f` option will be displayed using the same order as input.

```bash
# except second field
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -cf2
apple cat
1 3 4 5

# except first and third fields, order doesn't matter
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -cf3,1
ball
2 4 5

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -cf2-3
apple
1 4 5

# except last two fields
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -cnf-2:
apple
1 2 3

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -cnf-4
ball cat
1 3 4 5
```

## Empty separators

```bash
$ echo 'apple' | rcut -d '' -f2-4
p p l

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -o '' -f1,3
applecat
13
```

## Suppress lines without delimiters

The `-s` option behaves similarly to the `-s` option provided by `cut`. This will suppress a line from being printed if it doesn't contain the given IFS.

```bash
$ printf '1,2,3,4\nhello\na,b,c\n'
1,2,3,4
hello
a,b,c

$ printf '1,2,3,4\nhello\na,b,c\n' | rcut -d, -f2
2
hello
b
$ printf '1,2,3,4\nhello\na,b,c\n' | rcut -sd, -f2
2
b

$ printf '1,2,3,4\nhello\na,b,c\n' | rcut -csd, -f2
1,3,4
a,c
```

## Unicode

Unicode processing might work for some cases depending on the current locale.

```bash
# single character input field separator
# so output field separator is also same as input separator
$ echo '1α2α3' | rcut -dα -f3,1,2
3α1α2

# input field separator is considered as multiple characters here
# so, output field separator will be space instead of α
$ echo '1α2α3' | LC_ALL=C rcut -dα -f3,1,2
3 1 2
```

## Switch to gawk

```bash
# mawk doesn't support {} form of quantifiers
# see https://unix.stackexchange.com/q/506119 for more details
$ echo '1aa2aa3' | rcut -d'a{2}' -f2
1aa2aa3
$ echo '1aa2aa3' | rcut -d'aa' -f2
2

# -g option will use gawk, which supports {} quantifiers
$ echo '1aa2aa3' | rcut -gd'a{2}' -f2
2
```

## Corner cases

Minimum field number is forced to be `1`.

```bash
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f0
apple
1
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f0-0
apple
1
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f1-0
apple
1

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f22
cat
5

# first line has only three fields, so -4 becomes 1 (since minimum is 1)
# second line has five fields, so -4 becomes 2
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf-4,-1
apple cat
2 5

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf-100
apple
1
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf:-100
apple
1
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf-200:-100
apple
1

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -cnf-100
ball cat
2 3 4 5
```

Maximum field number is forced to be the last field of that particular input line.

```bash
# no extra output field separator for first line even though it has only 3 fields
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -o, -f-4
apple,ball,cat
1,2,3,4

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f4
cat
4

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f100
cat
5
```

Backslash as field delimiters.

```bash
$ echo 'a\b' | rcut -d'\' -f1,2,1
a\b\a
$ echo 'a,b' | rcut -d',' -o'\' -f1,2,1
a\b\a
$ echo 'a\b' | rcut -d'\' -o'\' -f1,2,1
a\b\a

# gawk needs special attention if -o is \
$ echo 'a,b' | rcut -d',' -go'\' -f1,2,1
a\b\a
```

## Errors

Space between the option and empty string is mandatory. Otherwise, further options if any would become the argument.

```bash
# -f2-4 will get treated as argument for -d
$ echo 'apple' | rcut -d'' -f2-4
apple
$ echo 'apple' | rcut -d''
Option -d requires an argument.

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -o'' -f1,3
apple-f1,3ball-f1,3cat
1-f1,32-f1,33-f1,34-f1,35
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -o''
Option -o requires an argument.
```

Bad arguments for `-f` option.

```bash
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f1a
Field number can only use integer values

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -fx
Field number can only use integer values

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f1.1
Field number can only use integer values

$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f ''
Field number can only use integer values

# can't use : if -n option isn't provided
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -f1:3
Field number can only use integer values
```

Invalid options.

```bash
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -t
Invalid option: -t
$ echo '123' | rcut -x
Invalid option: -x
```

