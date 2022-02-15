#!/bin/sh

case "$(echo | nc 127.0.0.1 10024 -w1)" in
	"220"*" ready"*)
		echo "amavis ready"
		;;
	*)
		echo "amavis not responding"
		exit 1
		;;
esac
