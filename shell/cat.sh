#!/bin/bash
cnt=0
while read t_line; do
	let cnt=$cnt+1;
done
echo $cnt
