# regexp-cut

Uses `awk` to provide `cut` like syntax for field extraction. The command name is `rcut`.

:warning: :warning: Work under construction!

<br>

## Motivation

`cut`'s syntax is handy for many field extraction problems. But it doesn't allow multi-character or regexp delimiters. So, this project aims to provide `cut` like syntax for those cases. Currently uses `mawk` in a `bash` script.

:information_source: **Note** that `rcut` isn't feature compatible or a replacement for the `cut` command. `rcut` helps when you need features like regexp field separator.

<br>

## Features

* Default field separation is same as `awk`
* Both input (`-d`) and output (`-o`) field separators can be multiple characters
* Input field separator can use regular expressions
    * this script uses `mawk` by default
    * you can change it to `gawk` for better regexp support with `-g` option
* If input field separator is a single character, output field separator will also be this same character
* Fixed string input field separator can be enabled by using the `-F` option
    * if `-o` is *not* used, value passed to the `-d` option will be set as the output field separator
* Field range can be specified by using `-` separator (same as `cut`)
    * `-` by itself means all the fields (this is also the default if `-f` option isn't used at all)
    * if start of the range isn't given, default is `1`
    * if end of the range isn't given, default is last field of a line
* Negative indexing is allowed if you use `-n` option
    * `-1` means the last field, `-2` means the second-last field and so on
    * you'll have to use `:` to specify field ranges
* Multiple fields and ranges can be separated using `,` character (same as `cut`)
* Unlike `cut`, order matters with the `-f` option and field/range duplication is also allowed
    * this assumes `-c` (complement) is not active
* Using `-c` option will print all the fields in the same order as input except the fields specified by `-f` option
* Using `-s` option will suppress lines not matching the input field separator
* Minimum field number is forced to be `1`
* Maximum field number is forced to be last field of a line

:warning: :warning: Work under construction!

<br>

## Examples

```bash
$ cat spaces.txt
   1 2	3  
x y z
 i          j 		k	

# by default, it uses awk's space/tab field separation and trimming
# unlike cut, order matters
$ rcut -f3,1 spaces.txt
3 1
z x
k i

# multi-character delimiter
$ echo 'apple:-:fig:-:guava' | rcut -d:-: -f2
fig

# regexp delimiter
$ echo 'Sample123string42with777numbers' | rcut -d'[0-9]+' -f1,4
Sample numbers

# fixed string delimiter
$ echo '123)(%)*#^&(*@#.[](\\){1}\xyz' | rcut -Fd')(%)*#^&(*@#.[](\\){1}\' -f1,2 -o,
123,xyz

# multiple ranges can be specified, order matters
$ printf '1 2 3 4 5\na b c d e\n' | rcut -f2-3,5,1,2-4
2 3 5 1 2 3 4
b c e a b c d

# last field
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -nf-1
cat
5

# except last two fields
$ printf 'apple ball cat\n1 2 3 4 5' | rcut -cnf-2:
apple
1 2 3

# suppress lines without input field delimiter
$ printf '1,2,3,4\nhello\na,b,c\n' | rcut -sd, -f2
2
b

# -g option will switch to gawk
$ echo '1aa2aa3' | rcut -gd'a{2}' -f2
2
```

See [Examples.md](examples/Examples.md) for many more examples.

<br>

## Tests

You can use [script.awk](examples/script.awk) to check if all the example code snippets are working as expected. 

```bash
$ cd examples/
$ awk -f script.awk Examples.md
```

<br>

## TODO

* Step value other than `1` for field range
* What to do if start of the range is greater than end?
* And possibly more...

<br>

## Similar tools

* [choose](https://github.com/theryangeary/choose) — negative indexing, regexp based delimiters, etc

<br>

## Contributing

* Please open an issue for typos/bugs/suggestions/etc
* **Even for pull requests, open an issue for discussion before submitting PRs**
* In case you need to reach me, mail me at `echo 'bGVhcm5ieWV4YW1wbGUubmV0QGdtYWlsLmNvbQo=' | base64 --decode` or send a DM via [twitter](https://twitter.com/learn_byexample)

<br>

## License

This project is licensed under MIT, see [LICENSE](./LICENSE) file for details.

