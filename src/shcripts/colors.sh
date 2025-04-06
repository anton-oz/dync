#!/usr/bin/env bash

ESC="\033["
NC="${ESC}0m"

FG="${ESC}38;5;"
BG="${ESC}48;5;"

FG_BLUE="${FG}39m"
FG_RED="${FG}196m"

BG_BLACK="${BG}16m"

DIR="${FG_BLUE}${BG_BLACK}"

ERROR="${FG_RED}${BG_BLACK} ERROR: ${NC}"
