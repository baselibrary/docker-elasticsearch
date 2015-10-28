NAME     = baselibrary/elasticsearch
REPO     = git@github.com:baselibrary/docker-elasticsearch.git
TAGS     = 1.7
VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))

all: build

build: $(VERSIONS)

release: $(VERSIONS)
	docker push ${NAME}

update:
	docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh

library:
	docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./generate-stackbrew-library.sh

sync-branches:
	git fetch $(REPO) master
	@$(foreach tag, $(TAGS), git branch -f $(tag) FETCH_HEAD;)
	@$(foreach tag, $(TAGS), git push $(REPO) $(tag);)
	@$(foreach tag, $(TAGS), git branch -D $(tag);)


.PHONY: all build library $(VERSIONS)
$(VERSIONS):
	docker build --rm -t $(NAME):$@ $@
