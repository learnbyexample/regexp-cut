# regexp-cut

Use awk to provide cut like syntax for field extraction.

:warning: :warning: Work under construction!

## Motivation

`cut`'s syntax is handy for many field extraction problems. But it doesn't allow multi-character or regexp delimiters. So, this project aims to provide `cut` like syntax for those cases. Currently uses `mawk` in a `bash` script.

:warning: :warning: Work under construction!

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

# multiple ranges can be specified, order matters
$ printf '1 2 3 4 5\na b c d e\n' | rcut -f2-3,5,1,2-4
2 3 5 1 2 3 4
b c e a b c d
```

See [Examples.md](examples/Examples.md) for more examples.

## TODO

* Add complement option
* Negative indexing
* Option to control lines without delimiters
* And many more...

## Other tools

* [choose](https://github.com/theryangeary/choose) - negative indexing, regexp based delimiters, etc

