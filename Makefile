# Some simple testing tasks (sorry, UNIX only).

FLAGS?=--maxfail=3
SCALA_VERSION?=2.13
KAFKA_VERSION?=2.8.1
DOCKER_IMAGE=aiolibs/kafka:$(SCALA_VERSION)_$(KAFKA_VERSION)
DIFF_BRANCH=origin/master
FORMATTED_AREAS=aiokafka/util.py aiokafka/structs.py

setup:
	pip install -r requirements-dev.txt
	pip install -Ue .

format:
	isort $(FORMATTED_AREAS) setup.py
	black $(FORMATTED_AREAS) setup.py

flake: lint
lint:
	black --check $(FORMATTED_AREAS) setup.py
	@if ! isort -c $(FORMATTED_AREAS) setup.py; then \
            echo "Import sort errors, run 'make format' to fix them!!!"; \
            isort --diff --color $(FORMATTED_AREAS) setup.py; \
            false; \
        fi
	flake8 aiokafka tests setup.py
	mypy --install-types --non-interactive $(FORMATTED_AREAS)

test: flake
	pytest -s --show-capture=no --docker-image $(DOCKER_IMAGE) $(FLAGS) tests

vtest: flake
	pytest -s -v --log-level INFO --docker-image $(DOCKER_IMAGE) $(FLAGS) tests

cov cover coverage: flake
	pytest -s --cov aiokafka --cov-report html --docker-image $(DOCKER_IMAGE) $(FLAGS) tests
	@echo "open file://`pwd`/htmlcov/index.html"

ci-test-unit:
	pytest -s --log-format="%(asctime)s %(levelname)s %(message)s" --log-level DEBUG --cov aiokafka --cov-report xml --color=yes $(FLAGS) tests

ci-test-all:
	pytest -s -v --log-format="%(asctime)s %(levelname)s %(message)s" --log-level DEBUG --cov aiokafka --cov-report xml  --color=yes --docker-image $(DOCKER_IMAGE) $(FLAGS) tests

coverage.xml: .coverage
	coverage xml

diff-cov: coverage.xml
	git fetch
	diff-cover coverage.xml --html-report diff-cover.html --compare-branch=$(DIFF_BRANCH)

check-readme:
	python setup.py check -rms

clean:
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -f `find . -type f -name '@*' `
	rm -f `find . -type f -name '#*#' `
	rm -f `find . -type f -name '*.orig' `
	rm -f `find . -type f -name '*.rej' `
	rm -f .coverage
	rm -rf htmlcov
	rm -rf docs/_build/
	rm -rf cover
	rm -rf dist
	rm -f aiokafka/record/_crecords/cutil.c
	rm -f aiokafka/record/_crecords/default_records.c
	rm -f aiokafka/record/_crecords/legacy_records.c
	rm -f aiokafka/record/_crecords/memory_records.c
	rm -f aiokafka/record/_crecords/*.html

doc:
	make -C docs html
	@echo "open file://`pwd`/docs/_build/html/index.html"

.PHONY: all flake test vtest cov clean doc
