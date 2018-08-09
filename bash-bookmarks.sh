#marks_name=()
#marks_path=()

function save(){
	marks_path+=($PWD)
	if ! [ -z "$1" ] # if $1 not null
		then #add bookmark name from $1
			marks_name+=($1)
		else
			marks_name+=($PWD) #bookmark name is just directory name
	fi
	echo "Saved"
}

function print(){
	for ((i=0; i<${#marks_name[@]}; i++))
		do printf "%i: %s\t:\t%s\n" "$i" "${marks_name[$i]}" "${marks_path[$i]}"
	done
}

function gt(){
	if [ $1 = "-h" ]
		then
			printf "\n"
			printf "gt -s <name>\t: Save current directory as <name>\n"
			printf "gt -s\t\t: Save current directory without name\n"
			printf "gt -p\t\t: Print all bookmarks\n"
			printf "gt <index>\t: Go to bookmark with index <index>\n"
			printf "\n"
			return 0;
	fi
	if [[ $(__isNum $1; echo $?) -eq 0 ]] #if is numeric
		then
			if ! [[ $1 -lt 0 || -z ${marks_name[$1]} ]] #if > 0 and index of that not null
				then
					cd ${marks_path[$1]} && return 0;
					echo "failed";
				else
					echo "Argument valid bookmark index or bookmark name"
			fi
	else
		echo "Not numeric, bookmark name probably"
	fi
}

# WIP
function __file_save(){
	local dir=~/.bashMarksSave
	for ((i=0; i<${#marks_name[@]}; i++))
	do
		if [ "$i" = 0 ]
		then
			printf "%s\t%s\n" "${marks_name[$i]}" "${marks_path[$i]}" > "$dir"
		else
			printf "%s\t%s\n" "${marks_name[$i]}" "${marks_path[$i]}" >> "$dir"
		fi
	done
}

function __isNum(){
	local numReg="^-?[0-9]+$"
	if [[ $1 =~ $numReg ]] ; then
			return 0;
		else
			return 1;
	fi
}

echo "Bash bookmarks!"
