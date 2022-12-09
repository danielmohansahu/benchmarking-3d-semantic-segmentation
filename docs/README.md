Report generation source code.

```bash
# generate the report
pdflatex report.tex && bibtex report && pdflatex report.tex
# verify word count
ps2ascii report.pdf | wc -w
```
