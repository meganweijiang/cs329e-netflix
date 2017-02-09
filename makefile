FILES :=                              \
    .travis.yml                       \
    Netflix.html                      \
    Netflix.log                       \
    Netflix.py                        \
    RunNetflix.in                     \
    RunNetflix.out                    \
    RunNetflix.py                     \
    TestNetflix.out                   \
    TestNetflix.py                    \
#    netflix-tests/EID-RunNetflix.in   \
#    netflix-tests/EID-RunNetflix.out  \
#    netflix-tests/EID-TestNetflix.out \
#    netflix-tests/EID--TestNetflix.py \
    
ifeq ($(shell uname), Darwin)          # Apple
    PYTHON   := python3.5
    PIP      := pip3.5
    PYLINT   := pylint
    COVERAGE := coverage-3.5
    PYDOC    := pydoc3.5
    AUTOPEP8 := autopep8
else ifeq ($(CI), true)                # Travis CI
    PYTHON   := python3.5
    PIP      := pip3.5
    PYLINT   := pylint
    COVERAGE := coverage-3.5
    PYDOC    := pydoc3
    AUTOPEP8 := autopep8
else ifeq ($(shell uname -p), unknown) # Docker
    PYTHON   := python                # on my machine it's python
    PIP      := pip3.5
    PYLINT   := pylint
    COVERAGE := coverage-3.5
    PYDOC    := python -m pydoc        # on my machine it's pydoc 
    AUTOPEP8 := autopep8
else                                   # UTCS
    PYTHON   := python3.5
    PIP      := pip3
    PYLINT   := pylint3
    COVERAGE := coverage-3.5
    PYDOC    := pydoc3.5
    AUTOPEP8 := autopep8
endif
	

netflix-tests:
	git clone https://github.com/cs329e-spring-2017/netflix-tests.git

Netflix.html: Netflix.py
	$(PYDOC) -w Netflix

Netflix.log:
	git log > Netflix.log

format:
	$(AUTOPEP8) -i Netflix.py
	$(AUTOPEP8) -i RunNetflix.py
	$(AUTOPEP8) -i TestNetflix.py

RunNetflix.tmp: RunNetflix.in RunNetflix.out RunNetflix.py
	$(PYTHON) RunNetflix.py < RunNetflix.in > RunNetflix.tmp
	diff RunNetflix.tmp RunNetflix.out

TestNetflix.tmp: TestNetflix.py
	$(COVERAGE) run    --branch TestNetflix.py >  TestNetflix.tmp 2>&1
	$(COVERAGE) report -m --omit=/usr/lib/python3/dist-packages/*,/home/travis/virtualenv/python3.5.2/lib/python3.5/site-packages/* >> TestNetflix.tmp
	cat TestNetflix.tmp

check:
	@not_found=0;                                 \
    for i in $(FILES);                            \
    do                                            \
        if [ -e $$i ];                            \
        then                                      \
            echo "$$i found";                     \
        else                                      \
            echo "$$i NOT FOUND";                 \
            not_found=`expr "$$not_found" + "1"`; \
        fi                                        \
    done;                                         \
    if [ $$not_found -ne 0 ];                     \
    then                                          \
        echo "$$not_found failures";              \
        exit 1;                                   \
    fi;                                           \
    echo "success";

clean:
	rm -f  .coverage
	rm -f  *.pyc
	rm -f  RunNetflix.tmp
	rm -f  TestNetflix.tmp
	rm -rf __pycache__

config:
	git config -l

scrub:
	make clean
	rm -f  Netflix.html
	rm -f  Netflix.log
	rm -rf Netflix-tests

status:
	make clean
	@echo
	git branch
	git remote -v
	git status

test: Netflix.html Netflix.log RunNetflix.tmp TestNetflix.tmp netflix-tests check
