#!/bin/bash

debinstall () {
    apt-get update
    apt-get upgrade -y
    apt-get install -y gcc make git libssl-dev screen curl
    if [[ ! -e /etc/apt/sources.list.d/nodesource.list ]]; then
        curl -sL https://deb.nodesource.com/setup_10.x | bash -
    fi
    apt-get install -y nodejs
}

webqqinstall () {
    if [[ -z $((echo l;echo q) | instmodsh | grep App::cpanminus) ]]; then
        (echo yes) | cpan -i App::cpanminus
    fi
    if [[ -z $((echo l;echo q) | instmodsh | grep Mojo::Webqq) ]]; then
        cpanm Crypt::OpenSSL::RSA Crypt::OpenSSL::Bignum Webqq::Encryption Mojo::Webqq
    fi
    if [[ -z $(curl -ks "https://raw.githubusercontent.com/sjdy521/Mojo-Webqq/master/script/check_dependencies.pl"|perl - | grep 12/12) ]]; then
        curl -ks "https://raw.githubusercontent.com/sjdy521/Mojo-Webqq/master/script/check_dependencies.pl"|perl - 
        exit
    fi
}

ffminstall () {
    if [[ ! -e ./FCM-for-Mojo-Server ]]; then
        git clone https://github.com/RikkaApps/FCM-for-Mojo-Server.git
        cd FCM-for-Mojo-Server
        cp config.example.js config.js
        npm install
    fi
}

ffmupgrade () {
    cd FCM-for-Mojo-Server
    git pull
    npm install
}

ffmstart () {
    if [[ -z $(screen -ls | grep ffm) ]]; then
        screen -dmS ffm
        screen -S ffm -X stuff 'cd FCM-for-Mojo-Server/\n'
        screen -S ffm -X stuff 'npm start\n'
    fi
}

ffmrestart () {
    ffmstop
    ffmstart
}

ffmstop () {
    if [[ -n $(screen -ls | grep ffm) ]]; then
        screen -S ffm -X stuff '^C'
        sleep 1
        screen -S ffm -X stuff 'exit\n'
    fi
}

case "$1" in
  start)
    ffmstart
    ;;
  stop)
    ffmstop
    ;;
  restart)
    ffmrestart
    ;;
  upgrade)
    ffmstop
    ffmupgrade
    ;;
  install)
    debinstall
    webqqinstall
    ffminstall
    ;;
    *)
    echo "ffm {start|stop|restart|upgrade|install}"
    exit 1
esac

exit 0