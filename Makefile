install:
	pip install --upgrade pip
	pip install -r requirements.txt

format:
	black-nb notebooks/*.ipynb

# lint won't work given bigquery creates the variables on the fly
# lint:
# 	ruff check notebooks/*.ipynb

all: install format # lint