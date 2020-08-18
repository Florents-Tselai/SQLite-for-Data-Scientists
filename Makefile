SHELL:=/bin/bash

install-environment:
	conda env create --force -f environment.yml
