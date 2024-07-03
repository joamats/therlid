install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

format:	
	pip install black-nb &&\
		black-nb notebooks/*.ipynb

lint:c
	ruff notebooks/*.ipynb
		
all: install lint format
