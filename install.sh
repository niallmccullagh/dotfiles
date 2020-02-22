declare -a arr=(".aliases" ".bash_completion.sh" ".bash_functions" ".bash_profile" ".bashrc" ".exports" ".git-prompt-colors.sh" ".gitconfig" ".inputrc" ".vimrc" ".vim" "bin")
dest_dir=~
cwd=$(pwd)

[[ -L $HOME/.vim ]] && echo "Deleting ~/.vim sym link" && rm -f $HOME/.vim
[[ -L $HOME/bin ]] && echo "Deleting ~/bin sym link" && rm -f $HOME/bin

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
