__gtv_names_arr=()
__gtv_paths_arr=()
__gtv_name_save_dir=~/.gt_name_save
__gtv_path_save_dir=~/.gt_path_save

function __gtf_save(){
	__gtv_paths_arr+=($PWD)
	if ! [ -z "$1" ] # if $1 not null
		then #add bookmark name from $1
			__gtv_names_arr+=($1)
		else
			__gtv_names_arr+=($PWD) #bookmark name is just directory name
	fi

	__gtf_file_save "$__gtv_name_save_dir" "${__gtv_names_arr[@]}"
	__gtf_file_save "$__gtv_path_save_dir" "${__gtv_paths_arr[@]}"

	echo "Saved"
}

function __gtf_print(){
	for ((i=0; i<${#__gtv_names_arr[@]}; i++))
		do printf "%i: %s\t:\t%s\n" "$i" "${__gtv_names_arr[$i]}" "${__gtv_paths_arr[$i]}"
	done
	return 0;
}

# Sets bookmark arrays to empty and deletes the save files
function __gtf_reset(){
	__gtv_names_arr=()
	__gtv_paths_arr=()
	[ -f "$__gtv_name_save_dir" ] && rm "$__gtv_name_save_dir"
	[ -f "$__gtv_path_save_dir" ] && rm "$__gtv_path_save_dir"
	echo "Bookmarks reset"
	return 0;
}

function gt(){
	if [ $1 = "-h" ]
		then
			printf "\n"
			printf "gt -s <name>\t: Save current directory as <name>\n"
			printf "gt -s\t\t: Save current directory without name\n"
			printf "gt -p\t\t: Print all bookmarks\n"
			printf "gt -r\t\t: Resets bookmarks to nothing\n"
			printf "gt <index>\t: Go to bookmark with index <index>\n"
			printf "\n"
			return 0;
		elif [ $1 = "-p" ]; then
				__gtf_print; return $?;
		elif [ $1 = '-s' ]; then
				__gtf_save $2; return $?;
		elif [ $1 = '-r' ]; then
				__gtf_reset; return $?;
	fi
	if [[ $(__gtf_is_num $1; echo $?) -eq 0 ]] #if is numeric
		then
			if ! [[ $1 -lt 0 || -z ${__gtv_names_arr[$1]} ]] #if > 0 and index of that not null
				then
					cd ${__gtv_paths_arr[$1]} && return 0;
					printf "Go to %s : %s has failed" ${__gtv_names_arr[$1]} ${__gtv_paths_arr[$1]}
				else
					echo "Argument valid bookmark index or bookmark name"
			fi
	else
		echo "Not numeric, bookmark name probably"
	fi
}

# Saves array to file
# $1 is path to file
# Pass array as $2 using "${arrayName[@]}"
function __gtf_file_save(){
	[ -z $1 ] && return 1 # Return fail if no path argument

	local arr_to_save=("$@")

	for ((i=1; i<${#arr_to_save[@]}; i++))
	do
		if [ "$i" = 1 ]
		then
			printf "%s\n" "${arr_to_save[$i]}" > "$1"
			#printf "%s\t%s\n" "${__gtv_names_arr[$i]}" "${__gtv_paths_arr[$i]}" > "$dir"
		else
			printf "%s\n" "${arr_to_save[$i]}" >> "$1"
			#printf "%s\t%s\n" "${__gtv_names_arr[$i]}" "${__gtv_paths_arr[$i]}" >> "$dir"
		fi
	done
}

# Reads array from __gtv_name_save_dir to __gtv_names_arr
function __gtf_read_to_names(){
	let i=0
	while IFS=$'\n' read -r line_data; do
			__gtv_names_arr[i]="${line_data}"
			((++i))
	done < "$__gtv_name_save_dir"
}

# Reads array from __gtv_path_save_dir to __gtv_paths_arr
function __gtf_read_to_dirs(){
	let i=0
	while IFS=$'\n' read -r line_data; do
	    __gtv_paths_arr[i]="${line_data}"
	    ((++i))
	done < "$__gtv_path_save_dir"
}

# Returns true if argument is positive or negative integer
function __gtf_is_num(){
	local numReg="^-?[0-9]+$"
	if [[ $1 =~ $numReg ]] ; then
			return 0;
		else
			return 1;
	fi
}

# Read the save files back into memory
[ -f "$__gtv_name_save_dir" ] && __gtf_read_to_names
[ -f "$__gtv_path_save_dir" ] && __gtf_read_to_dirs

echo "Bash bookmarks!"
