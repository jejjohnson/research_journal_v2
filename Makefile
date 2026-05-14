.PHONY: help venv install update build clean start docs docs-serve docs-deploy precommit

help:
	@echo "The following make targets are available:"
	@echo "	venv		create a virtual environment with uv"
	@echo "	install		install all dependencies for environment with uv"
	@echo "	update		update all dependencies for environment with uv"
	@echo "	build		build MyST site"
	@echo "	docs		build MyST site as HTML (alias of docs-build)"
	@echo "	docs-serve	live preview on http://localhost:3000"
	@echo "	docs-deploy	build + publish to GitHub Pages via ghp-import"
	@echo "	precommit	run pre-commit hooks on all files"
	@echo "	clean 		clean previously built files"

venv:
	uv venv

install:
	uv pip install -e .

update:
	uv pip install --upgrade -e .

start:
	myst start

build:
	myst build

docs:
	myst build --html

docs-serve:
	-@fuser -k 3000/tcp 2>/dev/null || true
	-@fuser -k 3100/tcp 2>/dev/null || true
	myst start --port 3000 --server-port 3100

docs-deploy:
	myst build --html
	ghp-import -n -p _build/html

precommit:
	uv run pre-commit run --all-files

clean:
	myst clean
