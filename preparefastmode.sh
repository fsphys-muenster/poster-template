#!/bin/sh

# generates the image files needed for "fast" option in the wwustyle package
#
# copy this file into a directory found in your system's PATH variable.

ARGC=$#
CMD=`basename $0`

usage() {
	cat <<EOF
$CMD your_document.tex

Generates the image files needed for "fast" option usage. If successful you
can add the option "fast" to your \usepackage[options]{wwustyle} line.
EOF
}

if [ $ARGC -ne 1 ]
then
	usage;
	exit 2;
fi

DOCFILE=$1

# skip rest of script if image files exist already!
if [ -f wwu-claim.pdf ]
then
	echo 'Files already exist!'
	exit 0
fi

OPWD=$PWD
TEMPDIR=$(mktemp -d /tmp/$CMD.XXXXX)

[ ! -f $DOCFILE ] && DOCFILE="$DOCFILE.tex"
if [ ! -f $DOCFILE ]
then
	echo "Document file not found: $DOCFILE... Exiting!"
	exit 1
fi

cp $DOCFILE $TEMPDIR
cd $TEMPDIR

sed -ne '/\\begin{document}/ q; s/\\tikzsetexternalprefix{[^}]*}//; s/\\usepackage\[[^]]*\]{wwustyle}/\\usepackage{wwustyle}/; p' $DOCFILE > tmp.tex
echo > infiles
sed -ne 's/^.*\\input{\([^}]*\)}.*$/\1/p' tmp.tex >> infiles

cat >> tmp.tex << EOF
\usepackage{tikz}
\usetikzlibrary{external}
\tikzexternalize

\begin{document}
\wwupreparefastmode
\end{document}
EOF

for file in $(cat infiles)
do
	infile=$OPWD/$file
	[ -f $infile ] || infile=$infile.tex
	[ -f $infile ] && cp $OPWD/$file . 
done

echo -n "Prepare image files..."
pdflatex -shell-escape tmp.tex 1> /dev/null 2> /dev/null
echo " (done)"

if [ ! -f wwu-claim.pdf ]; then
cat >&2 <<EOF
Could not create wwu image files. Option "fast" for the "wwustyle" package will
not be usable!

See wwu-images.log for more information.
EOF
rm -rf $TEMPDIR
exit 1
else
	cp wwu-*.pdf $OPWD
	cp tmp.log $OPWD/wwu-images.log
fi

rm -rf $TEMPDIR
