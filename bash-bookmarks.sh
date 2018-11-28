__bbv_names_arr=()
__bbv_paths_arr=()
__bbv_name_save_dir=~/.bb_name_save
__bbv_path_save_dir=~/.bb_path_save

# bbs <name> : Save current directory as <name>
function bbs(){
	__bbv_paths_arr+=("$PWD")
	if ! [ -z "$1" ] # if $1 not null
		then #add bookmark name from $1
			__bbv_names_arr+=("$1")
		else
			__bbv_names_arr+=("$PWD") #bookmark name is just directory name
	fi

	__bbf_file_save "$__bbv_name_save_dir" "${__bbv_names_arr[@]}"
	__bbf_file_save "$__bbv_path_save_dir" "${__bbv_paths_arr[@]}"
	__bbf_complete

	echo "Saved"
}

# List all bookmarks index, name, and directory
function bbl(){
	for ((i=0; i<${#__bbv_names_arr[@]}; i++))
		do printf "%i: %-10s : %s\n" "$i" "${__bbv_names_arr[$i]}" "${__bbv_paths_arr[$i]}"
	done
	return 0;
}

# Remove a bookmark by name or index
function bbd(){
	local temp_name_arr=()
	local temp_path_arr=()
	if [[ $(__bbf_is_num $1; echo $?) -eq 0 ]] #if is numeric
	then
		for ((i=0; i<${#__bbv_names_arr[@]}; i++)); do
			if ! [ $i = $1 ]
				then
					temp_name_arr+=("${__bbv_names_arr[$i]}")
					temp_path_arr+=("${__bbv_paths_arr[$i]}")
			fi
		done
	else
		__bbf_delete_by_name $1; return $?;
	fi
	__bbv_names_arr=("${temp_name_arr[@]}")
	__bbv_paths_arr=("${temp_path_arr[@]}")

	__bbf_file_save "$__bbv_name_save_dir" "${__bbv_names_arr[@]}"
	__bbf_file_save "$__bbv_path_save_dir" "${__bbv_paths_arr[@]}"
	__bbf_complete
}

# Takes bookmark name as parameter 1, finds its index, then calls bbd with that index
function __bbf_delete_by_name(){
	for ((i=0; i<${#__bbv_names_arr[@]}; i++))
	do
		if [ "$1" = "${__bbv_names_arr[$i]}" ]; then
			bbd $i; return $?;
		fi
	done
	# Fallthrough if not bookmark is found
	echo "Bookmark not found. Use bbl to list your bookmarks"
	echo "For help try bb -h"
	! [ -z $2 ] && echo "If your bookmark name contains spaces, surround it with quotation marks"
}

# Sets bookmark arrays to empty and deletes the save files
function __bbf_reset(){
	__bbv_names_arr=()
	__bbv_paths_arr=()
	[ -f "$__bbv_name_save_dir" ] && rm "$__bbv_name_save_dir"
	[ -f "$__bbv_path_save_dir" ] && rm "$__bbv_path_save_dir"
	echo "Bookmarks reset"
	return 0;
}

# bb for bash-bookmarks
function bb(){
	# Options
	if [ -z $1 ]
		then
			bbl
			return 0;
	fi
	if [[ $1 = "-h" || $1 = "--help" || -z $1 ]]
		then
			printf "\n"
			printf "bbs <name>\t\t: Save current directory as <name>\n"
			printf "bb  <index/name>\t: Go to bookmark with index <index> or name <name>\n"
			printf "bbo <index/name>\t: Open bookmark with index <index> or name <name> in file manager\n"
			printf "bbl \t\t\t: List all bookmarks\n"
			printf "bbd <index/name>\t: Remove bookmark with index <index> or name <name>\n"
			printf "bb  -r\t\t\t: Resets bookmarks to nothing\n"
			printf "\n"
			return 0;
	elif [ $1 = '-r' ]; then
		__bbf_reset; return $?;
	fi

	# Bookmarks index or name
	if [[ $(__bbf_is_num $1; echo $?) -eq 0 ]] #if is numeric
		then
			if ! [[ $1 -lt 0 || -z ${__bbv_names_arr[$1]} ]] #if > 0 and index of that not null
				then
					cd "${__bbv_paths_arr[$1]}" && return 0;
					printf "Go to %s : %s has failed" ${__bbv_names_arr[$1]} ${__bbv_paths_arr[$1]}
				else
					echo "Invalid bookmark index"
			fi
	else
		for ((i=0; i<${#__bbv_names_arr[@]}; i++))
		do
			if [ "$1" = "${__bbv_names_arr[$i]}" ]; then
				cd "${__bbv_paths_arr[$i]}"
				return 0
			fi
		done
		# Fallthrough if not bookmark is found
		echo "Bookmark not found. Use bbl to list your bookmarks"
		echo "For help try bb -h"
		! [ -z $2 ] && echo "If your bookmark name contains spaces, surround it with quotation marks"
	fi
}

# Opens bookmark in finder
function bbo(){
	if [[ $(__bbf_is_num $1; echo $?) -eq 0 ]] #if is numeric
		then
			if ! [[ $1 -lt 0 || -z ${__bbv_names_arr[$1]} ]] #if > 0 and index of that not null
				then
					open "${__bbv_paths_arr[$1]}" && return 0;
					printf "Go to %s : %s has failed" ${__bbv_names_arr[$1]} ${__bbv_paths_arr[$1]}
				else
					echo "Invalid bookmark index"
			fi
	else
		for ((i=0; i<${#__bbv_names_arr[@]}; i++))
		do
			if [ "$1" = "${__bbv_names_arr[$i]}" ]; then
				if [ ! -z "$(command -v open)" -a "$(command -v open)" != " " ]; then
					# Sometimes open exists, but we still want xdg-open.
					# TODO: Try something like
					# VAR="$(open /path/to/directory/; echo $?)"
					# to get the return value. If it is 1, then try xdg-open
					open "${__bbv_paths_arr[$i]}"
				elif [ ! -z "$(command -v xdg-open)" -a "$(command -v xdg-open)" != " " ]; then
					xdg-open "${__bbv_paths_arr[$i]}"
				else
					echo "Opening bookmarks in a file manager is not supported on this machine."
				fi
				return 0
			fi
		done
		# Fallthrough if not bookmark is found
		echo "Bookmark not found. Use bbl to list your bookmarks"
		echo "For help try bb -h"
		! [ -z $2 ] && echo "If your bookmark name contains spaces, surround it with quotation marks"
	fi
}

# Saves array to file
# $1 is path to file
# Pass array as $2 using "${arrayName[@]}"
function __bbf_file_save(){
	[ -z $1 ] && return 1 # Return fail if no path argument

	local arr_to_save=("$@")

	for ((i=1; i<${#arr_to_save[@]}; i++))
	do
		if [ "$i" = 1 ]
		then
			printf "%s\n" "${arr_to_save[$i]}" > "$1"
			#printf "%s\t%s\n" "${__bbv_names_arr[$i]}" "${__bbv_paths_arr[$i]}" > "$dir"
		else
			printf "%s\n" "${arr_to_save[$i]}" >> "$1"
			#printf "%s\t%s\n" "${__bbv_names_arr[$i]}" "${__bbv_paths_arr[$i]}" >> "$dir"
		fi
	done
}

# Reads array from __bbv_name_save_dir to __bbv_names_arr
function __bbf_read_to_names(){
	let i=0
	while IFS=$'\n' read -r line_data; do
			__bbv_names_arr[i]="${line_data}"
			((++i))
	done < "$__bbv_name_save_dir"
}

# Reads array from __bbv_path_save_dir to __bbv_paths_arr
function __bbf_read_to_dirs(){
	let i=0
	while IFS=$'\n' read -r line_data; do
	    __bbv_paths_arr[i]="${line_data}"
	    ((++i))
	done < "$__bbv_path_save_dir"
}

# Returns true if argument is positive or negative integer
function __bbf_is_num(){
	local numReg="^-?[0-9]+$"
	if [[ $1 =~ $numReg ]] ; then
			return 0;
		else
			return 1;
	fi
}

# compgen function to be used by __bbf_complete
function __bbf_comp(){
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "${__bbv_names_arr[*]}" -- $cur) )
}

# Initialize auto-complete in functions that use bookmark names
function __bbf_complete(){
	complete -F __bbf_comp bb
	complete -F __bbf_comp bbd
	complete -F __bbf_comp bbo
}

# Read the save files back into memory
[ -f "$__bbv_name_save_dir" ] && __bbf_read_to_names
[ -f "$__bbv_path_save_dir" ] && __bbf_read_to_dirs

echo "Bash Bookmarks:"
__bbf_complete
bbl
