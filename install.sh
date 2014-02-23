#ln -sf .git-prompt.sh ~/

declare -a arr=(".aliases" ".bash_prompt" ".gitconfig" ".bash_profile" ".commonrc" ".git-prompt.sh")
dest_dir=~
cwd=$(pwd)

echo $cwd

pushd $dest_dir > /dev/null 2>&1

for i in "${arr[@]}"
do
   echo "linking $dest_dir/$i to $cwd/$i"
   ln -sf $cwd/$i $i
done

popd > /dev/null 2>&1
