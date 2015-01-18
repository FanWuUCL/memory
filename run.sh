if [ $# -lt 1 ]; then
	echo "Invoke script followed by subject name"
	exit 0
fi

subject=$1
repeat=1
shift
if [ $1 -eq $1 2>/dev/null ]; then
	repeat=$1
	shift
fi

# prepare environment
./clean.sh

echo "Start experiment on >>>$subject<<<"

echo "Preparing executable >>>$subject<<<"

if [ ! $subject == "cfrac" ]; then
	gcc -shared -fPIC -O3 -o libmalloc.so malloc.c
else
	gcc -m32 -shared -fPIC -O3 -o libmalloc.so malloc.c
fi

cp libmalloc.so $subject/src/libmalloc.so
cd $subject/src
./configure
make clean
make
cd ../../

echo "Prepareing experiment environment"
cp $subject/src/$subject subject
cp $subject/subjectSetting.h src/subjectSetting.h
cp $subject/testcases.txt testcases.txt
if [ -d testcases ]; then
	rm -r testcases
fi
if [ $subject == "bash" ]; then
	cp $subject/testcases/* .
elif [ $subject == "abc" ]; then
	cp $subject/testcases/* .
elif [ $subject == "mencoder" ]; then
	cp $subject/testcases/* .
else
	cp -r $subject/testcases .
fi
if [ -d population ]; then
	rm -r population
fi
mkdir population
if [ ! -d curr ]; then
	mkdir curr
fi
	
# compile and run myga
echo "Running experiment on >>>$subject<<<"
cd src
make
cp myga ../myga
cp memory ../memory
cd ..

at=0
while [ $at -lt $repeat ]; do
	echo "myga $*"
	./myga $*
	
	# store result
	if [ -d population/generation999 ]; then
		opt="exp"
		for i in "$@"; do
			opt=$opt$i
		done
		opt=$opt"-at"$at
		mkdir $subject/$opt
		cp -r population $subject/$opt/
	fi
	at=$(($at+1))
done
