set -e
exts=$(cat .gitattributes | grep 'filter=lfs' | sed -e 's/^\*\.\([^ ]\+\).\+/\1/')
range=${TRAVIS_COMMIT_RANGE/.../..}

if [ "$range" == "" ]
then
	commits=$TRAVIS_COMMIT
else
	commits=$(git rev-list $range)
fi

echo "Checking extesions $exts"
echo "Looking at commits $commits"

for rev in $commits
do
	echo "Checking commit $rev"
	git checkout $rev
	status=0
	for ext in $exts
	do
		status=0
		find . -name \*.$ext -type f -exec file {} \; | grep -v 'ASCII text' \
			&& echo "ERROR: rogue $ext files found" && status=1 \
			|| echo "Ok: no rogue $ext files found"
	done
	if [ $status!=0 ]
	then
		exit $status
	fi
done
