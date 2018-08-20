#!/bin/sh
# Generates a complete .zip file with templates in German and English as well
# as all example title posters (all possible colors and sizes).
# Note: This takes quite a long time due to the amount of processed TeX
# documents.
# Command line arguments:
# $1: the LaTeX engine used for compilation (lualatex or xelatex);
#     optional (default: lualatex)

texdir=tex
fontdir=tex/fonts
zipname=latex_wwu_poster_$(date +%F)

latex_engine=$1
case "$latex_engine" in
	lualatex|xelatex)
		;;
	'')
		latex_engine=lualatex
		;;
	*)
		echo "Invalid LaTeX engine (must be lualatex or xelatex): $latex_engine"
		exit 2
		;;
esac
if [ ! -f "$fontdir/MetaOffcPro-Bold.ttf" ]     || \
	[ ! -f "$fontdir/MetaOffcPro-Norm.ttf" ]    || \
	[ ! -f "$fontdir/MetaOffcPro-NormIta.ttf" ] || \
	[ ! -f "$fontdir/MetaScOffcPro-Bold.ttf" ]  || \
	[ ! -f "$fontdir/MetaScOffcPro-Norm.ttf" ]  || \
	[ ! -f "$fontdir/MetaScOffcPro-NormIta.ttf" ]; then
	echo "Font files missing in $fontdir/!"
	exit 1
fi

# clean up previous build
rm -rf "$zipname/"
# remove converted PDF versions of EPS files
rm -f "$texdir/wwustyle"/*eps-converted-to*

olddir="$PWD"

tempdir=$(mktemp -d /tmp/latex-beamer.XXXXXX)
cp -r "$texdir/" "$tempdir/"
cd $tempdir
# delete dummy file
find "$fontdir/" -type f ! -name '*.ttf' -delete

# set up directories for compilation of example PDFs
mkdir -p de/vorlage/
mkdir -p en/template/

cp -r "$fontdir/" "$texdir/wwustyle/" \
	"$texdir"/*.sty \
	"$texdir/poster_de.tex" \
	'de/vorlage/'
cp -r "$fontdir/" "$texdir/wwustyle/" \
	"$texdir"/*.sty \
	"$texdir/poster_en.tex" \
	'en/template/'
mv de/vorlage/poster_de.tex de/vorlage/poster.tex
mv en/template/poster_en.tex en/template/poster.tex

cp -r de/vorlage/ de/beispiele/
cp -r en/template/ en/examples/

rm -r "$texdir/"

# compile examples
for d in de/beispiele en/examples; do
	cd "$d/"
	# generate all size and color options
	for size in a0paper a1paper; do
		for color in black7 234 7462 312 315 3135 369 390; do
			options="pantone$color"
			# remove commas from file names
			filename=$(echo "${options}_${size}" | sed 's/,/_/g')
			cp poster.tex "$filename.tex"
			# set options in the TeX file
			sed -i "s/a1paper]{article}/$size]{article}/" "$filename.tex"
			sed -i "s/pantone312]/$options]/" "$filename.tex"
			# run compilations
			latexmk "-$latex_engine" -interaction=nonstopmode -silent \
				"$filename.tex"
		done
	done
	# remove source files
	rm -r $(basename "$fontdir/") wwustyle/ *.tex *.sty
	# remove auxiliary files
	rm *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz
	cd "$tempdir"
done

# create .zip file
cd "$olddir"
cp -r "$tempdir/" "$zipname"
zip -r "$zipname.zip" "$zipname/"

rm -r "$tempdir"

