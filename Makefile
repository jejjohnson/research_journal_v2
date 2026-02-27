.PHONY: help venv install update build clean

help:
	@echo "The following make targets are available:"
	@echo "	venv		create a virtual environment with uv"
	@echo "	install		install all dependencies for environment with uv"
	@echo "	update		update all dependencies for environment with uv"
	@echo "	build		build jupyter book"
	@echo "	clean 		clean previously built files"

venv:
	uv venv

install:
	uv pip install -e .

update:
	uv pip install --upgrade -e .

start:
	myst start

clean:
	myst clean
