PROJECT=quaive/ploneintranet-base

docker-build:
	docker build -t $(PROJECT) .

docker-run:
	docker run -i -t $(PROJECT)

docker-push:
	docker push $(PROJECT)
