PROFILE = default
ENVIRONMENT = sbx
PREFIX = niroop
PROFILE = default
BUCKETNAME = s3snstest

.PHONY: explain
explain:
	#                                                                                                                                                        
		# PPPPPPPPPPPPPPPPP   IIIIIIIIIIPPPPPPPPPPPPPPPPP   EEEEEEEEEEEEEEEEEEEEEELLLLLLLLLLL             IIIIIIIIIINNNNNNNN        NNNNNNNNEEEEEEEEEEEEEEEEEEEEEE
		# P::::::::::::::::P  I::::::::IP::::::::::::::::P  E::::::::::::::::::::EL:::::::::L             I::::::::IN:::::::N       N::::::NE::::::::::::::::::::E
		# P::::::PPPPPP:::::P I::::::::IP::::::PPPPPP:::::P E::::::::::::::::::::EL:::::::::L             I::::::::IN::::::::N      N::::::NE::::::::::::::::::::E
		# PP:::::P     P:::::PII::::::IIPP:::::P     P:::::PEE::::::EEEEEEEEE::::ELL:::::::LL             II::::::IIN:::::::::N     N::::::NEE::::::EEEEEEEEE::::E
		#  P::::P     P:::::P  I::::I    P::::P     P:::::P  E:::::E       EEEEEE  L:::::L                 I::::I  N::::::::::N    N::::::N  E:::::E       EEEEEE
		#  P::::P     P:::::P  I::::I    P::::P     P:::::P  E:::::E               L:::::L                 I::::I  N:::::::::::N   N::::::N  E:::::E             
		#  P::::PPPPPP:::::P   I::::I    P::::PPPPPP:::::P   E::::::EEEEEEEEEE     L:::::L                 I::::I  N:::::::N::::N  N::::::N  E::::::EEEEEEEEEE   
		#  P:::::::::::::PP    I::::I    P:::::::::::::PP    E:::::::::::::::E     L:::::L                 I::::I  N::::::N N::::N N::::::N  E:::::::::::::::E   
		#  P::::PPPPPPPPP      I::::I    P::::PPPPPPPPP      E:::::::::::::::E     L:::::L                 I::::I  N::::::N  N::::N:::::::N  E:::::::::::::::E   
		#  P::::P              I::::I    P::::P              E::::::EEEEEEEEEE     L:::::L                 I::::I  N::::::N   N:::::::::::N  E::::::EEEEEEEEEE   
		#  P::::P              I::::I    P::::P              E:::::E               L:::::L                 I::::I  N::::::N    N::::::::::N  E:::::E             
		#  P::::P              I::::I    P::::P              E:::::E       EEEEEE  L:::::L         LLLLLL  I::::I  N::::::N     N:::::::::N  E:::::E       EEEEEE
		# PP::::::PP          II::::::IIPP::::::PP          EE::::::EEEEEEEE:::::ELL:::::::LLLLLLLLL:::::LII::::::IIN::::::N      N::::::::NEE::::::EEEEEEEE:::::E
		# P::::::::P          I::::::::IP::::::::P          E::::::::::::::::::::EL::::::::::::::::::::::LI::::::::IN::::::N       N:::::::NE::::::::::::::::::::E
		# P::::::::P          I::::::::IP::::::::P          E::::::::::::::::::::EL::::::::::::::::::::::LI::::::::IN::::::N        N::::::NE::::::::::::::::::::E
		# PPPPPPPPPP          IIIIIIIIIIPPPPPPPPPP          EEEEEEEEEEEEEEEEEEEEEELLLLLLLLLLLLLLLLLLLLLLLLIIIIIIIIIINNNNNNNN         NNNNNNNEEEEEEEEEEEEEEEEEEEEEE
		#
		### Targets
	#
	@cat Makefile* | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: create_stack
create_stack: ## creates the infrastructure using the cfn template
	make create_update_pipeline ACTION=create

.PHONY: update_stack
update_stack: ## updates the infrastructure using the cfn template
	make create_update_pipeline ACTION=update

.PHONY: validate_template
validate_template: ## validates the yaml file
	aws cloudformation validate-template --template-body file://codepipeline.yml

.PHONY: create_update_pipeline
create_update_pipeline: ## Creates or updates the infrastructure using the cfn template
	aws cloudformation ${ACTION}-stack \
		--stack-name $(PREFIX)-$(ENVIRONMENT)-s3updates \
		--template-body file://s3updates-stack.yml \
		--profile $(PROFILE) \
		--capabilities CAPABILITY_AUTO_EXPAND \
		--region "eu-west-2" \
		--parameters \
			ParameterKey=Prefix,ParameterValue=$(PREFIX) \
			ParameterKey=Environment,ParameterValue=$(ENVIRONMENT) \
			ParameterKey=BucketName,ParameterValue=$(BUCKETNAME) \
			ParameterKey=GitHubOwner,ParameterValue=$(GITHUBOWNER) \
			ParameterKey=GitHubRepo,ParameterValue=$(GITHUBREPO) \
			ParameterKey=GitHubBranch,ParameterValue=$(GITHUBBRANCH) \
			ParameterKey=GitToken,ParameterValue=$(GITTOKEN) \




