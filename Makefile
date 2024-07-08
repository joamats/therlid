install:
	pip install --upgrade pip
	pip install -r requirements.txt

format:
	find . -type f -name "*.ipynb" -exec nbqa black {} \;

# lint won't work given bigquery creates the variables on the fly
# lint:
# 	ruff check notebooks/*.ipynb

all: install format # lint