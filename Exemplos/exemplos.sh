#!/bin/sh
n=1
while [ $n -le 50 ]
do
./compilador exemplo$n.txt
(( n++ ))
done
