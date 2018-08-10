__gt_names_arr=()
__gt_paths_arr=()
__gtbm_name_save_dir=~/.gtbm_name_save
__gtbm_path_save_dir=~/.gtbm_path_save

function __gtbm_save(){
	__gt_paths_arr+=($PWD)
	if ! [ -z "$1" ] # if $1 not null
		then #add bookmark name from $1
			__gt_names_arr+=($1)
		else
			__gt_names_arr+=() #bookmark name is just directory name
	fi
	echo "Saved"
}

function __gtp(){
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
				__gtp; return $?;
		elif [ $1 = '-s' ]; then
				__gts $2; return $?;
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
function __gtbm_file_save(){
	[ -z $1 ] && return 1 # Return fail if no argument
	for ((i=0; i<${#__gt_names_arr[@]}; i++))
	do
		if [ "$i" = 0 ]
		then
			printf "%s\n" "${__gt_paths_arr[$i]}" > "$dir"
			#printf "%s\t%s\n" "${__gt_names_arr[$i]}" "${__gt_paths_arr[$i]}" > "$dir"
		else
			printf "%s\n" "${__gt_paths_arr[$i]}" >> "$dir"
			#printf "%s\t%s\n" "${__gt_names_arr[$i]}" "${__gt_paths_arr[$i]}" >> "$dir"
		fi
	done
}

# Reads array from __gtbm_path_save_dir to __gt_paths_arr
function __gtbm_read_to_dirs(){
	let i=0
	while IFS=$'\n' read -r line_data; do
	    __gt_paths_arr[i]="${line_data}"
	    ((++i))
	done < "$__gtbm_path_save_dir"
}

# Reads array from __gtbm_name_save_dir to __gt_names_arr
function __gtbm_read_to_names(){
	let i=0
	while IFS=$'\n' read -r line_data; do
			__gt_names_arr[i]="${line_data}"
			((++i))
	done < "$__gtbm_name_save_dir"
}

# Returns true if argument is positive or negative integer
function __gtbm_isNum(){
	local numReg="^-?[0-9]+$"
	if [[ $1 =~ $numReg ]] ; then
			return 0;
		else
			return 1;
	fi
}

echo "Bash bookmarks!"
