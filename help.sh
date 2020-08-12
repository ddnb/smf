#!/bin/bash

readonly NAME=${DIR/-/} # Scrip hyphen
readonly REPO_NAME=${DIR}
readonly REPO="https://github.com/ddnb/$NAME"
readonly CODE_PATH="/code"
readonly PUBLIC_PATH="/code/public_html"
readonly FULL_PATH="$( cd "$( dirname "$0" )" && pwd )"
readonly LOCALHOST="127.0.0.1"

helps() {
	case $1 in
		all|*) allhelps ;;
	esac
}

allhelps() {
cat <<EOF
Usage: ./help.sh COMMAND
[help|usage|build|init|up|down|restart|status|logs|ssh]
[Commands]
  build        Build docker service
  up or start  Run docker-compose as daemon (or up)
  down or stop Terminate all docker containers run by docker-compose (or down)
  restart      Restart docker-compose containers
  status       View docker containers status
  logs         View docker containers logs
  ssh          ssh cli
  open         open localhost test page
EOF
}

# Usage
usage() {
	echo "Usage:"
	echo "${0} [help|usage|build|init|up|down|restart|status|logs|ssh]"
}

# Docker compose build
build() {
	docker-compose build
}

# Docker compose up
start() {
	docker-compose up -d
}

# Docker compose down
stop() {
	docker-compose down
}

# Docker compose restart
restart() {
	docker-compose restart
}

# Docker compose status
run_status() {
	docker-compose ps;
}

# Docker compose logs
logs() {
	case $2 in
		liho|*)  docker-compose logs ;;
	esac
}

# ssh cli
dockerssh() {
	case $1 in
		*) docker-compose exec php /bin/bash ;;
	esac
}

# open test page
run_open() {
	case $2 in
		*)  open http://localhost:38087 ;;
	esac
}

run_init() {
	case $2 in
		*) rsync -avz ${FULL_PATH}/env ${FULL_PATH}/.env ;;
	esac
}

run_db() {
	case $2 in
		reset|truncate)
			readonly DROP_DB="mysqladmin -uddnb -pddnbPassword drop ddnb_smf"
			readonly CREATE_DB="mysqladmin -uddnb -pddnbPassword create ddnb_smf"
			docker-compose exec mysql /bin/bash -c "$DROP_DB"
			docker-compose exec mysql /bin/bash -c "$CREATE_DB"
		;;
		restore)
			readonly RESTORE_DB="mysql -uddnb -pddnbPassword ddnb_smf < /code/sql/init.sql"
			docker-compose exec mysql /bin/bash -c "$RESTORE_DB"
		;;
		dump)
			readonly DUMP_DB="mysqldump -uddnb -pddnbPassword ddnb_smf > /code/sql/`date +%Y%m%d`_smf.sql"
			docker-compose exec mysql /bin/bash -c "$DUMP_DB"
		;;
		*|help) echo "Help";;
	esac
}

case $1 in
	open) run_open ${1} ${2};;
	init) run_init ${2};;
	build) build ;;
	start|up) start ;;
	stop|down) stop ;;
	restart|reboot) restart ;;
	status|ps) run_status ${1:-help} ${2} ${3} ${4} ${5} ;;
	logs) logs ${2:-all} ;;
	ssh) dockerssh ${2:-php} ;;
	db) run_db ${1:-help} ${2} ${3} ${4} ${5} ;;
	*) helps ;;
esac