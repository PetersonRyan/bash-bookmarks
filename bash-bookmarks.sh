#marks_name=()
#marks_path=()
function save(){
	marks_path+=($PWD)
	if [ -z "$1" ]
		then
			marks_name+=($PWD)
		else
			marks_name+=($1)
	fi
	echo "Saved"
}

function print(){
	for ((i=0; i<${#marks_name[@]}; i++))
		do printf "%i: %s\t:\t%s\n" "$i" "${marks_name[$i]}" "${marks_path[$i]}"
	done
}

echo "Bash bookmarks!"
