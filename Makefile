SHELL := /bin/bash

NETWORK := local
CANISTER_INSTALL_MODE := install

CANISTER_CANDID_UI_IC := "a4gq6-oaaaa-aaaab-qaa4q-cai"

# cicd writes the commit sha to this file which is deployed with frontend
# the About page reads it
COMMIT_JSON := "src/frontend/assets/deploy-info/commit.json"

GIT_BRANCH_NAME := $(shell git branch --show-current)

# For dip721-  calls
DIP721_CANISTER_DIR := src/backend/minter
DIP721_CANISTER_NAME := canisterMinter
TOKEN_ID := 1
PRINCIPAL := g4arn-6gm5z-j6hki-v5hqq-tlxcm-uzori-tp7lm-o5pp5-lorz4-4vhk4-jae
OWNER := $(PRINCIPAL)
OP := $(PRINCIPAL)
APPROVED := false

# Canister
CANISTER_DIR := $(DIP721_CANISTER_DIR)
CANISTER_NAME := $(DIP721_CANISTER_NAME)

# Call a canister method with dfx-canister-call
CANISTER_METHOD := ownerOf
CANISTER_ARGUMENT := (1)
CANISTER_OUTPUT := pp
CANISTER_INPUT := idl

help:
	@echo "Example commands:"
	@echo " make dip721-balanceOf PRINCIPAL=xxxx-...."
	@echo " make dip721-ownerOf TOKEN_ID=1"
	@echo " make dip721-tokenURI TOKEN_ID=1"
	@echo " make dip721-name"
	@echo " make dip721-symbol"
	@echo " make dip721-isApprovedForAll OWNER=xxxx-.... OP=yyyy-...."
	@echo " make dip721-getApproved TOKEN_ID=1"
	@echo " make dip721-setApprovalForAll OP=yyyy-.... APPROVED=true"
	@echo "	make dfx-canisters-of-project NETWORK=ic"

.PHONY: all-clean
all-clean: \
	dfx-clean python-clean

.PHONY: all-static
all-static: \
	python-format python-lint \
	javascript-format javascript-lint
	
.PHONY: all-static-check
all-static-check: \
	python-format-check python-lint-check python-type-check \
	javascript-format-check javascript-lint-check

