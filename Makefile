.PHONY: ctf

ctf:
ifeq ($(word 2, $(MAKECMDGOALS)), new)
	@mkdir -p chall && echo "Directory chall created or already exists."
	@docker image rm ctf-env --force
	@docker build -t ctf-env:latest .
else
	@if [ ! -d "chall" ]; then \
		mkdir chall; \
		echo "Directory chall created"; \
	else \
		echo "Directory chall already exists"; \
	fi
	@if [ -z "$(shell docker images -q ctf-env:latest)" ]; then \
		docker build -t ctf-env:latest .; \
	else \
		echo "Image ctf-env:latest already exists."; \
	fi
endif
	@docker run --platform linux/amd64 --cap-add=ALL --security-opt seccomp=unconfined -it -v ${PWD}/chall:/chall ctf-env

# Dummy target for 'new'
new: ;
