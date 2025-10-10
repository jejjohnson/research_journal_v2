.PHONY: help install_jbook update_jbook install_jaxlib update_jaxlib build clear

help:
	@echo "The following make targets are available:"
	@echo "	install		install all dependencies for environment with conda"
	@echo "	update		update all dependencies for environment with conda"
	@echo "	build		build jupyter book"
	@echo " clean 		clean previously built files"

install:
	conda env create -f environment_jb.yml

update:
	conda env update -f environment_jb.yml --prune

start:
	myst start

clean:
	myst clean
