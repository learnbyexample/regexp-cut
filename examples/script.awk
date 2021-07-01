BEGIN {
	op_sh = "chk_snippets.sh"
	exp_op = "expected_op.txt"
	actual_op = "output.txt"
}

{
	if ($0 == "```bash") {
		code_block = 1
	} else if ($0 == "```") {
		code_block = 0
	} else if (code_block) {
		if (/^\$ /) {
			print(substr($0, 3)) > op_sh
		} else if (! /^$/ && ! /^# /) {
			print($0) > exp_op
		}
	}
}

END {
	system("bash " op_sh " > " actual_op " 2>&1")
	es = system("diff -q " exp_op " " actual_op)
	if (es == 0) {
		system("rm " op_sh " " exp_op " " actual_op)
		print ("All tests passed")
	}
}

