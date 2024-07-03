install:
	pip install --upgrade pip
	pip install -r requirements.txt

format:
	black-nb notebooks/*.ipynb

lint:
	ruff check notebooks/*.ipynb

all: install lint format