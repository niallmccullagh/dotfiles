declare -a arr=(".aliases" ".bash_prompt" ".gitconfig" ".bash_profile" ".bashrc" ".exports" ".git-prompt.sh" ".bash_functions" ".vimrc" ".vim" ".bash_completion.sh")
dest_dir=~
cwd=$(pwd)

[[ -L $HOME/.vim ]] && echo Deleting ~/.vim sym link && rm -f $HOME/.vim

echo $cwd

pushd $dest_dir > /dev/null 2>&1

for i in "${arr[@]}"
do
   echo "linking $dest_dir/$i to $cwd/$i"
   ln -sFfv $cwd/$i $i
done

popd > /dev/null 2>&1

unset dest_dir;
unset cwd;
unset arr;
