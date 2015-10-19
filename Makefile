NAME = tvial/docker-mailserver
VERSION = $(TRAVIS_BUILD_ID)

all: build run prepare fixtures tests

build:
	docker build --no-cache -t $(NAME):$(VERSION) . 

run:
	# Copy test files
	cp test/accounts.cf postfix/
	cp test/virtual postfix/
	# Run container
	docker run -d --name mail -v "`pwd`/postfix":/tmp/postfix -v "`pwd`/spamassassin":/tmp/spamassassin -v "`pwd`/test":/tmp/test -h mail.my-domain.com -t $(NAME):$(VERSION)
	sleep 15

prepare:
	# Reinitialize logs 
	docker exec mail /bin/sh -c 'echo "" > /var/log/mail.log'

fixtures:
	# Sending test mails
	for file in test/email-templates/*.txt ; do docker exec mail /bin/sh -c "nc 0.0.0.0 25 < /tmp/$$file" ;	done
	# Wait for mails to be analyzed
	sleep 10

tests:
	# Start tests
	/bin/bash ./test/test.sh
