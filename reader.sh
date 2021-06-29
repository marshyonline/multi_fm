cd /root/SDR/
mkfifo ./ch0.out ./ch1.out ./ch2.out
multifm multifm_config.json pocsag_narrow.json &

multimon-ng -q -b1 -c -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -t raw ./ch0.out 2>> /var/log/multimon-ng-voda.log   | node reader-voda.js 148.5625&
multimon-ng -q -b1 -c -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -t raw ./ch1.out 2>> /var/log/multimon-ng-rfs.log    | node reader-rfs.js 148.5875&
multimon-ng -q -b1 -c -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -t raw ./ch2.out 2>> /var/log/multimon-ng-custom.log | node reader-custom.js 148.9625&
wait
echo "KILLED"
