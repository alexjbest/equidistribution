.PHONY:	clean clean-html all check deploy debug

XSLTPROC = xsltproc --timing --stringparam debug.datedfiles no # -v

docs:	docs/equidistribution.pdf equidistribution-pretty.xml equidistribution.xsl filter.xsl
	mkdir -p docs
	cd docs/; \
	$(XSLTPROC) ../equidistribution.xsl ../equidistribution-pretty.xml

equidistribution.tex:	equidistribution-pretty.xml equidistribution-latex.xsl filter.xsl
	$(XSLTPROC) equidistribution-latex.xsl equidistribution-pretty.xml

equidistribution.md:	equidistribution-pretty.xml filter.xsl
	$(XSLTPROC) ../mathbook/xsl/mathbook-markdown-common.xsl equidistribution-wrapper.xml > equidistribution.md

docs/equidistribution.pdf:	equidistribution.tex
	latexmk -pdf -output-directory=docs -pdflatex="pdflatex -interaction=nonstopmode"  equidistribution.tex

equidistribution-wrapper.xml:	*.pug pug-plugin.json
	pug -O pug-plugin.json --extension xml equidistribution-wrapper.pug
	sed -i.bak -e 's/proofcase/case/g' equidistribution-wrapper.xml # Fix proofcase->case !! UGLY HACK, SAD
	rm equidistribution-wrapper.xml.bak

equidistribution-pretty.xml: equidistribution-wrapper.xml
	xmllint --pretty 2 equidistribution-wrapper.xml > equidistribution-pretty.xml

all:	docs docs/equidistribution.pdf

deploy: clean-html equidistribution-wrapper.xml docs
	cp equidistribution-wrapper.xml docs/equidistribution.xml
	./deploy.sh

debug:	*.pug pug-plugin.json
	pug -O pug-plugin.json --pretty --extension xml equidistribution-wrapper.pug

check:	equidistribution-pretty.xml
	jing ../mathbook/schema/pretext.rng equidistribution-pretty.xml
	#xmllint --xinclude --postvalid --noout --dtdvalid ../mathbook/schema/dtd/mathbook.dtd equidistribution-pretty.xml
	$(XSLTPROC) ../mathbook/schema/pretext-schematron.xsl equidistribution-pretty.xml

clean-html:
	rm -rf docs

clean:	clean-html
	rm -f equidistribution.md
	rm -f equidistribution*.tex
	rm -f equidistribution*.xml