.PHONY: dip721-balanceOf
dip721-balanceOf:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=balanceOf CANISTER_ARGUMENT=\(principal\ \"$(PRINCIPAL)\"\)

.PHONY: dip721-ownerOf
dip721-ownerOf:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=ownerOf CANISTER_ARGUMENT=\($(TOKEN_ID)\)

.PHONY: dip721-tokenURI
dip721-tokenURI:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=tokenURI CANISTER_ARGUMENT=\($(TOKEN_ID)\)

.PHONY: dip721-name
dip721-name:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=name CANISTER_ARGUMENT=\(\)

.PHONY: dip721-symbol
dip721-symbol:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=symbol CANISTER_ARGUMENT=\(\)

.PHONY: dip721-isApprovedForAll
dip721-isApprovedForAll:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=isApprovedForAll CANISTER_ARGUMENT=\(principal\ \"$(OWNER)\",\ principal\ \"$(OP)\"\)

.PHONY: dip721-getApproved
dip721-getApproved:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=getApproved CANISTER_ARGUMENT=\($(TOKEN_ID)\)

.PHONY: dip721-setApprovalForAll
dip721-setApprovalForAll:
	@$(MAKE) --no-print-directory dfx-canister-call  CANISTER_METHOD=setApprovalForAll CANISTER_ARGUMENT=\(principal\ \"$(OP)\",\ $(APPROVED)\)


.PHONY: dfx-canister-call
dfx-canister-call:
	@dfx canister --network $(NETWORK) call --output $(CANISTER_OUTPUT) --type $(CANISTER_INPUT) $(CANISTER_NAME) $(CANISTER_METHOD) '$(CANISTER_ARGUMENT)'


.PHONY: dfx-clean
dfx-clean:
	rm -rf .dfx
	rm -rf dist 
	rm -rf src/declarations

# This installs ~/bin/dfx
# Make sure to source ~/.profile afterwards -> it adds ~/bin to the path if it exists
.PHONY: dfx-install
dfx-install:
	sh -ci "$$(curl -fsSL https://sdk.dfinity.org/install.sh)"
	
.PHONY: dfx-canisters-of-project-ic
dfx-canisters-of-project-ic:
	@$(eval CANISTER_WALLET := $(shell dfx identity --network ic get-wallet))
	@$(eval CANISTER_MOTOKO := $(shell dfx canister --network ic id canisterMotoko))
	@$(eval CANISTER_MINTER := $(shell dfx canister --network ic id canisterMinter))
	@$(eval CANISTER_FRONTEND := $(shell dfx canister --network ic id canisterFrontend))

	@echo '-------------------------------------------------'
	@echo "NETWORK            : ic"
	@echo "cycles canister    : $(CANISTER_WALLET)"
	@echo "Candid UI canister : $(CANISTER_CANDID_UI_IC)"
	@echo "canisterMotoko     : $(CANISTER_MOTOKO)"
	@echo "canisterMinter     : $(CANISTER_MINTER)"
	@echo "canisterFrontend   : $(CANISTER_FRONTEND)"
	@echo '-------------------------------------------------'
	@echo 'View in browser at:'
	@echo  "cycles canister               : https://$(CANISTER_WALLET).raw.ic0.app/"
	@echo  "Candid UI                     : https://$(CANISTER_CANDID_UI_IC).raw.ic0.app/"
	@echo  "Candid UI of canisterMotoko   : https://$(CANISTER_CANDID_UI_IC).raw.ic0.app/?id=$(CANISTER_MOTOKO)"
	@echo  "Candid UI of canisterMinter   : https://$(CANISTER_CANDID_UI_IC).raw.ic0.app/?id=$(CANISTER_MINTER)"
	@echo  "Candid UI of canisterFrontend : https://$(CANISTER_CANDID_UI_IC).raw.ic0.app/?id=$(CANISTER_FRONTEND)"
	@echo  "canisterFrontend              : https://$(CANISTER_FRONTEND).ic0.app/"

.PHONY: dfx-canisters-of-project-local
dfx-canisters-of-project-local:
	@$(eval CANISTER_WALLET := $(shell dfx identity get-wallet))
	@$(eval CANISTER_CANDID_UI_LOCAL := $(shell dfx canister id __Candid_UI))
	@$(eval CANISTER_MOTOKO := $(shell dfx canister id canisterMotoko))
	@$(eval CANISTER_MINTER := $(shell dfx canister id canisterMinter))
	@$(eval CANISTER_FRONTEND := $(shell dfx canister id canisterFrontend))

	
	@echo '-------------------------------------------------'
	@echo "NETWORK            : local"
	@echo "cycles canister    : $(CANISTER_WALLET)"
	@echo "Candid UI canister : $(CANISTER_CANDID_UI_LOCAL)"
	@echo "canisterMotoko     : $(CANISTER_MOTOKO)"
	@echo "canisterMinter     : $(CANISTER_MINTER)"
	@echo "canisterFrontend   : $(CANISTER_FRONTEND)"
	@echo '-------------------------------------------------'
	@echo 'View in browser at:'
	@echo  "cycles canister               : ?? http://localhost:8000?canisterId=$(CANISTER_WALLET) ?? "
	@echo  "__Candid_UI                   : http://localhost:8000?canisterId=$(CANISTER_CANDID_UI_LOCAL)"
	@echo  "Candid UI of canisterMotoko   : http://localhost:8000?canisterId=$(CANISTER_CANDID_UI_LOCAL)&id=$(CANISTER_MOTOKO)"
	@echo  "Candid UI of canisterMinter   : http://localhost:8000?canisterId=$(CANISTER_CANDID_UI_LOCAL)&id=$(CANISTER_MINTER)"
	@echo  "Candid UI of canisterFrontend : http://localhost:8000?canisterId=$(CANISTER_CANDID_UI_LOCAL)&id=$(CANISTER_FRONTEND)"
	@echo  "canisterFrontend              : http://localhost:8000?canisterId=$(CANISTER_FRONTEND)"

.PHONY: dfx-canisters-of-project
dfx-canisters-of-project:
	@if [[ ${NETWORK} == "ic" ]]; then \
		make --no-print-directory dfx-canisters-of-project-ic; \
	else \
		make --no-print-directory dfx-canisters-of-project-local; \
	fi

.PHONY: dfx-canister-methods
dfx-canister-methods:
	@[ "${CANISTER}" ]	|| ( echo ">> Define CANISTER: 'make dfx-canister-methods CANISTER=[<canister_id>, --all]' "; exit 1 )
	@echo "NETWORK            : $(NETWORK)"
	@echo "CANISTER           : $(CANISTER)"
	@echo "View the canister's interface (i.e. the candid methods) at :"
	@echo "- Candid UI: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=$(CANISTER)"
	@echo "- icrocks  : https://ic.rocks/principal/$(CANISTER)"
	@echo "- Canlist  : https://k7gat-daaaa-aaaae-qaahq-cai.ic0.app/search?s=$(CANISTER)"
	@echo "-------------------------------------------------------------------------"
	@echo "Checking if it is listed at Canlista"
	@dfx canister --network $(NETWORK) call kyhgh-oyaaa-aaaae-qaaha-cai getCandid '(principal "$(CANISTER)")'

.PHONY: dfx-canister-create
dfx-canister-create:
	@[ "${CANISTER}" ]	|| ( echo ">> Define CANISTER: 'make dfx-canister-create CANISTER=[<canister_id>, --all]' "; exit 1 )
	@echo "NETWORK            : $(NETWORK)"
	@echo "CANISTER           : $(CANISTER)"
	@dfx canister --network $(NETWORK) create $(CANISTER)

.PHONY: dfx-canister-stop
dfx-canister-stop:
	@[ "${CANISTER}" ]	|| ( echo ">> Define CANISTER: 'make dfx-canister-create CANISTER=[<canister_id>, --all]' "; exit 1 )
	@echo "NETWORK            : $(NETWORK)"
	@echo "CANISTER           : $(CANISTER)"
	@dfx canister --network $(NETWORK) stop $(CANISTER)

.PHONY: dfx-canister-delete
dfx-canister-delete:
	@[ "${CANISTER}" ]	|| ( echo ">> Define CANISTER: 'make dfx-canister-delete CANISTER=[<canister_id>, --all]' "; exit 1 )
	@echo "NETWORK            : $(NETWORK)"
	@echo "CANISTER           : $(CANISTER)"
	@dfx canister --network $(NETWORK) stop $(CANISTER)
	@dfx canister --network $(NETWORK) delete $(CANISTER)

.PHONY: dfx-canister-install-upgrade
dfx-canister-install-upgrade:
	@make --no-print-directory dfx-canister-install CANISTER_INSTALL_MODE=upgrade

.PHONY: dfx-canister-install-reinstall
dfx-canister-install-reinstall:
	@make --no-print-directory dfx-canister-install CANISTER_INSTALL_MODE=reinstall

.PHONY: dfx-canister-install
dfx-canister-install:
	@[ "${CANISTER}" ]	|| ( echo ">> Define CANISTER: 'make dfx-canister-install CANISTER=[<canister_id>, --all]' "; exit 1 )
	@echo "NETWORK            : $(NETWORK)"
	@echo "CANISTER           : $(CANISTER)"
	@dfx canister --network $(NETWORK) install --mode $(CANISTER_INSTALL_MODE) $(CANISTER)

.PHONY: dfx-deploy-local
dfx-deploy-local:
	@make --no-print-directory test
	@dfx deploy
	@echo  "All done.... Getting details... "
	@make --no-print-directory dfx-canisters-of-project

.PHONY: dfx-deploy-ic
dfx-deploy-ic:
	
	@echo " "	
	@echo "--Check that working directory is a freshly pulled main branch--"
	@make --no-print-directory git-on-origin-main
	@make --no-print-directory git-no-unstaged-files
	@make --no-print-directory git-no-staged-files
	
	@echo " "	
	@echo "--Test Code--"
	@make --no-print-directory test

	@echo " "
	@echo "--Set commit sha for About page (file: $(COMMIT_JSON))--"
	@echo '{ "sha": "'$$(git log -1 --format='%h')'" }' > $(COMMIT_JSON)
	@cat $(COMMIT_JSON)
	
	@echo " "
	@echo "--Deploy--"
	@dfx deploy --network ic

	@echo " "
	@echo "--Discarding change to file $(COMMIT_JSON) --"
	@git checkout -- $(COMMIT_JSON)
	@cat $(COMMIT_JSON)


	@echo "--All done.... Get canister details..--"
	@make --no-print-directory dfx-canisters-of-project NETWORK=ic

.PHONY: dfx-identity-and-wallet-for-cicd
dfx-identity-and-wallet-for-cicd:
	@echo $(DFX_IDENTITY_PEM_ENCODED) | base64 --decode > identity-cicd.pem
	@dfx identity import cicd ./identity-cicd.pem
	@rm ./identity-cicd.pem
	@dfx identity use cicd
	@dfx identity --network ic set-wallet "$(DFX_WALLET_CANISTER_ID)"

.PHONY: dfx-identity-whoami
dfx-identity-whoami:
	@echo    "NETWORK         : $(NETWORK)"
	@echo -n "whoami          : " && dfx identity --network $(NETWORK) whoami
	@echo "-------------------------------------------------------------------------"
	@echo "principal       : "
	@dfx identity --network $(NETWORK) get-principal

.PHONY: dfx-local-network-start
dfx-local-network-start:
	@dfx start --clean --background

.PHONY: dfx-local-network-stop
dfx-local-network-stop:
	@dfx stop

.PHONY: dfx-wallet-details
dfx-wallet-details:
	@$(eval CANISTER_WALLET := $(shell dfx identity --network $(NETWORK) get-wallet))
	@echo    "NETWORK                 : $(NETWORK)"
	@echo "-------------------------------------------------------------------------"
	@if [[ ${NETWORK} == "ic" ]]; then \
		echo  "View details at         : https://$(CANISTER_WALLET).raw.ic0.app/"; \
	else \
		echo  "View details at         : ?? http://localhost:8000?canisterId=$(CANISTER_WALLET) ?? "; \
	fi
	
	@echo "-------------------------------------------------------------------------"
	@echo -n "cycles canister id      : " && dfx identity --network $(NETWORK) get-wallet
	@echo -n "cycles canister name    : " && dfx wallet --network $(NETWORK) name
	@echo -n "cycles canister balance : " && dfx wallet --network $(NETWORK) balance
	@echo "-------------------------------------------------------------------------"
	@echo "controllers: "
	@dfx wallet --network $(NETWORK) controllers
	@echo "-------------------------------------------------------------------------"
	@echo "custodians: "
	@dfx wallet --network $(NETWORK) custodians
	@echo "-------------------------------------------------------------------------"
	@echo "addresses: "
	@dfx wallet --network $(NETWORK) addresses

.PHONY: dfx-wallet-controller-add
dfx-wallet-controller-add:
	@[ "${PRINCIPAL}" ]	|| ( echo ">> Define PRINCIPAL to add as controller: 'make dfx-cycles-controller-add PRINCIPAL=....' "; exit 1 )
	@echo    "NETWORK         : $(NETWORK)"
	@echo    "PRINCIPAL       : $(PRINCIPAL)"
	@dfx wallet --network $(NETWORK) add-controller $(PRINCIPAL)

.PHONY: dfx-wallet-controller-remove
dfx-wallet-controller-remove:
	@[ "${PRINCIPAL}" ]	|| ( echo ">> Define PRINCIPAL to remove as controller: 'make dfx-cycles-controller-remove PRINCIPAL=....' "; exit 1 )
	@echo    "NETWORK         : $(NETWORK)"
	@echo    "PRINCIPAL       : $(PRINCIPAL)"
	@dfx wallet --network $(NETWORK) remove-controller $(PRINCIPAL)

.PHONY: javascript-install
javascript-install:
	./scripts/dracula_ui_install.sh
	npm install

.PHONY: javascript-format
javascript-format:
	@echo "---"
	@echo "javascript-format"
	npm run format:write

.PHONY: javascript-format-check
javascript-format-check:
	@echo "---"
	@echo "javascript-format-check"
	npm run format:check

.PHONY: javascript-lint
javascript-lint:
	@echo "---"
	@echo "javascript-lint"
	npm run lint:fix

.PHONY: javascript-lint-check
javascript-lint-check:
	@echo "---"
	@echo "javascript-lint-check"
	npm run lint:check

.PHONY: python-install
python-install:
	pip install --upgrade pip
	pip install -r requirements-dev.txt

.PHONY: python-clean
python-clean:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f  {} +

.PHONY: python-format
python-format:
	@echo "---"
	@echo "python-format"
	python -m black scripts src

.PHONY: python-format-check
python-format-check:
	@echo "---"
	@echo "python-format-check"
	python -m black --check scripts src

.PHONY: python-lint
python-lint:
	@echo "---"
	@echo "python-lint"
	python -m pylint --jobs=0 --rcfile=.pylintrc scripts src

.PHONY: python-lint-check
python-lint-check:
	@echo "---"
	@echo "python-lint-check"
	python -m pylint --jobs=0 --rcfile=.pylintrc scripts src

.PHONY: python-type-check
python-type-check:
	@echo "---"
	@echo "python-type-check"
	python -m mypy --config-file .mypy.ini --show-column-numbers --strict scripts

.PHONY: jp-install
jp-install:
	sudo apt update && sudo apt install jp
	@echo $(NEWLINE)
	@jp --version

.PHONY: test
test:
	@echo ' '
	@echo 'Check format with prettier'
	@npm run format:check
	@echo ' '
	@echo 'Check linting with eslint'
	@npm run lint:check

.PHONY: git-no-unstaged-files
git-no-unstaged-files:
	@if [[ $$(git diff --name-only) ]]; then \
		echo " "; \
		echo "Unstaged Files ($$(git diff --name-only | wc -w)):"; \
		git diff --name-only | awk '{print "- " $$1}'; \
		echo " "; \
		echo "There are unstaged files in your working directory."; \
		echo "Please only deploy to ic from a freshly pulled main branch."; \
		echo " "; \
		exit 1; \
	else \
		echo "Ok, you have no unstaged files in your working directory." ;\
	fi

.PHONY: git-no-staged-files
git-no-staged-files:
	@if [[ $$(git diff --cached --name-only) ]]; then \
		echo " "; \
		echo "Staged Files ($$(git diff --cached --name-only | wc -w)):"; \
		git diff --cached --name-only | awk '{print "- " $$1}'; \
		echo " "; \
		echo "There are staged files in your working directory."; \
		echo "Please only deploy to ic from a freshly pulled main branch."; \
		echo " "; \
		exit 1; \
	else \
		echo "Ok, you have no staged files in your working directory." ;\
	fi

.PHONY: git-on-origin-main
git-on-origin-main:
	@if [[ $$(git log origin/main..HEAD --first-parent --oneline | awk '{print $$1}' | wc -w) > 0 ]]; then \
		echo " "; \
		echo "Your working directory is not at origin/main:"; \
		git log origin/main..HEAD --first-parent --oneline --boundary; \
		echo " "; \
		echo "Please only deploy to ic from a freshly pulled main branch."; \
		echo " "; \
		exit 1; \
	else \
		echo "Ok, your working directory is at orgin/main" ;\
	fi

.PHONY: wabt-install
wabt-install:
	sudo apt update && sudo apt install wabt