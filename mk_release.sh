#!/bin/sh

OLDDIR=$PWD

TEMPDIR=$(mktemp -d /tmp/latex-beamer.XXXXXX)
git archive HEAD | tar xf - -C $TEMPDIR
cd $TEMPDIR
mkdir 'Ansichts-PDF'
mkdir 'LaTeX Vorlagen'

cp titlepage.tex wwustyle.sty beamer.tex preparefastmode.sh README 'LaTeX Vorlagen'
cp beamer.tex wwustyle.sty 'Ansichts-PDF'
cd 'Ansichts-PDF'

for i in 312 315 3282 369 390 396 prozessyellow
do
    fn="pantone$i"
    cp beamer.tex $fn.tex
    perl -pi -e "s/pantone312/$fn/;" $fn.tex
    pdflatex $fn
    pdflatex $fn
done

fn="english_claim"
cp beamer.tex $fn.tex
perl -pi -e "s/pantone312/pantone312,english/;" $fn.tex
pdflatex $fn
pdflatex $fn

cd ..

zip -r $OLDDIR/latex_vorlagen.zip Ansichts-PDF/*.pdf "LaTeX Vorlagen"

cd $OLDDIR
rm -rf ${TEMPDIR}

