#!/bin/bash

# Visit https://www.alt-codes.net/flags for more flags

# Local timezone
TODAY=$(date +"| Today is %A, %d of %B  |")
TIMENOW=$(date +"| Local time         🌍%r |")

# Stock Exchange Hours
TIME_NYSE=$(TZ='America/New_York' date +"| New York  (NYSE)   🇺🇸%r |")
NASDAQ="| NASDAQ                           |"
TIME_SSE=$(TZ='Asia/Shanghai' date +"| Shanghai  (SSE)    🇨🇳%r |")
SZSE="| Shenzhen  (SZSE)                 |"
TIME_JPX=$(TZ=Japan date +"| Tokyo     (JPX)    🇯🇵%r |")
TIME_TSX=$(TZ='Canada/Eastern' date +"| Toronto   (TSX)    🇨🇦%r |")
TIME_LSE=$(TZ='Europe/London' date +"| London    (LSE)    🇬🇧%r |")

# Printing info
line="|==================================|"

paste <(

# Stock exchange
echo $line
echo "|        █▀ ▀█▀ █▀█ █▀▀ █▄▀        |
|        ▄█ ░█░ █▄█ █▄▄ █░█        |
|                                  |
| █▀▀ ▀▄▀ █▀▀ █░█ ▄▀█ █▄░█ █▀▀ █▀▀ |
| ██▄ █░█ █▄▄ █▀█ █▀█ █░▀█ █▄█ ██▄ |"
echo -e $line "\n"$line

printf "%s\n%s\n%s\n" "$TIME_NYSE" "$NASDAQ" "$line"
printf "%s\n%s\n%s\n" "$TIME_SSE" "$SZSE" "$line"
printf "%s\n%s\n" "$TIME_JPX" "$line"
printf "%s\n%s\n" "$TIME_TSX" "$line"
printf "%s\n%s\n" "$TIME_LSE" "$line"

) <(

# Local
echo $line
echo "|       █░░ █▀█ █▀▀ ▄▀█ █░░        |
|       █▄▄ █▄█ █▄▄ █▀█ █▄▄        |"
echo -e $line "\n"$line

printf "%s\n%s\n" "$TODAY" "$TIMENOW"
echo $line

)
