__gt_names_arr=()
__gt_paths_arr=()
__gt_name_save_dir=~/.gt_name_save
__gt_path_save_dir=~/.gt_path_save

function __gt_save(){
	__gt_paths_arr+=($PWD)
	if ! [ -z "$1" ] # if $1 not null
		then #add bookmark name from $1
			__gt_names_arr+=($1)
		else
			__gt_names_arr+=($PWD) #bookmark name is just directory name
	fi

	__gt_file_save "$__gt_name_save_dir" "${__gt_names_arr[@]}"
	__gt_file_save "$__gt_path_save_dir" "${__gt_paths_arr[@]}"

	echo "Saved"
}

function __gt_print(){
	for ((i=0; i<${#__gt_names_arr[@]}; i++))
		do printf "%i: %s\t:\t%s\n" "$i" "${__gt_names_arr[$i]}" "${__gt_paths_arr[$i]}"
	done
	return 0;
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
		elif [ $1 = "-p" ]; then
				__gt_print; return $?;
		elif [ $1 = '-s' ]; then
				__gt_save $2; return $?;
	fi
	if [[ $(__isNum $1; echo $?) -eq 0 ]] #if is numeric
		then
			if ! [[ $1 -lt 0 || -z ${__gt_names_arr[$1]} ]] #if > 0 and index of that not null
				then
					cd ${__gt_paths_arr[$1]} && return 0;
					printf "Go to %s : %s has failed" ${__gt_names_arr[$1]} ${__gt_paths_arr[$1]}
				else
					echo "Argument valid bookmark index or bookmark name"
			fi
	else
		echo "Not numeric, bookmark name probably"
	fi
}

# WIP
function __gt_file_save(){
	[ -z $1 ] && return 1 # Return fail if no argument

	local arr_to_save=("$@")

	for ((i=1; i<${#arr_to_save[@]}; i++))
	do
		if [ "$i" = 1 ]
		then
			printf "%s\n" "${arr_to_save[$i]}" > "$1"
			#printf "%s\t%s\n" "${__gt_names_arr[$i]}" "${__gt_paths_arr[$i]}" > "$dir"
		else
			printf "%s\n" "${arr_to_save[$i]}" >> "$1"
			#printf "%s\t%s\n" "${__gt_names_arr[$i]}" "${__gt_paths_arr[$i]}" >> "$dir"
		fi
	done
}

# Reads array from __gt_path_save_dir to __gt_paths_arr
function __gt_read_to_dirs(){
	let i=0
	while IFS=$'\n' read -r line_data; do
	    __gt_paths_arr[i]="${line_data}"
	    ((++i))
	done < "$__gt_path_save_dir"
}

# Reads array from __gt_name_save_dir to __gt_names_arr
function __gt_read_to_names(){
	let i=0
	while IFS=$'\n' read -r line_data; do
			__gt_names_arr[i]="${line_data}"
			((++i))
	done < "$__gt_name_save_dir"
}

# Returns true if argument is positive or negative integer
function __gt_isNum(){
	local numReg="^-?[0-9]+$"
	if [[ $1 =~ $numReg ]] ; then
			return 0;
		else
			return 1;
	fi
}

echo "Bash bookmarks!"
