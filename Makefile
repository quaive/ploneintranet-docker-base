PROJECT=quaive/ploneintranet-base
BASETAG=saturn
MARKER=$(shell cat LATEST)
OLDTAG=$(shell docker images quaive/ploneintranet-base | grep $(BASETAG) | grep -v latest | awk '{print $$2}' | sort -nr | head -1)
NEWTAG=$(shell echo ${OLDTAG} | sed -r 's/(.+\.)([0-9]+)/OLDTAG="\2"; NEWTAG=$$(( OLDTAG+1 )); echo "\1$$NEWTAG"/ge')

version:
	@echo LATEST marker: ${MARKER}
	@echo old tag......: ${OLDTAG}
	@echo new tag......: ${NEWTAG}
ifneq ($(MARKER),$(OLDTAG))
	@echo "Error: LATEST marker does not match highest image tag."
	@echo "If tags are missing, run 'make docker-pull && make docker-retag'"
	@echo "To remove a brownbag build, run 'make docker-untag'"
endif

docker-build: version
ifeq ($(MARKER),$(OLDTAG))
	docker build -t $(PROJECT):$(NEWTAG) .
	docker tag $(PROJECT):$(NEWTAG) $(PROJECT):latest
	echo ${NEWTAG} > LATEST
	@echo " "
	@echo "Now commit LATEST so the new tag is git tracked, and run 'make docker-push'."
else
	@echo "Aborting docker build. Maybe you need to do a docker pull first?"
endif


docker-run:
	docker run -i -t $(PROJECT)

docker-push:
	docker push $(PROJECT)

docker-pull:
	docker pull  $(PROJECT)

docker-retag:
	docker tag $(PROJECT):latest $(PROJECT):$(MARKER)

docker-untag:
	docker rmi $(PROJECT):$(MARKER)
	docker images quaive/ploneintranet-base | grep $(BASETAG) | grep -v latest | awk '{print $$2}' | sort -nr | head -1 > LATEST
