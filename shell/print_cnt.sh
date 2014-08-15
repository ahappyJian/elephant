#!/bin/sh
for ((i=0; i<20; i++)) do
	ts=$(printf '%04d' $i)
	echo $ts
done
